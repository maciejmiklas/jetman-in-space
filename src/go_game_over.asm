;----------------------------------------------------------;
;                      Game Over                           ;
;----------------------------------------------------------;
    MODULE go

;----------------------------------------------------------;
;                       ShowGameOver                       ;
;----------------------------------------------------------;
ShowGameOver

    LD A, ms.GAME_OVER
    CALL ms.SetMainState

    CALL bm.HideImage

    ; Load palette
    LD HL, db.gameOverBgPaletteAdr
    LD A, (db.gameOverBgPaletteBytes)
    LD B, A
    CALL bp.LoadPalette

    ; Load background image
    LD D, "g"
    LD E, "o"
    CALL fi.LoadBgImageFile
    CALL bm.CopyImageData

    ; ##########################################
    ; Setup joystick
    CALL mij.ResetJoystick

    LD DE, mms.EnterNewScore
    LD (mij.callbackFire), DE

    ; ##########################################
    ; Music
    CALL dbs.SetupMusicBank
    LD A, aml.MUSIC_GAME_OVER
    CALL aml.LoadSong


    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE