tick_00: ; voltages (True, True, True, True, True, True, True, False, False, False, False, True, True, True, True, False, False, False, False, False, False, False)
    NOP ; 2 cycles
tick_01: ; voltages (True, True, True, True, True, False, False, False, False, True, True, True, True, False, False, False, False, False, False, False)
    NOP ; 2 cycles
tick_02: ; voltages (True, True, True, False, False, False, False, True, True, True, True, False, False, False, False, False, False, False)
    STA $C030 ; 4 cycles
tick_05: ; voltages (True, True, True, False, False, False, False, True, True, True, True, True, True, True)
    STA $C030 ; 4 cycles
tick_08: ; voltages (True, True, True, False, False, False, False, False, False, False)
    STA $C030 ; 4 cycles
tick_0b: ; voltages (True, True, True, True, True, True)
    JMP (WDATA) ; 6 cycles

tick_0e: ; voltages (True, True, True, True, True, True, True, False, False, False, False, True, True, True, True, True, True, False, False, False, False, False, False, False)
    NOP ; 2 cycles
tick_0f: ; voltages (True, True, True, True, True, False, False, False, False, True, True, True, True, True, True, False, False, False, False, False, False, False)
    NOP ; 2 cycles
tick_10: ; voltages (True, True, True, False, False, False, False, True, True, True, True, True, True, False, False, False, False, False, False, False)
    STA $C030 ; 4 cycles
tick_13: ; voltages (True, True, True, False, False, False, False, False, False, True, True, True, True, True, True, True)
    STA $C030 ; 4 cycles
tick_16: ; voltages (True, True, True, True, True, False, False, False, False, False, False, False)
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

tick_1d: ; voltages (True, True, True, True, True, True, True, False, False, False, False, True, True, True, True, True, True, True, True, False, False, False, False, False, False, False)
    NOP ; 2 cycles
tick_1e: ; voltages (True, True, True, True, True, False, False, False, False, True, True, True, True, True, True, True, True, False, False, False, False, False, False, False)
    NOP ; 2 cycles
tick_1f: ; voltages (True, True, True, False, False, False, False, True, True, True, True, True, True, True, True, False, False, False, False, False, False, False)
    STA $C030 ; 4 cycles
tick_22: ; voltages (True, True, True, False, False, False, False, False, False, False, False, True, True, True, True, True, True, True)
    STA $C030 ; 4 cycles
tick_25: ; voltages (True, True, True, True, True, True, True, False, False, False, False, False, False, False)
    NOP ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

tick_2d: ; voltages (True, True, True, True, True, True, True, False, False, False, False, False, False, True, True, True, True, False, False, False, False, False, False, False)
    NOP ; 2 cycles
tick_2e: ; voltages (True, True, True, True, True, False, False, False, False, False, False, True, True, True, True, False, False, False, False, False, False, False)
    NOP ; 2 cycles
tick_2f: ; voltages (True, True, True, False, False, False, False, False, False, True, True, True, True, False, False, False, False, False, False, False)
    STA $C030 ; 4 cycles
tick_32: ; voltages (True, True, True, True, True, False, False, False, False, True, True, True, True, True, True, True)
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

tick_3c: ; voltages (True, True, True, True, True, True, True, False, False, False, False, False, False, True, True, True, True, True, True, False, False, False, False, False, False, False)
    NOP ; 2 cycles
tick_3d: ; voltages (True, True, True, True, True, False, False, False, False, False, False, True, True, True, True, True, True, False, False, False, False, False, False, False)
    NOP ; 2 cycles
tick_3e: ; voltages (True, True, True, False, False, False, False, False, False, True, True, True, True, True, True, False, False, False, False, False, False, False)
    STA $C030 ; 4 cycles
tick_41: ; voltages (True, True, True, True, True, False, False, False, False, False, False, True, True, True, True, True, True, True)
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

tick_4c: ; voltages (True, True, True, True, True, True, True, False, False, False, False, False, False, True, True, True, True, True, True, True, True, False, False, False, False, False, False, False)
    NOP ; 2 cycles
tick_4d: ; voltages (True, True, True, True, True, False, False, False, False, False, False, True, True, True, True, True, True, True, True, False, False, False, False, False, False, False)
    NOP ; 2 cycles
tick_4e: ; voltages (True, True, True, False, False, False, False, False, False, True, True, True, True, True, True, True, True, False, False, False, False, False, False, False)
    STA $C030 ; 4 cycles
tick_51: ; voltages (True, True, True, True, True, False, False, False, False, False, False, False, False, True, True, True, True, True, True, True)
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

tick_5d: ; voltages (True, True, True, True, True, True, True, False, False, False, False, False, False, False, False, True, True, True, True, False, False, False, False, False, False, False)
    NOP ; 2 cycles
tick_5e: ; voltages (True, True, True, True, True, False, False, False, False, False, False, False, False, True, True, True, True, False, False, False, False, False, False, False)
    NOP ; 2 cycles
tick_5f: ; voltages (True, True, True, False, False, False, False, False, False, False, False, True, True, True, True, False, False, False, False, False, False, False)
    STA $C030 ; 4 cycles
tick_62: ; voltages (True, True, True, True, True, True, True, False, False, False, False, True, True, True, True, True, True, True)
    NOP ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

tick_6d: ; voltages (True, True, True, True, True, True, True, False, False, False, False, False, False, False, False, True, True, True, True, True, True, False, False, False, False, False, False, False)
    NOP ; 2 cycles
tick_6e: ; voltages (True, True, True, True, True, False, False, False, False, False, False, False, False, True, True, True, True, True, True, False, False, False, False, False, False, False)
    NOP ; 2 cycles
tick_6f: ; voltages (True, True, True, False, False, False, False, False, False, False, False, True, True, True, True, True, True, False, False, False, False, False, False, False)
    STA $C030 ; 4 cycles
tick_72: ; voltages (True, True, True, True, True, True, True, False, False, False, False, False, False, True, True, True, True, True, True, True)
    NOP ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

tick_7e: ; voltages (True, True, True, True, True, True, True, False, False, False, False, False, False, False, False, True, True, True, True, True, True, True, True, False, False, False, False, False, False, False)
    NOP ; 2 cycles
tick_7f: ; voltages (True, True, True, True, True, False, False, False, False, False, False, False, False, True, True, True, True, True, True, True, True, False, False, False, False, False, False, False)
    NOP ; 2 cycles
tick_80: ; voltages (True, True, True, False, False, False, False, False, False, False, False, True, True, True, True, True, True, True, True, False, False, False, False, False, False, False)
    STA $C030 ; 4 cycles
tick_83: ; voltages (True, True, True, True, True, True, True, False, False, False, False, False, False, False, False, True, True, True, True, True, True, True)
    NOP ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

tick_90: ; voltages (True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True)
    NOP ; 2 cycles
tick_91: ; voltages (True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True)
    NOP ; 2 cycles
tick_92: ; voltages (True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True)
    NOP ; 2 cycles
tick_93: ; voltages (True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True)
    NOP ; 2 cycles
tick_94: ; voltages (True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True)
    NOP ; 2 cycles
tick_95: ; voltages (True, True, True, True, True, True, True, True, True, True, True, True, True, True, True, True)
    NOP ; 2 cycles
tick_96: ; voltages (True, True, True, True, True, True, True, True, True, True, True, True, True, True)
    NOP ; 2 cycles
tick_97: ; voltages (True, True, True, True, True, True, True, True, True, True, True, True)
    NOP ; 2 cycles
tick_98: ; voltages (True, True, True, True, True, True, True, True, True, True)
    NOP ; 2 cycles
tick_99: ; voltages (True, True, True, True, True, True, True, True)
    NOP ; 2 cycles
    JMP (WDATA) ; 6 cycles

; 157 bytes
