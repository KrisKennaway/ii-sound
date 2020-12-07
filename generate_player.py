import enum
import itertools
import numpy
from typing import Iterable, List, Tuple


class Opcode(enum.Enum):
    NOP = 1
    NOP3 = 2
    STA = 3
    STAX = 4
    INC = 5
    INCX = 6
    JMP_INDIRECT = 7


# Byte length of opcodes
OPCODE_LEN = {
    Opcode.NOP: 1, Opcode.NOP3: 2, Opcode.STA: 3, Opcode.STAX: 3,
    Opcode.INC: 3, Opcode.INCX: 3, Opcode.JMP_INDIRECT: 3
}

ASM = {
    Opcode.NOP: "NOP", Opcode.NOP3: "STA zpdummy",
    Opcode.STA: "STA $C030", Opcode.STAX: "STA $C030,X",
    Opcode.INC: "INC $C030", Opcode.INCX: "INC $C030,X",
    Opcode.JMP_INDIRECT: "JMP (WDATA)"
}

# Applied speaker voltages resulting from executing opcode
VOLTAGES = {
    Opcode.STA: [1, 1, 1, -1],
    Opcode.INC: [1, 1, 1, -1, 1, -1],
    Opcode.INCX: [1, 1, 1, -1, 1, -1, 1],
    Opcode.STAX: [1, 1, 1, -1, 1],
    Opcode.NOP: [1, 1],
    Opcode.NOP3: [1, 1, 1],
    # TODO: support 6502 cycle counts as well
    Opcode.JMP_INDIRECT: [1, 1, 1, 1, 1, 1],
}


def voltage_sequence(
        opcodes: Iterable[Opcode], starting_voltage=1.0) -> numpy.ndarray:
    """Voltage sequence for sequence of opcodes."""
    out = []
    v = starting_voltage
    for op in opcodes:
        for nv in v * numpy.array(VOLTAGES[op]):
            v = nv
            out.append(v)
    return numpy.array(out, dtype=numpy.float64)


def all_opcodes(
        max_len: int, opcodes: Iterable[Opcode], start_opcodes: Iterable[Opcode]
) -> Iterable[Tuple[Opcode]]:
    """Enumerate all combinations of opcodes up to max_len cycles"""
    num_opcodes = 0
    while True:
        found_one = False
        for ops in itertools.product(opcodes, repeat=num_opcodes):
            ops = tuple(list(ops) + [Opcode.JMP_INDIRECT])
            if ops[0] not in start_opcodes:
                continue
            if sum(len(VOLTAGES[o]) for o in ops) <= max_len:
                found_one = True
                yield ops
        if not found_one:
            break
        num_opcodes += 1


def generate_player(
        max_cycles: int, opcodes: List[Opcode], start_opcodes: List[Opcode],
        opcode_filename: str, player_filename: str):
    num_bytes = 0

    seqs = {}
    num_op = 0
    offset = 0
    unique_opcodes = {}
    all_ops = sorted(
        list(all_opcodes(max_cycles, opcodes, start_opcodes)),
        key=lambda o: len(o), reverse=True)

    with open(player_filename, "w+") as f:
        for i, k in enumerate(all_ops):
            is_unique = False
            player_op = []
            player_op_len = 0

            new_offset = offset
            for j, o in enumerate(k):
                seq = tuple(voltage_sequence(k[j:], 1.0))
                dup = seqs.setdefault(seq, i)
                if dup == i:
                    player_op.append("tick_%02x: ; voltages %s" % (
                        new_offset, seq))
                    is_unique = True
                    unique_opcodes[new_offset] = seq
                player_op.append("  %s" % ASM[o])
                player_op_len += OPCODE_LEN[o]
                new_offset += OPCODE_LEN[o]
            player_op.append("\n")

            # If at least one of the partial opcode sequences was not
            # a dup, then add it to the player
            if is_unique:
                num_op += 1
                f.write("\n".join(player_op))
                num_bytes += player_op_len
                offset = new_offset

        f.write("; %d bytes\n" % num_bytes)

    with open(opcode_filename, "w") as f:
        f.write("import enum\nimport numpy\n\n\n")
        f.write("class Opcode(enum.Enum):\n")
        for o in unique_opcodes.keys():
            f.write("    TICK_%02x = 0x%02x\n" % (o, o))
        f.write("    EXIT = 0x%02x\n" % num_bytes)
        f.write("    SLOWPATH = 0x%02x\n" % (num_bytes + 3))

        f.write("\n\nVOLTAGE_SCHEDULE = {\n")
        for o, v in unique_opcodes.items():
            f.write(
                "    Opcode.TICK_%02x: numpy.array(%s, dtype=numpy.float64),"
                "\n" % (o, v))
        f.write("}\n")


if __name__ == "__main__":
    generate_player(
        max_cycles=19,  # TODO: flag
        opcodes=[
            Opcode.NOP,
            Opcode.NOP3,
            Opcode.STA,
            # Opcode.INC,
            # Opcode.INCX
            # Opcode.STAX
        ],
        start_opcodes=[Opcode.STA, Opcode.INC, Opcode.INCX, Opcode.STAX,
                       Opcode.JMP_INDIRECT],
        opcode_filename="opcodes_generated.py",
        player_filename="player/player_generated.s"
    )