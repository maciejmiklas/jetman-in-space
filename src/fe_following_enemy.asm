;----------------------------------------------------------;
;                   Following Enemy                        ;
;----------------------------------------------------------;
    MODULE fe
    ; ### TO USE THIS MODULE: CALL dbs.SetupFollowingEnemyBank ###

; Different moving angles/speeds are achieved by skipping 0-3 pixels on x/y axis (bis 1-2 and 5-6).
; Generally, enemies follow the Jetman at a 45-degree angle. To randomize this angle, we skip pixels in one direction. For example, when
; the enemy moves one pixel in the X and Y direction, this gives us a perfect 45-degree angle. However, when we move one pixel on the X-axis
; and two on the Y-axis, this changes the angle to 67 degrees. Instead of adding pixels, we skip pixels. The current setup for skipping
; pixels is stored in the state as #STATE_SKIP_X_MASK and #STATE_SKIP_Y_MASK. It allows us to skip up to 3 pixels in one direction.
; The counter for this is stored on each enemy as #FE.SKIP_XY_CNT.
; VALUES for #FE.STATE
; Bits:
;  - 0:   Not used
;  - 1-2: Number of pixels (0-3) to skip when moving on the x-axis
;  - 3:   #STATE_DIR_Y_BIT
;  - 4:   #STATE_DIR_X_BIT
;  - 5-6: Number of pixels (0-3) to skip when moving on the y-axis
;  - 7:   Not used
STATE_SKIP_X_MASK       = %0'00'00'11'0
STATE_SKIP_Y_MASK       = %0'11'00'00'0
STATE_SKIP_XY_MASK      = %0'11'00'11'0
STATE_SKIP_RESET_MASK   = %1'00'11'00'1

SKIP_XY_DEC_X           = %0'00'00'01'0
SKIP_XY_DEC_Y           = %0'01'00'00'0

STATE_DIR_Y_BIT         = 3                     ; Corresponds to #sr.MOVE_Y_IN_UP/#sr.MOVE_Y_IN_DOWN, 1-move up, 0-move down
STATE_DIR_Y_MASK        = %000'0'1'000          ; Reset all but #STATE_DIR_Y_BIT 

STATE_DIR_X_BIT         = 4                     ; Corresponds to #sr.MVX_IN_D_TOD_DIR_BIT, 1-move right (deploy left), 0-move left (deploy right)
STATE_DIR_X_MASK        = %000'1'0'000          ; Reset all but #STATE_DIR_BIT 

BOUNCE_H_MARG_D2        = 2

; Sprites, used by single enemies (#spriteExXX).
fEnemySprites
    SPR {089/*ID*/, sr.SDB_ENEMY1A/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, fEnemy01/*EXT_DATA_POINTER*/}
fEnemySprites2
    SPR {099/*ID*/, sr.SDB_ENEMY1A/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, fEnemy02/*EXT_DATA_POINTER*/}
    SPR {100/*ID*/, sr.SDB_ENEMY1A/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, fEnemy03/*EXT_DATA_POINTER*/}
    SPR {101/*ID*/, sr.SDB_ENEMY1A/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, fEnemy04/*EXT_DATA_POINTER*/}
    SPR {102/*ID*/, sr.SDB_ENEMY1A/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, fEnemy05/*EXT_DATA_POINTER*/}
    SPR {103/*ID*/, sr.SDB_ENEMY1A/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, fEnemy06/*EXT_DATA_POINTER*/}
    SPR {104/*ID*/, sr.SDB_ENEMY1A/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, fEnemy07/*EXT_DATA_POINTER*/}
    SPR {105/*ID*/, sr.SDB_ENEMY1A/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, fEnemy08/*EXT_DATA_POINTER*/}
    SPR {106/*ID*/, sr.SDB_ENEMY1A/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, fEnemy09/*EXT_DATA_POINTER*/}
    SPR {107/*ID*/, sr.SDB_ENEMY1A/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, fEnemy10/*EXT_DATA_POINTER*/}
fEnemySize              BYTE 1
FOLLOWING_FENEMY_SIZE   = 10

fEnemy01
    FE {STATE_DEPLOY_RIGHT /*STATE*/, 080/*RESPAWN_Y*/, 01/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/, 0,0,0,0,0,0}

fEnemy02
    FE {STATE_DEPLOY_LEFT /*STATE*/, 080/*RESPAWN_Y*/, 01/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/, 0,0,0,0,0,0}

fEnemy03
    FE {STATE_DEPLOY_RIGHT /*STATE*/, 080/*RESPAWN_Y*/, 01/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/, 0,0,0,0,0,0}

fEnemy04
    FE {STATE_DEPLOY_RIGHT /*STATE*/, 080/*RESPAWN_Y*/, 01/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/, 0,0,0,0,0,0}

fEnemy05
    FE {STATE_DEPLOY_RIGHT /*STATE*/, 080/*RESPAWN_Y*/, 01/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/, 0,0,0,0,0,0}

fEnemy06
    FE {STATE_DEPLOY_RIGHT /*STATE*/, 080/*RESPAWN_Y*/, 01/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/, 0,0,0,0,0,0}

fEnemy07
    FE {STATE_DEPLOY_RIGHT /*STATE*/, 080/*RESPAWN_Y*/, 01/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/, 0,0,0,0,0,0}

fEnemy08
    FE {STATE_DEPLOY_RIGHT /*STATE*/, 080/*RESPAWN_Y*/, 01/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/, 0,0,0,0,0,0}

fEnemy09
    FE {STATE_DEPLOY_RIGHT /*STATE*/, 080/*RESPAWN_Y*/, 01/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/, 0,0,0,0,0,0}

fEnemy10
    FE {STATE_DEPLOY_RIGHT /*STATE*/, 080/*RESPAWN_Y*/, 01/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/, 0,0,0,0,0,0}

; Each line contains a single set of 4 "angles", which will be applied to the enemy when it changes direction. Each angle lasts for 
; 0.5 seconds (_MainLoop025OnActiveGame -> NextFollowingAngle), and afterwards, the next one is taken until we reach the last one. 
; The last one remains active until the enemy changes direction again and a new line is applied. It gives us the effect of changing angle
; when changing direction, as well as acceleration.
; The bit pattern for each angle byte is a mask that can be directly applied to #FE.STATE. The state will set pixels that will be skipped 
; in the x/y direction.
ANGLE_LINE_SIZE         = 3
ANGLE_LINE_MAX          = ANGLE_LINE_SIZE - 1
ANGLE_LINES             = 11
angles
    DB %0'10'00'11'0, %0'01'00'10'0, %0'00'00'10'0
    DB %0'11'00'10'0, %0'10'00'01'0, %0'10'00'00'0
    DB %0'01'00'10'0, %0'01'00'01'0, %0'00'00'00'0
    DB %0'10'00'11'0, %0'01'00'11'0, %0'00'00'11'0
    DB %0'10'00'11'0, %0'01'00'11'0, %0'00'00'11'0
    DB %0'11'00'10'0, %0'11'00'01'0, %0'11'00'00'0
    DB %0'10'00'10'0, %0'01'00'10'0, %0'00'00'01'0
    DB %0'10'00'10'0, %0'10'00'01'0, %0'01'00'00'0
    DB %0'10'00'10'0, %0'01'00'01'0, %0'00'00'01'0
    DB %0'01'00'01'0, %0'10'00'10'0, %0'00'00'01'0
    DB %0'10'00'01'0, %0'01'00'00'0, %0'00'00'00'0
anglesLineIdx           DB 0                     ; Runs from 0 to ANGLE_LINES

;----------------------------------------------------------;
;                DisableFollowingEnemies                   ;
;----------------------------------------------------------;
DisableFollowingEnemies

    CALL _ResetSprites

    XOR A
    LD (anglesLineIdx), A
    LD (fEnemySize), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 SetupFollowingEnemies                    ;
;----------------------------------------------------------;
; Input:
;  - A:  Number of enemies (size of #FES)
;  - IX: Pointer to #FES
SetupFollowingEnemies

    LD B, A             ; Counter for .enemyLoop
    LD (fEnemySize), A

    XOR A
    LD (anglesLineIdx), A

    ; ##########################################
    ; Copy #FES to #FE for each active enemy

    LD IY, fEnemy01
.enemyLoop

    LD A, (IX + FES.STATE)
    LD (IY + FES.STATE), A

    LD A, (IX + FES.RESPAWN_Y)
    LD (IY + FES.RESPAWN_Y), A

    LD A, (IX + FES.RESPAWN_DELAY)
    LD (IY + FES.RESPAWN_DELAY), A

    LD A, (IX + FES.MOVE_DELAY)
    LD (IY + FES.MOVE_DELAY), A

    ; ##########################################
    ; Move pointer to next #FES
    LD DE, IX
    ADD DE, FES
    LD IX, DE

    ; Move pointer to next #FE
    LD DE, IY
    ADD DE, FE
    LD IY, DE

    DJNZ .enemyLoop

    CALL _ResetSprites

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   NextFollowingAngle                     ;
;----------------------------------------------------------;
NextFollowingAngle

    ; Iterate over all enemies
    LD IX, fEnemySprites
    LD A, (fEnemySize)
 
    ; Do not execute if there are no active enemies (disabled)
    CP 0
    RET Z

    LD B, A
.enemyLoop
    PUSH BC                                     ; Preserve B for loop counter

    ; Load extra data for this sprite to IY
    LD BC, (IX + SPR.EXT_DATA_POINTER)
    LD IY, BC

    CALL _NextFollowingAngle

    POP BC

    ; Move IX to the beginning of the next #fEnemySprites
    LD DE, SPR
    ADD IX, DE
    DJNZ .enemyLoop                             ; Jump if B > 0 (loop starts with B = #fEnemySpritesSize)

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  UpdateFollowingJetman                   ;
;----------------------------------------------------------;
; Updates #STATE_DIR_X_BIT and #STATE_DIR_Y_BIT based on Jetman's position
UpdateFollowingJetman

    ; Iterate over all enemies
    LD IX, fEnemySprites
    LD A, (fEnemySize)

    ; Do not execute if there are no active enemies (disabled)
    CP 0
    RET Z

    LD B, A

.sprLoop
    PUSH BC                                     ; Preserve B for loop counter

    ; Load extra data for this sprite to IY
    LD BC, (IX + SPR.EXT_DATA_POINTER)
    LD IY, BC

    CALL _UpdateFollowingEnemy

    POP BC

    ; Move IX to the beginning of the next #fEnemySprites
    LD DE, SPR
    ADD IX, DE
    DJNZ .sprLoop                               ; Jump if B > 0 (loop starts with B = #fEnemySpritesSize)

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 RespawnFollowingEnemy                    ;
;----------------------------------------------------------;
; Respawns next single enemy. To respawn next from formation use enf.RespawnFormation
RespawnFollowingEnemy

    ; Iterate over all enemies to find the first hidden, respawn it, and exit function.
    LD IX, fEnemySprites
    LD A, (fEnemySize)

    ; Do not execute if there are no active enemies (disabled)
    CP 0
    RET Z

    LD B, A

.sprLoop
    PUSH BC                                     ; Preserve B for loop counter
    CALL _TryRespawnNextFollowingEnemy
    POP BC

    CP A, _RET_YES_D1
    RET Z                                       ; Exit after respawning first enemy

    ; Move IX to the beginning of the next #fEnemySprites
    LD DE, SPR
    ADD IX, DE
    DJNZ .sprLoop                               ; Jump if B > 0 (loop starts with B = #fEnemySpritesSize)

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 MoveFollowingEnemies                     ;
;----------------------------------------------------------;
MoveFollowingEnemies

    ; ##########################################
    ; Loop ever all enemies skipping hidden
    LD IX, fEnemySprites
    LD A, (fEnemySize)

    ; Do not execute if there are no active enemies (disabled)
    CP 0
    RET Z

    LD B, A

.enemyLoop
    PUSH BC                                     ; Preserve B for loop counter

    ; ##########################################
    ; Move single enemy

    ; Ignore if enemy is not visible
    BIT sr.SPRITE_ST_VISIBLE_BIT, (IX + SPR.STATE)
    JR Z, .continue

    ; Ignore this sprite if it's hidden
    LD A, (IX + SPR.STATE)
    AND sr.SPRITE_ST_VISIBLE                    ; Reset all bits but visibility
    CP 0
    JR Z, .continue                             ; Jump if visibility is not set (sprite is hidden)

    ; Load extra data for this sprite to IY
    LD BC, (IX + SPR.EXT_DATA_POINTER)
    LD IY, BC

    ; ##########################################
    ; Slow down movement by decrementing the counter until it reaches 0, at 0 enemy moves

    ; Delay disabled?
    LD A, (IY + FE.MOVE_DELAY)
    CP 0                                        ; No delay? -> move at full speed
    JR Z, .afterMoveDelay

    LD A, (IY + FE.MOVE_DELAY_CNT)
    CP 0
    JR Z, .resetDelay

    ; Decrement the counter and skip the movement
    DEC A
    LD (IY + FE.MOVE_DELAY_CNT), A

    JR .continue

.resetDelay
    ; Reset the counter and move
    LD A, (IY + FE.MOVE_DELAY)
    LD (IY + FE.MOVE_DELAY_CNT), A
.afterMoveDelay

    ; ##########################################
    ; Sprite is visible, move it!

    CALL _MoveEnemy

.continue
    ; ##########################################
    ; Move IX to the beginning of the next #SPR
    LD DE, SPR
    ADD IX, DE

    ; ##########################################
    POP BC
    DJNZ .enemyLoop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                    _ResetSprites                         ;
;----------------------------------------------------------;
_ResetSprites
    LD IX, (fEnemySprites)
    LD B, (FOLLOWING_FENEMY_SIZE)

.spriteLoop

    LD A, (IX + SPR.ID)
    CALL sp.SetIdAndHideSprite

    CALL sr.ResetSprite

    ; Move IX to the next sprite
    LD DE, IX
    ADD DE, SPR
    LD IX, DE
    DJNZ .spriteLoop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                _UpdateFollowingEnemy                     ;
;----------------------------------------------------------;
; Updates #STATE_DIR_X_BIT and #STATE_DIR_Y_BIT based on Jetman's position
; Input
;  - IX: Pointer to #SPR holding data for single sprite that will be moved
;  - IY: Pointer to #FE
_UpdateFollowingEnemy

    ; Return if enemy is not visible
    BIT sr.SPRITE_ST_VISIBLE_BIT, (IX + SPR.STATE)
    RET Z

    ; ##########################################
    ; Is following disabled?
    LD A, (IY + FE.FOLLOW_OFF_CNT)
    CP 0
    JR Z, .afterFollowOff
    DEC A
    LD (IY + FE.FOLLOW_OFF_CNT), A
    RET
.afterFollowOff

    LD D, (IY + FE.STATE)                       ; Keep the state in D to check whether it will change later on
    ; ##########################################
    ; Move X

    ; Decide whether we should move enemy lef/right to get closer to the Jetman
    ; (Jetman X) - (Enemy X) > 0 -> move enemy left
    ; (Jetman X) - (Enemy X) < 0 -> move enemy right
    LD BC, (IX + SPR.X)                         ; X of the enemy
    LD HL, (jpo.jetX)                           ; X of the Jetman
    OR A: SBC HL, BC
    JP M, .moveEnemyLeft                        ; #jetY -#SPR.X < 0 -> move enemy left
 
    ; Increment enemy X (move right)
    SET STATE_DIR_X_BIT, (IY + FE.STATE)

    LD A, D: CP (IY + FE.STATE)
    CALL NZ, _EnemyDirectionChanged             ; Call only if state has changed
    JR .afterMoveX

    ; Decrement enemy X (move left)
.moveEnemyLeft
    RES STATE_DIR_X_BIT, (IY + FE.STATE)
    LD A, D: CP (IY + FE.STATE)
    CALL NZ, _EnemyDirectionChanged             ; Call only if state has changed

.afterMoveX

    ; ##########################################
    ; Move Y

    ; Decide whether we should move enemy up/down to get closer to the Jetman
    ; (Jetman Y)  > (Enemy Y) -> move enemy down
    ; (Jetman Y)  < (Enemy Y) -> move enemy up
    LD B, (IX + SPR.Y)                          ; Y of the enemy
    LD A, (jpo.jetY)                            ; Y of the Jetman
    CP B
    JP C, .moveEnemyUp                          ; Jump if  #jetY - #SPR.Y < 0

    ; Move enemy down (increment Y)
    RES STATE_DIR_Y_BIT, (IY + FE.STATE)

    ; Call direction change only if state has changed
    LD A, D: CP (IY + FE.STATE)
    CALL NZ, _EnemyDirectionChanged
    RET

    ; Move enemy up (decrement Y)
.moveEnemyUp

    LD B, (IX + SPR.Y)                          ; Y of the enemy 3e
    LD A, (jpo.jetY)                            ; Y of the Jetman e1

    SET STATE_DIR_Y_BIT, (IY + FE.STATE)

    ; Delay following only if state has changed
    LD A, D: CP (IY + FE.STATE)
    CALL NZ, _EnemyDirectionChanged

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 _NextFollowingAngle                      ;
;----------------------------------------------------------;
; Input
;  - IX: Pointer to #SPR holding data for single sprite that will be moved
;  - IY: Pointer to #FE
_NextFollowingAngle

    ; Return if enemy is not visible
    BIT sr.SPRITE_ST_VISIBLE_BIT, (IX + SPR.STATE)
    RET Z

    ; Set index to the next angle, assuming that we still have not reached the last one
    LD B, (IY + FE.ANGLES_IDX_END)
    LD A, (IY + FE.ANGLES_IDX)
    CP B
    RET Z                                       ; Already at last angle, keep it

    ; HL will point to angle that has to be loaded into the state, B will hold next angle value
    LD HL, angles
    ADD HL, A
    LD A, (HL)
    LD B, A

    ; Load state into A, reset all skip bits, and set new values from B
    LD A, (IY + FE.STATE)
    AND STATE_SKIP_RESET_MASK
    XOR B
    LD (IY + FE.STATE), A

    ; Next index value
    INC (IY + FE.ANGLES_IDX)

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                _EnemyDirectionChanged                    ;
;----------------------------------------------------------;
; Input
;  - IX: Pointer to #SPR holding data for single sprite that will be moved
;  - IY: Pointer to #FE
_EnemyDirectionChanged

    ; Set following off counter to random value
    LD A, R
    LD (IY + FE.FOLLOW_OFF_CNT), A

    ; ##########################################
    ; Load new angle line and set the angle on enemy's status
    LD A, (anglesLineIdx)
    CP ANGLE_LINES
    JR Z, .resetLines
    INC A
    JR .afterResetLines
.resetLines
    XOR A
.afterResetLines
    LD (anglesLineIdx), A
    
    ; A now holds the current line in #angles, change it to offset by multiplying by 4
    LD D, A
    LD E, ANGLE_LINE_SIZE
    MUL D, E
    LD A, E                                      ; A has offset to the current line
    
    LD (IY + FE.ANGLES_IDX), A
    ADD ANGLE_LINE_SIZE
    LD (IY + FE.ANGLES_IDX_END), A

    ; Load new angle immediately
    CALL _NextFollowingAngle

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  _BounceOfPlatform                       ;
;----------------------------------------------------------;
; Input
;  - IX: Pointer to #SPR holding data for single sprite that will be moved
;  - IY: Pointer to #FE
_BounceOfPlatform

    ; Check the collision with the platform
    PUSH IX, IY, HL
    LD HL, IX
    ADD HL, SPR.X                               ; Param next method

    CALL pl.PlatformBounceOff
    POP HL, IY, IX

    CP pl.PL_DHIT_NO
    RET Z

    CP pl.PL_DHIT_LEFT
    JR Z, .hitLeft

    CP pl.PL_DHIT_RIGHT
    JR Z, .hitRight

    CP pl.PL_DHIT_TOP
    JR Z, .hitTop

    CP pl.PL_DHIT_BOTTOM
    JR Z, .hitBottom

.hitLeft
    RES STATE_DIR_X_BIT, (IY + FE.STATE)        ; Move left, because enemy was moving right to hit platform from the left side
    LD A, sr.SDB_BOUNCE_SIDEA                   ; Bounce animation for #sr.LoadSpritePattern at .bounced
    JR .bounced

.hitRight
    SET STATE_DIR_X_BIT, (IY + FE.STATE)        ; Move right, because enemy was moving left to hit platform from the right side
    LD A, sr.SDB_BOUNCE_SIDEA                   ; Bounce animation for #sr.LoadSpritePattern at .bounced
    JR .bounced

.hitTop
    SET STATE_DIR_Y_BIT, (IY + FE.STATE)        ; Move up, because enemy was moving down to hit platform from the top
    LD A, sr.SDB_BOUNCE_TOPA                    ; Bounce animation for #sr.LoadSpritePattern at .bounced
    JR .bounced

.hitBottom
    RES STATE_DIR_Y_BIT, (IY + FE.STATE)        ; Move down, because enemy was moving up to hit the platform from the bottom
    LD A, sr.SDB_BOUNCE_TOPA                    ; Bounce animation for #sr.LoadSpritePattern below

.bounced
    CALL sr.LoadSpritePattern

    ; Disable following until the enemy is far from the platform
    CALL _EnemyDirectionChanged

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       _MoveEnemy                         ;
;----------------------------------------------------------;
; Input
;  - IX: Pointer to #SPR holding data for single sprite that will be moved
;  - IY: Pointer to #FE
_MoveEnemy

    CALL _BounceOfPlatform                     ; Should enemy bounce of the platform?

    ; ##########################################
    ; Move X - left/right

    ; Should we skip movement on x-axis (to change the angle)?
    LD A, (IY + FE.STATE)
    AND STATE_SKIP_X_MASK
    CP 0
    JR Z, .afterSkipX

    ; Check counter
    LD A, (IY + FE.SKIP_XY_CNT)                 ; Has counter reached 0?
    AND STATE_SKIP_X_MASK
    CP 0
    JR Z, .resetSkipX

    ; Decrement the counter and skip movement in this direction
    LD A, (IY + FE.SKIP_XY_CNT)
    SUB SKIP_XY_DEC_X
    LD (IY + FE.SKIP_XY_CNT), A
    JR .afterMoveX                              ; Skip movement

.resetSkipX
    ; Counter reached 0, reset it by copying value max value from state
    LD A, (IY + FE.STATE)
    AND STATE_SKIP_X_MASK
    LD B, A
    LD A, (IY + FE.SKIP_XY_CNT)
    OR B
    LD (IY + FE.SKIP_XY_CNT), A
.afterSkipX

    ; ##########################################
    ; Move on X left or right. The direction is being copied from FE.STATE to D as a parameter for #sr.MoveX
    LD A, (IY + FE.STATE)
    AND STATE_DIR_X_MASK
    LD B, A

    LD A, sr.MVX_IN_D_1PX_ROL
    OR B
    LD D, A
    CALL sr.MoveX

.afterMoveX

    ; ##########################################
    ; Move Y - up/down
    CALL _BounceOfTop

    ; Should we skip movement on y-axis (to change the angle)?
    LD A, (IY + FE.STATE)
    AND STATE_SKIP_Y_MASK
    CP 0
    JR Z, .afterSkipY

    ; Check counter
    LD A, (IY + FE.SKIP_XY_CNT)                 ; Has counter reached 0?
    AND STATE_SKIP_Y_MASK
    CP 0
    JR Z, .resetSkipY

    ; Decrement the counter and skip movement in this direction
    LD A, (IY + FE.SKIP_XY_CNT)
    SUB SKIP_XY_DEC_Y
    LD (IY + FE.SKIP_XY_CNT), A
    JR .afterMoveY                              ; Skip movement

.resetSkipY
    ; Counter reached 0, reset it by copying value max value from state
    LD A, (IY + FE.STATE)
    AND STATE_SKIP_Y_MASK
    LD B, A
    LD A, (IY + FE.SKIP_XY_CNT)
    OR B
    LD (IY + FE.SKIP_XY_CNT), A
.afterSkipY

    ; ##########################################
    ; Move up/down based on state
    BIT STATE_DIR_Y_BIT, (IY + FE.STATE)
    JR NZ, .moveUp                              ; Jump if bit #STATE_DIR_Y_BIT == 1

    ; Move down
    LD A, sr.MOVE_Y_IN_DOWN
    JR .afterMoveYDir

    ; Move up
.moveUp
    LD A, sr.MOVE_Y_IN_UP

.afterMoveYDir
    ; ##########################################
    CALL sr.MoveY                               ; A contains #MOVE_Y_IN_DOWN/UP
.afterMoveY

    CALL sr.SetSpriteId
    CALL sr.UpdateSpritePosition

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     _BounceOfTop                         ;
;----------------------------------------------------------;
; Invert Y (#STATE_DIR_Y_BIT) if the enemy is close to the top/bottom of the screen
; Input
;  - IX: Pointer to #SPR holding data for single sprite that will be moved
;  - IY: Pointer to #FE
_BounceOfTop

    ; Has enemy reached the bottom of the screen?
    LD A, (IX + SPR.Y)
    CP _GSC_Y_MAX2_D238-BOUNCE_H_MARG_D2
    JR C, .afterBounceMoveDown                  ; Jump if the enemy is above the ground (A < _GSC_Y_MAX_D232-BOUNCE_H_MARG_D3)

    ; Yes - we are at the bottom of the screen, set y to go up
    SET STATE_DIR_Y_BIT, (IY + FE.STATE)

    JR .afterBounced
.afterBounceMoveDown

    ; ##########################################
    ; Has enemy reached top of the screen?
    LD A, (IX + SPR.Y)
    CP _GSC_Y_MIN_D15 + BOUNCE_H_MARG_D2
    RET NC                                       ; Jump if the enemy is below max screen postion (A >= _GSC_Y_MIN_D15+_GSC_Y_MIN_D15)

    ; Yes - we are at the top of the screen, set y to go down
    RES STATE_DIR_Y_BIT, (IY + FE.STATE)
.afterBounced

    ; Bounce animation
    LD A, sr.SDB_BOUNCE_TOP
    CALL sr.LoadSpritePattern

    RET                                         ; ## END of the function ##

tmp db 0
;----------------------------------------------------------;
;            _TryRespawnNextFollowingEnemy                 ;
;----------------------------------------------------------;
; Input:
;  - IX: Pointer to #SPR holding data for single enemy
; Output:
;  - A:  _RET_YES_D1/_RET_NO_D0
_TryRespawnNextFollowingEnemy

    ; Skip this sprite if it's already visible/active
    BIT sr.SPRITE_ST_VISIBLE_BIT, (IX + SPR.STATE)
    JR Z, .afterAliveCheck                      ; Jump if not visible

    BIT sr.SPRITE_ST_ACTIVE_BIT, (IX + SPR.STATE)
    JR Z, .afterAliveCheck                      ; Jump if not active

    LD A, _RET_NO_D0
    RET
.afterAliveCheck

    ; Sprite is hidden, check the dedicated delay before respawning

    ; Load extra sprite data (#FE) to IY
    LD BC, (IX + SPR.EXT_DATA_POINTER)
    LD IY, BC

    ; There are two respawn delay timers. The first is global (#respawnDelayCnt) and ensures that multiple enemies do not respawn at the 
    ; same time. The second timer can be configured for a single enemy, which further delays its comeback.
    LD A, (IY + FE.RESPAWN_DELAY)

    ; Enemy disabled?
    CP enp.RESPAWN_OFF
    JR NZ, .respawnOn

    LD A, _RET_NO_D0
    RET
.respawnOn

    CP 0
    JR Z, .afterEnemyRespawnDelay               ; Jump if there is no extra delay for this enemy

    LD B, A
    LD A, (IY + FE.RESPAWN_DELAY_CNT)
    INC A
    CP B
    JR Z, .afterEnemyRespawnDelay               ; Jump if the timer reaches respawn delay

    LD (IY + FE.RESPAWN_DELAY_CNT), A           ; The delay timer for the enemy is still ticking
    ld (tmp),a
    
    LD A, _RET_NO_D0
    RET
.afterEnemyRespawnDelay

    ; ##########################################
    ; Respawn enemy

    LD A, (IX + SPR.STATE)

    CALL sr.SetStateVisible

    ; Reset counters
    XOR A                                       ; Set A to 0
    LD (IY + FE.RESPAWN_DELAY_CNT), A

    LD A, (IY + FE.MOVE_DELAY)
    LD (IY + FE.MOVE_DELAY_CNT), A

    ; Set Y (horizontal respawn)
    LD A, (IY + FE.RESPAWN_Y)
    LD (IX + SPR.Y), A

    ; Set X to left or right side of the screen
    BIT STATE_DIR_X_BIT, (IY + FE.STATE)
    JR NZ, .deployLeft

    ; Deploy right
    LD BC, _GSC_X_MAX_D315
    JR .afterLR

    ; Deploy left
.deployLeft
    LD BC, _GSC_X_MIN_D0

.afterLR
    LD (IX + SPR.X), BC
    CALL sr.SetSpriteId                         ; Set the ID of the sprite for the following commands
    CALL sr.ShowSprite

    LD A, _RET_YES_D1

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE