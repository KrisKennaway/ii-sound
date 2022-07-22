from typing import Iterable, Tuple

import numpy


class Opcode:
    """6502 assembly language opcode with cycle length"""

    def __init__(self, cycles, num_bytes, asm="", indent=4, toggle=False):
        self.cycles = cycles
        self.bytes = num_bytes
        self.asm = asm
        self.indent = indent
        # The opcode toggles speaker (only) on the last cycle
        self.toggle = toggle

    def __repr__(self):
        asm = "[%s] " % self.asm if self.asm else ""
        return "%s<%d cycles>" % (asm, self.cycles)

    def __str__(self):
        indent = " " * self.indent
        comment = ' ; %d cycles' % self.cycles if self.cycles else ""
        return indent + self.asm + comment


class Literal(Opcode):
    def __init__(self, asm, indent=4):
        super(Literal, self).__init__(
            cycles=0, num_bytes=0, asm=asm, indent=indent)

    def __repr__(self):
        return "<literal>"


class PaddingOpcode(Opcode):
    """Opcode variant that can be replaced by other interleaved opcodes."""
    pass


STA_C030 = Opcode(4, 3, "STA $C030", toggle=True)
# TODO: support 6502 cycle timings (5 cycles instead of 6)
JMP_WDATA = Opcode(6, 3, "JMP (WDATA)")


def padding(cycles):
    return PaddingOpcode(cycles, None, "; pad %d cycles" % cycles)


def nops(cycles: int) -> Iterable[Opcode]:
    if cycles < 2:
        raise ValueError
    while cycles:
        if cycles == 3:
            yield Opcode(3, 2, "STA zpdummy")
            cycles -= 3
            continue
        yield Opcode(2, 1, "NOP")
        cycles -= 2


def interleave_opcodes(
        base_opcodes: Iterable[Opcode],
        interleaved_opcodes: Iterable[Opcode]) -> Iterable[Opcode]:
    for op in base_opcodes:
        if isinstance(op, PaddingOpcode):
            padding_cycles = op.cycles

            while padding_cycles > 0:
                if interleaved_opcodes:
                    interleaved_op = interleaved_opcodes[0]
                    if (padding_cycles - interleaved_op.cycles) >= 0 and (
                            padding_cycles - interleaved_op.cycles) != 1:
                        yield interleaved_op
                        padding_cycles -= interleaved_op.cycles
                        interleaved_opcodes = interleaved_opcodes[1::]
                        if not interleaved_opcodes:
                            return
                        continue
                if padding_cycles == 3:
                    yield PaddingOpcode(3, 2, "STA zpdummy")
                    padding_cycles -= 3
                else:
                    yield PaddingOpcode(2, 1, "NOP")
                    padding_cycles -= 2
            assert padding_cycles == 0
        else:
            yield op
    if interleaved_opcodes:
        print(interleaved_opcodes)
        raise OverflowError


def total_bytes(opcodes: Iterable[Opcode]) -> int:
    return sum(op.bytes for op in opcodes)


def total_cycles(opcodes: Iterable[Opcode]) -> int:
    return sum(op.cycles for op in opcodes)


def voltages(opcodes: Iterable[Opcode]) -> Tuple[float]:
    res = []
    speaker = 1.0
    for op in opcodes:
        if not op.cycles:
            continue
        res.extend([speaker] * (op.cycles - 1))
        if op.toggle:
            speaker *= -1
        res.append(speaker)
    return tuple(res)


def join_voltages(op_seq: Iterable[Iterable[Opcode]]) -> numpy.ndarray:
    res = []
    last_voltage = 1.0
    for ops in op_seq:
        op_voltages = voltages(ops)
        res.extend(
            numpy.array(op_voltages, dtype=numpy.float32) * last_voltage)
        last_voltage = res[-1]

    return numpy.array(res, dtype=numpy.float32)
