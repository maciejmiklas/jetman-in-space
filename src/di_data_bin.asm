;----------------------------------------------------------;
;                Binary Data Loader - Part 1               ;
;----------------------------------------------------------;
	MODULE di

BGR_IMG_SB18			= 18					; Background image occupies 8K bank 18 to 23 (starts on 16K bank 9)
BGR_IMG_EB23			= 23					; Last background bank

BGR_IMG_PAL_B24			= 24					; Pallete for the background
BGR_IMG_PAL_16B9		= 9						; 16K bank 9 = 8k bank 18

SPRITE_B40				= 40					; Sprites on bank 40, 41
TILES_B42				= 42

;-------------------------------------------------------------------------------------;
;             Load tilemap into bank 42 mapping it to slot 6                          ;
;-------------------------------------------------------------------------------------;
	MMU _RAM_SLOT6, TILES_B42
	ORG _RAM_SLOT6_START_HC000

; Tilemap settings: 8px, 40x32 (2 bytes pre pixel), disable "include header" when downloading, file is then usable as is
tilemapBin INCBIN "assets/tiles.map"
tilemapBinLength = $ - tilemapBin
	ASSERT tilemapBinLength == 40*32*2

; Sprite editor settings: 4bit, 8x8. After downloading manually removed empty data!
tilesBin INCBIN "assets/tiles.spr"
tilesBinLength = $ - tilesBin

	; The tiles start at 6500 and must end at 7FFF because this is the end of 8K slot 3
	ASSERT tilesBinLength <= $7FFF - $6500	
/* 
  Values for Remy's editor (see also assets/tiles.txt):
  $1C7    $0    $5   $27   $2F   $6F   $B7  $13F   $10   $13   $15   $17   $18   $1B   $1D   $1F
  $1C7    $8   $40   $41   $40   $21   $2D   $2F   $1B   $1D   $35   $37   $3B   $18   $3D   $80
  $1C7   $80   $18   $41   $A8   $10   $40   $60    $0  $1C1   $80  $1C1  $1C1  $1C1  $1C1  $1C1
*/
tilePaletteBin									; RGB332, 8 bit
	DB $E3, $00, $02, $13, $17, $37, $5B, $9F, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F
	DB $E3, $04, $48, $20, $20, $10, $16, $17, $0D, $0E, $1A, $1B, $1D, $0C, $1E, $40
	DB $E3, $40, $0C, $20, $54, $08, $20, $30, $00, $E0, $40, $E0, $E0, $E0, $E0, $E0
tilePaletteBinLength = $ - tilePaletteBin
	
	ASSERT $$ == TILES_B42						; All data should fit into bank 42 (at least for now?)

;-------------------------------------------------------------------------------------;
;           Load sprites (16KB) into bank 40,41 mapping it to slot 6,7                ;
;-------------------------------------------------------------------------------------;
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
spritesBin INCBIN "assets/l001_sprites.spr",  0, 16384
spritesBinLength = $ - spritesBin
	ASSERT $$ == SPRITE_B40 + 1

;-------------------------------------------------------------------------------------;
;        Load background into bank 18...23 mapping it to slot 7                       ;
;-------------------------------------------------------------------------------------;
	; Slot 7 = $E000..$FFFF, "n" option to auto-wrap into next page. The image file has 48KB (6 * 8KB), occupying 6 slots: 18 to 23. 
	; The "n" option will ensure each slot is within $E000..$FFFF range. Once one slot is full (at $FFFF) it will start writing to a new slot at $E000
	MMU _RAM_SLOT7 n, BGR_IMG_SB18
	ORG _RAM_SLOT7_START_HE000

	; Following command was used to convert bmp (8bit indexed): "gfx2next -bitmap -pal-std -preview xxxx.bmp" (https://github.com/benbaker76/Gfx2Next)
	; I've used gimp to resize image to 256x192 and "Image -> Mode -> Indexed" to change palette to 8bit
	INCBIN "assets/l002_background.nxi", 0, 256*192

	ASSERT $ == $E000 && $$ == BGR_IMG_EB23 + 1	; Ensure that we loaded the whole image. MMU should be on the beginning of the next slot ("n" option)
	
	; After pre-loading the image pixel data, bank 24 should now automatically start at $E000
	; The background palette will be stored in bank 24
backGroundPalette
	INCBIN  "assets/l002_background.nxp", 0, 512
;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE