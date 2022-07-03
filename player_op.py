import numpy


class PlayerOp:
    def __init__(self, name: str, byte: int, toggles: numpy.ndarray):
        self.name = name
        self.byte = byte
        self.toggles = toggles

    def __repr__(self):
        return self.name

    def define_self(self):
        return ("PlayerOp(name=\"%s\", byte=0x%02x, toggles=numpy.array("
                "%s, dtype=numpy.float32))" % (self.name, self.byte,
                                               repr(list(self.toggles))))
