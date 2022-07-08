import itertools
import numpy
from typing import Iterable, List, Tuple, Dict

import opcodes_6502
import player_op


def audio_opcodes() -> Iterable[Tuple[opcodes_6502.Opcode]]:
    # These two basic sequences let us chain together STA $C030 with any number
    # >= 10 of intervening cycles  We don't need to explicitly
    # include 6 or more cycles of NOP because those can be obtained by chaining
    # together JMP (WDATA) to itself
    yield tuple(
        [nop for nop in opcodes_6502.nops(4)] + [
            opcodes_6502.STA_C030, opcodes_6502.JMP_WDATA])

    yield tuple(
        [nop for nop in opcodes_6502.nops(4)] + [
            opcodes_6502.Opcode(5, 3, "STA $BFFF,Y", toggle=True),
            opcodes_6502.JMP_WDATA])


def duty_cycle_range():
    cycles = []
    for i in range(4, 42):
        if i == 5:
            # No single-cycle instructions
            # TODO: use STA $BFFF,X(=31) as a 5-cycle instruction.  This would
            #   be tricky since it requires maintaining X=31 across arbitrary
            #   code interleaving
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
        opcodes_6502.Opcode(
            6, 3, "JMP (eof_trampoline_%d_stage3_page)" % cycles)
    ]
    if cycles < 7 or cycles == 8:
        return label + ops[:-1] + [opcodes_6502.Literal("@0:", indent=0)] + [
            ops[-1]]

    # For cycles == 7 or > 8 we need to interleave a STA $C030 into stage 2
    # because we couldn't fit it in stage 1
    interleave_ops = [
        opcodes_6502.padding(cycles - 7),
        opcodes_6502.STA_C030,
        opcodes_6502.padding(100)
    ]
    res = label + list(opcodes_6502.interleave_opcodes(interleave_ops, ops))
    # We can't insert the label before interleaving because we might have
    # NOP/STA inserted after it
    # TODO: this is a bit of a hack - add support for binding the literal to
    # the following opcode so it can't be split
    return res[:-1] + [opcodes_6502.Literal("@0:", indent=0)] + [res[-1]]


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
    # XXX
    res = {}

    for i in duty_cycles:
        for j in duty_cycles:
            # We only need to worry about i <= j because we can effectively
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
            #     ; It can't be 22 cycles though because there are no 1-cycle
            #     ; operations
            if i in {4, 6, 8}:
                if j < 21 or j == 22:
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

                if j < min_cycles or j == min_cycles + 1:
                    continue

            duty = j / (i + j) * 2 - 1
            res.setdefault(duty, []).append((i + j, i, j))

    cycles = []
    for c in sorted(list(res.keys())):
        pair = sorted(res[c], reverse=False)[0][1:]
        cycles.append(pair)
        print(c, pair)

    return sorted(cycles)


# Excludes special (10,10) cycle that we hand-craft
EOF_DUTY_CYCLES = _duty_cycles(duty_cycle_range())


def eof_trampoline_stage3_page_offsets(duty_cycles):
    second_cycles = {}
    for a, b in sorted(duty_cycles):
        second_cycles.setdefault(a, []).append(b)

    # bin-pack the (a, b) duty cycles into pages so that we can set up indirect
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
            if len(page) <= (128 - len(cycles2)):
                page.extend((cycle1, cycle2) for cycle2 in cycles2)
                longest_first_cycles[i] = None
                left -= 1
        pages.append(page)
        page = []

    page_offsets = {}
    for page_idx, page in enumerate(pages):
        offset = 0
        for a, b in page:
            page_offsets[(a, b)] = (page_idx, offset)
            offset += 2

    return page_offsets


EOF_TRAMPOLINE_STAGE3_PAGE_OFFSETS = eof_trampoline_stage3_page_offsets(
    EOF_DUTY_CYCLES)

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
    opcodes_6502.Opcode(
        4, 3, "LDA RXRD ; TODO: in principle we could update RXRD outside of "
              "the EOF path"),
    opcodes_6502.Opcode(2, 1, "CLC"),
    opcodes_6502.Opcode(2, 2, "ADC #$08"),
    opcodes_6502.Opcode(
        4, 3, "STA WDATA ; Store new high byte of received read pointer"),
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
    opcodes_6502.Opcode(
        2, 2,
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
    opcodes_6502.Opcode(2, 2, "LDY #$31"),
    opcodes_6502.Opcode(6, 3, "JMP (WDATA)"),
]


def validate_stage_3_ops(op_seq, a, b):
    toggles = opcodes_6502.join_toggles(op_seq)
    toggle_cadence = itertools.chain([4], itertools.cycle([a, b]))
    last = 1.0
    expected_count = next(toggle_cadence)
    # print(op_seq, a, b)
    for t in toggles:
        expected_count -= 1
        # print(expected_count, t)
        if t != last:
            assert expected_count == 0
            expected_count = next(toggle_cadence)
        last = t


EOF_STAGE1_10_10_OPS = [
    opcodes_6502.Literal("eof_trampoline_10_10:", indent=0),
    opcodes_6502.STA_C030,
    opcodes_6502.Opcode(3, 3, "JMP eof_stage_2_10_10")
]

EOF_STAGE2_10_10_BASE = (
        [
            opcodes_6502.Literal("eof_stage_2_10_10:",
                                 indent=0),
            opcodes_6502.Opcode(4, 3,
                                "LDA WDATA ; dummy read to maintain framing"),
        ] + EOF_STAGE_3_BASE
)


def generate_player(
        opcode_filename: str,
        player_stage1_filename: str,
        player_stage2_filename: str,
        player_stage3_table_filename: str
):
    # Generate assembly code for page 3 operations
    with open(player_stage1_filename, "w+") as f:
        # Audio operations
        audio_player_ops: Dict[str, player_op.PlayerOp] = {}
        page_3_offset = 0
        seen_op_suffix_toggles = set()
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
                        name=op_name,
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
        for eof_stage1_cycles in duty_cycle_first:
            eof_stage1_ops = EOF_TRAMPOLINE_STAGE1[eof_stage1_cycles]
            if not eof_stage1_ops:
                continue

            for op in eof_stage1_ops:
                f.write("%s\n" % str(op))
            f.write("\n")

            op_name = "END_OF_FRAME_%d_STAGE1" % eof_stage1_cycles
            stage_1_ops[op_name] = player_op.PlayerOp(
                name=op_name,
                byte=page_3_offset,
                toggles=numpy.array(opcodes_6502.toggles(eof_stage1_ops)))
            page_3_offset += opcodes_6502.total_bytes(eof_stage1_ops)

        # Write special-case (10,10) duty cycle EOF stage 1 operation
        for op in EOF_STAGE1_10_10_OPS:
            f.write("%s\n" % str(op))
        f.write("\n")

        op_name = "END_OF_FRAME_10_10_STAGE1"
        stage_1_ops[op_name] = player_op.PlayerOp(
            name=op_name,
            byte=page_3_offset,
            toggles=numpy.array(opcodes_6502.toggles(EOF_STAGE1_10_10_OPS))
        )
        page_3_offset += opcodes_6502.total_bytes(EOF_STAGE1_10_10_OPS)

        # XXX reserve space for reset vector and EXIT
        assert page_3_offset < 256
        f.write("; %d bytes\n" % page_3_offset)

    # Generate assembly code for stage 2 and 3 EOF operations
    with open(player_stage2_filename, "w+") as f:

        # Stage 2 EOF operations
        stage_2_3_ops: Dict[str, player_op.PlayerOp] = {}

        stage_2_ops_by_stage_1_op: Dict[str, List[str]] = {}
        for eof_stage1_cycles in duty_cycle_first:
            eof_stage2_ops = EOF_TRAMPOLINE_STAGE2[eof_stage1_cycles]
            if not eof_stage2_ops:
                continue

            for op in eof_stage2_ops:
                f.write("%s\n" % str(op))
            f.write("\n")

        eof_10_10_stage2_ops = list(opcodes_6502.interleave_opcodes(
            itertools.chain(
                [opcodes_6502.padding(3), opcodes_6502.STA_C030],
                itertools.cycle([opcodes_6502.padding(6),
                                 opcodes_6502.STA_C030])), EOF_STAGE2_10_10_BASE
        ))
        for op in eof_10_10_stage2_ops:
            f.write("%s\n" % str(op))
        f.write("\n")
        op_name = "END_OF_FRAME_10_10_STAGE2"
        stage_2_3_ops[op_name] = player_op.PlayerOp(
            name=op_name,
            byte=0xff,  # Dummy
            toggles=numpy.array(opcodes_6502.toggles(eof_10_10_stage2_ops))
        )
        stage_2_ops_by_stage_1_op.setdefault(
            "END_OF_FRAME_10_10_STAGE1", []).append(op_name)

        # Stage 3 EOF operations
        for a, b in EOF_DUTY_CYCLES:
            # Make sure we finish the first iteration of duty cycle
            c1, t1 = STAGE1_CYCLES_AFTER_TICK[a]
            c2, t2 = STAGE2_CYCLES_AFTER_TICK[a]

            if t1 == 2 and t2 == 0:
                # First duty cycle completed in stage 1
                # Counting down second duty cycle
                assert b >= (c2 + c1 + 4)
                header = [opcodes_6502.padding(b - c2 - c1 - 4)]
                # print("Padding A %d, %d --> %s" % (a, b, header))

            elif t1 == 1 and t2 == 1:
                # First duty cycle completed in stage 2
                # Counting down second duty cycle
                assert b >= (c2 + 4)
                header = [opcodes_6502.padding(b - c2 - 4)]
                # print(t1, c1, t2, c2)
                # print("Padding B %d, %d --> %s" % (a, b, header))
            elif t1 == 1 and t2 == 0:
                # First duty cycle has not yet completed
                # Counting down first duty cycle
                assert a >= (c2 + c1 + 4)
                header = [
                    opcodes_6502.padding(a - c1 - c2 - 4),
                    opcodes_6502.STA_C030,
                    opcodes_6502.padding(b - 4),
                ]
                # print(t1, c1, t2, c2)
                # print("Padding C %d, %d --> %s" % (a, b, header))
            else:
                assert False

            stage_3_tick_ops = itertools.chain(header, itertools.cycle(
                [opcodes_6502.STA_C030, opcodes_6502.padding(a - 4),
                 opcodes_6502.STA_C030, opcodes_6502.padding(b - 4)]
            ))
            stage_3_ops = [opcodes_6502.Literal("eof_stage_3_%d_%d:" % (a, b),
                                                indent=0)] + list(
                opcodes_6502.interleave_opcodes(stage_3_tick_ops,
                                                EOF_STAGE_3_BASE))
            validate_stage_3_ops(
                [EOF_TRAMPOLINE_STAGE1[a], EOF_TRAMPOLINE_STAGE2[a],
                 stage_3_ops], a, b)
            for op in stage_3_ops:
                f.write("%s\n" % str(op))
            f.write("\n")

            name = "END_OF_FRAME_%d_%d_STAGE2_3" % (a, b)
            _, offset = EOF_TRAMPOLINE_STAGE3_PAGE_OFFSETS[a, b]

            stage_2_3_ops[name] = player_op.PlayerOp(
                name=name,
                byte=offset,
                toggles=numpy.array(opcodes_6502.join_toggles(
                    [EOF_TRAMPOLINE_STAGE2[a], stage_3_ops]))
            )
            stage_2_ops_by_stage_1_op.setdefault(
                "END_OF_FRAME_%d_STAGE1" % a, []).append(name)

    with open(player_stage3_table_filename, "w+") as f:
        # We bin pack each (a, b) duty cycle onto the same jump table page
        first_duty_cycles_by_page = {}
        for ab, po in EOF_TRAMPOLINE_STAGE3_PAGE_OFFSETS.items():
            first_duty_cycles_by_page.setdefault(po[0], []).append(
                (po[1], ab))

        for page, data in first_duty_cycles_by_page.items():
            offsets = [None] * 128
            first_cycles = set()
            for offset, cycles in data:
                offsets[offset // 2] = cycles
                first_cycles.add(cycles[0])
            for first_cycle in sorted(list(first_cycles)):
                f.write("eof_trampoline_%d_stage3_page:\n" % first_cycle)

            for offset, cycles in enumerate(offsets):
                if cycles is None:
                    f.write("    .word $FFFF\n")
                else:
                    f.write("    .addr eof_stage_3_%d_%d\n" % cycles)
            f.write("\n")

    # Generated python code for player operations
    with open(opcode_filename, "w") as f:
        f.write("import numpy\nimport player_op\n\n\nclass PlayerOps:\n")

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

        f.write("\nAUDIO_OPS = (\n")
        for n in audio_player_ops:
            f.write("    PlayerOps.%s,\n" % n)
        f.write(")\n")

        f.write("\nEOF_STAGE_1_OPS = (\n")
        for n in stage_1_ops:
            f.write("    PlayerOps.%s,\n" % n)
        f.write(")\n")

        f.write("\nEOF_STAGE_2_3_OPS = {\n")
        for stage1_name, stage_2_3_names in stage_2_ops_by_stage_1_op.items():
            f.write("    PlayerOps.%s: [%s],\n" % (
                stage1_name, ", ".join("PlayerOps.%s" % n for n in sorted(
                    stage_2_3_names))))
        f.write("}\n")

        f.write("\n")

        # TODO: count toggles


def main():
    generate_player(
        opcode_filename="opcodes_generated.py",
        player_stage1_filename="player/player_generated.s",
        player_stage2_filename="player/player_stage2_3_generated.s",
        player_stage3_table_filename="player/player_stage3_table_generated.s"
    )

if __name__ == "__main__":
    main()
