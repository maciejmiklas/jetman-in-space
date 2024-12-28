;----------------------------------------------------------;
;                   Bitmap Manipulation                    ;
;----------------------------------------------------------;
	MODULE bm

;----------------------------------------------------------;
;                    #FillLevel2Image                      ;
;----------------------------------------------------------;
; Fill last two banks of layer 2 image with transparent color
FillLevel2Image

	NEXTREG _MMU_REG_SLOT7_H57, _CF_BIN_BGR_END_BANK-1
	LD HL, _RAM_SLOT7_START_HE000				; Start address of bank in slot 6
	LD D, _COL_TRANSPARENT
	CALL ut.FillBank

	NEXTREG _MMU_REG_SLOT7_H57, _CF_BIN_BGR_END_BANK
	LD HL, _RAM_SLOT7_START_HE000				; Start address of bank in slot 6
	LD D, _COL_TRANSPARENT
	CALL ut.FillBank

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                    #LoadLevel2Image                      ;
;----------------------------------------------------------;
; Copies data from slots 6 to 7. Slot 6 points to the bank containing the source of the image, and slot 7 points to the bank that contains 
; display data (NEXTREG _DC_REG_L2_BANK_H12)
; Input:
;  - D:  Start bank containing background image source
;  - HL: Address of layer 2 palette data. Must be in slot 6 ($C000-$DFFF)
LoadLevel2Image
	
	; Setup layer 2 palette
	CALL LoadLayer2Palette

	; ##########################################
	; Copy image data from temp RAM into screen memory
	NEXTREG _DC_REG_L2_BANK_H12, _CF_BM_16KBANK ; Layer 2 image (background) starts at 16k-bank 9 (default)
	LD E, _CF_BIN_BGR_ST_BANK					; Destination bank where layer 2 image is expected. See "NEXTREG _DC_REG_L2_BANK_H12 ...."
	LD B, _CF_BM_BANKS							; Amount of banks occupied by the image. 320x256 has 10, 256x192 has 6, 256x128 has 4
.slotLoop										; Each loop copies single bank, there are 10 iterations
	PUSH BC
	LD A, D
	NEXTREG _MMU_REG_SLOT6_H56, A				; Read from

	LD A, E
	NEXTREG _MMU_REG_SLOT7_H57, A				; Write to

	PUSH DE
	LD HL, _RAM_SLOT6_START_HC000				; Source
	LD DE, _RAM_SLOT7_START_HE000				; Destination
	LD BC, _CF_BANK_BYTES
	LDIR
	POP DE

	INC D										; Next bank
	INC E										; Next bank
	
	POP BC
	DJNZ .slotLoop

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #LoadLayer2Palette                      ;
;----------------------------------------------------------;
; Input:
;  - HL: Address of layer 2 palette data. Must be in slot 6 ($C000-$DFFF)
; Modifies: A,B,HL
LoadLayer2Palette

	; Setup palette that is going to be written, bits:
	;  - 0:   1 = Enabe ULANext mode
	;  - 1-3: 0 = First palette 
	;  - 6-4: 001 = Write layer 2 first palette
	;  - 7:   1 = disable palette write auto-increment
	NEXTREG _DC_REG_LA2_PAL_CTR_H43, %0'001'0'0'0'1 
	NEXTREG _DC_REG_LA2_PAL_IDX_H40, 0			; Palette starts with color index 0

	; Memory bank (8KiB) containing layer 2 palette data
	NEXTREG _MMU_REG_SLOT6_H56, _CF_BIN_BGR_PAL_BANK

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

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                 #SetupLayer2Palette                      ;
;----------------------------------------------------------;
; Input:
; - HL:		Address of layer 2 palette data
; Modifies: A,B,HL
SetupLayer2Palette

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

	RET											; ## END of the function ##


tmp byte 0
;----------------------------------------------------------;
;                   #ReplaceImageLine                      ;
;----------------------------------------------------------;
; Input:
;  - E:  Line number
ReplaceImageLine

	LD A, E
	LD (tmp), A

	; ##########################################
	LD B, _CF_BM_BANKS
.bankLoop
	LD A, _CF_BIN_BGR_L1_ST_BANK - 1
	ADD B
	NEXTREG _MMU_REG_SLOT7_H57, A

	LD HL, _RAM_SLOT7_START_HE000
	LD D, 0
	ADD HL, DE

	; ##########################################
	PUSH BC

	LD B, 32
.linesLoop
	LD (HL), 10
	ADD HL, 256
	DJNZ .linesLoop
	POP BC
	
	DJNZ .bankLoop

	RET											; ## END of the function ##
;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE
