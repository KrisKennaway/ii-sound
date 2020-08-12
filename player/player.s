;
;  player.s
;
;  Created by Kris Kennaway on 27/07/2020.
;  Copyright © 2020 Kris Kennaway. All rights reserved.
;
;  Delta modulation audio player for streaming audio over Ethernet (often called "BTC" in the Apple II community, after
;  https://www.romanblack.com/picsound.htm who described various Apple II-like audio circuits and audio encoding
;  algorithms).
;
;  How this works is by modeling the Apple II speaker as an RC circuit.  When we tick the speaker it inverts the voltage
;  across it, and the speaker responds by moving asymptotically towards the new level.  With some empirical tuning of
;  the time constant of this RC circuit, we can precisely model how the speaker will respond to voltage changes, and use
;  this to make the speaker "trace out" our desired waveform.  We can't do this precisely so there is some left-over
;  quantization noise that manifests as background static.
;
;  This player uses a 13-cycle period, i.e. about 78.7KHz sampling rate.  We could go as low as 9 cycles for the period,
;  but there is an audible 12.6KHz harmonic that I think is due to interference between the 9 cycle period and the
;  every-65-cycle "long cycle" of the Apple II CPU.  13 cycles evenly divides 65 so this avoids the harmonic.
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
;  - As with my II-Vision streaming video+audio player, we schedule a "slow path" dispatch to occur every 2KB in the
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
    LDA #<exit
    STA RESET_VECTOR
    LDA #>exit
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

; CONFIGRE SOCKET 0 FOR TCP

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

    ; pretty colours
    STA TEXTOFF
    STA FULLSCR

    LDA #$22
    LDX #$04
    LDY #$08
    JSR fill

    LDA #$66
    LDX #$08
    LDY #$0c
    JSR fill

    ; to restore after checkrecv
    LDY #>RXBASE
    
    LDA #>S0RXRSR
    STA WADRH
    JMP checkrecv

fill:
    STX @1+2
    STY @2+1

    PHA
@0:
    PLA
    LDX #$00
@1:
    STA $0400,X
    INX
    CPX #$78
    BNE @1

    PHA
    CLC
    LDA @1+1
    ADC #$80
    STA @1+1
    LDA @1+2
    ADC #$00
    STA @1+2
@2:
    CMP #$08
    BNE @0
    PLA
    RTS

; The actual player code

begin_copy_page1:
tick_page1: ; $300
    STA TICK
    STA PAGE2OFF
    JMP (WDATA)
    
notick_page1: ; $309
    STA PAGE2OFF
    NOP
    NOP
    JMP (WDATA)
    
notick_page2: ;$311
    STA PAGE2ON
    NOP
    NOP
    JMP (WDATA)

; Quit to ProDOS
exit: ; $319
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

; Manage W5100 socket buffer and ACK TCP stream.
;
; In order to simplify the buffer management we expect this ACK opcode to consume
; the last 4 bytes in a 2K "TCP frame".  i.e. we can assume that we need to consume
; exactly 2K from the W5100 socket buffer.
;
; While during this we need to keep ticking the speaker every 13 cycles to maintain the same
; net position of the speaker cone.  It might be possible to compensate for some other cadence in the encoder,
; but this risks introducing unwanted harmonics.  We end up ticking 12 times assuming we don't stall waiting for
; the socket buffer to refill.  In that case audio is already going to be disrupted though.
slowpath: ;$329
    STA TICK ; 4
    
    ; Save the W5100 address pointer so we can come back here later
    ; We know the low-order byte is 0 because Socket RX memory is page-aligned and so is 2K frame.
    ; IMPORTANT - from now on until we restore this below, we can't trash the Y register!
    LDY WADRH ; 4
    
    ; Read Received Read pointer
    LDA #>S0RXRD ; 2
    STA zpdummy ; 3
    STA TICK ; 4 [13]
    
    STA WADRH ; 4
    
    LDX #<S0RXRD ; 2
    STA zpdummy ; 3
    STA TICK ; 4 [13]
    
    STX WADRL ; 4
    NOP ; 2
    STA zpdummy ; 3
    STA TICK ; 4 [ 13]

    LDA WDATA ; 4 Read high byte
    ; No need to read low byte since it's guaranteed to be 0 since we're at the end of a 2K frame.

    ; Update new Received Read pointer
    ; We have received an additional 2KB
    CLC ; 2
    STA zpdummy ; 3
    STA TICK ; 4 [13]
    
    ADC #$08 ; 2

    STX WADRL ; 4 Reset address pointer, X still has #<S0RXRD
    STA zpdummy ; 3
    STA TICK ; 4 [13]

    STA WDATA ; 4 Store new high byte
    ; No need to store low byte since it's unchanged at 0

    ; Send the Receive command
    LDA #<S0CR ; 2

    STA zpdummy ; 3
    STA TICK ; 4 [13]
    
    STA WADRL ; 4

    LDA #SCRECV ; 2
    STA zpdummy ; 3
    STA TICK ; 4 [13]
    
    STA WDATA ; 4
    
checkrecv:
    LDA #<S0RXRSR   ; 2 Socket 0 Received Size register
    STA zpdummy ; 3

    ; we might loop an unknown number of times here waiting for data but the default should be to fall
    ; straight through
@0:
    STA TICK        ; 4
    STA WADRL       ; 4
    LDX #$07; 2  could move out of loop but need to pad cycles anyway
    STA zpdummy ; 3
    STA TICK ; 4 [13]
    
    CPX WDATA       ; 4 High byte of received size

    BCC @1          ; 2
    BCS @0          ; 3
    
@1:
    NOP ; 2
    STA TICK ; 4 [13]

    ; point W5100 back into the RX buffer where we left off
    ; There is data to read - we don't care exactly how much because it's at least 2K
    ;
    ; Restore W5100 address pointer where we last found it.
    ;
    ; It turns out that the W5100 automatically wraps the address pointer at the end of the 8K RX/TX buffers
    ; Since we're using an 8K socket, that means we don't have to do any work to manage the read pointer!
    STY WADRH  ; 4
    LDX #$00 ; 2
    STA zpdummy ; 3
    STA TICK ; 4
    
    STX WADRL  ; 4
    JMP (WDATA) ; 5
end_copy_page1:
.endproc
