/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                 Common Rocket Stuff.                     ;
;----------------------------------------------------------;
    MODULE ro

    STRUCT RO
DROP_X                  DB                      ; X coordinate to drop the given element/tank, max 255.
DROP_LAND_Y             DB                      ; Y coordinates where the dropped element/tank should land. Usually, it's the height of the platform/ground.
ASSEMBLY_Y              DB                      ; Height where given rocket element should land for assembly.
SPRITE_ID               DB                      ; Hardware ID of the sprite.
SPRITE_REF              DB                      ; Sprite pattern number from the sprite file.
    ENDS

rocketState             DB ROST_INACTIVE

ROST_INACTIVE           = 0
ROST_WAIT_DROP          = 1                     ; Rocket element (or fuel tank) is waiting for drop from the sky.

ROST_FALL_PICKUP        = 10                    ; Rocket element (or fuel tank) is falling down for pickup.
ROST_FALL_ASSEMBLY      = 11                    ; Rocket element (or fuel tank) falls towards the rocket for assembly.
ROST_WAIT_PICKUP        = 12                    ; Rocket element (or fuel tank) is waiting for pickup.
ROST_CARRY              = 13                    ; Jetman carries rocket element (or fuel tank).
ROST_TANK_EXPLODE       = 14

ROST_READY              = 100                   ; Rocket is ready to start and waits only for Jetman.
ROST_FLY                = 101                   ; Rocket is flying towards an unknown planet. See also #rof.rocketFlyPhase
ROST_EXPLODE            = 102                   ; Rocket explodes after hitting something.

EL_EXH_D1               = 1                     ; Rocket exhaust element, one that is blinking
EL_MID_D2               = 2
EL_TIP_D3               = 3                     ; Tip of the rocket.

; Offsets for rocket elemenst from EL_EXH_D1.
OFS_MID_D16              = -16
OFS_TIP_D16              = -32
OFS_FLAME_D16            = 16

SPR_PAT_READY1_D60      = 60                    ; Once the rocket is ready, it will start blinking using #SPR_PAT_READY1_D60 and #SPR_PAT_READY2_D61.
SPR_PAT_READY2_D61      = 61

; When assembling the rocket, this is the current element that is being dropped for pickup or Jetman carrying. 
; When the rocket is flying, it's the bottom sprite position (EL_EXH_D1).
rocX                    DW 0                    ; 0-320px
rocY                    DB 0                    ; 0-256px

rocketElPtr            DW 0                     ; Pointer to 9x RO.

;----------------------------------------------------------;
;                 UpdateRocketPosition                     ;
;----------------------------------------------------------;
UpdateRocketPosition

     LD IX, (rocketElPtr)                               ; Load the pointer to rocket into IX.
     
    ; Move bottom rocket element.
    XOR A
    CALL UpdateElementPosition

    ; ##########################################
    ; Move middle rocket element.
    LD A, EL_MID_D2
    CALL MoveIXtoGivenRocketElement

    LD A, OFS_MID_D16
    CALL UpdateElementPosition

    ; ##########################################
    ; Move top rocket element.
    LD A, EL_TIP_D3
    CALL MoveIXtoGivenRocketElement

    LD A, OFS_TIP_D16
    CALL UpdateElementPosition

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
;              SetRocketXSpriteCoordinate                  ;
;----------------------------------------------------------;
SetRocketXSpriteCoordinate

    LD BC, (rocX)

    ; Set MSB from X position.
    LD A, C
    NEXTREG _SPR_REG_X_H35, A

    ; Set overflow bit from X position.
    LD A, B                                     ; Load MSB from X into A.
    AND %00000001                               ; Keep only an overflow bit.
    NEXTREG _SPR_REG_ATR2_H37, A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 UpdateElementPosition                    ;
;----------------------------------------------------------;
; Input:
;  - IX: current #RO pointer.
;  - A:  correction for Y.
UpdateElementPosition

    PUSH AF
    LD D, (IX + RO.SPRITE_REF)
    CALL UpdateRocketSpritePattern

    ; ##########################################
    ; Set Rocket sprite X coordinate.
    CALL SetRocketXSpriteCoordinate

    ; ##########################################
    ; Sprite Y coordinate.
    LD A, (rocY)
    LD B, A
    POP AF
    ADD B
    NEXTREG _SPR_REG_Y_H36, A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE

