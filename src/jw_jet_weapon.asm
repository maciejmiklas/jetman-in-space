;----------------------------------------------------------;
;                      Jetman Weapon                       ;
;----------------------------------------------------------;
    MODULE jw


; Adjustment to place the first laser beam next to Jetman so that it looks like it has been fired from the laser gun.
FIRE_ADJUST_X_D10       = 10
FIRE_ADJUST_Y_D4        = 4
FIRE_THICKNESS_D10      = 10

JM_FIRE_DELAY_MAX       = 15
JM_FIRE_DELAY_MIN       = 3
JM_FIRE_SPEED_UP        = 4

; Sprites for single shots (#shots), based on #SPR.
shots
    sr.SPR {10/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
    sr.SPR {11/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
    sr.SPR {12/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
    sr.SPR {13/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
    sr.SPR {14/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
    sr.SPR {15/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
    sr.SPR {16/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
    sr.SPR {17/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
    sr.SPR {18/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
    sr.SPR {19/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
    sr.SPR {91/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
    sr.SPR {92/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
    sr.SPR {93/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
    sr.SPR {94/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
    sr.SPR {95/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
SHOTS_SIZE              = 15                    ; Amount of shots that can be simultaneously fired. Max is limited by #shotsXX

; The counter is incremented with each animation frame and reset when the fire is pressed. Fire can only be pressed when the counter reaches #JM_FIRE_DELAY.
fireDelayCnt            BYTE 0
fireDelay               BYTE JM_FIRE_DELAY_MAX

STATE_SHOT_DIR_BIT      = 5                     ; Bit for #sr.SPR.STATE, 1 - shot moves right, 0 - shot moves left.

fireFxDelayCnt          BYTE 0
fireFxDelay             BYTE FIRE_FX_DELAY_INIT
FIRE_FX_DELAY_INIT      = 2
FIRE_FX_DELAY_SOUND2    = 5                     ; When delay reaches this value play #af.FX_FIRE2
FIRE_FX_DELAY_2X        = 5

fireFxOn                BYTE 1
FIRE_FX_ON              = 1
FIRE_FX_OFF             = 0

;----------------------------------------------------------;
;                      #FlipFireFx                         ;
;----------------------------------------------------------;
FlipFireFx

    LD A, (fireFxOn)
    CPL
    LD (fireFxOn), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      #ResetWeapon                        ;
;----------------------------------------------------------;
ResetWeapon

    XOR A
    LD (fireFxDelayCnt), A
    LD (fireDelayCnt), A

    LD A, JM_FIRE_DELAY_MAX
    LD (fireDelay), A

    LD A, FIRE_FX_DELAY_INIT
    LD (fireFxDelay), A
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     #FireSpeedUp                         ;
;----------------------------------------------------------;
FireSpeedUp

    LD A, (fireDelay)
    CP JM_FIRE_DELAY_MIN
    RET Z

    LD A, JM_FIRE_SPEED_UP
    LD B, A
.loop
    CALL _FireDelayDown
    DJNZ .loop

    ; ##########################################
    ; Slow down FX
    LD A, (fireFxDelay)
    INC A
    CP FIRE_FX_DELAY_2X
    JR NZ, .doNotDouble
    INC A
    INC A
.doNotDouble
    LD (fireFxDelay), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       #HideShots                         ;
;----------------------------------------------------------;
HideShots

    XOR A
    LD (fireDelayCnt), A

    ; Loop ever all #shots skipping hidden shots.
    LD IX, shots                                ; IX points to the shot.
    LD B, SHOTS_SIZE 
.shotsLoop

    CALL sr.SetSpriteId                         ; Set the ID of the sprite for the following commands.
    CALL sp.HideSprite
    CALL sr.ResetSprite

    ; ##########################################
    ; Move IX to the beginning of the next #shotsXX.
    LD DE, sr.SPR
    ADD IX, DE
    DJNZ .shotsLoop                             ; Jump if B > 0 (loop starts with B = #SPR).

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   #WeaponHitEnemies                      ;
;----------------------------------------------------------;
WeaponHitEnemies

    CALL dbs.SetupArraysBank

    ; ##########################################
    LD IX, db.singleEnemySprites
    LD A, (ens.singleEnemySize)
    LD B, A
    CALL _CheckHitEnemies

    ; ##########################################
    LD IX, db.formationEnemySprites
    LD B, db.ENEMY_FORMATION_SIZE
    CALL _CheckHitEnemies

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      #ShotsCollision                     ;
;----------------------------------------------------------;
; The method checks whether any active laser beam has hit the sprite given by X/Y.
; Input:
; - DE:  X of the sprite.
; - C:   Y of the sprite.
; Output:
; - A:   values:
; Modifies: All
SHOT_HIT                    = 1
SHOT_MISS                   = 0
ShotsCollision

    ; Loop ever all #shots skipping hidden shots.
    LD IX, shots                                ; IX points to the shot.
    LD B, SHOTS_SIZE 
.shotsLoop
    PUSH BC, DE
    LD A, (IX + sr.SPR.STATE)

    ; Skip hidden laser shoots for collision detection.
    BIT sr.SPRITE_ST_VISIBLE_BIT, A
    JR Z, .continueShotsLoop

    ; Skip inactive laser shoots for collision detection.
    BIT sr.SPRITE_ST_ACTIVE_BIT, A
    JR Z, .continueShotsLoop

    ; Compare X coordinate of the sprite and the shot, HL holds X of the sprite.
    LD HL, (IX + sr.SPR.X)                  ; X of the shot.
    
    ; Subtracts DE from HL and check whether the result is less than or equal to A.
    SBC DE, HL
    CALL ut.AbsDE

    ; We will compare E with FIRE_THICKNESS_D10 but first ensure that D is 0. Otherwise, the following can happen: DE = 300, HL = 30.
    ; The distance is 270. However, 270 occupies two bytes: D=1, E=14. If we compare only E and ignore that D is 1, we will have a hit!
    XOR A                                       ; Set A to 0.
    CP D
    JR NZ, .continueShotsLoop

    LD A, FIRE_THICKNESS_D10
    CP E                                        ; SUB result is < 256, we can ignore H.
    JR C, .continueShotsLoop                    ; Jump if A(#FIRE_THICKNESS_D10) < L.
    
    ; We are here because the shot is horizontal with the enemy, now check the vertical match.
    LD A, (IX + sr.SPR.Y)                       ; A holds Y from the shot.

    ; Subtracts C from A and check whether the result is less than or equal to #FIRE_THICKNESS_D10.
    SUB C
    CALL ut.AbsA
    LD D, A
    LD A, FIRE_THICKNESS_D10
    CP D
    JR C, .continueShotsLoop                    ; Jump if A(#FIRE_THICKNESS_D10) < D.

    ; We have hit! Hide shot and return.
    CALL sr.HideSimpleSprite

    LD A, SHOT_HIT
    POP DE, BC
    RET

.continueShotsLoop
    ; Move IX to the beginning of the next #shotsXX.
    LD DE, sr.SPR
    ADD IX, DE

    POP DE, BC
    DJNZ .shotsLoop                             ; Jump if B > 0 (loop starts with B = #SPR).

    ; There was no hit.
    LD A, SHOT_MISS

    RET                                         ; ## END of the function ##.

;----------------------------------------------------------;
;                      #MoveShots                          ;
;----------------------------------------------------------;
; Modifies: ALL.
MoveShots

    ; Loop ever all shots# skipping hidden sprites.
    LD IX, shots    
    LD B, SHOTS_SIZE 

.shootsLoop
    PUSH BC                                     ; Preserve B for loop counter.

    ; Skip hidden shoots.
    BIT sr.SPRITE_ST_VISIBLE_BIT, (IX + sr.SPR.STATE)
    JR Z, .continue

    ; Shot is visible, move it and update postion.
    CALL sr.SetSpriteId                         ; Set the ID of the sprite for the following commands.
    
    LD D, sr.MVX_IN_D_6PX_HIDE

    ; Setup move direction for shot.
    BIT STATE_SHOT_DIR_BIT, (IX + sr.SPR.STATE)
    JR Z, .shotDirLeft  
    
    ; Shot moves right.
    SET sr.MVX_IN_D_TOD_DIR_BIT, D
    JR .afterShotDir
.shotDirLeft    
    ; Shot moves left.
    RES sr.MVX_IN_D_TOD_DIR_BIT, D
.afterShotDir
    
    CALL sr.MoveX
    CALL sr.UpdateSpritePosition

    ; Skip collision detection if the shot is not alive - it has hit something already, and it's exploding.
    BIT sr.SPRITE_ST_ACTIVE_BIT, (IX + sr.SPR.STATE)
    JR Z, .afterPlatformCollision               ; Exit if sprite is not alive.

    ; Check the collision with the platform.
    CALL pl.PlatformWeaponHit
    CP A, pl.PL_HIT_RET_A_NO
    JR Z, .afterPlatformCollision
    CALL sr.SpriteHit
.afterPlatformCollision

.continue
    ; Move IX to the beginning of the next #shotsXX.
    LD DE, sr.SPR
    ADD IX, DE
    POP BC
    DJNZ .shootsLoop                            ; Jump if B > 0 (loop starts with B = #SPR).

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  #FireDelayCounter                       ;
;----------------------------------------------------------;
FireDelayCounter
    
    ; Increment shot counter.
    LD A, (fireDelay)
    LD B, A
    LD A, (fireDelayCnt)
    CP B
    RET Z                                       ; Do increment the delay counter when it has reached the required value.

    INC A
    LD (fireDelayCnt), A
     
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      #AnimateShots                       ;
;----------------------------------------------------------;
AnimateShots

    LD IX, shots
    LD B, SHOTS_SIZE 
    CALL sr.AnimateSprites

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      #FireReleased                       ;
;----------------------------------------------------------;
FireReleased

    ; Reset fire delay on fire button release so that FX plays immediately after pressing the subsequent fire. 
    XOR A
    LD (fireFxDelayCnt), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                          #Fire                           ;
;----------------------------------------------------------;
Fire

    ; Check delay to limit fire speed.
    LD A, (fireDelay)
    LD B, A
    LD A, (fireDelayCnt)
    CP B
    RET NZ                                      ; Return if the delay counter did not reach the defined value.

    ; We can fire, reset counter.
    XOR A                                       ; Set A to 0.
    LD (fireDelayCnt), A

    ; Find the first inactive (sprite hidden) shot.
    LD IX, shots
    LD DE, sr.SPR
    LD B, SHOTS_SIZE 
.findLoop

    ; Check whether the current #shotsX is not visible and can be reused.
    BIT sr.SPRITE_ST_VISIBLE_BIT, (IX + sr.SPR.STATE)
    JR Z, .afterFound                           ; Jump if visibility is not set -> hidden, can be reused.

    ; Move HL to the beginning of the next #shotsX (see "LD DE, SPR" above).
    ADD IX, DE
    DJNZ .findLoop                              ; Jump if B > 0 (starts with B = #SPR).
    RET                                         ; Loop has ended without finding free #shotsX.

.afterFound                                     
    ; We are here because free #shotsX has been found, and IX points to it.

    ; Is Jetman moving left or right?
    LD A, (gid.jetDirection)
    BIT gid.MOVE_LEFT_BIT, A
    JR NZ, .movingLeft                          ; Jump if Jetman is moving left.
    
    XOR A                                       ; A will hold sr.SPR.STATE.
    ; Jetman is moving right, shot will move right also.
    SET STATE_SHOT_DIR_BIT, A                   ; Store shot direction in state.

    ; Set X coordinate for laser beam.
    LD HL, (jpo.jetX)
    ADD HL, FIRE_ADJUST_X_D10
    LD (IX + sr.SPR.X), HL

    JR .afterMoving
.movingLeft

    XOR A                                       ; A will hold sr.SPR.STATE.
    ; Jetman is moving left.
    RES STATE_SHOT_DIR_BIT, A                   ; Store shot direction in state.

    ; Set X coordinate for laser beam.
    LD HL, (jpo.jetX)
    ADD HL, -FIRE_ADJUST_X_D10
    LD (IX + sr.SPR.X), HL
.afterMoving

    CALL sr.SetStateVisible                     ; It will show sprite and store state from A.

    ; Set Y coordinate for laser beam.
    LD A, (jpo.jetY)
    ADD a, FIRE_ADJUST_Y_D4
    LD (IX + sr.SPR.Y), A

    ; Setup laser beam pattern, IX already points to the right memory address.
    CALL sr.SetSpriteId                         ; Set the ID of the sprite for the following commands.
    CALL sr.ShowSprite

    ; Call callback.
    CALL _WeaponFx

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                       #_WeaponFx                         ;
;----------------------------------------------------------;
_WeaponFx

    ; Do to play FX it it's off
    LD A, (fireFxOn)
    CP FIRE_FX_ON
    RET NZ

    ; Play FX every few game loops.
    LD A, (fireFxDelayCnt)
    CP 0
    JR NZ, .decFireFxCnt

    ; The delay counter is done, reset it, and play FX.
    LD A, (fireFxDelay)
    LD (fireFxDelayCnt), A

    ; Start playing different FX when the weapon fires at max speed.
    CP FIRE_FX_DELAY_SOUND2
    JR NC, .newSound
    LD A, af.FX_FIRE1
    JR .afterNewSound
.newSound
    LD A, af.FX_FIRE2
.afterNewSound
    CALL af.AfxPlay

    JR .afterFireFx
.decFireFxCnt
    DEC A
    LD (fireFxDelayCnt), A
.afterFireFx

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    #_CheckHitEnemies                     ;
;----------------------------------------------------------;
; Checks all active enemies given by IX for collision with leaser beam.
; Input
;  - IX:    Pointer to #SPR, the enemies.
;  - B:     Number of enemies in IX.
; Modifies: ALL
_CheckHitEnemies

.loop                                           ; Loop over every enemy.
    PUSH BC                                     ; Preserve B for loop counter.
    LD A, (IX + sr.SPR.STATE)
    BIT sr.SPRITE_ST_VISIBLE_BIT, A
    JR Z, .continue                             ; Jump if enemy is hidden.

    ; Skip collision detection if the enemy is not alive - it has hit something already, and it's exploding.
    BIT sr.SPRITE_ST_ACTIVE_BIT, A
    JR Z, .continue 
    
    ; Enemy is visible, check collision with leaser beam.
    LD DE, (IX + sr.SPR.X)                      ; X of the enemy.
    LD C, (IX + sr.SPR.Y)                       ; Y of the enemy.

    PUSH IX
    CALL ShotsCollision
    POP IX
    CP SHOT_HIT
    JR NZ, .continue                            ; Jump if there is no hit.

    ; We have hit!
    CALL gc.EnemyHit

.continue
    ; Move HL to the beginning of the next enemy.
    LD DE, sr.SPR
    ADD IX, DE

    POP BC
    DJNZ .loop                                  ; Jump if B > 0.

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    #_FireDelayDown                       ;
;----------------------------------------------------------;
_FireDelayDown

    LD A, (fireDelay)
    CP JM_FIRE_DELAY_MIN
    RET Z

    DEC A
    LD (fireDelay), A

    XOR A
    LD (fireDelayCnt), A

    RET                                         ; ## END of the function ##
;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE