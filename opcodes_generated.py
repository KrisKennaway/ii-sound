import enum
import numpy


class Opcode(enum.Enum):
    TICK_00 = 0x00
    TICK_03 = 0x03
    TICK_06 = 0x06
    TICK_09 = 0x09
    TICK_0c = 0x0c
    TICK_0f = 0x0f
    TICK_12 = 0x12
    TICK_14 = 0x14
    TICK_1f = 0x1f
    TICK_24 = 0x24
    TICK_27 = 0x27
    TICK_2a = 0x2a
    TICK_2f = 0x2f
    TICK_32 = 0x32
    TICK_34 = 0x34
    TICK_3b = 0x3b
    TICK_3e = 0x3e
    TICK_40 = 0x40
    TICK_47 = 0x47
    TICK_4a = 0x4a
    TICK_4b = 0x4b
    TICK_53 = 0x53
    TICK_56 = 0x56
    TICK_62 = 0x62
    TICK_6a = 0x6a
    TICK_6d = 0x6d
    TICK_75 = 0x75
    TICK_80 = 0x80
    TICK_8a = 0x8a
    TICK_95 = 0x95
    TICK_9f = 0x9f
    TICK_a2 = 0xa2
    TICK_a4 = 0xa4
    TICK_ae = 0xae
    TICK_b5 = 0xb5
    TICK_b8 = 0xb8
    TICK_bf = 0xbf
    TICK_c9 = 0xc9
    EXIT = 0xd2
    END_OF_FRAME = 0xd5


VOLTAGE_SCHEDULE = {
    Opcode.TICK_00: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_03: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_06: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_09: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_0c: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_0f: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_12: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_14: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_1f: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_24: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_27: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_2a: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_2f: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_32: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_34: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_3b: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_3e: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_40: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_47: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_4a: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_4b: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_53: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_56: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_62: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_6a: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_6d: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_75: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_80: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_8a: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_95: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_9f: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_a2: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_a4: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_ae: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_b5: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_b8: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float32),
    Opcode.TICK_bf: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
    Opcode.TICK_c9: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float32),
}


TOGGLES = {
    Opcode.TICK_00: 3,
    Opcode.TICK_03: 2,
    Opcode.TICK_06: 1,
    Opcode.TICK_09: 0,
    Opcode.TICK_0c: 2,
    Opcode.TICK_0f: 1,
    Opcode.TICK_12: 0,
    Opcode.TICK_14: 0,
    Opcode.TICK_1f: 0,
    Opcode.TICK_24: 2,
    Opcode.TICK_27: 1,
    Opcode.TICK_2a: 0,
    Opcode.TICK_2f: 2,
    Opcode.TICK_32: 1,
    Opcode.TICK_34: 1,
    Opcode.TICK_3b: 2,
    Opcode.TICK_3e: 1,
    Opcode.TICK_40: 1,
    Opcode.TICK_47: 2,
    Opcode.TICK_4a: 1,
    Opcode.TICK_4b: 1,
    Opcode.TICK_53: 2,
    Opcode.TICK_56: 1,
    Opcode.TICK_62: 1,
    Opcode.TICK_6a: 2,
    Opcode.TICK_6d: 1,
    Opcode.TICK_75: 2,
    Opcode.TICK_80: 2,
    Opcode.TICK_8a: 2,
    Opcode.TICK_95: 2,
    Opcode.TICK_9f: 1,
    Opcode.TICK_a2: 0,
    Opcode.TICK_a4: 0,
    Opcode.TICK_ae: 0,
    Opcode.TICK_b5: 1,
    Opcode.TICK_b8: 0,
    Opcode.TICK_bf: 1,
    Opcode.TICK_c9: 1,
}
