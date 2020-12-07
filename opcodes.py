import enum
import functools
import opcodes_generated
import numpy
from typing import Dict, List, Tuple, Iterable


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


Opcode = opcodes_generated.Opcode
VOLTAGE_SCHEDULE = opcodes_generated.VOLTAGE_SCHEDULE
VOLTAGE_SCHEDULE[Opcode.SLOWPATH] = make_slowpath_voltages()


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
    last_voltage = 1.0
    for op in opcodes:
        cycles.extend(last_voltage * VOLTAGE_SCHEDULE[op])
        last_voltage = cycles[-1]
    return tuple(cycles[:lookahead_cycles])


@functools.lru_cache(None)
def candidate_opcodes(
        frame_offset: int, lookahead_cycles: int
) -> Tuple[int, Tuple[Tuple[Opcode]], numpy.ndarray]:
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

    pruned_opcodes = tuple(pruned_opcodes)
    # Precompute and return the hash since it's relatively expensive to
    # recompute.
    return hash(pruned_opcodes), pruned_opcodes, numpy.array(pruned_cycles,
                                              dtype=numpy.float32)
