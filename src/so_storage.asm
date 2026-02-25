
/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                Persistant Game Storage                   ;
;----------------------------------------------------------;
    module so
   ; TO USE THIS MODULE: CALL dbs.SetupCode1Bank

storageStart
unlockedLevel           DB 10,10,10             ; There are three difficulty levels, unlocked independently.
UNLOCK_SIZE             = $ - unlockedLevel

; User can enter 10 character, but we display 13: [3xSPACE][10 characters for user name]
highScore                                       ; This score does not show on screen, it's only there for the sorting ;)

; Easy
highScoreEasy
    DW $FFFF
    DW $FFFF
    DB "   FREDUS    "
   
    DW 00000
    DW 09000
    DB "   MACIEJ    "

    DW 00000
    DW 08000
    DB "   ARTUR     "

    DW 00000
    DW 07000
    DB "   MARCIN    "

    DW 00000
    DW 06000
    DB "   MACIEJ    "

    DW 00000
    DW 05000
    DB "   JUREK     "

    DW 00000
    DW 04000
    DB "   FRANEK    "

    DW 00000
    DW 03000
    DB "   ZUZA      "

    DW 00000
    DW 02000
    DB "   KAROL     "

    DW 00000
    DW 01000
    DB "   FRED      "
HIGHSCORE_EASY          = $ - highScoreEasy

; Normal
highScoreNormal
    DW $FFFF
    DW $FFFF
    DB "   FREDUS    "
   
    DW 00000
    DW 09000
    DB "   MACIEJ    "

    DW 00000
    DW 08000
    DB "   ARTUR     "

    DW 00000
    DW 07000
    DB "   MARCIN    "

    DW 00000
    DW 06000
    DB "   MACIEJ    "

    DW 00000
    DW 05000
    DB "   JUREK     "

    DW 00000
    DW 04000
    DB "   FRANEK    "

    DW 00000
    DW 03000
    DB "   ZUZA      "

    DW 00000
    DW 02000
    DB "   KAROL     "

    DW 00000
    DW 01000
    DB "   FRED      "
HIGHSCORE_NORMAL          = $ - highScoreNormal

; Hard
highScoreHard
    DW $FFFF
    DW $FFFF
    DB "   FREDUS    "
   
    DW 00000
    DW 09000
    DB "   MACIEJ    "

    DW 00000
    DW 08000
    DB "   ARTUR     "

    DW 00000
    DW 07000
    DB "   MARCIN    "

    DW 00000
    DW 06000
    DB "   MACIEJ    "

    DW 00000
    DW 05000
    DB "   JUREK     "

    DW 00000
    DW 04000
    DB "   FRANEK    "

    DW 00000
    DW 03000
    DB "   ZUZA      "

    DW 00000
    DW 02000
    DB "   KAROL     "

    DW 00000
    DW 01000
    DB "   FRED      "
HIGHSCORE_HARD          = $ - highScoreHard

checksumUnlock          DB 0
checksumEasy            DB 0
checksumNormal          DB 0
checksumHard            DB 0
checksumVerify          DW 0

STORAGE_BYTES           = $ - storageStart

fileName                DB "game.sav",0

;----------------------------------------------------------;
;----------------------------------------------------------;
;                        MACROS                            ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                       _AddChecksum                       ;
;----------------------------------------------------------;
    MACRO _AddChecksum sum

    LD A, (sum)
    ADD DE, A

    OR E
    ADD DE, A

    OR D
    ADD DE, A

.end
    ENDM

;----------------------------------------------------------;
;               _CalculateChecksumVerify                   ;
;----------------------------------------------------------;
    MACRO _CalculateChecksumVerify

    _RES_DE

    _AddChecksum checksumUnlock
    _AddChecksum checksumEasy
    _AddChecksum checksumNormal
    _AddChecksum checksumHard

    LD (checksumVerify), DE

    ENDM

;----------------------------------------------------------;
;                  _CalculateChecksum                      ;
;----------------------------------------------------------;
    MACRO _CalculateChecksum data, dataSize, checksum

    LD B, dataSize
    LD IX, data
    _RES_HL

.loop
    LD A, (IX)
    LD D, A
    LD E, A

    LD A, B
    CP 2
    JR C, .continue
    LD A, (IX +1)
    LD E, A

.continue
    MUL D, E
    ADD HL, DE

    INC IX
    DJNZ .loop

    LD A, L
    LD (checksum), A

    ENDM

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PUBLIC FUNCTIONS                       ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                        WriteToSd                         ;
;----------------------------------------------------------;
WriteToSd

    _CalculateChecksum unlockedLevel, UNLOCK_SIZE, checksumUnlock
    _CalculateChecksum highScoreEasy, HIGHSCORE_EASY, checksumEasy
    _CalculateChecksum highScoreNormal, HIGHSCORE_NORMAL, checksumNormal
    _CalculateChecksum highScoreHard, HIGHSCORE_HARD, checksumHard

    _CalculateChecksumVerify
    
    ; Copy filename into buffer
    LD  HL, fileName
    CALL fi.CopyFileName

    ; Open for write (create if missing)
    CALL fi.FileOpenWrite

    ; Prepare data
    LD  IX, storageStart
    LD  BC, STORAGE_BYTES
    CALL fi.FileWrite

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE