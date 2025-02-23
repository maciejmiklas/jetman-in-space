;----------------------------------------------------------;
;                           Stars                          ;
;----------------------------------------------------------;
	MODULE ros

TILES_ROW_RESET			= _TI_VTILES_D32-1

; Ingame tilemap has 40x32 tiles, and stars have 40*64, therefore, there are two different counters.
tilesRow				BYTE TILES_ROW_RESET	; Current tiles row, runns from _TI_VTILES_D32-1 to 0.
starsRow				BYTE _TIS_ROWS_D128		; Current start row, runns from from _TIS_ROWS_D128 to 0.

tileOffset				BYTE _SC_RESY1_D255		; Runns from 255 to 0, see also "NEXTREG _DC_REG_TI_Y_H31, _SC_RESY1_D255" in sc.SetupScreen.
tilePixelCnt			BYTE 0					; Runns from 0 to 7.

;----------------------------------------------------------;
;                       #NextStarsRow                      ;
;----------------------------------------------------------;
; This method is called when the ingame tilemap has moved by 8 pixels. It reads the next row from the tilemap and places it on the bottom row 
; on the screen. But as the tilemap moved by 8 pixels, so did the bottom row. Each time the method is called, we have to calculate the new 
; position of the bottom row (#tilesRow). We also need to read the next row from the starts tilemap (#starsRow).
NextStarsRow
	NEXTREG _MMU_REG_SLOT6_H56, _BN_STARTS_BANK1_D44 ; Assign bank 44 to slot 6 (see di_data_bin.asm).
	NEXTREG _MMU_REG_SLOT7_H57, _BN_STARTS_BANK2_D45 ; Assign bank 45 to slot 7.

	; ##########################################
	; Decrement counters.
	LD A, (tilesRow)
	DEC A
	LD (tilesRow), A

	LD A, (starsRow)
	DEC A
	LD (starsRow), A							; A is used below.

	; ##########################################
	; Prepare tile copy fom temp RAM to screen RAM.

	; Load the memory address of the starts row to be copied into HL. HL = dbi.starsBin + starsRow * _TI_H_BYTES_D80.
	LD D, A
	LD E, _TI_H_BYTES_D80
	MUL D, E									; DE contains byte offset to current row.
	LD HL, dbi.starsBin
	ADD HL, DE									; Move RAM pointer to current row.

	; Load the memory address of ingame tiles into DE. This row will be replaced with stars. DE = _TI_START_H5B00 + tilesRow * _TI_H_BYTES_D8.0
	LD A, (tilesRow)
	LD D, A
	LD E, _TI_H_BYTES_D80
	MUL D, E									; DE contains #tilesRow * _TI_H_BYTES_D80.
	PUSH HL
	LD HL, _TI_START_H5B00						; HL contains memory offset to tiles.
	ADD HL, DE
	LD DE, HL
	POP HL

	LD BC, _TI_H_BYTES_D80						; Number of bytes to copy, it's one row.
	LDIR	

	; ##########################################
	; Reset stars counter ?
	LD A, (starsRow)
	CP A, 0
	JR NZ, .afterResetStarsRow					; Jump if #starsLine > 0.

	; Reset stars counter.
	LD A, _TIS_ROWS_D128
	LD (starsRow), A
.afterResetStarsRow

	; ##########################################
	; Reset tiles counter?
	LD A, (tilesRow)
	CP A, 0
	JR NZ, .afterResetTilesRow					; Jump if #tilesRow > 0.

	; Reset tiles counter.
	LD A, TILES_ROW_RESET + 1
	LD (tilesRow), A
.afterResetTilesRow

	RET											; ## END of the function ##

;----------------------------------------------------------;
;               #AnimateStarsOnFlyRocket                   ;
;----------------------------------------------------------;
AnimateStarsOnFlyRocket

	; Return if rocket is not flying.
	LD A, (ro.rocketState)
	CP ro.RO_ST_FLY
	RET NZ

	; ##########################################
	; Start animation when the rocket reaches given height.
	LD HL, (ro.rocketDistance)
	LD A, H
	CP 0										; If H > 0 then distance is definitely > _ITS_MOVE_FROM_D50.
	JR NZ, .afterAnimationStart

	LD A, L
	CP _ITS_MOVE_FROM_D50
	RET C
.afterAnimationStart

	; ##########################################
	; Increment the tile counter to determine whether we should load the next tile row.
	LD A, (tilePixelCnt)
	INC A
	LD (tilePixelCnt), A

	CP _TI_PIXELS_D8
	JR NZ, .afterNextTile
	
	; Reset the counter and fetch the next tile row.
	XOR A
	LD (tilePixelCnt), A

	CALL NextStarsRow
.afterNextTile

	; ##########################################
	; Move tiles.
	LD A, (tileOffset)
	DEC A
	LD (tileOffset), A
	NEXTREG _DC_REG_TI_Y_H31, A					; Y tile offset.

	RET											; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                      #_ResetStars                        ;
;----------------------------------------------------------;
_ResetStars
	LD A, TILES_ROW_RESET
	LD (tilesRow), A

	LD A, _TIS_ROWS_D128
	LD (starsRow), A

	LD A, _SC_RESY1_D255
	LD (tileOffset), A

	XOR A
	LD (tilePixelCnt), A
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE