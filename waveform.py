import math
import random
import soundfile as sf


def wave(count: int):
    freq = 3875
    dt = 1 / 44100.
    damping = -1210 # -0.015167
    w = freq * 2 * math.pi * dt
    d = damping * dt
    e = math.exp(d)
    c1 = 2 * e * math.cos(w)

    c2 = e * e
    y1 = y2 = 0
    x1 = 0
    x2 = 0
    t0 = (1 - 2 * e * math.cos(w) + e * e) / (d * d + w * w)
    t = d * d + w * w - math.pi * math.pi
    t1 = (1 + 2 * e * math.cos(w) + e * e) / math.sqrt(t * t + 4 * d * d *
                                                       math.pi * math.pi)
    b2 = (t1 - t0) / (t1 + t0)
    b1 = b2 * dt * dt * (t0 + t1) / 2

    # tm = math.atan(w/d)/w
    # scale = 500 * math.sqrt(d * d+ w * w) * math.exp(-d * tm) / (dt * 2000)

    x1 = 1.0
    th = 44100/3875/2
    switch = th
    scale = 25  # TODO: analytic expression
    for i in range(count):
        y = c1 * y1 - c2 * y2 + b1 * x1 + b2 * x2
        x2 = x1
        if i >= switch:
            x1 = -x1
            switch += th
        y2 = y1
        y1 = y
        yield y / scale


def main():
    with sf.SoundFile("out.wav", "w", samplerate=44100, channels=1) as f:
        f.write(list(wave(441000)))


if __name__ == "__main__":
    main()
