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
;  - B:  Amount of banks occupied by the image. 320x256 has 10, 256x192 has 6, 256x128 has 4
;  - D:  Start bank containing background image source
;  - HL: Address of layer 2 palette data
LoadLevel2Image
	
	PUSH BC

	; Setup layer 2 palette
	NEXTREG _MMU_REG_SLOT6_H56, _CF_BIN_BGR_PAL_BANK ; Memory bank (8KiB) containing layer 2 palette data
	CALL sc.SetupLayer2Palette

	; ##########################################
	; Copy image data from temp RAM into screen memory
	POP BC
	LD E, _CF_BIN_BGR_ST_BANK					; Destination bank where layer 2 image is expected. See "NEXTREG _DC_REG_L2_BANK_H12 ...."

.slotLoop										; Image has 320x256 and occupies 10 banks, each loop copies single bank
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
