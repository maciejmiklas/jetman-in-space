/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                      Main State                          ;
;----------------------------------------------------------;
    MODULE ms

MS_GAME_ACTIVE_D1       = 1
MS_GAME_PAUSE_D2        = 2
MS_FLY_ROCKET_D3        = 3

MS_LEVEL_INTRO_D10      = 10
MS_MENU_MAIN_D11        = 11
MS_MENU_MANUAL_D12      = 12
MS_MENU_SCORE_D13       = 13
MS_MENU_LEVEL_D14       = 14

MS_GAME_OVER_D20        = 20
MS_PAUSE_D30            = 30

mainState              DB MS_MENU_MAIN_D11
mainStateBackup        DB MS_MENU_MAIN_D11

;----------------------------------------------------------;
;                     SetMainState                         ;
;----------------------------------------------------------;
; Input:
;  - A: The state.
SetMainState

    LD (mainState), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                SetMainStateAndBackup                     ;
;----------------------------------------------------------;
; Input:
;  - A: The state.
SetMainStateAndBackup

    PUSH AF
    LD A, (mainState)
    LD (mainStateBackup), A
    POP AF

    LD (mainState), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   RestoreMainState                       ;
;----------------------------------------------------------;
RestoreMainState

    LD A, (mainStateBackup)
    LD (mainState), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;

    ENDMODULE