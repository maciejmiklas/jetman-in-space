;----------------------------------------------------------;
;          Screen Setup, Synchronization and Timing        ;
;----------------------------------------------------------;
	MODULE sc

SCR_X_MIN_POS			= 0
SCR_X_MAX_POS			= 315
SCR_Y_MIN_POS			= 10
SCR_Y_MAX_POS			= 240

SC_SYNC_SL				= 0						; Scanline to synch to

SHAKE_SCREEN_BY			= 5						; Number of pixels to move the screen by shaking

;----------------------------------------------------------;
;                      #SetupScreen                        ;
;----------------------------------------------------------;
SetupScreen
	; Sprite and Layers system. Bits:
	;  - 7: 0 - low RES mode off
	;  - 6: 1 - sprite on top
	;  - 5: 0 - sprite clipping disabled
	;  - 4-2: 110 - S(U+L) ULA and Layer 2 combined (tiles + background)
	;  - 1: 1 - sprite over border
	;  - 0: 1 - sprites visible
	NEXTREG _SPR_REG_SETUP_H15, %0'1'0'110'1'1

	; Setup Layer 2
	NEXTREG _DC_REG_CONTROL1_H69, %1'0'0'00000	; Enable Layer 2
	NEXTREG _DC_REG_LA2_H70, %000'00'000		; Layer 2 has 256x192x8bpp
	NEXTREG _DC_REG_L2_BANK_H12, di.BGR_IMG_PAL_16B9 ; Layer 2 image (background) starts at 16k-bank 9 (default)

	NEXTREG _GL_REG_TRANP_COL_H14, 00			; Global transparency

	LD	A, _COL_BLACK							; Set border color
	OUT (_BORDER_IO_HFE), A

	; Layer 2 Palette
	LD A, $$di.backGroundPalette				; Memory bank (8kb) containing layer 2 palette data
	LD HL, di.backGroundPalette					; Address of first byte of layer 2 palette data
	CALL SetupLayer2Palette

	RET

;----------------------------------------------------------;
;                 #SetupLayer2Palette                      ;
;----------------------------------------------------------;
; Input:
; - A:		8k memory bank containing layer 2 palette data
; - HL:		address of layer 2 palette data
SetupLayer2Palette
	NEXTREG _MMU_REG_SLOT7_H57, A				; Assign bank 24 to slot 7	

	; Bits
	;  - 0: 1 = Enabe ULANext mode
	;  - 1-3: 0 = First palette 
	;  - 6-4: 001 = Layer 2 first palette
	;  - 7: 0 = enable autoincrement on write	
	NEXTREG _DC_REG_LA2_PAL_CTR_H43, %0'001'0'0'0'1 
	NEXTREG _DC_REG_LA2_PAL_IDX_H40, 0			; Start with color index 0

	; Copy 9 bit (2 bytes per color) palette
	LD B, 255									; 256 colors (loop counter), palette has 512 bytes, but we read two bytes in one iteration
.loop:
	
	; - Two consecutive writes are needed to write the 9 bit colour:
	; - 1st write: bits 7-0 = RRRGGGBB
	; - 2nd write: bits 7-1 = 0, bit 0 = LSB B

	; 1st write
	LD A, (HL)
	INC HL
	NEXTREG _DC_REG_LA2_PAL_VAL_H44, A

	; 2nd write
	LD A, (HL)
	NEXTREG _DC_REG_LA2_PAL_VAL_H44, A
	INC HL		
	DJNZ .loop

	RET

;----------------------------------------------------------;
;                  #SetupTilemapPalette                    ;
;----------------------------------------------------------;
; Input:
; - B:		Number of colors to copy
; - HL:		Address of layer 2 palette data 
SetupTilemapPalette
	NEXTREG _DC_REG_TILE_TRANSP_H4C, $00		; Black for tilemap transparency

	; Bits
	;  - 0: 1 = Enabe ULANext mode
	;  - 1-3: 0 = First palette 
	;  - 6-4: 011 = Tilemap first palette
	;  - 7: 0 = enable autoincrement on write
	NEXTREG _DC_REG_LA2_PAL_CTR_H43, %0'011'0'0'0'1 
	NEXTREG _DC_REG_LA2_PAL_IDX_H40, 0			; Start with color index 0

	; Copy 8 bit palette
.loop
	LD A, (HL)									; Load RRRGGGBB into A
	INC HL										; Increment to next entry
	NEXTREG _DC_REG_LA2_PAL_VAL_H41, A			; Send entry to Next HW
	DJNZ .loop									; Repeat until B=0

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
;                   #ShakeScreen                           ;
;----------------------------------------------------------;
ShakeScreen
	LD A, (cd.counter4)
	CP 0
	RET NZ										; Return if counter to 5 did not reset	

	LD A, (cd.counter4FliFLop)					; Oscilates beetwen 1 and 0
	LD D, A
	LD e, SHAKE_SCREEN_BY
	MUL D, E
	LD A, E
	NEXTREG _DC_REG_TILE_X_LSB_H30, A

	RET		

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE