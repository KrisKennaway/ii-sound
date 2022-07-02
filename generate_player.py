import itertools
import numpy
from typing import Iterable, List, Tuple, Dict

import opcodes_6502


def audio_opcodes() -> Iterable[Tuple[opcodes_6502.Opcode]]:
    # These two basic sequences let us chain together STA $C030 with any number
    # >= 10 of intervening cycles (except 11).  We don't need to explicitly
    # include 6 or more cycles of NOP because those can be obtained by chaining
    # together JMP (WDATA) to itself
    #
    # XXX support 11 cycles explicitly?
    yield tuple(
        [nop for nop in opcodes_6502.nops(4)] + [
            opcodes_6502.STA_C030, opcodes_6502.JMP_WDATA])

    yield tuple(
        [nop for nop in opcodes_6502.nops(4)] + [
            opcodes_6502.Opcode(3, 2, "STA zpdummy"),
            opcodes_6502.STA_C030, opcodes_6502.JMP_WDATA])


def duty_cycle_range():
    cycles = []
    for i in range(4, 42):
        if i == 5:
            # No single-cycle instructions
            # XXX can we use a 5-cycle instruction that touches $C030 only on
            # last cycle?
            continue
        cycles.append(i)

    return cycles


def eof_trampoline_stage1(cycles):
    ops = [
        opcodes_6502.Literal(
            "eof_trampoline_%d:" % cycles, indent=0
        ),
        opcodes_6502.STA_C030,
    ]
    if cycles == 4:
        return ops + [
            opcodes_6502.STA_C030,
            opcodes_6502.Opcode(3, 3, "JMP eof_trampoline_%d_stage2" % cycles)
        ]
    if cycles == 5:
        return None
    if cycles == 6:
        return ops + [
            opcodes_6502.Opcode(2, 1, "NOP"),
            opcodes_6502.STA_C030,
            opcodes_6502.Opcode(3, 3, "JMP eof_trampoline_%d_stage2" % cycles)
        ]
    if cycles == 8:
        return ops + [
            opcodes_6502.Opcode(2, 1, "NOP"),
            opcodes_6502.Opcode(2, 1, "NOP"),
            opcodes_6502.STA_C030,
            opcodes_6502.Opcode(3, 3, "JMP eof_trampoline_%d_stage2" % cycles)
        ]
    return ops + [
        opcodes_6502.Opcode(3, 3, "JMP eof_trampoline_%d_stage2" % cycles)
    ]


EOF_TRAMPOLINE_STAGE1 = {
    a: eof_trampoline_stage1(a) for a in duty_cycle_range()
}


def eof_trampoline_stage2(cycles) -> List[opcodes_6502.Opcode]:
    label: List[opcodes_6502.Opcode] = [
        opcodes_6502.Literal(
            "eof_trampoline_%d_stage2:" % cycles, indent=0
        )
    ]

    ops = [
        opcodes_6502.Opcode(4, 3, "LDA WDATA"),
        opcodes_6502.Opcode(4, 3, "STA @0+1"),
        opcodes_6502.Literal("@0:", indent=0),
        opcodes_6502.Opcode(
            6, 3, "JMP (eof_trampoline_%d_stage3_page)" % cycles)
    ]
    if cycles < 7 or cycles == 8:
        return label + ops

    # For cycles == 7 or > 8 we need to interleave a STA $C030 into stage 2
    # because we couldn't fit it in stage 1
    interleave_ops = [
        opcodes_6502.padding(cycles - 7),
        opcodes_6502.STA_C030,
        opcodes_6502.padding(100)
    ]
    return label + list(opcodes_6502.interleave_opcodes(interleave_ops, ops))


EOF_TRAMPOLINE_STAGE2 = {
    a: eof_trampoline_stage2(a) for a in duty_cycle_range()
}


def cycles_after_tick(ops: Iterable[opcodes_6502.Opcode]) -> int:
    cycles = 0
    ticks = 0
    for op in ops:
        cycles += op.cycles
        if op.toggle:
            cycles = 0
            ticks += 1
    return cycles, ticks


STAGE1_CYCLES_AFTER_TICK = {
    a: cycles_after_tick(EOF_TRAMPOLINE_STAGE1[a]) for a in duty_cycle_range()
}

STAGE2_CYCLES_AFTER_TICK = {
    a: cycles_after_tick(EOF_TRAMPOLINE_STAGE2[a]) for a in duty_cycle_range()
}


def _duty_cycles(duty_cycles):
    # The player sequence for periods of silence (i.e. 0-valued waveform)
    # is a sequence of 10 cycle ticks, so we need to support maintaining
    # this during EOF in order to avoid introducing noise during such periods.
    res = {0.0: [(20, 10, 10)]}

    for i in duty_cycles:
        for j in duty_cycles:
            # We only need to worry about i < j because we can effectively
            # obtain the opposite cadence by inserting an extra half duty cycle
            # before the EOF
            # XXX try again removing this, we have space
            if j <= i:
                continue

            # Limit to min 22Khz carrier
            if (i + j) > 45:
                continue

            # When first duty cycle is small enough to fit in the stage 1
            # trampoline, we can't fit the second duty cycle in the stage 2
            # trampoline because we'd need too may stage 1 variants to fit in
            # page 3.  That sets a lower bound on the second duty cycle.
            #
            # e.g.
            #
            # eof_trampoline_4:
            #     STA $C030 ; 4 cycles
            #     STA $C030 ; 4 cycles
            #     JMP eof_trampoline_4_stage2 ; 3 cycles
            #
            # eof_trampoline_4_stage2:
            #     LDA WDATA ; 4
            #     STA @0+1 ; 4
            # @0: JMP (xxyy) ; 6
            #
            # eof_trampoline_4_b_stage3:
            #     ; second duty cycle must land here, i.e the earliest it can
            #     ; be is 3 + 4 + 4 + 6 + 4 = 21 cycles
            if i in {4, 6, 8}:
                if j < 21:
                    continue
            else:
                # stage 1 is STA $C030; JMP stage_2
                stage_1_cycles, stage_1_ticks = STAGE1_CYCLES_AFTER_TICK[i]
                assert (stage_1_cycles, stage_1_ticks) == (3, 1)

                stage_2_cycles, stage_2_ticks = STAGE2_CYCLES_AFTER_TICK[i]
                # the earliest the second duty cycle can complete is a
                # STA $c030 at the beginning of stage 3
                if stage_2_ticks:
                    min_cycles = stage_2_cycles + 4
                else:
                    min_cycles = stage_1_cycles + stage_2_cycles + 4

                if j < min_cycles:
                    continue

            duty = j / (i + j) * 2 - 1
            res.setdefault(duty, []).append((i + j, i, j))

    cycles = []
    for c in sorted(list(res.keys())):
        pair = sorted(res[c], reverse=False)[0][1:]
        cycles.append(pair)
        # print(c, pair)

    return sorted(cycles)


EOF_DUTY_CYCLES = _duty_cycles(duty_cycle_range())


def eof_trampoline_stage3_page_offsets(duty_cycles):
    second_cycles = {}
    for a, b in sorted(duty_cycles):
        second_cycles.setdefault(a, []).append(b)

    # bin-pack the (a, b) duty cycles into pages so we can set up indirect
    # jump tables to dispatch the third stage trampoline.  A greedy algorithm
    # works fine here
    pages = []
    page = []
    longest_first_cycles = sorted(
        list(second_cycles.items()), key=lambda c: len(c[1]), reverse=True)
    left = len(longest_first_cycles)
    while left:
        for i, cycles in enumerate(longest_first_cycles):
            if cycles is None:
                continue
            cycle1, cycles2 = cycles
            if len(page) < (128 - len(cycles2)):
                page.extend((cycle1, cycle2) for cycle2 in cycles2)
                longest_first_cycles[i] = None
                left -= 1
        pages.append(page)
        page = []

    page_offsets = {}
    for page_idx, page in enumerate(pages):
        offset = 0
        for a, b in page:
            offset += 2
            page_offsets[(a, b)] = (page_idx, offset)

    return page_offsets


EOF_TRAMPOLINE_STAGE3_PAGE_OFFSETS = eof_trampoline_stage3_page_offsets(
    EOF_DUTY_CYCLES)
print(EOF_TRAMPOLINE_STAGE3_PAGE_OFFSETS)

EOF_STAGE_3_BASE = [
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
    opcodes_6502.Opcode(4, 3, "LDY WADRH"),
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


import player_op


def generate_player(
        opcode_filename: str,
        player_stage1_filename: str,
        player_stage2_filename: str
):
    toggles = {}

    # Write out page 3 operations
    with open(player_stage1_filename, "w+") as f:
        # Audio operations
        page_3_offset = 0
        seen_op_suffix_toggles = set()

        audio_player_ops: Dict[str, player_op.PlayerOp] = {}

        for i, ops in enumerate(audio_opcodes()):
            player_ops = []
            # Generate unique entrypoints
            for j, op in enumerate(ops):
                op_suffix_toggles = opcodes_6502.toggles(ops[j:])
                if op_suffix_toggles not in seen_op_suffix_toggles:
                    # new subsequence
                    seen_op_suffix_toggles.add(op_suffix_toggles)
                    player_ops.append(
                        opcodes_6502.Literal(
                            "tick_%02x: ; voltages %s" % (
                                page_3_offset, op_suffix_toggles), indent=0))
                    op_name = "TICK_%02x" % page_3_offset
                    audio_player_ops[op_name] = player_op.PlayerOp(
                        byte=page_3_offset,
                        toggles=numpy.array(op_suffix_toggles))
                player_ops.append(op)
                page_3_offset += op.bytes

            for op in player_ops:
                f.write("%s\n" % str(op))
            f.write("\n")

        # stage 1 EOF trampoline operations
        duty_cycle_first = sorted(list(set(dc[0] for dc in EOF_DUTY_CYCLES)))
        stage_1_ops: Dict[str, player_op.PlayerOp] = {}
        # stage_1_offsets = {}
        for eof_stage1_cycles in duty_cycle_first:
            eof_stage1_ops = EOF_TRAMPOLINE_STAGE1[eof_stage1_cycles]
            if not eof_stage1_ops:
                continue

            for op in eof_stage1_ops:
                f.write("%s\n" % str(op))
            f.write("\n")

            # stage_1_offsets[eof_stage1_cycles] = page_3_offset
            op_name = "END_OF_FRAME_%d_STAGE1" % eof_stage1_cycles
            stage_1_ops[op_name] = player_op.PlayerOp(
                byte=page_3_offset,
                toggles=numpy.array(opcodes_6502.toggles(eof_stage1_ops)))
            page_3_offset += opcodes_6502.total_bytes(eof_stage1_ops)

        # XXX reserve space for reset vector and EXIT
        assert page_3_offset < 256
        f.write("; %d bytes\n" % page_3_offset)

    # Write out stage 2 EOF trampoline operations
    with open(player_stage2_filename, "w+") as f:

        stage_2_3_ops: Dict[str, player_op.PlayerOp] = {}
        for eof_stage1_cycles in duty_cycle_first:
            eof_stage2_ops = EOF_TRAMPOLINE_STAGE2[eof_stage1_cycles]
            if not eof_stage2_ops:
                continue

            for op in eof_stage2_ops:
                f.write("%s\n" % str(op))
            f.write("\n")

        for a, b in EOF_DUTY_CYCLES:
            # XXX compute deficit for first iteration
            stage_3_tick_ops = itertools.cycle(
                [opcodes_6502.STA_C030, opcodes_6502.padding(a - 4),
                 opcodes_6502.STA_C030, opcodes_6502.padding(b - 4)]
            )
            stage_3_ops = [opcodes_6502.Literal("eof_stage_3_%d_%d:" % (a, b),
                                                indent=0)] + list(
                opcodes_6502.interleave_opcodes(stage_3_tick_ops,
                                                EOF_STAGE_3_BASE))
            for op in stage_3_ops:
                f.write("%s\n" % str(op))
            f.write("\n")

            combined_ops = EOF_TRAMPOLINE_STAGE2[a] + stage_3_ops

            name = "END_OF_FRAME_%d_%d_STAGE2_3" % (a, b)
            _, offset = EOF_TRAMPOLINE_STAGE3_PAGE_OFFSETS[a, b]
            stage_2_3_ops[name] = player_op.PlayerOp(
                byte=offset,
                toggles=numpy.array(opcodes_6502.toggles(combined_ops)))

        # We bin pack each (a, b) duty cycle onto the same jump table page
        # XXX move
        pages_by_first_duty_cycle = {}
        for ab, po in EOF_TRAMPOLINE_STAGE3_PAGE_OFFSETS.items():
            pages_by_first_duty_cycle[ab[0]] = po[0]

        # XXX assemble page offset tables
        # eof_trampoline_4_stage3_page:
        # eof_trampoline_6_stage3_page:
        # eof_trampoline_7_stage3_page:
        # ; ...

    with open(opcode_filename, "w") as f:
        f.write("""import numpy
import player_op


class PlayerOps:
""")

        for name, op in audio_player_ops.items():
            f.write("    %s = player_op.%s\n" % (name, op.define_self()))
        # XXX EXIT operation
        # f.write("    EXIT = player_op.PlayerOp(0x%02x)\n" % num_bytes)
        f.write("\n")

        for name, op in stage_1_ops.items():
            f.write("    %s = player_op.%s\n" % (name, op.define_self()))
        f.write("\n")

        for name, op in stage_2_3_ops.items():
            f.write("    %s = player_op.%s\n" % (name, op.define_self()))
        f.write("\n")

        f.write("\nEOF_STAGE_1_OPS = (\n")
        for n in stage_1_ops:
            f.write("    PlayerOps.%s,\n" % n)
        f.write(")\n")

        f.write("\n\nEOF_STAGE_2_3_OPS = (\n")
        for n in stage_2_3_ops:
            f.write("    PlayerOps.%s,\n" % n)
        f.write(")\n")

        # TODO: count toggles

def main():
    generate_player(
        opcode_filename="opcodes_generated.py",
        player_stage1_filename="player/player_generated.s",
        player_stage2_filename="player/player_stage2_generated.s"
    )


if __name__ == "__main__":
    main()
