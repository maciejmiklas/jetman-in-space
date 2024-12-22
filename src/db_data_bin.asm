;----------------------------------------------------------;
;                 Binary Data Loader                       ;
;----------------------------------------------------------;
	module db


;----------------------------------------------------------;
;            #Load Game Sprites (Bank 40...41)             ;
;----------------------------------------------------------;
; Load sprites (16KB) into bank 40,41 mapping it to slot 6,7
	MMU _RAM_SLOT6 _RAM_SLOT7, _CF_BIN_SPRITE_BANK1
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
spritesBin INCBIN "assets/l001_sprites.spr", 0, _CF_BIN_SPRITE_BYTES
spritesBinLength = $ - spritesBin
	ASSERT $$ == _CF_BIN_SPRITE_BANK2

;----------------------------------------------------------;
;           #Load Game Tiles (Bank 42...43)                ;
;----------------------------------------------------------;
; Load tiles and pallete into 8K bank 42,42 mapping it to slot 6,7
	
	MMU _RAM_SLOT6 _RAM_SLOT7, _CF_BIN_TILES_BANK1 ; Assign slots 6,7 to banks 42,43
	ORG _RAM_SLOT6_START_HC000					; Set memmory pointer to start of the slot 6

; Tilemap settings: 8px, 40x32 (2 bytes pre pixel), disable "include header" when downloading, file is then usable as is.
tilemapBin INCBIN "assets/tiles.map"
tilemapBinLength = $ - tilemapBin
	ASSERT tilemapBinLength == _CF_TI_MAP_BYTES

; Sprite editor settings: 4bit, 8x8. After downloading manually remove empty data!
tileDefBin INCBIN "assets/tiles.spr"
tileDefBinLength = $ - tileDefBin
	ASSERT tileDefBinLength <= _CF_TI_DEF_MAX

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
	
	ASSERT $ > _RAM_SLOT6_START_HC000			; All data should fit into slot 6,7
	ASSERT $ <= _RAM_SLOT7_END_HFFFF 			
	ASSERT $$ <= _CF_BIN_TILES_BANK2 			; All data should fit into bank 43

;----------------------------------------------------------;
;               #Load Star Tiles  (Bank 44)                ;
;----------------------------------------------------------;
	MMU _RAM_SLOT6 _RAM_SLOT7, _CF_BIN_STARTS_BANK1 ; Assign slots 6,7 to banks 44,45
	ORG _RAM_SLOT6_START_HC000					; Set memmory pointer to start of the slot 6

starsBin INCBIN "assets/stars.map"
starsBinLength = $ - starsBin

	ASSERT starsBinLength == _CF_TIS_BYTES
	ASSERT $ > _RAM_SLOT6_START_HC000			; All data should fit into slot 6,7 
	ASSERT $ <= _RAM_SLOT7_END_HFFFF 			
	ASSERT $$ == _CF_BIN_STARTS_BANK2 			; All data should fit into bank 43

;----------------------------------------------------------;
;   #Load Game Background for Level 1 (Bank 18...23)       ;
;----------------------------------------------------------;

	; Load background into bank 18...23 (48K) mapping it to slot 7
	MMU _RAM_SLOT7 n, _CF_BIN_BGR_ST_BANK
	ORG _RAM_SLOT7_START_HE000

	INCBIN "assets/l002_background.nxi", 0, 320*256

	ASSERT $ == $E000 && $$ == _CF_BIN_BGR_END_BANK + 1
	
/*
backGroundLXXPalette
	INCBIN  "assets/l002_background.nxp", 0, _CF_GBG_PAL_BYTES
*/

;----------------------------------------------------------;
;   #Load Game Background for Level 1 into bank 46...56    ;
;----------------------------------------------------------;
	; The screen size is 320x256. However, the image is larger due to the horizontal scroll. It has 320*(256+76)=106240 bytes (104KiB).
	; Slot 7 has an address range of $E000..$FFFF. It can hold 8KiB and also fits into one bank. The "n" option will ensure that INCBIN 
	; loads the whole 104KiB into 13 banks, each with an address range of slot 7. It will load the first 8KiB into the first bank. Once it has 
	; reached $FFFF, it will switch to the following bank, set the address to $E000, and load the next 8KiB chunk, repeating the whole process.
	MMU _RAM_SLOT6 n, _CF_BIN_BGR_L1_ST_BANK
	ORG _RAM_SLOT6_START_HC000
backGroundL1Img	
	INCBIN "assets/l001_background_down.nxi", 0, _CF_GBG_IMG_BYTES

	; MMU should be in the next slot because the last slot has been filed
	ASSERT $$ == _CF_BIN_BGR_L1_END_BANK+1		; Image has 106240 bytes, 13 baks can hold 106496
	ASSERT $$backGroundL1Img == _CF_BIN_BGR_L1_ST_BANK

;----------------------------------------------------------;
;     #Load Game Background Palettes into bank 33          ;
;----------------------------------------------------------;
	MMU _CF_BIN_BGR_PAL_SLOT, _CF_BIN_BGR_PAL_BANK
	ORG _CF_BIN_BGR_PAL_ADDR

backGroundL1Palette
	INCBIN  "assets/l002_background.nxp", 0, _CF_GBG_PAL_BYTES
	ASSERT $$ == _CF_BIN_BGR_PAL_BANK

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE