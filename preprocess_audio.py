import sys
import librosa
import numpy
import soundfile as sf


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
    out = argv[2]
    sample_rate = int(1024. * 1000 / 13)

    sf.write(out, preprocess(serve_file, sample_rate), sample_rate)


if __name__ == "__main__":
    main(sys.argv)
