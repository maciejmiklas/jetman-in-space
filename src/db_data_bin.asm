;----------------------------------------------------------;
;                 Binary Data Loader                       ;
;----------------------------------------------------------;
	module db


;----------------------------------------------------------;
;            #Load Game Sprites (Bank 40...41)             ;
;----------------------------------------------------------;
; Load sprites (16KB) into bank 40,41 mapping it to slot 6,7.
	MMU _RAM_SLOT6 _RAM_SLOT7, _BIN_SPRITE_BANK1_D40
	ORG _RAM_SLOT6_START_HC000

; Sprites:
;   - 00-02: top, breathe
;   - 03-05: top, no breathe
;   - 06-11: low, walk
;   - 12-17: low, fly
;   - 18-21: low, hover
;   - 22-25: low, walk -> fly
;   - 26-29: low, fly -> walk
;   - 30-33: low, walk -> fall
;   - 34-37: low, stand
;   - 38-41: explosion
;   - 42-44: fire	
;   - 45-47: Flying enemey 1
;   - 48-50: Flying enemey 2
spritesBin INCBIN "assets/l001_sprites.spr", 0, _BIN_SPRITE_BYT_D16384
spritesBinLength = $ - spritesBin
	ASSERT $$ == _BIN_SPRITE_BANK2_D41

;----------------------------------------------------------;
;           #Load Game Tiles (Bank 42...43)                ;
;----------------------------------------------------------;
; Load tiles and pallete into 8K bank 42,42 mapping it to slot 6,7.
	
	MMU _RAM_SLOT6 _RAM_SLOT7, _BIN_TILES_BANK1_D42 ; Assign slots 6,7 to banks 42,43.
	ORG _RAM_SLOT6_START_HC000					; Set memmory pointer to start of the slot 6.

; Tilemap settings: 8px, 40x32 (2 bytes pre pixel), disable "include header" when downloading, file is then usable as is.
tilemapBin INCBIN "assets/tiles.map"
tilemapBinLength = $ - tilemapBin
	ASSERT tilemapBinLength == _TI_MAP_BYTES_D2560

; Sprite editor settings: 4bit, 8x8. After downloading manually remove empty data!
tileDefBin INCBIN "assets/tiles.spr"
tileDefBinLength = $ - tileDefBin
	ASSERT tileDefBinLength <= TI_DEF_MAX_D6910

/*
  Values for Remy's editor (see also assets/tiles.txt):
  $1C7    $0    $5   $27   $2F   $6F   $B7  $13F   $10   $13   $15   $17   $18   $1B   $1D   $1F
  $1C7    $8   $40   $41   $40   $21   $2D   $2F   $1B   $1D   $35   $37   $3B   $18   $3D   $80
  $1C7   $80   $18   $41   $A8   $10   $40   $60    $0  $1C1   $80  $1C1  $1C1  $1C1  $1C1   $DF
*/
tilePaletteBin									; RGB332, 8 bit
	DB $E3, $0, $2, $13, $17, $37, $5B, $9F, $8, $9, $A, $B, $C, $D, $E, $F
	DB $E3, $4, $20, $20, $20, $10, $16, $17, $D, $E, $1A, $1B, $1D, $C, $1E, $40
	DB $E3, $40, $C, $20, $54, $8, $20, $30, $0, $E0, $40, $E0, $E0, $E0, $E0, $6F
tilePaletteBinLength = $ - tilePaletteBin
	
	ASSERT $ > _RAM_SLOT6_START_HC000			; All data should fit into slot 6,7.
	ASSERT $ <= _RAM_SLOT7_END_HFFFF 			
	ASSERT $$ <= _BIN_TILES_BANK2_D43 			; All data should fit into bank 43.

;----------------------------------------------------------;
;               #Load Star Tiles  (Bank 44)                ;
;----------------------------------------------------------;
	MMU _RAM_SLOT6 _RAM_SLOT7, _BIN_STARTS_BANK1_D44 ; Assign slots 6,7 to banks 44,45.
	ORG _RAM_SLOT6_START_HC000					; Set memmory pointer to start of the slot 6.

starsBin INCBIN "assets/stars.map"
starsBinLength = $ - starsBin

	ASSERT starsBinLength == _TIS_BYTES_D10240
	ASSERT $ > _RAM_SLOT6_START_HC000			; All data should fit into slot 6,7.
	ASSERT $ <= _RAM_SLOT7_END_HFFFF 			
	ASSERT $$ == _BIN_STARTS_BANK2_D45 			; All data should fit into bank 43.

;----------------------------------------------------------;
;     #Load Game Background Palettes into bank 46          ;
;----------------------------------------------------------;
	MMU _RAM_SLOT6, _BIN_BGR_PAL_BANK_D46
	ORG _RAM_SLOT6_START_HC000

backGroundL1Palette
	INCBIN  "assets/l001_background.nxp", 0, _BM_PAL_BYTES_D512

backGroundL2Palette
	INCBIN  "assets/l002_background.nxp", 0, _BM_PAL_BYTES_D512

	ASSERT $$ == _BIN_BGR_PAL_BANK_D46

;----------------------------------------------------------;
;   #Load Game Background for Level 1 into bank 47...56    ;
;----------------------------------------------------------;
; The screen size is 320x256 (81920 bytes, 80KiB). Slot 7 has an address range of $E000..$FFFF. It can hold 8KiB and also fits into one bank.
; The "n" option will ensure that INCBIN loads the 80KiB into 10 banks, each with an address range of slot 7. It will load the first 8KiB 
; into the first bank. Once it has reached $FFFF, it will switch to the following bank, set the address to $E000, 
; and load the next 8KiB chunk, repeating the whole process.
	MMU _RAM_SLOT6 n, _BIN_BGR_L1_ST_BANK_D47
	ORG _RAM_SLOT6_START_HC000
backGroundL1Img	
	INCBIN "assets/l001_background.nxi", 0, _BM_BYTES_D81920

	; MMU should be in the next slot because the last slot has been filed.
	ASSERT $$ == _BIN_BGR_L1_EN_BANK_D56+1		; Image has 32768 bytes, 4 banks.
	ASSERT $$backGroundL1Img == _BIN_BGR_L1_ST_BANK_D47

;----------------------------------------------------------;
;   #Load Game Background for Level 2 into bank 57...66    ;
;----------------------------------------------------------;
	MMU _RAM_SLOT6 n, _BIN_BGR_L2_ST_BANK_D57
	ORG _RAM_SLOT6_START_HC000
backGroundL2Img	
	INCBIN "assets/l002_background.nxi", 0, _BM_BYTES_D81920

	; MMU should be in the next slot because the last slot has been filed.
	ASSERT $$ == _BIN_BGR_L2_EN_BANK_D66+1		; Image has 32768 bytes, 4 banks.
	ASSERT $$backGroundL2Img == _BIN_BGR_L2_ST_BANK_D57

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE