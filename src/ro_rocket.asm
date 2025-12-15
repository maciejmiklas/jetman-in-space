/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;               Building and Flying the Rocket             ;
;----------------------------------------------------------;
    MODULE ro

RO_DROP_NEXT_D10        = 10                    ; Drop next element delay.
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

rocketState             DB ROST_INACTIVE

ROST_INACTIVE           = 0
ROST_WAIT_DROP          = 1                     ; Rocket element (or fuel tank) is waiting for drop from the sky.

ROST_FALL_PICKUP        = 10                    ; Rocket element (or fuel tank) is falling down for pickup.
ROST_FALL_ASSEMBLY      = 11                    ; The rocket element (or fuel tank) falls towards the rocket for assembly.
ROST_WAIT_PICKUP        = 12                    ; Rocket element (or fuel tank) is waiting for pickup.
ROST_CARRY              = 13                    ; Jetman carries rocket element (or fuel tank).
ROST_TANK_EXPLODE       = 14

ROST_READY              = 100                   ; Rocket is ready to start and waits only for Jetman.
ROST_FLY                = 101                   ; The rocket is flying towards an unknown planet. See also #rof.rocketFlyPhase
ROST_EXPLODE            = 102                   ; Rocket explodes after hitting something.

DROP_LAND_Y_ADJ         = -5

; The single rocket element or fuel tank.
; The X coordinate of the rocket element is stored in two locations: 
;  1) #RO.DROP_X: when elements drop for pickup by Jetman.
;  2) #roxX when building the rocket.
    STRUCT RO
; Configuration values  
DROP_X                  DB                      ; X coordinate to drop the given element/tank, max 255.
DROP_LAND_Y             DB                      ; Y coordinates where the dropped element/tank should land. Usually, it's the height of the platform/ground.
ASSEMBLY_Y              DB                      ; Height where given rocket element should land for assembly.
SPRITE_ID               DB                      ; Hardware ID of the sprite.
SPRITE_REF              DB                      ; Sprite pattern number from the sprite file.

; Values set in program
Y                       DB                      ; Current Y position
    ENDS

explodeTankCnt          DB 0                    ; Current position in #rocketExplodeTankDB.
EXPLODE_TANK_MAX        = 4                     ; The amount of explosion sprites.

SPR_PAT_READY1_D60      = 60                    ; Once the rocket is ready, it will start blinking using #SPR_PAT_READY1_D60 and #SPR_PAT_READY2_D61.
SPR_PAT_READY2_D61      = 61
EL_LOW_D1               = 1
EL_MID_D2               = 2
EL_TOP_D3               = 3
EL_TANK1_D4             = 4
EL_TANK6_D9             = 9
EL_TANK_SIZE            = EL_TANK6_D9 - EL_TANK1_D4 + 1
EL_PROGRESS_START       = EL_TANK1_D4+1
CARRY_ADJUSTY_D10       = 10

rocketElPtr            DW 0                     ; Pointer to 9x ro.RO.

BAR_TILE_START         = 25*2                   ; *2 because each tile takes 2 bytes.
BAR_RAM_START          = ti.TI_MAP_RAM_H5B00 + BAR_TILE_START ; HL points to screen memory containing tilemap.
BAR_TILE_PAL           = $60

BAR_ICON               = 36
BAR_ICON_RAM_START     = BAR_RAM_START - 2
BAR_ICON_PAL           = $00
DROP_MARGX_D8           = 8

rocX                    DW 0                    ; 0-320px

;----------------------------------------------------------;
;                        SetupRocket                       ;
;----------------------------------------------------------;
; Input:
;  - A: X coordinate for rocket assembly.
;  - HL: Array containing 9 #RO elements.
SetupRocket

    LD (rocX), A
    LD (rocketElPtr), HL

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

    LD A, ROST_READY
    LD (rocketState), A

    LD A, 1
    LD IX, (rocketElPtr)
    
    CALL MoveIXtoGivenRocketElement
    LD A, 233
    LD (IX + RO.Y), A

    LD A, 2
    LD IX, (rocketElPtr)
    CALL MoveIXtoGivenRocketElement
    LD A, 217
    LD (IX + RO.Y), A

    LD A, 3
    LD IX, (rocketElPtr)
    CALL MoveIXtoGivenRocketElement
    LD A, 217
    LD (IX + RO.Y), 201

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   StartRocketAssembly                    ;
;----------------------------------------------------------;
StartRocketAssembly
    CALL dbs.SetupArrays2Bank

    LD A, ROST_WAIT_DROP
    LD (rocketState), A
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 ResetAndDisableRocket                    ;
;----------------------------------------------------------;
ResetAndDisableRocket
    CALL dbs.SetupArrays2Bank

    XOR A
    LD (rocX), A
    LD (rocY), A
    LD (dropNextDelay), A
    LD (rocketState), A
    LD (explodeTankCnt), A
    LD (rocketElementCnt), A

    ; ##########################################
    ; Reset rocket elements
    LD B, EL_TANK6_D9
    LD IX, (rocketElPtr)
.rocketElLoop

    XOR A
    LD (IX + RO.Y), A

    LD A, (IX + RO.SPRITE_ID)
    CALL sp.SetIdAndHideSprite

    ; ##########################################
    ; Next rocket element
    LD DE, IX
    ADD DE, RO
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
    LD A, (rocketState)
    CP ROST_FALL_PICKUP
    JR Z, .isFuel

    CP ROST_WAIT_PICKUP
    JR Z, .isFuel

    CP ROST_FALL_ASSEMBLY
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
    LD A, (rocketState)
    CP ROST_TANK_EXPLODE
    RET Z                                       ; Return if tank is already exploding.

    ; ##########################################
    ; Check hit by leaser beam
    CALL _SetIXtoCurrentRocketElement

    ; The X coordinate of the rocket element is stored in two locations: 
    ;  1) #RO.DROP_X: when elements drop for pickup by Jetman.
    ;  2) #roxX when building the rocket.
    LD A, (rocketState)
    CP ROST_FALL_ASSEMBLY
    JR Z, .assembly
    
    ; Falling rocket element for pickup
    LD DE, (IX + RO.DROP_X)                     ; X param for #ShotsCollision.
    JR .afterAssembly
.assembly
    ; The rocket is already assembled and waiting for fuel.
    LD DE, (rocX)                    ; X param for #ShotsCollision.
.afterAssembly

    LD D, 0                                     ; Reset D, X coordinate for drop is 8 bit.

    LD C,  (IX + RO.Y)                          ; Y param for #ShotsCollision.
    CALL jw.ShotsCollision
    CP jw.SHOT_HIT
    RET NZ

    ; ##########################################
    ; The laser beam hits the falling rocket tank!
    XOR A
    LD (explodeTankCnt), A

    LD A, ROST_TANK_EXPLODE
    LD (rocketState), A

    ; ##########################################
    CALL gc.RocketTankHit

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   AnimateTankExplode                     ;
;----------------------------------------------------------;
AnimateTankExplode
    CALL dbs.SetupArrays2Bank

    ; Return if tank is not exploding.
    LD A, (rocketState)
    CP ROST_TANK_EXPLODE
    RET NZ

    ; Is explosion over?
    LD A, (explodeTankCnt)
    CP EXPLODE_TANK_MAX
    JR NZ, .keepExploding

    ; Explosion is over.
    LD A, ROST_WAIT_DROP
    LD (rocketState), A

    CALL _ResetRocketElement
    RET

.keepExploding

    CALL _SetIXtoCurrentRocketElement

    ; Set the ID of the sprite for the following commands.
    LD A, (IX + RO.SPRITE_ID)
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
    LD A, (rocketState)
    CP ROST_CARRY
    RET NZ

    CALL _ResetRocketElement

    RET                                         ; ## END of the function ## 

;----------------------------------------------------------;
;               RocketElementFallsForPickup                ;
;----------------------------------------------------------;
RocketElementFallsForPickup

    CALL dbs.SetupArrays2Bank

    ; Return if there is no fall.
    LD A, (rocketState)
    CP ROST_FALL_PICKUP
    RET NZ                                      ; Return if falling bit is not set.

    CALL _SetIXtoCurrentRocketElement           ; Set IX to current #rocket postion.

    ; Move element one pixel down
    LD A, (IX + RO.Y)
    INC A
    LD (IX + RO.Y), A

    ; Update rocket sprite.
    LD A, (IX + RO.DROP_X)                      ; Sprite X coordinate, do not change value - element is falling down.
    CALL UpdateElementPosition

    ; Has the horizontal destination been reached?
    LD B, A
    LD A, DROP_LAND_Y_ADJ
    LD C, A
    LD A, (IX + RO.DROP_LAND_Y)
    ADD C                                       ; A = #DROP_LAND_Y + #DROP_LAND_Y_ADJ
    CP B
    RET NZ                                      ; No, keep falling down.
    
    ; Yes, element has reached landing postion.
    LD A, ROST_WAIT_PICKUP
    LD (rocketState), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 UpdateElementPosition                    ;
