/*
  Copyright (c) 2027 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                      Demo Over                           ;
;----------------------------------------------------------;
    MODULE dr


    IFDEF DEMO_MODE

;----------------------------------------------------------;
;                       ShowDemoOver                       ;
;----------------------------------------------------------;
ShowDemoOver

    CALL gb.HideGameBar

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

    ; ##########################################
    _LoadSong aml.MUSIC_GAME_OVER_D2

    RET                                         ; ## END of the function ##

    ENDIF 
;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE