import argparse
import math
import numpy
import librosa
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


def filter_audio(
        audio: numpy.ndarray, sample_rate: float,
        sim_rate: float) -> numpy.ndarray:
    freq = 3875
    dt = 1 / sim_rate
    damping = -1210

    c1, c2, b1, b2 = params(freq, damping, dt)

    y1 = y2 = 0
    x1 = 0
    x2 = 0

    x1 = 1.0
    scale = 650  # TODO: analytic expression
    maxy = 0

    cycles_per_sample = int(sim_rate / sample_rate)

    audio_idx = 0
    sample = audio[0]
    duty_cycle = int((sample + 1) * cycles_per_sample / 2)
    next_toggle = duty_cycle
    cycles = 0
    y = 0
    bias = 1.0
    while audio_idx <= len(audio) / 10:
        if audio_idx % 10000 == 0:
            print(audio_idx, len(audio), y / scale, x1, sample, duty_cycle,
                  next_toggle)
        cycles += 1
        # x1 += bias / 4
        # if x1 > 1.0:
        #     x1 = 1.0
        # if x1 < -1.0:
        #     x1 = -1.0

        y = (c1 * y1 - c2 * y2 + b1 * x1 + b2 * x2)
        x2 = x1
        if cycles >= next_toggle:
            bias *= -1.0
            x1 *= -1.0
            # x1 += bias / 4
            # if x1 > 1.0:
            #     x1 = 1.0
            # if x1 < -1.0:
            #     x1 = -1.0
            if bias == 1.0:
                audio_idx += 1
                sample = audio[audio_idx]
                duty_cycle = int((sample + 1) * cycles_per_sample / 2)
            else:
                duty_cycle = cycles_per_sample - duty_cycle
            next_toggle += duty_cycle

        y2 = y1
        y1 = y
        if math.fabs(y) > maxy:
            maxy = math.fabs(y)
        yield y / scale
    print("scale = %f" % maxy)


def preprocess(
        filename: str, target_sample_rate: int, normalize: float,
        normalization_percentile: int) -> numpy.ndarray:
    """Upscale input audio to target sample rate and normalize signal."""

    data, _ = librosa.load(filename, sr=target_sample_rate, mono=True)

    max_value = numpy.percentile(data, normalization_percentile)
    data /= max_value
    data *= normalize

    return data


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--clock", choices=['pal', 'ntsc'],
                        help="Whether target machine clock speed is PAL ("
                             "1015657Hz) or NTSC (1020484)",
                        required=True)
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
    sim_rate = 1015657 if args.clock == 'pal' else 1020484  # NTSC

    input_audio = preprocess(args.input, sim_rate / 46, args.normalization,
                             args.norm_percentile)

    output_audio = numpy.array(
        list(filter_audio(input_audio, sim_rate / 46, sim_rate)),
        dtype=numpy.float32)

    output_rate = 96000
    output = librosa.resample(output_audio, orig_sr=sim_rate,
                              target_sr=output_rate)
    with sf.SoundFile(
            args.output, "w", output_rate, channels=1, format='WAV') \
            as f:
        f.write(output)


if __name__ == "__main__":
    main()
