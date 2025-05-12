;----------------------------------------------------------;
;                   Lobby Main Menu                        ;
;----------------------------------------------------------;
    MODULE lom

;----------------------------------------------------------;
;                     #LoadMainMenu                        ;
;----------------------------------------------------------;
LoadMainMenu

    LD A, ms.MAIN_MENU
    CALL ms.SetMainState

    ; ##########################################
    ; Load palette.
    LD HL, db.mainMenuBgPaletteAdr
    LD A, (db.mainMenuBbPaletteBytes)
    LD B, A
    CALL bp.LoadPalette

    ; ##########################################
    ; Load background image.
    CALL fi.LoadMainMenuImage
    CALL bm.CopyImageData

    ; ##########################################
    ; Load game version.
    ;CALL ti.PrintText

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE