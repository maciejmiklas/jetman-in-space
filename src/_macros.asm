/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                      Common Macros                       ;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                        _YES                              ;
;----------------------------------------------------------;
; Return:
;  - YES: Z is reset (JP Z).
;  - NO:  Z is set (JP NZ).
    MACRO _YES

    XOR A                                       ; Return YES (Z is reset).

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                       _NO                                ;
;----------------------------------------------------------;
; Return:
;  - YES: Z is reset (JP Z).
;  - NO:  Z is set (JP NZ).
    MACRO _NO

    OR 1                                        ; Return NO (Z set).

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                        _DEB                              ;
;----------------------------------------------------------;
    MACRO _DEB

    NEXTREG 2,8

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                        _DEBA                             ;
;----------------------------------------------------------;
    MACRO _DEBA VAL

    LD A, VAL
    NEXTREG 2,8

    ENDM                                        ; ## END of the macro ##

v1 dw 0
;----------------------------------------------------------;
;                         _PR1                             ;
;----------------------------------------------------------;
    MACRO _PR1

    PUSH AF, BC, DE, IX, IY

    LD BC, 60
    LD HL, (v1)
    CALL ut.PrintNumber

.notSpace
    LD A, _KB_B_TO_SPC_H7F
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A.

    ; Key SPACE
    BIT 0, A                                    ; Bit 0 reset -> SPACE pressed.
    JR NZ, .notSpace

    CALL ut.Pause

    POP IY, IX, DE, BC, AF

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                        _PRF1                             ;
;----------------------------------------------------------;
    MACRO _PRF1

    PUSH AF, BC, DE, IX, IY

    LD BC, 60
    LD HL, (v1)
    CALL ut.PrintNumber

    POP IY, IX, DE, BC, AF

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                        _PRI1                             ;
;----------------------------------------------------------;
    MACRO _PRI1

    ld a, (v1)
    inc a
    ld (v1),a
    _PRF1

    ENDM                                        ; ## END of the macro ##

v2 dw 0
;----------------------------------------------------------;
;                         _PR2                             ;
;----------------------------------------------------------;
    MACRO _PR2

    PUSH AF, BC, DE, IX, IY

    LD BC, 66
    LD HL, (v2)
    CALL ut.PrintNumber

.notSpace
    LD A, _KB_B_TO_SPC_H7F
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A.

    ; Key SPACE
    BIT 0, A                                    ; Bit 0 reset -> SPACE pressed.
    JR NZ, .notSpace

    CALL ut.Pause

    POP IY, IX, DE, BC, AF

    ENDM                                        ; ## END of the macro ##