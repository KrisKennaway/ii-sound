import itertools
from typing import Iterable, List


class Opcode:
    """6502 assembly language opcode with cycle length"""

    def __init__(self, cycles, asm="", indent=4, toggle=False):
        self.cycles = cycles
        self.asm = asm
        self.indent = indent
        # Assume toggles speaker on the last cycle
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
        super(Literal, self).__init__(cycles=0, asm=asm, indent=indent)

    def __repr__(self):
        return "<literal>"


class PaddingOpcode(Opcode):
    """Opcode variant that can be replaced by other interleaved opcodes."""
    pass


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
                    yield PaddingOpcode(3, "STA zpdummy")
                    padding_cycles -= 3
                else:
                    yield PaddingOpcode(2, "NOP")
                    padding_cycles -= 2
            assert padding_cycles == 0
        else:
            yield op
    if interleaved_opcodes:
        print(interleaved_opcodes)
        raise OverflowError


STA_C030 = Opcode(4, "STA $C030", toggle=True)


def padding(cycles):
    return PaddingOpcode(cycles, "; pad %d cycles" % cycles)


CORE_EOF = [
    Literal(
        "; We've read exactly 2KB from the socket buffer.  Before continuing "
        "we need to ACK this read,"),
    Literal("; and make sure there's at least another 2KB in the buffer."),
    Literal(";"),
    Literal("; Save the W5100 address pointer so we can continue reading the "
            "socket buffer once we are done."),
    Literal(
        "; We know the low-order byte is 0 because Socket RX memory is "
        "page-aligned and so is 2K frame."),
    Literal(
        "; IMPORTANT - from now on until we restore this below, we can't "
        "trash the Y register!"),
    Opcode(4, "LDY WADRH"),
    Literal("; Update new Received Read pointer."),
    Literal(";"),
    Literal(
        "; We know we have received exactly 2KB, so we don't need to read the "
        "current value from the"),
    Literal("; hardware.  We can track it ourselves instead, which saves a "
            "few cycles."),
    Opcode(2, "LDA #>S0RXRD"),
    Opcode(4, "STA WADRH"),
    Opcode(2, "LDA #<S0RXRD"),
    Opcode(4, "STA WADRL"),
    Opcode(4, "LDA RXRD ; TODO: in principle we could update RXRD outside of "
              "the EOF path"),
    Opcode(2, "CLC"),
    Opcode(2, "ADC #$08"),
    Opcode(4, "STA WDATA ; Store new high byte of received read pointer"),
    Opcode(4, "STA RXRD ; Save for next time"),
    Literal("; Send the Receive command"),
    Opcode(2, "LDA #<S0CR"),
    Opcode(4, "STA WADRL"),
    Opcode(2, "LDA #SCRECV"),
    Opcode(4, "STA WDATA"),
    Literal(
        "; Make sure we have at least 2KB more in the socket buffer so we can "
        "start another frame."
    ),
    Opcode(2, "LDA #$07 ; 2"),
    Opcode(2, "LDX #<S0RXRSR ; Socket 0 Received Size register"),
    Literal(
        "; we might loop an unknown number of times here waiting for data but "
        "the default should be to"),
    Literal("; fall straight through"),
    Literal("@0:", indent=0),
    Opcode(4, "STX WADRL"),
    Opcode(4, "CMP WDATA ; High byte of received size"),
    Opcode(2,
           "BCS @0 ; 2 cycles in common case when there is already sufficient "
           "data waiting."),
    Literal(
        "; We're good to go for another frame.  Restore W5100 address pointer "
        "where we last found it, to"),
    Literal("; begin iterating through the next 2KB of the socket buffer."),
    Literal(";"),
    Literal(
        "; It turns out that the W5100 automatically wraps the address pointer "
        "at the end of the 8K"),
    Literal(
        "; RX/TX buffers.  Since we're using an 8K socket, that means we don't "
        "have to do any work to"),
    Literal("; manage the read pointer!"),
    Opcode(4, "STY WADRH"),
    Opcode(2, "LDA #$00"),
    Opcode(4, "STA WADRL"),
    Opcode(6, "JMP (WDATA)"),
]


def toggles(opcodes: Iterable[Opcode]) -> List[bool]:
    res = []
    speaker = True
    for op in opcodes:
        if not op.cycles:
            continue
        res.extend([speaker] * (op.cycles - 1))
        if op.toggle:
            speaker = not speaker
        res.append(speaker)
    return res


base = itertools.cycle([STA_C030, PaddingOpcode(6)])

eof = list(interleave_opcodes(base, CORE_EOF))
for op in eof:
    print(op)

print(toggles(eof))
