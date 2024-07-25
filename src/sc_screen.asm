;----------------------------------------------------------;
;          Screen Setup, Synchronization and Timing        ;
;----------------------------------------------------------;
	MODULE sc

SCR_X_MIN_POS			= 0
SCR_X_MAX_POS			= 315
SCR_Y_MIN_POS			= 10
SCR_Y_MAX_POS			= 240

SC_SYNC_SL				= 0						; Scanline to synch to

;----------------------------------------------------------;
;                      #SetupScreen                        ;
;----------------------------------------------------------;
SetupScreen

	; Sprite and Layers system. Bits:
	;  - 7: 0 - low res mode off
	;  - 6: 1 - sprite on top
	;  - 5: 0 - sprite clipping disabled
	;  - 4-2: 110 - S(U+L) ULA and Layer 2 combined (tiles + background)
	;  - 1: 1 - sprite over border
	;  - 0: 1 - sprites visible
	NEXTREG _SPR_REG_SETUP_H15, %0'1'0'110'1'1
	NEXTREG _DC_REG_CONTROL1_H69, %1'0'0'00000	; Enable Layer 2
	NEXTREG _DC_REG_TILE_TRANSP_H4C, $00		; Black for tilemap transparency
	NEXTREG _DC_REG_LA2_BANK_H12, di.BGR_IMG_16B9 ; Layer 2 image (background) starts at 16k-bank 9 (default)
	
	LD	A, _COL_BLACK							; Set border color
	OUT (_BORDER_IO), A

	CALL _ROM_CLS_H0DAF							; Clear screen
	
	RET

;----------------------------------------------------------;
;                     #WaitForScanline                     ;
;----------------------------------------------------------;
; Pauses executing for single frame, 1/60 or 1/50 of a second.
;
; The code waits for the given scanline (#SC_SYNC_SL) in the first loop, and then in the second loop, it waits again for the same scanline. 
; This method pauses for the whole frame or a bit more, depending on which scanline display is when calling "WaitForScanline".
; 
; Based on: https://github.com/robgmoran/DougieDoSource

WaitForScanline     
; Read NextReg $1F - LSB of current raster line
	LD BC, _GL_REG_SELECT_H243B					; TBBlue Register Select
	LD A, _GL_REG_VL_H1F						; Port to access - Active Video Line LSB Register
	OUT (C), A									; Select NextReg $1F
	INC B										; TBBlue Register Access

; Wait for scanline given by H (#SC_SYNC_SL)
.waitForScanline
	IN A, (C)									; Read the raster line LSB into A
	CP SC_SYNC_SL
	JR Z, .waitForScanline						; Keep looping until Scanline changes from given to next, 192->193

; Now we are at the scanline, wait the whole frame again for the same scanline
.waitAgainForScanline
	IN A, (C)									; Read the raster line LSB into A
	CP SC_SYNC_SL
	JR NZ, .waitAgainForScanline

	RET

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE