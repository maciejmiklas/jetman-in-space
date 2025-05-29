;----------------------------------------------------------;
;                     Game Manual                          ;
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
    CALL fi.LoadBgImage
    CALL bm.CopyImageData

    ; ##########################################
    ; Setup joystick
    CALL mij.ResetJoystick

    LD DE, mms.EnterNewScore
    LD (mij.callbackFire), DE

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE