;----------------------------------------------------------;
;       Single Enemy and Formation (Pattern Enemy)         ;
;----------------------------------------------------------;
    MODULE enp

; Enemies fly by a given hardcoded pattern. This file contains generic logic for such enemies 
; In general, there are two kinds of enemies: 
; - single enemies that fly independently from each other (es_enemy_single.asm), and 
; - pattern enemies that fly together (ep_enemy_pattern.asm)

; Extends #SPR by additional params.
    STRUCT ENP
; Bits:
;   - 0:    #ENP_ALONG_BIT
;   - 1:    #ENP_DEPLOY_BIT
SETUP                   DB    
MOVE_DELAY_CNT          DB                      ; Move delay counter, counting down. Move delay is specified in the move pattern, byte 2, bits 8-5. Bit 0-4 is the repetition counter
RESPAWN_DELAY           DB                      ; Number of game loops delaying respawn
RESPAWN_DELAY_CNT       DB                      ; Respawn delay counter
RESPAWN_Y               DB                      ; Respawn Y position
MOVE_PAT_POINTER        DW                      ; Pointer to the movement pattern (#movePatternXX)
MOVE_PAT_POS            DB                      ; Position in #MOVE_PAT_POINTER. Counts from #MOVE_PAT_STEP_OFFSET to #movePatternXX
MOVE_PAT_STEP           DB                      ; Counters X,Y from current move pattern
MOVE_PAT_STEP_RCNT      DB                      ; Counter for repetition of single move pattern st Counts towards 0
    ENDS

; Bits 4-7 on sr.SPR.STATE will be used here:
ENP_ALONG_BIT           = 0                     ; 1 - avoid platforms by flying along them, 0 - hit platform
ENP_DEPLOY_BIT          = 1                     ; 1 - deploy enemy on the left, 0 - on the right

ENP_S_RIGHT_ALONG       = %000000'0'1
ENP_S_RIGHT_HIT         = %000000'0'0
ENP_S_LEFT_ALONG        = %000000'1'1
ENP_S_LEFT_HIT          = %000000'1'0

MOVE_DELAY_CNT_INC      = %0001'0000 

; Setup values loaded for each level for #SPR
    STRUCT ENPS
RESPAWN_Y               DB                      ; Value for: ENP.RESPAWN_Y
RESPAWN_DELAY           DB                      ; Value for: ENP.RESPAWN_DELAY
MOVE_PAT_POINTER        DW                      ; Value for: ENP.MOVE_PAT_POINTER
SDB_INIT                DB                      ; Value for: sr.SPR.SDB_INIT
SETUP                   DB                      ; Value for: ENP.SETUP
    ENDS

RESPAWN_OFF             = 255

KILL_FEW                = 7

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
; 3:    #MOVE_PAT_X_TOD_DIR_BIT
; 4-6:  Number of pixels to move on Y axis
; 7:    #MOVE_PAT_Y_TOD_DIR_BIT
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
MOVE_PAT_X_TOD_DIR_BIT  = 3
MOVE_PAT_X_TOD_DIR_MASK = %0'000'1'000 

MOVE_PAT_Y_MASK         = %0'111'0'000 
MOVE_PAT_Y_ADD          = %0'001'0'000 

MOVE_PAT_Y_TOD_DIR_MASK = %1'000'0'000 

; Determines whether Y should be decremented (0 - move up) or incremented (1 - move down) in each iteration
MOVE_PAT_Y_TOD_DIR_BIT  = 7

MOVE_PAT_XY_MASK        = %0'111'0'111 
MOVE_PAT_XY_MASK_RES    = %1'000'1'000 

MOVE_STEP_SIZE          = 2                     ; Each move step in the pattern takes two bytes: pattern and delay/number of repeats
MOVE_STEP_CNT_OFF       = 1
MOVE_PAT_STEP_OFFSET    = 1                     ; Data for move pattern starts at byte 1, byte 0 provides size
MOVE_PAT_REPEAT_MASK    = %0000'1111 
MOVE_PAT_DELAY_MASK     = %1111'0000 

MOVE_DELAY_3X           = %0000'0000            ; Delay 0 moves the enemy by 3 pixels during a single frame.
MOVE_DELAY_2X           = %0001'0000            ; Delay 1 moves the enemy by 2 pixels during a single frame.
DEC_MOVE_DELAY          = %0001'0000 

MOVEX_SETUP             = %000'0'0000           ; Input mask for MoveX. Move the sprite by one pixel and roll over on the screen end

;----------------------------------------------------------;
;         CopyEnpsToEnpMovePatternEnemies                  ;
;----------------------------------------------------------;
; Input:
;   - IX: Pointer to #ENPS array
;   - IY: Pointer to #ENP array
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
;   - IY: Pointer to #ENP array.
ResetEnp

    XOR A
    LD (IY + ENP.MOVE_DELAY_CNT), A
    LD (IY + ENP.MOVE_PAT_STEP), A
    LD (IY + ENP.MOVE_PAT_STEP_RCNT), A
    LD (IY + ENP.RESPAWN_DELAY_CNT), A

    LD A, RESPAWN_OFF
    LD (IY + ENP.RESPAWN_DELAY), A

    LD A, MOVE_PAT_STEP_OFFSET
    LD (IY + ENP.MOVE_PAT_POS), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   ResetPatternEnemies                    ;
;----------------------------------------------------------;
; Resets #sr.SPR and linked #ENP
; Input:
;  - IX:  Pointer to the #sr.SPR array
;  - B:   Size of the #sr.SPR and #ENP array (both will be modified)
ResetPatternEnemies

.enemyLoop
    CALL sr.ResetSprite
    
    ; Load extra data for this sprite to IY.
    LD DE, (IX + sr.SPR.EXT_DATA_POINTER)
    LD IY, DE

    CALL ResetEnp

    LD A, MOVE_PAT_STEP_OFFSET
    LD (IY + ENP.MOVE_PAT_POS), A

    ; ##########################################
    ; Next sprite
    LD DE, IX
    ADD DE, sr.SPR
    LD IX, DE
    DJNZ .enemyLoop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 AnimatePatternEnemies                    ;
;----------------------------------------------------------;
AnimatePatternEnemies

    CALL dbs.SetupArraysBank

    ; ##########################################
    ; Animate single enemy
    LD IX, dba.singleEnemySprites
    LD A, dba.ENEMY_SINGLE_SIZE
    LD B, A
    CALL sr.AnimateSprites

    ; ##########################################
    ; Animate formation enemy
    LD IX, dba.formationEnemySprites
    LD B, dba.ENEMY_FORMATION_SIZE
    CALL sr.AnimateSprites

    RET                                         ; ## END of the function ##


;----------------------------------------------------------;
;                  KillFewPatternEnemies                   ;
;----------------------------------------------------------;
KillFewPatternEnemies

    LD B, KILL_FEW
.killLoop
    PUSH BC
    CALL enp.KillOnePatternEnemy
    POP BC
    DJNZ .killLoop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  KillOnePatternEnemy                     ;
;----------------------------------------------------------;
KillOnePatternEnemy

    CALL dbs.SetupArraysBank

    ; ##########################################
    ; Kill single enemy
    LD IX, dba.singleEnemySprites
    LD A, dba.ENEMY_SINGLE_SIZE
    LD B, A
    CALL sr.KillOneSprite

    ; ##########################################
    ; Kill formation enemy
    LD IX, dba.formationEnemySprites
    LD A, dba.ENEMY_FORMATION_SIZE
    LD B, A
    CALL sr.KillOneSprite

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  HidePatternEnemies                      ;
;----------------------------------------------------------;
HidePatternEnemies

    CALL dbs.SetupArraysBank

    ; ##########################################
    ; Hide single enemies
    LD IX, dba.singleEnemySprites
    LD A, dba.ENEMY_SINGLE_SIZE
    LD B, A 
    CALL sr.HideAllSimpleSprites

    ; ##########################################
    ; Hide formation enemies
    LD IX, dba.formationEnemySprites
    LD A, dba.ENEMY_FORMATION_SIZE
    LD B, A
    CALL sr.HideAllSimpleSprites

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  MovePatternEnemies                      ;
;----------------------------------------------------------;
; Input:
;  - IX: Pointer to array #sr.SPR
;  - B:  Number of elements in array given by IX
; Moves single enemies and those in formation
; Modifies: ALL
MovePatternEnemies
    
    CALL dbs.SetupArraysBank

    ; Loop ever all enemies skipping hidden 
.enemyLoop
    PUSH BC                                     ; Preserve B for loop counter

    ; Ignore this sprite if it's hidden
    LD A, (IX + sr.SPR.STATE)
    AND sr.SPRITE_ST_VISIBLE                    ; Reset all bits but visibility
    CP 0
    JR Z, .continue                             ; Jump if visibility is not set (sprite is hidden)

    ; Load extra data for this sprite to IY
    LD BC, (IX + sr.SPR.EXT_DATA_POINTER)
    LD IY, BC

    ; Slow down movement by decrementing the counter until it reaches 0
    LD A, (IY + ENP.MOVE_DELAY_CNT)
    CP 0                                        ; No delay? -> move at full speed
    JR Z, .afterDelayMove

    ; Delaying movement, decrement delay counter
    SUB MOVE_DELAY_CNT_INC
    LD (IY + ENP.MOVE_DELAY_CNT), A

    CP 0                                        
    JR NZ, .continue                            ; Skip enemy if the delay counter > 0

    CALL _LoadMoveDelay     
    LD (IY + ENP.MOVE_DELAY_CNT), A             ; Reset counter, A has the max value of delay counter

.afterDelayMove

    ; ##########################################
    ; Sprite is visible, move it!
    PUSH IY
    CALL _MoveEnemy
    POP IY

    ; Tripple movement speed if move delay is 0
    CALL _LoadMoveDelay
    CP MOVE_DELAY_3X
    JR NZ, .after3x
    PUSH IY
    CALL _MoveEnemy
    POP IY
    CALL _MoveEnemy
    JR .continue
.after3x    

    ; Double movement speed if move delay is 1
    CP MOVE_DELAY_2X
    JR NZ, .continue
    CALL _MoveEnemy

.continue   
    ; ##########################################
    ; Move IX to the beginning of the next #SPR
    LD DE, sr.SPR
    ADD IX, DE

    ; ##########################################
    POP BC
    DJNZ .enemyLoop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 RespawnPatternEnemy                      ;
;----------------------------------------------------------;
; Respawn single or formation
; Input
;  - IX:    Pointer to #SPR holding data for single enemy
; Output:
; - A:      RES_SE_OUT_XXX
RES_SE_OUT_YES                  = 1             ; Enemy did respawn
RES_SE_OUT_NO                   = 0             ; Enemy did not respawn
; Modifies: all
RespawnPatternEnemy

    BIT sr.SPRITE_ST_VISIBLE_BIT, (IX + sr.SPR.STATE)
    JR Z, .afterVisibilityCheck                 ; Skip this sprite if it's already visible
    
    LD A, RES_SE_OUT_NO
    RET
.afterVisibilityCheck
    ; Sprite is hidden, check the dedicated delay before respawning.

    ; Load extra sprite data (#ENP) to IY
    LD BC, (IX + sr.SPR.EXT_DATA_POINTER)
    LD IY, BC
    
    ; There are two respawn delay timers. The first is global (#respawnDelayCnt) and ensures that multiple enemies do not respawn at the 
    ; same time. The second timer can be configured for a single enemy, which further delays its comeback. Keep in mind, that 
    ; #respawnDelayCnt applies only to single enemies and not to formation.
    LD A, (IY + ENP.RESPAWN_DELAY)

    ; Enemy disabled?
    CP enp.RESPAWN_OFF
    JR NZ, .respawnOn

    LD A, RES_SE_OUT_NO
    RET
.respawnOn

    CP 0
    JR Z, .afterEnemyRespawnDelay               ; Jump if there is no extra delay for this enemy
        
    LD B, A
    LD A, (IY + ENP.RESPAWN_DELAY_CNT)
    INC A
    CP B
    JR Z, .afterEnemyRespawnDelay               ; Jump if the timer reaches respawn delay

    LD (IY + ENP.RESPAWN_DELAY_CNT), A          ; The delay timer for the enemy is still ticking

    LD A, RES_SE_OUT_NO
    RET
.afterEnemyRespawnDelay

    ; Respawn enemy, first mark it as visible.
    LD A, (IX + sr.SPR.STATE)
    CALL sr.SetStateVisible

    ; Reset counters and move pattern
    XOR A                                       ; Set A to 0
    LD (IY + ENP.RESPAWN_DELAY_CNT), A

    CALL _LoadMoveDelay
    CALL _SetDelayCnt

    CALL _RestartMovePattern

    ; Set Y (horizontal respawn)
    LD A,  (IY + ENP.RESPAWN_Y)
    LD (IX + sr.SPR.Y), A

    ; Set X to left or right side of the screen
    BIT ENP_DEPLOY_BIT, (IY + ENP.SETUP)
    JR NZ, .deployLeft                          ; Jump if bit is 0 -> deploy left

    ; Deploy right
    LD BC, _GSC_X_MAX_D315
    SET sr.SPRITE_ST_MIRROR_X_BIT, (IX + sr.SPR.STATE)  ; Mirror sprite, because it deploys on the right and moves to the left side
    JR .afterLR
.deployLeft
    RES sr.SPRITE_ST_MIRROR_X_BIT, (IX + sr.SPR.STATE)  ; Do not mirror sprite (this could be set if in another level it was moving right)
    ; Deploy left
    LD BC, _GSC_X_MIN_D0

.afterLR
    LD (IX + sr.SPR.X), BC
    CALL sr.SetSpriteId                         ; Set the ID of the sprite for the following commands
    CALL sr.ShowSprite

    LD A, RES_SE_OUT_YES

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                      _LoadMoveDelay                      ;
;----------------------------------------------------------;
; Input
;  - IY:    Pointer to #ENP holding data for single sprite
; Output:
;  - A;     Value of move delay counter for this pattern (bits 8-5)
; Modifies: A, HL
_LoadMoveDelay

    CALL _LoadCurrentMoveStep
    INC HL
    LD A, (HL)                                  ; Load the delay/repetition counter into A, reset all bits but delay
    AND MOVE_PAT_DELAY_MASK

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     _MoveEnemyX                          ;
;----------------------------------------------------------;
; Move enemy one step left or right
; Input
;  - IX:    Pointer to #SPR
;  - IY:    Pointer to #ENP
;  - HL:    Points to the current move pattern
; Modifies: A, BC
_MoveEnemyX

    LD D, MOVEX_SETUP                           ; D contains configuration for MoveX
    BIT ENP_DEPLOY_BIT, (IY + ENP.SETUP)
    JR NZ, .deployedLeft                        ; Jump if bit is 0 -> deploy left

    ; Enemy was deployed on the right, invert #MOVE_PAT_X_TOD_DIR_BIT
    BIT MOVE_PAT_X_TOD_DIR_BIT, (HL)
    JR NZ, .moveLeft                            ; Jump if bit is set to 1 (right), invert right -> left
    JR .moveRight                               ; Bit is 0 -> move left

.deployedLeft
    ; Enemy was deployed on the left, do not invert #MOVE_PAT_X_TOD_DIR_BIT
    BIT MOVE_PAT_X_TOD_DIR_BIT, (HL)
    JR NZ, .moveRight                           ; Jump if bit is set to 1 (right)
    JR .moveLeft                                ; Bit is 0 -> move left

.moveRight                                      ; Move right
    LD D, sr.MVX_IN_D_1PX_ROL
    SET sr.MVX_IN_D_TOD_DIR_BIT, D
    PUSH HL
    CALL sr.MoveX   
    POP HL
    RET

.moveLeft                                       ; Move left
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
;  - IX:    Pointer to #SPR holding data for single sprite that will be moved
; Modifies: all
_MoveEnemy

    ; Move the Sprite horizontally if it has been hit and it's dying
    LD A, (IX + sr.SPR.STATE)
    CALL sr.SetSpriteId                         ; Set sprite ID in hardware
    
    ; Load #ENP for this sprite to IY
    LD BC, (IX + sr.SPR.EXT_DATA_POINTER)
    LD IY, BC
    CALL _LoadCurrentMoveStep

    ; Current register values:
    ;  - IX: pointer to #SPR for current sprite
    ;  - IY: pointer to #ENP for current sprite
    ;  - HL: pointer to current position in #movePattern

    BIT sr.SPRITE_ST_ACTIVE_BIT, (IX + sr.SPR.STATE)
    JR NZ, .afterAliveCheck                     ; Jump if sprite is alive

    ; Sprite is not alive -> move it horizontally while it's exploding
    CALL _MoveEnemyX
    CALL sr.UpdateSpritePosition                ; Move sprite to new X,Y coordinates

    RET                                         ; Return - sprite is exploding
.afterAliveCheck

    ; ##########################################
    ; Should the enemy move along the platform to avoid collision?
    BIT ENP_ALONG_BIT, (IY + ENP.SETUP)
    JR Z, .afterMoveAlong                       ; Jump if move along is not set

    ; Check the collision with the platform
    PUSH IY, HL
    CALL pl.PlatformSpriteClose
    POP HL, IY

    CP A, pl.PL_HIT_RET_A_NO
    JR Z, .afterMoveAlong                       ; Jump if there is no collision

    ; Avoid collision with the platform by moving along it
    CALL _MoveEnemyX
    CALL sr.UpdateSpritePosition                ; Move sprite to new X,Y coordinates
    RET                                         ; Return, sprite moves along platform
.afterMoveAlong

    ; ##########################################
    ; Check if counter for X has already reached 0, or is set to 0
    LD A, (IY + ENP.MOVE_PAT_STEP)              ; A contains current X,Y counters
    AND MOVE_PAT_X_MASK                         ; Reset all but X
    CP 0
    JR Z, .afterMoveLR                          ; Jump if the counter for X has reached 0
    
    ; Decrement X counter
    LD A, (IY + ENP.MOVE_PAT_STEP)              ; A contains current X,Y counters
    SUB MOVE_PAT_X_ADD                          ; Decrement X counter by 1
    LD (IY + ENP.MOVE_PAT_STEP), A

    CALL _MoveEnemyX
.afterMoveLR

    ; ##########################################
    ; Check if counter for Y has already reached 0, or is set to 0.
    LD A, (IY + ENP.MOVE_PAT_STEP)              ; A contains current X,Y counters
    AND MOVE_PAT_Y_MASK                         ; Reset all but Y
    CP 0
    JR Z, .afterChangeY                         ; Jump if the counter for Y has reached 0

    ; Enemy should move on Y
    LD A, (IY + ENP.MOVE_PAT_STEP)              ; A contains current X,Y counters
    SUB MOVE_PAT_Y_ADD                          ; Decrement Y counter by 1
    LD (IY + ENP.MOVE_PAT_STEP), A  

    ; Move on Y-axis one pixel up or down?
    LD A, (HL)                                  ; A contains current pattern
    BIT MOVE_PAT_Y_TOD_DIR_BIT, A
    JR Z, .moveUp                               ; Jump if sprite should move up

    ; Move on pixel down.
    LD A, sr.MOVE_Y_IN_DOWN
    CALL sr.MoveY
    CP sr.MOVE_RET_HIDDEN
    JR NZ, .afterChangeY                        ; Jump is sprite is not hidden

    RET                                         ; Stop moving this sprite, it's hidden

.moveUp
    ; Move on pixel up
    LD A, sr.MOVE_Y_IN_UP
    CALL sr.MoveY
    CP sr.MOVE_RET_HIDDEN
    JR NZ,.afterChangeY                         ; Jump is sprite is not hidden

    RET                                         ; Stop moving this sprite, it's hidden

.afterChangeY
    CALL sr.UpdateSpritePosition                ; Move sprite to new X,Y coordinates

    ; Check if X and Y have reached 0
    LD A, (IY + ENP.MOVE_PAT_STEP)              ; A contains pattern counter
    AND MOVE_PAT_XY_MASK                        ; Reset all but max X,Y values
    CP 0
    JR Z, .resetXYCounters                      ; Jump if X and Y counters has reached 0

    JR .checkPlatformHit

.resetXYCounters
    ; ##########################################
    ; X and Y have reached the max value. First, reset the X and Y counters, and afterward, decrement the repetition counter.
    LD A, (HL)                                  ; X, Y counters will be set to max value as we count down towards 0
    LD (IY + ENP.MOVE_PAT_STEP), A  

    LD A, (IY + ENP.MOVE_PAT_STEP_RCNT)         ; decrement the repetition counter
    DEC A
    CP 0
    JR Z, .nextMovePattern                      ; Jump if repetition counter for single step has reached 0
    
    ; Decrement repetition counter for move step and return
    LD (IY + ENP.MOVE_PAT_STEP_RCNT), A         ; Store decremented counter
    
    JR .checkPlatformHit

.nextMovePattern
    ; ##########################################
    ; Setup next move pattern
    LD A, (IY + ENP.MOVE_PAT_POS)               ; A contains the current position in the move pattern

    ADD MOVE_STEP_SIZE                          ; Increment the position to the next pattern and store it
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
    CP A, pl.PL_HIT_RET_A_NO
    RET Z                                       ; Return if there is no collision
    CALL sr.SpriteHit                           ; Explode!
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  _LoadCurrentMoveStep                    ;
;----------------------------------------------------------;
; Load HL that points to the current move pattern
; Input
;  - IY:    Pointer to #ENP for current sprite
; Output:
;  - HL:    Points to the current move pattern
; Modifies: A
_LoadCurrentMoveStep

    LD HL, (IY + ENP.MOVE_PAT_POINTER)          ; HL points to start of the #movePattern
    LD A, (IY + ENP.MOVE_PAT_POS)
    ADD HL, A                                   ; Move HL from the beginning of the move pattern to current element

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  _RestartMovePattern                     ;
;----------------------------------------------------------;
; This method resets the move pattern (#ENP) so animation can start from the first move pattern. It does not modify #SPR.
; Input
;  - IX:    Pointer to #SPR holding data for single sprite that will be moved
;  - IY:    Pointer to #ENP for current sprite
; Modifies: A, IY, BC, HL
_RestartMovePattern
    
    LD BC, (IX + sr.SPR.EXT_DATA_POINTER)       ; Load #ENP for this sprite to IY
    LD IY, BC
    LD HL, (IY + ENP.MOVE_PAT_POINTER)          ; HL points to start of the #movePattern, that is the amount of elements in this pattern
    INC HL                                      ; HL points to the first move pattern element
    
    ; X, Y counters will be set to max value as we count down towards 0
    LD A, (HL)
    LD (IY + ENP.MOVE_PAT_STEP), A  

    ; Set position at the first pattern, this is one byte after the start of #movePatternXX
    LD A, MOVE_PAT_STEP_OFFSET
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
;  - A: Delay counter from configuration.
_SetDelayCnt

    AND MOVE_PAT_DELAY_MASK                     ; Leave only delay counter bits

    ; If the delay counter is above 0, decrement it by 2 if possible. The reason for this is that delay 0 and delay 1 move by 3 or 2 
    ; pixels per frame, so there is no delay at all. Delay 2 should move by 1 pixel, and first delay 3 should skip one pixel.
    CP 0
    JR Z, .storeA
    SUB DEC_MOVE_DELAY                          ; First decrement, try again to decrement if still above 0
    CP 0
    JR Z, .storeA
    SUB DEC_MOVE_DELAY
.storeA
    LD (IY + ENP.MOVE_DELAY_CNT), A
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE