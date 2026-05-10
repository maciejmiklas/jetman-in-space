/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                         Grenades                         ;
;----------------------------------------------------------;
    MODULE gr

grenadeCount            DB 0

GRENADE_ICON_CHAR       = 'G'
GRENADE_ICON_TI_POS     = 19
GRENADE_COUNT_TI_POS    = 20



;----------------------------------------------------------;
;                  UpdateGranedeGamebar                    ;
;----------------------------------------------------------;
UpdateGranedeGamebar

    LD A, (grenadeCount)
    OR A                                        ; Same as CP 0, but faster.
    RET Z

    CALL _UpdateeGamebar

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     GrenadePickup                        ;
;----------------------------------------------------------;
GrenadePickup

    LD A, (grenadeCount)
    INC A
    LD (grenadeCount), A

    CALL _UpdateeGamebar

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       UseGrenade                         ;
;----------------------------------------------------------;
UseGrenade

    LD A, (grenadeCount)
    OR A                                        ; Same as CP 0, but faster.
    RET Z

    DEC A
    LD (grenadeCount), A

    CALL enc.KillFewEnemies
    _AFX af.FX_GRENADE_EXPLODE
    CALL _UpdateeGamebar

    RET                                         ; ## END of the function ##



;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                    _UpdateeGamebar                       ;
;----------------------------------------------------------;
_UpdateeGamebar

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