import enum
import functools
import numpy
from typing import Dict, List, Tuple, Iterable


# TODO: support 6502 cycle counts as well

class Opcode(enum.Enum):
    """Audio player opcodes representing atomic units of audio playback work."""
    TICK_17 = 0x00
    TICK_15 = 0x01
    TICK_13 = 0x02
    TICK_14 = 0x0a
    TICK_12 = 0x0b
    TICK_10 = 0x0c
    NOTICK_6 = 0x0f

    EXIT = 0x12
    SLOWPATH = 0x22


def make_tick_voltages(length) -> numpy.ndarray:
    """Voltage sequence for a NOP; ...; STA $C030; JMP (WDATA)."""
    c = numpy.full(length, 1.0, dtype=numpy.float32)
    for i in range(length - 7, length):  # TODO: 6502
        c[i] = -1.0
    return c


def make_notick_voltages(length) -> numpy.ndarray:
    """Voltage sequence for a NOP; ...; JMP (WDATA)."""
    return numpy.full(length, 1.0, dtype=numpy.float32)


def make_slowpath_voltages() -> numpy.ndarray:
    """Voltage sequence for slowpath TCP processing."""
    length = 8 * 14 + 10  # TODO: 6502
    c = numpy.full(length, 1.0, dtype=numpy.float32)
    voltage_high = True
    for i in range(8):
        voltage_high = not voltage_high
        for j in range(3 + 14 * i, min(length, 3 + 14 * (i + 1))):
            c[j] = 1.0 if voltage_high else -1.0
    return c


# Sequence of applied voltage inversions that result from executing each player
# opcode, at each processor cycle.  We assume the starting applied voltage is
# 1.0.
VOLTAGE_SCHEDULE = {
    Opcode.TICK_17: make_tick_voltages(17),
    Opcode.TICK_15: make_tick_voltages(15),
    Opcode.TICK_13: make_tick_voltages(13),
    Opcode.TICK_14: make_tick_voltages(14),
    Opcode.TICK_12: make_tick_voltages(12),
    Opcode.TICK_10: make_tick_voltages(10),
    Opcode.NOTICK_6: make_notick_voltages(6),
    Opcode.SLOWPATH: make_slowpath_voltages(),

}  # type: Dict[Opcode, numpy.ndarray]


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

    return pruned_opcodes, numpy.array(pruned_cycles, dtype=numpy.float32)
