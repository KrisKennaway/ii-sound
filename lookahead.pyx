# cython: infer_types=True
# cython: profile=False
# cython: boundscheck=False
# cython: wraparound=False


import numpy as np


def evolve_return_best(object speaker, float position1, float position2, float voltage1, float voltage2, float[:, ::1] voltages, float[::1] data):
    cdef double c1 = speaker.c1
    cdef double c2 = speaker.c2
    cdef double b1 = speaker.b1
    cdef double b2 = speaker.b2
    cdef double scale = speaker.scale

    cdef int i, j
    cdef double y, y1, y2
    cdef float x1, x2

    cdef int lowest_idx
    cdef double lowest_err = 1e9
    cdef double error
    for i in range(voltages.shape[0]):
        x1 = voltage1
        x2 = voltage2
        y1 = position1
        y2 = position2
        error = 0
        for j in range(voltages.shape[1]):
            y = c1 * y1 - c2 * y2 + b1 * x1 + b2 * x2
            error += (y * scale - data[j]) ** 2
            if error > lowest_err:
                break
            x2 = x1
            x1 = voltages[i, j]  # XXX does this really always lag?
            y2 = y1
            y1 = y
        if error < lowest_err:
            lowest_err = error
            lowest_idx = i

    return lowest_idx


def evolve(object speaker, float position1, float position2, float voltage1, float voltage2, float[:, ::1] voltages):
    cdef double[:,::1] output = np.empty_like(voltages, dtype=np.float64)

    cdef double c1 = speaker.c1
    cdef double c2 = speaker.c2
    cdef double b1 = speaker.b1
    cdef double b2 = speaker.b2

    cdef int i, j
    cdef double y, y1, y2
    cdef float x1, x2

    for i in range(voltages.shape[0]):
        x1 = voltage1
        x2 = voltage2
        y1 = position1
        y2 = position2
        for j in range(voltages.shape[1]):
            y = c1 * y1 - c2 * y2 + b1 * x1 + b2 * x2
            output[i, j] = y
            x2 = x1
            x1 = voltages[i, j]  # XXX does this really always lag?
            y2 = y1
            y1 = y

    return output
