/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                       Game Pickups                       ;
;----------------------------------------------------------;
    MODULE pi
    ; Before using it CALL dbs.SetupArrays2Bank

PI_SPR_LIFE             = 3                 ; Exta life.
PI_SPR_DIAMOND          = 39                ; Extra points.
PI_SPR_JAR              = 40                ; Colls down jetpack's rocket exhaust.
PI_SPR_STRAWBERRY       = 41                ; Jetman invincible.
PI_SPR_GRENADE          = 42                ; Collect and expolode.
PI_FREEZE_ENEMIES       = 43                ; Freeze enemies.
PI_SPR_GUN              = 44                ; Improve weapon.

pickupsArrayPos          DB 0

deployed                DB 0                ; Currently deployed sprite reference from spr-file(#PI_SPR_XXX), 0 for none.

deployedX               DB 0                ; Pickup X postion.
deployedY               DB 0                ; Pickup Y postion.

deployDelayCnt          DB 0
DEPLOY_DELAY            = 10

pickupsPtr              DW 0
pickupsSize             DB 0

lifeDeployed            DB 0
LIVE_DEPLOYED_YES       = 1
LIVE_DEPLOYED_NO        = 1

PICKUP_SPRITE_ID        = 90

;----------------------------------------------------------;
;                    SetupPickups                          ;
;----------------------------------------------------------;
; Input:
; - A:  Number of pickups.
; - DE: Pointer to pickups array, each entry of #PI_SPR_XXX.
SetupPickups

    LD (pickupsSize), A
    LD (pickupsPtr), DE

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    ResetPickups                          ;
;----------------------------------------------------------;
ResetPickups

    XOR A
    LD (deployed), A
    LD (lifeDeployed), A
    LD (deployDelayCnt), A
    LD (pickupsArrayPos), A
    LD (deployedX), A
    LD (deployedY), A
    LD (pickupsSize), A

    LD A, PICKUP_SPRITE_ID
    CALL sp.SetIdAndHideSprite

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 UpdatePickupsOnJetmanMove                ;
;----------------------------------------------------------;
UpdatePickupsOnJetmanMove

    LD A, (jt.jetState)
    CP jt.JETST_RIP
    RET Z

    ; ##########################################
    ; Exit if there is no active pickup.
    LD A, (deployed)
    CP 0
    RET Z

    ; ##########################################
    ; Check the collision (pickup possibility) between Jetman and the element, return if there is none.
    LD BC, (deployedX)                          ; X of the element.
    LD B, 0
    LD A, (deployedY)                           ; Y of the element.
    LD D, A
    CALL jco.JetmanElementCollision
    CP _RET_NO_D0
    RET Z

    ; ##########################################
    ; Jetman got a pickup! Now call the right callback.

    ; ##########################################
    ; Pickup in the air?
    LD A, (deployedY)
    CP _GSC_Y_MAX2_D238
    CALL NZ, gc.JetPicksInAir

    ; ##########################################
    ; Callbacks
    LD A, (deployed)

    ; Diamond
    CP PI_SPR_DIAMOND
    JR NZ, .afterDiamond
    CALL gc.JetPicksDiamond
    JR .nextPickup
.afterDiamond

    ; Jar
    CP PI_SPR_JAR
    JR NZ, .afterJar
    CALL gc.JetPicksJar
    JR .nextPickup
.afterJar

    ; Strawberry
    CP PI_SPR_STRAWBERRY
    JR NZ, .afterStrawberry
    CALL gc.JetPicksStrawberry
    JR .nextPickup
.afterStrawberry

    ; Grenade
    CP PI_SPR_GRENADE
    JR NZ, .afterGrenade
    CALL gc.JetPicksGrenade
    JR .nextPickup
.afterGrenade

    ; Life
    CP PI_SPR_LIFE
    JR NZ, .afterLife
    CALL gc.JetPicksLife
    JR .nextPickup
.afterLife

    ; Gun
    CP PI_SPR_GUN
    JR NZ, .afterGun
    CALL gc.JetPicksGun
    JR .nextPickup
.afterGun

    ; Freeze enemies
    CP PI_FREEZE_ENEMIES
    JR NZ, .afterFreeze
    CALL gc.FreezeEnemies
    JR .nextPickup
.afterFreeze

.nextPickup
    CALL _PrepareNextPixkup

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 AnimateFallingPickup                     ;
;----------------------------------------------------------;
AnimateFallingPickup

    ; Exit if there is no active pickup.
    LD A, (deployed)
    CP 0
    RET Z

    ; ##########################################
    ; Update y postion (falling down).
    LD A, (deployedY)
    CP _GSC_Y_MAX2_D238
    JR NZ, .afterGroundCheck
    ; Pickup is already on the ground, so moving it is unnecessary. In case of life, hide it once it has reached the ground.
    LD A, (deployed)
    CP PI_SPR_LIFE
    RET NZ

    ; Life has reached the ground - hide it.
    CALL _PrepareNextPixkup
    RET

.afterGroundCheck
    ; Move pickup down.
    INC A
    LD (deployedY), A

    ; ##########################################
    ; Update sprite pattern.

    ; Set the ID of the sprite for the following commands.
    LD A, PICKUP_SPRITE_ID
    NEXTREG _SPR_REG_NR_H34, A
    
    ; Set sprite pattern.
    LD A, (deployed)
    OR _SPR_PATTERN_SHOW                        ; Set show bit.
    NEXTREG _SPR_REG_ATR3_H38, A

    ; Sprite X coordinate from A param.
    LD A, (deployedX)
    NEXTREG _SPR_REG_X_H35, A

    LD A, _SPR_REG_ATR2_EMPTY
    NEXTREG _SPR_REG_ATR2_H37, A

    ; Sprite Y coordinate.
    LD A, (deployedY)
    NEXTREG _SPR_REG_Y_H36, A 

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    PickupDropCounter                     ;
;----------------------------------------------------------;
PickupDropCounter

    ; Do not deploy next pickup if there is one out there.
    LD A, (deployed)
    CP 0
    RET NZ

    ; ##########################################
    ; Check deploy counter, deploy next only in case of overflow.
    LD A, (deployDelayCnt)
    INC A
    LD (deployDelayCnt), A
    CP DEPLOY_DELAY
    RET NZ

    ; ##########################################
    ; Deploy next pickup, first reset counter.
    XOR A
    LD (deployDelayCnt), A

    ; ##########################################
    ; Load into A the value of next deployment sprite (#PI_SPR_XXXX)

.deployNext
    ; Determine the index for #pickups
    LD A, (pickupsSize)
    LD B, A
    LD A, (pickupsArrayPos)
    INC A
    CP B
    JR NZ, .afterpickupsArrayPos
    XOR A
.afterpickupsArrayPos
    LD (pickupsArrayPos), A

    ; Load ID of next pickup
    LD HL, (pickupsPtr)
    ADD HL, A                                   ; HL points to next deployment sprite id.
    LD A, (HL)
    LD (deployed), A

    ; ##########################################
    ; Do not deploy life if it has already been deployed in this round.
    CP PI_SPR_LIFE
    JR NZ, .afterLifeCheck                      ; Jump if not deploying life.

    LD A, (lifeDeployed)
    CP LIVE_DEPLOYED_YES
    JR Z, .deployNext

    ; Deplying life for the first time.
    LD A, LIVE_DEPLOYED_YES
    LD (lifeDeployed), A
    JR .setupDeply
.afterLifeCheck

    ; ##########################################
    ; Do not deply gun if fire speed is already at max level.
    LD A, (deployed)
    CP PI_SPR_GUN
    JR NZ, .afterGunCheck

    LD A, (jw.fireDelay)
    CP jw.JM_FIRE_DELAY_MIN
    JR Z, .deployNext
.afterGunCheck

    ; ##########################################
.setupDeply
    ; Setup X,Y postion
    XOR A
    LD (deployedY), A
    
    LD A, R
    LD (deployedX), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                  _PrepareNextPixkup                      ;
;----------------------------------------------------------;
_PrepareNextPixkup

    XOR A
    LD (deployed), A
    LD (deployDelayCnt), A

    ; Hide pickup
    LD A, PICKUP_SPRITE_ID
    CALL sp.SetIdAndHideSprite

    RET                                         ; ## END of the function ##
;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE