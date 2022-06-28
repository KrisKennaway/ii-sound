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

; 7 entrypoints, 18 bytes
