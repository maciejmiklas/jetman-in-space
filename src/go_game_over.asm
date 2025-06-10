;----------------------------------------------------------;
;                      Game Over                           ;
;----------------------------------------------------------;
    MODULE go

GAME_OVER_CNT           = 2
fireCnt                 DB 0

;----------------------------------------------------------;
;                       GameOverLoop                       ;
;----------------------------------------------------------;
GameOverLoop

    LD A, (fireCnt)
    CP GAME_OVER_CNT
    RET Z

    INC A
    LD (fireCnt), A

    RET                                         ; ## END of the function ##
;----------------------------------------------------------;
;                       ShowGameOver                       ;
;----------------------------------------------------------;
ShowGameOver

    XOR A
    LD (fireCnt),A
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

    LD DE, _OnFirePressed
    LD (mij.callbackFire), DE

    ; ##########################################
    ; Music
    CALL dbs.SetupMusicBank
    LD A, aml.MUSIC_GAME_OVER
    CALL aml.LoadSong

    RET                                         ; ## END of the function ##


;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                      _OnFirePressed                      ;
;----------------------------------------------------------;
_OnFirePressed

    ; Player should not be able to exit the game over screen too quickly, for example, when the auto fire is enabled
    LD A, (fireCnt)
    CP GAME_OVER_CNT
    RET NZ

    CALL mms.EnterNewScore
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE