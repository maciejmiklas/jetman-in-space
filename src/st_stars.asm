;----------------------------------------------------------;
;                           Stars                          ;
;----------------------------------------------------------;
	MODULE st

TILES_ROW_RESET			= _CF_TI_V_TILES-1

; Ingame tilemap has 40x32 tiles, and stars have 40*64, therefore, there are two different counters.
tilesRow				BYTE TILES_ROW_RESET	; Current tiles row, runns from _CF_TI_V_TILES-1 to 0
starsRow				BYTE _CF_TIS_ROWS		; Current start row, runns from from _CF_TIS_ROWS to 0

tileOffset				BYTE _CF_SC_3MAX_Y		; Runns from 255 to 0, see also "NEXTREG _DC_REG_TI_Y_H31, _CF_SC_3MAX_Y" in sc.SetupScreen
tilePixelCnt			BYTE 0					; Runns from 0 to 7

;----------------------------------------------------------;
;                       #ResetStars                        ;
;----------------------------------------------------------;
	LD A, TILES_ROW_RESET
	LD (tilesRow), A

	LD A, _CF_TIS_ROWS
	LD (starsRow), A

	LD A, _CF_SC_3MAX_Y
	LD (tileOffset), A

	XOR A
	LD (tilePixelCnt), A
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       #NextStarsRow                      ;
;----------------------------------------------------------;
; This method is called when the ingame tilemap has moved by 8 pixels. It reads the next row from the tilemap and places it on the bottom row 
; on the screen. But as the tilemap moved by 8 pixels, so did the bottom row. Each time the method is called, we have to calculate the new 
; position of the bottom row (#tilesRow). We also need to read the next row from the starts tilemap (#starsRow)
NextStarsRow
	NEXTREG _MMU_REG_SLOT6_H56, _CF_BIN_STARTS_BANK1 ; Assign bank 44 to slot 6 (see di_data_bin.asm)
	NEXTREG _MMU_REG_SLOT7_H57, _CF_BIN_STARTS_BANK2 ; Assign bank 45 to slot 7

	; ##########################################
	; Decrement counters
	LD A, (tilesRow)
	DEC A
	LD (tilesRow), A

	LD A, (starsRow)
	DEC A
	LD (starsRow), A							; A is used below

	; ##########################################
	; Prepare tile copy fom temp RAM to screen RAM

	; Load the memory address of the starts row to be copied into HL. HL = db.starsBin + starsRow * _CF_TI_H_BYTES
	LD D, A
	LD E, _CF_TI_H_BYTES
	MUL D, E									; DE contains byte offset to current row
	LD HL, db.starsBin
	ADD HL, DE									; Move RAM pointer to current row

	; Load the memory address of ingame tiles into DE. This row will be replaced with stars. DE = _CF_TI_START + tilesRow * _CF_TI_H_BYTES
	LD A, (tilesRow)
	LD D, A
	LD E, _CF_TI_H_BYTES
	MUL D, E									; DE contains #tilesRow * _CF_TI_H_BYTES
	PUSH HL
	LD HL, _CF_TI_START							; HL contains memory offset to tiles
	ADD HL, DE
	LD DE, HL
	POP HL

	LD BC, _CF_TI_H_BYTES						; Number of bytes to copy, it's one row
	LDIR	

	; ##########################################
	; Reset stars counter ?
	LD A, (starsRow)
	CP A, 0
	JR NZ, .afterResetStarsRow					; Jump if #starsLine > 0

	; Reset stars counter
	LD A, _CF_TIS_ROWS
	LD (starsRow), A
.afterResetStarsRow

	; ##########################################
	; Reset tiles counter ?
	LD A, (tilesRow)
	CP A, 0
	JR NZ, .afterResetTilesRow					; Jump if #tilesRow > 0

	; Reset tiles counter
	LD A, TILES_ROW_RESET + 1
	LD (tilesRow), A
.afterResetTilesRow

	RET											; ## END of the function ##

;----------------------------------------------------------;
;               #AnimateStarsOnFlyRocket                   ;
;----------------------------------------------------------;
AnimateStarsOnFlyRocket

	; Return if rocket is not flying
	LD A, (ro.rocketState)
	CP ro.RO_ST_FLY
	RET NZ

	; ##########################################
	; Start animation when the rocket reaches given height
	LD HL, (ro.rocketDistance)
	LD A, H
	CP 0										; If H > 0 then distance is definitely > _CF_ITS_MOVE_FROM
	JR NZ, .afterAnimationStart

	LD A, L
	CP _CF_ITS_MOVE_FROM
	RET C
.afterAnimationStart

	; ##########################################
	; Increment the tile counter to determine whether we should load the next tile row
	LD A, (tilePixelCnt)
	INC A
	LD (tilePixelCnt), A

	CP _CF_TI_PIXELS
	JR NZ, .afterNextTile
	
	; Reset the counter and fetch the next tile row
	XOR A
	LD (tilePixelCnt), A

	CALL NextStarsRow
.afterNextTile

	; ##########################################
	; Move tiles
	LD A, (tileOffset)
	DEC A
	LD (tileOffset), A
	NEXTREG _DC_REG_TI_Y_H31, A					; Y tile offset

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE