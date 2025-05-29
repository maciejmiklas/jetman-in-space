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
    CALL fi.LoadMenuGameplayTilemap
    
    ; Load palette
    LD HL, db.menuGameplayBgPaletteAdr
    LD A, (db.menuGameplayBgPaletteBytes)
    LD B, A
    CALL bp.LoadPalette

    ; Load background image
    LD D, "m"
    LD E, "g"
    CALL fi.LoadBgImage
    CALL bm.CopyImageData

    ; ##########################################
    ; Setup joystick
    CALL mij.ResetJoystick

    LD DE, gc.LoadMainMenu
    LD (mij.callbackFire), DE

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      LoadMenuKeys                        ;
;----------------------------------------------------------;
LoadMenuKeys

    CALL _PreLoadMenu

    ; Load tiles with manual
    CALL fi.LoadMenuKeysTilemap

    ; Load palette
    LD HL, db.menuKeysBgPaletteAdr
    LD A, (db.menuKeysBgPaletteBytes)
    LD B, A
    CALL bp.LoadPalette

    ; Load background image
    LD D, "m"
    LD E, "k"
    CALL fi.LoadBgImage
    CALL bm.CopyImageData

    ; ##########################################
    ; Setup joystick
    CALL mij.ResetJoystick

    LD DE, gc.LoadMainMenu
    LD (mij.callbackFire), DE

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