/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                 Common Rocket Stuff.                     ;
;----------------------------------------------------------;
    MODULE ro

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

EL_LOW_D1               = 1
EL_MID_D2               = 2
EL_TOP_D3               = 3

SPR_PAT_READY1_D60      = 60                    ; Once the rocket is ready, it will start blinking using #SPR_PAT_READY1_D60 and #SPR_PAT_READY2_D61.
SPR_PAT_READY2_D61      = 61

; When assembling the rocket, this is the current element that is being dropped for pickup or Jetman carrying. 
; When the rocket is flying, it's the top sprite position (the top rocket element).
rocX                    DW 0                    ; 0-320px
rocY                    DB 0                    ; 0-256px

rocketElPtr            DW 0                     ; Pointer to 9x ro.RO.


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
    LD E, RO                                    ; D contains A, E contains size of #ro.RO.
    MUL D, E                                    ; DE contains D * E.
    ADD IX, DE                                  ; IX points to active #rocket (#ro.RO).

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                UpdateRocketSpritePattern                 ;
;----------------------------------------------------------;
; Input:
;  - IX: current #ro.RO pointer.
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
;                 UpdateElementPosition                    ;
;----------------------------------------------------------;
; Input:
;  - IX: current #ro.RO pointer.
UpdateElementPosition

    LD D, (IX + RO.SPRITE_REF)
    CALL UpdateRocketSpritePattern

    ; ##########################################
    ; Sprite X coordinate from A param.
    LD A, (rocX) ; TODO - MSB + FSB
    NEXTREG _SPR_REG_X_H35, A

    LD A, _SPR_REG_ATR2_EMPTY
    NEXTREG _SPR_REG_ATR2_H37, A

    ; ##########################################
    ; Sprite Y coordinate.
    LD A, (rocY)
    NEXTREG _SPR_REG_Y_H36, A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE

