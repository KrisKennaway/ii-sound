import enum
import functools
import numpy
from typing import Dict, List, Tuple, Iterable


class Opcode(enum.Enum):
    TICK_12 = 0x00
    TICK_17 = 0x08
    TICK_15 = 0x09
    TICK_13 = 0x0a
    TICK_11 = 0x0b
    TICK_9 = 0x0c

    NOTICK_8 = 0x12
    NOTICK_11 = 0x17
    NOTICK_9 = 0x18
    NOTICK_7 = 0x19
    NOTICK_5 = 0x1a
    EXIT = 0x1d
    SLOWPATH = 0x2d


def make_tick_cycles(length) -> numpy.ndarray:
    c = numpy.full(length, 1.0, dtype=numpy.float32)
    for i in range(length - 6, length):
        c[i] = -1.0
    return c


def make_notick_cycles(length) -> numpy.ndarray:
    return numpy.full(length, 1.0, dtype=numpy.float32)


def make_slowpath_cycles() -> numpy.ndarray:
    length = 12 * 13
    c = numpy.full(length, 1.0, dtype=numpy.float32)
    voltage_high = True
    for i in range(12):
        voltage_high = not voltage_high
        for j in range(3 + 13 * i, min(length, 3 + 13 * (i + 1))):
            c[j] = 1.0 if voltage_high else -1.0
    return c


# XXX rename to voltages
CYCLE_SCHEDULE = {
    Opcode.TICK_12: make_tick_cycles(12),
    Opcode.TICK_17: make_tick_cycles(17),
    Opcode.TICK_15: make_tick_cycles(15),
    Opcode.TICK_13: make_tick_cycles(13),
    Opcode.TICK_11: make_tick_cycles(11),
    Opcode.TICK_9: make_tick_cycles(9),
    Opcode.NOTICK_8: make_notick_cycles(8),
    Opcode.NOTICK_11: make_notick_cycles(11),
    Opcode.NOTICK_9: make_notick_cycles(9),
    Opcode.NOTICK_7: make_notick_cycles(7),
    Opcode.NOTICK_5: make_notick_cycles(5),
    Opcode.SLOWPATH: make_slowpath_cycles()
}  # type: Dict[Opcode, numpy.ndarray]


def cycle_length(op: Opcode) -> int:
    return len(CYCLE_SCHEDULE[op])


class _Opcodes:
    def __init__(self, opcodes: Iterable[Opcode]):
        self.opcodes = tuple(opcodes)
        self._hash = hash(self.opcodes)

    def __hash__(self):
        return self._hash

# Guarantees each Tuple[Opcode] has a unique _Opcodes representation
_OPCODES_CACHE = {}


@functools.lru_cache(None)
def Opcodes(opcodes: Tuple[Opcode]):
    return _OPCODES_CACHE.setdefault(opcodes, _Opcodes(opcodes))


@functools.lru_cache(None)
def opcode_choices(frame_offset: int) -> List[Opcode]:
    if frame_offset == 2047:
        return [Opcode.SLOWPATH]

    opcodes = set(CYCLE_SCHEDULE.keys()) - {Opcode.SLOWPATH}
    # Prefer longer opcodes to have a more compact bytestream
    # XXX if we aren't looking ahead beyond 1 opcode we should
    # pick the shortest?
    return sorted(list(opcodes), key=cycle_length, reverse=True)


@functools.lru_cache(None)
def _opcode_lookahead(
        frame_offset: int,
        lookahead_cycles: int) -> Tuple[Tuple[Opcode]]:
    ch = opcode_choices(frame_offset)
    ops = []
    for op in ch:
        if cycle_length(op) >= lookahead_cycles:
            ops.append((op,))
        else:
            for res in _opcode_lookahead((frame_offset + 1) % 2048,
                                        lookahead_cycles - cycle_length(op)):
                ops.append((op,) + res)
    return tuple(ops)  # XXX type


@functools.lru_cache(None)
def opcode_lookahead(
        frame_offset: int,
        lookahead_cycles: int) -> Tuple[_Opcodes]:
    return tuple(Opcodes(ops) for ops in
                 _opcode_lookahead(frame_offset, lookahead_cycles))


_CYCLES_CACHE = {}


class Cycles:
    def __init__(self, cycles: Tuple[float]):
        self.cycles = cycles
        self._hash = hash(cycles)

    def __hash__(self):
        return self._hash


@functools.lru_cache(None)
def cycle_lookahead(
        opcodes: _Opcodes,
        lookahead_cycles: int
) -> Cycles:
    cycles = []
    for op in opcodes.opcodes:
        cycles.extend(CYCLE_SCHEDULE[op])
    trunc_cycles = tuple(cycles[:lookahead_cycles])
    return _CYCLES_CACHE.setdefault(trunc_cycles, Cycles(trunc_cycles))


@functools.lru_cache(None)
def prune_opcodes(
        opcodes: Tuple[_Opcodes], lookahead_cycles: int
) -> Tuple[List[_Opcodes], numpy.ndarray]:
    seen_cycles = set()
    pruned_opcodes = []
    pruned_cycles = []
    for ops in opcodes:
        cycles = cycle_lookahead(ops, lookahead_cycles)
        if cycles in seen_cycles:
            continue
        seen_cycles.add(cycles)
        pruned_opcodes.append(ops)
        pruned_cycles.append(cycles.cycles)

    return pruned_opcodes, numpy.array(pruned_cycles, dtype=numpy.float32)


if __name__ == "__main__":
    lah = 50
    ops = opcode_lookahead(0, lah)
    pruned = prune_opcodes(ops, lah)
    print(len(ops), len(pruned[0]))
