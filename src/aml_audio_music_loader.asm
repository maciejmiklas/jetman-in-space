/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                   Vortex Tracker II                      ;
;----------------------------------------------------------;
    MODULE aml
    ; TO USE THIS MODULE: CALL dbs.SetupMusicBank

; Counter for game music from assets\snd.
gameMusicCnt            DB GAME_MUSIC_MIN_D1
GAME_MUSIC_MIN_D1       = 1
GAME_MUSIC_MAX_D25      = 25

MUSIC_GAME_OVER_D80     = 80
MUSIC_MAIN_MENU_D81     = 81
MUSIC_HIGH_SCORE_D82    = 82
MUSIC_INTRO_D82         = 83

;----------------------------------------------------------;
;                       FlipOnOff                          ;
;----------------------------------------------------------;
FlipOnOff

    LD A, (am.musicState)
    CP am.MUSIC_ST_ON_D1
    JR Z, .isOn
    CALL MusicOn
    RET
.isOn
    CALL MusicOff
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                         MusicOn                          ;
;----------------------------------------------------------;
MusicOn

    LD A, am.MUSIC_ST_ON_D1
    LD (am.musicState), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                         MusicOff                         ;
;----------------------------------------------------------;
MusicOff

    CALL am.MuteMusic

    XOR A
    LD BC, _GL_REG_SOUND_HFFFD
    OUT (C), A

    LD A, am.MUSIC_ST_OFF_D0
    LD (am.musicState), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       LoadSong                           ;
;----------------------------------------------------------;
;  - A: song number from "assets/snd/xx.pt3", #GAME_MUSIC_MIN_D1 - #GAME_MUSIC_MAX_D25.
LoadSong

    PUSH AF
    CALL aml.MusicOff
    POP AF
    CALL fi.LoadMusicFile
    CALL am.InitMusic
    CALL aml.MusicOn

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       NextGameSong                       ;
;----------------------------------------------------------;
NextGameSong

    ; Increase music counter, or overflow to min value.
    LD A, (gameMusicCnt)
    CP GAME_MUSIC_MAX_D25
    JR NZ, .incMusicCnt
    
    LD A, GAME_MUSIC_MIN_D1
    JR .afterMusicCnt

.incMusicCnt
    INC A
.afterMusicCnt
    LD (gameMusicCnt), A

    CALL LoadSong

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE