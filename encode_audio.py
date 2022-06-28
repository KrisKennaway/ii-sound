#!/usr/bin/env python3
# Delta modulation audio encoder.
#
# Simulates the Apple II speaker at 1MHz (i.e. cycle-level) resolution,
# by modeling it as an RC circuit with given time constant.  In order to
# reproduce a target audio waveform, we upscale it to 1MHz sample rate,
# and compute the sequence of player opcodes to best reproduce this waveform.
#
# XXX
# Since the player opcodes are chosen to allow ticking the speaker during any
# given clock cycle (though with some limits on the minimum time
# between ticks), this means that we are able to control the Apple II speaker
# with cycle-level precision, which results in high audio fidelity with low
# noise.
#
# To further optimize the audio quality we look ahead some defined number of
# cycles and choose a speaker trajectory that minimizes errors over this range.
# e.g. this allows us to anticipate large amplitude changes by pre-moving
# the speaker to better approximate them.
#
# This also needs to take into account scheduling the "end of frame" opcode
# every 2048 output bytes, where the Apple II will manage the TCP socket buffer
# while ticking the speaker at a regular cadence to keep it in a net-neutral
# position.  When looking ahead we can also (partially) compensate for this
# "dead" period by pre-positioning.

import argparse
import collections
import functools
import librosa
import numpy
from eta import ETA

import opcodes

import lookahead


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
    if frame_offset < (2047 - lookahead_steps):
        return 0
    return frame_offset


class Speaker:
    def __init__(self, sample_rate: float, freq: float, damping: float):
        self.sample_rate = sample_rate
        self.freq = freq
        self.damping = damping

        dt = numpy.float64(1 / sample_rate)

        w = numpy.float64(freq * 2 * numpy.pi * dt)

        d = damping * dt
        e = numpy.exp(d)
        c1 = 2 * e * numpy.cos(w)

        c2 = e * e
        t0 = (1 - 2 * e * numpy.cos(w) + e * e) / (d * d + w * w)
        t = d * d + w * w - numpy.pi * numpy.pi
        t1 = (1 + 2 * e * numpy.cos(w) + e * e) / numpy.sqrt(t * t + 4 * d * d *
                                                             numpy.pi * numpy.pi)
        b2 = (t1 - t0) / (t1 + t0)
        b1 = b2 * dt * dt * (t0 + t1) / 2

        self.c1 = c1
        self.c2 = c2
        self.b1 = b1
        self.b2 = b2
        # print(dt, w, d, e, c1,c2,b1,b2)

        # 3000 - 241
        # 2500 - 97
        # 2000 - 24
        # 1700 - 9.6
        # 1600 - 8.8
        # 1500 - 9.39
        # 1400 - 10.46
        # 1000 - 21.56

        # 1600 - 3603
        # 1000 - 708
        # 800 - 802
        self.scale = numpy.float64(1 / 800)  # TODO: analytic expression


def audio_bytestream(data: numpy.ndarray, step: int, lookahead_steps: int,
                     sample_rate: int, is_6502: bool):
    """Computes optimal sequence of player opcodes to reproduce audio data."""

    dlen = len(data)
    # Leave enough padding at the end to look ahead from the last data value,
    # and in case we schedule an end-of-frame opcode towards the end.
    # TODO: avoid temporarily doubling memory footprint to concatenate
    data = numpy.ascontiguousarray(numpy.concatenate(
        [data, numpy.zeros(max(lookahead_steps, opcodes.cycle_length(
            opcodes.Opcode.END_OF_FRAME_0, is_6502)), dtype=numpy.float32)]))

    # Starting speaker applied voltage.
    voltage1 = voltage2 = -1.0  # * 2.5

    toggles = 0

    sp = Speaker(sample_rate, freq=3875, damping=-1210)

    total_err = 0.0  # Total squared error of audio output
    frame_offset = 0  # Position in 2048-byte TCP frame
    i = 0  # index within input data
    eta = ETA(total=1000, min_ms_between_updates=0)
    next_tick = 0  # Value of i at which we should next update eta
    # Keep track of how many opcodes we schedule
    opcode_counts = collections.defaultdict(int)

    y1 = y2 = 1.0  # last 2 speaker positions
    # data = numpy.full(data.shape, 0.0)
    # data = numpy.sin(
    #     numpy.arange(len(data)) * (2 * numpy.pi / (sample_rate / 3875)))

    last_v = 1.0
    since_toggle = 0
    import itertools
    # opcode_seq = itertools.cycle(
    #     (
    #         opcodes.Opcode.TICK_13,
    #         opcodes.Opcode.TICK_14,
    #     )
    # )
    clicks = 0
    min_lookahead_steps = lookahead_steps
    while i < dlen // 1:
        # XXX handle end of data cleanly
        if i >= next_tick:
            eta.print_status()
            next_tick = int(eta.i * dlen / 1000)

        if frame_offset == 2047:
            lookahead_steps = min_lookahead_steps + 140  # XXX parametrize
        else:
            lookahead_steps = min_lookahead_steps

        # Compute all possible opcode sequences for this frame offset
        opcode_hash, candidate_opcodes, voltages, lookahead_steps = \
            opcodes.candidate_opcodes(
                frame_horizon(frame_offset, lookahead_steps),
                lookahead_steps, is_6502)
        all_positions = lookahead.evolve(
            sp, y1, y2, voltage1, voltage2, voltage1 * voltages)

        # Pick the opcode sequence that minimizes the total squared error
        # relative to the data waveform.
        errors = total_error(
            all_positions * sp.scale, data[i:i + lookahead_steps])
        opcode_idx = numpy.argmin(errors).item()
        # if frame_offset == 2046:
        #     print("XXX")
        #     print(opcode_idx)
        #     for i, e in enumerate(errors):
        #         print(i, e, candidate_opcodes[i])
        # Next opcode
        opcode = candidate_opcodes[opcode_idx][0]
        # opcode = opcode_seq.__next__()

        opcode_length = opcodes.cycle_length(opcode, is_6502)
        opcode_counts[opcode] += 1
        # toggles += opcodes.TOGGLES[opcode]

        # Apply this opcode to evolve the speaker position
        opcode_voltages = (voltage1 * opcodes.voltage_schedule(
            opcode, is_6502)).reshape((1, -1))
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
                  numpy.mean(data[i:i + opcode_length]))  # , "<----" if \
            # new_error > 0.3 else "")

        # print(i / sample_rate, opcode)
        for v in all_positions[0]:
            # print("  ", v * sp.scale)
            yield (v * sp.scale).astype(numpy.float32)
        #     # print(v * sp.scale)
        # if frame_offset == 2047:
        #     print(opcode)
        # yield opcode

        i += opcode_length
        frame_offset = (frame_offset + 1) % 2048

    # Make sure we have at least 2k left in stream so player will do a
    # complete read.
    # for _ in range(frame_offset % 2048, 2048):
    #     yield opcodes.Opcode.EXIT
    eta.done()
    print("Total error %f" % total_err)
    toggles_per_sec = toggles / dlen * sample_rate
    print("%d speaker toggles/sec" % toggles_per_sec)

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


import soundfile as sf


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--clock", choices=['pal', 'ntsc'],
                        help="Whether target machine clock speed is PAL ("
                             "1015657Hz) or NTSC (1020484)",
                        required=True)
    # TODO: implement 6502 - JMP indirect takes 5 cycles instead of 6
    parser.add_argument("--cpu", choices=['65c02'], default='65c02',
                        help="Target machine CPU type")
    parser.add_argument("--step_size", type=int,
                        help="Delta encoding step size")
    # TODO: if we're not looking ahead beyond the longest (non-end-of-frame)
    #  opcode then this will reduce quality, e.g. two opcodes may truncate to
    #  the same prefix, but have different results when we apply them
    #  fully.
    parser.add_argument("--lookahead_cycles", type=int,
                        help="Number of clock cycles to look ahead in audio "
                             "stream.")
    parser.add_argument("--normalization", default=1.0, type=float,
                        help="Overall multiplier to rescale input audio "
                             "values.")
    parser.add_argument("--norm_percentile", default=100,
                        help="Normalize to specified percentile value of input "
                             "audio")
    parser.add_argument("input", type=str, help="input audio file to convert")
    parser.add_argument("output", type=str, help="output audio file")
    args = parser.parse_args()

    # Effective clock rate, including every-65 cycle "long cycle" that takes
    # 16/14 as long.
    sample_rate = 1015657 if args.clock == 'pal' else 1020484  # NTSC

    input_audio = preprocess(args.input, sample_rate, args.normalization,
                             args.norm_percentile)
    print("Done preprocessing audio")
    output = numpy.array(list(
        audio_bytestream(input_audio, args.step_size, args.lookahead_cycles,
                         sample_rate, args.cpu == '6502')),
        dtype=numpy.float32)
    output_rate = 44100  # int(sample_rate / 4)
    output = librosa.resample(output, orig_sr=sample_rate,
                              target_sr=output_rate)
    with sf.SoundFile(
            args.output, "w", output_rate, channels=1, format='WAV') \
            as f:
        f.write(output)
    # with open(args.output, "wb+") as f:
    #     for opcode in audio_bytestream(
    #             preprocess(args.input, sample_rate, args.normalization,
    #                        args.norm_percentile), args.step_size,
    #             args.lookahead_cycles, sample_rate, args.cpu == '6502'):
    #         f.write(bytes([opcode.value]))


if __name__ == "__main__":
    main()
