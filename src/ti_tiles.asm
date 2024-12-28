;----------------------------------------------------------;
;                           Tiles                          ;
;----------------------------------------------------------;
	MODULE ti


; Timemap for single screen at 320x200 requires 2650 bytes:
; - 320 = 8*40 - 40 horizontal tiles
; - 256 = 8*32 - 32 vertical tiles
; Each tile occupies 2 bytes (tile offset and palette offset): 40*32*2 = 2560 bytes
;
; Size of a single tile definition (tile sprite): 8x8 pixels, but each has 4 bit pallte: 8*8/2 = 32 bytes
;
; Memory organization:
; - $4000 - $5AFF - ULA
; - $5B00 - $6500 - Tilemap, 2560 bytes
; - $6501 - $7FFF - Tile definitions/sprites. We can store up to 215 sprites: $7FFF - $6501 = 6910. 6910/32 = 215

;----------------------------------------------------------;
;                     #ShakeTilemap                        ;
;----------------------------------------------------------;
ShakeTilemap

	LD A, (gld.counter002FliFLop)				; Oscilates beetwen 1 and 0
	LD D, A
	LD E, _CF_SC_SHAKE_BY
	MUL D, E
	LD A, E
	NEXTREG _DC_REG_TI_X_LSB_H30, A				; X tile offset
	NEXTREG _DC_REG_TI_Y_H31, A					; Y tile offset
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                 #ResetTilemapOffset                      ;
;----------------------------------------------------------;
ResetTilemapOffset

	XOR A
	NEXTREG _DC_REG_TI_X_LSB_H30, A				; X tile offset
	NEXTREG _DC_REG_TI_Y_H31, A					; Y tile offset

	RET											; ## END of the function ##

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

	LD HL, _CF_TI_START							; HL points to screen memory containing tilemap 
	DEC HL										; TODO why (verify _CF_TI_START)?
	
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
	ADD A, -_CF_TX_ASCII_OFFSET					; Remove ASCII offset as tiles begin with 0

	LD (HL), _CF_TX_PALETTE						; Set palette for tile
	INC HL
	LD (HL), A									; Set character for tile
	INC HL

	DJNZ .loop									; Loop untill B == 0

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       #CleanTiles                        ;
;----------------------------------------------------------;
;  - B:		Amount of tiles to clean 
CleanTiles
	LD HL, _CF_TI_START							; HL points to screen memory containing tilemap 
	DEC HL										; TODO why (verify _CF_TI_START)?

	; ##########################################
	LD A, _CF_TI_EMPTY
.loop
	
	LD (HL), _CF_TX_PALETTE						; Set palette for tile
	INC HL
	
	LD (HL), A									; Set tile ind.
	INC HL	

	DJNZ .loop									; Loop untill B == 0

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                         #LoadTiles                       ;
;----------------------------------------------------------;
LoadTiles
	
	; Enable tilemap mode
	NEXTREG _TI_MAP_CONTROL_H6B, %10000001		; 40x32, 8-pixel tiles = 320x256
	NEXTREG _TI_ATTRIBTE_H6C, %00000000			; Palette offset, visuals

	; ##########################################
	; Setup clip window to hide bottom tile row
	CALL SetTilesClipFull

	; ##########################################
	; Tell harware where to find tiles. Bits 5-0 = MSB of address of the tilemap in Bank 5
	NEXTREG _TI_MAP_ADR_H6E, _CF_TI_OFFSET		; MSB of tilemap in bank 5
	NEXTREG _TI_DEF_ADR_H6F, _CF_TID_OFFSET		; MSB of tilemap definitions (sprites)

	; ##########################################
	; Setup palette
	LD HL, db.tilePaletteBin					; Address of palette data in memory
	LD B, db.tilePaletteBinLength				; Number of colors to copy
	CALL LoadTilemapPalette

	; ##########################################
	; Copy tilemap to expected memory
	LD DE, _CF_TI_START
	LD HL, db.tilemapBin						; Addreess of tilemap in memory
	LD BC, db.tilemapBinLength	
	LDIR

	; ##########################################
	; Copy tile definitions to expected memory
	LD DE, _CF_TID_START
	LD HL, db.tileDefBin						; Address of tiles in memory
	LD BC, db.tileDefBinLength					; Number of bytes to copy
	LDIR	

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #LoadTilemapPalette                     ;
;----------------------------------------------------------;
; Input:
; - B:		Number of colors to copy
; - HL:		Address of layer 2 palette data 
LoadTilemapPalette

	; Black for tilemap transparency
	NEXTREG _DC_REG_TI_TRANSP_H4C, _COL_TRANSPARENT

	; Bits
	;  - 0: 1 = Enabe ULANext mode
	;  - 1-3: 0 = First palette 
	;  - 6-4: 011 = Tilemap first palette
	;  - 7: 0 = enable autoincrement on write
	NEXTREG _DC_REG_LA2_PAL_CTR_H43, %0'011'000'1 
	NEXTREG _DC_REG_LA2_PAL_IDX_H40, 0			; Start with color index 0

	; Copy 8 bit palette
.loop
	LD A, (HL)									; Load RRRGGGBB into A
	INC HL										; Increment to next entry
	NEXTREG _DC_REG_LA2_PAL_VAL_H41, A			; Send entry to Next HW
	DJNZ .loop									; Repeat until B=0

	RET											; ## END of the function ##
	
;----------------------------------------------------------;
;                   #SetTilesClipFull                      ;
;----------------------------------------------------------;
SetTilesClipFull

	NEXTREG _CF_TI_CLIP_WINDOW_H1B, _CF_TI_CLIP_X1
	NEXTREG _CF_TI_CLIP_WINDOW_H1B, _CF_TI_CLIP_X2
	NEXTREG _CF_TI_CLIP_WINDOW_H1B, _CF_TI_CLIP_Y1
	NEXTREG _CF_TI_CLIP_WINDOW_H1B, _CF_TI_CLIP_FULL_Y2-32

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                 #SetTilesClipRocket                      ;
;----------------------------------------------------------;
SetTilesClipRocket

	NEXTREG _CF_TI_CLIP_WINDOW_H1B, _CF_TI_CLIP_X1
	NEXTREG _CF_TI_CLIP_WINDOW_H1B, _CF_TI_CLIP_X2
	NEXTREG _CF_TI_CLIP_WINDOW_H1B, _CF_TI_CLIP_Y1
	NEXTREG _CF_TI_CLIP_WINDOW_H1B, _CF_TI_CLIP_ROCKET_Y2

	RET											; ## END of the function ##	

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE