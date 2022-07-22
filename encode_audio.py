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


def total_error(positions: numpy.ndarray, data: numpy.ndarray) -> numpy.ndarray:
    """Computes the total squared error for speaker position matrix vs data."""
    return numpy.sum(numpy.square(positions - data), axis=-1)


@functools.lru_cache(None)
def frame_horizon(frame_offset: int, lookahead_steps: int):
    """Optimize frame_offset when more than lookahead_steps from end of frame.

    Candidate opcodes for all values of frame_offset are equal, until the
    end-of-frame opcode comes within our lookahead horizon.
    """
    # TODO: This could be made tighter because a step is always at least 5
    #  cycles towards lookahead_steps.
    if frame_offset < (FRAME_SIZE - lookahead_steps):
        return 0
    return frame_offset


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


def audio_bytestream(data: numpy.ndarray, step: int, lookahead_steps: int,
                     sample_rate: int):
    """Computes optimal sequence of player opcodes to reproduce audio data."""

    dlen = len(data)
    # Leave enough padding at the end to look ahead from the last data value,
    # and in case we schedule an end-of-frame opcode towards the end.
    # TODO: avoid temporarily doubling memory footprint to concatenate
    data = numpy.ascontiguousarray(numpy.concatenate(
        [data, numpy.zeros(max(lookahead_steps, opcodes.cycle_length(
            opcodes_generated.PlayerOps.TICK_00)), dtype=numpy.float32)]))

    # At resonance freq the scale is about 22400 but we can only access about 7%
    # of it across the frequency range.  This is also the equilibrium speaker
    # position when voltage is held constant. Normalize to this working
    # range for convenience.
    inv_scale = 22400 * 0.07759626164027278  # XXX

    # Starting speaker applied voltage.
    voltage1 = voltage2 = 1.0
    # last 2 speaker positions.
    # XXX 0.0?
    y1 = y2 = 1.0

    sp = Speaker(sample_rate, freq=3875, damping=-1210, scale=1 / inv_scale)

    total_err = 0.0  # Total squared error of audio output
    frame_offset = 0  # Position in 2048-byte TCP frame
    i = 0  # index within input data
    eta = ETA(total=1000, min_ms_between_updates=0)
    next_tick = 0  # Value of i at which we should next update eta
    # Keep track of how many opcodes we schedule
    opcode_counts = collections.defaultdict(int)

    clicks = 0
    min_lookahead_steps = lookahead_steps
    while i < dlen // 1:
        if i >= next_tick:
            eta.print_status()
            next_tick = int(eta.i * dlen / 1000)

        if frame_offset >= (FRAME_SIZE - 5):  # XXX
            lookahead_steps = min_lookahead_steps + 130  # XXX parametrize
        else:
            lookahead_steps = min_lookahead_steps

        # Compute all possible opcode sequences for this frame offset
        last_opcode = opcode if frame_offset == FRAME_SIZE - 1 else None
        next_candidate_opcodes, voltages, lookahead_steps = \
            opcodes.candidate_opcodes(
                frame_horizon(frame_offset, lookahead_steps),
                lookahead_steps, last_opcode)
        opcode_idx = lookahead.evolve_return_best(
            sp, y1, y2, voltage1, voltage2, voltage1 * voltages,
            data[i:i + lookahead_steps])

        opcode = next_candidate_opcodes[opcode_idx]
        opcode_length = opcodes.cycle_length(opcode)
        opcode_counts[opcode] += 1

        # Apply this opcode to evolve the speaker position
        opcode_voltages = (voltage1 * opcodes.voltage_schedule(
            opcode)).reshape((1, -1))
        all_positions = lookahead.evolve(
            sp, y1, y2, voltage1, voltage2, opcode_voltages)

        assert all_positions.shape[0] == 1
        assert all_positions.shape[1] == opcode_length

        voltage1 = opcode_voltages[0, -1]
        voltage2 = opcode_voltages[0, -2]
        y1 = all_positions[0, -1]
        y2 = all_positions[0, -2]
        new_error = total_error(
            all_positions[0] * sp.scale, data[i:i + opcode_length]).item()
        total_err += new_error
        if new_error > 0.3:
            clicks += 1
            print(frame_offset, i / sample_rate, opcode, new_error,
                  numpy.mean(data[i:i + opcode_length]))

        yield opcode, numpy.array(
            all_positions * sp.scale, dtype=numpy.float32).reshape(-1)

        i += opcode_length
        frame_offset = (frame_offset + 1) % FRAME_SIZE

    # Make sure we have at least 2k left in stream so player will do a
    # complete read.
    # for _ in range(frame_offset % 2048, 2048):
    #     yield opcodes.Opcode.EXIT
    eta.done()
    print("Total error %f" % total_err)

    print("Opcodes used:")
    for v, k in sorted(list(opcode_counts.items()), key=lambda kv: kv[1],
                       reverse=True):
        print("%s: %d" % (v, k))
    print("%d clicks" % clicks)


def preprocess(
        filename: str, target_sample_rate: int, normalize: float,
        normalization_percentile: int) -> numpy.ndarray:
    """Upscale input audio to target sample rate and normalize signal."""

    data, _ = librosa.load(filename, sr=target_sample_rate, mono=True)

    max_value = numpy.percentile(data, normalization_percentile)
    data /= max_value
    data *= normalize

    return data


def resample_output(output_buffer, input_audio, sample_rate, output_rate,
                    noise_output=False):
    resampled_output = librosa.resample(
        numpy.array(output_buffer, dtype=numpy.float32),
        orig_sr=sample_rate,
        target_sr=output_rate)

    resampled_noise = None
    if noise_output:
        noise_len = min(len(output_buffer), len(input_audio))
        resampled_noise = librosa.resample(
            numpy.array(output_buffer[:noise_len] - input_audio[:noise_len]),
            orig_sr=sample_rate,
            target_sr=output_rate)

    return resampled_output, resampled_noise


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
    sample_rate = 1015657 if args.clock == 'pal' else 1020484  # NTSC

    input_audio = preprocess(args.input, sample_rate, args.normalization,
                             args.norm_percentile)
    print("Done preprocessing audio")

    output_rate = 44100

    output_buffer = []
    input_offset = 0

    opcode_context = open(args.output, "wb+")

    if args.wav_output:
        wav_context = sf.SoundFile(
            args.wav_output, "w", output_rate, channels=1, format='WAV')
    else:
        wav_context = contextlib.nullcontext

    if args.noise_output:
        noise_context = sf.SoundFile(
            args.noise_output, "w", output_rate, channels=1,
            format='WAV')
    else:
        # We're not creating a file but still need a context
        noise_context = contextlib.nullcontext

    with wav_context as wav_f, noise_context as noise_f, opcode_context \
            as opcode_f:
        for idx, sample_data in enumerate(audio_bytestream(
                input_audio, args.step_size, args.lookahead_cycles,
                sample_rate)):
            opcode, samples = sample_data
            opcode_f.write(bytes([opcode.byte]))

            output_buffer.extend(samples)
            input_offset += len(samples)

            # TODO: don't bother computing if we're not writing wavs

            # Keep accumulating as long as we have <1MB in the buffer, or are
            # within 1MB from the end.  This ensures we have enough samples to
            # resample including the last (partial) buffer
            if len(output_buffer) < 1 * 1024 * 1024:
                continue
            if (len(input_audio) - input_offset) < 1 * 1024 * 1024:
                continue
            resampled_output_buffer, resampled_noise_buffer = resample_output(
                output_buffer, input_audio[input_offset - len(output_buffer):],
                sample_rate, output_rate, bool(args.noise_output)
            )
            if args.wav_output:
                wav_f.write(resampled_output_buffer)
                wav_f.flush()
            if args.noise_output:
                noise_f.write(resampled_noise_buffer)
                noise_f.flush()

            output_buffer = []

        if output_buffer:
            resampled_output_buffer, resampled_noise_buffer = resample_output(
                output_buffer, input_audio[input_offset - len(output_buffer):],
                sample_rate, output_rate, bool(args.noise_output)
            )
            if args.wav_output:
                wav_f.write(resampled_output_buffer)
            if args.noise_output:
                noise_f.write(resampled_noise_buffer)


if __name__ == "__main__":
    main()
