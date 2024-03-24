;----------------------------------------------------------;
;                     #LoadSpritesFPGA                     ;
;----------------------------------------------------------;
; Loads sprites from file into hardware using DMA.
;
; Method Parameters:
;    - HL - RAM address containing sprite binary data.
;    - BC - Number of bytes to copy, i.e. 4 sprites 16x16: "LD BC, 16*16*4".
LoadSpritesFPGA:
	; Store dynamic values into DMA program
	LD (spriteDMAPortA), HL						; Copy sprite sheet address from HL
	LD (spriteDMADataLength), BC				; Copy sprite file lenght into WR0

	; Execute DMA program
	LD HL, spriteDMAProgram						; Setup source for OTIR
	LD B, spriteDMAProgramLength 				; Setup length for OTIR
	LD C, DMA_PORT_H6B							; Setup DMA port
	OTIR										; Upload DMA program and execute

; DMA  is a program that executes in hardware. This program consists of a series of commands from WR0 to WR6. 
; Each command is a single byte with a unique signature given by setting a few bits:
; - WR0: $0'xxxxx'01
; - WR1: $0'xxxx'100
; - WR2: $0'xxxx'000
; - WR3: $1'xxxxx'00
; - WR4: $1'xxxxx'01
; - WR5: $1'xxxxx'10
; - WR6: $1'xxxxx'11
;           "xxxx" bits carry data for the DMA command
;
; Some commands can have additional parameters, as they do not fit into a single byte. In such cases, the command byte is 
; followed by a few parameter bytes, like WR0: DB %0'11111'01 -> DW $C000 -> DW 2048. 
; It is the reason for a few labels within the DMA program so that we can inject dynamic data.
; Finally OTIR uploads the DMA program to memory through port $xx6B, and it executes.
;
; More Info: https://wiki.specnext.dev/DMA
spriteDMAProgram:
	DB %1'00000'11								; WR6: Disable DMA (last command will re-enable it)

	; WR0 - Direction, Operation, Port A Configuration:
	;  - D2 = 1 -> Port A is source, port B destination
	;  - D4,D3 = 11 -> Port A address is a byte that directly follows DW0 byte
	;  - D6,D5 = 11 -> The number of bytes to be copied by DMA is 16-bit and directly follows the Port A address
	; DW0 consists of 4 bytes: DW0 -> A address -> data length (LSB) -> data lenght (MSB)
	DB %0'11111'01

spriteDMAPortA:
	DW 0										; WR0 parameter pointing to RAM containing sprite data

spriteDMADataLength:										
	DW 0										; WR0 parameter defining a amount of bytes for sprite data

	; WR1 - Port A configuration.
	;   - D3 = 0 -> Port A is memory
	;   - D5,D4 = 01 -> Port A address increments
	DB %0'0010'100

	; WR2 - Port B configuration.
	;   - D3 = 1 -> Port B is IO (FPGA Sprite Hardware)
	;   - D5 = 0 -> Port B address is fixed
	DB %0'0101'000								; WR2 - B fixed, B=I/O

	; WR4 - Port B, Timing, Interrupt Control
	DB %1'01011'01								; WR4 - continuous mode, append port B address
	DW $005B									; 16-bit port B starting address

	; WR5 - Ready and stop configuration
	;   - D4 = 0 -> CE only (the only option anyway)
	;   - D5 = 0 -> Stop operation on end of block
	DB %1'00000'10							

	; WR6 - Command register
	;   - D6,D5,D4,D3,D2 = 10011 -> LOAD command, to start copy from A to B
	DB %1'10011'11
	DB %1'00001'11								; Again WR6, now enable DMA and copy!

spriteDMAProgramLength = $ - spriteDMAProgram	

	RET											; END LoadSpritesFPGA

;----------------------------------------------------------;
;                    #AnimateSprites                       ;
;----------------------------------------------------------;
ANIM_FR				= 5						; Change sprite pattern every few frames     
frameCnt			BYTE 0						; The animation counter is used to update the sprite pattern every few FP

AnimateSprites:
	LD A, (frameCnt)
	INC A
	LD (frameCnt), A							

	CP ANIM_FR								
	RET C										; Return if #frameCnt <  #ANIM_FR

	LD A, 0										; #frameCnt == #ANIM_FR -> reset counter and update the animation pattern
	LD (frameCnt), A

	; Update sprite patterns
	CALL UpdateJetmanSpritePattern

	RET											; END AnimateSprites	