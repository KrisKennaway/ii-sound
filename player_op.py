import numpy


class PlayerOp:
    def __init__(self, name: str, byte: int, voltages: numpy.ndarray):
        self.name = name
        self.byte = byte
        self.voltages = voltages

    def __repr__(self):
        return self.name

    def define_self(self):
        return ("PlayerOp(name=\"%s\", byte=0x%02x, voltages=numpy.array("
                "%s, dtype=numpy.float32))" % (self.name, self.byte,
                                               repr(list(self.voltages))))
