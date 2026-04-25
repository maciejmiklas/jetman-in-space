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

; Deploying starts few seconds before running (TS_RUNS_EMPTY_D30), and it's used to play sound before thief starts running.
TS_DEPLOYING_D2         = 2
TS_EXPLODES_D20         = 20
TS_RUNS_EMPTY_D30       = 30
TS_CARRIES_FUEL_D31     = 31
thiefState              DB TS_DISABLED_D0
THIEF_SIZE_D1           = 1
FUEL_SPRITE_ID_D97      = 97                    ; Sprite ID for the fuel tank.
FUEL_SPRITE_REF_D17     = 17                    ; Sprite id from sprite file.
FUEL_HEIGHT_D226        = 226
DEPLOY_SIDE_RND_H30     = $30

thiefRespawnDelayCnt    DB 0

; Repown delay in seconds, MUST me be > RO_DROP_NEXT_D20 (theif respown resets #dropNextDelay)
RESPAWN_DELAY_D30       = 30
RESPAWN_DEPLOYING_D25   = 25

MIN_FUEL_LEVEL_D6       = 6

;----------------------------------------------------------;
;----------------------------------------------------------;
;                     PRIVATE MACROS                       ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                   _LoadThiefSprToIxIy                    ;
;----------------------------------------------------------;
; Return:
;  IX: points to SPR
;  IY: points to ENP
    MACRO _LoadThiefSprToIxIy

    LD IX, ena.fuelThiefSpr
    LD BC, (IX + SPR.EXT_DATA_POINTER)
    LD IY, BC

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                _ResetThiefRespawnDelay                   ;
;----------------------------------------------------------;
    MACRO _ResetThiefRespawnDelay

    XOR A
    LD (IY + ENP.RESPAWN_DELAY), A
    LD (thiefRespawnDelayCnt), A

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                 _HideFuelTankSprite                      ;
;----------------------------------------------------------;
    MACRO _HideFuelTankSprite

    LD A, FUEL_SPRITE_ID_D97
    sp.SetIdAndHideSprite

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PUBLIC FUNCTIONS                       ;
;----------------------------------------------------------;
;----------------------------------------------------------;

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

    _LoadThiefSprToIxIy                         ; Load SPR to IX and ENP to IY

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

    _HideFuelTankSprite
    _ResetThiefRespawnDelay
    CALL enur.ResetDropNextDelay

    CALL gc.FuelThiefHit

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     RespawnFuelThief                     ;
;----------------------------------------------------------;
RespawnFuelThief

    ; Respawn if #TS_WAITING_D1, #TS_DEPLOYING_D2 or TS_EXPLODES_D20
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
    CP RESPAWN_DEPLOYING_D25
    JR NZ, .afterRespawn

    LD A, TS_DEPLOYING_D2
    LD (thiefState), A

    ; Reset the deployment countdown for the next fuel element because the thief is active.
    CALL enur.ResetDropNextDelay
.afterRespawn

    ; ##########################################
    ; Respawn thief.

    LD A, (thiefRespawnDelayCnt)
    CP RESPAWN_DELAY_D30
    RET NZ

    LD A, TS_RUNS_EMPTY_D30
    LD (thiefState), A

    _LoadThiefSprToIxIy

    ; Random left/right deployment.
    LD A, R
    CP DEPLOY_SIDE_RND_H30
    JR C, .deployRight

    ; Deploy left.
    LD (IY+ENP.SETUP), enp.ENP_LEFT_ALONG 
    JR .afterDeploySide

    ; Deploy right.
.deployRight
    LD (IY+ENP.SETUP), enp.ENP_RIGHT_ALONG 
.afterDeploySide

    CALL enp.RespawnPatternEnemy

    ; Reset the deployment countdown for the next fuel element because the thief is active.
    CALL enur.ResetDropNextDelay

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   AnimateFuelThief                       ;
;----------------------------------------------------------;
AnimateFuelThief

    ; Do not execute if thief is not moving/exploding.
    LD A, (thiefState)
    CP TS_EXPLODES_D20
    RET C                                       ; Return if #thiefState < TS_EXPLODES_D20

    ; Animate
    _LoadThiefSprToIxIy
    sp.AnimateSprite

    ; Switch from TS_EXPLODES_D20 to TS_WAITING_D1 when explosion is over.
    BIT sp.SPRITE_ST_VISIBLE_BIT, (IX + SPR.STATE)
    RET NZ                                      ; Retun if sprite still visible.

    LD A, TS_WAITING_D1
    LD (thiefState), A

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
    _LoadThiefSprToIxIy

    ; ##########################################
    ; Move sprite.
    LD A, THIEF_SIZE_D1
    LD B, A
    PUSH IX, IY
    CALL enp.MovePatternEnemies
    POP IY, IX

    ; ##########################################
    ; Hide if the thief has reached the left side of the screen, if he deployed right.
    BIT enp.ENP_BIT_DEPLOY_D1, (IY + ENP.SETUP)
    JR NZ, .hideNotDeplyedRight                ; Jump if bit is 0 -> deploy left.

    LD BC, (IX + SPR.X)
    LD A, B
    OR A                                        ; Same as CP 0, but faster.
    JR NZ, .hideNotDeplyedRight
    LD A, C
    CP 5
    JR NC, .hideNotDeplyedRight

    ; Hide sprite, is on the left side.
    LD A, (IY+ENP.SETUP)
    LD BC, (IX + SPR.X)

    CALL _HideFuelThief
    RET

.hideNotDeplyedRight
    ; ##########################################
    ; Hide if the thief has reached the right side of the screen (315 =  $13B), if he deployed left.
    BIT enp.ENP_BIT_DEPLOY_D1, (IY + ENP.SETUP)
    JR Z, .hideNotDepoyedLeft                    ; Jump if bit is 1 -> deploy right.

    LD BC, (IX + SPR.X)
    LD A, B
    CP 1
    JR NZ, .hideNotDepoyedLeft
    LD A, C
    CP $3B
    JR C, .hideNotDepoyedLeft

    ; Hide sprite, is on the right side
    LD A, (IY+ENP.SETUP)
    LD BC, (IX + SPR.X)

    CALL _HideFuelThief
    RET
.hideNotDepoyedLeft

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
    sp.ShowSpriteReg
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

    _LoadThiefSprToIxIy
    LD B, THIEF_SIZE_D1
    CALL enp.ResetPatternEnemies

    _ResetThiefRespawnDelay

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     _HideFuelThief                       ;
;----------------------------------------------------------;
_HideFuelThief

    _LoadThiefSprToIxIy

    LD A, TS_WAITING_D1
    LD (thiefState), A

    CALL sp.HideSprite

    _HideFuelTankSprite

    ; Restart deploy countdown
    _ResetThiefRespawnDelay

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE