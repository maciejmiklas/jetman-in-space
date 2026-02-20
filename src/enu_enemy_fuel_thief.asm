/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                       Fuel Thief                         ;
;----------------------------------------------------------;
    MODULE enu

    ; ### TO USE THIS MODULE: CALL dbs.SetupPatternEnemyBank ###

TS_DISABLED_D0          = 0
TS_WAITING_D1           = 1
TS_DEPLOYING_D2         = 2
TS_EXPLODES_D20         = 20
TS_RUNS_EMPTY_D30       = 30
TS_CARRIES_FUEL_D31     = 31
thiefState              DB TS_DISABLED_D0

THIEF_SIZE_D1           = 1
FUEL_SPRITE_ID_D97      = 97                    ; Sprite ID for the screen.
FUEL_SPRITE_REF_D17     = 17                    ; Sprite id from sprite file.
FUEL_HEIGHT_D226        = 226
DEPLOY_SIDE_RND_H30     = $30

thiefRespawnDelayCnt    DB 0
RESPAWN_DELAY_D22       = 22
RESPAWN_DEPLOYING_D16   = 16

MIN_FUEL_LEVEL_D6       = 6

;----------------------------------------------------------;
;                     DisableFuelThief                     ;
;----------------------------------------------------------;
DisableFuelThief

    CALL _HideFuelThief

    LD A, TS_DISABLED_D0
    LD (thiefState), A

    CALL _SetupFuelThief

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      EnableFuelThief                     ;
;----------------------------------------------------------;
EnableFuelThief

    CALL _HideFuelThief

    LD A, TS_WAITING_D1
    LD (thiefState), A

    CALL _SetupFuelThief

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      ThiefWeaponHit                      ;
;----------------------------------------------------------;
ThiefWeaponHit

    ; Do not execute it thief is not moving.
    LD A, (thiefState)
    CP TS_RUNS_EMPTY_D30
    RET C

    CALL _LoadSprToIxIy                         ; Load SPR to IX and ENP to IY

    ; Check weapon hit
    LD DE, (IX + SPR.X)
    LD C, (IX + SPR.Y)
    PUSH IX
    CALL jw.ShotsCollision
    POP IX
    RET NZ

    ; Weapon hit confirmed!
    LD A, TS_EXPLODES_D20
    LD (thiefState), A

    CALL sp.SpriteHit

    LD A, FUEL_SPRITE_ID_D97
    sp.SetIdAndHideSprite

    ; Restart deploy countdown.
    XOR A
    LD (thiefRespawnDelayCnt), A

    CALL gc.FuelThiefHit

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     RespawnFuelThief                     ;
;----------------------------------------------------------;
RespawnFuelThief

    ; Respawn if #TS_WAITING_D1, #TS_DEPLOYING_D2 or #TS_EXPLODES_D20.
    LD A, (thiefState)
    CP TS_WAITING_D1
    JR Z, .respawn

    CP TS_DEPLOYING_D2
    JR Z, .respawn

    CP TS_EXPLODES_D20
    RET NZ
.respawn

    ; ##########################################
    ; Does the rocket have enough fuel?
    CALL enur.LoadRocketElementCnt
    CP MIN_FUEL_LEVEL_D6
    RET C                                       ; Return if rocket does not have enough fuel.

    ; ##########################################
    ; Respawn thief only if no rocket tank is deployed for pickup. Otherwise, decrementing the element number would make picking up the 
    ; deployed one impossible.
    CALL enur.LoadRocketState
    CP ro.ROST_WAIT_DROP_D1
    RET NZ

    ; ##########################################
    ; Increment respawn delay counter.
    LD A, (thiefRespawnDelayCnt)
    INC A
    LD (thiefRespawnDelayCnt), A

    ; ##########################################
    ; Deploying starts few loops before running, and it's used to play sound before thief starts running.
    CP RESPAWN_DEPLOYING_D16
    JR NZ, .afterDeploying

    LD A, TS_DEPLOYING_D2
    LD (thiefState), A

    ; Reset the deployment countdown for the next fuel element because the thief is active.
    CALL enur.ResetDropNextDelay
.afterDeploying

    ; ##########################################
    ; Respawn thief.

    LD A, (thiefRespawnDelayCnt)
    CP RESPAWN_DELAY_D22
    RET NZ

    LD A, TS_RUNS_EMPTY_D30
    LD (thiefState), A

    CALL _LoadSprToIxIy

    ; Random left/right deployment.
    LD A, R
    CP DEPLOY_SIDE_RND_H30
    JR C, .deployRight
    LD (IY+ENP.SETUP), enp.ENP_LEFT_ALONG 
    JR .afterDeploySide
.deployRight
    LD (IY+ENP.SETUP), enp.ENP_RIGHT_ALONG 
.afterDeploySide

    ; Reset the deployment countdown for the next fuel element because the thief is active.
    CALL enur.ResetDropNextDelay
    CALL enp.RespawnPatternEnemy

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   AnimateFuelThief                       ;
;----------------------------------------------------------;
AnimateFuelThief

    ; Do not execute it thief is not moving/exploding.
    LD A, (thiefState)
    CP TS_EXPLODES_D20
    RET C

    LD IX, ena.fuelThiefSpr
    LD A, THIEF_SIZE_D1
    LD B, A
    CALL sp.AnimateSprites

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     MoveFuelThief                        ;
;----------------------------------------------------------;
MoveFuelThief

    ; Do not execute it thief is not moving.
    LD A, (thiefState)
    CP TS_RUNS_EMPTY_D30
    RET C

    ; ##########################################
    ; Load SPR to IX and ENP to IY.
    CALL _LoadSprToIxIy

    ; ##########################################
    ; Move sprite.
    LD A, THIEF_SIZE_D1
    LD B, A
    PUSH IX
    CALL enp.MovePatternEnemies
    POP IX

    ; ##########################################
    ; Hide if the thief has reached the left side of the screen, if he deployed right.
    BIT enp.ENP_BIT_DEPLOY_D1, (IY + ENP.SETUP)
    JR NZ, .notHideLeft                        ; Jump if bit is 0 -> deploy left.

    LD BC, (IX + SPR.X)
    LD A, B
    OR A                                        ; Same as CP 0, but faster.
    JR NZ, .notHideLeft
    LD A, C
    CP 5
    JR NC, .notHideLeft
    ; Hide sprite, is on the left side.
    CALL _HideFuelThief
    RET
.notHideLeft

    ; ##########################################
    ; Hide if the thief has reached the right side of the screen (315 =  $13B), if he deployed left.
    BIT enp.ENP_BIT_DEPLOY_D1, (IY + ENP.SETUP)
    JR Z, .notHideRight                        ; Jump if bit is 1 -> deploy right.

    LD BC, (IX + SPR.X)
    LD A, B
    CP 1
    JR NZ, .notHideRight
    LD A, C
    CP $3B
    JR C, .notHideRight
    ; Hide sprite, is on the right side
    CALL _HideFuelThief
    RET
.notHideRight

    ; ##########################################
    ; Check if the thief has reached the rocket to steal fuel.
    LD A, (thiefState)                          ; Do not take fuel twice ;)
    CP TS_RUNS_EMPTY_D30
    JR NZ, .notAtRocket

    LD BC, (IX + SPR.X)
    LD A, B                                     ; Rocket postion is 8 bit, ignore X postion if > 256 (9bit).
    CP 1
    JR Z, .notAtRocket

    CALL enur.LoadRocAssemblyX

    SUB C                                       ; Ignore B because X < 255, rocket assembly X is 8bit.
    CP roa.DROP_MARGX_D8
    JR NC, .notAtRocket
 
    ; ##########################################
    ; Pickup fuel tank.
    CALL enur.RemoveRocketElement
    LD A, TS_CARRIES_FUEL_D31
    LD (thiefState), A
.notAtRocket

    ; ##########################################
    ; Move fuel tank with thief.
    LD A, (thiefState)
    CP TS_CARRIES_FUEL_D31
    JR NZ, .notCarryFuel

    ; Set the ID of the sprite for the following commands.
    LD A, FUEL_SPRITE_ID_D97
    NEXTREG _SPR_REG_NR_H34, A

    ; Set sprite X coordinate.
    LD BC, (IX + SPR.X)
    LD A, C
    NEXTREG _SPR_REG_X_H35, A
    
    ; Set _SPR_REG_ATR2_H37 containing overflow bit from X position.
    LD A, B                                     ; Load MSB from X into A.
    AND _OVERFLOW_BIT                           ; Keep only an overflow bit.
    NEXTREG _SPR_REG_ATR2_H37, A

    ; Set Y coordinate
    LD A, FUEL_HEIGHT_D226
    NEXTREG _SPR_REG_Y_H36, A                   ; Set Y position.

    ; Set sprite pattern
    LD A, FUEL_SPRITE_REF_D17
    OR _SPR_ATTR3_SHOW                        ; Set show bit.
    NEXTREG _SPR_REG_ATR3_H38, A
.notCarryFuel

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                    _SetupFuelThief                       ;
;----------------------------------------------------------;
_SetupFuelThief

    LD IX, ena.fuelThiefSpr
    LD B, THIEF_SIZE_D1
    CALL enp.ResetPatternEnemies

    XOR A
    LD (IY + ENP.RESPAWN_DELAY), A
    LD (thiefRespawnDelayCnt), A
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     _HideFuelThief                       ;
;----------------------------------------------------------;
_HideFuelThief

    LD A, TS_WAITING_D1
    LD (thiefState), A

    LD IX, ena.fuelThiefSpr
    CALL sp.HideSprite

    ; Hide tank
    LD A, FUEL_SPRITE_ID_D97
    sp.SetIdAndHideSprite

    ; Restart deploy countdown
    XOR A
    LD (thiefRespawnDelayCnt), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     _LoadSprToIxIy                       ;
;----------------------------------------------------------;
; Return:
;  IX: points to SPR
;  IY: points to ENP
_LoadSprToIxIy

    LD IX, ena.fuelThiefSpr
    LD BC, (IX + SPR.EXT_DATA_POINTER)
    LD IY, BC

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE