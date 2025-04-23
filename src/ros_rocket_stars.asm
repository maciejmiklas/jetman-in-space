;----------------------------------------------------------;
;                     Rocket Stars                         ;
;----------------------------------------------------------;
	MODULE ros

; Tile stars
TI_ROWS_D128			= ti.TI_VTILES_D32*4	; 128 rows (4*32), tile starts takes 4 horizontal screens.
	ASSERT TI_ROWS_D128 =  128

TI_MOVE_FROM_D50		= 50					; Start moving stats when the rocket reaches the given height.	

; 320/8*2 = 80 bytes pro row -> single tile has 8x8 pixels. 320/8 = 40 tiles pro line, each tile takes 2 bytes.
ti.TI_H_BYTES_D80			= 320/8 * 2

; In-game tilemap has 40x32 tiles, and stars have 40*64, therefore, there are two different counters.
tilesRow				BYTE ti.TI_VTILES_D32	; Current tiles row, runs from TI_VTILES_D32-1 to 0.
sourceTilesRow			BYTE TI_ROWS_D128		; Current tiles row in source file (RAM), runs from from TI_ROWS_D128 to 0.

tileOffset				BYTE _SC_RESY1_D255		; Runs from 255 to 0, see also "NEXTREG _DC_REG_TI_Y_H31, _SC_RESY1_D255" in sc.SetupScreen.
tilePixelCnt			BYTE ti.TI_PIXELS_D8	; Runs from 0 to 7 (ti.TI_PIXELS_D8-1).

;----------------------------------------------------------;
;                   #ResetRocketStars                      ;
;----------------------------------------------------------;
ResetRocketStars
	LD A, ti.TI_VTILES_D32
	LD (tilesRow), A

	LD A, TI_ROWS_D128
	LD (sourceTilesRow), A

	LD A, _SC_RESY1_D255
	LD (tileOffset), A

	XOR A
	LD (tilePixelCnt), A
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;               #AnimateStarsOnFlyRocket                   ;
;----------------------------------------------------------;
AnimateStarsOnFlyRocket

	; Start animation when the rocket reaches given height.
	LD HL, (ro.rocketDistance)
	LD A, H
	CP 0										; If H > 0 then distance is definitely > TI_MOVE_FROM_D50.
	JR NZ, .afterAnimationStart

	LD A, L
	CP TI_MOVE_FROM_D50
	RET C
.afterAnimationStart

	; ##########################################
	; Increment the tile counter to determine whether we should load the next tile row.
	LD A, (tilePixelCnt)
	INC A
	LD (tilePixelCnt), A

	CP ti.TI_PIXELS_D8
	JR NZ, .afterNextTile
	
	; Reset the counter and fetch the next tile row.
	XOR A
	LD (tilePixelCnt), A

	CALL _NextTilesRow
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
;                   #_NextTilesRow                         ;
;----------------------------------------------------------;
; This method is called when the in-game tilemap has moved by 8 pixels. It reads the next row from the tilemap and places it on the bottom row 
; on the screen. But as the tilemap moved by 8 pixels, so did the bottom row. Each time the method is called, we have to calculate the new 
; position of the bottom row (#tilesRow). We also need to read the next row from the starts tilemap (#sourceTilesRow).
_NextTilesRow
	CALL dbs.Setup16KTilemapBank

	; ##########################################
	; Decrement counters.
	LD A, (tilesRow)
	DEC A
	LD (tilesRow), A

	LD A, (sourceTilesRow)
	DEC A
	LD (sourceTilesRow), A							; A is used below.

	; ##########################################
	; Prepare tile copy fom temp RAM to screen RAM.

	; Load the memory address of the starts row to be copied into HL. HL = TI_RAM_ADDR + sourceTilesRow * ti.TI_H_BYTES_D80.
	LD D, A
	LD E, ti.TI_H_BYTES_D80
	MUL D, E									; DE contains byte offset to current row.
	LD HL, _RAM_SLOT6_STA_HC000
	ADD HL, DE									; Move RAM pointer to current row.

	; Load the memory address of in-game tiles into DE. This row will be replaced with stars. 
	; DE = ti.RAM_START_H5B00 + tilesRow * ti.TI_H_BYTES_D80
	LD A, (tilesRow)
	LD D, A
	LD E, ti.TI_H_BYTES_D80
	MUL D, E									; DE contains #tilesRow * ti.TI_H_BYTES_D80.
	PUSH HL
	LD HL, ti.RAM_START_H5B00					; HL contains memory offset to tiles.
	ADD HL, DE
	LD DE, HL
	POP HL

	LD BC, ti.TI_H_BYTES_D80						; Number of bytes to copy, it's one row.
	LDIR	

	; ##########################################
	; Reset stars counter ?
	LD A, (sourceTilesRow)
	CP A, 0
	JR NZ, .afterResetStarsRow					; Jump if #starsLine > 0.

	; Reset stars counter.
	LD A, TI_ROWS_D128
	LD (sourceTilesRow), A
.afterResetStarsRow

	; ##########################################
	; Reset tiles counter?
	LD A, (tilesRow)
	CP A, 0
	JR NZ, .afterResetTilesRow					; Jump if #tilesRow > 0.

	; Reset tiles counter.
	LD A, ti.TI_VTILES_D32
	LD (tilesRow), A
.afterResetTilesRow

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE