#!/usr/bin/env python3
# Delta modulation audio encoder.
#
# Simulates the Apple II speaker at 1MHz (i.e. cycle-level) resolution,
# by modeling it as an RC circuit with given time constant.  In order to
# reproduce a target audio waveform, we upscale it to 1MHz sample rate,
# and compute the sequence of player opcodes to best reproduce this waveform.
#
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
# This also needs to take into account scheduling the "slow path" opcode every
# 2048 output bytes, where the Apple II will manage the TCP socket buffer while
# ticking the speaker at a regular cadence of 13 cycles to keep it in a
# net-neutral position.  When looking ahead we can also (partially)
# compensate for this "dead" period by pre-positioning.

import collections
import functools
import sys
import librosa
import numpy
from eta import ETA
from typing import Tuple

import opcodes


# TODO: add flags to parametrize options

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
    """Optimize frame_offset when we're not within lookahead_steps of slowpath.

    When computing candidate opcodes, all frame offsets are the same until the
    end-of-frame slowpath comes within our lookahead horizon.
    """
    # TODO: This could be made tighter because a step is always at least 5
    #  cycles towards lookahead_steps.
    if frame_offset < (2047 - lookahead_steps):
        return 0
    return frame_offset


def audio_bytestream(data: numpy.ndarray, step: int, lookahead_steps: int,
                     sample_rate: int):
    """Computes optimal sequence of player opcodes to reproduce audio data."""

    dlen = len(data)
    # Leave enough padding at the end to look ahead from the last data value,
    # and in case we schedule a slowpath opcode towards the end.
    # TODO: avoid temporarily doubling memory footprint to concatenate
    data = numpy.ascontiguousarray(numpy.concatenate(
        [data, numpy.zeros(max(lookahead_steps, opcodes.cycle_length(
            opcodes.Opcode.SLOWPATH)),
                           dtype=numpy.float32)]))

    # Starting speaker position and applied voltage.
    position = 0.0
    voltage = -1.0

    toggles = 0
    all_partial_positions = {}
    # Precompute partial_positions so we don't skew ETA during encoding.
    for i in range(2048):
        for voltage in [-1.0, 1.0]:
            opcode_hash, _, voltages = opcodes.candidate_opcodes(
                frame_horizon(i, lookahead_steps), lookahead_steps)
            delta_powers, partial_positions = _partial_positions(
                voltage * voltages, step)

            # These matrices usually have more rows than columns, so store
            # then in column-major order which optimizes for this.
            delta_powers = numpy.asfortranarray(delta_powers)
            partial_positions = numpy.asfortranarray(
                partial_positions)

            all_partial_positions[opcode_hash, voltage] = (
                delta_powers, partial_positions)

    opcode_partial_positions = {}
    for op, voltages in opcodes.VOLTAGE_SCHEDULE.items():
        for voltage in [-1.0, 1.0]:
            delta_powers, partial_positions = _partial_positions(
                voltage * voltages, step)
            assert delta_powers.shape == partial_positions.shape
            assert delta_powers.shape[-1] == opcodes.cycle_length(op)
            opcode_partial_positions[op, voltage] = (
                delta_powers, partial_positions, voltage * voltages[-1])

    total_err = 0.0  # Total squared error of audio output
    frame_offset = 0  # Position in 2048-byte TCP frame
    i = 0  # index within input data
    eta = ETA(total=1000, min_ms_between_updates=0)
    next_tick = 0  # Value of i at which we should next update eta
    # Keep track of how many opcodes we schedule
    opcode_counts = collections.defaultdict(int)
    while i < int(dlen / 1):
        if i >= next_tick:
            eta.print_status()
            next_tick = int(eta.i * dlen / 1000)

        # Compute all possible opcode sequences for this frame offset
        opcode_hash, candidate_opcodes, _ = opcodes.candidate_opcodes(
            frame_horizon(frame_offset, lookahead_steps), lookahead_steps)
        # Look up the precomputed partial values for these candidate opcode
        # sequences.
        delta_powers, partial_positions = all_partial_positions[opcode_hash,
                                                                voltage]
        # Compute matrix of new speaker positions for candidate opcode
        # sequences.
        all_positions = new_positions(position, partial_positions, delta_powers)

        assert all_positions.shape[1] == lookahead_steps
        # Pick the opcode sequence that minimizes the total squared error
        # relative to the data waveform.  This total_error() call is where
        # about 75% of CPU time is spent.
        opcode_idx = numpy.argmin(
            total_error(all_positions, data[i:i + lookahead_steps])).item()
        # Next opcode
        opcode = candidate_opcodes[opcode_idx][0]
        opcode_length = opcodes.cycle_length(opcode)
        opcode_counts[opcode] += 1
        toggles += opcodes.TOGGLES[opcode]

        # Apply this opcode to evolve the speaker position
        delta_powers, partial_positions, last_voltage = \
            opcode_partial_positions[opcode, voltage]
        all_positions = new_positions(position, partial_positions, delta_powers)
        assert len(all_positions) == opcode_length
        voltage = last_voltage
        position = all_positions[-1]
        total_err += total_error(
            all_positions, data[i:i + opcode_length]).item()

        yield opcode

        i += opcode_length
        frame_offset = (frame_offset + 1) % 2048

    # Make sure we have at least 2k left in stream so player will do a
    # complete read.
    for _ in range(frame_offset % 2048, 2048):
        yield opcodes.Opcode.EXIT
    eta.done()
    print("Total error %f" % total_err)
    toggles_per_sec = toggles / dlen * sample_rate
    print("%d speaker toggles/sec" % toggles_per_sec)

    print("Opcodes used:")
    for v, k in sorted(list(opcode_counts.items()), key=lambda kv: kv[1],
                       reverse=True):
        print("%s: %d" % (v, k))


def preprocess(
        filename: str, target_sample_rate: int, normalize: float = 1.0,
        normalization_percentile: int = 100) -> numpy.ndarray:
    """Upscale input audio to target sample rate and normalize signal."""

    data, _ = librosa.load(filename, sr=target_sample_rate, mono=True)

    max_value = numpy.percentile(data, normalization_percentile)
    data /= max_value
    data *= normalize

    return data


def main(argv):
    serve_file = argv[1]
    step = int(argv[2])

    # TODO: if we're not looking ahead beyond the longest (non-slowpath) opcode
    # then this will reduce quality, e.g. two opcodes may truncate to the
    # same prefix, but have different results when we apply them fully.
    lookahead_steps = int(argv[3])
    out = argv[4]

    # Effective clock rate, including every-65 cycle "long cycle" that takes
    # 16/14 as long.
    #
    # NTSC: 1020484
    # PAL //c: 1015625
    sample_rate = 1015657  # PAL

    with open(out, "wb+") as f:
        for opcode in audio_bytestream(
                preprocess(serve_file, sample_rate), step, lookahead_steps,
                sample_rate):
            f.write(bytes([opcode.value]))


if __name__ == "__main__":
    main(sys.argv)
