;----------------------------------------------------------;
;                   Following Enemy                        ;
;----------------------------------------------------------;
    MODULE fe
    ; ### TO USE THIS MODULE: CALL dbs.SetupFollowingEnemyBank ###

freezeCnt               DB 0
FREEZE_ENEMIES_CNT      = 250

UPDATE_DIR_DELAY        = 10
updateDirDelay          BYTE UPDATE_DIR_DELAY

    STRUCT FE
STATE                   DB
RESPAWN_Y               DB                      ; Respawn Y position
RESPAWN_DELAY           DB                      ; Number of game loops delaying respawn
MOVE_DELAY              DB

; Values changed during runtime
MOVE_DELAY_CNT          DB                      ; Counts down from #FE.MOVE_DELAY to 0
RESPAWN_DELAY_CNT       DB                      ; Respawn delay counter, counts up from 0 to #FE.RESPAWN_DELAY
    ENDS

; VALUES for #FE.STATE
STATE_DIR_BIT           = 4                     ; Corresponds to #sr.MVX_IN_D_TOD_DIR_BIT, 1-move right (deploy left), 0-move left (deploy right)
STATE_DIR_MASK          = %000'1'0000           ; Reset all but #STATE_DIR_BIT

STATE_MOVE_RIGHT        = %000'1'0000           ; Deploy on the left side of the screen and move right
STATE_MOVE_LEFT         = %000'0'0000           ; Deploy on the right side of the screen and move left

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
fEnemySize              BYTE 2

fEnemy01
    FE {STATE_MOVE_RIGHT /*STATE*/, 080/*RESPAWN_Y*/, 01/*RESPAWN_DELAY*/, 02/*MOVE_DELAY*/, 0/*MOVE_DELAY_CNT*/, 0/*RESPAWN_DELAY_CNT*/}

fEnemy02
    FE {STATE_MOVE_LEFT/*STATE*/, 120/*RESPAWN_Y*/, 01/*RESPAWN_DELAY*/, 03/*MOVE_DELAY*/, 0/*MOVE_DELAY_CNT*/, 0/*RESPAWN_DELAY_CNT*/}

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
;                       _MoveEnemy                         ;
;----------------------------------------------------------;
; Input
;  - IX: Pointer to #SPR holding data for single sprite that will be moved
;  - IY: Pointer to #FE
_MoveEnemy

    ; Set sprite ID in hardware
    CALL sr.SetSpriteId

    ; Copy move left/right from state
    LD A, (IY + FE.STATE)
    AND STATE_DIR_MASK
    LD B, A

    LD A, sr.MVX_IN_D_1PX_ROL
    OR B
    LD D, A
    CALL sr.MoveX

    CALL sr.UpdateSpritePosition                ; Move sprite to new X,Y coordinates

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
    BIT STATE_DIR_BIT, (IY + FE.STATE)
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