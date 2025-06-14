;----------------------------------------------------------;
;                         Text Utils                       ;
;----------------------------------------------------------;
    MODULE tx

formatted16                                     ; Formatted 16bit number
    DB "00000"                                  ; Contains a number formatted into a string
FORMATTED16_SIZE        = 5

;----------------------------------------------------------;
;                        PrintNum16                        ;
;----------------------------------------------------------;
; Print 16 bit number from HL. Each character takes 8x8 pixels
;Input:
;  - HL:    16-bit number to print
;  - BC:    Character offset from top left corner. Each character takes 8 pixels, screen can contain 40x23 characters
;           For B=5 -> First characters starts at 40px (5*8) in first line, for B=41 first characters starts in second line
PrintNum16

    ; Print number from HL into #formatted16
    PUSH BC
    LD DE, formatted16
    CALL Num16ToString
    POP BC

    ; Print text from #formatted8 on screen using tiles
    LD DE, formatted16                           ; Contains 16-bit number as ASCII
    LD A, FORMATTED16_SIZE                       ; Print 5 characters
    CALL ti.PrintText

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   PrintCharacterAt                       ;
;----------------------------------------------------------;
;  - A: ASCII code to print
;  - BC: Character offset from top left corner. Each character takes 8 pixels, screen can contain 40x23 characters
;        For B=5 -> First characters starts at 40px (5*8) in first line, for B=41 first characters starts in second line
PrintCharacterAt

    LD HL, formatted16
    LD (HL), A

    LD DE, formatted16
    LD A, 1                                     ; Print 1 character
    CALL ti.PrintText

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       PrintNum99                         ;
;----------------------------------------------------------;
; Print 8 bit number from A, but only up to 99
;Input:
;  - A:  8-bit number to print
;  - BC: Character offset from top left corner. Each character takes 8 pixels, screen can contain 40x23 characters
;        For B=5 -> First characters starts at 40px (5*8) in first line, for B=41 first characters starts in second line
PrintNum99

    PUSH BC
    CALL ut.NumTo99Str
    POP BC
    LD HL, formatted16
    LD (HL), D
    INC HL
    LD (HL), E

    LD DE, formatted16
    LD A, 2                                     ; Print 2 characters
    CALL ti.PrintText

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      Num16ToString                       ;
;----------------------------------------------------------;
; Converts a given 16-bit number into a 5-character string with padding zeros.
; Input:
;   - HL: 16-bit number to convert.
;   - DE: Pointer to RAM that will contain formatted text, 5-characters long, 0 padded
; Output: ASCII string at memory address given by DE, 5-characters long, 0 padded
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

    LD  C, B                                    ; Last, the rightmost digit

.format
    LD  A, '0'-1                                ; Load ASCI code for 0
.loop 
    INC A
    ADD HL, BC                                  ; Subtract (add negative) given number from input number

    ; Keep looping and subtracting until the carry bit is set.
    ; It happens when subtracting resets the most significant number, i.e., 1234 -> 0123.
    JR  C, .loop
    
    SUB HL, BC                                  ; Add above caused an overflow. Substrat will turn the value one step back, ie: 59857 -> 4321 for input: 54321
    LD (DE), A                                  ; A contains the ASCII value of the most significant number, stored in DE
    INC DE                                      ; Move DE offset to the next position to store the next number

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE