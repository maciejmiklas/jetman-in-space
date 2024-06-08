;----------------------------------------------------------;
;                           Tiles                          ;
;----------------------------------------------------------;
	MODULE ti

; Tiles should be stored between $4000 and $7FFF. This area is called Bank 5 (16K Banks). However, ULA uses $4000-$6000. For this reason, 
; we start loading tiles from $6000. Hardware expects tiles in Bank 5; therefore, we only have to provide offsets starting from $4000.
START_OF_BANK_5		= $4000 

START_OF_TILEMAP	= $6000						; Just after ULA attributes
START_OF_TILES		= $6A00						; Just after tilemap -> 40x32x2 (2 bytes for tile)

; START_OF_TILEMAP - START_OF_BANK_5 = $2000  -> >> 8 =  $20 = 32
OFFSET_OF_MAP		= (START_OF_TILEMAP - START_OF_BANK_5) >> 8

; START_OF_TILES - START_OF_BANK_5 = $2600  -> >> 8 =  $26 = 38
OFFSET_OF_TILES		= (START_OF_TILES - START_OF_BANK_5) >> 8

CHAR_ASCII_OFFSET	= 34						; Tiles containing characters beginning with '!' - this is 33 in the ASCII table.
CHAR_PALETTE_BYTE	= 0							; Palette byte for tile characters
;----------------------------------------------------------;
;                        #PrintText                        ;
;----------------------------------------------------------;
; Print given text using tiles
; Method Parameters:
;  - IN: DE - pointer to the text
;       B - amount of characters in DE  
;       C - Character offset from the top left corner. Each character takes 8 pixels, screen can contain 40x23 characters. 
;           For B=5 -> First characters starts at 5x8 in first line, for B=41 first charactes starts in second line.         
PrintText
	LD HL, START_OF_TILEMAP						; HL points to screen memory containing tilemap 
	DEC HL
	
	; Move HL by 2*C so that HL points to the position of the first character
	PUSH DE
	LD D, 0
	LD E, C
	SLA E										; E*2 because each tile has 2 bytes
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
	NEXTREG $6B, %10000001						; 40x32, 16-bit entries = 320x256
	NEXTREG $6C, %00000000						; palette offset, visuals

	; Tell harware where to find tiles
	; bits 5-0 = MSB of address of the tilemap in Bank 5
	NEXTREG $6E, OFFSET_OF_MAP					; MSB of tilemap in bank 5
	NEXTREG $6F, OFFSET_OF_TILES				; MSB of tilemap definitions

	; Setup tilemap palette
	NEXTREG $43, %00110000						; Auto increment, select first tilemap palette
	NEXTREG $40, 0								; Start with first entry

	; Copy palette
	LD HL, di.tilePaletteBin					; Address of palette data in memory
	LD B, di.tilePaletteBinLength				; Number of colors to copy
.copyPalette
	LD A, (HL)									; Load RRRGGGBB into A
	INC HL										; Increment to next entry
	NEXTREG $41, A								; Send entry to Next HW
	DJNZ .copyPalette							; Repeat until B=0

	; Copy tile definitions to expected memory
	LD HL, di.tilesBin							; Address of tiles in memory
	LD BC, di.tilesBinLength					; Number of bytes to copy
	LD DE, START_OF_TILES
	LDIR

	; Copy tilemap to expected memory
	LD HL, di.tilemapBin						; Addreess of tilemap in memory
	LD BC, di.tilemapBinLength
	LD DE, START_OF_TILEMAP
	LDIR

	RET

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE