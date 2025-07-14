;----------------------------------------------------------;
;                   Following Enemy                        ;
;----------------------------------------------------------;
    MODULE fe
    ; ### TO USE THIS MODULE: CALL dbs.SetupFollowingEnemyBank ###

freezeCnt               DB 0
FREEZE_ENEMIES_CNT      = 250

    STRUCT FE
STATE                   DB                      ; See: #STATE_XXX
RESPAWN_Y               DB                      ; Respawn Y position
RESPAWN_DELAY           DB                      ; Number of game loops delaying respawn
MOVE_DELAY              DB

; Values changed during runtime
MOVE_DELAY_CNT          DB                      ; Counts down from #FE.MOVE_DELAY to 0
RESPAWN_DELAY_CNT       DB                      ; Respawn delay counter, counts up from 0 to #FE.RESPAWN_DELAY
FOLLOW_OFF_CNT          DB                      ; Disables following (direction change towards Jetman) for a few loops
BOUNCE_OFF_CNT          DB
    ENDS

; VALUES for #FE.STATE
STATE_DIR_X_BIT         = 4                     ; Corresponds to #sr.MVX_IN_D_TOD_DIR_BIT, 1-move right (deploy left), 0-move left (deploy right)
STATE_DIR_X_MASK        = %000'1'0000           ; Reset all but #STATE_DIR_BIT

STATE_DIR_Y_BIT         = 3                     ; Corresponds to #sr.MOVE_Y_IN_UP/#sr.MOVE_Y_IN_DOWN, 1-move up, 0-move down
STATE_DIR_Y_MASK        = %0000'1'000           ; Reset all but #STATE_DIR_Y_BIT

STATE_MOVE_RD           = %000'1'0'000          ; Deploy on the left side of the screen and move right-down 
STATE_MOVE_RU           = %000'1'1'000          ; Deploy on the left side of the screen and move right-up 
STATE_MOVE_LD           = %000'0'0'000          ; Deploy on the right side of the screen and move left-down 
STATE_MOVE_LU           = %000'0'1'000          ; Deploy on the right side of the screen and move left-up 

BOUNCE_H_MARG_D2        = 2
BOUNCE_OFF_D10          = 10

FOLLOW_OFF_CHANGE_D4    = 4                     ; 4 = 2s (_MainLoop025 -> UpdateFollowingEnemies)

; Sprites, used by single enemies (#spriteExXX).
fEnemySprites
    SPR {089/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, fEnemy01/*EXT_DATA_POINTER*/}
    SPR {099/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, fEnemy02/*EXT_DATA_POINTER*/}
    SPR {100/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, fEnemy01/*EXT_DATA_POINTER*/}
    SPR {101/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, fEnemy01/*EXT_DATA_POINTER*/}
    SPR {102/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, fEnemy01/*EXT_DATA_POINTER*/}
    SPR {103/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, fEnemy01/*EXT_DATA_POINTER*/}
    SPR {104/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, fEnemy01/*EXT_DATA_POINTER*/}
    SPR {105/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, fEnemy01/*EXT_DATA_POINTER*/}
    SPR {106/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, fEnemy01/*EXT_DATA_POINTER*/}
    SPR {107/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, fEnemy01/*EXT_DATA_POINTER*/}
fEnemySize              BYTE 1

fEnemy01
    FE {STATE_MOVE_RD /*STATE*/, 080/*RESPAWN_Y*/, 01/*RESPAWN_DELAY*/, 02/*MOVE_DELAY*/, 0/*MOVE_DELAY_CNT*/, 0/*RESPAWN_DELAY_CNT*/, 0/*FOLLOW_OFF_CNT*/, 0/*BOUNCE_OFF_CNT*/}

fEnemy02
    FE {STATE_MOVE_LD  /*STATE*/, 120/*RESPAWN_Y*/, 01/*RESPAWN_DELAY*/, 03/*MOVE_DELAY*/, 0/*MOVE_DELAY_CNT*/, 0/*RESPAWN_DELAY_CNT*/, 0/*FOLLOW_OFF_CNT*/, 0/*BOUNCE_OFF_CNT*/}

;----------------------------------------------------------;
;                UpdateFollowingEnemies                    ;
;----------------------------------------------------------;
UpdateFollowingEnemies

    ; Iterate over all enemies to find the first hidden, respawn it, and exit function.
    LD IX, fEnemySprites
    LD A, (fEnemySize)
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
;                FreezeFollowingEnemies                    ;
;----------------------------------------------------------;
FreezeFollowingEnemies

    LD A, FREEZE_ENEMIES_CNT
    LD (freezeCnt), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 RespawnFollowingEnemy                    ;
;----------------------------------------------------------;
; Respawns next single enemy. To respawn next from formation use enf.RespawnFormation
RespawnFollowingEnemy

    ; Iterate over all enemies to find the first hidden, respawn it, and exit function.
    LD IX, fEnemySprites
    LD A, (fEnemySize)
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
;               AnimateFollowingEnemies                    ;
;----------------------------------------------------------;
AnimateFollowingEnemies

    ; Animate single enemy
    LD IX, fEnemySprites
    LD A, (fEnemySize)
    LD B, A
    CALL sr.AnimateSprites

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 MoveFollowingEnemies                     ;
;----------------------------------------------------------;
MoveFollowingEnemies

    ; Enemies frozen and cannot move?
    LD A, (freezeCnt)
    CP 0
    JR Z, .afterFreeze
    DEC A
    LD (freezeCnt),A
    RET
.afterFreeze

    ; ##########################################
    ; Loop ever all enemies skipping hidden
    LD IX, fEnemySprites
    LD A, (fEnemySize)
    LD B, A

.enemyLoop
    PUSH BC                                     ; Preserve B for loop counter

    ; ##########################################
    ; Move single enemy

    ; Ignore this sprite if it's hidden
    LD A, (IX + SPR.STATE)
    AND sr.SPRITE_ST_VISIBLE                    ; Reset all bits but visibility
    CP 0
    JR Z, .continue                             ; Jump if visibility is not set (sprite is hidden)

    ; Load extra data for this sprite to IY
    LD BC, (IX + SPR.EXT_DATA_POINTER)
    LD IY, BC

    ; ##########################################
    ; Slow down movement by decrementing the counter until it reaches 0
    LD A, (IY + FE.MOVE_DELAY)
    CP 0                                        ; No delay? -> move at full speed
    JR Z, .afterMoveDelay

    LD A, (IY + FE.MOVE_DELAY_CNT)
    DEC A
    LD (IY + FE.MOVE_DELAY_CNT), A

    CP 0
    JR NZ, .continue                            ; Skip enemy if the delay counter > 0

    ; Reset the counter
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
;                _UpdateFollowingEnemy                     ;
;----------------------------------------------------------;
; Updates #STATE_DIR_X_BIT and #STATE_DIR_Y_BIT based on Jetman's position
; Input
;  - IX: Pointer to #SPR holding data for single sprite that will be moved
;  - IY: Pointer to #FE
_UpdateFollowingEnemy

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
    CALL NZ, _DelayFollowing             ; Call only if state has changed
    JR .afterMoveX

    ; Decrement enemy X (move left)
.moveEnemyLeft
    RES STATE_DIR_X_BIT, (IY + FE.STATE)
    LD A, D: CP (IY + FE.STATE)
    CALL NZ, _DelayFollowing             ; Call only if state has changed

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

    ; Delay following only if state has changed
    LD A, D: CP (IY + FE.STATE)
    CALL NZ, _DelayFollowing
    RET

    ; Move enemy up (decrement Y)
.moveEnemyUp

    LD B, (IX + SPR.Y)                          ; Y of the enemy 3e
    LD A, (jpo.jetY)                            ; Y of the Jetman e1

    SET STATE_DIR_Y_BIT, (IY + FE.STATE)

    ; Delay following only if state has changed
    LD A, D: CP (IY + FE.STATE)
    CALL NZ, _DelayFollowing                    

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  _DelayFollowing                         ;
;----------------------------------------------------------;
; Input
;  - IX: Pointer to #SPR holding data for single sprite that will be moved
;  - IY: Pointer to #FE
_DelayFollowing

    LD A, FOLLOW_OFF_CHANGE_D4
    LD (IY + FE.FOLLOW_OFF_CNT), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  _BounceOfPlatform                       ;
;----------------------------------------------------------;
; Input
;  - IX: Pointer to #SPR holding data for single sprite that will be moved
;  - IY: Pointer to #FE
_BounceOfPlatform

    LD A, (IY + FE.BOUNCE_OFF_CNT)
    CP 0
    JR Z, .afterDelay
    DEC A
    LD (IY + FE.BOUNCE_OFF_CNT), A
    RET
.afterDelay

    ; Check the collision with the platform
    PUSH IX, IY, HL
    LD HL, IX
    ADD HL, SPR.X                               ; Param next method

    CALL pl.PlatformBounceOff
    POP HL, IY, IX

    CP pl.PL_DHIT_NO
    RET Z

    CP pl.PL_DHIT_LEFT
    JR Z, .bounceHorizontal

    CP pl.PL_DHIT_RIGHT
    JR Z, .bounceHorizontal

    CP pl.PL_DHIT_TOP
    JR Z, .bounceVertical

    CP pl.PL_DHIT_BOTTOM
    JR Z, .bounceVertical

.bounceHorizontal
    ; Enemy bounces from the platform's left/right, reverse movement

    ; Flip X direction
    LD A, (IY + FE.STATE)
    XOR STATE_DIR_X_MASK
    LD (IY + FE.STATE), A
    LD A, sr.SDB_BOUNCE_SIDE                    ; Bounce animation for #sr.LoadSpritePattern
    JR .bounced

    RET

.bounceVertical
  
    ; Enemy bounces from the platform's top/bottom, reverse movement

    ; Flip Y direction
    LD A, (IY + FE.STATE)
    XOR STATE_DIR_Y_MASK
    LD (IY + FE.STATE), A
    LD A, sr.SDB_BOUNCE_TOP                     ; Bounce animation for #sr.LoadSpritePattern

.bounced

    CALL sr.LoadSpritePattern

    LD A, BOUNCE_OFF_D10
    LD (IY + FE.BOUNCE_OFF_CNT), A

    CALL _DelayFollowing

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

    LD A, (IY + FE.STATE)
    AND STATE_DIR_X_MASK
    LD B, A

    LD A, sr.MVX_IN_D_1PX_ROL
    OR B
    LD D, A
    CALL sr.MoveX

    ; ##########################################
    ; Move Y - up/down
    CALL _InvertYForBounce

    BIT STATE_DIR_Y_BIT, (IY + FE.STATE)
    JR NZ, .moveUp                              ; Jump if bit 3 == 1

    ; Move down
    JR .afterMoveY
    LD A, sr.MOVE_Y_IN_DOWN

    ; Move up
.moveUp
    LD A, sr.MOVE_Y_IN_UP

.afterMoveY
    ; ##########################################
    CALL sr.MoveY                               ; A contains #MOVE_Y_IN_DOWN/UP

    CALL sr.SetSpriteId
    CALL sr.UpdateSpritePosition

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    _InvertYForBounce                     ;
;----------------------------------------------------------;
; Invert Y (#STATE_DIR_Y_BIT) if the enemy is close to the top/bottom of the screen
; Input
;  - IX: Pointer to #SPR holding data for single sprite that will be moved
;  - IY: Pointer to #FE
_InvertYForBounce

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
    ; Turn off following the Jetman for a few frames because the enemy bounces off
    CALL _DelayFollowing

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;            _TryRespawnNextFollowingEnemy                 ;
;----------------------------------------------------------;
; Input:
;  - IX: Pointer to #SPR holding data for single enemy
; Output:
;  - A:  _RET_YES_D1/_RET_NO_D0
_TryRespawnNextFollowingEnemy

    BIT sr.SPRITE_ST_VISIBLE_BIT, (IX + SPR.STATE)
    JR Z, .afterVisibilityCheck                 ; Skip this sprite if it's already visible
    
    LD A, _RET_NO_D0
    RET
.afterVisibilityCheck
    ; Sprite is hidden, check the dedicated delay before respawning.

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

    LD (IY + FE.RESPAWN_DELAY_CNT), A          ; The delay timer for the enemy is still ticking

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