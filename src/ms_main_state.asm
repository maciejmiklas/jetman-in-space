;----------------------------------------------------------;
;                      Main State                          ;
;----------------------------------------------------------;
    MODULE ms

GAME_ACTIVE             = 1
GAME_PAUSE              = 2
FLY_ROCKET              = 3
LEVEL_INTRO             = 4
MAIN_MENU               = 5

mainState              BYTE MAIN_MENU

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