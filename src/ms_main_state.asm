;----------------------------------------------------------;
;                      Lobby State                         ;
;----------------------------------------------------------;
    MODULE ms

GAME_ACTIVE             = 1
GAME_PAUSE              = 2
LEVEL_INTRO             = 3
MAIN_MENU               = 4
SUBMENU_SETTING         = 5
SUBMENU_HIGH_SCORE      = 6
FLY_ROCKET              = 7

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