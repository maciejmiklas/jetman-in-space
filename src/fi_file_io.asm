;----------------------------------------------------------;
;                         File IO                          ;
;----------------------------------------------------------;
    MODULE fi

fileHandle              DEFB 0
fileName                DB "0000000000000000000000000"
FILE_SIZE               = 25

; Open a file.
; Input:
;   - A:  Drive specifier ('*'=default, '$'=system) (overridden if filespec includes a drive)
;   - IX: [HL from dot command]=filespec, null-terminated
;   - B:  Access modes, a combination of:
;      any/all of:
;        - esx_mode_read $01 request read access
;        - esx_mode_write $02 request write access
;        - esx_mode_use_header $40 read/write +3DOS header
;      plus one of:
;        - esx_mode_open_exist $00 only open existing file
;        - esx_mode_open_creat $08 open existing or create file
;        - esx_mode_creat_noexist $04 create new file, error if exists
;        - esx_mode_creat_trunc $0c create new file, delete existing
;   - DE: 8-byte buffer with/for +3DOS header data (if specified in mode). NB: filetype will be set to $ff if headerless file was opened
; Output (success):
;   - Fc: 0
;   - A: File handle
; Output (failure):
;    - Fc: 0
;    - A : Error code
F_OPEN                  = $9A
F_OPEN_B_READ           = $01                   ; Access mode: read + exists

; Close a file or directory
; Input:
;   - A: File handle or directory handle
; Output (success):
;   - Fc: 0
;   - A:  0
; Output (failure):
;   - Fc: 1
;   - A:  Error code
F_CLOSE                 = $9B

; Read bytes from file
; NOTES:
; EOF is not an error, check BC to determine if all bytes requested were read
; Input:
;   - A:  File handle
;   - IX: [HL from dot command]=address
;   - BC  Bytes to read
; Output (success):
;   - Fc:  0
;   - BC:  Bytes actually read (also in DE)
;   - HL:  Address following bytes read
; Output (failure):
;   - Fc: 1
;   - BC: Bytes actually read
;   - A:  Error code
F_READ                  = $9D

F_CMD                   = $08
ASCII_O                 = $30

; Tiles for stars when rocket flaying
ST_FILE1_BYT_D8192      = _BANK_BYTES_D8192
ST_FILE2_BYT_D2048      = 2048
ST_BYTES_D10240         = ti.TI_MAP_BYTES_D2560*4   ; 10240=(40*32*2)*4 bytes, 4 screens. 40x128 tiles
    ASSERT ST_BYTES_D10240 =  10240
    ASSERT ST_FILE1_BYT_D8192+ST_FILE2_BYT_D2048 = ST_BYTES_D10240

;----------------------------------------------------------;
;                     LoadMusicFile                        ;
;----------------------------------------------------------;
; Input:
;  - A: song number from "assets/snd/xx.pt3"
LoadMusicFile

    CALL dbs.SetupArraysBank                    ; Setup slot 7 to load arrays

    CALL ut.NumTo99Str                          ; DE now contains ASCII of value from A

    LD HL, dba.sndFileName
    PUSH HL                                     ; Keep the address in HL to point to the beginning of the string (for _CopyFileName)
    LD IX, HL                                   ; Param for #_LoadImageToTempRam
    ADD HL, dba.SND_NR_POS                      ; Move HL to ""assets/snd/"

    LD (HL), D                                  ; Set first number
    INC HL
    LD (HL), E                                  ; Set second number
    POP HL

    CALL _CopyFileName
    CALL _FileOpen

    ; Read file
    CALL dbs.SetupMusicBank                     ; Setup slot 7 to load music binary
    LD IX, am.MUSIC_BIN_ADDR_HE000              ; Song bin takes whole bank
    LD BC, _BANK_BYTES_D8192                    ; Read always 8KiB, this will read a whole song and some garbage
    CALL _FileRead

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;               LoadLevelIntroImageFile                    ;
;----------------------------------------------------------;
; The screen size is 320x256 (81920 bytes, 80KiB)
; Input:
;  - DE: Level number as ASCII, for example for level 4: D="0", E="4"
LoadLevelIntroImageFile

    ; Set the level number in the file name, DE="35" will give: "assets/00/...." -> "assets/35/...".
    CALL dbs.SetupArraysBank

    LD HL, dba.liBgFileName
    PUSH HL                                     ; Keep the address in HL to point to the beginning of the string (for _CopyFileName)
    LD IX, HL                                   ; Param for #_LoadImageToTempRam
    ADD HL, dba.LI_BG_FILE_LEVEL_POS            ; Move HL to "assets/"
    LD (HL), D                                  ; Set first number
    INC HL
    LD (HL), E                                  ; Set second number
    POP HL
    CALL _CopyFileName

    LD C, dba.LI_BG_FILE_IMG_POS
    CALL _LoadImageToTempRam

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     LoadBgImageFile                      ;
;----------------------------------------------------------;
; The screen size is 320x256 (81920 bytes, 80KiB).
; Input:
;  - DE: Level number as ASCII, for example for level 4: D="0", E="4"
LoadBgImageFile

    ; Set the level number in the file name, DE="35" will give: "assets/00/...." -> "assets/35/....".
    CALL dbs.SetupArraysBank

    LD HL, dba.lbFileName
    PUSH HL
    LD IX, HL                                   ; Param for #_LoadImageToTempRam
    ADD HL, dba.LB_FILE_LEVEL_POS               ; Move HL to "assets/"
    LD (HL), D                                  ; Set first number.
    INC HL
    LD (HL), E                                  ; Set second number
    POP HL
    
    CALL _CopyFileName

    LD C, dba.LB_FILE_IMG_POS
    CALL _LoadImageToTempRam

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;               LoadPlatformsTilemapFile                   ;
;----------------------------------------------------------;
; Input:
;  - DE: Level number as ASCII, for example for level 4: D="0", E="4"
LoadPlatformsTilemapFile

    ; Set the level number in the file name, DE="35" will give: "assets/00/tiles.map" -> "assets/35/tiles.map".
    CALL dbs.SetupArraysBank

    LD HL, dba.plTileFileName
    PUSH HL
    LD IX, HL                                   ; Param for _FileOpen
    ADD HL, dba.PL_FILE_LEVEL_POS               ; Move HL to "assets/"
    LD (HL), D                                  ; Set first number
    INC HL
    LD (HL), E                                  ; Set second number
    POP HL

    CALL _CopyFileName
    CALL _FileOpen

    ; Read file
    LD IX, ti.TI_MAP_RAM_H5B00
    LD BC, ti.TI_MAP_BYTES_D2560
    CALL _FileRead

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    LoadSpritesFile                       ;
;----------------------------------------------------------;
; Input:
;  - DE: Level number as ASCII, for example for level 4: D="0", E="4"
LoadSpritesFile

    CALL dbs.SetupArraysBank

    ; Load first file
    PUSH DE
    LD HL, dba.sprTileFileName
    CALL _CopyFileName

    CALL dbs.SetupSpritesBank

    LD A, "0"
    CALL _PrepareFileOpenForSprites
    CALL _FileOpen

    ; Read file.
    LD IX, sp.SP_ADDR_HC000
    LD BC, dba.SPR_FILE_BYT_D8192
    CALL _FileRead
    POP DE
    
    ; ##########################################
    ; Load second file

    LD A, "1"
    CALL _PrepareFileOpenForSprites
    CALL _FileOpen

    ; Read file
    LD IX, _RAM_SLOT7_STA_HE000
    LD BC, dba.SPR_FILE_BYT_D8192
    CALL _FileRead

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;              LoadRocketStarsTilemapFile                  ;
;----------------------------------------------------------;
; Input:
;  - DE: Level number as ASCII, for example for level 4: D="0", E="4"
LoadRocketStarsTilemapFile

    CALL dbs.SetupArraysBank

    LD HL, dba.stTilesFileName
    CALL _CopyFileName

    LD BC, ST_FILE2_BYT_D2048
    CALL _Load16KTilemap

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;               LoadLevelIntroTilemapFile                  ;
;----------------------------------------------------------;
; Input:
;  - DE: Level number as ASCII, for example for level 4: D="0", E="4"
LoadLevelIntroTilemapFile

    CALL dbs.SetupArraysBank

    LD HL, dba.introTilesFileName
    CALL _CopyFileName

    LD BC, (dba.introSecondFileSize)
    CALL _Load16KTilemap

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;              LoadMenuGameplayTilemapFile                 ;
;----------------------------------------------------------;
LoadMenuGameplayTilemapFile

    CALL dbs.SetupArraysBank

    LD HL, dba.mmgTileFileName
    CALL _CopyFileName

    ; Open file
    CALL _FileOpen

    ; Read file
    LD IX, ti.TI_MAP_RAM_H5B00
    LD BC, ti.TI_MAP_BYTES_D2560
    CALL _FileRead

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 LoadMenuKeysTilemapFile                  ;
;----------------------------------------------------------;
LoadMenuKeysTilemapFile

    ; Open file
    CALL dbs.SetupArraysBank

    LD HL, dba.mmkTileFileName
    CALL _CopyFileName

    CALL _FileOpen

    ; Read file
    LD IX, ti.TI_MAP_RAM_H5B00
    LD BC, ti.TI_MAP_BYTES_D2560
    CALL _FileRead

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  LoadMenuEasyImageFile                   ;
;----------------------------------------------------------;
LoadMenuEasyImageFile

    CALL dbs.SetupArraysBank

    LD HL, dba.menuEasyBgFileName
    CALL _CopyFileName

    LD C, dba.MENU_EASY_BG_POS
    CALL _LoadImageToTempRam

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 LoadMenuHardImageFile                    ;
;----------------------------------------------------------;
LoadMenuHardImageFile

    CALL dbs.SetupArraysBank

    LD HL, dba.menuHardBgFileName
    CALL _CopyFileName

    LD C, dba.MENU_HARD_BG_POS
    CALL _LoadImageToTempRam

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                      _CopyFileName                       ;
;----------------------------------------------------------;
; Input:
;  - HL: Pointer to file name
_CopyFileName

    PUSH BC, DE

    LD BC, FILE_SIZE
    LD DE, fileName
    LDIR

    POP DE, BC

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   _LoadImageToTempRam                    ;
;----------------------------------------------------------;
; BMP 320x256 with 8bit palette (Gimp -> Image -> Mode -> Indexed)
; ./gfx2next -bitmap -preview -bitmap-y -pal-min .\bg.bmp
; if palette is broken try this:
; ./gfx2next -bitmap -preview -bitmap-y  -pal-std .\bg.bmp

; This function loads the image into temp RAM, in order to show it call #bm.CopyImageData
; Input:
;  - C:  Position of a image part number (0-9) in the file name of the background image
_LoadImageToTempRam

    ; Iterate over banks, loading one after another, form 0 to 9 inclusive.
    LD B, 0
.bankLoop
    PUSH BC

    ; ##########################################
    ; Set the image part in the file name, for B=3  "...bg_0.nxi" -> "...bg_3.nxi"
    LD HL, fileName
    LD A, C
    ADD HL, A                                   ; Move HL to "...00/bg_"
    LD A, ASCII_O                               ; Map B to ASCII value 0 to 9
    ADD B
    LD (HL), A

    ; ##########################################
    ; Load file into RAM

    ; Set bank number for slot 6, we will read file into it
    LD A, dbs.BMA_ST_BANK_S6_D73
    ADD B
    NEXTREG _MMU_REG_SLOT6_H56, A

    ; Open file
    CALL _FileOpen

    ; Read file
    LD IX, _RAM_SLOT6_STA_HC000
    LD BC, _BANK_BYTES_D8192
    CALL _FileRead

    ; ##########################################
    ; Loop up to B == 9
    POP BC
    INC B
    LD A, B
    CP dbs.BM_BANKS_D10
    JR NZ, .bankLoop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   _Load16KTilemap                        ;
;----------------------------------------------------------;
; Input:
;  - DE: Level number as ASCII, for example for level 4: D="0", E="4"
;  - BC: Size in bytes of second tilemap 8K file
_Load16KTilemap

    CALL dbs.Setup16KTilemapBank

    ; ##########################################
    ; Load first file
    PUSH DE, IX, BC

    ; Read file.
    LD A, "0"
    CALL _Prepare16KTilemapFile
    CALL _FileOpen
    
    LD IX, _RAM_SLOT6_STA_HC000
    LD BC, ST_FILE1_BYT_D8192
    CALL _FileRead

    POP BC, IX, DE

    ; ##########################################
    ; Load second file
    PUSH BC

    ; Should we load second file?
    LD A, B
    CP 0
    JR NZ, .loadSecond

    LD A, C
    CP 0
    JR NZ, .loadSecond
    
    POP BC
    RET                                         ; B and C are 0, do not load second file

.loadSecond
    ; Read file.
    LD A, "1"
    CALL _Prepare16KTilemapFile
    CALL _FileOpen

    LD IX, _RAM_SLOT7_STA_HE000
    POP BC
    CALL _FileRead

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 _Prepare16KTilemapFile                   ;
;----------------------------------------------------------;
; Input:
;  - A: Stars file number 0 for stars0.map, and 1 for stars1.map
;  - DE: Level number as ASCII, for example for level 4: D="0", E="4"
; Output:
;  - #stTilesFileName with correct name
_Prepare16KTilemapFile

    LD IX, fileName

    ; Set the level number in the file name, DE="35" will give: "assets/00/stars_0.map" -> "assets/35/stars_0.map"
    LD HL, IX
    ADD HL, dba.TI16K_FILE_LEVEL_POS            ; Move HL to "assets/0"
    LD (HL), D                                  ; Set first number
    INC HL
    LD (HL), E                                  ; Set second number

    ADD HL, dba.TI16K_FILE_NR_POS               ; Move HL to "assets/35/stars_"
    LD (HL), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;               _PrepareFileOpenForSprites                 ;
;----------------------------------------------------------;
; Input:
;  - A: Sprites file number 0 for sprites0.spr, and 1 for sprites1.spr
;  - DE: Level number as ASCII, for example for level 4: D="0", E="4"
; Output:
;  - #fileName with correct name
_PrepareFileOpenForSprites

    ; Set the level number in the file name, DE="35" will give: "assets/00/sprites_0.map" -> "assets/35/sprites_0.map"
    LD HL, fileName
    LD IX, HL                                   ; Param for _FileOpen
    ADD HL, dba.SPR_FILE_LEVEL_POS              ; Move HL to "assets/"
    LD (HL), D                                  ; Set first number
    INC HL
    LD (HL), E                                  ; Set second number

    ADD HL, dba.SPR_FILE_NR_POS                 ; Move HL to "assets/35/sprites_"
    LD (HL), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       _FileRead                          ;
;----------------------------------------------------------;
; Read bytes from a file.
; Input:
;  - IX: Address to load into
;  - BC: Number of bytes to read
_FileRead

    LD A, (fileHandle)
    RST F_CMD: DB F_READ
    CALL C, _IOError                            ; Handle errors
    CALL _FileClose

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                         _FileOpen                        ;
;----------------------------------------------------------;
_FileOpen

    ; Set params for F_OPEN
    LD IX, fileName
    LD A, '*'                                   ; Read from default drive
    LD B, F_OPEN_B_READ                         ; Open file
    RST F_CMD: DB F_OPEN                        ; Execute command
    CALL C, _IOError                            ; Handle errors

    LD (fileHandle), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        _FileClose                        ;
;----------------------------------------------------------;
_FileClose
    LD A, (fileHandle)
    RST F_CMD: DB F_CLOSE

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                         _IOError                         ;
;----------------------------------------------------------;
_IOError
    LD A, er.ERR_002
    CALL er.ReportError

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE