;----------------------------------------------------------;
;                       Game Pickups                       ;
;----------------------------------------------------------;
    MODULE pi

PI_SPR_DIAMOND          = 39
PI_SPR_JAR              = 40
PI_SPR_STRAWBERRY       = 41
PI_SPR_GRENADE          = 42
PI_SPR_LIFE             = 43
PI_SPR_GUN              = 44

deployOrderPos          BYTE 0
deployOrder
    DB PI_SPR_DIAMOND, PI_SPR_STRAWBERRY, PI_SPR_GUN, PI_SPR_DIAMOND, PI_SPR_JAR, PI_SPR_GUN, PI_SPR_JAR, PI_SPR_STRAWBERRY
    DB PI_SPR_GUN, PI_SPR_GRENADE, PI_SPR_STRAWBERRY, PI_SPR_GUN, PI_SPR_GRENADE, PI_SPR_GUN, PI_SPR_STRAWBERRY, PI_SPR_GUN
    DB PI_SPR_JAR, PI_SPR_STRAWBERRY, PI_SPR_DIAMOND, PI_SPR_GUN, PI_SPR_STRAWBERRY
DEPLOY_ORDER_SIZE       = 20

PI_SPR_MIN              = PI_SPR_DIAMOND
PI_SPR_MAX              = PI_SPR_GUN

deployed                BYTE 0                  ; Currently deployed sprite reference from spr-file(#PI_SPR_XXX), 0 for none.

deployedX               BYTE 0                  ; Pickup X postion
deployedY               BYTE 0                  ; Pickup Y postion

deployCnt               BYTE 0
DEPLOY_CNT_DELAY        = 15

lifeDeployed            BYTE 0
LIVE_DEPLOYED_YES       = 1
LIVE_DEPLOYED_NO        = 1

PICKUP_SPRITE_ID        = 90

;----------------------------------------------------------;
;                #UpdatePickupsOnJetmanMove                ;
;----------------------------------------------------------;
UpdatePickupsOnJetmanMove

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
    CP _GSC_Y_MAX2_D234
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

.nextPickup
    ; ##########################################
    ; Prep next pickup.
    XOR A
    LD (deployed), A
    LD (deployCnt), A

    ; Hide pickup.
    LD A, PICKUP_SPRITE_ID
    CALL sp.SetIdAndHideSprite

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
    ; Update y postion (falling down)
    LD A, (deployedY)
    CP _GSC_Y_MAX2_D234
    RET Z                                       ; Pickup is already on the ground, so moving it is unnecessary.
    
    ; Move pickup down.
    INC A
    LD (deployedY), A

    ; ##########################################
    ; Update sprite pattern.

    ; Set the ID of the sprite for the following commands.
    LD A, PICKUP_SPRITE_ID
    NEXTREG _SPR_REG_NR_H34, A
    
    ; Set sprite pattern
    LD A, (deployed)
    OR _SPR_PATTERN_SHOW                        ; Set show bit.
    NEXTREG _SPR_REG_ATR3_H38, A

    ; Sprite X coordinate from A param
    LD A, (deployedX)
    NEXTREG _SPR_REG_X_H35, A

    LD A, _SPR_REG_ATR2_EMPTY
    NEXTREG _SPR_REG_ATR2_H37, A

    ; Sprite Y coordinate
    LD A, (deployedY)
    NEXTREG _SPR_REG_Y_H36, A 

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    ResetPickups                          ;
;----------------------------------------------------------;
ResetPickups

    XOR A
    LD (deployed), A
    LD (lifeDeployed), A
    LD (deployCnt), A
    LD (deployOrderPos), A
    LD (deployedX), A
    LD (deployedY), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     LifeDropCounter                      ;
;----------------------------------------------------------;
LifeDropCounter

    ; Do not deploy next pickup if there is one out there.
    LD A, (deployed)
    CP 0
    RET NZ

    ; Do not deploy life if it has already been deployed in this round.
    LD A, (lifeDeployed)
    CP LIVE_DEPLOYED_YES
    RET Z

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
    LD A, (deployCnt)
    INC A
    LD (deployCnt), A
    CP DEPLOY_CNT_DELAY
    RET NZ

    ; ##########################################
    ; Deploy next pickup, first reset counter.
    XOR A
    LD (deployCnt), A

    ; ##########################################
    ; Load into A the value of next deployment sprite (#PI_SPR_XXXX)

    ; Determine the index for #deployOrder.
    LD A, (deployOrderPos)
    INC A 
    CP DEPLOY_ORDER_SIZE
    JR NZ, .afterDeployOrderPos
    XOR A
.afterDeployOrderPos
    LD (deployOrderPos), A

    ; Load ID of next pickup.
    LD HL, deployOrder
    ADD HL, A                                   ; HL points to next deployment sprite id.
    LD A, (HL)
    LD (deployed), A

    ; Setup X,Y postion
    XOR A
    LD (deployedY), A
    
    LD A, R
    LD (deployedX), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE