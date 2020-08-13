#!/usr/bin/env python3
# Delta modulation audio encoder.
#
# Models the Apple II speaker as an RC circuit with given time constant
# and computes a sequence of speaker ticks at multiples of 13-cycle intervals
# to approximate the target audio waveform.
#
# To optimize the audio quality we look ahead some defined number of steps and
# choose a speaker trajectory that minimizes errors over this range.  e.g.
# this allows us to anticipate large amplitude changes by pre-moving
# the speaker to better approximate them.
#
# This also needs to take into account scheduling the "slow path" every 2048
# output bytes, where the Apple II will manage the TCP socket buffer while
# ticking the speaker every 13 cycles.  Since we know this is happening
# we can compensate for it, i.e. look ahead to this upcoming slow path and
# pre-position the speaker so that it introduces the least error during
# this "dead" period when we're keeping the speaker in a net-neutral position.

import sys
import librosa
import numpy
from typing import List, Tuple
from eta import ETA

import opcodes


#
# # TODO: test
# @functools.lru_cache(None)
# def lookahead_patterns(
#         lookahead: int, slowpath_distance: int,
#         voltage: float) -> numpy.ndarray:
#     initial_voltage = voltage
#     patterns = set()
#
#     slowpath_pre_bits = 0
#     slowpath_post_bits = 0
#     if slowpath_distance <= 0:
#         slowpath_pre_bits = min(12 + slowpath_distance, lookahead)
#     elif slowpath_distance <= lookahead:
#         slowpath_post_bits = lookahead - slowpath_distance
#
#     enumerate_bits = lookahead - slowpath_pre_bits - slowpath_post_bits
#     assert slowpath_pre_bits + enumerate_bits + slowpath_post_bits == lookahead
#
#     for i in range(2 ** enumerate_bits):
#         voltage = initial_voltage
#         pattern = []
#         for j in range(slowpath_pre_bits):
#             voltage = -voltage
#             pattern.append(voltage)
#
#         for j in range(enumerate_bits):
#             voltage = 1.0 if ((i >> j) & 1) else -1.0
#             pattern.append(voltage)
#
#         for j in range(slowpath_post_bits):
#             voltage = -voltage
#             pattern.append(voltage)
#
#         patterns.add(tuple(pattern))
#
#     res = numpy.array(list(patterns), dtype=numpy.float32)
#     return res


def lookahead(step_size: int, initial_position: float, data: numpy.ndarray,
              offset: int,
              voltages: numpy.ndarray):
    positions = numpy.empty((voltages.shape[0], voltages.shape[1] + 1),
                            dtype=numpy.float32)
    positions[:, 0] = initial_position

    target_val = data[offset:offset + voltages.shape[1]]
    # total_error = numpy.zeros(shape=voltages.shape[0], dtype=numpy.float32)
    for i in range(0, voltages.shape[1]):
        positions[:, i + 1] = positions[:, i] + (
                voltages[:, i] - positions[:, i]) / step_size
        # err = numpy.power(numpy.abs(positions - target_val[i]), 2)
        # total_error += err
    try:
        err = positions[:, 1:] - target_val
    except ValueError:
        print(offset, len(data), positions.shape, target_val.shape)
        raise
    total_error = numpy.sum(numpy.power(err, 2), axis=1)

    best = numpy.argmin(total_error)
    return best


def evolve(opcode: opcodes.Opcode, starting_position, starting_voltage,
           step_size, data, starting_idx):
    # Skip ahead to end of this opcode
    opcode_length = opcodes.cycle_length(opcode)
    voltages = starting_voltage * opcodes.CYCLE_SCHEDULE[opcode]
    position = starting_position
    total_err = 0.0
    v = starting_voltage
    for i, v in enumerate(voltages):
        position += (v - position) / step_size
        err = position - data[starting_idx + i]
        total_err += err ** 2
    return position, v, total_err, starting_idx + opcode_length

@profile
def sample(data: numpy.ndarray, step: int, lookahead_steps: int):
    dlen = len(data)
    data = numpy.concatenate([data, numpy.zeros(lookahead_steps)]).astype(
        numpy.float32)

    voltage = -1.0
    position = -1.0

    total_err = 0.0
    frame_offset = 0
    eta = ETA(total=1000)
    i = 0
    last_updated = 0
    while i < int(dlen / 100):
        if (i - last_updated) > int((dlen / 1000)):
            eta.print_status()
            last_updated = i

        candidate_opcodes = opcodes.opcode_lookahead(
            frame_offset, lookahead_steps)
        pruned_opcodes, voltages = opcodes.prune_opcodes(
            candidate_opcodes, lookahead_steps)

        opcode_idx = lookahead(step, position, data, i, voltage * voltages)
        opcode = pruned_opcodes[opcode_idx].opcodes[0]
        yield opcode

        position, voltage, new_error, i = evolve(
            opcode, position, voltage, step, data, i)

        total_err += new_error
        frame_offset = (frame_offset + 1) % 2048

    for _ in range(frame_offset % 2048, 2047):
        yield opcodes.Opcode.NOTICK_5
    yield opcodes.Opcode.EXIT
    eta.done()
    print("Total error %f" % total_err)


def preprocess(
        filename: str, target_sample_rate: int,
        normalize: float = 0.5) -> numpy.ndarray:
    data, _ = librosa.load(filename, sr=target_sample_rate, mono=True)

    max_value = numpy.percentile(data, 90)
    data /= max_value
    data *= normalize

    return data


def main(argv):
    serve_file = argv[1]
    step = int(argv[2])
    lookahead_steps = int(argv[3])
    out = argv[4]

    sample_rate = int(1024. * 1000)
    data = preprocess(serve_file, sample_rate)
    with open(out, "wb+") as f:
        for opcode in sample(data, step, lookahead_steps):
            f.write(bytes([opcode.value]))


if __name__ == "__main__":
    main(sys.argv)
