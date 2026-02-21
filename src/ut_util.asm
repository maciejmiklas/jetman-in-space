/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                          Utils                           ;
;----------------------------------------------------------;
    MODULE ut

PAUSE_TIME_D10          = 10

; DMA Program to copy RAM from #dmaPortAAddress to #dmaPortBAddress, size is given by: dmaTransferLength
dmaProgram
    DB %1'00000'11                              ; WR6 - disable DMA.

    DB %0'11'11'1'01                            ; WR0 - append length + port A address, A->B
dmaPortAAddress
    DW 0                                        ; WR0 par 1&2 - port A start address
dmaTransferSize
    DW 0                                        ; WR0 par 3&4 - transfer length

    DB %0'0'01'0'100                            ; WR1 - A incr., A=memory

    DB %0'0'01'0'000                            ; WR2 - B incr., B=memory

    DB %1'01'0'11'01                            ; WR4 - continuous, append port B address
dmaPortBAddress
    DW 0                                        ; WR4 par 1&2 - port B address

    DB %10'0'0'0010                             ; WR5 - stop on end of block, CE only

    DB %1'10011'11                              ; WR6 - load addresses into DMA counters
    DB %1'00001'11                              ; WR6 - enable DMA
dmaProgramSize = $-dmaProgram


;----------------------------------------------------------;
;                      NumTo99Str                          ;
;----------------------------------------------------------;
; Input:  
;    - A: 8-bit value (0..99)
; Return: 
;    - D: ASCII tens digit
;    - E: ASCII units digit
NumTo99Str
    LD B, 0                                     ; B = tens counter
    LD C, 10                                    ; C = divisor

.divLoop:
    CP C                                        ; A < 10?
    JR C, .doneDiv                              ; If yes, exit loop
    SUB C                                       ; A -= 10
    INC B                                       ; B++
    JR .divLoop

.doneDiv:
    LD D, B                                     ; D = tens digit (BCD)
    LD E, A                                     ; E = units digit (BCD)
    LD A, D
    ADD A, '0'                                  ; Convert tens to ASCII
    LD D, A
    LD A, E
    ADD A, '0'                                  ; Convert units to ASCII
    LD E, A
    ; D and E now contain the ASCII digits

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        CopyRam                           ;
;----------------------------------------------------------;
; Input:
;  - #dmaPortAAddress: Address from
;  - #dmaPortBAddress: Address to
;  - #dmaTransferSize: Number of bytes to copy
CopyRam

    LD HL, dmaProgram                          ; HL = pointer to DMA program
    LD B, dmaProgramSize                       ; B = size of the code
    LD C, _DMA_PORT_H6B                        ; C = $6B (zxnDMA port)
    OTIR                                       ; Upload DMA program

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       Add8To32                           ;
;----------------------------------------------------------;
; Input:
;  - HL: points to the start of the two DW (LO,HI) elements in RAM
;  - A:  contains the 8-bit value to add
Add8To32

    ; Add 8-bit value to the second DW, LO byte.
    LD B, A                                     ; Copy the 8-bit value into B (used for carry handling).
    LD A, (HL)                                  ; Load the least significant byte (LSB) of the second DW (LO).
    ADD B                                       ; Add the 8-bit value to the LSB.
    LD (HL), A                                  ; Store the result back to memory.
    INC HL                                      ; Move to the next byte.

    ; Populate overflow to remaining 3 bytes
    LD B, 3
.loop
    LD A, (HL)                                  ; Load next byte from 32bit word.
    ADC A, 0                                    ; Add the carry from the previous addition.
    LD (HL), A                                  ; Store the result back to memory.
    INC HL                                      ; Move to the next byte.
    DJNZ .loop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                          HLdivC                          ;
;----------------------------------------------------------;
; http://z80-heaven.wikidot.com/math#toc12
; Input:
;  - HL: numerator
;  - C:  denominator
; Return:
;  - HL: reslut HL/C
HLdivC

    LD B,16
    XOR A
    ADD HL,HL
    RLA
    CP C
    JR C,$+4
    INC L
    SUB C
    DJNZ $-7

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                          CdivD                           ;
;----------------------------------------------------------;
; http://z80-heaven.wikidot.com/math#toc12
; Input:
;  - C: numerator
;  - D: denominator
; Return:
;  - A: remainder
;  - C: result C/D
CdivD

    LD B,8
    XOR A
    SLA C
    RLA
    CP D
    JR C, $+4
    INC C
    SUB D
    DJNZ $-8

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                          AbsDE                           ;
;----------------------------------------------------------;
; http://z80-heaven.wikidot.com/math#toc12
AbsDE

    BIT 7, D
    RET Z
    XOR A
    SUB E 
    LD E, A
    SBC A, A 
    SUB D 
    LD D, A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                          AbsBC                           ;
;----------------------------------------------------------;
; http://z80-heaven.wikidot.com/math#toc12
AbsBC

    BIT 7, B
    RET Z
    XOR A 
    SUB C 
    LD C, A
    SBC A, A
    SUB B
    LD B, A

    RET                                         ; ## END of the function ##
    
;----------------------------------------------------------;
;                          AbsHL                           ;
;----------------------------------------------------------;
; http://z80-heaven.wikidot.com/math#toc12
AbsHL

    BIT 7, H
    RET Z
    XOR A
    SUB L 
    LD L, A
    SBC A, A 
    SUB H 
    LD H, A
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                          AbsA                            ;
;----------------------------------------------------------;
AbsA

    OR A
    RET P
    NEG
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    PrintNumber                           ;
;----------------------------------------------------------;
; Print 16 bit number from HL. Each character takes 8x8 pixels.
;Input:
;  - HL: 16-bit number to print
;  - BC: character offset from top left corner. Each character takes 8 pixels, screen can contain 40x23 characters.
;        For B=5 -> First characters starts at 40px (5*8) in first line, for B=41 first characters starts in second line.
PrintNumber

    PUSH AF, BC, DE, IX, IY
    
    CALL tx.PrintNum16
    
    POP IY, IX, DE, BC, AF
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        HlEqual0                          ;
;----------------------------------------------------------;
; Check if both H and L are 0
; Input:
;  - HL: value to compare to B
; Return:
;  - YES: Z is reset (JP Z).
;  - NO:  Z is set (JP NZ).
HlEqual0

    LD A, H                                     ; Check if H == B
    OR A                                        ; Same as CP 0, but faster.
    JR NZ, .notEqual                            ; Jump if H != B
    LD A, L                                     ; Check if L == B
    OR A                                        ; Same as CP 0, but faster.
    JR NZ, .notEqual                            ; Jump if L == B

    ; H == 0 and L == 0
    _YES
    RET

.notEqual
    _NO

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ReadNextReg                        ;
;----------------------------------------------------------;
; Input:
;   - A: nextreg to read
; Return:
;   - A: value in nextreg
ReadNextReg

    PUSH    BC
    LD      BC, _GL_REG_SELECT_H243B
    OUT     (C),A
    INC     B
    IN      A,(C)                               ; Read desired NextReg state
    POP     BC

    RET

;----------------------------------------------------------;
;                        PauseShort                        ;
;----------------------------------------------------------;
PauseShort

    LD BC, 65000
    CALL CountdownBC
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                          Pause                           ;
;----------------------------------------------------------;
Pause

    PUSH AF, BC, DE, HL, IX, IY

    LD A, PAUSE_TIME_D10
.loop:

    LD BC, 65000
    CALL CountdownBC

    DEC A
    JP NZ, .loop

    POP IY, IX, HL, DE, BC, AF

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        CountdownBC                       ;
;----------------------------------------------------------;
; Input: 
;  - BC: loop amount
CountdownBC

    PUSH AF, BC, DE, HL, IX, IY

.loop:
    DEC BC                                      ; DEC BC from 65000 to 0
    LD A, B
    OR A                                        ; Same as CP 0, but faster.
    JP NZ,.loop

    POP IY, IX, HL, DE, BC, AF

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                         FillBank                         ;
;----------------------------------------------------------;
; Input:
;  - A: destination bank
;  - D: value to fill banks with
;  - HL: start address
; Modifies: AF,BC,HL
FillBank

    LD BC, _BANK_BYTES_D8192                    ; 8192 bytes is a full bank.
.loop
    LD (HL), D
    INC HL
    DEC BC

    ; Check if BC is 0. OR returns 0 when both params are 0, it also sets ZF.
    LD A, B
    OR C
    JR NZ, .loop                                ; Keep looping if ZF is not set (BC != 0).

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE