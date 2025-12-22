/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                     Asteroids Shower                     ;
;----------------------------------------------------------;
    MODULE rot
    ; TO USE THIS MODULE: CALL dbs.SetupRocketBank

; Each asteroid sprite is a matrix built of single 16x16 sprites. For example, 3x2 (#spH=3, #spV=2). It has AS_FRAMES animation frames.
; Sprites are stored in 16K sprite files (asteroi_0.spr/asteroi_1.spr). Sprites are stored horizontally, one after another. 
; For example for the 3x2 we have following IDs:
;
; - animation frame 1:
;  0 1 2
;  3 4 5
;
; - animation frame 2:
;  6 7  8
;  9 10 11

AS_FRAMES               = 5                     ; Number of frames for asteroid sprite.
spV                     DB 3                    ; Number of 16x16 elemets building sprite in vertical position.
spH                     DB 3                    ; Number of 16x16 elemets building sprite in horizontal position
spSize                  DB 9                    ; Nuimber of 16x16 elemets building sprite.

; Sprite data for each active asteroid.
    STRUCT AS
SID                     DB                      ; Sprite ID for the first sprite element, the following IDs will be incremented from this one.
X                       DW
Y                       DB
FRAME                   DB
ACTIVE                  DB
    ENDS

AS_ACTIVE_YES           = 1
AS_ACTIVE_NO            = 1

asteroids
    ;   SID X   Y   FRAME ACTIVE
    AS {20, 50, 50, 0,    0}
    AS {30, 50, 50, 0,    0}
    AS {40, 50, 50, 0,    0}
ASTEROIDS               = 3

ANIM_DEPLAY             = 5
animDelayCnt            DB ANIM_DEPLAY

;----------------------------------------------------------;
;                    SetupAsteroids                        ;
;----------------------------------------------------------;
SetupAsteroids

    LD A, ANIM_DEPLAY
    LD (animDelayCnt), A

    LD IX, asteroids
    LD A, ASTEROIDS
    LD B, A
.asLoop
    ld a, $aa: nextreg 2,8
    PUSH BC
    LD A, (IX + AS.SID)

    ; ##########################################
    ; Setup unified relative sprires.
    ; There are 2 loops, H goes from 0 to #spH-1, L from 0 to #spV-1

    XOR A
    LD L, A
.vLoop

    XOR A
    LD H, A
.hLoop

    ; ##########################################
    ; Setup unified sprire based on current values from #spV and #spH

    ; Calculate X offset based on #spH (H).
    LD D, H
    LD E, _SPR_SIZE_D16
    MUL D, E
    LD C, E                                     ; C has X offset for the sprite.

    ; Calculate Y offset based on #spV (L).
    LD D, L
    LD E, _SPR_SIZE_D16
    MUL D, E                                    ; E has Y offset for the sprite.
    ; X = C, Y = E
    nextreg 2,8

    ; Anchor sprite is on X=0 and Y=0
    LD A, H
    OR L
    CP 0
    JR NZ, .notAnchorSprite

    ; ##########################################
    ; Setup sprites
    
    ; Setup anchor sprite
    NEXTREG _SPR_REG_NR_H34, A                  ; Set the sprite ID
    NEXTREG _SPR_REG_X_H35, 0                   ; Set X position
    NEXTREG _SPR_REG_Y_H36, 0                   ; Set Y position
    NEXTREG _SPR_REG_ATR2_H37, 0
    NEXTREG _SPR_REG_ATR3_H38, _SPR_ATTR3_HIDE
.notAnchorSprite

    ; Relative sprite
    NEXTREG _SPR_REG_ATR4_INC_H79, _SPR_ATR4_ANCHOR

    LD A, C
    NEXTREG _SPR_REG_X_H35, A                   ; Set X position

    LD A, E
    NEXTREG _SPR_REG_Y_H36, A                   ; Set Y position
    
    NEXTREG _SPR_REG_ATR2_H37, 0
    NEXTREG _SPR_REG_ATR3_H38, _SPR_ATTR3_HIDE_EXT

    NEXTREG _SPR_REG_ATR4_H39, _SPR_ATR4_RELATIVE

    ; ##########################################
    ; .hLoop iteration
    INC H
    LD A, (spH)
    CP H
    JR NZ, .hLoop

    ; .vLoop iteration
    INC L
    LD A, (spV)
    CP L
    JR NZ, .vLoop

    ; Move IX to next AS record.
    LD DE, AS
    ADD IX, DE

    ; Loop
    POP BC
    DJNZ .asLoop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  AnimateAsteroids                        ;
;----------------------------------------------------------;
AnimateAsteroids

    ; Delay amination.
    LD A, (animDelayCnt)
    DEC A
    LD (animDelayCnt), A
    CP 0
    RET NZ

    LD A, ANIM_DEPLAY
    LD (animDelayCnt), A

    ; ##########################################
    ; Play next animation frame.

    LD IX, asteroids
   ; CALL _NextFrame
    CALL _UpdateAsteroidSprite

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    _ShowAsteroid                         ;
;----------------------------------------------------------;
; Input:
;  - IX: Pointer to AS
;  - DE: X
;  - A:  Y
_ShowAsteroid

    LD (IX + AS.ACTIVE), AS_ACTIVE_YES
    LD (IX + AS.X), DE
    LD (IX + AS.Y), A


    ; ################################################

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 _NextAsteroidFrame                       ;
;----------------------------------------------------------;
; Input:
;  - IX: Pointer to AS
_NextAsteroidFrame


    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 _UpdateAsteroidSprite                    ;
;----------------------------------------------------------;
; Input:
;  - IX: Pointer to AS
_UpdateAsteroidSprite

    LD D, (IX + AS.SID)

    LD A, (spV)
    LD B, A
.vLoop
    PUSH BC

    LD A, (spH)
    LD B, A
.hLoop
    PUSH BC

    ; Inc sprite id
    LD A, D
    INC A
    LD D, A
    NEXTREG _SPR_REG_NR_H34, A                  ; Set the ID of the sprite for the following commands

    ; Set X postion as 9-bit value.
    LD BC, (IX + SPR.X)
    LD A, C                                     ; Set LSB from BC (X).
    NEXTREG _SPR_REG_X_H35, A

    ; Update the H37
    LD A, B                                     ; Set MSB from BC (X).
    AND _SPR_REG_ATR2_OVERFLOW                  ; Keep only an overflow bit.
    LD B, A                                     ; Backup A to B, as we need A.

    XOR A
    OR B                                        ; Apply B to set MSB from X.
    AND _SPR_REG_ATR2_RES_PAL                   ; Reset bits reserved for palette.
    NEXTREG _SPR_REG_ATR2_H37, A

    ; Set Y position.
    LD A, (IX + AS.Y)
    NEXTREG _SPR_REG_Y_H36, A                   ; Set Y position.

    POP BC
    DJNZ .hLoop

    POP BC
    DJNZ .vLoop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    _NextFrame                            ;
;----------------------------------------------------------;
; Input:
;  - IX: Pointer to AS
_NextFrame




    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE