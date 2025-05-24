;----------------------------------------------------------;
;                     Jemtan Lives                         ;
;----------------------------------------------------------;
    MODULE jl

FACE_PAL                = $30
FACE_NORM_LEFT          = 192
FACE_NORM_STRAIGHT      = 193
FACE_NORM_RIGHT         = 194
FACE_RED_ADD            = 3                     ; Add this value to normal icon to get the same but in red
FACE_TI_POS_BYTE        = 16*2                  ; *2 because each tile takes 2 bytes
SCORE_NR_TI_POS         = 17
TI_RAM_START            = ti.TI_MAP_RAM_H5B00 + FACE_TI_POS_BYTE

RED_FACE_LIVES          = 3                     ; Show face when #lives < than this value
JET_POS_LEFT            = 100                   ; Face looks to the left, if Jetman postion is < 100
JET_POS_RIGHT           = 200                   ; Face looks to the right, if Jetman postion is > 100
lives                   DB 10

;----------------------------------------------------------;
;                        #LifeUp                           ;
;----------------------------------------------------------;
LifeUp

    LD A, (lives)
    INC A
    LD (lives), A
    CALL _UpdateJetLives

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       #LifeDown                          ;
;----------------------------------------------------------;
LifeDown

    LD A, (lives)
    DEC A
    LD (lives), A

    CP 0
    JR NZ, .keepPlaying
    CALL gc.GameOver
    RET
.keepPlaying

    CALL _UpdateJetLives

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     #SetupLivesBar                       ;
;----------------------------------------------------------;
SetupLivesBar

    CALL UpdateLifeFaceOnJetMove
    CALL _UpdateJetLives

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                #UpdateLifeFaceOnJetMove                  ;
;----------------------------------------------------------;
UpdateLifeFaceOnJetMove

    LD HL, TI_RAM_START

    LD DE, (jpo.jetX)
    LD A, E

    ; Is Jetman facing left?
    CP JET_POS_LEFT
    JR NC, .notLeft
    LD B, FACE_NORM_LEFT
    JR .loaded
.notLeft

    ; Is Jetman facing right?
    CP JET_POS_RIGHT
    JR C, .notRight
    LD B, FACE_NORM_RIGHT
    JR .loaded
.notRight
    ; Not right and not left, then straight
    LD B, FACE_NORM_STRAIGHT

.loaded

    ; Should icon face turn red because there are almost no lives left?
    LD A, (lives)
    CP RED_FACE_LIVES
    JR NC, .notRed
    LD A, FACE_RED_ADD
    ADD A, B 
    LD B, A
.notRed

    LD (HL), B                                  ; Set tile id
    INC HL
    LD (HL), FACE_PAL                           ; Set palette for tile
    INC HL

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                   #_UpdateJetLives                       ;
;----------------------------------------------------------;
_UpdateJetLives

    LD A, (lives)
    LD BC, SCORE_NR_TI_POS
    CALL tx.PrintNum99
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE
