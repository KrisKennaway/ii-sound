import math
import librosa
import numpy
import soundfile as sf


def params(freq, damping, dt):
    w = freq * 2 * math.pi * dt
    d = damping * dt
    e = math.exp(d)
    c1 = 2 * e * math.cos(w)

    c2 = e * e
    t0 = (1 - 2 * e * math.cos(w) + e * e) / (d * d + w * w)
    t = d * d + w * w - math.pi * math.pi
    t1 = (1 + 2 * e * math.cos(w) + e * e) / math.sqrt(t * t + 4 * d * d *
                                                       math.pi * math.pi)
    b2 = (t1 - t0) / (t1 + t0)
    b1 = b2 * dt * dt * (t0 + t1) / 2

    return c1, c2, b1, b2


def wave(count: int, sample_rate):
    freq = 3875
    dt = 1 / sample_rate
    damping = -1210  # -0.015167

    c1, c2, b1, b2 = params(freq, damping, dt)

    # freq2 = 525
    # damping2 = -130
    #
    # cc1, cc2, bb1, bb2 = params(freq2, damping2, dt)
    # mult2 = 1#  0.11

    y1 = y2 = 0
    x1 = 0
    x2 = 0

    # tm = math.atan(w/d)/w
    # scale = 500 * math.sqrt(d * d+ w * w) * math.exp(-d * tm) / (dt * 2000)

    x1 = 1.0
    th = 23  # sample_rate // 10
    switch = th
    scale = 650  # TODO: analytic expression
    maxy = 0
    for i in range(count):
        # y =  (c1 * y1 - c2 * y2 + b1 * x1 + b2 * x2) + mult2 * (
        #         1 - cc1 * y1 + cc2 * y2 - bb1 * x1 - bb2 * x2)
        y = (c1 * y1 - c2 * y2 + b1 * x1 + b2 * x2)
        # print(i, y / scale, x1)
        x2 = x1
        if i >= switch:
            x1 = -x1
            switch += th
        y2 = y1
        y1 = y
        if math.fabs(y) > maxy:
            maxy = math.fabs(y)
        yield y / scale
    print(maxy)


def main():
    # print(list(wave(1020400)))
    sample_rate = 1015657
    output = numpy.array(list(wave(1015657, sample_rate)), dtype=numpy.float32)

    output_rate = 96000  # int(sample_rate / 4)
    output = librosa.resample(output, orig_sr=sample_rate,
                              target_sr=output_rate)
    with sf.SoundFile("out.wav", "w", samplerate=96000, channels=1) as f:
        f.write(output)


if __name__ == "__main__":
    main()
