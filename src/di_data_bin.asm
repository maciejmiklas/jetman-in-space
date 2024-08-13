;----------------------------------------------------------;
;                Binary Data Loader - Part 1               ;
;----------------------------------------------------------;
	MODULE di

BGR_IMG_SB18			= 18					; Background image occupies 8K bank 18 to 23 (starts on 16K bank 9)
BGR_IMG_EB23			= 23					; Last background bank
BGR_IMG_EB24			= 24					; Pallete for the background
BGR_IMG_16B9			= 9						; 16K bank 9 = 8k bank 18

SPRITE_B40				= 40					; Sprites on bank 40, 41
SPR_PALETTE_B42			= 42

;-------------------------------------------------------------------------------------;
;             Load tilemap into bank 42 mapping it to Slot: 6                         ;
;-------------------------------------------------------------------------------------;
	MMU _RAM_SLOT6, SPR_PALETTE_B42
	ORG _RAM_SLOT6_START_HC000

; Tilemap settings: 8px, 40x32 (2 bytes pre pixel), disable "include header" when downloading, file is then usable as is
tilemapBin INCBIN "assets/tiles.map"
tilemapBinLength = $ - tilemapBin

; Sprite editor settings: 4bit, 8x8. After downloading manually removed empty data!
tilesBin INCBIN "assets/tiles.spr"
tilesBinLength = $ - tilesBin


/* Values for Remy's editor
  $1C7    $0    $5   $27   $2F   $6F   $B7  $13F   $10   $13   $15   $17   $18   $1B   $1D   $1F
  $1C7   $43   $42   $41   $40   $25   $2D   $2F   $1B   $1D   $35   $37   $38   $3B   $3D   $3F
*/
tilePaletteBin									; RGB332
	DB $E3, $E0, $2, $13, $17, $37, $5B, $1F, $8, $9, $A, $B, $C, $D, $E, $F
	DB $E3, $21, $21, $20, $20, $12, $16, $17, $D, $E, $1A, $1B, $1C, $1D, $1E, $1F
tilePaletteBinLength = $ - tilePaletteBin

;-------------------------------------------------------------------------------------;
;           Load sprites (16KB) into bank 40,41 mapping it to Slot: 6,7               ;
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

;-------------------------------------------------------------------------------------;
;        Load background into bank 18...23 mapping it to slot 7                       ;
;-------------------------------------------------------------------------------------;
	; Slot 7 = $E000..$FFFF, "n" option to auto-wrap into next page. The image file has 48KB (6 * 8KB), occupying 6 slots: 18 to 23. 
	; The "n" option will ensure each slot is within $E000..$FFFF range. Once one slot is full (at $FFFF) it will start writing to a new slot at $E000
	MMU _RAM_SLOT7 n, BGR_IMG_SB18
	ORG _RAM_SLOT7_START_HE000

	; Following command was used to convert bmp (8bit indexed): "gfx2next -bitmap -pal-std -preview xxxx.bmp"
	; I've used gimp to resize image to 256x192 and "Image -> Mode -> Indexed" to change palette to 8bit	
	INCBIN "assets/l001_background.nxi", 0, 256*192

	ASSERT $ == $E000 && $$ == BGR_IMG_EB23 + 1	; Ensure that we loaded the whole image. MMU should be on the beginning of the next slot ("n" option)
	
	; After pre-loading the image pixel data, bank 24 should now automatically start at $E000
	; The background palette will be stored in bank 24
backGroundPalette
	INCBIN  "assets/l001_background.nxp", 0, 512
;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE