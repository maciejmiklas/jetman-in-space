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