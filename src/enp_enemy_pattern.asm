/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;       Single Enemy and Formation (Pattern Enemy)         ;
;----------------------------------------------------------;
    MODULE enp

    ; ### TO USE THIS MODULE: CALL dbs.SetupPatternEnemyBank ###

; Enemies fly by a given hardcoded pattern. This file contains generic logic for such enemies 
; In general, there are two kinds of enemies: 
; - single enemies that fly independently from each other (es_enemy_single.asm), and 
; - pattern enemies that fly together (ep_enemy_pattern.asm)

; SEE ALSO _constants.asm -> #ENP and #ENPS

; Each enemy has a dedicated behavior given by #ENP. #ENP contains a few bytes configuring the enemy's behavior. Others are set during runtime. 
; The game has a maximum of 20 enemies (#spriteEx01 - #spriteEx020) that can be active in a game. #ENP is a generic structure configuring 
; enemies and has to be configured for each level so that we have different enemies. To have this ability to configure it per level, 
; there is another structure, #ENPS - this structure has elements with the same name as #ENP (but not all, only those that we can configure). 
; Before the level starts, values from ENPS are directly copied to ENP, and enemies for this level are configured and ready to go.
; Enemies can move according to the different movement patterns given by #ENP.MOVE_PAT_POINTER. After they are destroyed, the next 
; deployment is delayed by #ENP.RESPAWN_DELAY. #ENP.SDB_INIT gives Sprite animation. #ENP.RESPAWN_Y determines the horizontal respawn position.
; #ENP.SETUP (see #ENP_S_BIT_XXX) decides whether the enemy is deployed on the right or left side of the screen and whether it should hit 
; a platform, fly along it, or bounce from it.

; Values for #ENP.SETUP
ENP_S_BIT_ALONG_D0      = 0                     ; 1 - avoid platforms by flying along them, 0 - hit platform.
ENP_S_BIT_DEPLOY_D1     = 1                     ; 1 - deploy enemy on the left, 0 - on the right.
ENP_S_BIT_BOUNCE_D2     = 2                     ; 1 - bounce from platforms, if set #ENP_S_BIT_ALONG_D0 is ignored, 0 - disabled.
ENP_S_BIT_BOUNCE_AN_D3  = 3                     ; 1 - enable extra bouncing animation (sprites 34,35,36).
ENP_S_BIT_REVERSE_Y_D7  = 7                     ; 1 - reverses bit #ENP_S_BIT_DEPLOY_D1, set during runtime when enemy hits platform from L/R.

ENP_S_LEFT_ALONG        = %0000'0'0'1'1 
ENP_S_RIGHT_ALONG       = %0000'0'0'0'1 

ENP_S_LEFT_HIT          = %0000'0'0'1'0 
ENP_S_RIGHT_HIT         = %0000'0'0'0'0 

ENP_S_LEFT_BOUNCE       = %0000'0'1'1'0 
ENP_S_RIGHT_BOUNCE      = %0000'0'1'0'0 

ENP_S_LEFT_BOUNCE_AN    = %0000'1'1'1'0         ; Deploy left, bounce, animate bounce effect.
ENP_S_RIGHT_BOUNCE_AN   = %0000'1'1'0'0 

ENP_S_REVERSE_Y         = %1'0000000 

MOVE_DELAY_CNT_INC      = %0001'0000 

RESPAWN_OFF_D255        = 255

; The move pattern is stored as a byte array. The first byte in this array holds the size in bytes of the whole pattern. 
; Each pattern step takes 2 bytes so that the size will be 24 for movement consisting of 12 patterns.
; The byte indicating size is being followed by move patterns, each of which consists of two bytes: the first for the pattern itself 
; (pattern step) and the second for the movement delay (bits 8-5) and the number of times it should be repeated (bits 4-0).

; To illustrate, if the first byte is set to 5,  the move pattern will span a total of 11 bytes: 11 = 1 + 5 * 2, or:
; [number of patterns],[[step],[delay/repetition],[[step],[delay/repetition],...,[[step],[delay/repetition]].
;
; Each pattern step contains the number of pixels to move along the X axis (left or right) and the number of pixels to move along Y axis 
; (up or down).
;
; The sprite travels only one pixel in each direction during each animation loop. If possible, it travels in both directions 
; (increasing X and Y by one). If the number of pixels in a particular direction has been reached, it will continue vertically or horizontally. 
;
; Bits of the single step:
; 0-2:  Number of pixels to move along X axis
; 3:    #MOVE_PAT_X_TOD_DIR_B_D3
; 4-6:  Number of pixels to move on Y axis
; 7:    #MOVE_PAT_Y_TOD_DIR_B_D7
; 
; Example: for a move pattern: "%0'011'1'101, 10" the sprite will move 5 pixels on the X axis, 3 pixel on the Y axis,
; and it will be repeated 10 times. In total sprite will travel: 5*10 pixels on X and 3*10 pixels on Y. 
; Below we have single step that will be repeated 10x.
; 1) INC X, DEC Y:  %0'000'1'000
; 2) INC X, DEC Y:  %0'001'1'001
; 3) INC X, DEC Y:  %0'010'1'010
; 4) _    , DEC Y:  %0'011'1'011
; 5) _,     DEC Y:  %0'011'1'100
; 6) _,     DEC Y:  %0'011'1'101
; In this example, both counters count up, and hoverer X position is increment (move right), and Y is decrement (move up).

MOVE_PAT_X_MASK         = %0'000'0'111 
MOVE_PAT_X_ADD          = %0'000'0'001 

; Determines whether X should be incremented (1 - move right) or decremented (0 - move left) in each iteration. It's under the assumption,
; that deployment takes place on the left side of the screen. Values will be automatically inverted if it's on the right side of the screen.
MOVE_PAT_X_TOD_DIR_B_D3 = 3
MOVE_PAT_X_TOD_DIR_MASK = %0'000'1'000 

MOVE_PAT_Y_MASK         = %0'111'0'000 
MOVE_PAT_Y_ADD          = %0'001'0'000 

MOVE_PAT_Y_TOD_DIR_MASK = %1'000'0'000 

; Determines whether Y should be decremented (0 - move up) or incremented (1 - move down) in each iteration.
MOVE_PAT_Y_TOD_DIR_B_D7 = 7

MOVE_PAT_XY_MASK        = %0'111'0'111 
MOVE_PAT_XY_MASK_RES    = %1'000'1'000 

MOVE_STEP_SIZE_D2       = 2                     ; Each move step in the pattern takes two bytes: pattern and delay/number of repeats.
MOVE_STEP_CNT_OFF_D1    = 1
MOVE_PAT_STEP_OFFSET_D1 = 1                     ; Data for move pattern starts at byte 1, byte 0 provides size.
MOVE_PAT_REPEAT_MASK    = %0000'1111 
MOVE_PAT_DELAY_MASK     = %1111'0000 

MOVE_DELAY_3X           = %0000'0000            ; Delay 0 moves the enemy by 3 pixels during a single frame
MOVE_DELAY_2X           = %0001'0000            ; Delay 1 moves the enemy by 2 pixels during a single frame
DEC_MOVE_DELAY          = %0001'0000 

MOVEX_SETUP             = %000'0'0000           ; Input mask for MoveX. Move the sprite by one pixel and roll over on the screen end.

BOUNCE_H_MARG_D3        = 3


;----------------------------------------------------------;
;----------------------------------------------------------;
;                     PRIVATE MACROS                       ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                  _LoadCurrentMoveStep                    ;
;----------------------------------------------------------;
; Load HL that points to the current move pattern
; Input
;  - IY: pointer to #ENP for current sprite
; Return:
;  - HL: points to the current move pattern
; Modifies: A
    MACRO _LoadCurrentMoveStep

    LD HL, (IY + ENP.MOVE_PAT_POINTER)          ; HL points to start of the #movePattern
    LD A, (IY + ENP.MOVE_PAT_POS)
    ADD HL, A                                   ; Move HL from the beginning of the move pattern to current element

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                      _LoadMoveDelay                      ;
;----------------------------------------------------------;
; Input
;  - IY: pointer to #ENP holding data for single sprite.
; Return:
;  - A: value of move delay counter for this pattern (bits 8-5).
; Modifies: A, HL
    MACRO _LoadMoveDelay

    _LoadCurrentMoveStep
    INC HL
    LD A, (HL)                                  ; Load the delay/repetition counter into A, reset all bits but delay.
    AND MOVE_PAT_DELAY_MASK

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PUBLIC FUNCTIONS                       ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                    CopyEnpsToEnp                         ;
;----------------------------------------------------------;
; Input:
;   - IX: pointer to #ENPS array
;   - IY: pointer to #ENP array
CopyEnpsToEnp

    LD A, (IX + ENPS.RESPAWN_Y)
    LD (IY + ENP.RESPAWN_Y), A

    LD A, (IX + ENPS.SETUP)
    LD (IY + ENP.SETUP), A

    LD A, (IX + ENPS.RESPAWN_DELAY)
    LD (IY + ENP.RESPAWN_DELAY), A

    LD DE, (IX + ENPS.MOVE_PAT_POINTER)
    LD (IY + ENP.MOVE_PAT_POINTER), DE

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ResetEnp                           ;
;----------------------------------------------------------;
; Input:
;   - IY: pointer to #ENP array
ResetEnp

    XOR A
    LD (IY + ENP.MOVE_DELAY_CNT), A
    LD (IY + ENP.MOVE_PAT_STEP), A
    LD (IY + ENP.MOVE_PAT_STEP_RCNT), A
    LD (IY + ENP.RESPAWN_DELAY_CNT), A

    LD A, RESPAWN_OFF_D255
    LD (IY + ENP.RESPAWN_DELAY), A

    LD A, MOVE_PAT_STEP_OFFSET_D1
    LD (IY + ENP.MOVE_PAT_POS), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   ResetPatternEnemies                    ;
;----------------------------------------------------------;
; Resets #SPR and linked #ENP
; Input:
;  - IX: pointer to the #SPR array.
;  - B:  size of the #SPR and #ENP array (both will be modified).
ResetPatternEnemies

.enemyLoop
    CALL sr.ResetSprite

    ; Load extra data for this sprite to IY.
    LD DE, (IX + SPR.EXT_DATA_POINTER)
    LD IY, DE

    CALL ResetEnp

    LD A, MOVE_PAT_STEP_OFFSET_D1
    LD (IY + ENP.MOVE_PAT_POS), A

    ; ##########################################
    ; Next sprite
    LD DE, IX
    ADD DE, SPR
    LD IX, DE
    DJNZ .enemyLoop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  MovePatternEnemies                      ;
;----------------------------------------------------------;
; Input:
;  - IX: pointer to array #SPR.
;  - B:  number of elements in array given by IX.
; Moves single enemies and those in formation.
; Modifies: ALL
MovePatternEnemies

    ; ##########################################
    ; Loop ever all enemies skipping hidden 
.enemyLoop
    PUSH BC                                     ; Preserve B for loop counter.

    ; Ignore this sprite if it's hidden.
    LD A, (IX + SPR.STATE)
    AND sr.SPRITE_ST_VISIBLE                    ; Reset all bits but visibility.
    OR A                                        ; Same as CP 0, but faster.
    JR Z, .continue                             ; Jump if visibility is not set (sprite is hidden).

    ; Load extra data for this sprite to IY.
    LD BC, (IX + SPR.EXT_DATA_POINTER)
    LD IY, BC

    ; Slow down movement by decrementing the counter until it reaches 0.
    LD A, (IY + ENP.MOVE_DELAY_CNT)
    OR A                                        ; No delay? -> move at full speed.
    JR Z, .afterMoveDelay

    ; Delaying movement, decrement delay counter.
    SUB MOVE_DELAY_CNT_INC
    LD (IY + ENP.MOVE_DELAY_CNT), A

    OR A                                        ; Same as CP 0, but faster.
    JR NZ, .continue                            ; Skip enemy if the delay counter > 0.

    _LoadMoveDelay
    LD (IY + ENP.MOVE_DELAY_CNT), A             ; Reset counter, A has the max value of delay counter.

.afterMoveDelay

    ; ##########################################
    ; Sprite is visible, move it!
    PUSH IY
    CALL _MoveEnemy
    POP IY
/*
    ; Tripple movement speed if move delay is 0.
    _LoadMoveDelay
    CP MOVE_DELAY_3X
    JR NZ, .after3x
    PUSH IY
    CALL _MoveEnemy
    POP IY
    CALL _MoveEnemy
    JR .continue
.after3x

    ; Double movement speed if move delay is 1.
    CP MOVE_DELAY_2X
    JR NZ, .continue
    CALL _MoveEnemy
*/
.continue
    ; ##########################################
    ; Move IX to the beginning of the next #SPR.
    LD DE, SPR
    ADD IX, DE

    ; ##########################################
    POP BC
    DJNZ .enemyLoop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 RespawnPatternEnemy                      ;
;----------------------------------------------------------;
; Respawn single or formation
; Input:
;  - IX: pointer to #SPR holding data for single enemy.
; Return:
;  - YES: Z is reset (JP Z).
;  - NO:  Z is set (JP NZ).

; Modifies: all
RespawnPatternEnemy

    BIT sr.SPRITE_ST_VISIBLE_BIT, (IX + SPR.STATE)
    JR Z, .afterVisibilityCheck                 ; Skip this sprite if it's already visible.

    _NO
    RET
.afterVisibilityCheck
    ; Sprite is hidden, check the dedicated delay before respawning.

    ; Load extra sprite data (#ENP) to IY
    LD BC, (IX + SPR.EXT_DATA_POINTER)
    LD IY, BC
    
    ; There are two respawn delay timers. The first is global (#respawnDelayCnt) and ensures that multiple enemies do not respawn at the 
    ; same time. The second timer can be configured for a single enemy, which further delays its comeback. Keep in mind, that
    ; #respawnDelayCnt applies only to single enemies and not to formation.
    LD A, (IY + ENP.RESPAWN_DELAY)

    ; Enemy disabled?
    CP RESPAWN_OFF_D255
    JR NZ, .respawnOn

    _NO
    RET
.respawnOn

    OR A                                        ; Same as CP 0, but faster.
    JR Z, .afterEnemyRespawnDelay               ; Jump if there is no extra delay for this enemy.

    LD B, A
    LD A, (IY + ENP.RESPAWN_DELAY_CNT)
    INC A
    CP B
    JR Z, .afterEnemyRespawnDelay               ; Jump if the timer reaches respawn delay.

    LD (IY + ENP.RESPAWN_DELAY_CNT), A          ; The delay timer for the enemy is still ticking.

    _NO
    RET
.afterEnemyRespawnDelay

    ; ##########################################
    ; Respawn enemy, first mark it as visible.
    LD A, (IX + SPR.STATE)
    CALL sr.SetStateVisible

    ; Reset counters and move pattern.
    LD (IY + ENP.RESPAWN_DELAY_CNT), 0

    ; Reset reverse
    RES ENP_S_BIT_REVERSE_Y_D7, (IY + ENP.SETUP)

    _LoadMoveDelay
    CALL _SetDelayCnt
    CALL _RestartMovePattern

    ; Set Y (horizontal respawn)
    LD A,  (IY + ENP.RESPAWN_Y)
    LD (IX + SPR.Y), A

    ; Set X to left or right side of the screen.
    BIT ENP_S_BIT_DEPLOY_D1, (IY + ENP.SETUP)
    JR NZ, .deployLeft                          ; Jump if bit is 0 -> deploy left.

    ; Deploy right
    LD BC, _GSC_X_MAX_D315
    SET sr.SPRITE_ST_MIRROR_X_BIT, (IX + SPR.STATE)  ; Mirror sprite, because it deploys on the right and moves to the left side.
    JR .afterLR

    ; Deploy left
.deployLeft
    RES sr.SPRITE_ST_MIRROR_X_BIT, (IX + SPR.STATE)  ; Do not mirror sprite (this could be set if in another level it was moving right).
    LD BC, _GSC_X_MIN_D0

.afterLR
    LD (IX + SPR.X), BC
    sr.SetSpriteId
    CALL sr.ShowSprite

    _YES

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                      _FlipReverseY                       ;
;----------------------------------------------------------;
_FlipReverseY

    LD A, (IY + ENP.SETUP)
    XOR ENP_S_REVERSE_Y
    LD (IY + ENP.SETUP), A

    LD A, sr.SDB_BOUNCE_TOP
    CALL _PlayBounceAnimation

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 _PlayBounceAnimation                     ;
;----------------------------------------------------------;
; Input:
;  - A: hit side sr.SDB_BOUNCE_SIDE or sr.SDB_BOUNCE_TOP
_PlayBounceAnimation

    BIT ENP_S_BIT_BOUNCE_AN_D3, (IY + ENP.SETUP)
    RET Z

    PUSH BC, HL
    CALL sr.LoadSpritePattern
    POP HL, BC

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     _MoveEnemyX                          ;
;----------------------------------------------------------;
; Move enemy one step left or right.
; Input
;  - IX: pointer to #SPR.
;  - IY: pointer to #ENP.
;  - HL: points to the current move pattern.
; Modifies: A, BC
_MoveEnemyX

    LD D, MOVEX_SETUP                           ; D contains configuration for MoveX.
    BIT ENP_S_BIT_DEPLOY_D1, (IY + ENP.SETUP)
    JR NZ, .deployedLeft                        ; Jump if bit is 0 -> deploy left.

.deployRight
    ; Enemy was deployed on the right, invert #MOVE_PAT_X_TOD_DIR_B_D3.
    BIT MOVE_PAT_X_TOD_DIR_B_D3, (HL)
    JR NZ, .moveLeft                            ; Jump if bit is set to 1 (right), invert right -> left.
    JR .moveRight                               ; Bit is 0 -> move left.

.deployedLeft
    ; Enemy was deployed on the left, do not invert #MOVE_PAT_X_TOD_DIR_B_D3.
    BIT MOVE_PAT_X_TOD_DIR_B_D3, (HL)
    JR NZ, .moveRight                           ; Jump if bit is set to 1 (right).
    JR .moveLeft                                ; Bit is 0 -> move left.

    ; ##########################################
    ; Move right
.moveRight

    ; Reverse bit not set, now really move right.
    LD D, sr.MVX_IN_D_1PX_ROL
    SET sr.MVX_IN_D_TOD_DIR_BIT, D
    PUSH HL
    CALL sr.MoveX
    POP HL
    RET

    ; ##########################################
    ; Move left
.moveLeft

    ; Reverse bit not set, now really move left.
    LD D, sr.MVX_IN_D_1PX_ROL
    RES sr.MVX_IN_D_TOD_DIR_BIT, D
    PUSH HL
    CALL sr.MoveX
    POP HL

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       _MoveEnemy                         ;
;----------------------------------------------------------;
; Input
;  - IX: pointer to #SPR holding data for single sprite that will be moved
_MoveEnemy

    ; Set sprite ID in hardware
    sr.SetSpriteId

    ; Load #ENP for this sprite to IY
    LD BC, (IX + SPR.EXT_DATA_POINTER)
    LD IY, BC
    _LoadCurrentMoveStep

    ; Current register values:
    ;  - IX: pointer to #SPR for current sprite
    ;  - IY: pointer to #ENP for current sprite
    ;  - HL: pointer to current position in #movePattern

    ; ##########################################
    ; Is enemy alive?
    BIT sr.SPRITE_ST_ACTIVE_BIT, (IX + SPR.STATE)
    JR NZ, .afterAliveCheck                     ; Jump if sprite is alive

    ; Sprite is not alive -> move it horizontally while it's exploding
    CALL _MoveEnemyX
    CALL sr.UpdateSpritePosition                ; Move sprite to new X,Y coordinates

    RET                                         ; Return - enemy is exploding
.afterAliveCheck

    ; ##########################################
    ; Should enemy bounce of the platform?
    BIT ENP_S_BIT_BOUNCE_D2, (IY + ENP.SETUP)
    JR Z, .afterBounceSetup                        ; Jump if bounce is not set

    ; Check the collision with the platform
    PUSH IX, IY, HL
    LD HL, IX
    ADD HL, SPR.X

    CALL pl.PlatformBounceOff
    POP HL, IY, IX

    OR A                                            ; Same as CP pl.PL_DHIT_NO_D0
    JR Z, .afterBounceSetup

    CP pl.PL_DHIT_LEFT_D1
    JR Z, .bounceL

    CP pl.PL_DHIT_RIGHT_D2
    JR Z, .bounceR

    CP pl.PL_DHIT_TOP_D3
    JR Z, .bounceHorizontal

    CP pl.PL_DHIT_BOTTOM_D4
    JR Z, .bounceHorizontal

.bounceHorizontal
    ; Enemy bounces from the platform's top/bottom, reverse movement
    CALL _FlipReverseY                        ; Revert reverse

    JR .afterBounceSetup
.bounceL
    ; Enemy bounces from the platform's left side, reverse deploy bit, and as a result, the enemy will change direction
    RES ENP_S_BIT_DEPLOY_D1, (IY + ENP.SETUP)
    SET sr.SPRITE_ST_MIRROR_X_BIT, (IX + SPR.STATE); Turn sprite

    LD A, sr.SDB_BOUNCE_SIDE
    CALL _PlayBounceAnimation

    JR .afterBounceSetup
.bounceR
    ; Enemy bounces from the platform's right side
    SET ENP_S_BIT_DEPLOY_D1, (IY + ENP.SETUP)
    RES sr.SPRITE_ST_MIRROR_X_BIT, (IX + SPR.STATE); Turn sprite

    LD A, sr.SDB_BOUNCE_SIDE
    CALL _PlayBounceAnimation

.afterBounceSetup

    ; ##########################################
    ; Should the enemy move along the platform to avoid collision?
    BIT ENP_S_BIT_ALONG_D0, (IY + ENP.SETUP)
    JR Z, .afterMoveAlong                       ; Jump if move along is not set

    ; Check the collision with the platform
    PUSH IX, IY, HL
    CALL pl.PlatformSpriteClose
    POP HL, IY, IX

    JR NZ, .afterMoveAlong                      ; Jump if there is no collision

    ; Avoid collision with the platform by moving along it
    CALL _MoveEnemyX
    CALL sr.UpdateSpritePosition                ; Move sprite to new X,Y coordinates
    RET                                         ; Return, sprite moves along platform
.afterMoveAlong

    ; ##########################################
    ; Check if counter for X has already reached 0, or is set to 0
    LD A, (IY + ENP.MOVE_PAT_STEP)              ; A contains current X,Y counters
    AND MOVE_PAT_X_MASK                         ; Reset all but X
    OR A                                        ; Same as CP 0, but faster.
    JR Z, .afterMoveLR                          ; Jump if the counter for X has reached 0

    ; Decrement X counter
    LD A, (IY + ENP.MOVE_PAT_STEP)              ; A contains current X,Y counters
    SUB MOVE_PAT_X_ADD                          ; Decrement X counter by 1
    LD (IY + ENP.MOVE_PAT_STEP), A

    CALL _MoveEnemyX
.afterMoveLR

    ; ##########################################
    ; Check if counter for Y has already reached 0, or is set to 0
    LD A, (IY + ENP.MOVE_PAT_STEP)              ; A contains current X,Y counters
    AND MOVE_PAT_Y_MASK                         ; Reset all but Y
    OR A                                        ; Same as CP 0, but faster.
    JR Z, .afterChangeY                         ; Jump if the counter for Y has reached 0

    ; Enemy should move on Y
    LD A, (IY + ENP.MOVE_PAT_STEP)              ; A contains current X,Y counters
    SUB MOVE_PAT_Y_ADD                          ; Decrement Y counter by 1
    LD (IY + ENP.MOVE_PAT_STEP), A  

    ; Move on Y-axis one pixel up or down?
    LD A, (HL)                                  ; A contains current pattern

    ; Reverse movement direction?
    BIT ENP_S_BIT_REVERSE_Y_D7, (IY + ENP.SETUP)
    JR Z, .doNotReverseY

    ; Yes, reverse bit is set, up -> down, down -> up
    XOR MOVE_PAT_Y_TOD_DIR_MASK
.doNotReverseY

    BIT MOVE_PAT_Y_TOD_DIR_B_D7, A
    JR Z, .moveUp                               ; Jump if sprite should move up

    ; ##########################################
    ; Move on pixel down, but first, check whether the enemy bounces off the ground

    ; Bounce is set, has sprite reached the bottom of the screen?
    LD A, (IX + SPR.Y)
    CP _GSC_Y_MAX2_D238-BOUNCE_H_MARG_D3
    JR C, .afterBounceMoveDown                  ; Jump if the enemy is above the ground (A < _GSC_Y_MAX_D232-BOUNCE_H_MARG_D3)
    ; Yes - we are at the bottom of the screen, set reverse-y and move up instead of down
    CALL _FlipReverseY
    LD A, sr.MOVE_Y_IN_UP_D1
    CALL sr.MoveY
    JR .afterChangeY

.afterBounceMoveDown
    ; Bouncing not necessary, finally move down
    LD A, sr.MOVE_Y_IN_DOWN_D0
    CALL sr.MoveY
    OR A                                        ; Same as: CP sr.MOVE_RET_HIDDEN_D0
    JR NZ, .afterChangeY                        ; Jump is sprite is not hidden

    RET                                         ; Stop moving this sprite, it's hidden

.moveUp
    ; ##########################################
    ; Move on pixel up, but first, check whether the enemy bounces off the top of the screen
    BIT ENP_S_BIT_BOUNCE_D2, (IY + ENP.SETUP)
    JR Z, .afterBounceMoveUp                    ; Jump if bounce is not set

    ; Bounce is set, has sprite reached top of the screen?
    LD A, (IX + SPR.Y)
    CP _GSC_Y_MIN_D15 + BOUNCE_H_MARG_D3
    JR NC, .afterBounceMoveUp                   ; Jump if the enemy is below max screen postion (A >= _GSC_Y_MIN_D15+_GSC_Y_MIN_D15)

    ; Yes - we are at the top of the screen, set reverse-y and move down instead of up
    CALL _FlipReverseY
    LD A, sr.MOVE_Y_IN_DOWN_D0
    CALL sr.MoveY
    JR .afterChangeY
.afterBounceMoveUp

    ; Bouncing not necessary, finally move up
    LD A, sr.MOVE_Y_IN_UP_D1
    CALL sr.MoveY
    OR A                                        ; Same as: CP sr.MOVE_RET_HIDDEN_D0
    JR NZ,.afterChangeY                         ; Jump is sprite is not hidden
    RET                                         ; Stop moving this sprite, it's hidden

.afterChangeY
    CALL sr.UpdateSpritePosition                ; Move sprite to new X,Y coordinates

    ; Check if X and Y have reached 0
    LD A, (IY + ENP.MOVE_PAT_STEP)              ; A contains pattern counter
    AND MOVE_PAT_XY_MASK                        ; Reset all but max X,Y values
    OR A                                        ; Same as CP 0, but faster.
    JR Z, .resetXYCounters                      ; Jump if X and Y counters has reached 0

    JR .checkPlatformHit

.resetXYCounters
    ; ##########################################
    ; X and Y have reached the max value. First, reset the X and Y counters, and afterward, decrement the repetition counter.
    LD A, (HL)                                  ; X, Y counters will be set to max value as we count down towards 0
    LD (IY + ENP.MOVE_PAT_STEP), A  

    LD A, (IY + ENP.MOVE_PAT_STEP_RCNT)         ; decrement the repetition counter
    DEC A
    OR A                                        ; Same as CP 0, but faster.
    JR Z, .nextMovePattern                      ; Jump if repetition counter for single step has reached 0

    ; Decrement repetition counter for move step and return
    LD (IY + ENP.MOVE_PAT_STEP_RCNT), A         ; Store decremented counter
    
    JR .checkPlatformHit

.nextMovePattern
    ; ##########################################
    ; Setup next move pattern
    LD A, (IY + ENP.MOVE_PAT_POS)               ; A contains the current position in the move pattern

    ADD MOVE_STEP_SIZE_D2                          ; Increment the position to the next pattern and store it
    LD (IY + ENP.MOVE_PAT_POS), A

    ; Check if we should restart the move pattern, as it might have reached the last element.
    DEC A                                       ; Pattern starts after offset
    PUSH HL
    LD HL, (IY + ENP.MOVE_PAT_POINTER)          ; DE points to start of the #movePattern
    LD B, (HL)                                  ; B contains the amount of bytes in the move pattern array
    POP HL
    CP B
    JR NC, .restartMovePattern                  ; Jump A >= B -> (current postion >= size)

    ; There is no need to restart the move pattern, load the next one.
    LD BC, HL                                   ; BC points to current position in #movePatternXX
    INC BC                                      ; Move BC to the counter for current pattern
    INC BC                                      ; Move BC to the next pattern
    
    LD A, (BC)                                  ; X, Y counters will be set to max value as we count down towards 0
    LD (IY + ENP.MOVE_PAT_STEP), A  

    INC BC                                      ; Move BC to the counter for the next pattern
    LD A, (BC)                                  ; Load delay/repeat counter into A
    LD D, A

    ; Set pattern counter for next pattern
    AND MOVE_PAT_REPEAT_MASK                    ; Leave only repeat counter bits
    LD (IY + ENP.MOVE_PAT_STEP_RCNT), A

    ; Set delay counter for next pattern
    LD A, D
    CALL _SetDelayCnt
    JR .checkPlatformHit

.restartMovePattern
    ; Restart move pattern, it has reached max value.
    CALL _RestartMovePattern

; Check the collision with the platform.
; Check platform hit independent of move-along-bit. The margin for move-along is more significant than one for the hit. Sprite can hit 
; the platform where it's impossible to avoid a collision, such as a front hit.
.checkPlatformHit

    CALL pl.PlatformSpriteHit
    RET NZ                                      ; Return if there is no collision
    CALL sr.SpriteHit                           ; Explode!

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  _RestartMovePattern                     ;
;----------------------------------------------------------;
; This method resets the move pattern (#ENP) so animation can start from the first move pattern. It does not modify #SPR.
; Input
;  - IX: pointer to #SPR holding data for single sprite that will be moved
;  - IY: pointer to #ENP for current sprite
; Modifies: A, IY, BC, HL
_RestartMovePattern

    LD BC, (IX + SPR.EXT_DATA_POINTER)       ; Load #ENP for this sprite to IY
    LD IY, BC
    LD HL, (IY + ENP.MOVE_PAT_POINTER)          ; HL points to start of the #movePattern, that is the amount of elements in this pattern
    INC HL                                      ; HL points to the first move pattern element
    
    ; X, Y counters will be set to max value as we count down towards 0
    LD A, (HL)
    LD (IY + ENP.MOVE_PAT_STEP), A  

    ; Set position at the first pattern, this is one byte after the start of #movePatternXX
    LD A, MOVE_PAT_STEP_OFFSET_D1
    LD (IY + ENP.MOVE_PAT_POS), A

    ; Set pattern counters to the first pattern
    INC HL                                      ; HL points to delay/repeat counter byte
    LD A, (HL)
    LD B, A

    ; Set repeat counter
    AND MOVE_PAT_REPEAT_MASK                    ; Leave only repeat counter bits
    LD (IY + ENP.MOVE_PAT_STEP_RCNT), A

    ; Set delay counter 
    LD A, B
    CALL _SetDelayCnt

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      _SetDelayCnt                        ;
;----------------------------------------------------------;
; Input:
;  - A: delay counter from configuration.
_SetDelayCnt

    AND MOVE_PAT_DELAY_MASK                     ; Leave only delay counter bits

    ; If the delay counter is above 0, decrement it by 2 if possible. The reason for this is that delay 0 and delay 1 move by 3 or 2 
    ; pixels per frame, so there is no delay at all. Delay 2 should move by 1 pixel, and first delay 3 should skip one pixel.
    OR A                                        ; Same as CP 0, but faster.
    JR Z, .storeA
    SUB DEC_MOVE_DELAY                          ; First decrement, try again to decrement if still above 0
    OR A                                        ; Same as CP 0, but faster.
    JR Z, .storeA
    SUB DEC_MOVE_DELAY
.storeA
    LD (IY + ENP.MOVE_DELAY_CNT), A
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE