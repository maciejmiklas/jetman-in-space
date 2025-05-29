;----------------------------------------------------------;
;                   Vortex Tracker II                      ;
;----------------------------------------------------------;
    MODULE aml
    
; Counter for game music from assets\snd
gameMusicCnt            DB 12
GAME_MUSIC_MIN          = 1
GAME_MUSIC_MAX          = 29

;----------------------------------------------------------;
;                       NextGameSong                       ;
;----------------------------------------------------------;

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