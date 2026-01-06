/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                     Jemtan Lives                         ;
;----------------------------------------------------------;
    MODULE jl

FACE_PAL_H30            = $30
FACE_NORM_LEFT_D192     = 192
FACE_NORM_STR_D193      = 193
FACE_NORM_RIGHT_D194    = 194
FACE_RED_ADD_D3         = 3                     ; Add this value to normal icon to get the same but in red.
FACE_TI_POS_BYTE_D30    = 15*2                  ; *2 because each tile takes 2 bytes.
SCORE_NR_TI_POS_D16     = 16
TI_RAM_START            = ti.TI_MAP_RAM_H5B00 + FACE_TI_POS_BYTE_D30

RED_FACE_LIVES_D1       = 3                     ; Show face when #lives < than this value.
JET_POS_LEFT_D100       = 100                   ; Face looks to the left, if Jetman postion is < 100.
JET_POS_RIGHT_D200      = 200                   ; Face looks to the right, if Jetman postion is > 100.
JET_LIVES_D5            = 5

    ; TODO 50 lives for easy
    DB "If you read this text, it means that you have reached forbidden memory space."
lives                   DB JET_LIVES_D5
    DB "The script stored here will format the SD Card in the next 60 seconds!"
    DB "I would suggest a quick reset ;)"
;----------------------------------------------------------;
;                         LifeUp                           ;
;----------------------------------------------------------;
LifeUp

    LD A, (lives)
    INC A
    LD (lives), A
    CALL _UpdateJetLives

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        LifeDown                          ;
;----------------------------------------------------------;
LifeDown

    LD A, (lives)
    DEC A
    LD (lives), A

    OR A                                        ; Same as CP 0, but faster.
    JR NZ, .keepPlaying
    CALL gc.GameOver
    RET
.keepPlaying

    CALL _UpdateJetLives

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ResetLives                         ;
;----------------------------------------------------------;
ResetLives

    LD A, JET_LIVES_D5
    LD (lives), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       SetupLives                         ;
;----------------------------------------------------------;
SetupLives

    CALL UpdateLifeFaceOnJetMove
    CALL _UpdateJetLives

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 UpdateLifeFaceOnJetMove                  ;
;----------------------------------------------------------;
UpdateLifeFaceOnJetMove

    ; This method is called only when the gamer is active. However, there is one exception. When Jetman boards the rocket, it still counts 
    ; as movement, but the state has already changed to rocket fly.
    LD A, (ms.mainState)
    CP ms.MS_GAME_ACTIVE_D1
    RET NZ

    LD HL, TI_RAM_START

    LD DE, (jpo.jetX)
    LD A, E

    ; Is Jetman facing left?
    CP JET_POS_LEFT_D100
    JR NC, .notLeft
    LD B, FACE_NORM_LEFT_D192
    JR .loaded
.notLeft

    ; Is Jetman facing right?
    CP JET_POS_RIGHT_D200
    JR C, .notRight
    LD B, FACE_NORM_RIGHT_D194
    JR .loaded
.notRight
    ; Not right and not left, then straight
    LD B, FACE_NORM_STR_D193

.loaded

    ; Should icon face turn red because there are almost no lives left?
    LD A, (lives)
    CP RED_FACE_LIVES_D1
    JR NC, .notRed
    LD A, FACE_RED_ADD_D3
    ADD A, B 
    LD B, A
.notRed

    LD (HL), B                                  ; Set tile id.
    INC HL
    LD (HL), FACE_PAL_H30                           ; Set palette for tile.
    INC HL

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                    _UpdateJetLives                       ;
;----------------------------------------------------------;
_UpdateJetLives

    LD A, (lives)
    LD BC, SCORE_NR_TI_POS_D16
    CALL tx.PrintNum99
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE
