import sys
import functools
import numpy
import soundfile
from typing import List

PORT = 1977

OPCODES = {
    'tick': 0x00,
    'notick_page1': 0x08,
    'notick_page2': 0x10,
    'exit': 0x18,
    'slowpath': 0x28
}

# Errors
# 1000 LAH 1 = 704632.752909

# 100 LAH 1 Norm 0.5 = 6783135.377118

# 100 LAH 1 Norm 0.3 = 3251821.285253
# 100 LAH 2 Norm 0.3 = 6446570.565330

# 100 LAH 1 Norm 0.2 = 1798442.832489
# 100 LAH 7 Norm 0.2 = 1624865.370107

# 10 LAH 1 Norm 0.5 = 3251142.161679
# 20 LAH 1 Norm 0.5 = 3518009.983899
# 30 ... = 4137179.898981

# 40 LAH 1 Norm 0.5 = 4667834.501476
# 40 LAH 7 Norm 0.5 = 3614627.124544

# 50 ... = 5118520.178948
# 60 ... = 5513928.786507
# 70 ... = 5872060.623297
# 80 ... = 6198922.754212
# 90 ... = 6501755.264692
# 100 ... = 6782164.670392
# 200 = 8708489.044314
# 300 = 9686398.703931
# 400 = 10233308.826519
# 500 = 10567966.087857

# TODO: synchronize to VBL
# TODO: tick now has space to also flip a soft-switch


# @profile
def lookahead(step_size: int, initial_position: float,
              initial_voltage: float, data: numpy.ndarray, offset: int,
              toggles: List):

    # TODO: construct list of voltage values directly
    # - construct voltage trajectories from position and vectorize comparison
    voltage = initial_voltage
    position = initial_position

    total_error = 0.0
    for i, t in enumerate(toggles):
        target_val = data[i+offset]
        if t:
            voltage = -voltage
        position += (voltage - position) / step_size
        err = position - target_val
        total_error += abs(err)
    return total_error


# TODO: test slowpath
@functools.lru_cache(None)
def lookahead_patterns(lookahead: int, slowpath: int):
    patterns = []

    num_bits = max(lookahead - slowpath, 0)
    for i in range(2 ** num_bits):
        pattern = []
        for j in range(num_bits):
            pattern.append(bool((i >> j) & 1))
        pattern.extend([True for _ in range(min(slowpath, lookahead))])
        patterns.append(pattern)

    return patterns

def sample(data: numpy.ndarray, step: int, lookahead_steps: int):
    dlen = len(data)
    data = numpy.concatenate([data, numpy.zeros(lookahead_steps)])

    voltage = -1.0
    position = -1.0

    total_err = 0.0
    slowpath = 0
    cnt = 0
    for i, val in enumerate(data[:dlen]):
        if i % int((dlen / 100)) == 0:
            print("%d%% complete" % (i * 100 / dlen))
        if (cnt % 2048) == 2047:
            slowpath = 12

        min_err = 1e9
        best_pattern = None

        # TODO: double-check this
        slowpath_bits = max((cnt % 2048) + lookahead_steps - 2047, 0)
        for lh in lookahead_patterns(lookahead_steps, slowpath_bits):
            err = lookahead(step, position, voltage, data, i, lh)
            # print(err, lh)
            if err < min_err:
                min_err = err
                best_pattern = lh
                # "BEST: %f, %s --> %s" % (err, lh, lh[0]))

        if slowpath:
            if slowpath == 12:
                yield OPCODES['slowpath']
                cnt += 1
            slowpath -= 1
        elif best_pattern[0]:
            voltage = -voltage
            yield OPCODES['tick']
            cnt += 1
        else:
            yield OPCODES['notick_page1']
            cnt += 1
        position += (voltage - position) / step
        err = position - val
        total_err += abs(err)
        # print("State: ", sp.voltage, sp.position, val)

    for _ in range(cnt % 2048, 2047):
        yield OPCODES['notick_page1']
    yield OPCODES['exit']
    print("Total error %f" % total_err)


def main(argv):
    serve_file = argv[1]
    step = int(argv[2])
    lookahead_steps = int(argv[3])
    out = argv[4]

    data, sr = soundfile.read(serve_file)
    with open(out, "wb+") as f:
        for b in sample(data, step, lookahead_steps):
            f.write(bytes([b]))


if __name__ == "__main__":
    main(sys.argv)
