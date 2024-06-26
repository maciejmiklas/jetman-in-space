;----------------------------------------------------------;
;          Screen Setup, Synchronization and Timing        ;
;----------------------------------------------------------;
	MODULE sc

SCR_X_MIN_POS			= 0
SCR_X_MAX_POS			= 315
SCR_Y_MIN_POS			= 10
SCR_Y_MAX_POS			= 240

SC_SYNC_SL				= 1						; Scanline to synch to

;----------------------------------------------------------;
;                      #SetupScreen                        ;
;----------------------------------------------------------;
SetupScreen

	; Sprite and Layers system
	; Bits:
	;  - 7		= '0': LowRes off
	;  - 6		= '1': Sprites on top
	;  - 5		= '0': Sprites over border
	;  - 4-2 	= '010': SUL -> Top - Sprites, enhanced ULA, Layer 2
	;  - 1 		= '1': over border
	;  - 0 		= '1': sprites visible
	NEXTREG _SPR_REG_SETUP_H15, %0'1'0'010'1'1 	; Sprite 0 on top('1'), SLU('000'), over border('1'), sprites visible('1')
	NEXTREG _DC_REG_CONTROL1_H69, %00'01'0000	; Layer 2 screen resolution 320 x 256 x 8bpp
	nextreg _DC_REG_TILE_TRANSP_H4C, $00		; Black for tilemap transparency
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
	LD A, SC_SYNC_SL							; Set Scanline to wait for
	LD D, A

; Wait for Scanline given by H (#SC_SYNC_SL)
.waitForScanline
	IN A, (C)									; Read the raster line LSB into A
	CP D
	JR Z, .waitForScanline						; Keep looping until Scanline changes from given to next, 192->193

; Now we are past #SC_SYNC_SL -> on #SC_SYNC_SL + 1

; Wait the whole frame again for given Scanline (#SC_SYNC_SL)
.waitAgainForScanline
	IN A, (C)									; Read the raster line LSB into A
	CP D
	JR NZ, .waitAgainForScanline

	RET

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE