/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                      Common Macros                       ;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                     _LoadSong                            ;
;----------------------------------------------------------;
;  - A: song number from "assets/snd/xx.pt3", #GAME_MUSIC_MIN_D1 - #GAME_MUSIC_MAX_D25.
    MACRO _LoadSong SONG_NR

    CALL dbs.SetupMusicCommonBank
    LD A, SONG_NR
    CALL aml.LoadSong

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                        _AFX                              ;
;----------------------------------------------------------;
    MACRO _AFX FX_NR

    CALL dbs.SetupAyFxsBank
    LD A, FX_NR
    CALL af.AfxPlay

    ENDM                                        ; ## END of the macro ##

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
;                       _RES_HL                            ;
;----------------------------------------------------------;
    MACRO _RES_HL

    XOR A
    LD H, A
    LD L, A
    
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                       _RES_DE                            ;
;----------------------------------------------------------;
    MACRO _RES_DE

    XOR A
    LD D, A
    LD E, A
    
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