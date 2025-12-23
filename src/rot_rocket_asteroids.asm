/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                     Asteroids Shower                     ;
;----------------------------------------------------------;
    MODULE rot
    ; TO USE THIS MODULE: CALL dbs.SetupRocketBank

; Each asteroid sprite is a matrix built of single 16x16 sprites. For example, 3x2 (#spH=3, #spV=2). It has AS_PATTERNS animation frames.
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

AS_PATTERNS             = 5                     ; Number of frames for asteroid sprite.
spV                     DB 3                    ; Number of 16x16 elemets building sprite in vertical position.
spH                     DB 3                    ; Number of 16x16 elemets building sprite in horizontal position
spSize                  DB 9                    ; Nuimber of 16x16 elemets building sprite.

; Sprite data for each active asteroid.
    STRUCT AS
SID                     DB                      ; Sprite ID for the first sprite element, the following IDs will be incremented from this one.
X                       DW
Y                       DB
PAT                     DB                      ; Current animation pattern, from 0 to AS_PATTERNS-1
ACTIVE                  DB
    ENDS

AS_ACTIVE_YES           = 1
AS_ACTIVE_NO            = 0

asteroids                                       ; Rocket has sprite ID 80-89
    ;   SID X   Y  PAT ACTIVE
    AS {00, 50, 0, 0,    0}
    AS {10, 0,  0, 0,    0}
    AS {20, 0,  0, 0,    0}
ASTEROIDS               = 1

DEPLY_DELAY             = 1
deplyDelay              DB DEPLY_DELAY

;----------------------------------------------------------;
;                    DeolyNextAsteroid                     ;
;----------------------------------------------------------;
DeolyNextAsteroid

    ; Find first not active asteroid.
    LD IX, asteroids
    LD B, ASTEROIDS
.asLoop
    LD A, (IX + AS.ACTIVE)
    CP AS_ACTIVE_NO
    JR Z, .foundAs

    LD DE, AS
    ADD IX, DE
    DJNZ .asLoop

    RET

.foundAs
    ; Deply asteroid given by IX
    LD (IX + AS.ACTIVE), AS_ACTIVE_YES
    LD (IX + AS.X), 100
    LD (IX + AS.Y), 0
    LD (IX + AS.PAT), 0

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      MoveAsteroids                       ;
;----------------------------------------------------------;
MoveAsteroids
/*
    ; Find first not active asteroid.
    LD IX, asteroids
    LD B, ASTEROIDS
.asLoop
    LD A, (IX + AS.ACTIVE)
    CP AS_ACTIVE_NO
    JR Z, .foundAs

    LD DE, AS
    ADD IX, DE
    DJNZ .asLoop

    RET

.foundAs
    ; ################################################
    ; Deply asteroid given by IX
    LD (IX + AS.ACTIVE), AS_ACTIVE_YES
    LD (IX + AS.PAT), 0
*/

    LD IX, asteroids

    LD A, (IX + AS.SID)
    NEXTREG _SPR_REG_NR_H34, A                  ; Set the sprite ID for the following commands.

    LD A, (IX + AS.Y)
    INC A
    LD (IX + AS.Y), A
    NEXTREG _SPR_REG_Y_H36, A                   ; Set Y position

    NEXTREG _SPR_REG_ATR4_H39, _SPR_ATR4_ANCHOR

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    SetupAsteroids                        ;
;----------------------------------------------------------;
SetupAsteroids

    LD IX, asteroids
    LD B, ASTEROIDS

.asLoop
    PUSH BC

    ; ##########################################
    ; Setup unified relative sprires.
    ; There are 2 loops, H goes from 0 to #spH-1, L from 0 to #spV-1

    XOR A
    LD L, A
.vLoop

    XOR A
    LD H, A
.hLoop

    ; Loop data:
    ; - H: counter from 0 to #spH-1.
    ; - L: counter from 0 to #spV-1.
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
    ; X-pos = C, Y-pos = E

    ; Anchor sprite is on X=0 and Y=0
    LD A, H
    OR L
    CP 0
    JR NZ, .notAnchor

    ; ##########################################
    ; Setup sprites

    ; Setup anchor sprite
    LD A, (IX + AS.SID)
    NEXTREG _SPR_REG_NR_H34, A                  ; Set the sprite ID
    NEXTREG _SPR_REG_X_H35, 100                   ; Set X position
    NEXTREG _SPR_REG_Y_H36, 0                   ; Set Y position
    NEXTREG _SPR_REG_ATR2_H37, 0
    NEXTREG _SPR_REG_ATR3_H38, _SPR_ATTR3_HIDE_EXT

    NEXTREG _SPR_REG_ATR4_H39, _SPR_ATR4_ANCHOR
    JR .hLoopEnd
.notAnchor

    ; Relative sprite ($79 will increase sprite id)
    NEXTREG _SPR_REG_ATR4_INC_H79, _SPR_ATR4_RELATIVE

    LD A, C
    NEXTREG _SPR_REG_X_H35, A                   ; Set X position

    LD A, E
    NEXTREG _SPR_REG_Y_H36, A                   ; Set Y position
    NEXTREG _SPR_REG_ATR2_H37, 0
    NEXTREG _SPR_REG_ATR3_H38, _SPR_ATTR3_SHOW_EXT
    NEXTREG _SPR_REG_ATR4_H39, _SPR_ATR4_RELATIVE

    ; ##########################################
    ; .hLoop iteration
.hLoopEnd
    INC H
    LD A, (spH)
    CP H
    JR NZ, .hLoop

    ; .vLoop iteration
    INC L
    LD A, (spV)
    CP L
    JR NZ, .vLoop

    ; Loop, move IX to next AS record.
    LD DE, AS
    ADD IX, DE
    POP BC
    DJNZ .asLoop

    CALL AnimateAsteroids

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  AnimateAsteroids                        ;
;----------------------------------------------------------;
AnimateAsteroids

    LD IX, asteroids
    LD B, ASTEROIDS

.asLoop
    PUSH BC

    ; Play next animation frame.
    LD IX, asteroids

    ; Load next animation pattern into H. For #spSize = 9, H should have following values: 0, 9, 18, 27, 36
    LD A, (IX + AS.PAT)
    INC A
    CP AS_PATTERNS
    JR NZ, .afterFrameNumber
    XOR A
.afterFrameNumber
    LD (IX + AS.PAT), A

    LD D, A
    LD A, (spSize)
    PUSH AF
    LD E, A
    MUL D, E
    LD H, E
    POP AF

    ; Loop counters, A already contains #spSize.
    LD C, A
    LD B, 0

    ; Sprite ID.
    LD A, (IX + AS.SID)
    LD L, A
.patternLoop                                    ; Loop runds from B to C-1 -> from 0 to #spSize-1

    ; Loop data:
    ;  - H: current animation pattern.
    ;  - L: current sprite ID, increases with each loop.
    ;  - B: counter going from 0 to #spSize-1.
    ;  - C: keeps #spSize to improve performance.

    ; Set the sprite ID.
    LD A, L
    NEXTREG _SPR_REG_NR_H34, A

    ; Set animation pattern and flags
    LD A, _SPR_ATTR3_SHOW_EXT
    OR H
    NEXTREG _SPR_REG_ATR3_H38, A

    ; Loop logic
    INC H                                       ; Next animation pattern.
    INC B                                       ; Next loop iteration.
    INC L                                       ; Next sprite ID.
    LD A, B
    CP C
    JR NZ, .patternLoop

    ; Loop, move IX to next AS record.
    LD DE, AS
    ADD IX, DE
    POP BC
    DJNZ .asLoop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE