;----------------------------------------------------------;
;          Screen Setup, Synchronization and Timing        ;
;----------------------------------------------------------;
	MODULE sc

;----------------------------------------------------------;
;                      #SetupScreen                        ;
;----------------------------------------------------------;
SetupScreen

	; Sprite and Layers system. Bits:
	;  - 7: 0 - low RES mode off,
	;  - 6: 1 - sprite on top,
	;  - 5: 0 - sprite clipping disabled,
	;  - 4-2: 110 - S(U+L) ULA and Layer 2 combined (tiles + background),
	;  - 1: 1 - sprite over border,
	;  - 0: 1 - sprites visible.
	NEXTREG _SPR_REG_SETUP_H15, %0'1'0'110'1'1

	NEXTREG _DC_REG_TI_Y_H31, _SC_RESY1_D255	; Reverses scrolling of the tiles, required by tl.NextStarsRow.

	NEXTREG _DC_REG_CONTROL1_H69, %1'0'0'00000	; Enable Layer 2
	
	NEXTREG _GL_REG_TRANP_COL_H14, _COL_TRANSPARENT_D0 ; Global transparency.

	NEXTREG _DC_REG_LA2_H70, %00'01'0000		; Layer 2 320x256x8bpp, palette offset at 0.

	LD	A, _COL_BLACK_D0						; Set border color.
	OUT (_BORDER_IO_HFE), A

	; Clip window for layer 2, required to display full picture at 320x256.
	NEXTREG _DC_REG_L2_CLIP_H18, 0
	NEXTREG _DC_REG_L2_CLIP_H18, 159
	NEXTREG _DC_REG_L2_CLIP_H18, 0
	NEXTREG _DC_REG_L2_CLIP_H18, 255	

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                     #WaitForScanline                     ;
;----------------------------------------------------------;
; Pauses executing for single frame, 1/60 or 1/50 of a second.
; Based on: https://github.com/robgmoran/DougieDoSource
WaitForScanline     

; Read NextReg $1F - LSB of current raster line
	LD BC, _GL_REG_SELECT_H243B					; TBBlue Register Select.
	LD A, _GL_REG_VL_H1F						; Port to access - Active Video Line LSB Register.
	OUT (C), A									; Select NextReg $1F.
	INC B										; TBBlue Register Access.

; Wait for scanline (#_SC_SYNC_SL_D192).
.waitForScanline
	IN A, (C)									; Read the raster line LSB into A.
	CP _SC_SYNC_SL_D192
	JR NZ, .waitForScanline

	RET											; ## END of the function ##
;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE