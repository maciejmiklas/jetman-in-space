;----------------------------------------------------------;
;                         Grenades                         ;
;----------------------------------------------------------;
    MODULE gr

grenadeCount            DB 0

GRENADE_ICON_CHAR       = 'G'
GRENADE_ICON_TI_POS     = 19
GRENADE_COUNT_TI_POS    = 20

;----------------------------------------------------------;
;                     GrenadePickup                        ;
;----------------------------------------------------------;
GrenadePickup

    LD A, (grenadeCount)
    INC A
    LD (grenadeCount), A

    CALL _UpdateGamebar

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       UseGrenade                         ;
;----------------------------------------------------------;
UseGrenade

    LD A, (grenadeCount)
    CP 0
    RET Z

    DEC A
    LD (grenadeCount), A

    CALL gc.KillFewEnemies

    LD A, af.FX_GRENADE_EXPLODE
    CALL dbs.SetupAyFxsBank
    CALL af.AfxPlay

    CALL _UpdateGamebar

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                     _UpdateGamebar                       ;
;----------------------------------------------------------;
_UpdateGamebar

    ; Print icon
    LD A, GRENADE_ICON_TI_POS
    LD B, 0
    LD C, A
    LD A, GRENADE_ICON_CHAR
    CALL tx.PrintCharacterAt

    ; Print count value
    LD A, (grenadeCount)
    LD BC, GRENADE_COUNT_TI_POS
    CALL tx.PrintNum99
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE