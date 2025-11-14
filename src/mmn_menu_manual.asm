;----------------------------------------------------------;
;                     Game Manual                          ;
;----------------------------------------------------------;
; Manual handles two menus: MENU_EL_KEYS (IN GAME KEYS) and MENU_EL_GAMEPLAY (GAMEPLAY)
    MODULE mmn

;----------------------------------------------------------;
;                     LoadMenuGameplay                     ;
;----------------------------------------------------------;
LoadMenuGameplay

    CALL _PreLoadMenu

    ; Load tiles with manual
    CALL fi.LoadMenuGameplayTilemapFile
    
    ; Load palette
    LD D, "m"
    LD E, "g"
    PUSH DE

    CALL fi.LoadBgPaletteFile
    CALL btd.LoadOriginalPalette

    POP DE

    ; Load background image
    LD D, "m"
    LD E, "g"
    CALL fi.LoadBgImageFile
    CALL bm.CopyImageData

    ; ##########################################
    ; Setup joystick
    CALL ki.ResetKeyboard

    LD DE, gc.LoadMainMenu
    LD (ki.callbackFire), DE

    ; ##########################################
    ; Music on
    CALL dbs.SetupMusicBank
    CALL aml.MusicOn

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      LoadMenuKeys                        ;
;----------------------------------------------------------;
LoadMenuKeys

    CALL _PreLoadMenu

    ; Load tiles with manual
    CALL fi.LoadMenuKeysTilemapFile

    ; Load palette
    LD D, "m"
    LD E, "k"
    PUSH DE

    CALL fi.LoadBgPaletteFile
    CALL btd.LoadOriginalPalette
    POP DE

    ; Load background image

    CALL fi.LoadBgImageFile
    CALL bm.CopyImageData

    ; ##########################################
    ; Setup joystick
    CALL ki.ResetKeyboard

    LD DE, gc.LoadMainMenu
    LD (ki.callbackFire), DE

    ; ##########################################
    ; Music on
    CALL dbs.SetupMusicBank
    CALL aml.MusicOn

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                       _PreLoadMenu                       ;
;----------------------------------------------------------;
_PreLoadMenu

    ; Music of
    CALL dbs.SetupMusicBank
    CALL aml.MusicOff

    LD A, ms.MENU_MANUAL
    CALL ms.SetMainState

    CALL js.HideJetSprite
    CALL ti.CleanAllTiles
    CALL bm.HideImage
    
    RET                                         ; ## END of the function ##
    
;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE