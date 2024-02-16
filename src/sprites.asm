; Loads 
LoadSprites:
	LD (.dmaSource), HL						; Copy sprite sheet address from HL
	LD (.dmaLength), BC						; Copy length in bytes from BC
	LD BC, $303B							; Prepare port for sprite index
	OUT (C), A								; Load index of first sprite
	LD HL, .dmaProgram						; Setup source for OTIR
	LD B, .dmaProgramLength 				; Setup length for OTIR
	LD C, $6B								; Setup DMA port
	OTIR									; Invoke DMA code
	RET

.dmaProgram:
	DB %10000011							; WR6 - Disable DMA
	DB %01111101							; WR0 - append length + port A address, A->B

.dmaSource:
	DW 0									; WR0 par 1&2 - port A start address

.dmaLength:
	DW 0									; WR0 par 3&4 - transfer length
	DB %00010100							; WR1 - A incr., A=memory
	DB %00101000							; WR2 - B fixed, B=I/O
	DB %10101101							; WR4 - continuous, append port B address
	DW $005B								; WR4 par 1&2 - port B address
	DB %10000010							; WR5 - stop on end of block, CE only
	DB %11001111							; WR6 - load addresses into DMA counters
	DB %10000111							; WR6 - enable DMA
.dmaProgramLength = $-.dmaProgram

sprites:
	INCBIN "assets/sprites.spr"

ShowSprites:	
	LD HL, sprites							; Sprites data source
	LD BC, 16*16*5							; Copy 5 sprites, each 16x16 pixels
	LD A, 0									; Start with first sprite
	CALL LoadSprites						; Load sprites to Hardware

	NEXTREG SPR_SETUP, %01000011			; Sprite 0 on top, SLU, sprites visible

	NEXTREG SPR_NR, SPR_JETMAN_ID			; Player

	LD A, (JetX)							; Set player X position
	NEXTREG SPR_X, A						

	LD A, (JetY)							; Set player Y position
	NEXTREG SPR_Y, A						

	NEXTREG SPR_ATTR_2, %00000000 			; Palette offset, no mirror, no rotation
	NEXTREG SPR_ATTR_3, %10000000			; Visible, no byte 4, pattern 0

	;NEXTREG SPR_NR, 1
	;NEXTREG SPR_X, 50 
	;NEXTREG SPR_Y, 80 
	;NEXTREG SPR_ATTR_2, %00000000 
	;NEXTREG SPR_ATTR_3, %10000000

	;NEXTREG SPR_NR, 2
	;NEXTREG SPR_X, 250 
	;NEXTREG SPR_Y, 250 
	;NEXTREG SPR_ATTR_2, %00000000 
	;NEXTREG SPR_ATTR_3, %10000000

	RET