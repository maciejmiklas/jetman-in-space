;----------------------------------------------------------;
;                Binary Data Loader - Part 1               ;
;----------------------------------------------------------;
	module db

BGR_IMG_L1_SB18			= 18					; Background image occupies six 8K banks from 18 to 23 (starts on 16K bank 9)
BGR_IMG_L1_EB23			= 23					; Last background bank

BGR_IMG_PAL_B24			= 24					; Pallete for the background
BGR_IMG_PAL_16B9		= 9						; 16K bank 9 = 8k bank 18

SPRITE_B40				= 40					; Sprites on bank 40, 41
SPRITE_B41				= 41

TILES_B42				= 42
TILES_B43				= 43

STARTS_SB44				= 44
STARTS_EB45				= 45

BGR_IMG_L2_SB46			= 46					; Background image occupies six 8K banks from 46 to 51 (starts on 16K bank 9)
BGR_IMG_L2_EB52			= 51					; Last background bank

;----------------------------------------------------------;
;    #Load Game Background for Leve 1 (Bank 18...23)       ;
;----------------------------------------------------------;
; Load background into bank 18...23 (48K) mapping it to slot 7

	; Slot 7 = $E000..$FFFF, "n" option to auto-wrap into next page. The image file has 48KB (6 * 8KB), occupying 6 slots: 18 to 23. 
	; The "n" option will ensure each slot is within $E000..$FFFF range. Once one slot is full (at $FFFF) it will start writing to a new slot at $E000
	MMU _RAM_SLOT7 n, BGR_IMG_L1_SB18
	ORG _RAM_SLOT7_START_HE000

	; Following command was used to convert bmp (8bit indexed): "gfx2next -bitmap -pal-std -preview xxxx.bmp" (https://github.com/benbaker76/Gfx2Next)
	; I've used gimp to resize image to 256x192 and "Image -> Mode -> Indexed" to change palette to 8bit.
	INCBIN "assets/l001_background.nxi", 0, 256*192

	ASSERT $ == $E000 && $$ == BGR_IMG_L1_EB23 + 1	; Ensure that we loaded the whole image. MMU should be on the beginning of the next slot ("n" option)
	
	; After pre-loading the image pixel data, bank 24 should now automatically start at $E000
	; The background palette will be stored in bank 24
backGroundL1Palette
	INCBIN  "assets/l001_background.nxp", 0, 512

;----------------------------------------------------------;
;    #Load Game Background for Leve 2 (Bank 46...52)       ;
;----------------------------------------------------------;
; The same procedure as for Level 1 above
	MMU _RAM_SLOT7 n, BGR_IMG_L2_SB46
	ORG _RAM_SLOT7_START_HE000

	INCBIN "assets/l002_background.nxi", 0, 256*192

	ASSERT $ == $E000 && $$ == BGR_IMG_L2_EB52 + 1

backGroundL2Palette
	INCBIN  "assets/l002_background.nxp", 0, 512

;----------------------------------------------------------;
;            #Load Game Sprites (Bank 40...41)             ;
;----------------------------------------------------------;
; Load sprites (16KB) into bank 40,41 mapping it to slot 6,7

	MMU _RAM_SLOT6 _RAM_SLOT7, SPRITE_B40
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
spritesBin INCBIN "assets/l001_sprites.spr", 0, 16384
spritesBinLength = $ - spritesBin
	ASSERT $$ == SPRITE_B41

;----------------------------------------------------------;
;           #Load Game Tiles (Bank 42...43)                ;
;----------------------------------------------------------;
; Load tiles and pallete into bank 42 mapping it to slot 6
	
	MMU _RAM_SLOT6 _RAM_SLOT7, TILES_B42		; Assign slots 6,7 to banks 42,43
	ORG _RAM_SLOT6_START_HC000					; Set memmory pointer to start of the slot 6

; Tilemap settings: 8px, 40x32 (2 bytes pre pixel), disable "include header" when downloading, file is then usable as is.
tilemapBin INCBIN "assets/tiles.map"
tilemapBinLength = $ - tilemapBin
	ASSERT tilemapBinLength == _CF_TI_MAP_BYTES

; Sprite editor settings: 4bit, 8x8. After downloading manually removed empty data!
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
	ASSERT $$ <= TILES_B43 						; All data should fit into bank 43

;----------------------------------------------------------;
;               #Load Star Tiles  (Bank 44)                ;
;----------------------------------------------------------;

	MMU _RAM_SLOT6 _RAM_SLOT7, STARTS_SB44		; Assign slots 6,7 to banks 44,45
	ORG _RAM_SLOT6_START_HC000					; Set memmory pointer to start of the slot 6

starsBin INCBIN "assets/stars.map"
starsBinLength = $ - starsBin

	ASSERT starsBinLength == _CF_TIS_BYTES
	ASSERT $ > _RAM_SLOT6_START_HC000			; All data should fit into slot 6,7 
	ASSERT $ <= _RAM_SLOT7_END_HFFFF 			
	ASSERT $$ == STARTS_EB45 					; All data should fit into bank 43
;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE