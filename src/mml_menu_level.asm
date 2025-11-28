/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                  Menu Level Select                       ;
;----------------------------------------------------------;
    MODULE mml

    STRUCT MLS                                  ; Menu Level Select
TILE_OFFSET             DW                      ; Tile offset.
JET_X                   DB                      ; X postion of Jetman pointing to active element.
JET_Y                   DB                      ; Y postion of Jetman pointing to active element.
    ENDS

currentLevel           DB _LEVEL_MIN

;----------------------------------------------------------;
;                   LoadMenuLevelSelect                    ;
;----------------------------------------------------------;
LoadMenuLevelSelect

    ; Music of
    CALL dbs.SetupMusicBank
    CALL aml.MusicOff

    LD A, ms.MENU_LEVEL
    CALL ms.SetMainState

    CALL js.HideJetSprite
    CALL ti.CleanAllTiles
    CALL bm.HideImage

    ; ##########################################
    LD A, _LEVEL_MIN
    LD (currentLevel), A
    
    ; ##########################################
    ; Load background palette
    CALL dbs.SetupStorageBank
    CALL lu.LoadUnlockLevel
    CALL ut.NumTo99Str                          ; Load A into DE as Text

    PUSH DE
    CALL fi.LoadLevelSelectPalFile
    CALL bp.LoadDefaultPalette
    POP DE
    
    ; Load image
    CALL fi.LoadLevelSelectImageFile
    CALL bm.CopyImageData

    ; ##########################################
    ; Setup joystick
    CALL ki.ResetKeyboard

    LD DE, _ConfirmSelection
    LD (ki.callbackFire), DE

    LD DE, _NextLevel
    LD (ki.callbackRight), DE
    LD (ki.callbackDown), DE

    LD DE, _PreviousLevel
    LD (ki.callbackLeft), DE
    LD (ki.callbackUp), DE

    ; ##########################################
    ; Setup Jetman sprite
    CALL jt.SetJetStateInactive

    ; Jetman is facing left
    XOR A
    SET gid.MOVE_LEFT_BIT, A
    LD (gid.jetDirection), A

    LD A, js.SDB_HOVER
    CALL js.ChangeJetSpritePattern

    CALL _UpdateJetPos
    CALL js.ShowJetSprite
    
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
;                    _ConfirmSelection                     ;
;----------------------------------------------------------;
_ConfirmSelection

    LD A, (currentLevel)
    LD (lu.currentLevel), A
    
    CALL gc.LoadMainMenu

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       _UpdateJetPos                      ;
;----------------------------------------------------------;
_UpdateJetPos

    ; Set IX to the position in #MLS that corresponds to the currently selected level.
    CALL dbs.SetupArrays2Bank

    LD A, (currentLevel)
    DEC A
    LD D, A
    LD E, MLS
    MUL D, E

    LD IX, db2.menuLevelEl
    ADD IX, DE                                  ; Now IX points to current #MLS

    ; ##########################################
    ; Set X Jet position.
    LD D, 0
    LD E, (IX + MLS.JET_X)
    LD (jpo.jetX), DE
 
    ; Set Y Jet position.
    LD A, (IX + MLS.JET_Y)
    LD (jpo.jetY), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                         _MoveJet                         ;
;----------------------------------------------------------;
_MoveJet

    LD A, js.SDB_T_KO
    CALL js.ChangeJetSpritePattern

    LD A, af.FX_MENU_MOVE
    CALL dbs.SetupAyFxsBank
    CALL af.AfxPlay

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     _NextLevel                           ;
;----------------------------------------------------------;
_NextLevel

    ; Increment #currentLevel by 1 up to #unlockedLevel.
    CALL lu.LoadUnlockLevel
    LD B, A
    
    LD A, (currentLevel)
    CP B
    RET Z

    INC A
    LD (currentLevel), A

    ; ##########################################
    CALL _UpdateJetPos
    CALL _MoveJet

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   _PreviousLevel                         ;
;----------------------------------------------------------;
_PreviousLevel

    ; Decrement #currentLevel by 1, min value is 1.
    LD A, (currentLevel)
    DEC A
    CP 0
    RET Z

    LD (currentLevel), A

    ; ##########################################
    CALL _UpdateJetPos
    CALL _MoveJet

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE