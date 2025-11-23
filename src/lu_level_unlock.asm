;----------------------------------------------------------;
;                       Level Ulock                        ;
;----------------------------------------------------------;
    module lu

currentLevel            DB _LEVEL_MIN

;----------------------------------------------------------;
;                   LoadUnlockLevel                        ;
;----------------------------------------------------------;
; Output:
;  -A: Level number for current difficulty, 1-10.
LoadUnlockLevel

    ; The unlock level is stored for each difficulty, as 3 bytes in #unlockedLevel. #difLevel counts from 1 to 3, and we will use it to 
    ; calculate the offset to read the unlock level for the current difficulty.
    LD A, (jt.difLevel)
    DEC A                                       ; Diff level counts 1-3, for offset we need 0-2

    CALL dbs.SetupStorageBank
    LD DE, so.unlockedLevel
    ADD DE, A
    LD A, (DE)

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  ResetLevelPlaying                       ;
;----------------------------------------------------------;
ResetLevelPlaying

    LD A, _LEVEL_MIN
    LD (currentLevel), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   SetLevelPlaying                        ;
;----------------------------------------------------------;
; Input:
;  -A: Level number, 1-10
SetLevelPlaying

    LD (currentLevel), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   UnlockNextLevel                        ;
;----------------------------------------------------------;
UnlockNextLevel

    ; Increment current level, or eventually reset it (10 -> 1).
    LD A, (currentLevel)
    INC A
    LD (currentLevel), A

    ; Player has finished the last level, restart at  1, but do not store the unlock level.
    CP _LEVEL_MAX + 1
    JR Z, .resetCurrentLevel

    ; ##########################################
    ; Update the unlock level
    PUSH AF
    CALL dbs.SetupStorageBank

    ; Move DE to the #unlockedLevel for the current difficulty level.
    LD DE, so.unlockedLevel

    LD A, (jt.difLevel)
    DEC A
    ADD DE, A                                   ; DE points to the current value with unlocked level

    ; Update unlocked level only if the new value is > than the current one.
    LD A, (DE)
    LD B, A
    POP AF
    ; Now, A contains the current level that the player has just finished, and B holds the unlocked level. 
    ; We have to make sure that we do not overwrite the unlocked level with a lower value.
    CP B
    RET C
    LD (DE), A
    RET

.resetCurrentLevel
    LD A, _LEVEL_MIN
    LD (currentLevel), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE