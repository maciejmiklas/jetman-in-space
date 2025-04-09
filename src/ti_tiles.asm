;----------------------------------------------------------;
;                           Tiles                          ;
;----------------------------------------------------------;
	MODULE ti


; Hardware expects tiles in Bank 5. Therefore, we only have to provide offsets starting from $4000.
TI_OFFSET	= (_TI_START_H5B00 - _RAM_SLOT2_START_H4000) >> 8

; Each tile sprite has 8x8 pixels = 64 and 32 bytes due to a 4-bit color. Sprites are combined into a 4x4 structure,
; each taking 4x32 bytes = 128bytes. We can assign to the whole tile sprites file 6910 bytes, 6910/128 = 53.
; The editor stores 4 sprites (4x4) in a single row. 53/4 = 13 rows. The editor can contain at most 4x13 large sprites.
;   6910                 =           $7FFF      -    $5B00     -     2560
TI_DEF_MAX_D6910		 = _RAM_SLOT3_END_H7FFF - _TI_START_H5B00 - _TI_MAP_BYTES_D2560

TI_CLIP_X1_D0			= 0
TI_CLIP_X2_D159			= 159
TI_CLIP_Y1_D0			= 0
TI_CLIP_FULLY2_D255		= _SC_RESY1_D255

TI_CLIP_TOP_D8			= _TI_PIXELS_D8
TI_CLIP_BOTTOM_D247		= _SC_RESY1_D255 - _TI_PIXELS_D8

TX_ASCII_OFFSET_D34		= 34					; Tiles containing characters beginning with '!' - this is 33 in the ASCII table.
TX_PALETTE_D0			= 0						; Palette byte for tile characters.


; Tilemap settings: 8px, 40x32 (2 bytes pre pixel), disable "include header" when downloading, file is then usable as is.
;
; Time map for single screen at 320x200 requires 2650 bytes:
; - 320 = 8*40 - 40 horizontal tiles,
; - 256 = 8*32 - 32 vertical tiles.
; Each tile occupies 2 bytes (tile offset and palette offset): 40*32*2 = 2560 bytes.
;
; Size of a single tile definition (tile sprite): 8x8 pixels, but each has 4 bit palate: 8*8/2 = 32 bytes.
;
; Memory organization:
; - $4000 - $5AFF - ULA,
; - $5B00 - $6500 - Tilemap, 2560 bytes,
; - $6501 - $7FFF - Tile definitions/sprites. We can store up to 215 sprites: $7FFF - $6501 = 6910. 6910/32 = 215.

; Tile definition (sprite file).
START_H6500	= _TI_START_H5B00 + _TI_MAP_BYTES_D2560 ; Tile definitions (sprite file).
	ASSERT START_H6500 >= _RAM_SLOT2_START_H4000
	ASSERT START_H6500 <= _RAM_SLOT3_END_H7FFF
	
; Hardware expects tiles in Bank 5. Therefore, we only have to provide offsets starting from $4000.
OFFSET	= (START_H6500 - _RAM_SLOT2_START_H4000) >> 8

gameFileName 		DB "assets/l00/tiles.map",0
FILE_LEVEL_POS		= 8							; Position of a level number (00-99) in the file name of the background image.

;----------------------------------------------------------;
;                   #LoadGameTilemap                       ;
;----------------------------------------------------------;
; Input:
;  - DE: Level number as ASCII, for example for level 4: D="0", E="4"
LoadGameTilemap

	; Set the level number in the file name, DE="35" will give: "assets/l00/tiles.map" -> "assets/l35/tiles.map"
	LD HL, gameFileName
	LD IX, HL									; Param for #LoadImage
	ADD HL, FILE_LEVEL_POS						; Move HL to "assets/l"
	LD (HL), D									; Set first number.
	INC HL
	LD (HL), E									; Set second number.

	CALL fi.LoadTilemap

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                     #ShakeTilemap                        ;
;----------------------------------------------------------;
ShakeTilemap

	LD A, (gld.counter002FliFLop)				; Oscillates between 1 and 0.
	LD D, A
	LD E, _SC_SHAKE_BY_D2
	MUL D, E
	LD A, E
	NEXTREG _DC_REG_TI_X_LSB_H30, A				; X tile offset.
	NEXTREG _DC_REG_TI_Y_H31, A					; Y tile offset.
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                 #ResetTilemapOffset                      ;
;----------------------------------------------------------;
ResetTilemapOffset

	XOR A
	NEXTREG _DC_REG_TI_X_LSB_H30, A				; X tile offset.roc
	NEXTREG _DC_REG_TI_Y_H31, A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                        #PrintText                        ;
;----------------------------------------------------------;
; Print given text using tiles.
; Input:
;  - DE:	Pointer to the text.
;  - B:		Amount of characters in DE.
;  - C: 	Character offset from the top left corner. Each character takes 8 pixels, screen can contain 40x23 characters.
;           For B=5 -> First characters starts at 40px (5*8) in first line, for B=41 first character starts in second line.
PrintText

	LD HL, _TI_START_H5B00						; HL points to screen memory containing tilemap.
	DEC HL										; TODO why (verify _TI_START_H5B00)?
	
	; HL will point to the memory location containing the data of the first character (tile).
	PUSH DE
	LD D, 0
	LD E, C
	ADD HL, DE									; *2 because each tile has 2 bytes.
	ADD HL, DE
	POP DE  

.loop
	LD A, (DE)									; Load current char.
	INC DE										; Move to the next char .
	ADD A, -TX_ASCII_OFFSET_D34				; Remove ASCII offset as tiles begin with 0.

	LD (HL), TX_PALETTE_D0						; Set palette for tile.
	INC HL
	LD (HL), A									; Set character for tile.
	INC HL

	DJNZ .loop									; Loop until B == 0

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       #CleanTiles                        ;
;----------------------------------------------------------;
;  - B:		Amount of tiles to clean 
CleanTiles
	LD HL, _TI_START_H5B00						; HL points to screen memory containing tilemap.
	DEC HL										; TODO why (verify _TI_START_H5B00)?

	; ##########################################
	LD A, _TI_EMPTY_D57
.loop
	
	LD (HL), TX_PALETTE_D0						; Set palette for tile.
	INC HL
	
	LD (HL), A									; Set tile gid.
	INC HL	

	DJNZ .loop									; Loop until B == 0.

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                        #SetupTiles                       ;
;----------------------------------------------------------;
SetupTiles

	CALL dbs.SetupTilesBank

	; ##########################################	
	; Enable tilemap mode.
	NEXTREG _TI_MAP_CONTROL_H6B, %10000001		; 40x32, 8-pixel tiles = 320x256.
	NEXTREG _TI_ATTRIBUTE_H6C, %00000000		; Palette offset, visuals.

	; ##########################################
	; Setup clip window to hide bottom tile row.
	CALL SetTilesClipFull

	; ##########################################
	; Tell hardware where to find tiles. Bits 5-0 = MSB of address of the tilemap in Bank 5.
	NEXTREG _TI_MAP_ADR_H6E, TI_OFFSET			; MSB of tilemap in bank 5.
	NEXTREG _TI_DEF_ADR_H6F, OFFSET		; MSB of tilemap definitions (sprites).

	; ##########################################
	; Setup palette
	LD HL, db.tilePaletteBin					; Address of palette data in memory.
	LD B, db.tilePaletteBinLength				; Number of colors to copy.
	CALL LoadTilemapPalette

	; ##########################################
	; Copy tile definitions to expected memory.
	LD DE, START_H6500
	LD HL, db.tileSprBin						; Address of tiles in memory.
	LD BC, db.tileSprBinLength					; Number of bytes to copy.
	LDIR

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #LoadTilemapPalette                     ;
;----------------------------------------------------------;
; Input:
; - B:		Number of colors to copy.
; - HL:		Address of layer 2 palette data .
LoadTilemapPalette

	; Black for tilemap transparency.
	NEXTREG _DC_REG_TI_TRANSP_H4C, _COL_BLACK_D0

	; Bits
	;  - 0: 1 = Enable ULANext mode,
	;  - 1-3: 0 = First palette,
	;  - 6-4: 011 = Tilemap first palette,
	;  - 7: 0 = enable auto increment on write.
	NEXTREG _DC_REG_LA2_PAL_CTR_H43, %0'011'000'1 
	NEXTREG _DC_REG_LA2_PAL_IDX_H40, 0			; Start with color index 0.

	; Copy 8 bit palette.
.loop
	LD A, (HL)									; Load RRRGGGBB into A.
	INC HL										; Increment to next entry.
	NEXTREG _DC_REG_LA2_PAL_VAL_H41, A			; Send entry to Next HW.
	DJNZ .loop									; Repeat until B=0.

	RET											; ## END of the function ##
	
;----------------------------------------------------------;
;                   #SetTilesClipFull                      ;
;----------------------------------------------------------;
SetTilesClipFull

	NEXTREG _C_TI_CLIP_WINDOW_H1B, TI_CLIP_X1_D0
	NEXTREG _C_TI_CLIP_WINDOW_H1B, TI_CLIP_X2_D159
	NEXTREG _C_TI_CLIP_WINDOW_H1B, TI_CLIP_Y1_D0
	NEXTREG _C_TI_CLIP_WINDOW_H1B, TI_CLIP_FULLY2_D255

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                 #SetTilesClipVertical                    ;
;----------------------------------------------------------;
; 8px clip from top and 8px clip from the bottom.
SetTilesClipVertical

	NEXTREG _C_TI_CLIP_WINDOW_H1B, TI_CLIP_X1_D0
	NEXTREG _C_TI_CLIP_WINDOW_H1B, TI_CLIP_X2_D159
	NEXTREG _C_TI_CLIP_WINDOW_H1B, TI_CLIP_TOP_D8
	NEXTREG _C_TI_CLIP_WINDOW_H1B, TI_CLIP_BOTTOM_D247

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE