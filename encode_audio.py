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


# We simulate the speaker voltage trajectory resulting from applying multiple
# voltage profiles, compute the resulting squared error relative to the target
# waveform, and pick the best one.
#
# We use numpy to vectorize the computation since it has better scaling
# performance with more opcode choices, although also has a larger fixed
# overhead.
#
# The speaker position p_i evolves according to
# p_{i+1} = p_i + (v_i - p_i) / s
# where v_i is the i'th applied voltage, s is the speaker step size
#
# Rearranging, we get p_{i+1} = v_i / s + (1-1/s) p_i
# and if we expand the recurrence relation
# p_{i+1} = Sum_{j=0}^i (1-1/s)^(i-j) v_j / s + (1-1/s)^(i+1) p_0
# = (1-1/s)^(i+1)(1/s * Sum_{j=0}^i v_j / (1-1/s)^(j+1) + p0)
#
# We can precompute most of this expression:
# 1) the vector {(1-1/s)^i} ("_delta_powers")
# 2) the position-independent term of p_{i+1} ("_partial_positions").  Since
#    the candidate opcodes list only depends on frame_offset, the voltage matrix
#    v also only takes a few possible values, so we can precompute all values
#    of this term.


@functools.lru_cache(None)
def _delta_powers(shape, step_size: int) -> numpy.ndarray:
    delta = 1 - 1 / step_size
    return numpy.cumprod(numpy.full(shape, delta), axis=-1)


def _partial_positions(voltages, step_size):
    delta_powers = _delta_powers(voltages.shape, step_size)

    partial_positions = delta_powers * (
            numpy.cumsum(voltages / delta_powers, axis=-1) / step_size)
    return delta_powers, partial_positions


def new_positions(
        position: float, partial_positions: numpy.ndarray,
        delta_powers: numpy.ndarray) -> numpy.ndarray:
    """Computes new array of speaker positions for position and voltage data."""
    return partial_positions + delta_powers * position


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

        self.scale = numpy.float64(1 / 1000)  # TODO: analytic expression

    def evolve(self, y1, y2, voltage1, voltage2, voltages):
        output = numpy.zeros_like(voltages, dtype=numpy.float64)
        x1 = numpy.full((1, voltages.shape[0]), voltage1,
                        dtype=numpy.float32)
        x2 = numpy.full((1, voltages.shape[0]), voltage2,
                        dtype=numpy.float32)
        for i in range(voltages.shape[1]):
            # print(i)
            y = self.c1 * y1 - self.c2 * y2 + self.b1 * x1 + self.b2 * x2
            output[:, i] = y

            y2 = y1
            y1 = y
            x2 = x1
            x1 = voltages[:, i]  # XXX does this really always lag?

        # print(output)
        return output


def audio_bytestream(data: numpy.ndarray, step: int, lookahead_steps: int,
                     sample_rate: int, is_6502: bool):
    """Computes optimal sequence of player opcodes to reproduce audio data."""

    dlen = len(data)
    # Leave enough padding at the end to look ahead from the last data value,
    # and in case we schedule an end-of-frame opcode towards the end.
    # TODO: avoid temporarily doubling memory footprint to concatenate
    data = numpy.ascontiguousarray(numpy.concatenate(
        [data, numpy.zeros(max(lookahead_steps, opcodes.cycle_length(
            opcodes.Opcode.END_OF_FRAME_1, is_6502)), dtype=numpy.float32)]))

    # Starting speaker position and applied voltage.
    # position = 0.0
    voltage1 = voltage2 = -1.0

    toggles = 0

    sp = Speaker(sample_rate, freq=3875, damping=-1210)
    #
    # print(sp.evolve(0, 0, 1.0, 1.0, numpy.full((1, 10000), 1.0)) * sp.scale)
    # assert False

    # XXX
    # Smoothing window N --> log_2 N bit resolution
    # - 64
    # Maintain last N voltages
    # Lookahead window L
    # Compute all opcodes for window L
    # Compute all voltage schedules for window L
    # Compute moving average over combined voltage schedule and minimize error
    # XXX band pass filter first - to speaker range?  no point trying to
    # model frequencies that can't be produced

    # old method was basically an exponential moving average, another way of
    # smoothing square waveform

    total_err = 0.0  # Total squared error of audio output
    frame_offset = 0  # Position in 2048-byte TCP frame
    i = 0  # index within input data
    eta = ETA(total=1000, min_ms_between_updates=0)
    next_tick = 0  # Value of i at which we should next update eta
    # Keep track of how many opcodes we schedule
    opcode_counts = collections.defaultdict(int)

    y1 = y2 = 0.0  # last 2 speaker positions
    min_lookahead_steps = lookahead_steps
    while i < int(dlen / 10):
        # print(i, dlen)
        if i >= next_tick:
            eta.print_status()
            next_tick = int(eta.i * dlen / 1000)
        # Compute all possible opcode sequences for this frame offset
        opcode_hash, candidate_opcodes, voltages, lookahead_steps = \
            opcodes.candidate_opcodes(
                frame_horizon(frame_offset, min_lookahead_steps),
                min_lookahead_steps, is_6502)
        # print(frame_offset, lookahead_steps)

        all_positions = sp.evolve(y1, y2, voltage1, voltage2, voltage1
                                  * voltages)
        # print(all_positions, all_positions.shape)

        # Look up the precomputed partial values for these candidate opcode
        # sequences.
        # delta_powers, partial_positions = all_partial_positions[opcode_hash,
        #                                                         voltage]
        # # Compute matrix of new speaker positions for candidate opcode
        # # sequences.
        # all_positions = new_positions(position, partial_positions, delta_powers)

        # opcode_idx, _ = lookahead.moving_average(
        #     smoothed_window, voltage * voltages, data[i:i + lookahead_steps],
        #     lookahead_steps)

        # assert all_positions.shape[1] == lookahead_steps
        # Pick the opcode sequence that minimizes the total squared error
        # relative to the data waveform.  This total_error() call is where
        # about 75% of CPU time is spent.
        opcode_idx = numpy.argmin(
            total_error(
                all_positions * sp.scale, data[i:i + lookahead_steps])).item()
        # Next opcode
        opcode = candidate_opcodes[opcode_idx][0]
        opcode_length = opcodes.cycle_length(opcode, is_6502)
        opcode_counts[opcode] += 1
        # toggles += opcodes.TOGGLES[opcode]

        # Apply this opcode to evolve the speaker position
        opcode_voltages = (voltage1 * opcodes.voltage_schedule(
            opcode, is_6502)).reshape((1, -1))
        all_positions = sp.evolve(y1, y2, voltage1, voltage2, opcode_voltages)

        # delta_powers, partial_positions, last_voltage = \
        #     opcode_partial_positions[opcode, voltage]
        # all_positions = new_positions(position, partial_positions, delta_powers)
        assert all_positions.shape[0] == 1
        assert all_positions.shape[1] == opcode_length

        voltage1 = opcode_voltages[0, -1]
        voltage2 = opcode_voltages[0, -2]
        y1 = all_positions[0, -1]
        y2 = all_positions[0, -2]
        # print(y1, y2, all_positions[0] * sp.scale)
        new_error = total_error(
            all_positions[0] * sp.scale, data[i:i + opcode_length]).item()
        total_err += new_error
        if new_error > 1:
            print(i, frame_offset, new_error)
        # print(all_positions[0] * sp.scale, data[i:i + opcode_length])

        # print(frame_offset, opcode)
        for v in all_positions[0]:
            yield v * sp.scale
            # print(v * sp.scale)
        # for v in opcode_voltages[0]:
        #    print("  %d" % v)

        i += opcode_length
        frame_offset = (frame_offset + 1) % 2048

    # Make sure we have at least 2k left in stream so player will do a
    # complete read.
    # for _ in range(frame_offset % 2048, 2048):
    #    yield opcodes.Opcode.EXIT
    eta.done()
    print("Total error %f" % total_err)
    toggles_per_sec = toggles / dlen * sample_rate
    print("%d speaker toggles/sec" % toggles_per_sec)

    print("Opcodes used:")
    for v, k in sorted(list(opcode_counts.items()), key=lambda kv: kv[1],
                       reverse=True):
        print("%s: %d" % (v, k))


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
    # TODO: implement 6502
    parser.add_argument("--cpu", choices=['6502', '65c02'], default='65c02',
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
    parser.add_argument("--norm_percentile", default=99,
                        help="Normalize to specified percentile value of input "
                             "audio")
    parser.add_argument("input", type=str, help="input audio file to convert")
    parser.add_argument("output", type=str, help="output audio file")
    args = parser.parse_args()

    # Effective clock rate, including every-65 cycle "long cycle" that takes
    # 16/14 as long.
    sample_rate = 1015657 if args.clock == 'pal' else 1020484  # NTSC

    # with open(args.output, "wb+") as f:[d20+
    output = numpy.array(list(audio_bytestream(
        preprocess(args.input, sample_rate, args.normalization,
                   args.norm_percentile), args.step_size,
        args.lookahead_cycles, sample_rate, args.cpu == '6502')),
        dtype=numpy.float32)
    output_rate = 44100  # int(sample_rate / 4)
    output = librosa.resample(output, orig_sr=sample_rate,
                              target_sr=output_rate)
    with sf.SoundFile(
            args.output, "w", output_rate, channels=1, format='WAV') \
            as f:
        f.write(output)
    # f.write(bytes([opcode.value]))


if __name__ == "__main__":
    main()
