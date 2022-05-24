import enum
import functools
import opcodes_generated
import numpy
from typing import Dict, List, Tuple, Iterable

#
# def _make_end_of_frame_voltages(bits) -> numpy.ndarray:
#     """Voltage sequence for end-of-frame TCP processing."""
#     length = 8 * 20  # 4 + 14 * 10 + 6
#     c = numpy.full(length, 1.0, dtype=numpy.float32)
#     voltage_high = True
#     toggles = 0
#     for i in range(8):
#         if bool((bits >> i) & 1):
#             voltage_high = not voltage_high
#             toggles += 1
#         for j in range(3 + 20 * i, min(length, 3 + 20 * (i + 1))):
#             c[j] = 1.0 if voltage_high else -1.0
#     return c, toggles


Opcode = opcodes_generated.Opcode
TOGGLES = opcodes_generated.TOGGLES
_VOLTAGE_SCHEDULE = opcodes_generated.VOLTAGE_SCHEDULE
# _VOLTAGE_SCHEDULE[Opcode.END_OF_FRAME], TOGGLES[Opcode.END_OF_FRAME] = (
#     _make_end_of_frame_voltages())

# _VOLTAGE_EOF = {}
# # _TOGGLES_EOF = {}
# for i in range(256):
#     _VOLTAGE_EOF[i], _ = _make_end_of_frame_voltages(i)


def cycle_length(op: Opcode, is_6502: bool) -> int:
    """Returns the 65[C]02 cycle length of a player opcode."""
    l = len(_VOLTAGE_SCHEDULE[op])
    # JMP (indirect) is 5 cycles for 6502 instead of 6
    return l - 1 if is_6502 else l


def voltage_schedule(op: Opcode, is_6502: bool) -> numpy.ndarray:
    """Returns the 65[C]02 applied voltage schedule of a player opcode."""
    v = _VOLTAGE_SCHEDULE[op]
    # JMP (indirect) is 5 cycles for 6502 instead of 6
    return v[:-1] if is_6502 else v


@functools.lru_cache(None)
def opcode_choices(frame_offset: int, is_6502: bool) -> List[Opcode]:
    """Returns sorted list of valid opcodes for given frame offset.

    Sorted by decreasing cycle length, so that if two opcodes produce equally
    good results, we'll pick the one with the longest cycle count to reduce the
    stream bitrate.
    """
    if frame_offset == 2047:
        return opcodes_generated.EOF_OPCODES

    def _cycle_length(op: Opcode) -> int:
        return cycle_length(op, is_6502)

    opcodes = set(_VOLTAGE_SCHEDULE.keys()) - set(opcodes_generated.EOF_OPCODES)
    # print(frame_offset, opcodes)
    return sorted(list(opcodes), key=_cycle_length, reverse=True)


@functools.lru_cache(None)
def opcode_lookahead(
        frame_offset: int,
        lookahead_cycles: int, is_6502: bool) -> Tuple[Tuple[Opcode]]:
    """Recursively enumerates all valid opcode sequences."""

    ch = opcode_choices(frame_offset, is_6502)
    ops = []
    for op in ch:
        if cycle_length(op, is_6502) >= lookahead_cycles:
            ops.append((op,))
        else:
            for res in opcode_lookahead(
                    (frame_offset + 1) % 2048,
                    lookahead_cycles - cycle_length(op, is_6502), is_6502):
                ops.append((op,) + res)
    return tuple(ops)  # TODO: fix return type


@functools.lru_cache(None)
def cycle_lookahead(
        opcodes: Tuple[Opcode],
        lookahead_cycles: int, is_6502: bool) -> Tuple[float]:
    """Computes the applied voltage effects of a sequence of opcodes.

    i.e. produces the sequence of applied voltage changes that will result
    from executing these opcodes, limited to the next lookahead_cycles.
    """
    cycles = []
    last_voltage = 1.0
    for op in opcodes:
        cycles.extend(last_voltage * voltage_schedule(op, is_6502))
        last_voltage = cycles[-1]
    return tuple(cycles[:lookahead_cycles])


@functools.lru_cache(None)
def candidate_opcodes(
        frame_offset: int, lookahead_cycles: int, is_6502: bool
) -> Tuple[int, Tuple[Tuple[Opcode]], numpy.ndarray]:
    """Deduplicate a tuple of opcode sequences that are equivalent.

    For each opcode sequence whose effect is the same when truncated to
    lookahead_cycles, retains the first such opcode sequence.
    """
    opcodes = opcode_lookahead(frame_offset, lookahead_cycles, is_6502)
    # Look ahead over the common cycle subsequence to make sure we see as far
    # as possible into the future
    cycles = []
    for ops in opcodes:
        op_len = sum(cycle_length(op, is_6502) for op in ops)
        cycles.append(op_len)
    # print(cycles)
    lookahead_cycles = min(cycles)
    seen_cycles = set()
    pruned_opcodes = []
    pruned_cycles = []
    for ops in opcodes:
        cycles = cycle_lookahead(ops, lookahead_cycles, is_6502)
        if cycles in seen_cycles:
            continue
        seen_cycles.add(cycles)
        pruned_opcodes.append(ops)
        pruned_cycles.append(cycles)

    pruned_opcodes = tuple(pruned_opcodes)
    # Precompute and return the hash since it's relatively expensive to
    # recompute.
    return hash(pruned_opcodes), pruned_opcodes, numpy.array(
        pruned_cycles, dtype=numpy.float32), lookahead_cycles
