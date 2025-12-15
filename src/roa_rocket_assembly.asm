/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                     Building the Rocket                  ;
;----------------------------------------------------------;
    MODULE roa

RO_DROP_NEXT_D10        = 2                    ; Drop next element delay.
RO_DROP_Y_MAX_D180      = 180                   ; Jetman has to be above the rocket to drop the element.
RO_DROP_Y_MIN_D130      = 130                   ; Maximal height above ground (min y) to drop rocket element.
RO_DROP_Y_MIN_EASY_D30  = 30
dropMinY                DB RO_DROP_Y_MIN_D130

RO_DOWN_SPR_ID_D80      = 80                    ; Sprite ID is used to lower the rocket part, which has the engine and fuel.

; Number of _MainLoop040 cycles to drop next rocket module.
dropNextDelay           DB 0

; It counts from EL_LOW_D1 to EL_TANK6_D9, both inclusive. After the rocket is ready for takeoff, it is set to EL_TANK6_D9+1 to light up
; the last progress bar section.
rocketElementCnt        DB 0

DROP_LAND_Y_ADJ         = -5

explodeTankCnt          DB 0                    ; Current position in #rocketExplodeTankDB.
EXPLODE_TANK_MAX        = 4                     ; The amount of explosion sprites.

EL_TANK1_D4             = 4
EL_TANK6_D9             = 9
EL_TANK_SIZE            = EL_TANK6_D9 - EL_TANK1_D4 + 1
EL_PROGRESS_START       = EL_TANK1_D4+1
CARRY_ADJUSTY_D10       = 10

BAR_TILE_START         = 25*2                   ; *2 because each tile takes 2 bytes.
BAR_RAM_START          = ti.TI_MAP_RAM_H5B00 + BAR_TILE_START ; HL points to screen memory containing tilemap.
BAR_TILE_PAL           = $60

BAR_ICON               = 36
BAR_ICON_RAM_START     = BAR_RAM_START - 2
BAR_ICON_PAL           = $00
DROP_MARGX_D8           = 8

rocAssemblyX           DB 0

;----------------------------------------------------------;
;                        SetupRocket                       ;
;----------------------------------------------------------;
; Input:
;  - A: X coordinate for rocket assembly.
;  - HL: Array containing 9 #ro.RO elements.
SetupRocket

    LD (rocAssemblyX), A
    LD (ro.rocketElPtr), HL

    LD A, (jt.difLevel)
    CP jt.DIF_EASY
    RET NZ

    LD A, RO_DROP_Y_MIN_EASY_D30
    LD (dropMinY), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                AssemblyRocketForDebug                    ;
;----------------------------------------------------------;
AssemblyRocketForDebug
    CALL dbs.SetupArrays2Bank

    LD A, EL_TANK6_D9
    LD (rocketElementCnt), A

    LD A, ro.ROST_READY
    LD (ro.rocketState), A

    LD A, 1
    LD IX, (ro.rocketElPtr)

    LD A, 201
    LD (ro.rocY), A

/*
    CALL ro.MoveIXtoGivenRocketElement
    LD (IX + ro.RO.Y), 233

    LD A, 2
    LD IX, (rocketElPtr)
    CALL ro.MoveIXtoGivenRocketElement
    LD (IX + ro.RO.Y), 217

    LD A, 3
    LD IX, (rocketElPtr)
    CALL ro.MoveIXtoGivenRocketElement
    LD (IX + ro.RO.Y), 201
*/
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   StartRocketAssembly                    ;
;----------------------------------------------------------;
StartRocketAssembly
    CALL dbs.SetupArrays2Bank

    LD A, ro.ROST_WAIT_DROP
    LD (ro.rocketState), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 ResetAndDisableRocket                    ;
;----------------------------------------------------------;
ResetAndDisableRocket
    CALL dbs.SetupArrays2Bank

    XOR A
    LD (rocAssemblyX), A
    LD (ro.rocX), A
    LD (ro.rocY), A
    LD (dropNextDelay), A
    LD (ro.rocketState), A
    LD (explodeTankCnt), A
    LD (rocketElementCnt), A

    ; ##########################################
    ; Reset rocket elements
    LD B, EL_TANK6_D9
    LD IX, (ro.rocketElPtr)
.rocketElLoop

    XOR A
    LD A, (IX + ro.RO.SPRITE_ID)
    CALL sp.SetIdAndHideSprite

    ; ##########################################
    ; Next rocket element
    LD DE, IX
    ADD DE, ro.RO
    LD IX, DE
    DJNZ .rocketElLoop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 UpdateRocketOnJetmanMove                 ;
;----------------------------------------------------------;
UpdateRocketOnJetmanMove
    CALL dbs.SetupArrays2Bank

    CALL _PickupRocketElement
    CALL _CarryRocketElement
    CALL _BoardRocket

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        IsFuelDeployed                    ;
;----------------------------------------------------------;
; Return:
;  - YES: Z is reset (JP Z).
;  - NO:  Z is set (JP NZ).
IsFuelDeployed

    LD A, (rocketElementCnt)
    CP EL_TANK1_D4
    JR C, .notFuel                              ; Jump if counter is < 4 (still assembling rocket).

    ; Element count is correct, it could be fuel, but is it really out there?
    LD A, (ro.rocketState)
    CP ro.ROST_FALL_PICKUP
    JR Z, .isFuel

    CP ro.ROST_WAIT_PICKUP
    JR Z, .isFuel

    CP ro.ROST_FALL_ASSEMBLY
    JR Z, .isFuel

.notFuel
    OR 1                                        ; Return NO (Z set).
    RET

.isFuel
    XOR A                                       ; Return YES (Z is reset).

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      CheckHitTank                        ;
;----------------------------------------------------------;
; Checks falling tank for collision with leaser beam.
CheckHitTank

    ; Not tank hit on easy
    LD A, (jt.difLevel)
    CP jt.DIF_EASY
    RET Z

    CALL dbs.SetupArrays2Bank

    ; Is the thank out there?
    CALL IsFuelDeployed
    RET NZ

    ; Is tank already exploding?
    LD A, (ro.rocketState)
    CP ro.ROST_TANK_EXPLODE
    RET Z                                       ; Return if tank is already exploding.

    ; ##########################################
    ; Check hit by leaser beam
    CALL _SetIXtoCurrentRocketElement

    ; The X coordinate of the rocket element is stored in two locations: 
    ;  1) #ro.RO.DROP_X: when elements drop for pickup by Jetman.
    ;  2) #roxX when building the rocket.
    LD A, (ro.rocketState)
    CP ro.ROST_FALL_ASSEMBLY
    JR Z, .assembly
    
    ; Falling rocket element for pickup
    LD DE, (IX + ro.RO.DROP_X)                     ; X param for #ShotsCollision.
    JR .afterAssembly
.assembly
    ; The rocket is already assembled and waiting for fuel.
    LD DE, (rocAssemblyX)                       ; X param for #ShotsCollision.
.afterAssembly

    LD D, 0                                     ; Reset D, X coordinate for drop is 8 bit.

    ; Y param for #ShotsCollision.
    LD A, (ro.rocY)
    LD C, A
    CALL jw.ShotsCollision
    CP jw.SHOT_HIT
    RET NZ

    ; ##########################################
    ; The laser beam hits the falling rocket tank!
    XOR A
    LD (explodeTankCnt), A

    LD A, ro.ROST_TANK_EXPLODE
    LD (ro.rocketState), A

    ; ##########################################
    CALL gc.RocketTankHit

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   AnimateTankExplode                     ;
;----------------------------------------------------------;
AnimateTankExplode
    CALL dbs.SetupArrays2Bank

    ; Return if tank is not exploding.
    LD A, (ro.rocketState)
    CP ro.ROST_TANK_EXPLODE
    RET NZ

    ; Is explosion over?
    LD A, (explodeTankCnt)
    CP EXPLODE_TANK_MAX
    JR NZ, .keepExploding

    ; Explosion is over.
    LD A, ro.ROST_WAIT_DROP
    LD (ro.rocketState), A

    CALL _ResetRocketElement
    RET

.keepExploding

    CALL _SetIXtoCurrentRocketElement

    ; Set the ID of the sprite for the following commands.
    LD A, (IX + ro.RO.SPRITE_ID)
    NEXTREG _SPR_REG_NR_H34, A
    
    ; Move #rocketExplodeTankDB by #explodeTankCnt, so that A points to current explosion frame.
    LD A, (explodeTankCnt)
    LD B, A
    LD A, (db2.rocketExplodeTankDB)
    ADD B

    ; Set sprite pattern.
    OR _SPR_PATTERN_SHOW                        ; Set show bit
    NEXTREG _SPR_REG_ATR3_H38, A

    ; Increment #explodeTankCnt
    LD A, (explodeTankCnt)
    INC A
    LD (explodeTankCnt), A

    RET                                         ; ## END of the function ## 

;----------------------------------------------------------;
;               ResetCarryingRocketElement                 ;
;----------------------------------------------------------;
ResetCarryingRocketElement

    CALL dbs.SetupArrays2Bank

    ; Return if the state does not match carry.
    LD A, (ro.rocketState)
    CP ro.ROST_CARRY
    RET NZ

    CALL _ResetRocketElement

    RET                                         ; ## END of the function ## 

;----------------------------------------------------------;
;               RocketElementFallsForPickup                ;
;----------------------------------------------------------;
RocketElementFallsForPickup

    CALL dbs.SetupArrays2Bank

    ; Return if there is no fall.
    LD A, (ro.rocketState)
    CP ro.ROST_FALL_PICKUP
    RET NZ                                      ; Return if falling bit is not set.

    CALL _SetIXtoCurrentRocketElement           ; Set IX to current #rocket postion.

    ; Move element one pixel down
    LD A, (ro.rocY)
    INC A
    LD (ro.rocY), A

    ; Update rocket sprite.
    LD A, (IX + ro.RO.DROP_X)                      ; Sprite X coordinate, do not change value - element is falling down.
    LD (ro.rocX), A
    CALL ro.UpdateElementPosition

    ; Has the horizontal destination been reached?
    LD B, A
    LD A, DROP_LAND_Y_ADJ
    LD C, A
    LD A, (IX + ro.RO.DROP_LAND_Y)
    ADD C                                       ; A = #DROP_LAND_Y + #DROP_LAND_Y_ADJ
    CP B
    RET NZ                                      ; No, keep falling down.
    
    ; Yes, element has reached landing postion.
    LD A, ro.ROST_WAIT_PICKUP
    LD (ro.rocketState), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    BlinkRocketReady                      ;
;----------------------------------------------------------;
BlinkRocketReady

    CALL dbs.SetupArrays2Bank

    ; Return if rocket is not ready.
    LD A, (ro.rocketState)
    CP ro.ROST_READY
    RET NZ  

    ; Set the ID of the sprite for the following commands.
    LD A, RO_DOWN_SPR_ID_D80
    NEXTREG _SPR_REG_NR_H34, A

    ; Set sprite pattern - one for flip, one for flop -> rocket will blink waiting for Jetman.
    LD A, (mld.counter008FliFLop)
    CP _GC_FLIP_ON_D1
    JR Z, .flip
    LD A, ro.SPR_PAT_READY1_D60
    JR .afterSet
.flip   
    LD A, ro.SPR_PAT_READY2_D61
.afterSet
    OR _SPR_PATTERN_SHOW                        ; Set visibility bit
    NEXTREG _SPR_REG_ATR3_H38, A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;              RocketElementFallsForAssembly               ;
;----------------------------------------------------------;
RocketElementFallsForAssembly

    CALL dbs.SetupArrays2Bank

    ; Return if there is no assembly
    LD A, (ro.rocketState)
    CP ro.ROST_FALL_ASSEMBLY
    RET NZ                                      ; Return if assembly bit is not set.

    ; ##########################################
    ; Set IX to current #rocket postion.
    CALL _SetIXtoCurrentRocketElement

    ; ##########################################
    ; Set the ID of the sprite for the following commands.
    LD A, (IX + ro.RO.SPRITE_ID)
    NEXTREG _SPR_REG_NR_H34, A

    ; ##########################################
    ; Sprite X coordinate to assembly location.
    LD A, (rocAssemblyX)
    NEXTREG _SPR_REG_X_H35, A

    ; ##########################################
    ; Set sprite pattern.
    LD A, (IX + ro.RO.SPRITE_REF)
    OR _SPR_PATTERN_SHOW                        ; Set show bit.
    NEXTREG _SPR_REG_ATR3_H38, A

    ; ##########################################
    ; Sprite Y coordinate, increment until the destination has been reached.
    LD A, (ro.rocY)
    INC A
    LD (ro.rocY), A
    NEXTREG _SPR_REG_Y_H36, A

    ; ##########################################
    ; Has the horizontal destination been reached?
    LD B, A
    LD A, (IX + ro.RO.ASSEMBLY_Y)
    CP B
    RET NZ                                      ; No, keep falling down.

    ; ##########################################
    ; Yes, element has reached landing postion, set state for next drop.
    LD A, ro.ROST_WAIT_DROP
    LD (ro.rocketState), A

    ; ##########################################
    ; Check if we are dropping fuel already. If it's the case, hide the fuel tank sprite. Sprite of rocket element remains visible.
    LD A, (rocketElementCnt)
    CP EL_TANK1_D4
    RET C                                       ; Jump if counter is < 4 (still assembling rocket).

    ; We are dropping fuel already, hide the fuel sprite as it has reached the rocket.
    LD A, (IX + ro.RO.SPRITE_ID)
    CALL sp.SetIdAndHideSprite

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  DropNextRocketElement                   ;
;----------------------------------------------------------;
DropNextRocketElement
    CALL dbs.SetupArrays2Bank
    
    ; Check state.
    LD A, (ro.rocketState)
    CP ro.ROST_WAIT_DROP
    RET NZ

    ; ##########################################
    ; Increment delay counter and check whether it's already time to process with the next rocket element/tank.
    LD A, (dropNextDelay)
    INC A
    LD (dropNextDelay), A
    CP RO_DROP_NEXT_D10
    RET NZ                                      ; Jump if #nextCnt !=  #DROP_NEXT_MAX

    ; The counter has reached the required value, reset it first.
    XOR A                                       ; Set A to 0
    LD (dropNextDelay), A
    LD (ro.rocY), A                                ; Set the element's position to the top.

    ; Check whether rocket element counter has already reached max value.
    LD A, (rocketElementCnt)
    CP EL_TANK6_D9
    JR NZ, .dropNext                            ; Jump if the counter did not reach max value.

    ; ##########################################
    ; The rocket is assembled and fueled.

    ; Increment element counter to light up last progress bar element.
    LD A, (rocketElementCnt)
    INC A
    LD (rocketElementCnt), A
    CALL _UpdateFuelProgressBar

    LD A, ro.ROST_READY
    LD (ro.rocketState), A

    CALL gc.RocketReady

    RET

.dropNext
    ; ##########################################
    ; Increment element counter.
    LD A, (rocketElementCnt)
    INC A
    LD (rocketElementCnt), A
    CALL _UpdateFuelProgressBar

    ; We are going to drop the next element -> set falling state.
    LD A, ro.ROST_FALL_PICKUP
    LD (ro.rocketState), A

    ; Drop next rocket element/tank, first set IX to current #rocket postion.
    CALL _SetIXtoCurrentRocketElement

    ; Reset Y for element/tank to top of the screen.
    XOR A                                       ; Set A to 0
    LD (IX + ro.RO.Y), A
    
    RET                                         ; ## END of the function ##]

;----------------------------------------------------------;
;                   RemoveRocketElement                    ;
;----------------------------------------------------------;
RemoveRocketElement

    LD A, (rocketElementCnt)
    DEC A
    LD (rocketElementCnt), A
    
    CALL _UpdateFuelProgressBar

    ; Change state
    LD A, ro.ROST_WAIT_DROP
    LD (ro.rocketState), A

    XOR A
    LD (dropNextDelay), A
    LD (ro.rocY), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;              _SetIXtoCurrentRocketElement                ;
;----------------------------------------------------------;
; Set IX to current #rocket postion.
_SetIXtoCurrentRocketElement

    ; Load the pointer to #rocket into IX and move the pointer to the actual rocket element.
    LD IX, (ro.rocketElPtr)

    ; Now, move IX so that it points to the #ro.RO given by the deploy counter. First, load the counter into A (value 1-6).
    ; Afterward, load A info D and the size of the #ro.RO into E, and multiply D by E.
    LD A, (rocketElementCnt)
    CALL ro.MoveIXtoGivenRocketElement

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  _PickupRocketElement                    ;
;----------------------------------------------------------;
_PickupRocketElement

    ; Return if there is no element/tank to pick up. Status must be #ro.ROST_WAIT_PICKUP or #ro.ROST_FALL_PICKUP.
    LD A, (ro.rocketState)
    CP ro.ROST_WAIT_PICKUP
    JR Z, .afterStatusCheck

    CP ro.ROST_FALL_PICKUP
    RET NZ
    
.afterStatusCheck

    ; ##########################################
    ;  Exit if RiP.
    LD A, (jt.jetState)
    CP jt.JETST_RIP
    RET Z

    ; ##########################################
    ; Set IX to current #rocket postion.
    CALL _SetIXtoCurrentRocketElement

    ; ##########################################
    ; Check the collision (pickup possibility) between Jetman and the element, return if there is none.
    LD BC, (IX + ro.RO.DROP_X)                     ; X of the element.
    LD B, 0
    LD DE, (ro.rocY)                               ; Y of the element.
    LD D, E
    CALL jco.JetmanElementCollision
    RET NZ

     ; ##########################################
    ; Call game command with pickup info.
    LD A, (ro.rocketState)
    CP ro.ROST_FALL_PICKUP
    JR NZ, .pickupOnGround
    CALL gc.RocketElementPickupInAir
.pickupOnGround
    CALL gc.RocketElementPickup

    ; ##########################################
    ; Jetman picks up element/tank. Update state to reflect it and return.
    LD A, ro.ROST_CARRY
    LD (ro.rocketState), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    _MoveWithJetman                       ;
;----------------------------------------------------------;
; Move the element to the current Jetman's position.
_MoveWithJetman

    ; Set the ID of the sprite for the following commands.
    LD A, (IX + ro.RO.SPRITE_ID)
    NEXTREG _SPR_REG_NR_H34, A

    ; ##########################################
    ; Set sprite X coordinate.
    LD BC, (jpo.jetX)
    LD A, C     
    NEXTREG _SPR_REG_X_H35, A                   ; Set _SPR_REG_NR_H34 with LDB from Jetman's X postion.
    
    ; Set _SPR_REG_ATR2_H37 containing overflow bit from X position.
    LD A, B                                     ; Load MSB from X into A.
    AND %00000001                               ; Keep only an overflow bit.
    NEXTREG _SPR_REG_ATR2_H37, A

    ; ##########################################
    ; Set Y coordinate
    LD A, (jpo.jetY)
    ADD CARRY_ADJUSTY_D10
    NEXTREG _SPR_REG_Y_H36, A                   ; Set Y position.

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 _JetmanDropsRocketElement                ;
;----------------------------------------------------------;
_JetmanDropsRocketElement

    ; Is Jetman over the drop location (+/- #PICK_MARGX_D8)?
    LD BC, (jpo.jetX)
    LD A, (rocAssemblyX)
    SUB C                                       ;  Ignore B because X < 255, rocket assembly X is 8bit.
    CP DROP_MARGX_D8
    RET NC

    ; ##########################################
    ; To drop rocket element Jetman's height has to be within bounds: #dropMinY < #jpo.jetY < #RO_DROP_Y_MAX_D180.
    LD A, (dropMinY)
    LD B, A
    LD A, (jpo.jetY)
    CP RO_DROP_Y_MAX_D180
    RET NC

    CP B
    RET C

    ; ##########################################
    ; Jetman drops rocket element.
    LD A, ro.ROST_FALL_ASSEMBLY
    LD (ro.rocketState), A

    ; ##########################################
    ; Store the height of the drop so that the element can keep falling from this location into the assembly place.
    CALL _SetIXtoCurrentRocketElement           ; Set IX to current #rocket postion.
    LD A, (jpo.jetY)
    LD (ro.rocY), A

    ; ##########################################
    CALL gc.RocketElementDrop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   _CarryRocketElement                    ;
;----------------------------------------------------------;
_CarryRocketElement

    ; Return if the state does not match.
    LD A, (ro.rocketState)
    CP ro.ROST_CARRY
    RET NZ

    CALL _SetIXtoCurrentRocketElement
    CALL _MoveWithJetman
    CALL _JetmanDropsRocketElement

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 _ResetRocketElement                      ;
;----------------------------------------------------------;
_ResetRocketElement

    ; Reset to wait for drop, hide sprite.
    CALL _SetIXtoCurrentRocketElement

    ; Hide rocket element sprite.
    LD A, (IX + ro.RO.SPRITE_ID)
    CALL sp.SetIdAndHideSprite

    ; Reset the state and decrement element counter -> we will drop this element again.
    CALL RemoveRocketElement

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     _BoardRocket                         ;
;----------------------------------------------------------;
_BoardRocket
    CALL dbs.SetupArrays2Bank

    ; Return if rocket is not ready for boarding.
    LD A, (ro.rocketState)
    CP ro.ROST_READY
    RET NZ
    
    ; ##########################################
    ; Jetman collision with first (lowest) rocket element triggers liftoff.
    LD IX, (ro.rocketElPtr)

    LD BC, (rocAssemblyX)                  ; X of the element.
    LD B, 0
    LD A, (ro.rocY)                           ; Y of the element.
    LD D, A
    CALL jco.JetmanElementCollision
    RET NZ

    ; ##########################################
    ; Jetman boards the rocket!
    LD A, ro.ROST_FLY
    LD (ro.rocketState), A

    CALL gc.RocketFLyStartPhase1

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 _UpdateFuelProgressBar                   ;
;----------------------------------------------------------;
_UpdateFuelProgressBar

    ; Return if gamebar is hidden.
    LD A, (gb.gamebarState)
    CP gb.GB_VISIBLE
    RET NZ

    ; ##########################################
    ; Return if still building the rocket.
    LD A, (rocketElementCnt)
    CP EL_PROGRESS_START
    RET C

    ; ##########################################
    ; Show icon on first load only.
    JR NZ, .afterIcon
    CALL _ShowHeatBarIcon
.afterIcon

    ; ##########################################
    ; Dropping fuel already, show a progress bar.
    LD B, 0                                     ; Loop from 0 to EL_TANK_SIZE.
    LD HL, BAR_RAM_START
.tilesLoop

    LD A, (rocketElementCnt)
    SUB EL_PROGRESS_START
    CP B
    JR C, .emptyBar                             ; Jump if B < (#rocketElementCnt-EL_TANK1_D4).
    LD A, _BAR_FULL_SPR
    JR .afterBar
.emptyBar
    LD A, _BAR_EMPTY_SPR
.afterBar
    ADD B
    
    LD (HL), A                                  ; Set tile id.
    INC HL
    LD (HL), BAR_TILE_PAL                       ; Set palette for tile.
    INC HL

    ; ##########################################
    ; Loop
    INC B
    LD A, B
    CP EL_TANK_SIZE
    JR NZ, .tilesLoop

    RET                                         ; ## END of the function #

;----------------------------------------------------------;
;                    _ShowHeatBarIcon                      ;
;----------------------------------------------------------;
_ShowHeatBarIcon

    LD HL, BAR_ICON_RAM_START

    LD (HL), BAR_ICON                           ; Set tile id.
    INC HL
    LD (HL), BAR_ICON_PAL                       ; Set palette for tile.

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE