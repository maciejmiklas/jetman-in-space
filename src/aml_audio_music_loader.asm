/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                   Vortex Tracker II                      ;
;----------------------------------------------------------;
    MODULE aml
    ; TO USE THIS MODULE: CALL dbs.SetupMusicCommonBank

; Counter for game music from assets\snd.
gameMusicCnt            DB 0

MUSIC_GAME_OVER_D80     = 10
MUSIC_MAIN_MENU_D81     = 3
MUSIC_HIGH_SCORE_D82    = 4
MUSIC_INTRO_D82         = 1

NEXT_MUSIC_SEC          = 180
nextMusicTimeCnt        DB NEXT_MUSIC_SEC

;----------------------------------------------------------;
;                    MusicTimerTick                        ;
;----------------------------------------------------------;
MusicTimerTick

    LD A, (am.musicState)
    CP am.MUSIC_ST_OFF_D0
    RET Z

    LD A, (nextMusicTimeCnt)
    CP 0
    JR Z, .resetCnt
    DEC A
    LD (nextMusicTimeCnt), A
    RET
.resetCnt
    CALL NextGameSong

    RET                                         ; ## END of the function ##

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
    CALL ar.LoadMusicFile
    CALL am.InitMusic
    CALL aml.MusicOn

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       NextGameSong                       ;
;----------------------------------------------------------;
NextGameSong

    CALL aml.MusicOff

    LD A, NEXT_MUSIC_SEC
    LD (nextMusicTimeCnt), A

    LD A, (gameMusicCnt)
    INC A
    LD (gameMusicCnt), A

    CALL dbs.NextInGameMusicBank
    CALL dbs.SetupInGameMusicBank
    CALL am.InitMusic
    CALL aml.MusicOn

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    PreloadIngameMusic                    ;
;----------------------------------------------------------;
PreloadIngameMusic
    CALL dbs.ResetInGameMusicBank

    ; Initialize the music counter to a random value if it hasn't already been set.
    LD A, (gameMusicCnt)
    CP 0
    JR NZ, .afterInitMusicCnt
    LD A, R
    LD (gameMusicCnt), A
.afterInitMusicCnt
    LD C, A

    ; ##########################################
    LD B, dbs.AY_MI_BANKS_40
.loop
    PUSH BC

    CALL dbs.NextInGameMusicBank
    LD B, A
    LD A, C
    CALL ar.LoadMusicBankFile

    POP BC

    ; Increment song numnber for #LoadMusicBankFile
    LD A, C
    INC A
    LD C, A
    DJNZ .loop

    CALL dbs.ResetInGameMusicBank

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE