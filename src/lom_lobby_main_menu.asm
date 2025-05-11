;----------------------------------------------------------;
;                   Lobby Main Menu                        ;
;----------------------------------------------------------;
    MODULE lom

;----------------------------------------------------------;
;                     #LoadMainMenu                        ;
;----------------------------------------------------------;
LoadMainMenu

    CALL los.SetLobbyStateMainMenu

    ; ##########################################
    ; Load palette
    LD HL, db.menuBgPaletteAdr
    LD A, (db.menuBbPaletteBytes)
    LD B, A
    CALL bp.LoadPalette

    ; ##########################################
    ; Load background image
    CALL fi.LoadLobbyImage
    CALL bm.CopyImageData

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE   