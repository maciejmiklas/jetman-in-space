;----------------------------------------------------------;
;                        Globals                           ;
;----------------------------------------------------------;
DI_X_MIN_POS			= 0
DI_X_MAX_POS			= 315
DI_Y_MIN_POS			= 1
DI_Y_MAX_POS			= 240

;----------------------------------------------------------;
;                     #SetupScreen                         ;
;----------------------------------------------------------;
SetupScreen:

	; Sprite and Layers system
;  - 7: LoRes mode, 128 x 96 x 256 colours (1 = enabled)
;  - 6: Sprite priority (1 = sprite 0 on top, 0 = sprite 127 on top)
;  - 5: Enable sprite clipping in over border mode (1 = enabled)
;  - 4-2: set layers priorities:
;   Reset default is 000, sprites over the Layer 2, over the ULA graphics:
;    - 000: S L U
;    - 001: L S U
;    - 010: S U L - (Top - Sprites, Enhanced_ULA, Layer 2)
;    - 011: L U S
;    - 100: U S L
;    - 101: U L S
;    - 110: S(U+L) ULA and Layer 2 combined, colours clamped to 7
;    - 111: S(U+L-5) ULA and Layer 2 combined, colours clamped to [0,7]
;  - 1: Over border (1 = yes)(Back to 0 after a reset)
;  - 0: Sprites visible (1 = visible)(Back to 0 after a reset)


	NEXTREG SPR_REG_SETUP_H15, %010000011 		; Sprite 0 on top, SLU, over border, sprites visible	
//	NEXTREG DC_REG_CONTROL_1_H69, %11000000  	; Layer 2 screen resolution 256 x 192 x 8bpp

	CALL ROM_CLS_H0DAF							; Clear screen

//	LD A, COL_YELLOW							; Set the border color
//	OUT	(BORDER_IO), A
/*
	; ### Set screen color ###
	LD HL, DI_COLOR_START_H5800					; Load into HL beginning address of color RAM, we will iterate over it
	LD BC, 0									; Counter for iteration over color memory, from 0 to 768
	LD D, COL_GREEN								; Color to be set
.loop
	LD (HL), D									; Set color for current 
	INC HL										; Set the color for the current position of color memory
	INC BC										; Increment BC
	LD A, B										; 768 is $0300 -> B=03, C=00
	CP $03										; We have filled whole color memory when B is at 03
	JP NZ, .loop								; Keep looping untill whole color memory is set
*/
	RET											; END SetupScreen

;----------------------------------------------------------;
;                     #WaitOneFrame                        ;
;----------------------------------------------------------;
; Pauses executing for single frame, 1/60 or 1/50 of a second.
;
; The code waits for the given scanline (192) in the first loop, and then in the second loop, it waits again for the same scanline (192). 
; This method pauses for the whole frame or a bit more, depending on which scanline display is when calling "WaitOneFrame".
; 
; Based on: https://github.com/robgmoran/DougieDoSource

WaitOneFrame:     
; Read NextReg $1F - LSB of current raster line
	LD BC, GL_REG_SELECT_H243B					; TBBlue Register Select
	LD A, GL_REG_VL_H1F							; Port to access - Active Video Line LSB Register
	OUT (C), A									; Select NextReg $1F
	INC B										; TBBlue Register Access
	LD A, DI_SYNC_SL							; Set Scanline to wait for
	LD D, A

; Wait for Scanline given by param H, i.e. 192
.waitForScanline:
	IN A, (C)									; Read the raster line LSB into A
	CP D
	JR Z, .waitForScanline						; Keep looping until Scanline changes from given to next, 192->193

; Now we are past 192 -> on 193

; Wait the whole frame again for given Scanline (192)
.waitAgainForScanline:
	IN A, (C)									; Read the raster line LSB into A
	CP D
	JR NZ, .waitAgainForScanline

	RET											; END WaitOneFrame
