; Tiles should be stored between $4000 and $7FFF. This area is called Bank 5 (16K Banks). However, ULA uses $4000-$6000. For this reason, 
; we start loading tiles from $6000. Hardware expects tiles in Bank 5; therefore, we only have to provide offsets starting from $4000.
START_OF_BANK_5		= $4000	

START_OF_TILEMAP	= $6000					; Just after ULA attributes
START_OF_TILES		= $6A00					; Just after tilemap -> 40x32x2 (2 bytes for tile)

; START_OF_TILEMAP - START_OF_BANK_5 = $2000  -> >> 8 =  $20 = 32
OFFSET_OF_MAP		= (START_OF_TILEMAP - START_OF_BANK_5) >> 8

; START_OF_TILES - START_OF_BANK_5 = $2600  -> >> 8 =  $26 = 38
OFFSET_OF_TILES		= (START_OF_TILES - START_OF_BANK_5) >> 8

LoadTiles:
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
	LD HL, tilePaletteBin						; Address of palette data in memory
	LD B, tilePaletteBinLength					; Number of colours to copy
.copyPalette:
	LD A, (HL)									; Load RRRGGGBB into A
	INC HL										; Increment to next entry
	NEXTREG $41, A								; Send entry to Next HW
	DJNZ .copyPalette							; Repeat until B=0

	; Copy tile definitions to expected memory
	LD HL, tilesBin								; Address of tiles in memory
	LD BC, tilesBinLength						; Number of bytes to copy
	LD DE, START_OF_TILES
	LDIR

	; Copy tilemap to expected memory
	LD HL, tilemapBin							; Addreess of tilemap in memory
	LD BC, tilemapBinLength
	LD DE, START_OF_TILEMAP
	LDIR

	RET