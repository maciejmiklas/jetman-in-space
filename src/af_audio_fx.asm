/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/

;----------------------------------------------------------;
;                        Audio FX                          ;
;----------------------------------------------------------;

    MODULE af

    ; TO USE THIS MODULE: CALL dbs.SetupAyFxsBank

FX_JET_LAND             = 1
FX_FIRE2                = 2
MENU_ENTER              = 3 
FX_ROCKET_START         = 4
FX_PICKUP_LIVE          = 5
FX_JET_NORMAL           = 6
FX_PICKUP_FUEL          = 7
FX_GRENADE_EXPLODE      = 8
FX_PICKUP_DIAMOND       = 9
FX_JET_OVERHEAT         = 10
FX_EXPLODE_TANK         = 11
FX_PICKUP_GUN           = 12
FX_BUMP_PLATFORM        = 13
FX_JET_KILL             = 14
FX_FIRE1                = 15
FX_EXPLODE_ENEMY_1      = 16
FX_ROCKET_READY         = 17
FX_EXPLODE_ENEMY_2      = 18
FX_EXPLODE_ENEMY_3      = 19
FX_ROCKET_FLY           = 20
FX_ROCKET_EL_DROP       = 21
FX_PICKUP_STRAWBERRY    = 22
FX_MENU_MOVE            = 23
FX_PICKUP_JAR           = 24
FX_PICKUP_ROCKET_EL     = 25
FX_FIRE_PLATFORM_HIT    = 26
FX_JET_TAKE_OFF         = 27
FX_THIEF                = 28
FX_FREEZE_ENEMIES       = 29
FX_ROCKET_FLY_SLOW      = 30

fxFlipFlop              DB 0

;----------------------------------------------------------;
;                         SetupAyFx                        ;
;----------------------------------------------------------;
; Setup AYFX for playing sound effects.
SetupAyFx

    CALL af1.SetupAyFx
    CALL af2.SetupAyFx

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                         AfxFrame                         ;
;----------------------------------------------------------;
; Play the current frame.
AfxFrame

    CALL af1.AfxFrame
    CALL af2.AfxFrame

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        AfxPlay                           ;
;----------------------------------------------------------;
; Launch the effect on a free channel. If no free channels, the longest sounding is selected.
; Input: 
;  - A:  effect number 0..255
AfxPlay

    PUSH AF

    ; 1 -> 0 and 0 -> 1
    LD A, (fxFlipFlop)
    XOR 1
    LD (fxFlipFlop), A
    OR A                                        ; Same as CP 0, but faster.
    JR Z, .fx2

    POP AF
    CALL af1.AfxPlay
    RET

.fx2
    POP AF
    CALL af2.AfxPlay

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE