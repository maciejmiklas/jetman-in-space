;----------------------------------------------------------;
;                     Rocket Stars                         ;
;----------------------------------------------------------;
	MODULE ros


TIS_ROWS_D128			= _TI_VTILES_D32*4		; 128 rows (4*32), tile starts takes two horizontal screens.
	ASSERT TIS_ROWS_D128 =  128

TIS_MOVE_FROM_D50		= 50					; Start moving stats when the rocket reaches the given height.	

TI_HTILES_D40			= 320/8					; 40 horizontal tiles.

; 320/8*2 = 80 bytes pro row -> single tile has 8x8 pixels. 320/8 = 40 tiles pro line, each tile takes 2 bytes.
TI_H_BYTES_D80			= TI_HTILES_D40 * 2

; In-game tilemap has 40x32 tiles, and stars have 40*64, therefore, there are two different counters.
tilesRow				BYTE _TI_VTILES_D32		; Current tiles row, runs from _TI_VTILES_D32-1 to 0.
starsRow				BYTE TIS_ROWS_D128		; Current start row, runs from from TIS_ROWS_D128 to 0.

tileOffset				BYTE _SC_RESY1_D255		; Runs from 255 to 0, see also "NEXTREG _DC_REG_TI_Y_H31, _SC_RESY1_D255" in sc.SetupScreen.
tilePixelCnt			BYTE _TI_PIXELS_D8		; Runs from 0 to 7 (_TI_PIXELS_D8-1).

;----------------------------------------------------------;
;                 #ResetRocketStarsRow                     ;
;----------------------------------------------------------;
ResetRocketStarsRow
	LD A, _TI_VTILES_D32
	LD (tilesRow), A

	LD A, TIS_ROWS_D128
	LD (starsRow), A

	LD A, _SC_RESY1_D255
	LD (tileOffset), A

	XOR A
	LD (tilePixelCnt), A
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #NextRocketStarsRow                     ;
;----------------------------------------------------------;
; This method is called when the in-game tilemap has moved by 8 pixels. It reads the next row from the tilemap and places it on the bottom row 
; on the screen. But as the tilemap moved by 8 pixels, so did the bottom row. Each time the method is called, we have to calculate the new 
; position of the bottom row (#tilesRow). We also need to read the next row from the starts tilemap (#starsRow).
NextRocketStarsRow
	CALL dbs.SetupRocketStarsBank

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

	; Load the memory address of the starts row to be copied into HL. HL = TI_RAM_ADDR + starsRow * TI_H_BYTES_D80.
	LD D, A
	LD E, TI_H_BYTES_D80
	MUL D, E									; DE contains byte offset to current row.
	LD HL, dbs.RS_ADDR_HC000
	ADD HL, DE									; Move RAM pointer to current row.

	; Load the memory address of in-game tiles into DE. This row will be replaced with stars. DE = ti.RAM_START_H5B00 + tilesRow * _TI_H_BYTES_D8.0
	LD A, (tilesRow)
	LD D, A
	LD E, TI_H_BYTES_D80
	MUL D, E									; DE contains #tilesRow * TI_H_BYTES_D80.
	PUSH HL
	LD HL, ti.RAM_START_H5B00						; HL contains memory offset to tiles.
	ADD HL, DE
	LD DE, HL
	POP HL

	LD BC, TI_H_BYTES_D80						; Number of bytes to copy, it's one row.
	LDIR	

	; ##########################################
	; Reset stars counter ?
	LD A, (starsRow)
	CP A, 0
	JR NZ, .afterResetStarsRow					; Jump if #starsLine > 0.

	; Reset stars counter.
	LD A, TIS_ROWS_D128
	LD (starsRow), A
.afterResetStarsRow

	; ##########################################
	; Reset tiles counter?
	LD A, (tilesRow)
	CP A, 0
	JR NZ, .afterResetTilesRow					; Jump if #tilesRow > 0.

	; Reset tiles counter.
	LD A, _TI_VTILES_D32
	LD (tilesRow), A
.afterResetTilesRow

	RET											; ## END of the function ##

;----------------------------------------------------------;
;               #AnimateStarsOnFlyRocket                   ;
;----------------------------------------------------------;
AnimateStarsOnFlyRocket

	; Return if rocket is not flying.
	LD A, (ro.rocketState)
	CP ro.ROST_FLY
	RET NZ

	; ##########################################
	; Start animation when the rocket reaches given height.
	LD HL, (ro.rocketDistance)
	LD A, H
	CP 0										; If H > 0 then distance is definitely > TIS_MOVE_FROM_D50.
	JR NZ, .afterAnimationStart

	LD A, L
	CP TIS_MOVE_FROM_D50
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

	CALL NextRocketStarsRow
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
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE