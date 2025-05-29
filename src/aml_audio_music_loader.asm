;----------------------------------------------------------;
;                   Vortex Tracker II                      ;
;----------------------------------------------------------;
    MODULE aml

    ; TO USE THIS MODULE: CALL dbs.SetupMusicBank

; Counter for game music from assets\snd
gameMusicCnt            DB 12
GAME_MUSIC_MIN          = 1
GAME_MUSIC_MAX          = 29

MUSIC_GAME_OVER         = 80
MUSIC_MAIN_MENU         = 81
MUSIC_MAIN_SCORE        = 82

;----------------------------------------------------------;
;                       LoadSong                           ;
;----------------------------------------------------------;
;  - A: song number from "assets/snd/xx.pt3", #GAME_MUSIC_MIN - #GAME_MUSIC_MAX
LoadSong

    CALL fi.LoadMusic

    CALL am.InitMusic

    LD A, am.MUSIC_ST_ON
    CALL am.SetMusicState

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

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE