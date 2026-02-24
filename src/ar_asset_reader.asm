/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                     Asset Reader                         ;
;----------------------------------------------------------;
    MODULE ar

TI8K_FILE_BYT_D7680      = 7680                     ; 40*32*2*3 = 7680

; 16K tiles.
TI16_FILE1_BYT_D8192      = _BANK_BYTES_D8192
TI16_FILE2_BYT_D2048      = 2048
TI16_BYTES_D10240         = ti.TI_MAP_BYTES_D2560*4   ; 10240=(40*32*2)*4 bytes, 4 screens. 40x128 tiles.
    ASSERT TI16_BYTES_D10240 =  10240
    ASSERT TI16_FILE1_BYT_D8192+TI16_FILE2_BYT_D2048 = TI16_BYTES_D10240

ASCII_O                 = $30

;----------------------------------------------------------;
;               LoadLevelIntroImageFile                    ;
;----------------------------------------------------------;
; The screen size is 320x256 (81920 bytes, 80KiB).
; Input:
;  - DE: level number as ASCII, for example for level 4: D="0", E="4"
LoadLevelIntroImageFile

    CALL dbs.SetupArrays2Bank

    LD HL, db2.liBgFileName
    PUSH HL                                     ; Keep the address in HL to point to the beginning of the string (for fi.CopyFileName).
    CALL _SetFileLevelNumber
    POP HL
    CALL fi.CopyFileName

    LD C, db2.LI_BG_FILE_IMG_POS
    CALL _LoadImageToTempRam

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                LoadLevelSelectImageFile                  ;
;----------------------------------------------------------;
; Input:
;  - DE: level number as ASCII, for example for level 4: D="0", E="4"
LoadLevelSelectImageFile

    CALL dbs.SetupArrays2Bank

    ; Prepare file name for Level given by DE.
    LD HL, db2.levelSelectBgFileName
    CALL _SetupLevelIntroFileName
  

    ; Load the image.
    LD C, db2.LS_BG_IMG_POS
    CALL _LoadImageToTempRam

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                LoadLevelSelectPalFile                    ;
;----------------------------------------------------------;
; Input:
;  - DE: level number as ASCII, for example for level 4: D="0", E="4"
LoadLevelSelectPalFile

    CALL dbs.SetupArrays2Bank

    ; Prepare file name for Level given by DE.
    LD HL, db2.levelSelectPalFileName
    CALL _SetupLevelIntroFileName
    CALL fi.FileOpen

    ; Read file
    CALL dbs.SetupPaletteBank

    LD IX, bp.DEFAULT_PAL_ADDR
    LD BC, bp.PAL_BYTES_D512
    CALL fi.FileRead

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;               LoadMenuScoreImageFile                     ;
;----------------------------------------------------------;
; Input:
;  - DE: level number as ASCII, for example for level 4: D="0", E="2"
LoadMenuScoreImageFile

    CALL dbs.SetupArrays2Bank

    ; Prepare file name for Level given by DE.
    LD HL, db2.menuScoreBgFileName
    CALL _SetupMenuScoreFileName
  

    ; Load the image.
    LD C, db2.MS_BG_IMG_POS
    CALL _LoadImageToTempRam

    RET                                         ; ## END of the function ##


;----------------------------------------------------------;
;                   LoadMenuScorePalFile                   ;
;----------------------------------------------------------;
; Input:
;  - DE: difficulty number as ASCII, for example for level 4: D="0", E="1"
LoadMenuScorePalFile

    CALL dbs.SetupArrays2Bank

    ; Prepare file name for Level given by DE.
    LD HL, db2.menuScorePalFileName
    CALL _SetupMenuScoreFileName
    CALL fi.FileOpen

    ; Read file
    CALL dbs.SetupPaletteBank

    LD IX, bp.DEFAULT_PAL_ADDR
    LD BC, bp.PAL_BYTES_D512
    CALL fi.FileRead

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     LoadMusicFile                        ;
;----------------------------------------------------------;
; Input:
;  - A: song number from "assets/snd/xx.pt3".
LoadMusicFile

    CALL dbs.SetupArrays2Bank                    ; Setup slot 7 to load arrays.

    CALL ut.NumTo99Str                          ; DE now contains ASCII of value from A.

    LD HL, db2.sndFileName
    PUSH HL                                     ; Keep the address in HL to point to the beginning of the string (for fi.CopyFileName).
    LD IX, HL                                   ; Param for #_LoadImageToTempRam.
    ADD HL, db2.SND_NR_POS                      ; Move HL to ""assets/snd/".

    LD (HL), D                                  ; Set first number.
    INC HL
    LD (HL), E                                  ; Set second number.
    POP HL

    CALL fi.CopyFileName
    CALL fi.FileOpen

    ; Read file
    CALL dbs.SetupMusicBank                     ; Setup slot 7 to load music binary.
    LD IX, am.MUSIC_BIN_ADDR_HE000              ; Song bin takes whole bank.
    LD BC, _BANK_BYTES_D8192                    ; Read always 8KiB, this will read a whole song and some garbage.
    CALL fi.FileRead

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     LoadBgImageFile                      ;
;----------------------------------------------------------;
; The screen size is 320x256 (81920 bytes, 80KiB).
; Input:
;  - DE: level number as ASCII, for example for level 4: D="0", E="4".
LoadBgImageFile

    CALL dbs.SetupArrays2Bank

    LD HL, db2.lbFileName
    PUSH HL
    CALL _SetFileLevelNumber
    POP HL
    
    CALL fi.CopyFileName

    LD C, db2.LB_FILE_IMG_POS
    CALL _LoadImageToTempRam

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     LoadIntroPalFile                     ;
;----------------------------------------------------------;
LoadIntroPalFile

    LD HL, db2.introPalFileName
    CALL _LoadPalFileByName

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      LoadEasyPalFile                     ;
;----------------------------------------------------------;
LoadEasyPalFile

    LD HL, db2.easyPalFileName
    CALL _LoadPalFileByName

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     LoadHardPalFile                      ;
;----------------------------------------------------------;
LoadHardPalFile

    LD HL, db2.hardPalFileName
    CALL _LoadPalFileByName

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   LoadBgPaletteFile                      ;
;----------------------------------------------------------;
; Input:
;  - DE: level number as ASCII, for example for level 4: D="0", E="4"
LoadBgPaletteFile

    CALL dbs.SetupArrays2Bank

    LD HL, db2.lbpFileName
    PUSH HL
    CALL _SetFileLevelNumber
    POP HL

    CALL fi.CopyFileName
    CALL fi.FileOpen

    ; Read file
    CALL dbs.SetupPaletteBank

    LD IX, bp.DEFAULT_PAL_ADDR
    LD BC, bp.PAL_BYTES_D512
    CALL fi.FileRead

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;               LoadPlatformsTilemapFile                   ;
;----------------------------------------------------------;
; Input:
;  - DE: level number as ASCII, for example for level 4: D="0", E="4"
LoadPlatformsTilemapFile

    CALL dbs.SetupArrays2Bank

    LD HL, db2.plTileFileName
    PUSH HL
    CALL _SetFileLevelNumber
    POP HL
    CALL fi.CopyFileName

    CALL fi.FileOpen

    ; Read file
    LD IX, ti.TI_MAP_RAM_H5B00
    LD BC, ti.TI_MAP_BYTES_D2560
    CALL fi.FileRead

    RET                                         ; ## END of the function ##


;----------------------------------------------------------;
;                  LoadTileStarsSprFile                    ;
;----------------------------------------------------------;
; Input:
;  - DE: level number as ASCII, for example for level 4: D="0", E="4".
LoadTileStarsSprFile

    CALL dbs.SetupArrays2Bank

    LD HL, db2.strTileFileName
    PUSH DE
    CALL fi.CopyFileName
    POP DE

    LD HL, fi.fileNameBuf
    CALL _SetFileLevelNumber
    CALL fi.FileOpen

    LD IX, ti.TI_DEF_RAM_H6500
    LD BC, db2.SPR_TILE_BYT_D6400
    CALL fi.FileRead

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;               LoadTilePlatformsSprFile                   ;
;----------------------------------------------------------;
; Input:
;  - DE: level number as ASCII, for example for level 4: D="0", E="4".
LoadTilePlatformsSprFile

    CALL dbs.SetupArrays2Bank

    LD HL, db2.sprTileFileName
    PUSH DE
    CALL fi.CopyFileName
    POP DE

    LD HL, fi.fileNameBuf
    CALL _SetFileLevelNumber
    CALL fi.FileOpen

    LD IX, ti.TI_DEF_RAM_H6500
    LD BC, db2.SPR_TILE_BYT_D6400
    CALL fi.FileRead

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    LoadSpritesFile                       ;
;----------------------------------------------------------;
; Loads sprites_0.spr/sprites_1.spr 
; Input:
;  - DE: level number as ASCII, for example for level 4: D="0", E="4".
LoadSpritesFile

    LD HL, db2.sprFileName
    CALL _LoadSpritesFile

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    LoadMeteorsFile                       ;
;----------------------------------------------------------;
; Loadsasteroi_0.spr/asteroi_1.spr
; Input:
;  - DE: level number as ASCII, for example for level 4: D="0", E="4".
LoadMeteorsFile

    LD HL, db2.metFileName
    CALL _LoadSpritesFile

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;              LoadRocketStarsTilemapFile                  ;
;----------------------------------------------------------;
; Input:
;  - DE: level number as ASCII, for example for level 4: D="0", E="4".
LoadRocketStarsTilemapFile

    CALL dbs.SetupArrays2Bank

    LD HL, db2.stTilesFileName
    CALL fi.CopyFileName

    CALL _Load8KTilemap

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;               LoadLevelIntroTilemapFile                  ;
;----------------------------------------------------------;
; Input:
;  - DE: level number as ASCII, for example for level 4: D="0", E="4"
LoadLevelIntroTilemapFile

    CALL dbs.SetupArrays2Bank

    LD HL, db2.introTilesFileName
    CALL fi.CopyFileName

    LD BC, (db2.introSecondFileSize)
    CALL _Load16KTilemap

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;              LoadMenuGameplayTilemapFile                 ;
;----------------------------------------------------------;
LoadMenuGameplayTilemapFile

    CALL dbs.SetupArrays2Bank

    LD HL, db2.mmgTileFileName
    CALL fi.CopyFileName

    ; Open file
    CALL fi.FileOpen

    ; Read file
    LD IX, ti.TI_MAP_RAM_H5B00
    LD BC, ti.TI_MAP_BYTES_D2560
    CALL fi.FileRead

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 LoadMenuKeysTilemapFile                  ;
;----------------------------------------------------------;
LoadMenuKeysTilemapFile

    ; Open file
    CALL dbs.SetupArrays2Bank

    LD HL, db2.mmkTileFileName
    CALL fi.CopyFileName
    CALL fi.FileOpen

    ; Read file
    LD IX, ti.TI_MAP_RAM_H5B00
    LD BC, ti.TI_MAP_BYTES_D2560
    CALL fi.FileRead

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  LoadMenuEasyImageFile                   ;
;----------------------------------------------------------;
LoadMenuEasyImageFile

    CALL dbs.SetupArrays2Bank

    LD HL, db2.menuEasyBgFileName
    CALL fi.CopyFileName

    LD C, db2.MENU_EASY_BG_POS
    CALL _LoadImageToTempRam

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 LoadMenuHardImageFile                    ;
;----------------------------------------------------------;
LoadMenuHardImageFile

    CALL dbs.SetupArrays2Bank

    LD HL, db2.menuHardBgFileName
    CALL fi.CopyFileName

    LD C, db2.MENU_HARD_BG_POS
    CALL _LoadImageToTempRam

    RET                                         ; ## END of the function ##


;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                    _LoadSpritesFile                      ;
;----------------------------------------------------------;
; Loads sprites_0.spr/sprites_1.spr and asteroi_0.spr/asteroi_1.spr
; Input:
;  - DE: level number as ASCII, for example for level 4: D="0", E="4".
;  - HL: ponter to file name
_LoadSpritesFile

    CALL dbs.SetupArrays2Bank

    ; Load first file
    PUSH DE
    CALL fi.CopyFileName

    CALL dbs.SetupSpritesBank

    LD A, "0"
    CALL _PrepareFileOpenForSprites
    CALL fi.FileOpen

    ; Read file.
    LD IX, sp.SP_ADDR_HC000
    LD BC, db2.SPR_FILE_BYT_D8192
    CALL fi.FileRead
    POP DE

    ; ##########################################
    ; Load second file

    LD A, "1"
    CALL _PrepareFileOpenForSprites
    CALL fi.FileOpen

    ; Read file
    LD IX, _RAM_SLOT7_STA_HE000
    LD BC, db2.SPR_FILE_BYT_D8192
    CALL fi.FileRead

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  _SetFileLevelNumber                     ;
;----------------------------------------------------------;
; Set the level number in the file name, DE="35" will give: "assets/00/tiles.map" -> "assets/35/tiles.map".
; Input:
;  - DE: level number as ASCII, for example for level 4: D="0", E="4".
;  - HL: pointer to file starting with: "assets/XX".
; Return:
;  - HL: just after "assets/xx".
; Modifies: HL, IX
_SetFileLevelNumber

    LD IX, HL                                   ; Param for fi.FileOpen.
    ADD HL, db2.LEVEL_FILE_POS                  ; Move HL to "assets/".
    LD (HL), D                                  ; Set first number.
    INC HL
    LD (HL), E                                  ; Set second number.

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;               _SetupLevelIntroFileName                   ;
;----------------------------------------------------------;
; Input:
;  - DE: level number as ASCII, for example for level 4: D="0", E="4".
;  - HL: pointer to file name.
_SetupLevelIntroFileName

    PUSH HL                                     ; Keep the address in HL to point to the beginning of the string (for fi.CopyFileName).
    LD IX, HL
    ADD HL, db2.LS_BG_LEVEL_POS
    LD (HL), D
    INC HL
    LD (HL), E
    POP HL
    CALL fi.CopyFileName

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   _LoadImageToTempRam                    ;
;----------------------------------------------------------;
; BMP 320x256 with 8bit palette (Gimp -> Image -> Mode -> Indexed)
; ./gfx2next -bitmap -preview -bitmap-y -pal-min .\bg.bmp
; if palette is broken try this:
; ./gfx2next -bitmap -preview -bitmap-y  -pal-std .\bg.bmp

; This function loads the image into temp RAM, in order to show it call #bm.CopyImageData.
; Input:
;  - C:  position of a image part number (0-9) in the file name of the background image.
_LoadImageToTempRam

    ; Iterate over banks, loading one after another, form 0 to 9 inclusive.
    LD B, 0
.bankLoop
    PUSH BC

    ; ##########################################
    ; Set the image part in the file name, for B=3  "...bg_0.nxi" -> "...bg_3.nxi"
    LD HL, fi.fileNameBuf
    LD A, C
    ADD HL, A                                   ; Move HL to "...00/bg_".
    LD A, ASCII_O                               ; Map B to ASCII value 0 to 9.
    ADD B
    LD (HL), A

    ; ##########################################
    ; Load file into RAM.

    ; Set bank number for slot 6, we will read file into it.
    LD A, dbs.BMA_ST_BANK_S6_D73
    ADD B
    NEXTREG _MMU_REG_SLOT6_H56, A

    ; Open file
    CALL fi.FileOpen

    ; Read file
    LD IX, _RAM_SLOT6_STA_HC000
    LD BC, _BANK_BYTES_D8192
    CALL fi.FileRead

    ; ##########################################
    ; Loop up to B == 9.
    POP BC
    INC B
    LD A, B
    CP dbs.BM_BANKS_D10
    JR NZ, .bankLoop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                _SetupMenuScoreFileName                   ;
;----------------------------------------------------------;
; Input:
;  - DE: difficulty number as ASCII, for example for level 4: D="0", E="2".
;  - HL: pointer to file name.
_SetupMenuScoreFileName

    PUSH HL                                     ; Keep the address in HL to point to the beginning of the string (for fi.CopyFileName).
    LD IX, HL
    ADD HL, db2.MS_BG_LEVEL_POS
    LD (HL), D
    INC HL
    LD (HL), E
    POP HL
    CALL fi.CopyFileName

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  _LoadPalFileByName                      ;
;----------------------------------------------------------;
; Input:
;  - HL: pointer to file name.
_LoadPalFileByName

    CALL dbs.SetupArrays2Bank

    CALL fi.CopyFileName
    CALL fi.FileOpen

    ; Read file
    CALL dbs.SetupPaletteBank

    LD IX, bp.DEFAULT_PAL_ADDR
    LD BC, bp.PAL_BYTES_D512
    CALL fi.FileRead

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    _Load8KTilemap                        ;
;----------------------------------------------------------;
; Input:
;  - DE: level number as ASCII, for example for level 4: D="0", E="4".
_Load8KTilemap

    CALL dbs.Setup8KTilemapBank

    ; Read file.
    LD HL, fi.fileNameBuf
    CALL _SetFileLevelNumber
    CALL fi.FileOpen
    
    LD IX, _RAM_SLOT7_STA_HE000
    LD BC, TI8K_FILE_BYT_D7680
    CALL fi.FileRead

    RET                                         ; ## END of the function ##


;----------------------------------------------------------;
;                   _Load16KTilemap                        ;
;----------------------------------------------------------;
; Input:
;  - DE: level number as ASCII, for example for level 4: D="0", E="4".
;  - BC: size in bytes of second tilemap 8K file.
_Load16KTilemap

    CALL dbs.Setup16KTilemapBank

    ; ##########################################
    ; Load first file
    PUSH DE, IX, BC

    ; Read file.
    LD A, "0"
    CALL _Prepare16KTilemapFile
    CALL fi.FileOpen
    
    LD IX, _RAM_SLOT6_STA_HC000
    LD BC, TI16_FILE1_BYT_D8192
    CALL fi.FileRead

    POP BC, IX, DE

    ; ##########################################
    ; Load second file.
    PUSH BC

    ; Should we load second file?
    LD A, B
    OR A                                        ; Same as CP 0, but faster.
    JR NZ, .loadSecond

    LD A, C
    OR A                                        ; Same as CP 0, but faster.
    JR NZ, .loadSecond

    POP BC
    RET                                         ; B and C are 0, do not load second file.

.loadSecond
    ; Read file.
    LD A, "1"
    CALL _Prepare16KTilemapFile
    CALL fi.FileOpen

    LD IX, _RAM_SLOT7_STA_HE000
    POP BC
    CALL fi.FileRead

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 _Prepare16KTilemapFile                   ;
;----------------------------------------------------------;
; Input:
;  - A: stars file number 0 for stars0.map, and 1 for stars1.map.
;  - DE: level number as ASCII, for example for level 4: D="0", E="4".
; Return:
;  - #stTilesFileName with correct name.
_Prepare16KTilemapFile

    LD HL, fi.fileNameBuf

    CALL _SetFileLevelNumber

    ADD HL, db2.TI16K_FILE_NR_POS               ; Move HL to "assets/35/stars_".
    LD (HL), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;               _PrepareFileOpenForSprites                 ;
;----------------------------------------------------------;
; Input:
;  - A:  sprites file number 0 for sprites0.spr, and 1 for sprites1.spr.
;  - DE: level number as ASCII, for example for level 4: D="0", E="4".
; Return:
;  - #fileName with correct name.
_PrepareFileOpenForSprites

    LD HL, fi.fileNameBuf
    CALL _SetFileLevelNumber
    ADD HL, db2.SPR_FILE_NR_POS                 ; Move HL to "assets/35/sprites_".
    LD (HL), A

    RET                                         ; ## END of the function ##
;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE