import enum
import numpy


class Opcode(enum.Enum):
    TICK_00 = 0x00
    TICK_03 = 0x03
    TICK_06 = 0x06
    TICK_09 = 0x09
    TICK_0c = 0x0c
    TICK_0f = 0x0f
    TICK_10 = 0x10
    TICK_17 = 0x17
    TICK_1a = 0x1a
    TICK_1b = 0x1b
    TICK_23 = 0x23
    TICK_26 = 0x26
    TICK_27 = 0x27
    TICK_2a = 0x2a
    TICK_2e = 0x2e
    TICK_31 = 0x31
    TICK_32 = 0x32
    TICK_35 = 0x35
    TICK_3a = 0x3a
    TICK_3d = 0x3d
    TICK_46 = 0x46
    TICK_49 = 0x49
    TICK_4c = 0x4c
    TICK_51 = 0x51
    TICK_54 = 0x54
    TICK_57 = 0x57
    TICK_5d = 0x5d
    TICK_67 = 0x67
    TICK_72 = 0x72
    TICK_7c = 0x7c
    TICK_87 = 0x87
    TICK_8a = 0x8a
    TICK_8b = 0x8b
    TICK_91 = 0x91
    TICK_94 = 0x94
    TICK_95 = 0x95
    TICK_9c = 0x9c
    TICK_a5 = 0xa5
    EXIT = 0xaf
    END_OF_FRAME_0 = 0xb3


VOLTAGE_SCHEDULE = {
    Opcode.TICK_00: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_03: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_06: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_09: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_0c: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_0f: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_10: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_17: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_1a: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_1b: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_23: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_26: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_27: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_2a: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_2e: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_31: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_32: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_35: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_3a: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_3d: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_46: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_49: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_4c: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_51: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_54: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_57: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_5d: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_67: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_72: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_7c: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_87: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_8a: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_8b: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_91: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_94: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_95: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_9c: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_a5: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.END_OF_FRAME_0: numpy.array([1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0], dtype=numpy.float32),
}


TOGGLES = {
    Opcode.TICK_00: 3,
    Opcode.TICK_03: 2,
    Opcode.TICK_06: 1,
    Opcode.TICK_09: 0,
    Opcode.TICK_0c: 2,
    Opcode.TICK_0f: 1,
    Opcode.TICK_10: 1,
    Opcode.TICK_17: 2,
    Opcode.TICK_1a: 1,
    Opcode.TICK_1b: 1,
    Opcode.TICK_23: 2,
    Opcode.TICK_26: 1,
    Opcode.TICK_27: 1,
    Opcode.TICK_2a: 0,
    Opcode.TICK_2e: 2,
    Opcode.TICK_31: 1,
    Opcode.TICK_32: 1,
    Opcode.TICK_35: 0,
    Opcode.TICK_3a: 2,
    Opcode.TICK_3d: 1,
    Opcode.TICK_46: 2,
    Opcode.TICK_49: 1,
    Opcode.TICK_4c: 0,
    Opcode.TICK_51: 2,
    Opcode.TICK_54: 1,
    Opcode.TICK_57: 0,
    Opcode.TICK_5d: 2,
    Opcode.TICK_67: 2,
    Opcode.TICK_72: 2,
    Opcode.TICK_7c: 2,
    Opcode.TICK_87: 1,
    Opcode.TICK_8a: 0,
    Opcode.TICK_8b: 0,
    Opcode.TICK_91: 1,
    Opcode.TICK_94: 0,
    Opcode.TICK_95: 0,
    Opcode.TICK_9c: 1,
    Opcode.TICK_a5: 1,
}


EOF_OPCODES = (
    Opcode.END_OF_FRAME_0,
)
