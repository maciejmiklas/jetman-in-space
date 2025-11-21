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

    ; Copy tile definitions (sprite file) to expected memory.
    LD D, "m"
    LD E, "a"
    CALL fi.LoadTileSprFile

    ; Load palette
    LD D, "g"
    LD E, "o"
    PUSH DE

    CALL fi.LoadBgPaletteFile
    CALL bp.LoadDefaultPalette

    POP DE

    ; Load background image
    CALL fi.LoadBgImageFile
    CALL bm.CopyImageData

    ; ##########################################
    ; Setup joystick
    CALL ki.ResetKeyboard

    LD DE, _OnFirePressed
    LD (ki.callbackFire), DE

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

    ; Player should not be able to exit the game over screen too quickly, for example, when the auto fire is enabled.
    LD A, (fireCnt)
    CP GAME_OVER_CNT
    RET NZ

    CALL mms.EnterNewScore
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE