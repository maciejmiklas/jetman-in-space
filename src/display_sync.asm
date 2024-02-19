;----------------------------------------------------------;
;               Scanline Synchronization                   ;
;----------------------------------------------------------;
; Based on: https://github.com/robgmoran/DougieDoSource

WaitForScanlineUnderUla:
; Sync the main game loop by waiting for particular scanline under the ULA paper area, i.e. scanline 192
     
; Update the TotalFrames counter by +1
.UpdateTotalFrames:
	LD HL, (TotalFrames)
	INC HL
	LD (TotalFrames), HL

; if HL=0, increment upper 16bit too
; Cannot compare a word (hl) therefore need to compare both h & l together
	LD A,H
	or L
    JR NZ,.totalFramesUpdated
	LD HL,(TotalFrames+2)
	INC HL
	LD (TotalFrames+2), HL

.totalFramesUpdated:
; read NextReg $1F - LSB of current raster line
	LD BC,$243B        ; TBBlue Register Select
	LD A,$1F           ; Port to access - Active Video Line LSB Register
	OUT (C),A           ; Select NextReg $1F
	INC B               ; TBBlue Register Access

; If already at scanline 192, then wait extra whole frame (for super-fast game loops)
.cantStartAtScanLine:
	LD A, 192
	LD D,A
	IN A,(C)       ; read the raster line LSB
	CP D
	JR Z,.cantStartAtScanLine

; If not yet at scanline, wait for it ... wait for it ...
.waitLoop:
	IN A,(C)       ; read the raster line LSB
	CP D
	JR NZ,.waitLoop
; and because the max scanline number is between 260..319 (depends on video mode),
; I don't need to read MSB. 256+192 = 448 -> such scanline is not part of any mode.

	RET