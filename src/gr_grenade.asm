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
;                   gr.GrenadePickup                       ;
;----------------------------------------------------------;
    MACRO gr.GrenadePickup

    LD A, (gr.grenadeCount)
    INC A
    LD (gr.grenadeCount), A

    CALL gr._UpdateGamebar

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                     gr.UseGrenade                        ;
;----------------------------------------------------------;
    MACRO gr.UseGrenade

    LD A, (gr.grenadeCount)
    CP 0
    JR Z, .end

    DEC A
    LD (gr.grenadeCount), A

    CALL gc.KillFewEnemies

    CALL dbs.SetupAyFxsBank
    LD A, af.FX_GRENADE_EXPLODE
    CALL af.AfxPlay

    CALL gr._UpdateGamebar

.end
    ENDM                                        ; ## END of the macro ##

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