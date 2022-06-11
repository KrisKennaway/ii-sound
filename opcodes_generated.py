import enum
import numpy


class Opcode(enum.Enum):
    TICK_00 = 0x00
    TICK_03 = 0x03
    TICK_06 = 0x06
    TICK_09 = 0x09
    TICK_0a = 0x0a
    TICK_0d = 0x0d
    TICK_10 = 0x10
    TICK_13 = 0x13
    TICK_14 = 0x14
    TICK_1a = 0x1a
    TICK_1d = 0x1d
    TICK_1e = 0x1e
    TICK_27 = 0x27
    TICK_33 = 0x33
    TICK_36 = 0x36
    TICK_39 = 0x39
    TICK_3a = 0x3a
    TICK_3f = 0x3f
    TICK_42 = 0x42
    TICK_43 = 0x43
    TICK_4b = 0x4b
    TICK_4e = 0x4e
    TICK_4f = 0x4f
    TICK_57 = 0x57
    TICK_5a = 0x5a
    TICK_5b = 0x5b
    TICK_63 = 0x63
    TICK_6e = 0x6e
    TICK_79 = 0x79
    TICK_84 = 0x84
    TICK_87 = 0x87
    TICK_88 = 0x88
    TICK_8f = 0x8f
    EXIT = 0x99
    END_OF_FRAME_0 = 0x9d
    END_OF_FRAME_1 = 0x9e
    END_OF_FRAME_2 = 0x9f
    END_OF_FRAME_3 = 0xa0
    END_OF_FRAME_4 = 0xa1
    END_OF_FRAME_5 = 0xa2


VOLTAGE_SCHEDULE = {
    Opcode.TICK_00: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_03: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_06: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_09: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_0a: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_0d: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_10: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_13: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_14: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_1a: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_1d: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_1e: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_27: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_33: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_36: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_39: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_3a: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_3f: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_42: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_43: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_4b: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_4e: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_4f: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_57: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_5a: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_5b: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_63: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_6e: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_79: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_84: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_87: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_88: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_8f: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.END_OF_FRAME_0: numpy.array([1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0], dtype=numpy.float32),  # (10, 10)
    Opcode.END_OF_FRAME_1: numpy.array([1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0], dtype=numpy.float32),  # (12, 10)
    Opcode.END_OF_FRAME_2: numpy.array([1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0], dtype=numpy.float32),  # (12, 8)
    Opcode.END_OF_FRAME_3: numpy.array([1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0], dtype=numpy.float32),  # (14, 10)
    Opcode.END_OF_FRAME_4: numpy.array([1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0], dtype=numpy.float32),  # (14, 6)
    Opcode.END_OF_FRAME_5: numpy.array([1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0], dtype=numpy.float32),  # (14, 8)
}


TOGGLES = {
    Opcode.TICK_00: 3,
    Opcode.TICK_03: 2,
    Opcode.TICK_06: 1,
    Opcode.TICK_09: 0,
    Opcode.TICK_0a: 0,
    Opcode.TICK_0d: 3,
    Opcode.TICK_10: 2,
    Opcode.TICK_13: 1,
    Opcode.TICK_14: 1,
    Opcode.TICK_1a: 3,
    Opcode.TICK_1d: 2,
    Opcode.TICK_1e: 2,
    Opcode.TICK_27: 3,
    Opcode.TICK_33: 2,
    Opcode.TICK_36: 1,
    Opcode.TICK_39: 0,
    Opcode.TICK_3a: 0,
    Opcode.TICK_3f: 2,
    Opcode.TICK_42: 1,
    Opcode.TICK_43: 1,
    Opcode.TICK_4b: 2,
    Opcode.TICK_4e: 1,
    Opcode.TICK_4f: 1,
    Opcode.TICK_57: 2,
    Opcode.TICK_5a: 1,
    Opcode.TICK_5b: 1,
    Opcode.TICK_63: 2,
    Opcode.TICK_6e: 2,
    Opcode.TICK_79: 2,
    Opcode.TICK_84: 1,
    Opcode.TICK_87: 0,
    Opcode.TICK_88: 0,
    Opcode.TICK_8f: 1,
}


EOF_OPCODES = (
    Opcode.END_OF_FRAME_0,
    Opcode.END_OF_FRAME_1,
    Opcode.END_OF_FRAME_2,
    Opcode.END_OF_FRAME_3,
    Opcode.END_OF_FRAME_4,
    Opcode.END_OF_FRAME_5,
)
