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
import functools
import librosa
import numpy
from eta import ETA

OPCODES = {
    'tick_page1': 0x00,
    'notick_page1': 0x09,
    'notick_page2': 0x11,
    'exit': 0x19,
    'slowpath': 0x29
}

# TODO: notick also has room to flip another softswitch, what can I do with it?


# TODO: test
@functools.lru_cache(None)
def lookahead_patterns(
        lookahead: int, slowpath_distance: int,
        voltage: float) -> numpy.ndarray:
    initial_voltage = voltage
    patterns = set()

    slowpath_pre_bits = 0
    slowpath_post_bits = 0
    if slowpath_distance <= 0:
        slowpath_pre_bits = min(12 + slowpath_distance, lookahead)
    elif slowpath_distance <= lookahead:
        slowpath_post_bits = lookahead - slowpath_distance

    enumerate_bits = lookahead - slowpath_pre_bits - slowpath_post_bits
    assert slowpath_pre_bits + enumerate_bits + slowpath_post_bits == lookahead

    for i in range(2 ** enumerate_bits):
        voltage = initial_voltage
        pattern = []
        for j in range(slowpath_pre_bits):
            voltage = -voltage
            pattern.append(voltage)

        for j in range(enumerate_bits):
            voltage = 1.0 if ((i >> j) & 1) else -1.0
            pattern.append(voltage)

        for j in range(slowpath_post_bits):
            voltage = -voltage
            pattern.append(voltage)

        patterns.add(tuple(pattern))

    res = numpy.array(list(patterns), dtype=numpy.float32)
    return res


def lookahead(step_size: int, initial_position: float, data: numpy.ndarray,
              offset: int,
              voltages: numpy.ndarray):
    positions = numpy.full(voltages.shape[0], initial_position,
                           dtype=numpy.float32)
    target_val = data[offset:offset + voltages.shape[1]]
    total_error = numpy.zeros(shape=voltages.shape[0], dtype=numpy.float32)
    for i in range(0, voltages.shape[1]):
        positions += (voltages[:, i] - positions) / step_size
        err = numpy.power(numpy.abs(positions - target_val[i]), 2)
        total_error += err
    # err = numpy.abs(positions[:, 1:] - target_val)
    # total_error = numpy.sum(err, axis=1)

    best = numpy.argmin(total_error)
    return voltages[best, 0]


def sample(data: numpy.ndarray, step: int, lookahead_steps: int):
    dlen = len(data)
    data = numpy.concatenate([data, numpy.zeros(lookahead_steps)]).astype(
        numpy.float32)

    voltage = -1.0
    position = -1.0

    total_err = 0.0
    slowpath_distance = 2047
    cnt = 0
    eta = ETA(total=1000)
    for i, val in enumerate(data[:dlen]):
        if i and i % int((dlen / 1000)) == 0:
            eta.print_status()

        voltages = lookahead_patterns(
            lookahead_steps, slowpath_distance, voltage)
        new_voltage = lookahead(step, position, data, i, voltages)

        if slowpath_distance == 0:
            yield OPCODES['slowpath']
            cnt += 1
        elif slowpath_distance > 0:
            if new_voltage != voltage:
                yield OPCODES['tick_page1']
                cnt += 1
            else:
                yield OPCODES['notick_page2']
                cnt += 1

        slowpath_distance -= 1
        if slowpath_distance == -12:
            # End of slowpath
            slowpath_distance = 2047

        voltage = new_voltage
        position += (voltage - position) / step
        err = (position - val) ** 2
        total_err += abs(err)

    for _ in range(cnt % 2048, 2047):
        yield OPCODES['notick_page1']
    yield OPCODES['exit']
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

    sample_rate = int(1024. * 1000 / 13)
    data = preprocess(serve_file, sample_rate)
    with open(out, "wb+") as f:
        for b in sample(data, step, lookahead_steps):
            f.write(bytes([b]))


if __name__ == "__main__":
    main(sys.argv)
