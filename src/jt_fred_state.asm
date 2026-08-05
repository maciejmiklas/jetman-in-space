/*
  Copyright (c) 2027 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                     Fred State Logic                   ;
;----------------------------------------------------------;
    MODULE jt

JT_STATE_INACTIVE_D0    = 0                 ; Must be 0, because we reset it with "XOR A"

; States for Fred in the air, 0 for not in the air
AIR_FLY_D10             = 10                    ; Fred is flaying.
AIR_HOOVER_D11          = 11                    ; Fred is hovering.
AIR_FALL_RIGHT_D12      = 12                    ; Fred falls from platform on the right.
AIR_FALL_LEFT_D13       = 13                    ; Fred falls from platform on the left.
AIR_BUMP_RIGHT_D14      = 14                    ; Fred bumps into a platform from the right, he faces/moves left.
AIR_BUMP_LEFT_D15       = 15                    ; Fred bumps into a platform from the left, he faces/moves right.
AIR_BUMP_BOTTOM_D16     = 16                    ; Fred bumps into a platform from the bottom.
AIR_ENEMY_KICK_D17      = 17                    ; Fred flies above the enemy and kicks.

jetAir                  DB JT_STATE_INACTIVE_D0    ; Game start, Fred standing on the ground (see _JM_RESPAWN_Y_D217).

; States for Fred on the platform/ground
GND_WALK_D51            = 51                    ; Fred walks on the ground.
GND_JSTAND_D52          = 52                    ; Fred stands on the ground for a very short time, not enough to switch to #GND_STAND_D53.
GND_STAND_D53           = 53                    ; Fred stands on the ground.

jetGnd                  DB GND_STAND_D53

; Fred states
JETST_NORMAL_D101       = 101                   ; Fred is alive, could be flying (#jetAir != JT_STATE_INACTIVE_D0) or walking (#jetGnd != JT_STATE_INACTIVE_D0).
JETST_INV_D102          = 102                   ; Fred is invincible.
JETST_RIP_D103          = 103                   ; Fred got hit by enemy.
JETST_OVERHEAT_D104     = 104                   ; Jetpack is overheating, and Fred flays slowly.

jetState                DB JETST_NORMAL_D101         ; Game start, Fred in the air.

DIF_EASY_D1             = 1
DIF_NORMAL_D2           = 2
DIF_HARD_D3             = 3
difLevel                DB DIF_NORMAL_D2

levelNumber             DW "00"                 ; ASCII level number from 01 to 10

;----------------------------------------------------------;
;               UpdateStateOnJoyWillEnable                 ;
;----------------------------------------------------------;
UpdateStateOnJoyWillEnable

    ; Reset #jetAir
    LD A, (jetAir)
    OR A                                        ; Same as: CP JT_STATE_INACTIVE_D0
    JR Z, .afterResetAir                        ; Do not need to reset if #jetAir is inactive.

    ; Reset!
    LD A, AIR_FLY_D10
    LD (jetAir), A
.afterResetAir

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      SetFredStateAir                      ;
;----------------------------------------------------------;
; Input:
;  - A:                                         ; Air State: #AIR_XXX.
SetFredStateAir

    LD (jetAir), A                              ; Update Air from param.

    XOR A
    LD (jetGnd), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     SetFredStateGnd                       ;
;----------------------------------------------------------;
SetFredStateGnd

    LD (jetGnd), A

    XOR A
    LD (jetAir), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     SetFredStateRip                       ;
;----------------------------------------------------------;
SetFredStateRip

    XOR A
    LD (jetAir), A
    LD (jetGnd), A

    LD A, JETST_RIP_D103
    LD (jetState), A

    RET                                         ; ## END of the function ##
    
;----------------------------------------------------------;
;                   SetFredStateRespawn                     ;
;----------------------------------------------------------;
SetFredStateRespawn

    LD A, GND_STAND_D53
    LD (jetGnd), A

    XOR A
    LD (jetAir), A
    
    LD A, JETST_NORMAL_D101
    LD (jetState), A
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   SetFredStateInactive                    ;
;----------------------------------------------------------;
SetFredStateInactive

    XOR A
    LD (jetAir), A
    LD (jetGnd), A
    LD (jetState), A
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ResetOverheat                      ;
;----------------------------------------------------------;
ResetOverheat

    ; Reset overheat only if it's active.
    LD A, (jetState)
    CP JETST_OVERHEAT_D104
    RET NZ

    LD A, JETST_NORMAL_D101
    LD (jetState), A
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       SetFredState                        ;
;----------------------------------------------------------;
; Input:
;  - A:                                         ; Air State: #JETST_XXX
SetFredState

    LD (jetState), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE       