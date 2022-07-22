eof_trampoline_4_stage2:
    LDA WDATA ; 4 cycles
    STA @0+1 ; 4 cycles
@0:
    JMP (eof_trampoline_4_stage3_page) ; 6 cycles

eof_trampoline_6_stage2:
    LDA WDATA ; 4 cycles
    STA @0+1 ; 4 cycles
@0:
    JMP (eof_trampoline_6_stage3_page) ; 6 cycles

eof_trampoline_7_stage2:
    STA $C030 ; 4 cycles
    LDA WDATA ; 4 cycles
    STA @0+1 ; 4 cycles
@0:
    JMP (eof_trampoline_7_stage3_page) ; 6 cycles

eof_trampoline_8_stage2:
    LDA WDATA ; 4 cycles
    STA @0+1 ; 4 cycles
@0:
    JMP (eof_trampoline_8_stage3_page) ; 6 cycles

eof_trampoline_9_stage2:
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    LDA WDATA ; 4 cycles
    STA @0+1 ; 4 cycles
@0:
    JMP (eof_trampoline_9_stage3_page) ; 6 cycles

eof_trampoline_10_stage2:
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA WDATA ; 4 cycles
    STA @0+1 ; 4 cycles
@0:
    JMP (eof_trampoline_10_stage3_page) ; 6 cycles

eof_trampoline_11_stage2:
    LDA WDATA ; 4 cycles
    STA $C030 ; 4 cycles
    STA @0+1 ; 4 cycles
@0:
    JMP (eof_trampoline_11_stage3_page) ; 6 cycles

eof_trampoline_12_stage2:
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA WDATA ; 4 cycles
    STA @0+1 ; 4 cycles
@0:
    JMP (eof_trampoline_12_stage3_page) ; 6 cycles

eof_trampoline_13_stage2:
    LDA WDATA ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA @0+1 ; 4 cycles
@0:
    JMP (eof_trampoline_13_stage3_page) ; 6 cycles

eof_trampoline_14_stage2:
    LDA WDATA ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA @0+1 ; 4 cycles
@0:
    JMP (eof_trampoline_14_stage3_page) ; 6 cycles

eof_trampoline_15_stage2:
    LDA WDATA ; 4 cycles
    STA @0+1 ; 4 cycles
    STA $C030 ; 4 cycles
@0:
    JMP (eof_trampoline_15_stage3_page) ; 6 cycles

eof_trampoline_16_stage2:
    LDA WDATA ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA @0+1 ; 4 cycles
@0:
    JMP (eof_trampoline_16_stage3_page) ; 6 cycles

eof_trampoline_17_stage2:
    LDA WDATA ; 4 cycles
    STA @0+1 ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
@0:
    JMP (eof_trampoline_17_stage3_page) ; 6 cycles

eof_trampoline_18_stage2:
    LDA WDATA ; 4 cycles
    STA @0+1 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
@0:
    JMP (eof_trampoline_18_stage3_page) ; 6 cycles

eof_trampoline_19_stage2:
    LDA WDATA ; 4 cycles
    STA @0+1 ; 4 cycles
    NOP ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
@0:
    JMP (eof_trampoline_19_stage3_page) ; 6 cycles

eof_trampoline_20_stage2:
    LDA WDATA ; 4 cycles
    STA @0+1 ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
@0:
    JMP (eof_trampoline_20_stage3_page) ; 6 cycles

eof_trampoline_21_stage2:
    LDA WDATA ; 4 cycles
    STA @0+1 ; 4 cycles
@0:
    JMP (eof_trampoline_21_stage3_page) ; 6 cycles

eof_trampoline_22_stage2:
    LDA WDATA ; 4 cycles
    STA @0+1 ; 4 cycles
    NOP ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
@0:
    JMP (eof_trampoline_22_stage3_page) ; 6 cycles

eof_stage_2_10_10:
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA WDATA ; dummy read to maintain framing ; 4 cycles
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    STA $C030 ; 4 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA $C030 ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    STA $C030 ; 4 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    STA $C030 ; 4 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_4_21:
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_4_23:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_4_24:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_4_25:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_4_26:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_4_27:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_4_28:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_4_29:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_4_30:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_4_31:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_4_32:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_4_33:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_4_34:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_4_35:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_4_36:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_4_37:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_4_38:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_4_39:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_4_40:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_4_41:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_6_21:
    STA $C030 ; 4 cycles
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_6_23:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #<S0CR ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_6_24:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    STA $C030 ; 4 cycles
    CLC ; 2 cycles
    STA $C030 ; 4 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_6_25:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_6_26:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    STA $C030 ; 4 cycles
    ADC #$08 ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    STA $C030 ; 4 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    STA $C030 ; 4 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_6_27:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #$07 ; 2 cycles
    STA $C030 ; 4 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_6_28:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #>S0RXRD ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_6_29:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_6_30:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    STA $C030 ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_6_31:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_6_32:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #$00 ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_6_33:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_6_34:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_6_35:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDY #$31 ; 2 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_6_37:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    STA $C030 ; 4 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_6_38:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    STA $C030 ; 4 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    STA $C030 ; 4 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_7_18:
    STA $C030 ; 4 cycles
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_7_20:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    STA $C030 ; 4 cycles
    ; Send the Receive command
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    STA $C030 ; 4 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_7_21:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_7_22:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    STA $C030 ; 4 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_7_23:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_7_24:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    STA $C030 ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_7_25:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_7_26:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_7_27:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_7_29:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_7_30:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_7_31:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_7_32:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_7_33:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_7_34:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_7_36:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    STA $C030 ; 4 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_7_37:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_7_38:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_8_21:
    STA $C030 ; 4 cycles
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    STA $C030 ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    STA $C030 ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_8_23:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    LDY WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    STA $C030 ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STY WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_8_25:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA $C030 ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_8_26:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDY WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA $C030 ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STX WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    NOP ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_8_27:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    STA $C030 ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    STA $C030 ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_8_29:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #<S0CR ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_8_30:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_8_31:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #$00 ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_8_33:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    STA $C030 ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_8_34:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    STA $C030 ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    NOP ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_8_35:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    STA $C030 ; 4 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_8_37:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    STA $C030 ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STX WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_9_18:
    STA $C030 ; 4 cycles
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_9_20:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    STA $C030 ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_9_21:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_9_22:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    STA $C030 ; 4 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_9_23:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #<S0CR ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_9_24:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    STA $C030 ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_9_25:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #>S0RXRD ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_9_26:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_9_28:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    STA $C030 ; 4 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_9_29:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_9_30:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_9_31:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_9_32:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDY #$31 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_9_33:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_9_34:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    STA $C030 ; 4 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_9_35:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDY #$31 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_10_18:
    STA $C030 ; 4 cycles
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    STA $C030 ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    STA $C030 ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    STA $C030 ; 4 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_10_21:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    STA $C030 ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_10_22:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA $C030 ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    STA $C030 ; 4 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_10_23:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA $C030 ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_10_24:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    STA $C030 ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    STA $C030 ; 4 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_10_25:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    STA $C030 ; 4 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_10_26:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_10_27:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_10_28:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    STA $C030 ; 4 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_10_29:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_10_31:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    STA $C030 ; 4 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_10_32:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    STA $C030 ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_10_33:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    STA $C030 ; 4 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_10_34:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    STA $C030 ; 4 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    STA $C030 ; 4 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_11_14:
    STA $C030 ; 4 cycles
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #SCRECV ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STX WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #$00 ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    NOP ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_11_16:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    STA $C030 ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    STA $C030 ; 4 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STY WADRH ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    NOP ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_11_17:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #SCRECV ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STX WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #$00 ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    NOP ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_11_18:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    STA $C030 ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #SCRECV ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_11_19:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #<S0CR ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STY WADRH ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    NOP ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_11_20:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    STA $C030 ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_11_21:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #>S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #SCRECV ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_11_23:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_11_24:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    STA $C030 ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_11_25:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STX WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_11_26:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #SCRECV ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #$00 ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_11_27:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #<S0CR ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_11_28:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDY #$31 ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_11_29:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #SCRECV ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #$00 ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_11_30:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    STA $C030 ; 4 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    NOP ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    NOP ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_11_31:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDY #$31 ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_11_32:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    STA $C030 ; 4 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_11_34:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    STA $C030 ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_12_18:
    STA $C030 ; 4 cycles
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    STA $C030 ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA $C030 ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    STA $C030 ; 4 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_12_20:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    STA $C030 ; 4 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    STA $C030 ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_12_21:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA $C030 ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    STA $C030 ; 4 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_12_22:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_12_23:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_12_25:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_12_26:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_12_27:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_12_29:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_12_31:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    STA $C030 ; 4 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_12_33:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    STA $C030 ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_13_14:
    STA $C030 ; 4 cycles
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    STA $C030 ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    STA $C030 ; 4 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_13_16:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_13_17:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STX WADRL ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_13_18:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_13_19:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_13_20:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA $C030 ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STX WADRL ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDY #$31 ; 2 cycles
    NOP ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_13_21:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_13_22:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_13_23:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STX WADRL ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDY #$31 ; 2 cycles
    NOP ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_13_24:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_13_25:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_13_27:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_13_28:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_13_29:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_13_30:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    STA $C030 ; 4 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_13_31:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_13_32:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STX WADRL ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_14_16:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    STA $C030 ; 4 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    STA $C030 ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    STA $C030 ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    NOP ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_14_17:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    STA $C030 ; 4 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_14_18:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    STA $C030 ; 4 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    STA $C030 ; 4 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_14_19:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    STA $C030 ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    NOP ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_14_20:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    STA $C030 ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    STA $C030 ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_14_22:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    STA $C030 ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_14_23:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_14_24:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    STA $C030 ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_14_25:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    STA $C030 ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_14_26:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    STA $C030 ; 4 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    STA $C030 ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    NOP ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_14_27:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    STA $C030 ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_14_29:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    STA $C030 ; 4 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    NOP ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_14_30:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    STA $C030 ; 4 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_14_31:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    STA $C030 ; 4 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    STA $C030 ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_15_16:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    STA $C030 ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_15_17:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    NOP ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_15_18:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    STA $C030 ; 4 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_15_19:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_15_20:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    STA $C030 ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    STA $C030 ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_15_21:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_15_22:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_15_23:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_15_24:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_15_26:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    STA $C030 ; 4 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    NOP ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_15_28:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    STA $C030 ; 4 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_15_29:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    NOP ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_16_17:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    STA $C030 ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_16_18:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_16_19:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    STA $C030 ; 4 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_16_20:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    STA $C030 ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    STA $C030 ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_16_21:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_16_22:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    STA $C030 ; 4 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_16_23:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    STA $C030 ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_16_25:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    STA $C030 ; 4 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_16_26:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    STA $C030 ; 4 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    STA $C030 ; 4 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_16_27:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    STA $C030 ; 4 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_16_29:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    STA $C030 ; 4 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_17_18:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_17_19:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_17_20:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_17_21:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_17_22:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    NOP ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_17_23:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_17_24:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_17_25:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    NOP ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_17_26:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    STA $C030 ; 4 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_17_27:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_17_28:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    STA $C030 ; 4 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_18_19:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    STA $C030 ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    STA $C030 ; 4 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_18_20:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_18_21:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    STA $C030 ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    STA $C030 ; 4 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_18_22:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_18_23:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_18_25:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_18_26:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_19_20:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_19_21:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_19_22:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_19_23:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_19_24:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    STA $C030 ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_19_25:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_19_26:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_20_21:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    STA $C030 ; 4 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_20_22:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA $C030 ; 4 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA $C030 ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    STA $C030 ; 4 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_20_23:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    NOP ; 2 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    STA $C030 ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_21_23:
    STA $C030 ; 4 cycles
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    STY WADRH ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    NOP ; 2 cycles
    NOP ; 2 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    JMP (WDATA) ; 6 cycles

eof_stage_3_22_23:
    ; We've read exactly 2KB from the socket buffer.  Before continuing we need to ACK this read,
    ; and make sure there's at least another 2KB in the buffer.
    ;
    ; Save the W5100 address pointer so we can continue reading the socket buffer once we are done.
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4 cycles
    ; Update new Received Read pointer.
    ;
    ; We know we have received exactly 2KB, so we don't need to read the current value from the
    ; hardware.  We can track it ourselves instead, which saves a few cycles.
    LDA #>S0RXRD ; 2 cycles
    STA WADRH ; 4 cycles
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #<S0RXRD ; 2 cycles
    STA WADRL ; 4 cycles
    LDA RXRD ; TODO: in principle we could update RXRD outside of the EOF path ; 4 cycles
    CLC ; 2 cycles
    ADC #$08 ; 2 cycles
    STA WDATA ; Store new high byte of received read pointer ; 4 cycles
    STA $C030 ; 4 cycles
    STA RXRD ; Save for next time ; 4 cycles
    ; Send the Receive command
    LDA #<S0CR ; 2 cycles
    STA WADRL ; 4 cycles
    LDA #SCRECV ; 2 cycles
    STA WDATA ; 4 cycles
    ; Make sure we have at least 2KB more in the socket buffer so we can start another frame.
    STA zpdummy ; 3 cycles
    STA $C030 ; 4 cycles
    LDA #$07 ; 2 cycles
    LDX #<S0RXRSR ; Socket 0 Received Size register ; 2 cycles
    ; we might loop an unknown number of times here waiting for data but the default should be to
    ; fall straight through
@0:
    STX WADRL ; 4 cycles
    CMP WDATA ; High byte of received size ; 4 cycles
    BCS @0 ; 2 cycles in common case when there is already sufficient data waiting. ; 2 cycles
    ; We're good to go for another frame.  Restore W5100 address pointer where we last found it, to
    ; begin iterating through the next 2KB of the socket buffer.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K
    ; RX/TX buffers.  Since we're using an 8K socket, that means we don't have to do any work to
    ; manage the read pointer!
    STY WADRH ; 4 cycles
    STA $C030 ; 4 cycles
    LDA #$00 ; 2 cycles
    STA WADRL ; 4 cycles
    LDY #$31 ; 2 cycles
    JMP (WDATA) ; 6 cycles

