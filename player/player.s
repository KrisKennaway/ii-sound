;
;  player.s
;
;  Created by Kris Kennaway on 27/07/2020.
;  Copyright © 2020 Kris Kennaway. All rights reserved.
;
;  Delta modulation audio player for streaming audio over Ethernet.
;
;  How this works is by modeling the Apple II speaker as an RC circuit.  Delta modulation with an RC circuit is often
;  called "BTC", after https://www.romanblack.com/picsound.htm.
;
;  When we tick the speaker it inverts the applied voltage across it, and the speaker responds by moving asymptotically
;  towards the new level.  With some empirical tuning of the time constant of this RC circuit (which seems to be about
;  500 us), we can precisely model how the speaker will respond to voltage changes, and use this to make the speaker
;  "trace out" our desired waveform.  We can't do this precisely -- the speaker will zig-zag around the target waveform
;  because we can only move it in finite steps -- so there is some left-over quantization noise that manifests as
;  background static.
;
;  This player is capable of manipulating the speaker with 1-cycle precision, i.e. a 1MHz sampling rate, depending on
;  how the "player opcodes" are chained together by the ethernet bytestream.  The catch is that once we have toggled
;  the speaker we can't toggle it again until at least 10 cycles have passed, but we can pick any interval >= 10 cycles
;  (except for 11 because of 6502 opcode timing limitations).
;
;  Some other tricks used here:
;
;  - The minimal 9-cycle speaker loop is: STA $C030; JMP (WDATA), where we use an undocumented property of the
;    Uthernet II: I/O registers on the WDATA don't wire up all of the address lines, so they are also accessible at
;    other address offsets.  In particular WDATA+1 is a duplicate copy of WMODE.  In our case WMODE happens to be 0x3.
;    This lets us use WDATA as a jump table into page 3, where we place our player code.  We then choose the network
;    byte stream to contain the low-order byte of the target address we want to jump to next.
;  - Since our 13-cycle period gives us 4 "spare" cycles over the minimal 9, that also lets us do a page-flipping trick
;    to visualize the audio bitstream while playing.
;  - As with my ][-Vision streaming video+audio player, we schedule a "slow path" dispatch to occur every 2KB in the
;    byte stream, and use this to manage the socket buffers (ACK the read 2KB and wait until at least 2KB more is
;    available, which is usually non-blocking).  While doing this we need to maintain the 13 cycle cadence so the
;    speaker is in a known trajectory.  We can compensate for this in the audio encoder.

.proc main
.org $2000

init:
    JMP bootstrap

; TODO: make these configurable
SRCADDR:  .byte   10,0,65,02                 ; 10.0.65.02     W5100 IP
FADDR:    .byte   10,0,0,1                   ; 10.0.0.1       FOREIGN IP
FPORT:    .byte   $07,$b9                    ; 1977           FOREIGN PORT
MAC:      .byte   $00,$08,$DC,$01,$02,$03    ; W5100 MAC ADDRESS

; SLOT 1 I/O ADDRESSES FOR THE W5100
; Change this to support the Uthernet II in another slot
;
; TODO: make slot I/O addresses customizable at runtime - would probably require somehow
; compiling a list of all of the binary offsets at which we reference $C09x and patching
; them in memory or on-disk.
WMODE = $C094
WADRH = $C095
WADRL = $C096
WDATA = $C097

; W5100 LOCATIONS
MACADDR  =   $0009    ; MAC ADDRESS
SRCIP    =   $000F    ; SOURCE IP ADDRESS
RMSR     =   $001A    ; RECEIVE BUFFER SIZE

; SOCKET 0 LOCATIONS
S0MR = $0400  ; SOCKET 0 MODE REGISTER
S0CR = $0401  ; COMMAND REGISTER
S0SR = $0403  ; STATUS REGISTER
S0LOCALPORT = $0404   ; LOCAL PORT
S0FORADDR =  $040C    ; FOREIGN ADDRESS
S0FORPORT =  $0410    ; FOREIGN PORT
S0TXRR   =   $0422    ; TX READ POINTER REGISTER
S0TXWR   =   $0424    ; TX WRITE POINTER REGISTER
S0RXRSR  =   $0426    ; RX RECEIVED SIZE REGISTER
S0RXRD   =   $0428    ; RX READ POINTER REGISTER

; SOCKET 0 PARAMETERS
RXBASE =  $6000       ; SOCKET 0 RX BASE ADDR
RXMASK =  $1FFF       ; SOCKET 0 8KB ADDRESS MASK
TXBASE  =   $4000     ; SOCKET 0 TX BASE ADDR
TXMASK  =   RXMASK    ; SOCKET 0 TX MASK

; SOCKET COMMANDS
SCOPEN   =   $01  ; OPEN
SCCONNECT =  $04  ; CONNECT
SCDISCON =   $08  ; DISCONNECT
SCSEND   =   $20  ; SEND
SCRECV   =   $40  ; RECV

; SOCKET STATUS
STINIT   =   $13
STESTABLISHED = $17

PRODOS      = $BF00 ; ProDOS MLI entry point
RESET_VECTOR = $3F2 ; Reset vector
COUT        = $FDED
HOME        = $FC58

TICK        = $C030 ; where the magic happens
TEXTOFF     = $C050
FULLSCR     = $C052
PAGE2OFF    = $C054
PAGE2ON     = $C055
ptr = $06  ; TODO: we only use this for connection retry count
zpdummy = $ff

; RESET AND CONFIGURE W5100
bootstrap:
    ; install reset handler
    LDA #<real_exit
    STA RESET_VECTOR
    LDA #>real_exit
    STA RESET_VECTOR+1
    EOR #$A5
    STA RESET_VECTOR+2 ; checksum to ensure warm-start reset

    LDA   #6    ; 5 RETRIES TO GET CONNECTION
    STA   ptr   ; NUMBER OF RETRIES

reset_w5100:
    LDA #$80    ; reset
    STA WMODE
    LDA #3  ; CONFIGURE WITH AUTO-INCREMENT
    STA WMODE

; ASSIGN MAC ADDRESS
    LDA #>MACADDR
    STA WADRH
    LDA #<MACADDR
    STA WADRL
    LDX #0
@L1:
    LDA MAC,X
    STA WDATA ; USING AUTO-INCREMENT
    INX
    CPX #6  ;COMPLETED?
    BNE @L1

; ASSIGN A SOURCE IP ADDRESS
    LDA #<SRCIP
    STA WADRL
    LDX #0
@L2:
    LDA SRCADDR,X
    STA WDATA
    INX
    CPX #4
    BNE @L2

;CONFIGURE BUFFER SIZES

    LDA #<RMSR
    STA WADRL
    LDA #3 ; 8KB TO SOCKET 0
    STA WDATA ; SET RECEIVE BUFFER
    STA WDATA ; SET TRANSMIT BUFFER

; CONFIGURE SOCKET 0 FOR TCP

    LDA #>S0MR
    STA WADRH
    LDA #<S0MR
    STA WADRL
    LDA #$21 ; TCP MODE | !DELAYED_ACK
    STA WDATA

; SET LOCAL PORT NUMBER

    LDA #<S0LOCALPORT
    STA WADRL
    LDA #$C0 ; HIGH BYTE OF LOCAL PORT
    STA WDATA
    LDA #0 ; LOW BYTE
    STA WDATA

; SET FOREIGN ADDRESS
    LDA #<S0FORADDR
    STA WADRL
    LDX #0
@L3:
    LDA FADDR,X
    STA WDATA
    INX
    CPX #4
    BNE @L3

; SET FOREIGN PORT
    LDA FPORT   ; HIGH BYTE OF FOREIGN PORT
    STA WDATA   ; ADDR PTR IS AT FOREIGN PORT
    LDA FPORT+1  ; LOW BYTE OF PORT
    STA WDATA

; OPEN SOCKET
    LDA #<S0CR
    STA WADRL
    LDA #SCOPEN ;OPEN COMMAND
    STA WDATA

; CHECK STATUS REGISTER TO SEE IF SUCCEEDED
    LDA #<S0SR
    STA WADRL
    LDA WDATA
    CMP #STINIT ; IS IT SOCK_INIT?
    BEQ OPENED
    LDY #0
@L4:
    LDA @SOCKERR,Y
    BEQ @LDONE
    JSR COUT
    INY
    BNE @L4
@LDONE: BRK
@SOCKERR: .byte $d5,$d4,$c8,$c5,$d2,$ce,$c5,$d4,$a0,$c9,$c9,$ba,$a0,$c3,$cf,$d5,$cc,$c4,$a0,$ce,$cf,$d4,$a0,$cf,$d0,$c5,$ce,$a0,$d3,$cf,$c3,$cb,$c5,$d4,$a1
; "UTHERNET II: COULD NOT OPEN SOCKET!"
    .byte $8D,$00 ; cr+null

; TCP SOCKET WAITING FOR NEXT COMMAND
OPENED:
    LDA #<S0CR
    STA WADRL
    LDA #SCCONNECT
    STA WDATA

; WAIT FOR TCP TO CONNECT AND BECOME ESTABLISHED

CHECKTEST:
    LDA #<S0SR
    STA WADRL
    LDA WDATA ; GET SOCKET STATUS
    BEQ FAILED ; 0 = SOCKET CLOSED, ERROR
    CMP #STESTABLISHED
    BEQ setup ; SUCCESS
    BNE CHECKTEST

FAILED:
    DEC ptr
    BEQ ERRDONE ; TOO MANY FAILURES
    LDA #$AE    ; "."
    JSR COUT
    JMP reset_w5100 ; TRY AGAIN

ERRDONE:
    LDY #0
@L:
    LDA ERRMSG,Y
    BEQ @DONE
    JSR COUT
    INY
    BNE @L
@DONE: BRK

ERRMSG: .byte $d3,$cf,$c3,$cb,$c5,$d4,$a0,$c3,$cf,$d5,$cc,$c4,$a0,$ce,$cf,$d4,$a0,$c3,$cf,$ce,$ce,$c5,$c3,$d4,$a0,$ad,$a0,$c3,$c8,$c5,$c3,$cb,$a0,$d2,$c5,$cd,$cf,$d4,$c5,$a0,$c8,$cf,$d3,$d4
; "SOCKET COULD NOT CONNECT - CHECK REMOTE HOST"
    .byte $8D,$00

setup:
    ; move player code into $3xx
    LDX #0
@0:
    LDA begin_copy_page1,X
    STA $300,X
    INX
    CPX #(end_copy_page1 - begin_copy_page1+1)
    BNE @0

    ; clear screen
    jsr HOME

    ; to restore after checkrecv
    LDY #>RXBASE
    LDA #>S0RXRSR
    STA WADRH
    JMP checkrecv

real_exit:
    INC  RESET_VECTOR+2  ; Invalidate power-up byte
    JSR  PRODOS          ; Call the MLI ($BF00)
    .BYTE $65            ; CALL TYPE = QUIT
    .ADDR exit_parmtable ; Pointer to parameter table

exit_parmtable:
    .BYTE 4             ; Number of parameters is 4
    .BYTE 0             ; 0 is the only quit type
    .WORD 0000          ; Pointer reserved for future use
    .BYTE 0             ; Byte reserved for future use
    .WORD 0000          ; Pointer reserved for future use

; The actual player code, which will be copied to $3xx for execution
;
; opcode cycle counts are for 65c02, for 6502 they are 1 less because JMP (indirect) is 5 cycles instead of 6.

begin_copy_page1:
; generated audio playback code
.include "player_generated.s"

; Quit to ProDOS
exit:
    JMP real_exit

; Manage W5100 socket buffer and ACK TCP stream.
;
; In order to simplify the buffer management we expect this ACK opcode to consume the last 4 bytes in a 2K "TCP frame".
; i.e. we can assume that we need to consume exactly 2K from the W5100 socket buffer.
;
; While during this we need to keep ticking the speaker at a regular cadence to maintain the same net position of the
; speaker cone.  We choose to tick every 14 cycles, which requires adding in minimal NOP padding.
;
; We end up ticking 8 times with 10 cycles left over, assuming we don't stall waiting for the socket buffer to refill.
;
; From the point of view of speaker voltages this slowpath is equivalent to the following opcode sequence:
; TICK_6 (TICK_14 * 7) with 4 cycles left over, adding 4 to the effective n of the next TICK_n we jump to (as chosen by
; the encoder).  XXX timing
;
; If we do stall waiting for data then there is no need to worry about maintaining an even cadence, because audio
; will already be disrupted (since the encoder won't have predicted it, so will be tracking wrong).  The speaker will
; resynchronize within a few hundred microseconds though.
end_of_frame:
    STA TICK ; 4
    JMP _end_of_frame ; 3 rest of end_of_frame doesn't fit in page 3
end_copy_page1:

_end_of_frame:
    STA zpdummy ; 3
    ; Save the W5100 address pointer so we can come back here later
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    STA TICK ; 4 [10]
    LDY WADRH ; 4

    ; Read Received Read pointer
    LDA #>S0RXRD ; 2
    STA TICK ; 4 [10]
    STA WADRH ; 4

    LDX #<S0RXRD ; 2
    STA TICK ; 4 [10]

    STX WADRL ; 4
    NOP ; 2
    STA TICK ; 4 [10]
    LDA WDATA ; 4 Read high byte

    ; No need to read low byte since it's guaranteed to be 0 since we're at the end of a 2K frame.

    ; Update new Received Read pointer
    ; We have received an additional 2KB
    CLC ; 2
    STA TICK ; 4 [10]
    ADC #$08 ; 2

    STX WADRL ; 4 Reset address pointer, X still has #<S0RXRD
    STA TICK ; 4 [10]
    ; No need to store low byte since it's unchanged at 0
    STA WDATA ; 4 Store new high byte

    ; Send the Receive command
    LDA #<S0CR ; 2
    STA TICK ; 4 [10]
    STA WADRL ; 4

    LDA #SCRECV ; 2
    STA TICK ; 4 [10]
    STA WDATA ; 4

checkrecv:
    LDA #<S0RXRSR   ; 2 Socket 0 Received Size register
    STA TICK ; 4 [10]
    LDX #$07 ; 2
    NOP ; 2
    NOP ; 2
    STA TICK ; 4 [10]
    ; we might loop an unknown number of times here waiting for data but the default should be to fall
    ; straight through
@0:
    STA WADRL       ; 4
    NOP ; 2
    STA TICK ; 4 [10]
    CPX WDATA       ; 4 High byte of received size
    BCS @0          ; 2 in common case when there is already sufficient data waiting.
    STA TICK ; 4 [10]

    ; point W5100 back into the RX buffer where we left off
    ; There is data to read - we don't care exactly how much because it's at least 2K
    ;
    ; Restore W5100 address pointer where we last found it.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K RX/TX buffers
    ; Since we're using an 8K socket, that means we don't have to do any work to manage the read pointer!
    STY WADRH  ; 4
    LDX #$00 ; 2
    STA TICK ; 4 [10]

    STX WADRL  ; 4
    NOP ; 2
    STA TICK ; 4 [10]
    JMP (WDATA) ; 6
.endproc
