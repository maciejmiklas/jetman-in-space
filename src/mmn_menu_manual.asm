/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                Menu Game Manual and Keys                 ;
;----------------------------------------------------------;
; Manual handles two menus: MENU_EL_KEYS (IN GAME KEYS) and MENU_EL_GAMEPLAY (GAMEPLAY)
    MODULE mmn

;----------------------------------------------------------;
;                     LoadMenuGameplay                     ;
;----------------------------------------------------------;
LoadMenuGameplay

    CALL _PreLoadMenu

    ; Load tiles with manual
    CALL ar.LoadMenuGameplayTilemapFile
    
    ; Load palette
    LD D, "m"
    LD E, "g"
    PUSH DE
    CALL ar.LoadBgPaletteFile
    CALL bp.LoadDefaultPalette
    POP DE

    ; Load background image
    CALL ar.LoadBgImageFile
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
    CALL ar.LoadMenuKeysTilemapFile

    ; Load palette
    LD D, "m"
    LD E, "k"
    PUSH DE
    CALL ar.LoadBgPaletteFile
    CALL bp.LoadDefaultPalette
    POP DE

    ; Load background image
    CALL ar.LoadBgImageFile
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

    LD A, ms.MS_MENU_MANUAL_D12
    CALL ms.SetMainState

    CALL js.HideJetSprite
    CALL ti.CleanAllTiles
    CALL bm.HideImage
    
    RET                                         ; ## END of the function ##
    
;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE