tick_00: ; voltages (1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0)
    NOP ; 2 cycles
tick_01: ; voltages (1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0)
    NOP ; 2 cycles
tick_02: ; voltages (1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0)
    STA $C030 ; 4 cycles
tick_05: ; voltages (1.0, 1.0, 1.0, 1.0, 1.0, 1.0)
    JMP (WDATA) ; 6 cycles

tick_08: ; voltages (1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0)
    NOP ; 2 cycles
tick_09: ; voltages (1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0)
    NOP ; 2 cycles
tick_0a: ; voltages (1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0)
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_trampoline_4:
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    JMP eof_trampoline_4_stage2 ; 3 cycles

eof_trampoline_6:
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    JMP eof_trampoline_6_stage2 ; 3 cycles

eof_trampoline_7:
    STA $C030 ; 4 cycles
    JMP eof_trampoline_7_stage2 ; 3 cycles

eof_trampoline_8:
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    JMP eof_trampoline_8_stage2 ; 3 cycles

eof_trampoline_9:
    STA $C030 ; 4 cycles
    JMP eof_trampoline_9_stage2 ; 3 cycles

eof_trampoline_10:
    STA $C030 ; 4 cycles
    JMP eof_trampoline_10_stage2 ; 3 cycles

eof_trampoline_11:
    STA $C030 ; 4 cycles
    JMP eof_trampoline_11_stage2 ; 3 cycles

eof_trampoline_12:
    STA $C030 ; 4 cycles
    JMP eof_trampoline_12_stage2 ; 3 cycles

eof_trampoline_13:
    STA $C030 ; 4 cycles
    JMP eof_trampoline_13_stage2 ; 3 cycles

eof_trampoline_14:
    STA $C030 ; 4 cycles
    JMP eof_trampoline_14_stage2 ; 3 cycles

eof_trampoline_15:
    STA $C030 ; 4 cycles
    JMP eof_trampoline_15_stage2 ; 3 cycles

eof_trampoline_16:
    STA $C030 ; 4 cycles
    JMP eof_trampoline_16_stage2 ; 3 cycles

eof_trampoline_17:
    STA $C030 ; 4 cycles
    JMP eof_trampoline_17_stage2 ; 3 cycles

eof_trampoline_18:
    STA $C030 ; 4 cycles
    JMP eof_trampoline_18_stage2 ; 3 cycles

eof_trampoline_19:
    STA $C030 ; 4 cycles
    JMP eof_trampoline_19_stage2 ; 3 cycles

eof_trampoline_20:
    STA $C030 ; 4 cycles
    JMP eof_trampoline_20_stage2 ; 3 cycles

eof_trampoline_21:
    STA $C030 ; 4 cycles
    JMP eof_trampoline_21_stage2 ; 3 cycles

eof_trampoline_22:
    STA $C030 ; 4 cycles
    JMP eof_trampoline_22_stage2 ; 3 cycles

; 7 entrypoints, 138 bytes
