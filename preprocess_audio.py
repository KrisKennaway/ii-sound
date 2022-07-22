"""Converts an input file to 1.024MHz wav file used by encode_audio.py"""

import argparse
import librosa
import numpy
import soundfile


def preprocess(
        filename: str, target_sample_rate: int, normalize: float = 1.0,
        normalization_percentile: int = 100) -> numpy.ndarray:
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
    parser.add_argument("input", type=str, help="input audio file to convert")
    parser.add_argument("output", type=str, help="output audio file")
    args = parser.parse_args()

    # Effective clock rate, including every-65 cycle "long cycle" that takes
    # 16/14 as long.
    sample_rate = 1015657 if args.clock == 'pal' else 1020484  # NTSC

    soundfile.write(args.output, preprocess(args.input, sample_rate),
                    sample_rate)


if __name__ == "__main__":
    main()
