import enum
import functools
import numpy
from typing import Dict, List, Tuple, Iterable


# TODO: support 6502 cycle counts as well
#
# class Opcode(enum.Enum):
#     """Audio player opcodes representing atomic units of audio playback work."""
#     TICK_17 = 0x00
#     TICK_15 = 0x01
#     TICK_13 = 0x02
#     TICK_14 = 0x0a
#     TICK_12 = 0x0b
#     TICK_10 = 0x0c
#     NOTICK_6 = 0x0f
#
#     EXIT = 0x12
#     SLOWPATH = 0x22
#
#     # XXX not yet diminishing returns, add more?
#     # TODO: incremental quality from each of these
#     TICK_TICK_TICK_TICK_TICK = 0x77
#     TICK_TICK_TICK_TICK = 0x7a
#     TICK_TICK_TICK = 0x7d
#     TICK_TICK = 0x80
#     INC_INC_INC_INC_INC = 0x89
#     INC_INC_INC_INC = 0x8c
#     INC_INC_INC = 0x8f
#     INC_INC = 0x92
#     INC = 0x95
#     STAX_STAX_STAX_STAX_STAX = 0x9b
#     STAX_STAX_STAX_STAX = 0x9e
#     STAX_STAX_STAX = 0xa1
#     STAX_STAX = 0xa4
#     STAX = 0xa7
#     INCX_INCX_INCX_INCX_INCX = 0xad
#     INCX_INCX_INCX_INCX = 0xb0
#     INCX_INCX_INCX = 0xb3
#     INCX_INCX = 0xb6
#     INCX = 0xb9
class Opcode(enum.Enum):
    TICK_01 = 0x01
    TICK_02 = 0x02
    TICK_03 = 0x03
    TICK_04 = 0x04
    TICK_05 = 0x05
    TICK_08 = 0x08
    TICK_09 = 0x09
    TICK_0a = 0x0a
    TICK_0b = 0x0b
    TICK_0c = 0x0c
    TICK_0e = 0x0e
    TICK_12 = 0x12
    TICK_13 = 0x13
    TICK_14 = 0x14
    TICK_17 = 0x17
    TICK_1b = 0x1b
    TICK_1c = 0x1c
    TICK_1d = 0x1d
    TICK_20 = 0x20
    TICK_24 = 0x24
    TICK_25 = 0x25
    TICK_27 = 0x27
    TICK_2e = 0x2e
    TICK_2f = 0x2f
    TICK_32 = 0x32
    TICK_36 = 0x36
    TICK_37 = 0x37
    TICK_3a = 0x3a
    TICK_3e = 0x3e
    TICK_40 = 0x40
    TICK_47 = 0x47
    TICK_49 = 0x49
    TICK_50 = 0x50
    TICK_53 = 0x53
    TICK_5a = 0x5a
    TICK_5d = 0x5d
    TICK_65 = 0x65
    TICK_70 = 0x70
    TICK_79 = 0x79
    TICK_82 = 0x82
    TICK_8b = 0x8b
    TICK_94 = 0x94
    EXIT = 0xfe
    SLOWPATH = 0xff


def make_tick_voltages(length) -> numpy.ndarray:
    """Voltage sequence for a NOP; ...; STA $C030; JMP (WDATA)."""
    c = numpy.full(length, 1.0, dtype=numpy.float64)
    for i in range(length - 7, length):  # TODO: 6502
        c[i] = -1.0
    return c


def make_notick_voltages(length) -> numpy.ndarray:
    """Voltage sequence for a NOP; ...; JMP (WDATA)."""
    return numpy.full(length, 1.0, dtype=numpy.float64)


def make_slowpath_voltages() -> numpy.ndarray:
    """Voltage sequence for slowpath TCP processing."""
    length = 14 * 10 + 10  # TODO: 6502
    c = numpy.full(length, 1.0, dtype=numpy.float64)
    voltage_high = True
    for i in range(15):
        voltage_high = not voltage_high
        for j in range(3 + 10 * i, min(length, 3 + 10 * (i + 1))):
            c[j] = 1.0 if voltage_high else -1.0
    return c


# exp3

class Opcode(enum.Enum):
    TICK_00 = 0x00
    TICK_01 = 0x01
    TICK_02 = 0x02
    TICK_03 = 0x03
    TICK_04 = 0x04
    TICK_05 = 0x05
    TICK_08 = 0x08
    TICK_09 = 0x09
    TICK_0a = 0x0a
    TICK_0b = 0x0b
    TICK_11 = 0x11
    TICK_12 = 0x12
    TICK_13 = 0x13
    TICK_1a = 0x1a
    TICK_1b = 0x1b
    TICK_23 = 0x23
    TICK_2c = 0x2c
    TICK_2d = 0x2d
    TICK_2e = 0x2e
    TICK_34 = 0x34
    TICK_35 = 0x35
    TICK_36 = 0x36
    TICK_3c = 0x3c
    TICK_3d = 0x3d
    TICK_46 = 0x46
    TICK_47 = 0x47
    TICK_4e = 0x4e
    TICK_4f = 0x4f
    TICK_56 = 0x56
    TICK_60 = 0x60
    TICK_6a = 0x6a
    TICK_72 = 0x72
    TICK_7a = 0x7a
    TICK_7b = 0x7b
    TICK_81 = 0x81
    TICK_8a = 0x8a
    TICK_93 = 0x93
    TICK_9c = 0x9c
    TICK_a5 = 0xa5
    TICK_ae = 0xae
    EXIT = 0xb5
    SLOWPATH = 0xb8


VOLTAGE_SCHEDULE = {
    Opcode.TICK_00: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
                                 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0),
                                dtype=numpy.float64),
    Opcode.TICK_01: numpy.array(
        (1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0),
        dtype=numpy.float64),
    Opcode.TICK_02: numpy.array(
        (1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0),
        dtype=numpy.float64),
    Opcode.TICK_03: numpy.array(
        (1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0),
        dtype=numpy.float64),
    Opcode.TICK_04: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0),
                                dtype=numpy.float64),
    Opcode.TICK_05: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0),
                                dtype=numpy.float64),
    Opcode.TICK_08: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
                                 -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0),
                                dtype=numpy.float64),
    Opcode.TICK_09: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0,
                                 -1.0, -1.0, -1.0, -1.0, -1.0),
                                dtype=numpy.float64),
    Opcode.TICK_0a: numpy.array(
        (1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0),
        dtype=numpy.float64),
    Opcode.TICK_0b: numpy.array(
        (1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0),
        dtype=numpy.float64),
    Opcode.TICK_11: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0,
                                 -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0),
                                dtype=numpy.float64),
    Opcode.TICK_12: numpy.array((
        1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0,
        -1.0, -1.0, -1.0, -1.0, -1.0),
        dtype=numpy.float64),
    Opcode.TICK_13: numpy.array(
        (1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0),
        dtype=numpy.float64),
    Opcode.TICK_1a: numpy.array((
        1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0,
        -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0),
        dtype=numpy.float64),
    Opcode.TICK_1b: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0,
                                 -1.0, -1.0, -1.0, -1.0, -1.0, -1.0),
                                dtype=numpy.float64),
    Opcode.TICK_23: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0,
                                 -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0,
                                 -1.0), dtype=numpy.float64),
    Opcode.TICK_2c: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, 1.0,
                                 -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0),
                                dtype=numpy.float64),
    Opcode.TICK_2d: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, -1.0, 1.0, -1.0, -1.0,
                                 -1.0, -1.0, -1.0, -1.0, -1.0),
                                dtype=numpy.float64),
    Opcode.TICK_2e: numpy.array(
        (1.0, 1.0, 1.0, -1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0),
        dtype=numpy.float64),
    Opcode.TICK_34: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, 1.0,
                                 1.0, 1.0, 1.0, 1.0, 1.0, 1.0),
                                dtype=numpy.float64),
    Opcode.TICK_35: numpy.array(
        (1.0, 1.0, 1.0, 1.0, 1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0),
        dtype=numpy.float64),
    Opcode.TICK_36: numpy.array(
        (1.0, 1.0, 1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0),
        dtype=numpy.float64),
    Opcode.TICK_3c: numpy.array((
        1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0,
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0),
        dtype=numpy.float64),
    Opcode.TICK_3d: numpy.array((
        1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0,
        1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float64),
    Opcode.TICK_46: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, -1.0, 1.0, -1.0, -1.0,
                                 -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0),
                                dtype=numpy.float64),
    Opcode.TICK_47: numpy.array((1.0, 1.0, 1.0, -1.0, 1.0, -1.0, -1.0, -1.0,
                                 -1.0, -1.0, -1.0, -1.0, -1.0, -1.0),
                                dtype=numpy.float64),
    Opcode.TICK_4e: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, -1.0, 1.0, 1.0, 1.0,
                                 1.0, 1.0, 1.0, 1.0, 1.0, 1.0),
                                dtype=numpy.float64),
    Opcode.TICK_4f: numpy.array(
        (1.0, 1.0, 1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0),
        dtype=numpy.float64),
    Opcode.TICK_56: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0,
                                 -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0),
                                dtype=numpy.float64),
    Opcode.TICK_60: numpy.array((
        1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0,
        1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0),
        dtype=numpy.float64),
    Opcode.TICK_6a: numpy.array((1.0, 1.0, 1.0, -1.0, 1.0, -1.0, -1.0, -1.0,
                                 -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0,
                                 -1.0), dtype=numpy.float64),
    Opcode.TICK_72: numpy.array((1.0, 1.0, 1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
                                 1.0, 1.0, 1.0, 1.0, 1.0, 1.0),
                                dtype=numpy.float64),
    Opcode.TICK_7a: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, -1.0, 1.0, -1.0, 1.0,
                                 1.0, 1.0, 1.0, 1.0, 1.0, 1.0),
                                dtype=numpy.float64),
    Opcode.TICK_7b: numpy.array(
        (1.0, 1.0, 1.0, -1.0, 1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0),
        dtype=numpy.float64),
    Opcode.TICK_81: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, 1.0,
                                 -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0),
                                dtype=numpy.float64),
    Opcode.TICK_8a: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, 1.0,
                                 -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0),
                                dtype=numpy.float64),
    Opcode.TICK_93: numpy.array((1.0, 1.0, 1.0, -1.0, 1.0, -1.0, -1.0, -1.0,
                                 -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0),
                                dtype=numpy.float64),
    Opcode.TICK_9c: numpy.array((1.0, 1.0, 1.0, -1.0, 1.0, 1.0, 1.0, 1.0, -1.0,
                                 -1.0, -1.0, -1.0, -1.0, -1.0, -1.0),
                                dtype=numpy.float64),
    Opcode.TICK_a5: numpy.array((1.0, 1.0, 1.0, -1.0, 1.0, 1.0, 1.0, 1.0, -1.0,
                                 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0),
                                dtype=numpy.float64),
    Opcode.TICK_ae: numpy.array((1.0, 1.0, 1.0, -1.0, 1.0, -1.0, 1.0, 1.0, 1.0,
                                 1.0, 1.0, 1.0, 1.0, 1.0, 1.0),
                                dtype=numpy.float64),
    Opcode.SLOWPATH: make_slowpath_voltages(),
}


#
# class Opcode(enum.Enum):
#   TICK_00 = 0x00
#   TICK_01 = 0x01
#   TICK_02 = 0x02
#   TICK_03 = 0x03
#   TICK_04 = 0x04
#   TICK_05 = 0x05
#   TICK_08 = 0x08
#   TICK_09 = 0x09
#   TICK_0a = 0x0a
#   TICK_0b = 0x0b
#   TICK_0c = 0x0c
#   TICK_11 = 0x11
#   TICK_12 = 0x12
#   TICK_13 = 0x13
#   TICK_14 = 0x14
#   TICK_1a = 0x1a
#   TICK_1b = 0x1b
#   TICK_1c = 0x1c
#   TICK_23 = 0x23
#   TICK_24 = 0x24
#   TICK_25 = 0x25
#   TICK_2d = 0x2d
#   TICK_2e = 0x2e
#   TICK_2f = 0x2f
#   TICK_37 = 0x37
#   TICK_38 = 0x38
#   TICK_40 = 0x40
#   TICK_41 = 0x41
#   TICK_4a = 0x4a
#   TICK_4b = 0x4b
#   TICK_54 = 0x54
#   TICK_5d = 0x5d
#   TICK_67 = 0x67
#   TICK_71 = 0x71
#   TICK_72 = 0x72
#   TICK_7b = 0x7b
#   TICK_85 = 0x85
#   TICK_8f = 0x8f
#   TICK_9a = 0x9a
#   TICK_a5 = 0xa5
#   TICK_b0 = 0xb0
#   EXIT = 0xba
#   SLOWPATH = 0xbd
#
# VOLTAGE_SCHEDULE = {
#   Opcode.TICK_00: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float64),
#   Opcode.TICK_01: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float64),
#   Opcode.TICK_02: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float64),
#   Opcode.TICK_03: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float64),
#   Opcode.TICK_04: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float64),
#   Opcode.TICK_05: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float64),
#   Opcode.TICK_08: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float64),
#   Opcode.TICK_09: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float64),
#   Opcode.TICK_0a: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float64),
#   Opcode.TICK_0b: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float64),
#   Opcode.TICK_0c: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float64),
#   Opcode.TICK_11: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float64),
#   Opcode.TICK_12: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float64),
#   Opcode.TICK_13: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float64),
#   Opcode.TICK_14: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float64),
#   Opcode.TICK_1a: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float64),
#   Opcode.TICK_1b: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float64),
#   Opcode.TICK_1c: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float64),
#   Opcode.TICK_23: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float64),
#   Opcode.TICK_24: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float64),
#   Opcode.TICK_25: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float64),
#   Opcode.TICK_2d: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float64),
#   Opcode.TICK_2e: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float64),
#   Opcode.TICK_2f: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float64),
#   Opcode.TICK_37: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float64),
#   Opcode.TICK_38: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float64),
#   Opcode.TICK_40: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float64),
#   Opcode.TICK_41: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float64),
#   Opcode.TICK_4a: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float64),
#   Opcode.TICK_4b: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float64),
#   Opcode.TICK_54: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float64),
#   Opcode.TICK_5d: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float64),
#   Opcode.TICK_67: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float64),
#   Opcode.TICK_71: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float64),
#   Opcode.TICK_72: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float64),
#   Opcode.TICK_7b: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float64),
#   Opcode.TICK_85: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float64),
#   Opcode.TICK_8f: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float64),
#   Opcode.TICK_9a: numpy.array((1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float64),
#   Opcode.TICK_a5: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0), dtype=numpy.float64),
#   Opcode.TICK_b0: numpy.array((1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0), dtype=numpy.float64),
#   Opcode.SLOWPATH: make_slowpath_voltages(),
# }


def cycle_length(op: Opcode) -> int:
    """Returns the 65C02 cycle length of a player opcode."""
    return len(VOLTAGE_SCHEDULE[op])


@functools.lru_cache(None)
def opcode_choices(frame_offset: int) -> List[Opcode]:
    """Returns sorted list of valid opcodes for given frame offset.

    Sorted by decreasing cycle length, so that if two opcodes produce equally
    good results, we'll pick the one with the longest cycle count to reduce the
    stream bitrate.
    """
    if frame_offset == 2047:
        return [Opcode.SLOWPATH]

    opcodes = set(VOLTAGE_SCHEDULE.keys()) - {Opcode.SLOWPATH}
    return sorted(list(opcodes), key=cycle_length, reverse=True)


@functools.lru_cache(None)
def opcode_lookahead(
        frame_offset: int,
        lookahead_cycles: int) -> Tuple[Tuple[Opcode]]:
    """Recursively enumerates all valid opcode sequences."""

    ch = opcode_choices(frame_offset)
    ops = []
    for op in ch:
        if cycle_length(op) >= lookahead_cycles:
            ops.append((op,))
        else:
            for res in opcode_lookahead((frame_offset + 1) % 2048,
                                        lookahead_cycles - cycle_length(op)):
                ops.append((op,) + res)
    return tuple(ops)  # TODO: fix return type


@functools.lru_cache(None)
def cycle_lookahead(
        opcodes: Tuple[Opcode],
        lookahead_cycles: int
) -> Tuple[float]:
    """Computes the applied voltage effects of a sequence of opcodes.

    i.e. produces the sequence of applied voltage changes that will result
    from executing these opcodes, limited to the next lookahead_cycles.
    """
    cycles = []
    for op in opcodes:
        cycles.extend(VOLTAGE_SCHEDULE[op])
    return tuple(cycles[:lookahead_cycles])


@functools.lru_cache(None)
def candidate_opcodes(
        frame_offset: int, lookahead_cycles: int
) -> Tuple[List[Opcode], numpy.ndarray]:
    """Deduplicate a tuple of opcode sequences that are equivalent.

    For each opcode sequence whose effect is the same when truncated to
    lookahead_cycles, retains the first such opcode sequence.
    """
    opcodes = opcode_lookahead(frame_offset, lookahead_cycles)
    seen_cycles = set()
    pruned_opcodes = []
    pruned_cycles = []
    for ops in opcodes:
        cycles = cycle_lookahead(ops, lookahead_cycles)
        if cycles in seen_cycles:
            continue
        seen_cycles.add(cycles)
        pruned_opcodes.append(ops)
        pruned_cycles.append(cycles)

    return pruned_opcodes, numpy.array(pruned_cycles, dtype=numpy.float64)
