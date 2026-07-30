/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                      Demo Over                           ;
;----------------------------------------------------------;
    MODULE dr

DEMO_OVER_CNT_D2        = 2
fireCnt                 DB 0

    IFDEF DEMO_MODE
;----------------------------------------------------------;
;                       DemoOverLoop                       ;
;----------------------------------------------------------;
DemoOverLoop

    LD A, (fireCnt)
    CP DEMO_OVER_CNT_D2
    RET Z

    INC A
    LD (fireCnt), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ShowDemoOver                       ;
;----------------------------------------------------------;
ShowDemoOver

    CALL gb.HideGameBar

    XOR A
    LD (fireCnt),A

    LD A, ms.MS_GAME_OVER_D20
    CALL ms.SetMainState

    CALL ar.LoadMenuTilemapSprites
    CALL ar.LoadTilemapMenuPalette

    ; Load palette
    LD D, "d"
    LD E, "r"
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

    LD DE, _OnFirePressed
    LD (ki.callbackFire), DE

    ; ##########################################
    _LoadSong aml.MUSIC_GAME_OVER_D2

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
    CP DEMO_OVER_CNT_D2
    RET NZ

    CALL mma.SwitchToMainMenu

    RET                                         ; ## END of the function ##

    ENDIF 
;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE