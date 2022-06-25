import enum
import itertools
import numpy
from typing import Iterable, List, Tuple

import opcodes_6502

SLOW_PATH_TRAMPOLINE = [
    opcodes_6502.Literal("eof_slow_path:", indent=0),
    opcodes_6502.STA_C030,
    opcodes_6502.Opcode(4, 3, "LDX WDATA"),
    opcodes_6502.Opcode(4, 3, "STX @jmp+1"),
    opcodes_6502.Literal("@jmp:", indent=0),
    opcodes_6502.Opcode(6, 3, "JMP ($2000)")  # TODO: 5 cycles on 6502
]

SLOW_PATH_EOF = [
    opcodes_6502.Literal(
        "; We've read exactly 2KB from the socket buffer.  Before continuing "
        "we need to ACK this read,"),
    opcodes_6502.Literal(
        "; and make sure there's at least another 2KB in the buffer."),
    opcodes_6502.Literal(";"),
    opcodes_6502.Literal(
        "; Save the W5100 address pointer so we can continue reading the "
        "socket buffer once we are done."),
    opcodes_6502.Literal(
        "; We know the low-order byte is 0 because Socket RX memory is "
        "page-aligned and so is 2K frame."),
    opcodes_6502.Literal(
        "; IMPORTANT - from now on until we restore this below, we can't "
        "trash the Y register!"),
    opcodes_6502.Opcode(4, 4, "LDY WADRH"),
    opcodes_6502.Literal("; Update new Received Read pointer."),
    opcodes_6502.Literal(";"),
    opcodes_6502.Literal(
        "; We know we have received exactly 2KB, so we don't need to read the "
        "current value from the"),
    opcodes_6502.Literal(
        "; hardware.  We can track it ourselves instead, which saves a "
        "few cycles."),
    opcodes_6502.Opcode(2, 2, "LDA #>S0RXRD"),
    opcodes_6502.Opcode(4, 3, "STA WADRH"),
    opcodes_6502.Opcode(2, 2, "LDA #<S0RXRD"),
    opcodes_6502.Opcode(4, 3, "STA WADRL"),
    opcodes_6502.Opcode(4, 3,
                        "LDA RXRD ; TODO: in principle we could update RXRD outside of "
                        "the EOF path"),
    opcodes_6502.Opcode(2, 1, "CLC"),
    opcodes_6502.Opcode(2, 2, "ADC #$08"),
    opcodes_6502.Opcode(4, 3,
                        "STA WDATA ; Store new high byte of received read pointer"),
    opcodes_6502.Opcode(4, 3, "STA RXRD ; Save for next time"),
    opcodes_6502.Literal("; Send the Receive command"),
    opcodes_6502.Opcode(2, 2, "LDA #<S0CR"),
    opcodes_6502.Opcode(4, 3, "STA WADRL"),
    opcodes_6502.Opcode(2, 2, "LDA #SCRECV"),
    opcodes_6502.Opcode(4, 3, "STA WDATA"),
    opcodes_6502.Literal(
        "; Make sure we have at least 2KB more in the socket buffer so we can "
        "start another frame."
    ),
    opcodes_6502.Opcode(2, 2, "LDA #$07"),
    opcodes_6502.Opcode(2, 2, "LDX #<S0RXRSR ; Socket 0 Received Size "
                              "register"),
    opcodes_6502.Literal(
        "; we might loop an unknown number of times here waiting for data but "
        "the default should be to"),
    opcodes_6502.Literal("; fall straight through"),
    opcodes_6502.Literal("@0:", indent=0),
    opcodes_6502.Opcode(4, 3, "STX WADRL"),
    opcodes_6502.Opcode(4, 3, "CMP WDATA ; High byte of received size"),
    opcodes_6502.Opcode(2, 2,
                        "BCS @0 ; 2 cycles in common case when there is already sufficient "
                        "data waiting."),
    opcodes_6502.Literal(
        "; We're good to go for another frame.  Restore W5100 address pointer "
        "where we last found it, to"),
    opcodes_6502.Literal(
        "; begin iterating through the next 2KB of the socket buffer."),
    opcodes_6502.Literal(";"),
    opcodes_6502.Literal(
        "; It turns out that the W5100 automatically wraps the address pointer "
        "at the end of the 8K"),
    opcodes_6502.Literal(
        "; RX/TX buffers.  Since we're using an 8K socket, that means we don't "
        "have to do any work to"),
    opcodes_6502.Literal("; manage the read pointer!"),
    opcodes_6502.Opcode(4, 3, "STY WADRH"),
    opcodes_6502.Opcode(2, 2, "LDA #$00"),
    opcodes_6502.Opcode(4, 3, "STA WADRL"),
    opcodes_6502.Opcode(6, 3, "JMP (WDATA)"),
]

# Fast path really only requires 1 byte but we have to burn an extra one to
# sync up to 2KB boundary
FAST_PATH_EOF = [opcodes_6502.Opcode(4, 3, "LDA WDATA")] + SLOW_PATH_EOF


def fast_path_trampoline(label: str) -> List[opcodes_6502.Opcode]:
    return [
        opcodes_6502.Literal("eof_fast_path_%s:", indent=0),
        opcodes_6502.STA_C030,
        opcodes_6502.Opcode(3, 3, "JMP _eof_fast_path_%s" % label)
    ]


# def _make_end_of_frame_voltages(cycles) -> numpy.ndarray:
#     """Voltage sequence for end-of-frame TCP processing."""
#     c = []
#     voltage_high = True
#     for i, skip_cycles in enumerate(cycles):
#         c.extend([1.0 if voltage_high else -1.0] * (skip_cycles - 1))
#         if i != len(cycles) - 1:
#             voltage_high = not voltage_high
#         c.append(1.0 if voltage_high else -1.0)
#     return numpy.array(c, dtype=numpy.float32)

#
# # These are duty cycles
# eof_cycles = [
#     # (16,6),
#     # (14,6),
#     # (12,8),  # -0.15
#     # (14, 10),  # -0.10
#     # (12,10),  # -0.05
#     # (4, 40, 4, 40, 4, 40, 4, 6),
#     # (4, 38, 6, 38, 6, 38, 6, 6),
#     # (4, 36, 8, 36, 8, 36, 8, 6),
#     # (4, 34, 10, 34, 10, 34, 10, 6),
#     # (4, 32, 12, 32, 12, 32, 12, 6),
#     # (4, 30, 14, 30, 14, 30, 14, 6),
#     (4, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 6),  # 0.0
#     (4, 11, 10, 11, 10, 11, 10, 11, 10, 11, 10, 11, 10, 11, 6),  # 0.046
#     (4, 24, 20, 24, 20, 24, 20, 6),  # 0.09
#     (4, 10, 8, 10, 8, 10, 8, 10, 8, 10, 8, 10, 8, 10, 8, 10, 6),  # 0.11
#     (4, 13, 10, 13, 10, 13, 10, 13, 10, 13, 10, 13, 10, 13, 6),  # 0.13
#     (4, 28, 20, 28, 20, 28, 20, 6),  # 0.166
#     (4, 26, 18, 26, 18, 26, 18, 6),  # 0.18
#     (4, 24, 16, 24, 16, 24, 16, 6),  # 0.2
#
#     # (10, 8, 10, 10, 10, 8),  # 0.05
#     # (12, 10, 12, 8, 10, 10),  # 0.1
#     # (4, 10, 8, 10, 8, 10, 8, 10, 8, 10, 8, 10, 8, 10, 8, 10, 8, 10, 6),  # 0.15
#     # (10, 6, 12, 6),  # 0.20
#     # (10, 4),  # 0.25
#     # (14, 4, 10, 6),  # 0.30
#     # (12, 4),  # 0.35
#     # (14, 4),  # 0.40
# ]
#
import itertools


def _make_end_of_frame_voltages2(cycles) -> numpy.ndarray:
    """Voltage sequence for end-of-frame TCP processing."""
    max_len = 140
    voltage_high = False
    c = [1.0, 1.0, 1.0, -1.0]  # STA $C030
    for i, skip_cycles in enumerate(itertools.cycle(cycles)):
        c.extend([1.0 if voltage_high else -1.0] * (skip_cycles - 1))
        voltage_high = not voltage_high
        c.append(1.0 if voltage_high else -1.0)
        if len(c) >= max_len:
            break
    c.extend([1.0 if voltage_high else -1.0] * 6)  # JMP (WDATA)
    return numpy.array(c, dtype=numpy.float32)
#
#
def _duty_cycles():
    res = {}

    for i in range(4, 50, 2):
        for j in range(i, 50, 2):
            if i + j < 20 or i + j > 50:
                continue
            duty = j / (i + j) * 2 - 1
            res.setdefault(duty, []).append((i + j, i, j))

    cycles = []
    for c in sorted(list(res.keys())):
        pair = sorted(sorted(res[c], reverse=False)[0][1:], reverse=True)
        cycles.append(pair)

    # return [(10, 10), (12, 10), (12, 8), (14, 10), (14, 6), (14, 8)]
    return cycles


eof_cycles = _duty_cycles()


# def voltage_sequence(
#         opcodes: Iterable[Opcode], starting_voltage=1.0
# ) -> Tuple[numpy.float32, int]:
#     """Voltage sequence for sequence of opcodes."""
#     out = []
#     v = starting_voltage
#     toggles = 0
#     for op in opcodes:
#         for nv in v * numpy.array(VOLTAGES[op]):
#             if v != nv:
#                 toggles += 1
#             v = nv
#             out.append(v)
#     return tuple(numpy.array(out, dtype=numpy.float32)), toggles


def audio_opcodes() -> Iterable[opcodes_6502.Opcode]:
    # Interleave 3 x STA_C030 with 0,2,4 intervening NOP cycles
    # We don't need to worry about 6 or more cycle paddings because
    # these can always be achieved by chaining JMP (WDATA) to itself
    for i in range(0, 6, 2):
        for j in range(0, 6, 2):
            ops = []
            # don't need to worry about 0 or 2 since they are subsequences
            ops.extend(opcodes_6502.nops(4))
            ops.append(opcodes_6502.STA_C030)
            if i:
                ops.extend(opcodes_6502.nops(i))
            ops.append(opcodes_6502.STA_C030)
            if j:
                ops.extend(opcodes_6502.nops(j))
            ops.append(opcodes_6502.STA_C030)
            ops.append(opcodes_6502.JMP_WDATA)
            yield tuple(ops)

    # Add a NOP sled so we can more efficiently chain together longer
    # runs of NOPs without wasting bytes in the TCP frame by chaining
    # together JMP (WDATA)
    yield tuple(
        [nop for nop in opcodes_6502.nops(20)] + [opcodes_6502.JMP_WDATA])


def generate_player(
        player_ops: Iterable[Tuple[opcodes_6502.Opcode]],
        opcode_filename: str,
        player_filename: str
):
    num_bytes = 0
    seen_op_suffix_toggles = set()
    offset = 0
    unique_entrypoints = {}
    toggles = {}
    with open(player_filename, "w+") as f:
        for i, ops in enumerate(player_ops):
            player_op = []
            for j, op in enumerate(ops):
                op_suffix_toggles = opcodes_6502.toggles(ops[j:])
                if op_suffix_toggles not in seen_op_suffix_toggles:
                    # new subsequence
                    seen_op_suffix_toggles.add(op_suffix_toggles)
                    player_op.append(
                        opcodes_6502.Literal(
                            "tick_%02x: ; voltages %s" % (
                                offset, op_suffix_toggles), indent=0))
                    unique_entrypoints[offset] = op_suffix_toggles
                player_op.append(op)
                offset += op.bytes

            assert unique_entrypoints
            player_op_len = opcodes_6502.total_bytes(player_op)
            # Make sure we reserve 9 bytes for END_OF_FRAME and EXIT
            assert (num_bytes + player_op_len) <= (256 - 9)

            for op in player_op:
                f.write("%s\n" % str(op))

            num_bytes += player_op_len
            f.write("\n")

        f.write("; %d entrypoints, %d bytes\n" % (
            len(unique_entrypoints), num_bytes))

    with open(opcode_filename, "w") as f:
        f.write("import enum\nimport numpy\n\n\n")
        f.write("class Opcode(enum.Enum):\n")
        for o in unique_entrypoints.keys():
            f.write("    TICK_%02x = 0x%02x\n" % (o, o))
        f.write("    EXIT = 0x%02x\n" % num_bytes)
        # f.write("    END_OF_FRAME = 0x%02x\n" % (num_bytes + 3))
        for i, _ in enumerate(eof_cycles):
            f.write("    END_OF_FRAME_%d = 0x%02x\n" % (i, num_bytes + 4 + i))
        f.write("\n\nVOLTAGE_SCHEDULE = {\n")
        for o, v in unique_entrypoints.items():
            f.write(
                "    Opcode.TICK_%02x: numpy.array(%s, dtype=numpy.float32),"
                "\n" % (o, v))
        for i, skip_cycles in enumerate(eof_cycles):
            f.write("    Opcode.END_OF_FRAME_%d: numpy.array([%s], "
                    "dtype=numpy.float32),  # %s\n" % (i, ", ".join(
                str(f) for f in _make_end_of_frame_voltages2(
                    skip_cycles)), skip_cycles))
        f.write("}\n")
    #
    #     f.write("\n\nTOGGLES = {\n")
    #     for o, v in toggles.items():
    #         f.write(
    #             "    Opcode.TICK_%02x: %d,\n" % (o, v)
    #         )
    #     f.write("}\n")
    #
        f.write("\n\nEOF_OPCODES = (\n")
        for i in range(len(eof_cycles)):
            f.write("    Opcode.END_OF_FRAME_%d,\n" % i)
        f.write(")\n")


def main():
    player_ops = audio_opcodes()
    generate_player(
        player_ops,
        opcode_filename="opcodes_generated.py",
        player_filename="player/player_generated.s"
    )


if __name__ == "__main__":
    main()
