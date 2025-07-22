;----------------------------------------------------------;
;                         Game Bar                         ;
;----------------------------------------------------------;
    MODULE gb 

GB_VISIBLE              = 1
GB_HIDDEN               = 0
GB_TILES_D13            = 320 / 8 * 3

gamebarState            DB GB_VISIBLE

;----------------------------------------------------------;
;                     HideGameBar                          ;
;----------------------------------------------------------;
HideGameBar

    ; Update state
    LD A, GB_HIDDEN
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
    LD A, GB_VISIBLE
    LD (gamebarState),A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      PrintDebug                          ;
;----------------------------------------------------------;
PrintDebug

    ; Return if gamebar is hidden
    LD A, (gamebarState)
    CP GB_VISIBLE
    RET NZ


    ; ##########################################
    LD IX, fe.fEnemySprites

    CALL dbs.SetupFollowingEnemyBank
    LD BC, 40
    LD H, 0
    LD A, (IX + SPR.STATE) 
    LD L, A
    CALL ut.PrintNumber

    ; ##########################################
    LD IX, fe.fEnemySprites2

    CALL dbs.SetupFollowingEnemyBank
    LD BC, 46
    LD H, 0
    LD A, (IX + SPR.STATE) 
    LD L, A
    CALL ut.PrintNumber

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE