;----------------------------------------------------------;
;                           Tiles                          ;
;----------------------------------------------------------;
	MODULE ti

; Tiles should be stored between $4000 and $7FFF. This area is called Bank 5 (16K Banks), or slot 2-3 (8K slots). However, 
; ULA uses $4000-$6000. For this reason, we start loading tiles from $6000. Hardware expects tiles in Bank 5; therefore, we only have to 
; provide offsets starting from $4000.

; ULA screen and Tilemaps share 16KB Bank 5
; - $4000 - $5800 - ULA Bitmap Data
; - $5800 - $5B00 - ULA Colour Attribute Data
; - $5B00 - $6500 - Tilemap (42*32*2 = 2560 -> each tile takes 2 bytes: tile offset and palette offset)
; - $6500 - $7FFF - Tile Descriptions (32*215 = 6911, 215 tiles, each 32bytes, 8x8pixels, 4 bit palette)

START_OF_BANK_5		= $4000
START_OF_TILEMAP	= $5B00						; Tilemap just after ULA attributes (2560 bytes)
START_OF_TILES		= $6500						; Tiledefinitions (sprite file, max 6911 bytes)

; $5B00 - $4000 = $1B00 -> $1B00 >> 8 = $1B
OFFSET_OF_TILEMAP	= (START_OF_TILEMAP - START_OF_BANK_5) >> 8
	ASSERT OFFSET_OF_TILEMAP == $1B

; $6500 - $4000 = $2000 -> $2000 >> 8 = $20
OFFSET_OF_TILES		= (START_OF_TILES - START_OF_BANK_5) >> 8
	ASSERT OFFSET_OF_TILES == $25

CHAR_ASCII_OFFSET	= 34						; Tiles containing characters beginning with '!' - this is 33 in the ASCII table.
CHAR_PALETTE_BYTE	= 0							; Palette byte for tile characters
;----------------------------------------------------------;
;                        #PrintText                        ;
;----------------------------------------------------------;
; Print given text using tiles
; Input:
;  - DE:	Pointer to the text
;  - B:		Amount of characters in DE  
;  - C: 	Character offset from the top left corner. Each character takes 8 pixels, screen can contain 40x23 characters.
;           For B=5 -> First characters starts at 40px (5*8) in first line, for B=41 first charactes starts in second line.
PrintText

	LD HL, START_OF_TILEMAP						; HL points to screen memory containing tilemap 
	DEC HL
	
	; HL will point to the memory location containing the data of the first character (tile)
	PUSH DE
	LD D, 0
	LD E, C
	ADD HL, DE									; *2 because each tile has 2 bytes
	ADD HL, DE
	POP DE  

.loop
	LD A, (DE)									; Load current char
	INC DE										; Move to the next char 
	ADD A, -CHAR_ASCII_OFFSET					; Remove ASCII offset as tiles begin with 0

	LD (HL), CHAR_PALETTE_BYTE					; Set palette for tile
	INC HL
	LD (HL), A									; Set character for tile
	INC HL

	DJNZ .loop									; Loop untill B == 0

	RET
;----------------------------------------------------------;
;                         #LoadTiles                       ;
;----------------------------------------------------------;
LoadTiles

	; Enable tilemap mode
	NEXTREG _TILE_MAP_CONTROL_H6B, %10000001	; 40x32, 8-pixel tiles = 320x256
	NEXTREG _TILE_ATTRIBTE_H6C, %00000000		; palette offset, visuals

	; Tell harware where to find tiles
	; bits 5-0 = MSB of address of the tilemap in Bank 5
	NEXTREG _TILE_MAP_ADDRESR_H6E, OFFSET_OF_TILEMAP ; MSB of tilemap in bank 5
	NEXTREG _TILE_ADDRESR_H6F, OFFSET_OF_TILES	; MSB of tilemap definitions

	; Setup palette
	LD HL, di.tilePaletteBin					; Address of palette data in memory
	LD B, di.tilePaletteBinLength				; Number of colors to copy
	CALL sc.SetupTilemapPalette

	; Copy tile definitions to expected memory
	LD DE, START_OF_TILES
	LD HL, di.tilesBin							; Address of tiles in memory
	LD BC, di.tilesBinLength					; Number of bytes to copy
	LDIR	

	; Copy tilemap to expected memory
	LD DE, START_OF_TILEMAP
	LD HL, di.tilemapBin						; Addreess of tilemap in memory
	LD BC, di.tilemapBinLength	
	LDIR

	RET

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE