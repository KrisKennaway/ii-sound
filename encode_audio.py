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


@functools.lru_cache(None)
def _delta_powers(shape, step_size: int) -> Tuple[float, numpy.ndarray]:
    delta = (1 - 1 / step_size)
    return delta, numpy.cumprod(numpy.full(shape, delta), axis=-1)


def lookahead(step_size: int, initial_position: float, data: numpy.ndarray,
              offset: int, voltages: numpy.ndarray):
    """Evaluate effects of multiple potential opcode sequences and pick best.

    We simulate the speaker voltage trajectory resulting from applying multiple
    voltage profiles, compute the resulting squared error relative to the
    target waveform, and pick the best one.

    We use numpy to vectorize the computation since it has better scaling
    performance with more opcode choices, although also has a larger fixed
    overhead.
    """
    # The speaker position p_i evolves according to
    # p_{i+1} = p_i + (v_i - p_i) / s
    # where v_i is the i'th applied voltage, s is the speaker step size
    #
    # Rearranging, we get p_{i+1} = v_i / s + (1-1/s) p_i
    # and if we expand the recurrence relation
    # p_{i+1} = Sum_{j=0}^i (1-1/s)^(i-j) v_j / s + (1-1/s)^(i+1) p_0
    # = (1-1/s)^(i+1)(1/s * Sum_{j=0}^i v_j / (1-1/s)^(j+1) + p0)
    delta, delta_powers = _delta_powers(voltages.shape, step_size)

    positions = delta_powers * (
            numpy.cumsum(voltages / delta_powers, axis=1) / step_size +
            initial_position)
    total_error = numpy.sum(
        numpy.square(positions - data[offset:offset + voltages.shape[1]]),
        axis=1)

    best = numpy.argmin(total_error)
    return best


# TODO: Merge with lookahead
def evolve(opcode: opcodes.Opcode, starting_position, starting_voltage,
           step_size, data, starting_idx):
    """Apply the effects of playing a single opcode to completion.

    Returns new state.
    """
    opcode_length = opcodes.cycle_length(opcode)
    voltages = starting_voltage * opcodes.VOLTAGE_SCHEDULE[opcode]
    delta, delta_powers = _delta_powers(opcode_length, step_size)

    positions = delta_powers * (
            numpy.cumsum(voltages / delta_powers) / step_size +
            starting_position)

    # TODO: compute error once at the end?
    total_err = numpy.sum(numpy.square(
        positions - data[starting_idx:starting_idx + opcode_length]))
    return positions[-1], voltages[-1], total_err, starting_idx + opcode_length


@functools.lru_cache(None)
def frame_horizon(frame_offset: int, lookahead_steps: int):
    """Optimize frame_offset when we're not within lookahead_steps of slowpath.

    When computing candidate opcodes, all frame offsets are the same until the
    end-of-frame slowpath comes within our lookahead horizon.
    """
    if frame_offset < (2047 - lookahead_steps):
        return 0
    return frame_offset


def audio_bytestream(data: numpy.ndarray, step: int, lookahead_steps: int):
    """Computes optimal sequence of player opcodes to reproduce audio data."""

    dlen = len(data)
    # TODO: avoid temporarily doubling memory footprint to concatenate
    data = numpy.concatenate(
        [data, numpy.zeros(lookahead_steps, dtype=numpy.float32)])

    voltage = -1.0
    position = -1.0

    # Pre-warm cache so we don't skew ETA during encoding
    for i in range(2048):
        _, _ = opcodes.candidate_opcodes(frame_horizon(i, lookahead_steps),
                                         lookahead_steps)

    total_err = 0.0
    frame_offset = 0
    eta = ETA(total=1000)
    i = 0
    last_updated = 0
    opcode_counts = collections.defaultdict(int)

    while i < dlen:
        if (i - last_updated) > int((dlen / 1000)):
            eta.print_status()
            last_updated = i

        candidate_opcodes, voltages = opcodes.candidate_opcodes(
            frame_horizon(frame_offset, lookahead_steps), lookahead_steps)
        opcode_idx = lookahead(step, position, data, i, voltage * voltages)
        opcode = candidate_opcodes[opcode_idx][0]
        opcode_counts[opcode] += 1
        yield opcode

        position, voltage, new_error, i = evolve(
            opcode, position, voltage, step, data, i)

        total_err += new_error
        frame_offset = (frame_offset + 1) % 2048

    for _ in range(frame_offset % 2048, 2047):
        yield opcodes.Opcode.NOTICK_6
    yield opcodes.Opcode.EXIT
    eta.done()
    print("Total error %f" % total_err)

    print("Opcodes used:")
    for v, k in sorted(list(opcode_counts.items()), key=lambda kv: kv[1],
                       reverse=True):
        print("%s: %d" % (v, k))


def preprocess(
        filename: str, target_sample_rate: int, normalize: float = 0.5,
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
    # then this will reduce quality, e.g. a long NOTICK and TICK will
    # both look the same over a too-short horizon, but have different results.
    lookahead_steps = int(argv[3])
    out = argv[4]

    # TODO: PAL Apple ][ clock rate is slightly different
    sample_rate = int(1024. * 1000)

    with open(out, "wb+") as f:
        for opcode in audio_bytestream(
                preprocess(serve_file, sample_rate), step, lookahead_steps):
            f.write(bytes([opcode.value]))


if __name__ == "__main__":
    main(sys.argv)
