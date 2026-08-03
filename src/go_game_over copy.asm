/*
  Copyright (c) 2027 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                      Game Over                           ;
;----------------------------------------------------------;
    MODULE go

; Minimum time to show the game over screen before the user can exit it.
GAME_OVER_CNT_D2        = 2
showDelay               DB 0

; Delays showing the game over image - the game is still active and plays the animation of the dying jetman.
GAME_OVER_DELAY         = 5
startDelay              DB 0

;----------------------------------------------------------;
;                       GameOverLoop                       ;
;----------------------------------------------------------;
GameOverLoop

    LD A, (startDelay)
    CP GAME_OVER_DELAY
    JR Z, .mainLoop

    INC A
    LD (startDelay), A
 
    RET

    ; The delay has been reached, turn it off and show the game over screen.
    XOR A
    LD (startDelay), A

    CALL _ShowGameOverNow
    RET

.mainLoop
    LD A, (showDelay)
    CP GAME_OVER_CNT_D2
    RET Z

    INC A
    LD (showDelay), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ShowGameOver                       ;
;----------------------------------------------------------;
ShowGameOver

    XOR A
    LD (startDelay), A

    LD A, ms.MS_GAME_OVER_D20
    CALL ms.SetMainState

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                    _ShowGameOverNow                      ;
;----------------------------------------------------------;
_ShowGameOverNow

    CALL gb.HideGameBar

    XOR A
    LD (showDelay),A

    CALL ar.LoadMenuTilemapSprites
    CALL ar.LoadTilemapMenuPalette

    ; Load palette
    LD D, "g"
    LD E, "o"
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
;                      _OnFirePressed                      ;
;----------------------------------------------------------;
_OnFirePressed

    ; Player should not be able to exit the game over screen too quickly, for example, when the auto fire is enabled.
    LD A, (showDelay)
    CP GAME_OVER_CNT_D2
    RET NZ

    CALL mms.EnterNewScore

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE