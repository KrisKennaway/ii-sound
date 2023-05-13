#!/usr/bin/env python3
# Delta modulation audio encoder for playback via Uthernet II streaming.
#
# Simulates the Apple II speaker at 1MHz (i.e. cycle-level) resolution,
# by modeling it as a damped harmonic oscillator.
#
# On the Apple II side we use an audio player that is able to toggle the
# speaker with 1MHz precision, i.e. on any CPU clock cycle, although with a
# lower limit of 10 cycles between toggles (i.e. 102KHz maximum
# frequency).
#
# In order to reproduce a target audio waveform, we upscale it to 1MHz sample
# rate, i.e. to determine the desired speaker position at every CPU clock
# cycle, and compute the sequence of player operations on the Apple II side to
# best reproduce this waveform.
#
# This means that we are able to control the Apple II speaker with cycle-level
# precision, which results in high audio fidelity with low noise.
#
# To further optimize the audio quality we look ahead some defined number of
# cycles and choose a speaker trajectory that minimizes errors over this range.
# e.g. this allows us to anticipate large amplitude changes by pre-moving
# the speaker to better approximate them.
#
# This also needs to take into account scheduling the "end of frame" opcode
# every 2048 output bytes, where the Apple II will manage the TCP socket buffer
# while ticking the speaker at a regular (a, b) cadence to attempt to
# continue tracking the waveform as best we can.  Since we are stepping away
# from cycle-level management of the speaker during this period, it does
# introduce some quality degradation (manifesting as a slight background
# "crackle" to the audio)

import argparse
import collections
import contextlib
import functools
import librosa
import numpy
import soundfile as sf
from eta import ETA
from typing import Tuple

import lookahead
import opcodes
import opcodes_generated

# How many bytes to use per frame in the audio stream.  At the end of each
# frame we need to switch to special end-of-frame operations to cause the
# Apple II to manage the TCP socket buffers (ACK data received so far, and
# check we have at least another frame of data available)
#
# With an 8KB socket buffer this seems to be about the maximum we can get away
# with - it has to be page aligned, and 4KB causes stuttering even from a
# local playback source.
FRAME_SIZE = 2048


class Speaker:
    """Simulates the response of the Apple II speaker."""

    # TODO: move lookahead.evolve into Speaker method

    def __init__(self, sample_rate: float, freq: float, damping: float,
                 scale: float):
        """Initialize the Speaker object

        :arg sample_rate The sample rate of the simulated speaker (Hz)
        :arg freq The resonant frequency of the speaker
        :arg damping The exponential decay factor of the speaker response
        :arg scale Scale factor to normalize speaker position to desired range
        """
        self.sample_rate = sample_rate
        self.freq = freq
        self.damping = damping
        self.scale = numpy.float64(scale)  # TODO: analytic expression

        # See _Signal Processing in C_, C. Reid, T. Passin
        # https://archive.org/details/signalprocessing0000reid/
        dt = numpy.float64(1 / sample_rate)
        w = numpy.float64(freq * 2 * numpy.pi * dt)

        d = damping * dt
        e = numpy.exp(d)
        c1 = 2 * e * numpy.cos(w)
        c2 = e * e

        # Square wave impulse response parameters
        b2 = 0.0
        b1 = 1.0

        self.c1 = c1
        self.c2 = c2
        self.b1 = b1
        self.b2 = b2

def total_error(positions: numpy.ndarray, data: numpy.ndarray) -> numpy.ndarray:
    """Computes the total squared error for speaker position matrix vs data."""

    # Deal gracefully with the case where our speaker operation would slightly
    # run past the end of data
    min_len = min(len(positions), len(data))
    return numpy.sum(numpy.square(positions[:min_len] - data[:min_len]),
                     axis=-1)


@functools.lru_cache(None)
def frame_horizon(frame_offset: int, lookahead_steps: int):
    """Optimize frame_offset when more than lookahead_steps from end of frame.

    Candidate opcodes for all values of frame_offset are equal, until the
    end-of-frame opcode comes within our lookahead horizon.  This avoids
    needing to recompute many copies of the same candidate opcodes.

    TODO: this is a bit of a hack and we should be able to make the candidate
      opcode selection itself smarter about avoiding duplicate work
    """
    # TODO: This could be made tighter because a step is always at least 5
    #  cycles towards lookahead_steps.
    if frame_offset < (FRAME_SIZE - lookahead_steps):
        return 0
    return frame_offset


def audio_bytestream(data: numpy.ndarray, step: int, lookahead_steps: int,
                     sample_rate: int):
    """Computes optimal sequence of player opcodes to reproduce audio data."""
    # At resonance freq the scale is about 22400 but we can only access about 7%
    # of it across the frequency range.  This is also the equilibrium speaker
    # position when voltage is held constant. Normalize to this working
    # range for convenience.
    inv_scale = 22400 * 0.07759626164027278  # XXX

    # Speaker response parameters can be fitted in several ways.  First, by
    # recording audio of
    # - a single speaker click (impulse response)
    # - a frequency sweep over the entire audible spectrum
    #
    # Resonant frequency can be read off from the frequency spectrum.  For my
    # speaker there were two primary frequencies, at ~3875 and ~480Hz.
    # Looking at the click waveform the higher frequency mode dominates at
    # short time scales, and the lower frequency mode dominates at late
    # times.  Since we're interested in short timescale speaker control we
    # can ignore the latter.
    #
    # Damping factor can be estimated by fitting against the speaker click
    # waveform or the spectrum, e.g. by simulating a speaker click and then
    # computing its spectrum.
    #
    # TODO: other Apple II speakers almost certainly have different response
    #  characteristics, but hopefully not too widely varying.
    sp = Speaker(sample_rate, freq=3875, damping=-1210, scale=1 / inv_scale)

    # Starting speaker applied voltage.
    voltage1 = voltage2 = 1.0

    # last 2 speaker positions.
    # XXX 0.0?
    y1 = y2 = 1.0

    # Leave enough padding at the end to look ahead from the last data value,
    # and in case we schedule an end-of-frame opcode towards the end.
    # TODO: avoid temporarily doubling memory footprint to concatenate
    data = numpy.ascontiguousarray(numpy.concatenate(
        [data, numpy.zeros(max(lookahead_steps, opcodes.cycle_length(
            opcodes_generated.PlayerOps.TICK_00)), dtype=numpy.float32)]))

    # index within input audio data
    i = 0
    # Position in 2048-byte TCP frame
    frame_offset = 0

    # Total squared error of audio output
    total_err = 0.0

    # Keep track of how many large deviations we see from the target waveform
    # as another measure of audio quality
    clicks = 0
    # total squared error threshold to consider an operation as producing a
    # click
    click_threshold = 0.3

    # Keep track of how many opcodes we schedule, so we can print summary
    # statistics at the end
    opcode_counts = collections.defaultdict(int)

    # Always look ahead at least this many cycles.  We pick a higher value
    # when approaching end of frame, so we can maximize the
    min_lookahead_steps = lookahead_steps

    # Progress tracker
    # TODO: find a more adaptive ETA tracker, this one doesn't estimate well
    #   if the processing rate changes (which it does for us, since first few
    #   steps do extra work to precompute values that are cached for later
    #   steps)
    eta = ETA(total=1000, min_ms_between_updates=0)
    # Value of i at which we should next update eta
    next_eta_tick = 0

    while i < len(data):
        if i >= next_eta_tick:
            eta.print_status()
            next_eta_tick = int(eta.i * len(data) / 1000)

        if frame_offset >= (FRAME_SIZE - 5):  # XXX
            lookahead_steps = min_lookahead_steps + 130  # XXX parametrize
        else:
            lookahead_steps = min_lookahead_steps

        # The EOF opcodes need to act as a matched pair, so if we're emitting
        # the second one we need to pass in its predecessor
        last_opcode = opcode if frame_offset == FRAME_SIZE - 1 else None

        # Compute all possible opcode sequences we could emit starting at this
        # frame offset
        next_candidate_opcodes, voltages, lookahead_steps = \
            opcodes.candidate_opcodes(
                frame_horizon(frame_offset, lookahead_steps),
                lookahead_steps, last_opcode)

        # Simulate speaker trajectory for all of these  candidate opcode
        # sequences and pick the one that minimizes total error
        opcode_idx = lookahead.evolve_return_best(
            sp, y1, y2, voltage1, voltage2, voltage1 * voltages,
            data[i:i + lookahead_steps])
        opcode = next_candidate_opcodes[opcode_idx]
        opcode_length = opcodes.cycle_length(opcode)
        opcode_counts[opcode] += 1

        # Apply this opcode to evolve the speaker position
        opcode_voltages = (voltage1 * opcode.voltages).reshape((1, -1))
        all_positions = lookahead.evolve(
            sp, y1, y2, voltage1, voltage2, opcode_voltages)

        assert all_positions.shape[0] == 1
        assert all_positions.shape[1] == opcode_length

        # Update to new speaker state
        voltage1 = opcode_voltages[0, -1]
        voltage2 = opcode_voltages[0, -2]
        y1 = all_positions[0, -1]
        y2 = all_positions[0, -2]

        # Track accumulated error between desired and actual speaker trajectory
        new_error = total_error(
            all_positions[0] * sp.scale, data[i:i + opcode_length]).item()
        total_err += new_error
        if new_error > click_threshold:
            clicks += 1
            # XXX
            print(frame_offset, i / sample_rate, opcode, new_error,
                  numpy.mean(data[i:i + opcode_length]))

        # Emit chosen operation and simulated audio samples for recording
        yield opcode, numpy.array(
            all_positions * sp.scale, dtype=numpy.float32).reshape(-1)

        # Update input and output stream positions
        i += opcode_length
        frame_offset = (frame_offset + 1) % FRAME_SIZE

    # Make sure we have at least 2k left in stream so the player will do a
    # complete read of the last frame.
    # for _ in range(frame_offset % 2048, 2048):
    #     yield opcodes.Opcode.EXIT
    eta.done()

    # Print summary statistics
    print("Total error %f" % total_err)
    print("%d clicks" % clicks)
    print("Opcodes used:")
    for v, k in sorted(list(opcode_counts.items()), key=lambda kv: kv[1],
                       reverse=True):
        print("%s: %d" % (v, k))


def preprocess_audio(
        filename: str, target_sample_rate: int, normalize: float,
        normalization_percentile: int) -> numpy.ndarray:
    """Upscale input audio to target sample rate and normalize signal."""

    data, _ = librosa.load(filename, sr=target_sample_rate, mono=True)

    max_value = numpy.percentile(data, normalization_percentile)
    data /= max_value
    data *= normalize

    return data


def downsample_audio(simulated_audio, original_audio, input_rate, output_rate,
                     noise_output=False):
    """Downscale the 1MHz simulated audio output suitable for writing as .wav

    :arg simulated_audio The simulated audio data to downsample
    :arg original_audio The original audio data that was simulated
    :arg input_rate Sample rate of input audio
    :arg output_rate Desired sample rate of output audio
    :arg noise_output Whether to also produce a noise waveform, i.e. difference
      between input and output audio

    :returns Tuple of downsampled audio and noise data (or None
    if noise_output==False)
    """
    downsampled_output = librosa.resample(
        numpy.array(simulated_audio, dtype=numpy.float32),
        orig_sr=input_rate,
        target_sr=output_rate)

    downsampled_noise = None
    if noise_output:
        noise_len = min(len(simulated_audio), len(original_audio))
        downsampled_noise = librosa.resample(
            numpy.array(
                simulated_audio[:noise_len] - original_audio[:noise_len]),
            orig_sr=input_rate,
            target_sr=output_rate)

    return downsampled_output, downsampled_noise


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--clock", choices=['pal', 'ntsc'],
                        help="Whether target machine clock speed is PAL ("
                             "1015657Hz) or NTSC (1020484)",
                        required=True)
    # TODO: implement 6502 - JMP indirect takes 5 cycles instead of 6
    parser.add_argument("--step_size", type=int,
                        help="Delta encoding step size")
    # TODO: if we're not looking ahead beyond the longest (non-end-of-frame)
    #  opcode then this will reduce quality, e.g. two opcodes may truncate to
    #  the same prefix, but have different results when we apply them
    #  fully.
    parser.add_argument("--lookahead_cycles", type=int,
                        help="Number of clock cycles to look ahead in audio "
                             "stream.")
    parser.add_argument("--normalization", default=0.8, type=float,
                        help="Overall multiplier to rescale input audio "
                             "values.")
    parser.add_argument("--norm_percentile", default=100,
                        help="Normalize to specified percentile value of input "
                             "audio")
    parser.add_argument("--wav_output", type=str, help="output audio file")
    parser.add_argument("--noise_output", type=str, help="output audio file")
    parser.add_argument("input", type=str, help="input audio file to convert")
    parser.add_argument("output", type=str, help="output audio file")
    args = parser.parse_args()

    # Effective clock rate, including every-65 cycle "long cycle" that takes
    # 16/14 as long.
    cpu_clock_rate = 1015657 if args.clock == 'pal' else 1020484  # NTSC

    input_audio = preprocess_audio(
        args.input, cpu_clock_rate, args.normalization, args.norm_percentile)
    print("Done preprocessing audio")

    # Sample rate for output .wav files
    # TODO: flag
    output_rate = 44100

    # Buffers simulated audio output so we can downsample it in suitably
    # large chunks for writing to the output .wav file
    output_buffer = []

    # Python contexts for writing output files if requested
    opcode_context = open(args.output, "wb+")
    if args.wav_output:
        wav_context = sf.SoundFile(
            args.wav_output, "w", output_rate, channels=1, format='WAV')
    else:
        # We're not creating a file but still need a context
        # XXX does this work?
        wav_context = contextlib.nullcontext()
    if args.noise_output:
        noise_context = sf.SoundFile(
            args.noise_output, "w", output_rate, channels=1,
            format='WAV')
    else:
        # We're not creating a file but still need a context
        noise_context = contextlib.nullcontext()

    with wav_context as wav_f, noise_context as noise_f, opcode_context \
            as opcode_f:
        # Tracks current position in input audio waveform
        input_offset = 0

        # Process input audio, writing output to ][-Sound audio file
        # and (if requested) .wav files of simulated speaker audio and
        # noise (difference between original and simulated audio)
        for idx, sample_data in enumerate(audio_bytestream(
                input_audio, args.step_size, args.lookahead_cycles,
                cpu_clock_rate)):
            opcode, samples = sample_data
            opcode_f.write(bytes([opcode.byte]))

            output_buffer.extend(samples)
            input_offset += len(samples)
            # Keep accumulating as long as we have <1MB in the buffer, or are
            # within 1MB from the end.  This ensures we have enough samples to
            # downsample, including the last (partial) buffer.
            if (
                    len(output_buffer) < 1 * 1024 * 1024 or (
                    len(input_audio) - input_offset) < 1 * 1024 * 1024
            ):
                continue

            # TODO: don't bother computing if we're not writing wavs
            downsampled_audio, downsampled_noise = downsample_audio(
                output_buffer, input_audio[input_offset - len(output_buffer):],
                cpu_clock_rate, output_rate, bool(args.noise_output)
            )
            if args.wav_output:
                wav_f.write(downsampled_audio)
                wav_f.flush()
            if args.noise_output:
                noise_f.write(downsampled_noise)
                noise_f.flush()

            output_buffer = []

        # TODO: handle last buffer more cleanly than duplicating this code
        if output_buffer:
            downsampled_audio, downsampled_noise = downsample_audio(
                output_buffer, input_audio[input_offset - len(output_buffer):],
                cpu_clock_rate, output_rate, bool(args.noise_output)
            )
            if args.wav_output:
                wav_f.write(downsampled_audio)
            if args.noise_output:
                noise_f.write(downsampled_noise)


if __name__ == "__main__":
    main()
