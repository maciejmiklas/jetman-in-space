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

mainState              BYTE MENU_MAIN

;----------------------------------------------------------;
;                    #SetMainState                         ;
;----------------------------------------------------------;
; Input:
;  - A: The state.
SetMainState

    LD (mainState), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;

    ENDMODULE