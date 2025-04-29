;----------------------------------------------------------;
;                   Game Level Intro                       ;
;----------------------------------------------------------;
	MODULE li

; The on-screen tilemap has 40x32 tiles, and into-tiles take a few horizontal screens (i.e., 40x120). Therefore, there are two different counters.
screenTilesRow			BYTE 0					; Current tiles row on the screen, runs from 0 to #ti.TI_VTILES_D32-1.
sourceTilesRow			BYTE 0					; Current tiles row in source file (RAM), runs from from 0 to sourceTilesRowMax.
sourceTilesRowMax		BYTE 0

tileOffset				BYTE 0					; Runs from 0 to 255, see also "NEXTREG _DC_REG_TI_Y_H31, _SC_RESY1_D255" in sc.SetupScreen.
tilePixelCnt			BYTE 0					; Runs from 0 to 7 (#ti.TI_PIXELS_D8-1).

animateDelayCnt			BYTE ANIMATE_DELAY 		; Start scrolling without a delay.
ANIMATE_DELAY			= 50
;----------------------------------------------------------;
;                   #LoadLevelIntro                        ;
;----------------------------------------------------------;
; Input:
;  - A:  Number of horizontal lines in source tilemap (40xA).
;  - DE: Level number as ASCII, for example for level 4: D="0", E="4"
;  - HL: Size of second tiles file (first one has 8KiB).
LoadLevelIntro

	LD (sourceTilesRowMax), A

	PUSH DE
	CALL _ResetLevelIntro
	LD (fi.introSecondFileSize), HL
	CALL ti.SetTilesClipVertical

	; ##########################################
	; Load palette
	LD HL, db.gameIntroPaletteAdr
	LD A, (db.gameIntroPaletteBytes)
	LD B, A
	CALL bp.LoadPalette

	; ##########################################
	; Load background image
	POP DE
	CALL fi.LoadLevelIntroImage
	CALL bm.LoadImage

	; ##########################################
	; Tilemap with story
	LD D, "0"
	LD E, "1"
	CALL fi.LoadLevelIntroTilemap
	CALL _NextTilesRow

	RET											; ## END of the function ##

;----------------------------------------------------------;
;             #AnimateLevelIntroTextScroll                 ;
;----------------------------------------------------------;
AnimateLevelIntroTextScroll
	; Return if intro is not active

	/* TODO use it when menu is ready.
	LD A, (los.lobbyState)
	CP los.LEVEL_INTRO							
	RET NZ */
	LD A, (los.lobbyState)
	CP los.LOBBY_INACTIVE
	RET Z
	
	; ##########################################
	; Delay animation (text scrolling) until the counter has reached ANIMATE_DELAY. When this happens, the animation runs at full speed 
	; until the delay counter has been reset. It occurs when the next text line from Tilemap is being loaded.
	LD A, (animateDelayCnt)
	CP ANIMATE_DELAY
	JR Z, .afterAnimateDelay
	INC A
	LD (animateDelayCnt), A
	RET
.afterAnimateDelay

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
	LD (animateDelayCnt), A
	CALL _NextTilesRow
.afterNextTile

	; ##########################################
	; Move tiles.
	LD A, (tileOffset)
	INC A
	LD (tileOffset), A
	NEXTREG _DC_REG_TI_Y_H31, A					; Y tile offset.

	RET											; ## END of the function ##
	
;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                  #_ResetLevelIntro                       ;
;----------------------------------------------------------;
_ResetLevelIntro

	LD A, ti.TI_VTILES_D32-1
	LD (screenTilesRow), A

	XOR A
	LD (tileOffset), A
	LD (sourceTilesRow), A
	LD (tilePixelCnt), A

	LD A, ANIMATE_DELAY
	LD (animateDelayCnt), A
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                   #_NextTilesRow                         ;
;----------------------------------------------------------;
; This method is called when the on screen tilemap has moved by 8 pixels. It reads the next row from the source tilemap and places it on 
; the bottom row on the screen. But as the tilemap moved by 8 pixels, so did the bottom row. Each time the method is called, we have to 
; calculate the new position of the bottom row (#screenTilesRow). We also need to read the next row from the source tilemap (#sourceTilesRow).
_NextTilesRow
	CALL dbs.Setup16KTilemapBank

	; ##########################################
	; Prepare tile copy fom temp RAM to screen RAM.

	; Load the memory address of the tiles row to be copied into HL. HL = RS_ADDR_HC000 + sourceTilesRow * ti.TI_H_BYTES_D80.
	LD A, (sourceTilesRow)
	LD D, A
	LD E, ti.TI_H_BYTES_D80
	MUL D, E									; DE contains byte offset to current row.
	LD HL, _RAM_SLOT6_STA_HC000
	ADD HL, DE									; Move RAM pointer to current row.

	; Load the bottom line of tilemap screen memory into DE. This row will be replaced with new lite line. 
	; DE = ti.RAM_START_H5B00 + screenTilesRow * ti.TI_H_BYTES_D80
	LD A, (screenTilesRow)

	LD D, A
	LD E, ti.TI_H_BYTES_D80
	MUL D, E									; DE contains #screenTilesRow * ti.TI_H_BYTES_D80.
	PUSH HL										; Keep HL because it already contains proper source tiles address
	LD HL, ti.RAM_START_H5B00					; Now HL contains memory offset to tiles.
	ADD HL, DE
	LD DE, HL
	POP HL
	LD BC, ti.TI_H_BYTES_D80					; Number of bytes to copy, it's one row.
	LDIR

	; ##########################################
	; Increment and reset #sourceTilesRow counter.
	LD A, (sourceTilesRow)
	INC A
	LD (sourceTilesRow), A
	LD B, A
	LD A, (sourceTilesRowMax)
	CP B
	JR NZ, .afterResetStarsRow					; Jump if #sourceTilesRow != #sourceTilesRowMax.

	; Reset counter.
	XOR A
	LD (sourceTilesRow), A
.afterResetStarsRow

	; ##########################################
	; Increment and reset #screenTilesRow counter.
	LD A, (screenTilesRow)
	INC A
	LD (screenTilesRow), A

	CP A, ti.TI_VTILES_D32
	JR NZ, .afterResetTilesRow					; Jump if #screenTilesRow != #ti.TI_VTILES_D32

	; Reset tiles counter.
	XOR A
	LD (screenTilesRow), A
.afterResetTilesRow

	RET											; ## END of the function ##
;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE