;----------------------------------------------------------;
;                      Main State                          ;
;----------------------------------------------------------;
    MODULE ms

GAME_ACTIVE             = 1
GAME_PAUSE              = 2
FLY_ROCKET              = 3
LEVEL_INTRO             = 4
MENU_MAIN               = 5
MENU_MANUAL             = 6
MENU_SCORE              = 7
GAME_OVER               = 8
PAUSE                   = 9

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