;----------------------------------------------------------;
; Input:
;  - IX: current #RO pointer.
;  - A:  X postion.
UpdateElementPosition

    LD B, A                                     ; Backup A

    LD D, (IX + RO.SPRITE_REF)
    CALL UpdateRocketSpritePattern

    ; ##########################################
    ; Sprite X coordinate from A param.
    LD A, B                                     ; Restore A
    NEXTREG _SPR_REG_X_H35, A

    LD A, _SPR_REG_ATR2_EMPTY
    NEXTREG _SPR_REG_ATR2_H37, A

    ; ##########################################
    ; Sprite Y coordinate.
    LD A, (IX + RO.Y)
    NEXTREG _SPR_REG_Y_H36, A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    BlinkRocketReady                      ;
;----------------------------------------------------------;
BlinkRocketReady

    CALL dbs.SetupArrays2Bank

    ; Return if rocket is not ready.
    LD A, (rocketState)
    CP ROST_READY
    RET NZ  

    ; Set the ID of the sprite for the following commands.
    LD A, RO_DOWN_SPR_ID_D80
    NEXTREG _SPR_REG_NR_H34, A

    ; Set sprite pattern - one for flip, one for flop -> rocket will blink waiting for Jetman.
    LD A, (mld.counter008FliFLop)
    CP _GC_FLIP_ON_D1
    JR Z, .flip
    LD A, SPR_PAT_READY1_D60
    JR .afterSet
.flip   
    LD A, SPR_PAT_READY2_D61
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
    LD A, (rocketState)
    CP ROST_FALL_ASSEMBLY
    RET NZ                                      ; Return if assembly bit is not set.

    ; ##########################################
    ; Set IX to current #rocket postion.
    CALL _SetIXtoCurrentRocketElement

    ; ##########################################
    ; Set the ID of the sprite for the following commands.
    LD A, (IX + RO.SPRITE_ID)
    NEXTREG _SPR_REG_NR_H34, A

    ; ##########################################
    ; Sprite X coordinate to assembly location.
    LD A, (rocX)
    NEXTREG _SPR_REG_X_H35, A

    ; ##########################################
    ; Set sprite pattern.
    LD A, (IX + RO.SPRITE_REF)
    OR _SPR_PATTERN_SHOW                        ; Set show bit.
    NEXTREG _SPR_REG_ATR3_H38, A

    ; ##########################################
    ; Sprite Y coordinate, increment until the destination has been reached.
    LD A, (IX + RO.Y)
    INC A
    LD (IX + RO.Y), A
    NEXTREG _SPR_REG_Y_H36, A

    ; ##########################################
    ; Has the horizontal destination been reached?
    LD B, A
    LD A, (IX + RO.ASSEMBLY_Y)
    CP B
    RET NZ                                      ; No, keep falling down.

    ; ##########################################
    ; Yes, element has reached landing postion, set state for next drop.
    LD A, ROST_WAIT_DROP
    LD (rocketState), A

    ; ##########################################
    ; Check if we are dropping fuel already. If it's the case, hide the fuel tank sprite. Sprite of rocket element remains visible.
    LD A, (rocketElementCnt)
    CP EL_TANK1_D4
    RET C                                       ; Jump if counter is < 4 (still assembling rocket).

    ; We are dropping fuel already, hide the fuel sprite as it has reached the rocket.
    LD A, (IX + RO.SPRITE_ID)
    CALL sp.SetIdAndHideSprite

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  DropNextRocketElement                   ;
;----------------------------------------------------------;
DropNextRocketElement
    CALL dbs.SetupArrays2Bank
    
    ; Check state.
    LD A, (rocketState)
    CP ROST_WAIT_DROP
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

    LD A, ROST_READY
    LD (rocketState), A

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
    LD A, ROST_FALL_PICKUP
    LD (rocketState), A

    ; Drop next rocket element/tank, first set IX to current #rocket postion.
    CALL _SetIXtoCurrentRocketElement

    ; Reset Y for element/tank to top of the screen.
    XOR A                                       ; Set A to 0
    LD (IX + RO.Y), A
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 MoveIXtoGivenRocketElement               ;
;----------------------------------------------------------;
; Input:
;  - A: rocket element from 1 to 6
MoveIXtoGivenRocketElement

    ; Load the pointer to #rocket into IX and move the pointer to the actual rocket element.
    LD IX, (rocketElPtr)
    
    SUB 1                                       ; A contains 0-2.
    LD D, A
    LD E, RO                                    ; D contains A, E contains size of #RO.
    MUL D, E                                    ; DE contains D * E.
    ADD IX, DE                                  ; IX points to active #rocket (#RO).

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                UpdateRocketSpritePattern                 ;
;----------------------------------------------------------;
; Input:
;  - IX: current #RO pointer.
;  - D:  sprite pattern.
UpdateRocketSpritePattern

    ; Set the ID of the sprite for the following commands.
    LD A, (IX + RO.SPRITE_ID)
    NEXTREG _SPR_REG_NR_H34, A
    
    ; ##########################################
    ; Set sprite pattern
    LD A, D
    OR _SPR_PATTERN_SHOW                        ; Set show bit.
    NEXTREG _SPR_REG_ATR3_H38, A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   RemoveRocketElement                    ;
;----------------------------------------------------------;
RemoveRocketElement

    LD A, (rocketElementCnt)
    DEC A
    LD (rocketElementCnt), A
    
    CALL _UpdateFuelProgressBar

    ; Change state
    LD A, ROST_WAIT_DROP
    LD (rocketState), A

    ; Reset drop delay
    XOR A                                       ; Set A to 0.
    LD (dropNextDelay), A

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
    LD IX, (rocketElPtr)

    ; Now, move IX so that it points to the #RO given by the deploy counter. First, load the counter into A (value 1-6).
    ; Afterward, load A info D and the size of the #RO into E, and multiply D by E.
    LD A, (rocketElementCnt)
    CALL MoveIXtoGivenRocketElement

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  _PickupRocketElement                    ;
;----------------------------------------------------------;
_PickupRocketElement

    ; Return if there is no element/tank to pick up. Status must be #ROST_WAIT_PICKUP or #ROST_FALL_PICKUP.
    LD A, (rocketState)
    CP ROST_WAIT_PICKUP
    JR Z, .afterStatusCheck

    CP ROST_FALL_PICKUP
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
    LD BC, (IX + RO.DROP_X)                     ; X of the element.
    LD B, 0
    LD D, (IX + RO.Y)                           ; Y of the element.
    CALL jco.JetmanElementCollision
    RET NZ

     ; ##########################################
    ; Call game command with pickup info.
    LD A, (rocketState)
    CP ROST_FALL_PICKUP
    JR NZ, .pickupOnGround
    CALL gc.RocketElementPickupInAir
.pickupOnGround
    CALL gc.RocketElementPickup

    ; ##########################################
    ; Jetman picks up element/tank. Update state to reflect it and return.
    LD A, ROST_CARRY
    LD (rocketState), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    _MoveWithJetman                       ;
;----------------------------------------------------------;
; Move the element to the current Jetman's position.
_MoveWithJetman

    ; Set the ID of the sprite for the following commands.
    LD A, (IX + RO.SPRITE_ID)
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
    LD A, (rocX)
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
    LD A, ROST_FALL_ASSEMBLY
    LD (rocketState), A

    ; ##########################################
    ; Store the height of the drop so that the element can keep falling from this location into the assembly place.
    CALL _SetIXtoCurrentRocketElement           ; Set IX to current #rocket postion.
    LD A, (jpo.jetY)
    LD (IX + RO.Y), A

    ; ##########################################
    CALL gc.RocketElementDrop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   _CarryRocketElement                    ;
;----------------------------------------------------------;
_CarryRocketElement

    ; Return if the state does not match.
    LD A, (rocketState)
    CP ROST_CARRY
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
    LD A, (IX + RO.SPRITE_ID)
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
    LD A, (rocketState)
    CP ROST_READY
    RET NZ
    
    ; ##########################################
    ; Jetman collision with first (lowest) rocket element triggers liftoff.
    LD IX, (rocketElPtr)

    LD BC, (rocX)                               ; X of the element.
    LD B, 0
    LD D, (IX + RO.Y)                           ; Y of the element.
    CALL jco.JetmanElementCollision
    RET NZ

    ; ##########################################
    ; Jetman boards the rocket!
    LD A, ROST_FLY
    LD (rocketState), A

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