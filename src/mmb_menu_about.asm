/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                      Menu About                          ;
;----------------------------------------------------------;
    MODULE mmb

;----------------------------------------------------------;
;                       LoadMenuAbout                      ;
;----------------------------------------------------------;
LoadMenuAbout

    CALL _PreLoadMenu

    ; Load palette
    LD D, "a"
    LD E, "b"
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

    LD DE, mma.SwitchToMainMenu
    LD (ki.callbackFire), DE

    ; ##########################################
    ; Music on
    dbs.SetupCodeMusicBank
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
    dbs.SetupCodeMusicBank
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