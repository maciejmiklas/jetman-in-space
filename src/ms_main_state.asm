/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                      Main State                          ;
;----------------------------------------------------------;
    MODULE ms

GAME_ACTIVE             = 1
GAME_PAUSE              = 2
FLY_ROCKET              = 3

LEVEL_INTRO             = 10
MENU_MAIN               = 11
MENU_MANUAL             = 12
MENU_SCORE              = 13
MENU_LEVEL              = 14

GAME_OVER               = 20
PAUSE                   = 30

mainState              DB MENU_MAIN
mainStateBackup        DB MENU_MAIN

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