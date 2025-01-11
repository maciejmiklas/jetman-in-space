;----------------------------------------------------------;
;                   Bitmap Manipulation                    ;
;----------------------------------------------------------;
	MODULE bm

;----------------------------------------------------------;
;                    #BrightnessDown                       ;
;----------------------------------------------------------;
; Input
;  - DE: Contains 9-bit color. D = xxxxxxx'B, E = RRR'BBB'GG
; Output:
;  - DE: Given color with decremented brightness.
BrightnessDown

	; Decrement red color (RRR'xxx'xx)
	LD A, E
	AND _BM_PAL_RRR_MASK						; Reset all bits but red.

	CP 0										; Do not decrement if red is already at 0.
	JR Z, .afterDecrementRed

	; Red is above 0, decrement it.
	SUB _BM_PAL_RRR_INC

	; Update orginal color in DE
	LD B, A										; Keep A in B, A contains new RRR value.

	LD A, E										; Load RRR'GGG'BB into A and reset RRR, because we will set it to new value with XOR.
	AND _BM_PAL_RRR_MASKN
	XOR B										; Set new RRR value to E.
	LD E, A										; Update orginal input/return value.

.afterDecrementRed

	; ##########################################
	; Decrement green color (xxx'GGG'xxx)

	LD A, E
	AND _BM_PAL_GGG_MASK						; Reset all bits but green.

	CP 0										; Do not decrement if green is already at 0.
	JR Z, .afterDecrementGreen

	; Green is above 0, decrement it.
	SUB _BM_PAL_GGG_INC

	; Update orginal color in DE.
	LD B, A										; Keep A in B, A contains new GGG value.

	LD A, E										; Load RRR'GGG'BB into A and reset GGG, because we will set it to new value with XOR.
	AND _BM_PAL_GGG_MASKN
	XOR B										; Set new GGG value to E.
	LD E, A										; Update orginal input/return value.
.afterDecrementGreen	

	; ##########################################
	; Decrement blue color part 1: xxx'xxx'BB

.beforeDecrementBB
	; Try decrementing the first byte: xxx'xxx'BB
	LD A, E
	AND _BM_PAL_BB_MASK							; Reset all bits but blue.

	CP 0										; Do not decrement if blue is already at 0
	JR Z, .afterDecrementBB

	; Blue is above 0, decrement it.
	DEC A

	; Update orginal color in DE.
	LD B, A										; Keep A in B, A contains new BB value.

	LD A, E										; Load RRR'GGG'BB into A and reset BB, because we will set it to new value with XOR.
	AND _BM_PAL_BB_MASKN
	XOR B										; Set new GGG value to E.
	LD E, A										; Update orginal input/return value.
	JR .afterDecrementB							; Do not decrement B if BB was decremented.
.afterDecrementBB

	; ##########################################
	; Decrement blue color part 2: B'0000000. Decrement B only if BB is already 0 and B is 1.

	; Check
	LD A, E
	AND _BM_PAL_BB_MASK							; Reset all bits but blue.

	; Check if BB is 0
	CP 0										; Do not decrement B if BB > 0
	JR NZ, .afterDecrementB

	; BB == 0, but is B > 0 ?
	LD A, D
	CP 0
	JR Z, .afterDecrementB						; Jump if A (and also D) is already 0

	; B is 1, reset it and set BB to 11. 
	XOR A
	LD D, A										; D is 0

	; Set BB to 11
	LD A, E
	XOR _BM_PAL_BB_MASK							; BB is 00 -> 00 XOR 11 = 11
	LD E, A	
.afterDecrementB

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                 #CopyPalleteToTmp                        ;
;----------------------------------------------------------;
; Input:
;  - BC: Sieze of the pallete in bytes.
;  - HL: Address of layer 2 palette data. Must be in slot 6 ($C000-$DFFF).
CopyPalleteToTmp

	CALL SetupPaletteBank
	
	LD DE, db.backgroundTmpPalette				; Destination
	LDIR

	RET											; ## END of the function ##

;----------------------------------------------------------;
;               #PaletteBrightnessDown                     ;
;----------------------------------------------------------;
; Decreases brightness of each color in #backgroundTmpPalette and loads it. Call #CopyPalleteToTmp to setup tmep.
; Input:
;  - B:  Sieze of the pallete in bytes.
PaletteBrightnessDown

	CALL SetupPaletteLoad
	
	; ##########################################
	; Copy 9 bit (2 bytes per color) palette. Nubmer of colors is giveb by B (method param).
	LD HL, db.backgroundTmpPalette
.loopCopyColor:
	
	; ##########################################
	; Decrease the brightness of the current color.
	PUSH BC
	LD DE, (HL)
	CALL BrightnessDown							; DE contains color.
	LD (HL), DE									; Update temp color.
	POP BC

	; - Two consecutive writes are needed to write the 9 bit colour:
	; - 1st write: bits 7-0 = RRRGGGBB
	; - 2nd write: bits 7-1 = 0, bit 0 = LSB B

	; 1st write
	LD A, E
	INC HL
	NEXTREG _DC_REG_LA2_PAL_VAL_H44, A

	; 2nd write
	LD A, D
	
	NEXTREG _DC_REG_LA2_PAL_VAL_H44, A
	INC HL		
	DJNZ .loopCopyColor

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                   #SetupPaletteLoad                      ;
;----------------------------------------------------------;
SetupPaletteLoad

	; Setup palette that is going to be written, bits:
	;  - 0:   0 = Disable ULANext mode
	;  - 1-3: 0 = First palette 
	;  - 6-4: 001 = Write layer 2 first palette
	;  - 7:   0 = enable palette write auto-increment for _DC_REG_LA2_PAL_VAL_H44
	NEXTREG _DC_REG_LA2_PAL_CTR_H43, %0'001'000'1 

	NEXTREG _DC_REG_LA2_PAL_IDX_H40, 0			; Start writing the palette from the first color, we will replace all 256 colors.
		
	CALL SetupPaletteBank

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                   #SetupPaletteBank                      ;
;----------------------------------------------------------;
SetupPaletteBank

	; Memory bank (8KiB) containing layer 2 palette data.
	NEXTREG _MMU_REG_SLOT6_H56, _BN_BG_PAL_BANK_D46
	
	RET											; ## END of the function ##
;----------------------------------------------------------;
;                  #LoadLayer2Palette                      ;
;----------------------------------------------------------;
; Input:
;  - B:  Sieze of the pallete in bytes.
;  - HL: Address of layer 2 palette data. Must be in slot 6 ($C000-$DFFF).
LoadLayer2Palette

	CALL SetupPaletteLoad
	; ##########################################
	; Copy 9 bit (2 bytes per color) palette. Nubmer of colors is giveb by B (method param).
.loopCopyColor:
	
	; - Two consecutive writes are needed to write the 9 bit colour:
	; - 1st write: bits 7-0 = RRRGGGBB,
	; - 2nd write: bits 7-1 = 0, bit 0 = LSB B.

	; 1st write
	LD A, (HL)
	INC HL
	NEXTREG _DC_REG_LA2_PAL_VAL_H44, A

	; 2nd write
	LD A, (HL)
	NEXTREG _DC_REG_LA2_PAL_VAL_H44, A
	INC HL		
	DJNZ .loopCopyColor

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #FillLayer2Palette                      ;
;----------------------------------------------------------;
; Fill the remaining colors with transparent.
; Input:
;  - B:  Sieze of the pallete in bytes.
FillLayer2Palette

	; We copied the number of colors given by B, but we had to copy 256 colors (512 bytes). 
	LD A, _BM_PAL_COLORS_D255
	SUB B
	LD B, A										; B contains the number of colors that must be filled to complete 256.
	
	LD A, _COL_TRANSPARENT_D0					; Fill remaining colors with transparent
.loopFillBlank:

	NEXTREG _DC_REG_LA2_PAL_VAL_H44, A			; 1st write
	NEXTREG _DC_REG_LA2_PAL_VAL_H44, A			; 2nd write

	DJNZ .loopFillBlank

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                    #LoadLevel2Image                      ;
;----------------------------------------------------------;
; Copies data from slots 6 to 7. Slot 6 points to the bank containing the source of the image, and slot 7 points to the bank that contains 
; display data (NEXTREG _DC_REG_L2_BANK_H12).
; Input:
;  - D:  Start bank containing background image source
LoadLevel2Image
	
	; Copy image data from temp RAM into screen memory
	NEXTREG _DC_REG_L2_BANK_H12, _BM_16KBANK_D9 ; Layer 2 image (background) starts at 16k-bank 9 (default).
	LD E, _BN_BG_ST_BANK_D18					; Destination bank where layer 2 image is expected. See "NEXTREG _DC_REG_L2_BANK_H12 ....".
	LD B, _BM_BANKS_D10							; Amount of banks occupied by the image. 320x256 has 10, 256x192 has 6, 256x128 has 4.
.slotLoop										; Each loop copies single bank, there are 10 iterations.
	PUSH BC
	LD A, D
	NEXTREG _MMU_REG_SLOT6_H56, A				; Read from.

	LD A, E
	NEXTREG _MMU_REG_SLOT7_H57, A				; Write to.

	PUSH DE
	LD HL, _RAM_SLOT6_START_HC000				; Source
	LD DE, _RAM_SLOT7_START_HE000				; Destination
	LD BC, _BANK_BYTES_D8192
	LDIR
	POP DE

	INC D										; Next bank.
	INC E										; Next bank.
	
	POP BC
	DJNZ .slotLoop

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                   #HideImageLine                         ;
;----------------------------------------------------------;
; Replaces line of the image with transparent color.
; Input:
;  - E:  Line number
HideImageLine

	LD B, _BM_BANKS_D10
.bankLoop										; Loop from 10 (_BM_BANKS_D10) to 0.

	; We will iterate over 10 banks ascending from _BN_BG_ST_BANK_D18 to _BN_BG_END_BANK_D27.
	; However, the loop starts at 10 (inclusive) and goes to 0 (exclusive)
	LD A, _BN_BG_END_BANK_D27 + 1				; 27 + 1 - 10 = 18 -> _BN_BG_END_BANK_D27 + 1 - _BM_BANKS_D10 = _BN_BG_ST_BANK_D18
	SUB B
	NEXTREG _MMU_REG_SLOT7_H57, A				; Use slot 7 to modify dispalyed image.

	; Each bank contains lines, each having 256 bytes/pixels. To draw the horizontal line at pixel 12 (y position from the top of the picture),
	; we have to set byte 12, then 12+256, 12+(256*2), 12+(256*3), and so on.
	LD HL, _RAM_SLOT7_START_HE000
	LD D, 0										; E contains the line number, reset only D to use DE for 16-bit math.
	ADD HL, DE									; HL poits at line that will be replaced.

	; ##########################################
	; Iterate over each picture line in the current bank. Each bank has 8*1024/256=32 lines.
	PUSH BC

	LD B, _BANK_BYTES_D8192/_BM_YRES_D256		; 8*1024/256=32
.linesLoop
	LD (HL), _COL_TRANSPARENT_D0
	ADD HL, _BM_YRES_D256						; Move DE to the next pixel to the right by adding 256 pixels.

	DJNZ .linesLoop
	POP BC
	
	DJNZ .bankLoop

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                 #ReplaceImageLine                        ;
;----------------------------------------------------------;
; Replaces the line of the displayed layer 2 image with the corresponding line of the given image.
; Input:
;  - C:  The first bank of the source image from which the given line will be taken.
;  - E:  Line number.
ReplaceImageLine

	LD B, 0
.bankLoop										; Loop from 0 to _BM_BANKS_D10 - 1.
	
	; ##########################################
	; Setup banks. The source image will be stored in bank 6, destination image in bank 7. We will copy line from 6 to 7.

	; Setup slot 6 with source.
	LD A, C
	ADD B										; A points to current bank from the soure image.
	NEXTREG _MMU_REG_SLOT6_H56, A				; Slot 6 contains source of the image.
	
	; Setup slot 7 with destination.
	LD A, _BN_BG_ST_BANK_D18
	ADD B										; A points to current bank of the source image.
	NEXTREG _MMU_REG_SLOT7_H57, A				; Use slot 7 to modify dispalyed image.

	; ##########################################
	; Copy line from source to destination image.  Iterate over each picture line's pixel in current bank. Each bank has 8*1024/256=32 lines.
	PUSH BC

	LD B, _BANK_BYTES_D8192/_BM_YRES_D256		; 8*1024/256=32
	LD D, 0										; E contains the line number, reset only D to use DE for 16-bit math.
.linesLoop

	; Copy a pixel from the source image into C.
	LD HL, _RAM_SLOT6_START_HC000
	ADD HL, DE									; Move DE from the beginning of the bank to the current pixel.
	LD C, (HL)									; C contains pixel value.
	
	; Copy pixel value from C into the destination image.
	LD HL, _RAM_SLOT7_START_HE000
	ADD HL, DE									; Move DE from the beginning of the bank to the current pixel.
	LD (HL), C									; Store pixel value.

	ADD DE, _BM_YRES_D256						; Move DE to the next pixel to the right by adding 256 pixels.

	DJNZ .linesLoop
	POP BC
	
	; ##########################################
	; Loop from 0 to _BM_BANKS_D10 - 1.
	LD A, B
	INC A
	LD B, A
	CP _BM_BANKS_D10
	JR NZ, .bankLoop

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE
