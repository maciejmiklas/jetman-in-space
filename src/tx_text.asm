/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                         Text Utils                       ;
;----------------------------------------------------------;
    MODULE tx

formatted32
    DB "0000000000"                             ; 10 characters for 32-bit (max 4,294,967,295)

; Temporary storage for 32-bit number
num32tmp
    DW 0, 0                                     ; 4 bytes for 32-bit number
num32bak    DW 0,0                              ; backup of num32tmp
num32work   DW 0,0                              ; low word scratch (for tentative subtract)

FORMATTED32_SIZE_D10    = 10
FORMATTED16_SIZE_D5     = 5

;----------------------------------------------------------;
;                        PrintNum16                        ;
;----------------------------------------------------------;
; Print 16 bit number from HL. Each character takes 8x8 pixels
;Input:
;  - HL: 16-bit number to print
;  - BC:  character offset from top left corner. Each character takes 8 pixels, screen can contain 40x23 characters.
;         For B=5 -> First characters starts at 40px (5*8) in first line, for B=41 first characters starts in second line.
PrintNum16

    ; Print number from HL into #formatted16.
    PUSH BC
    LD DE, formatted32
    CALL Num16ToString
    POP BC

    ; Print text from #formatted8 on screen using tiles.
    LD DE, formatted32                              ; Contains 16-bit number as ASCII.
    LD A, FORMATTED16_SIZE_D5                       ; Print 5 characters.
    CALL ti.PrintText

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        PrintNum32                        ;
;----------------------------------------------------------;
; Print 32 bit number from HL:DE. Each character takes 8x8 pixels
; Input:
;  - HL: high 16 bits of the 32-bit number
;  - DE: low 16 bits of the 32-bit number
;  - BC: character offset from top left corner
PrintNum32

    ; Convert 32-bit number to string
    PUSH BC
    CALL Num32ToString
    POP BC

    ; Print text from formatted32 on screen using tiles
    LD DE, formatted32
    LD A, FORMATTED32_SIZE_D10
    CALL ti.PrintText

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   PrintCharacterAt                       ;
;----------------------------------------------------------;
;  - A: ASCII code to print
;  - BC: character offset from top left corner. Each character takes 8 pixels, screen can contain 40x23 characters.
;        For B=5 -> First characters starts at 40px (5*8) in first line, for B=41 first characters starts in second line.
PrintCharacterAt

    LD HL, formatted32
    LD (HL), A

    LD DE, formatted32
    LD A, 1                                     ; Print 1 character
    CALL ti.PrintText

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       PrintNum99                         ;
;----------------------------------------------------------;
; Print 8 bit number from A, but only up to 99
;Input:
;  - A:  8-bit number to print
;  - BC: Character offset from top left corner. Each character takes 8 pixels, screen can contain 40x23 characters.
;        For B=5 -> First characters starts at 40px (5*8) in first line, for B=41 first characters starts in second line.
PrintNum99

    PUSH BC
    CALL ut.NumTo99Str
    POP BC
    LD HL, formatted32
    LD (HL), D
    INC HL
    LD (HL), E

    LD DE, formatted32
    LD A, 2                                     ; Print 2 characters.
    CALL ti.PrintText

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      Num16ToString                       ;
;----------------------------------------------------------;
; Converts a given 16-bit number into a 5-character string with padding zeros.
; Input:
;   - HL: 16-bit number to convert.
;   - DE: pointer to RAM that will contain formatted text, 5-characters long, 0 padded.
; Return: ASCII string at memory address given by DE, 5-characters long, 0 padded.
Num16ToString

    ; Each line prints one digit into DE, starting with the most significant.
    LD  BC, -10000
    CALL .format

    LD  BC, -1000
    CALL .format

    LD  BC, -100
    CALL .format

    LD  C, -10
    CALL .format

    LD  C, B                                    ; Last, the rightmost digit.

.format
    LD  A, '0'-1                                ; Load ASCI code for 0.
.loop 
    INC A
    ADD HL, BC                                  ; Subtract (add negative) given number from input number.

    ; Keep looping and subtracting until the carry bit is set.
    ; It happens when subtracting resets the most significant number, i.e., 1234 -> 0123.
    JR  C, .loop
    
    SUB HL, BC                                  ; Add above caused an overflow. Substrat will turn the value one step back, ie: 59857 -> 4321 for input: 54321.
    LD (DE), A                                  ; A contains the ASCII value of the most significant number, stored in DE.
    INC DE                                      ; Move DE offset to the next position to store the next number.

    RET                                         ; ## END of the function ##

    LD HL, $0000
    LD DE, $00FF

;----------------------------------------------------------;
;                      Num32ToString                       ;
;----------------------------------------------------------;
; Converts a 32-bit number into a 10-character string with padding zeros.
; Input:
;  - HL: high 16 bits of the 32-bit number
;  - DE: low  16 bits of the 32-bit number
; Output:
;  - formatted32: 10 ASCII digits '0'..'9'
Num32ToString

    ; Store input 32-bit number: num32tmp = HL:DE
    LD  (num32tmp), HL                          ; high word
    LD  (num32tmp+2), DE                        ; low  word

    LD  HL, formatted32                         ; HL -> output buffer

    ; Precomputed 32-bit powers of 10, high:low words
    ; 10^9  =  1 000 000 000 = $3B9ACA00
    ; 10^8  =    100 000 000 = $05F5E100
    ; 10^7  =     10 000 000 = $00989680
    ; 10^6  =      1 000 000 = $000F4240
    ; 10^5  =        100 000 = $000186A0
    ; 10^4  =         10 000 = $00002710
    ; 10^3  =          1 000 = $000003E8
    ; 10^2  =            100 = $00000064
    ; 10^1  =             10 = $0000000A
    ; 10^0  =              1 = $00000001

    ; 10^9
    LD  BC, $3B9A
    LD  DE, $CA00
    CALL _Format32Digit

    ; 10^8
    LD  BC, $05F5
    LD  DE, $E100
    CALL _Format32Digit

    ; 10^7
    LD  BC, $0098
    LD  DE, $9680
    CALL _Format32Digit

    ; 10^6
    LD  BC, $000F
    LD  DE, $4240
    CALL _Format32Digit

    ; 10^5
    LD  BC, $0001
    LD  DE, $86A0
    CALL _Format32Digit

    ; 10^4
    LD  BC, $0000
    LD  DE, $2710
    CALL _Format32Digit

    ; 10^3
    LD  BC, $0000
    LD  DE, $03E8
    CALL _Format32Digit

    ; 10^2
    LD  BC, $0000
    LD  DE, $0064
    CALL _Format32Digit

    ; 10^1
    LD  BC, $0000
    LD  DE, $000A
    CALL _Format32Digit

    ; 10^0
    LD  BC, $0000
    LD  DE, $0001
    CALL _Format32Digit

    RET

;----------------------------------------------------------;
;                      _Format32Digit                       ;
;----------------------------------------------------------;
; Computes one decimal digit for current divisor BC:DE.
; Uses num32tmp as the working 32-bit number.
; Input:
;  - BC: high word of divisor
;  - DE: low  word of divisor
;  - HL: pointer to current output position
; Output:
;  - (HL) = ASCII digit
;  - HL   = HL+1
;  - num32tmp reduced by digit*(BC:DE)
_Format32Digit
    PUSH HL                                     ; save output pointer

    LD   A, 0                                   ; digit counter

    ; Backup current num32tmp into num32bak
    LD   HL, (num32tmp)
    LD   (num32bak), HL
    LD   HL, (num32tmp+2)
    LD   (num32bak+2), HL

DigitLoop32
    ; Try: num32tmp - divisor
    LD   HL, (num32tmp+2)                       ; low word
    OR   A                                      ; clear carry
    SBC  HL, DE
    LD   (num32work+2), HL                      ; store tentative low

    LD   HL, (num32tmp)                         ; high word
    SBC  HL, BC
    JR   C, DigitDone32                         ; if borrow -> too far, stop

    ; No borrow: commit tentative result
    LD   (num32tmp), HL
    LD   HL, (num32work+2)
    LD   (num32tmp+2), HL

    INC  A
    JR   DigitLoop32

DigitDone32
    ; Restore num32tmp from backup, then subtract (digit) * divisor
    ; Actually, we *already* kept num32tmp as last valid, because
    ; the negative attempt didn't overwrite it. So no restore needed.
    ; (If you prefer explicit safety, you can restore here.)

    POP  HL                                 ; restore output pointer
    ADD  A, '0'
    LD   (HL), A
    INC  HL

    RET

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE