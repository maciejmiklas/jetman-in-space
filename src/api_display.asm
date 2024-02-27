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
	LD BC, REG_SELECT						; TBBlue Register Select
	LD A, REG_VL							; Port to access - Active Video Line LSB Register
	OUT (C), A								; Select NextReg $1F
	INC B									; TBBlue Register Access
	LD A, DI_SYNC_SL						; Set Scanline to wait for
	LD D, A

; Wait for Scanline given by param H, i.e. 192
.waitForScanline:
	IN A, (C)								; Read the raster line LSB into A
	CP D
	JR Z, .waitForScanline					; Keep looping until Scanline changes from given to next, 192->193

; Now we are past 192 -> on 193

; Wait the whole frame again for given Scanline (192)
.waitAgainForScanline:
	IN A, (C)								; Read the raster line LSB into A
	CP D
	JR NZ, .waitAgainForScanline
	RET

;----------------------------------------------------------;
;                     #ClearScreen                         ;
;----------------------------------------------------------;
ClearScreen:
	CALL ROM_CLS							; Clear screen

	LD A, COL_YELLOW						; Set the border color
	OUT	(BORDER_IO), A

	; Set screen color
	LD HL, DI_COL_ST						; Load into HL beginning address of color RAM, we will iterate over it
	LD BC, 0								; Counter for iteration over color memory, from 0 to 768
	LD D, COL_BLACK							; Color to be set
.loop
	LD (HL), D								; Set color for current 
	INC HL									; Set the color for the current position of color memory
	INC BC									; Increment BC
	LD A, B									; 768 is $0300 -> B=03, C=00
	CP $03									; We have filled whole color memory when B is at 03
	JP NZ, .loop							; Keep looping untill whole color memory is set
	RET