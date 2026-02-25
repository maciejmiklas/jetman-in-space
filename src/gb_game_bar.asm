/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                         Game Bar                         ;
;----------------------------------------------------------;
    MODULE gb 

GB_VISIBLE_D1           = 1
GB_HIDDEN_D0            = 0
GB_TILES_D13            = 320 / 8 * 3

gamebarState            DB GB_VISIBLE_D1

;----------------------------------------------------------;
;                     HideGameBar                          ;
;----------------------------------------------------------;
HideGameBar

    ; Update state
    LD A, GB_HIDDEN_D0
    LD (gamebarState), A

    ; ##########################################
    ; Remove gamebar from screen
    LD A, GB_TILES_D13
    LD B, A
    CALL ti.CleanTiles

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     ShowGameBar                          ;
;----------------------------------------------------------;
ShowGameBar

    ; Update state
    LD A, GB_VISIBLE_D1
    LD (gamebarState),A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      PrintDebug                          ;
;----------------------------------------------------------;
    IFDEF DEBUG_BAR
PrintDebug

    ; Return if gamebar is hidden
    LD A, (gamebarState)
    OR A
    RET Z

    IFDEF PERFORMANCE
    ; ##########################################
    LD BC, 40
    LD H, 0
    LD A, (endLine)
    LD L, A
    CALL ut.PrintNumber

    ; ##########################################
    LD BC, 46
    LD H, 0
    LD A, (endLineMax)
    LD L, A
    CALL ut.PrintNumber
    ENDIF

    CALL dbs.SetupCode1Bank
    ; ##########################################
    LD BC, 60
    LD HL, (so.checksumVerify)
    CALL ut.PrintNumber

    ; ##########################################
    LD BC, 66
    LD H, 0
    LD A, (so.checksumEasy)
    LD L, A
    CALL ut.PrintNumber
/*
    ; ##########################################
    LD BC, 72
    LD H, 0
    LD A, (so.checksumNormal)
    LD L, A
    CALL ut.PrintNumber

    ; ##########################################
    LD BC, 80
    LD H, 0
    LD A, (so.checksumHard)
    LD L, A
    CALL ut.PrintNumber
*/
    RET                                         ; ## END of the function ##
    ENDIF
;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE