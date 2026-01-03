/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                     Jetman State Logic                   ;
;----------------------------------------------------------;
    MODULE jt

JT_STATE_INACTIVE           = 0                 ; Must be 0, because we reset it with "XOR A"

; States for Jetman in the air, 0 for not in the air
AIR_FLY                 = 10                    ; Jetman is flaying.
AIR_HOOVER              = 11                    ; Jetman is hovering.
AIR_FALL_RIGHT          = 12                    ; Jetman falls from platform on the right.
AIR_FALL_LEFT           = 13                    ; Jetman falls from platform on the left.
AIR_BUMP_RIGHT          = 14                    ; Jetman bumps into a platform from the right, he faces/moves left.
AIR_BUMP_LEFT           = 15                    ; Jetman bumps into a platform from the left, he faces/moves right.
AIR_BUMP_BOTTOM         = 16                    ; Jetman bumps into a platform from the bottom.
AIR_ENEMY_KICK          = 17                    ; Jetman flies above the enemy and kicks.

jetAir                  DB JT_STATE_INACTIVE    ; Game start, Jetman standing on the ground (see _JM_RESPAWN_Y_D217).

; States for Jetman on the platform/ground
GND_WALK                = 51                    ; Jetman walks on the ground.
GND_JSTAND              = 52                    ; Jetman stands on the ground for a very short time, not enough to switch to #GND_STAND.
GND_STAND               = 53                    ; Jetman stands on the ground.

jetGnd                  DB GND_STAND

; Jetman states
JETST_NORMAL            = 101                   ; Jetman is alive, could be flying (#jetAir != JT_STATE_INACTIVE) or walking (#jetGnd != JT_STATE_INACTIVE).
JETST_INV               = 102                   ; Jetman is invincible.
JETST_RIP               = 103                   ; Jetman got hit by enemy.
JETST_OVERHEAT          = 104                   ; Jetpack is overheating, and Jetman flays slowly.

jetState                DB JETST_NORMAL         ; Game start, Jetman in the air.

DIF_EASY                = 1
DIF_NORMAL              = 2
DIF_HARD                = 3
difLevel                DB DIF_NORMAL

levelNumber             DW "00"                 ; ASCII level number from 01 to 10

;----------------------------------------------------------;
;              jt.UpdateStateOnJoyWillEnable               ;
;----------------------------------------------------------;
    MACRO jt.UpdateStateOnJoyWillEnable

    ; Reset #jetAir
    LD A, (jt.jetAir)
    CP jt.JT_STATE_INACTIVE
    JR Z, .afterResetAir                        ; Do not need to reset if #jetAir is inactive.

    ; Reset!
    LD A, jt.AIR_FLY
    LD (jt.jetAir), A
.afterResetAir

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                      SetJetStateAir                      ;
;----------------------------------------------------------;
; Input:
;  - A:                                         ; Air State: #AIR_XXX.
SetJetStateAir

    LD (jetAir), A                              ; Update Air from param.

    XOR A
    LD (jetGnd), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     SetJetStateGnd                       ;
;----------------------------------------------------------;
SetJetStateGnd

    LD (jetGnd), A

    XOR A
    LD (jetAir), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   jt.SetJetStateRip                      ;
;----------------------------------------------------------;
    MACRO jt.SetJetStateRip

    XOR A
    LD (jt.jetAir), A
    LD (jt.jetGnd), A

    LD A, jt.JETST_RIP
    LD (jt.jetState), A

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                 jt.SetJetStateRespawn                    ;
;----------------------------------------------------------;
    MACRO jt.SetJetStateRespawn

    LD A, jt.GND_STAND
    LD (jt.jetGnd), A

    XOR A
    LD (jt.jetAir), A
    
    LD A, jt.JETST_NORMAL
    LD (jt.jetState), A

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                   SetJetStateInactive                    ;
;----------------------------------------------------------;
SetJetStateInactive

    XOR A
    LD (jetAir), A
    LD (jetGnd), A
    LD (jetState), A
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     jt.ResetOverheat                     ;
;----------------------------------------------------------;
    MACRO jt.ResetOverheat

    ; Reset overheat only if it's active.
    LD A, (jt.jetState)
    CP jt.JETST_OVERHEAT
    JR NZ, .end

    LD A, jt.JETST_NORMAL
    LD (jt.jetState), A

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                     jt.SetJetState                       ;
;----------------------------------------------------------;
; Input:
;  - A:                                         ; Air State: #JETST_XXX
    MACRO jt.SetJetState

    LD (jt.jetState), A

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE       