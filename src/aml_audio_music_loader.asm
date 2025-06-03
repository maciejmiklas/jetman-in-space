;----------------------------------------------------------;
;                   Vortex Tracker II                      ;
;----------------------------------------------------------;
    MODULE aml

    ; TO USE THIS MODULE: CALL dbs.SetupMusicBank

; Counter for game music from assets\snd
gameMusicCnt            DB GAME_MUSIC_MIN
GAME_MUSIC_MIN          = 5
GAME_MUSIC_MAX          = 27

MUSIC_GAME_OVER         = 80
MUSIC_MAIN_MENU         = 81
MUSIC_HIGH_SCORE        = 82
MUSIC_INTRO             = 83

;----------------------------------------------------------;
;                       FlipOnOff                          ;
;----------------------------------------------------------;
FlipOnOff

    LD A, (am.musicState)
    CP am.MUSIC_ST_ON
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

    LD A, am.MUSIC_ST_ON
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

    LD A, am.MUSIC_ST_OFF
    LD (am.musicState), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       LoadSong                           ;
;----------------------------------------------------------;
;  - A: song number from "assets/snd/xx.pt3", #GAME_MUSIC_MIN - #GAME_MUSIC_MAX
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

    ; Increase music counter, or overflow to min value
    LD A, (gameMusicCnt)
    CP GAME_MUSIC_MAX
    JR NZ, .incMusicCnt
    JR .afterMusicCnt
    LD A, GAME_MUSIC_MIN
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