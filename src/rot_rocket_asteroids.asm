/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                     Asteroids Shower                     ;
;----------------------------------------------------------;
    MODULE rot
    ; TO USE THIS MODULE: CALL dbs.SetupRocketBank

; Asteroid sprite takes almost a complete 16K sprite file (asteroi_0.spr/asteroi_1.spr). Each asteroid sprite is a matrix of 3x3 sprites 
; (a composite sprite with an anchor). A single animation frame (pattern) occupies 6 slots (3*2=6) in the sprite file. 
; Each asteroid has 5 animation patterns. For an asteroid of size 3x2 requires 30 (3*2*5) slots in the sprite file. 
; Patterns are stored horizontally, one after another. For example, for the 3x2, we have the following IDs:
;
; - animation pattern 1:
;  0 1 2
;  3 4 5
;
; - animation pattern 2:
;  6 7  8
;  9 10 11

AS_PATTERNS             = 5                     ; Number of frames for asteroid sprite.
AS_SIZE                 = 3                     ; Number of 16x16 elemets building sprite in vertical/horizontal position (3x3).
spSize                  DB 9                    ; Nuimber of 16x16 elemets building sprite.

; Sprite data for each active asteroid.
    STRUCT AS
SID                     DB                      ; Sprite ID for the first sprite element, the following IDs will be incremented from this one.
X                       DW
Y                       DB
PAT                     DB                      ; Current animation pattern, from 0 to AS_PATTERNS-1
MOVE_SPD                DB                      ; Number of game loops to skip.
MOVE_PAT                DB                      ; MP1, MP2 or MP3
ACTIVE                  DB
    ENDS

; This structure will be copied over AS  (only matching keys) when a particular asteroid is deployed. 
    STRUCT ASD
X                       DW
Y                       DB
MOVE_SPD                DB                      ; Number of game loops to skip.
MOVE_PAT                DB                      ; MP1, MP2 or MP3
ACTIVE                  DB                      ; True if has been alrady deplyed
    ENDS

AS_ACTIVE_YES           = 1
AS_ACTIVE_NO            = 0

MP1                     = 1                     ; Increment Y
MP2                     = 2                     ; Increment Y,  decrement X

asteroids                                       ; Rocket has sprite ID 80-89
;       SID  X  Y  PAT MOVE_SPD MOVE_PAT ACTIVE
    AS {00,  0, 0, 0,  0,       0,       0}
    AS {10,  0, 0, 0,  0,       0,       0}
    AS {20,  0, 0, 0,  0,       0,       0}
    AS {30,  0, 0, 0,  0,       0,       0}
    AS {40,  0, 0, 0,  0,       0,       0}
    AS {50,  0, 0, 0,  0,       0,       0}
    AS {60,  0, 0, 0,  0,       0,       0}
    AS {70,  0, 0, 0,  0,       0,       0}

asDeployAddr            DW 0                    ; Pointer to #ASD array, must contain 7 elements.
AS_DEPLOY_SIZE          = 7

; This list is used to adjust asteroid's speeds over time. It contains pairs, let's call the elements in each pair A and B. For example: 
; "A,B, A,B, ... A,B". A loop runs every few seconds, each iteration takes the next AB pair from this list and applies it to the element 
; from ASD list. A gives an index in the ASD list (starts from 0), and B is the applied value. B will be added or subtracted 
; from ASD.MOVE_SPD. In the latter case,bit 7 has to be set. B has a value from -127 to +127 (x|$80), but reasonable values are +/-5.
randMovAddr             DW 0
randMovPos              DB 0
RAND_MOVE_SIZE_D30      = 30                    ; 30 elements, 60 bytes.
RAND_MOVE_EL_D2         = 2
RAND_SIGN_BIT_D7        = 7

COL_MARGIN_Y_D30        = 30
COL_ADD_Y_N25           = -25
COL_MARGIN_X_D20        = 20
COL_ADD_X_N17           = -17

;----------------------------------------------------------;
;                CheckRocketCollision                      ;
;----------------------------------------------------------;
CheckRocketCollision

    LD IX, asteroids
    LD B, AS_DEPLOY_SIZE

.asLoop

    ; ##########################################
    ; Check Y collision.
    LD A, (ro.rocY)                             ; Y of the rocket.
    ADD COL_ADD_Y_N25
    LD C, (IX + AS.Y)                           ; Y of the asteroid.

    ; Is rocket above or below the asteroid?
    LD E, COL_MARGIN_Y_D30
    CP C
    JR C, .above                                ; Jump if roc-y < asteroid-y

    ; Rocket is below the asteroid.
    SUB C
    CP E
    JR C, .collisionOnY                            ; Jump if A - C < E (the distance between the rocket and the asteroid is smaller than the margin)
    JR .asLoopNext

    ; Rocket is above the asteroid.
.above

    ; Swap A and C to avoid negative value
    LD D, A
    LD A, C
    LD C, D
    SUB C
    
    CP E
    JR C, .collisionOnY
    JR .asLoopNext

.collisionOnY
    ; ##########################################
    ; We have collision on Y, not check X.

    LD DE, (ro.rocX)                             ; X of the rocket.
    ADD DE, COL_ADD_X_N17
    LD HL, (IX + AS.X)                           ; X of the asteroid.

    ; Check whether the rocket is horizontal with the asteroid.
    SBC HL, DE
    CALL ut.AbsHL                               ; HL contains a positive distance between the enemy and Jetman.
    LD A, H
    CP 0
    JR Z, .keepCheckingX

    ; HL > 256  -> no collision.
    JR .asLoopNext

.keepCheckingX
    LD A, L
    LD B, COL_MARGIN_X_D20
    CP B
    JR C, .collisionFound

.asLoopNext
    ; ##########################################
    ; Asteroid loop logic.

    ; Move IX to next AS record.
    LD DE, AS
    ADD IX, DE
    DJNZ .asLoop
    RET

.collisionFound

    CALL gc.RocketHitsAsteroid

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     SetupAsteroids                       ;
;----------------------------------------------------------;
; Remember to set #spH and #spV
; Input:
; - DE: pointer to be sotred in #asDeployAddr
; - HL: pointer to be sotred in #randMovAddr
SetupAsteroids

    LD (asDeployAddr), DE
    LD (randMovAddr), HL

    XOR A
    LD (randMovPos), A

    ; ##########################################
    ; Reset asteroid data.
    LD IX, asteroids
    LD IY, DE
    LD B, AS_DEPLOY_SIZE
.asLoop

    LD (IX + AS.ACTIVE), AS_ACTIVE_NO
    LD (IY + ASD.ACTIVE), AS_ACTIVE_NO
    
    ; ##########################################
    ; Loop logic.
    LD DE, ASD
    ADD IY, DE

    LD DE, AS
    ADD IX, DE

    DJNZ .asLoop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  ChangeAsteroidSpeed                     ;
;----------------------------------------------------------;
ChangeAsteroidSpeed

    ; HL will point to #randMov based on #randMovPos
    LD A, (randMovPos)
    LD D, A
    LD E, RAND_MOVE_EL_D2
    MUL D, E
    LD HL, (randMovAddr)
    ADD HL, DE

    ; Load current #randMov into BC.
    LD B, (HL)
    INC HL
    LD C, (HL)

    ; IX will point to ASD given by offset from B.
    LD HL, asteroids
    LD D, B
    LD E, AS
    MUL D, E
    ADD HL, DE
    LD IX, HL

    ;  Add or subtract from AS.MOVE_SPD the value in C.
    LD A, (IX + AS.MOVE_SPD)

    BIT RAND_SIGN_BIT_D7, C
    JR NZ, .sub
    ADD C
    JR .afterMath
.sub
    RES RAND_SIGN_BIT_D7, C
    SUB C
    JP P, .afterMath                            ; Jump if A-C >= 0
    XOR A                                       ; Sub was negative, reset A to 1.
.afterMath

    LD (IX + AS.MOVE_SPD), A

    ; ##########################################
    ; Move the index to the next record, or reset it to the first one.
    LD A, (randMovPos)
    INC A
    CP RAND_MOVE_SIZE_D30
    JR NZ, .afterPosReset
    XOR A
.afterPosReset
    LD (randMovPos), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   DeployNextAsteroid                     ;
;----------------------------------------------------------;
DeployNextAsteroid

    LD IX, asteroids
    LD IY, (asDeployAddr)

    ; ##########################################
    ; We are looking for inactive asteroid to deploy.
    LD B, AS_DEPLOY_SIZE
.asLoop
    LD A, (IY + ASD.ACTIVE)

    CP AS_ACTIVE_NO
    JR Z, .foundAs

    LD DE, AS
    ADD IX, DE

    LD DE, ASD
    ADD IY, DE

    DJNZ .asLoop

    RET
.foundAs

    ; ##########################################
    ; Deploy the asteroid given by IX, but first copy the initial data from the template provided by IY.

    LD (IY + ASD.ACTIVE), AS_ACTIVE_YES
    LD (IX + AS.ACTIVE), AS_ACTIVE_YES

    LD HL, (IY + ASD.X)
    LD (IX + AS.X), HL

    LD A, (IY + ASD.Y)
    LD (IX + AS.Y), A

    LD A, (IY + ASD.MOVE_SPD)
    LD (IX + AS.MOVE_SPD), A

    LD A, (IY + ASD.MOVE_PAT)
    LD (IX + AS.MOVE_PAT), A

    ; ##########################################
    ; Set up the asteroid's sprite.
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
    ; - IX: points to AS.
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

    LD A, (IX + AS.X)
    NEXTREG _SPR_REG_X_H35, A                   ; Set X position

    LD A, (IX + AS.Y)
    NEXTREG _SPR_REG_Y_H36, A                   ; Set Y position
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
    LD A, AS_SIZE
    CP H
    JR NZ, .hLoop

    ; .vLoop iteration
    INC L
    LD A, AS_SIZE
    CP L
    JR NZ, .vLoop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      MoveAsteroids                       ;
;----------------------------------------------------------;
MoveAsteroids

    LD IX, asteroids
    LD B, AS_DEPLOY_SIZE

.asLoop
    PUSH BC

    ; ##########################################
    ; Is asteroid active?
    LD A, (IX + AS.ACTIVE)
    CP AS_ACTIVE_YES
    JR NZ, .asLoopNext

.afterDelCnt
    ; ##########################################
    LD A, (IX + AS.SID)
    NEXTREG _SPR_REG_NR_H34, A                  ; Set the sprite ID for the following commands.

    ; Increment Y based on the defined speed.
    LD A, (IX + AS.MOVE_SPD)
    CP 0
    JR Z, .asLoopNext
    LD B, (IX + AS.Y)
    ADD A, B
    LD (IX + AS.Y), A
    NEXTREG _SPR_REG_Y_H36, A                   ; Set Y position

    ; DEC X based on the defined speed and only if it's enabled.
    LD A, (IX + AS.MOVE_PAT)
    CP MP2
    JR NZ, .afterX

    LD BC, (IX + AS.X)
    DEC BC
    LD (IX + AS.X), BC
    LD A, C
    NEXTREG _SPR_REG_X_H35, A

    ; Set overflow bit from X position.
    LD A, B                                     ; Load MSB from X into A.
    AND _OVERFLOW_BIT                           ; Keep only an overflow bit.
    NEXTREG _SPR_REG_ATR2_H37, A
.afterX

    NEXTREG _SPR_REG_ATR4_H39, _SPR_ATR4_ANCHOR

.asLoopNext
    ; ##########################################
    ; Asteroid loop logic.
    
    ; Move IX to next AS record.
    LD DE, AS
    ADD IX, DE
    POP BC
    DJNZ .asLoop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  AnimateAsteroids                        ;
;----------------------------------------------------------;
AnimateAsteroids

    LD IX, asteroids
    LD B, AS_DEPLOY_SIZE

.asLoop
    PUSH BC

    ; ##########################################
    ; Is asteroid active?
    LD A, (IX + AS.ACTIVE)
    CP AS_ACTIVE_YES
    JR NZ, .asLoopNext

    ; ##########################################
    ; Play next animation frame.

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

    ; ##########################################
    ; Patern loop logic.
    INC H                                       ; Next animation pattern.
    INC B                                       ; Next loop iteration.
    INC L                                       ; Next sprite ID.
    LD A, B
    CP C
    JR NZ, .patternLoop

.asLoopNext
    ; ##########################################
    ; Asteroid loop logic.
    
    ; Move IX to next AS record.
    LD DE, AS
    ADD IX, DE
    POP BC
    DJNZ .asLoop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE