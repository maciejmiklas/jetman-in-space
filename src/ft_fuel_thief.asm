;----------------------------------------------------------;
;                       Fuel Thief                         ;
;----------------------------------------------------------;
    MODULE ft

TS_DISABLED             = 0
TS_WAITING              = 1
TS_RUNS_EMPTY           = 20
TS_CARRIES_FUEL         = 21
thiefState              DB TS_DISABLED

THIEF_SIZE              = 1
FUEL_SPRITE_ID          = 97                    ; Sprite ID for the screen
FUEL_SPRITE_REF         = 17                    ; Sprite id from sprite file
FUEL_HEIGHT             = 226

;----------------------------------------------------------;
;                    #SetThiefState                        ;
;----------------------------------------------------------;
; Input:
;  A: New state as one of: TS_XXX
SetThiefState

    LD (thiefState), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    #SetupFuelThief                       ;
;----------------------------------------------------------;
SetupFuelThief

    CALL dbs.SetupArraysBank

    LD IX, dba.fuelThiefSpr
    LD B, THIEF_SIZE
    CALL enp.ResetPatternEnemies

    XOR A
    LD (IY + enp.ENP.RESPAWN_DELAY), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  #RespawnFuelThief                       ;
;----------------------------------------------------------;
RespawnFuelThief

    LD A, TS_RUNS_EMPTY
    CALL SetThiefState

    CALL dbs.SetupArraysBank

    LD IX, dba.fuelThiefSpr
    LD BC, (IX + sr.SPR.EXT_DATA_POINTER)       ; Load extra sprite data (#ENP) to IY
    LD IY, BC

    LD (IY+enp.ENP.SETUP),  enp.ENP_S_LEFT_ALONG ;ENP_S_RIGHT_ALONG

    CALL enp.RespawnPatternEnemy

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     #HideFuelThief                       ;
;----------------------------------------------------------;
HideFuelThief

    LD A, TS_WAITING
    CALL SetThiefState

    CALL dbs.SetupArraysBank

    LD IX, dba.fuelThiefSpr
    CALL sr.HideSimpleSprite

    ; Hide tank
    LD A, FUEL_SPRITE_ID
    CALL sp.SetIdAndHideSprite

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  #AnimateFuelThief                       ;
;----------------------------------------------------------;
AnimateFuelThief

    CALL dbs.SetupArraysBank

    LD IX, dba.fuelThiefSpr
    LD A, THIEF_SIZE
    LD B, A
    CALL sr.AnimateSprites

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    #MoveFuelThief                        ;
;----------------------------------------------------------;
MoveFuelThief

    ; Do not execute it thief is not moving
    LD A, (thiefState)
    CP TS_RUNS_EMPTY
    RET C

    ; ##########################################
    ; Load SPR to IX and ENP to IY
    LD IX, dba.fuelThiefSpr
    LD BC, (IX + sr.SPR.EXT_DATA_POINTER)
    LD IY, BC

    ; ##########################################
    ; Move sprite
    CALL dbs.SetupArraysBank
    LD A, THIEF_SIZE
    LD B, A
    PUSH IX
    CALL enp.MovePatternEnemies
    POP IX

    ; ##########################################
    ; Check if the thief has reached the rocket to steal fuel
    LD BC, (IX + sr.SPR.X)
    LD A, (ro.rocketAssemblyX)
    SUB C                                       ; Ignore B because X < 255, rocket assembly X is 8bit
    CP ro.DROP_MARGX_D8
    JR NC, .notAtRocket
 
    ; ##########################################
    ; Pickup fuel tank
    ;CALL ro.DecrementRocketFuelLevel
    LD A, TS_CARRIES_FUEL
    CALL SetThiefState
.notAtRocket

    ; ##########################################
    ; Move fuel tank with thief
    LD A, (thiefState)
    CP TS_CARRIES_FUEL
    JR NZ, .notCarryFuel

    ; Set the ID of the sprite for the following commands
    LD A, FUEL_SPRITE_ID
    NEXTREG _SPR_REG_NR_H34, A

    ; Set sprite X coordinate.
    LD BC, (IX + sr.SPR.X)
    LD A, C     
    NEXTREG _SPR_REG_X_H35, A
    
    ; Set _SPR_REG_ATR2_H37 containing overflow bit from X position
    LD A, B                                     ; Load MSB from X into A
    AND %00000001                               ; Keep only an overflow bit
    NEXTREG _SPR_REG_ATR2_H37, A

    ; Set Y coordinate
    LD A, FUEL_HEIGHT
    NEXTREG _SPR_REG_Y_H36, A                   ; Set Y position

    ; Set sprite pattern
    LD A, FUEL_SPRITE_REF
    OR _SPR_PATTERN_SHOW                        ; Set show bit
    NEXTREG _SPR_REG_ATR3_H38, A
.notCarryFuel

    ; ##########################################
    ; Hide if the thief has reached the left side of the screen, if he deployed right
    BIT enp.ENP_DEPLOY_BIT, (IY + enp.ENP.SETUP)
    JR NZ, .notHideLeft                        ; Jump if bit is 0 -> deploy left

    LD BC, (IX + sr.SPR.X)
    LD A, B
    CP 0
    JR NZ, .notHideLeft
    LD A, C
    CP 5
    JR NC, .notHideLeft
    ; Hide sprite, is on the left side
    CALL HideFuelThief
.notHideLeft

    ; ##########################################
    ; Hide if the thief has reached the right side of the screen (315 =  $13B), if he deployed left
    BIT enp.ENP_DEPLOY_BIT, (IY + enp.ENP.SETUP)
    JR Z, .notHideRight                        ; Jump if bit is 1 -> deploy right

    LD BC, (IX + sr.SPR.X)
    LD A, B
    CP 1
    JR NZ, .notHideRight
    LD A, C
    CP $3B
    JR C, .notHideRight
    ; Hide sprite, is on the right side
    CALL HideFuelThief
.notHideRight

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE