import functools
from typing import List, Tuple

import numpy

import opcodes_generated
import player_op


# How many bytes to use per frame in the audio stream.  At the end of each
# frame we need to switch to special end-of-frame operations to cause the
# Apple II to manage the TCP socket buffers (ACK data received so far, and
# check we have at least another frame of data available)
#
# With an 8KB socket buffer this seems to be about the maximum we can get away
# with - it has to be page aligned, and 4KB causes stuttering even from a
# local playback source.
#
# TODO: share this with encode_audio.py
FRAME_SIZE = 2048


def cycle_length(op: player_op.PlayerOp) -> int:
    """Returns the cycle length of a player opcode."""
    return len(op.toggles)


def opcode_choices(
        frame_offset: int,
        eof_stage_1_op: player_op.PlayerOp = None) -> List[player_op.PlayerOp]:
    """Returns sorted list of valid opcodes for given frame offset.

    Sorted by decreasing cycle length, so that if two opcodes produce equally
    good results, we'll pick the one with the longest cycle count to reduce the
    stream bitrate.
    """
    if frame_offset == FRAME_SIZE - 2:
        return opcodes_generated.EOF_STAGE_1_OPS
    if frame_offset == FRAME_SIZE - 1:
        return opcodes_generated.EOF_STAGE_2_3_OPS[eof_stage_1_op]

    return sorted(
        list(opcodes_generated.AUDIO_OPS), key=cycle_length, reverse=True)


def opcode_lookahead(
        frame_offset: int,
        lookahead_cycles: int,
        eof_stage_1_op: player_op.PlayerOp = None
) -> Tuple[Tuple[player_op.PlayerOp]]:
    """Recursively enumerates all valid opcode sequences."""

    ch = opcode_choices(frame_offset, eof_stage_1_op)
    ops = []
    for op in ch:
        if cycle_length(op) >= lookahead_cycles:
            ops.append((op,))
        else:
            # XXX check this
            if frame_offset == FRAME_SIZE - 2 and eof_stage_1_op is None:
                temp_op = op
            else:
                temp_op = eof_stage_1_op

            for res in opcode_lookahead(
                    (frame_offset + 1) % FRAME_SIZE,
                    lookahead_cycles - cycle_length(op), temp_op):
                ops.append((op,) + res)
    return tuple(ops)  # TODO: fix return type


def cycle_lookahead(
        opcodes: Tuple[player_op.PlayerOp],
        lookahead_cycles: int) -> Tuple[float]:
    """Computes the applied voltage effects of a sequence of opcodes.

    i.e. produces the sequence of applied voltage changes that will result
    from executing these opcodes, limited to the next lookahead_cycles.
    """
    cycles = []
    last_voltage = 1.0
    for op in opcodes:
        cycles.extend(last_voltage * op.toggles)
        last_voltage = cycles[-1]
    return tuple(cycles[:lookahead_cycles])


@functools.lru_cache(None)
def candidate_opcodes(
        frame_offset: int, lookahead_cycles: int,
        eof_stage_1_op: player_op.PlayerOp
) -> Tuple[Tuple[player_op.PlayerOp], numpy.ndarray, int]:
    """Deduplicate a tuple of opcode sequences that are equivalent.

    For each opcode sequence whose effect is the same when truncated to
    lookahead_cycles, retains the first such opcode sequence.
    """
    opcodes = opcode_lookahead(frame_offset, lookahead_cycles, eof_stage_1_op)
    # Look ahead over the common cycle subsequence to make sure we see as far
    # as possible into the future
    cycles = []
    for ops in opcodes:
        op_len = sum(cycle_length(op) for op in ops)
        cycles.append(op_len)
    lookahead_cycles = min(cycles)
    seen_cycles = {}
    pruned_opcodes = []
    pruned_cycles = []
    for ops in opcodes:
        cycles = cycle_lookahead(ops, lookahead_cycles)
        if cycles in seen_cycles:
            continue
        seen_cycles[cycles] = ops
        pruned_opcodes.append(ops[0])
        pruned_cycles.append(cycles)

    pruned_opcodes = tuple(pruned_opcodes)
    return (
        pruned_opcodes,
        numpy.array(pruned_cycles, dtype=numpy.float32),
        lookahead_cycles
    )
