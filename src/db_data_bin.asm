;----------------------------------------------------------;
;                    Binary Data Loader                    ;
;----------------------------------------------------------;
	module db

;----------------------------------------------------------;
;                            Temps                         ;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                Game Sprites (Bank 40...41)               ;
;----------------------------------------------------------;
; Load sprites (16KB) into bank 40,41 mapping it to slot 6,7.
	MMU _RAM_SLOT6 _RAM_SLOT7, _BN_SPRITE_BANK1_D40
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
;   - 45-47: Flying enemy 1
;   - 48-50: Flying enemy 2
spritesBin INCBIN "assets/sprites.spr", 0, _BN_SPRITE_BYT_D16384
spritesBinLength = $ - spritesBin
	ASSERT $$ == _BN_SPRITE_BANK2_D41
counter002FliFLop
;----------------------------------------------------------;
;               Game Tiles (Bank 42...43)                  ;
;----------------------------------------------------------;
; Load tiles and palette into 8K bank 42,42 mapping it to slot 6,7.
	
	MMU _RAM_SLOT6 _RAM_SLOT7, _BN_TILES_BANK1_D42 ; Assign slots 6,7 to banks 42,43.
	ORG _RAM_SLOT6_START_HC000					; Set memory pointer to start of the slot 6.

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
	ASSERT $$ <= _BN_TILES_BANK2_D43 			; All data should fit into bank 43.

;----------------------------------------------------------;
;                   Star Tiles (Bank 44)                  ;
;----------------------------------------------------------;
	MMU _RAM_SLOT6 _RAM_SLOT7, _BN_STARTS_BANK1_D44 ; Assign slots 6,7 to banks 44,45.
	ORG _RAM_SLOT6_START_HC000					; Set memory pointer to start of the slot 6.

starsBin INCBIN "assets/stars.map"
starsBinSize = $ - starsBin

	ASSERT starsBinSize == _TIS_BYTES_D10240
	ASSERT $ > _RAM_SLOT6_START_HC000			; All data should fit into slot 6,7.
	ASSERT $ <= _RAM_SLOT7_END_HFFFF 			
	ASSERT $$ == _BN_STARTS_BANK2_D45 			; All data should fit into bank 43.

;----------------------------------------------------------;
;                Layer 2 Palettes (Bank 46)                ;
;----------------------------------------------------------;
	MMU _RAM_SLOT6, _BN_PAL2_BANK_D46
	ORG _RAM_SLOT6_START_HC000

 ; #############################################
bgrL1PaletteAdr
	INCBIN  "assets/l01_background.nxp"

bgrL1PaletteBytes = $ - bgrL1PaletteAdr
	ASSERT bgrL1PaletteBytes <= _BM_PAL2_BYTES_D512

 ; #############################################
bgrL2PaletteAdr
	INCBIN  "assets/l02_background.nxp"

bgrL2PaletteBytes = $ - bgrL2PaletteAdr
	ASSERT bgrL2PaletteBytes <= _BM_PAL2_BYTES_D512

 ; #############################################
bgrL3PaletteAdr
	INCBIN  "assets/l03_background.nxp"

bgrL3PaletteBytes = $ - bgrL3PaletteAdr
	ASSERT bgrL3PaletteBytes <= _BM_PAL2_BYTES_D512

 ; #############################################
bgrL4PaletteAdr
	INCBIN  "assets/l04_background.nxp"

bgrL4PaletteBytes = $ - bgrL4PaletteAdr
	ASSERT bgrL4PaletteBytes <= _BM_PAL2_BYTES_D512

 ; #############################################
bgrL5PaletteAdr
	INCBIN  "assets/l05_background.nxp"

bgrL5PaletteBytes = $ - bgrL5PaletteAdr
	ASSERT bgrL5PaletteBytes <= _BM_PAL2_BYTES_D512

 ; #############################################
bgrL6PaletteAdr
	INCBIN  "assets/l06_background.nxp"

bgrL6PaletteBytes = $ - bgrL6PaletteAdr
	ASSERT bgrL6PaletteBytes <= _BM_PAL2_BYTES_D512
	
 ; #############################################
bgrL7PaletteAdr
	INCBIN  "assets/l07_background.nxp"

bgrL7PaletteBytes = $ - bgrL7PaletteAdr
	ASSERT bgrL7PaletteBytes <= _BM_PAL2_BYTES_D512

 ; #############################################
bgrL8PaletteAdr
	INCBIN  "assets/l08_background.nxp"

bgrL8PaletteBytes = $ - bgrL8PaletteAdr
	ASSERT bgrL8PaletteBytes <= _BM_PAL2_BYTES_D512

 ; #############################################
bgrL9PaletteAdr
	INCBIN  "assets/l09_background.nxp"

bgrL9PaletteBytes = $ - bgrL9PaletteAdr
	ASSERT bgrL9PaletteBytes <= _BM_PAL2_BYTES_D512

 ; #############################################
bgrL10PaletteAdr
	INCBIN  "assets/l10_background.nxp"

bgrL10PaletteBytes = $ - bgrL10PaletteAdr
	ASSERT bgrL10PaletteBytes <= _BM_PAL2_BYTES_D512
	
 ; #############################################
	ASSERT $$ == _BN_PAL2_BANK_D46	

;----------------------------------------------------------;
;          Layer 2 Brightness Palettes (Bank 47)           ;
;----------------------------------------------------------;
todL2Palettes									; Pallete will be generated during runtime.

;----------------------------------------------------------;
;        Game Background for Level 1 (Bank 48...57)        ;
;----------------------------------------------------------;
; The screen size is 320x256 (81920 bytes, 80KiB). Slot 7 has an address range of $E000..$FFFF. It can hold 8KiB and also fits into one bank.
; The "n" option will ensure that INCBIN loads the 80KiB into 10 banks, each with an address range of slot 7. It will load the first 8KiB 
; into the first bank. Once it has reached $FFFF, it will switch to the following bank, set the address to $E000,
; and load the next 8KiB chunk, repeating the whole process.
;
; BMP 320x256 with 8bit palette (Gimp -> Image -> Mode -> Indexed)
; ./gfx2next -bitmap -preview -bitmap-y -pal-min .\l01_background.bmp

	MMU _RAM_SLOT6 n, _BN_BG_L1_ST_BANK_D48
	ORG _RAM_SLOT6_START_HC000
bgrL1Img	
	INCBIN "assets/l01_background.nxi", 0, _BM_BYTES_D81920

	ASSERT $$bgrL1Img == _BN_BG_L1_ST_BANK_D48

	; MMU should be in the next slot because the last slot has been filed.
	ASSERT $$ == _BN_BG_L1_EN_BANK_D57+1		; Image has 81920 bytes, 10 banks.

;----------------------------------------------------------;
;         Game Background for Level 2 (Bank 58...67)       ;
;----------------------------------------------------------;
	MMU _RAM_SLOT6 n, _BN_BG_L2_ST_BANK_D58
	ORG _RAM_SLOT6_START_HC000
bgrL2Img	
	INCBIN "assets/l02_background.nxi", 0, _BM_BYTES_D81920

	ASSERT $$bgrL2Img == _BN_BG_L2_ST_BANK_D58  ; Make sure that we have configured the right bank.

	; MMU should be in the next slot because the last slot has been filed.
	ASSERT $$ == _BN_BG_L2_EN_BANK_D67+1		; Image has 81920 bytes, 10 banks

;----------------------------------------------------------;
;         Game Background for Level 3 (Bank 68...77)       ;
;----------------------------------------------------------;
	MMU _RAM_SLOT6 n, _BN_BG_L3_ST_BANK_D68
	ORG _RAM_SLOT6_START_HC000
bgrL3Img	
	INCBIN "assets/l03_background.nxi", 0, _BM_BYTES_D81920

	ASSERT $$bgrL3Img == _BN_BG_L3_ST_BANK_D68  ; Make sure that we have configured the right bank.

	; MMU should be in the next slot because the last slot has been filed.
	ASSERT $$ == _BN_BG_L3_EN_BANK_D77+1		; Image has 81920 bytes, 10 banks.

;----------------------------------------------------------;
;         Game Background for Level 4 (Bank 78...87)       ;
;----------------------------------------------------------;
	MMU _RAM_SLOT6 n, _BN_BG_L4_ST_BANK_D78
	ORG _RAM_SLOT6_START_HC000
bgrL4Img	
	INCBIN "assets/l04_background.nxi", 0, _BM_BYTES_D81920

	ASSERT $$bgrL4Img == _BN_BG_L4_ST_BANK_D78  ; Make sure that we have configured the right bank.

	; MMU should be in the next slot because the last slot has been filed.
	ASSERT $$ == _BN_BG_L4_EN_BANK_D87+1		; Image has 81920 bytes, 10 banks.

;----------------------------------------------------------;
;         Game Background for Level 5 (Bank 88...97)       ;
;----------------------------------------------------------;
	MMU _RAM_SLOT6 n, _BN_BG_L5_ST_BANK_D88
	ORG _RAM_SLOT6_START_HC000
bgrL5Img	
	INCBIN "assets/l05_background.nxi", 0, _BM_BYTES_D81920

	ASSERT $$bgrL5Img == _BN_BG_L5_ST_BANK_D88  ; Make sure that we have configured the right bank.

	; MMU should be in the next slot because the last slot has been filed.
	ASSERT $$ == _BN_BG_L5_EN_BANK_D97+1		; Image has 81920 bytes, 10 banks.	

;----------------------------------------------------------;
;        Game Background for Level 6 (Bank 98...107)       ;
;----------------------------------------------------------;
	MMU _RAM_SLOT6 n, _BN_BG_L6_ST_BANK_D98
	ORG _RAM_SLOT6_START_HC000
bgrL6Img	
	INCBIN "assets/l06_background.nxi", 0, _BM_BYTES_D81920

	ASSERT $$bgrL6Img == _BN_BG_L6_ST_BANK_D98  ; Make sure that we have configured the right bank.

	; MMU should be in the next slot because the last slot has been filed.
	ASSERT $$ == _BN_BG_L6_EN_BANK_D107+1		; Image has 81920 bytes, 10 banks.

;----------------------------------------------------------;
;       Game Background for Level 7 (Bank 108...117)       ;
;----------------------------------------------------------;
	MMU _RAM_SLOT6 n, _BN_BG_L7_ST_BANK_D108
	ORG _RAM_SLOT6_START_HC000
bgrL7Img	
	INCBIN "assets/l07_background.nxi", 0, _BM_BYTES_D81920

	ASSERT $$bgrL7Img == _BN_BG_L7_ST_BANK_D108  ; Make sure that we have configured the right bank.

	; MMU should be in the next slot because the last slot has been filed.
	ASSERT $$ == _BN_BG_L7_EN_BANK_D117+1		; Image has 81920 bytes, 10 banks.

;----------------------------------------------------------;
;       Game Background for Level 8 (Bank 118...127)       ;
;----------------------------------------------------------;
	MMU _RAM_SLOT6 n, _BN_BG_L8_ST_BANK_D118
	ORG _RAM_SLOT6_START_HC000
bgrL8Img	
	INCBIN "assets/l08_background.nxi", 0, _BM_BYTES_D81920

	ASSERT $$bgrL8Img == _BN_BG_L8_ST_BANK_D118  ; Make sure that we have configured the right bank.

	; MMU should be in the next slot because the last slot has been filed.
	ASSERT $$ == _BN_BG_L8_EN_BANK_D127+1		; Image has 81920 bytes, 10 banks.

;----------------------------------------------------------;
;       Game Background for Level 9 (Bank 128...137)       ;
;----------------------------------------------------------;
	MMU _RAM_SLOT6 n, _BN_BG_L9_ST_BANK_D128
	ORG _RAM_SLOT6_START_HC000
bgrL9Img	
	INCBIN "assets/l09_background.nxi", 0, _BM_BYTES_D81920

	ASSERT $$bgrL9Img == _BN_BG_L9_ST_BANK_D128  ; Make sure that we have configured the right bank.

	; MMU should be in the next slot because the last slot has been filed.
	ASSERT $$ == _BN_BG_L9_EN_BANK_D137+1		; Image has 81920 bytes, 10 banks.

;----------------------------------------------------------;
;      Game Background for Level 10 (Bank 138...147)       ;
;----------------------------------------------------------;
	MMU _RAM_SLOT6 n, _BN_BG_L10_ST_BANK_D138
	ORG _RAM_SLOT6_START_HC000
bgrL10Img	
	INCBIN "assets/l10_background.nxi", 0, _BM_BYTES_D81920

	ASSERT $$bgrL10Img == _BN_BG_L10_ST_BANK_D138  ; Make sure that we have configured the right bank.

	; MMU should be in the next slot because the last slot has been filed.
	ASSERT $$ == _BN_BG_L10_EN_BANK_D147+1		; Image has 81920 bytes, 10 banks.

;----------------------------------------------------------;
;        Star Data (Bank 148) - st_star_data.asm           ;
;----------------------------------------------------------;

;----------------------------------------------------------;
;        Enemy Data (Bank 149) - ed_enemy_data.asm         ;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE