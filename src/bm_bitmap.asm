;----------------------------------------------------------;
;                   Bitmap Manipulation                    ;
;----------------------------------------------------------;
	MODULE bm

brL2PaletteAddr 		WORD 0					; Pointer to current brightness palette.

;----------------------------------------------------------;
;                    #BrightnessDown                       ;
;----------------------------------------------------------;
; Input
;  - DE: Contains 9-bit color. D = xxxxxxx'B, E = RRR'GGG'BB
; Output:
;  - DE: Given color with decremented brightness.
BrightnessDown

	; ##########################################
	; Decrement red color (RRR'xxx'xx)
	LD A, E
	AND _BM_PAL2_RRR_MASK						; Reset all bits but red.

	CP _BM_PAL2_MIN								; Do not decrement if red is already at 0.
	JR Z, .afterDecrementRed

	; Red is above 0, decrement it.
	SUB _BM_PAL2_RRR_INC

	; Update orginal color in DE
	LD B, A										; Keep A in B, A contains new RRR value.

	LD A, E										; Load RRR'GGG'BB into A and reset RRR, because we will set it to new value with XOR.
	AND _BM_PAL2_RRR_MASKN
	XOR B										; Set new RRR value to E.
	LD E, A										; Update orginal input/return value.

.afterDecrementRed

	; ##########################################
	; Decrement green color (xxx'GGG'xxx)

	LD A, E
	AND _BM_PAL2_GGG_MASK						; Reset all bits but green.

	CP _BM_PAL2_MIN								; Do not decrement if green is already at 0.
	JR Z, .afterDecrementGreen

	; Green is above 0, decrement it.
	SUB _BM_PAL2_GGG_INC 

	; Update orginal color in DE.
	LD B, A										; Keep A in B, A contains new GGG value.

	LD A, E										; Load RRR'GGG'BB into A and reset GGG, because we will set it to new value with XOR.
	AND _BM_PAL2_GGG_MASKN
	XOR B										; Set new GGG value to E.
	LD E, A										; Update orginal input/return value.

.afterDecrementGreen	

	; ##########################################
	; Decrement blue color part 1: E: xxx'xxx'BB D: B'xxxxxxx

	; Prepare BBB for decrement oparation: xxx'xxx'BB B'xxxxxxx -> 00000BBB
	LD A, E
	AND _BM_PAL2_BB_MASK							; A contains 000'000'BB.
	RL D										; Rotate left D, if B'xxxxxxx is set, it will set CF.
	RLA											; Rotale left A. It will set CF from the previous operation on bit 0: 000000'BB -> 00000'BB'CF.

	; Ensure that BBB is > 0 before decreasing it.
	CP _BM_PAL2_MIN
	JR Z, .afterDecrementBlue

	DEC A										; Decrement BBB.

	; Apply new BBB value to orginal DE.
	RRA											; 00000'BBB -> 000000'BB -> CF
	RR D										; 00000000 -> CF'0000000 -> D now contains proper value.

	LD B, A										; Backup A containing BB.
	LD A, E
	AND _BM_PAL2_BB_MASKN						; Load RRR'GGG'BB into A and reset BB, because we will set it to new value with XOR.
	XOR B
	LD E, A
.afterDecrementBlue	

	RET											; ## END of the function ##

;----------------------------------------------------------;
;               #InitPaletteBrightness                     ;
;----------------------------------------------------------;
; Copies first palette to #brL2Palette and resets #brL2PaletteAddr
; Input:
;  - BC: Sieze of the pallete in bytes.
;  - HL: Address of layer 2 palette data to be copied into #brL2Palette. Must be in slot 6 ($C000-$DFFF).
InitPaletteBrightness

	CALL SetupPaletteBank
	
	LD DE, dbi.brL2Palette						; Destination
	LD (brL2PaletteAddr), DE					; Reset palette pointer.
	LDIR

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                     #BytesToColors                       ;
;----------------------------------------------------------;
; Input:
;  - BC: Sieze of the pallete in bytes.
; Output:
;  - B: Number of colors.
BytesToColors
	
	; Divide BC by 2 - two bytes carry one color
	SRL B										; Shift the higher byte (B) right by 1 bit
	RR C										; Rotate right through carry the lower byte (C)

	; Now BC contains max 255, becaue we have 512 colors
	LD B, C

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #PaletteBrightnessUp                    ;
;----------------------------------------------------------;
; Input
;  - BC:  Sieze of the pallete in bytes.
PaletteBrightnessUp

	; Moves #brL2PaletteAddr to the previous palette
	LD HL, (brL2PaletteAddr)
	LD DE, HL
	ADD DE, -_BM_PAL2_BYTES_D512
	LD (brL2PaletteAddr), DE

	; ##########################################
	; Load colors
	CALL BytesToColors							; BC contains color size in bytes, we need number of colors in B.
.loopCopyColor
	LD DE, (HL)

	CALL WriteColor
	INC HL
	INC HL
	DJNZ .loopCopyColor

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                 #PaletteBrightnessDown                   ;
;----------------------------------------------------------;
; Input:
;  - BC:  Sieze of the pallete in bytes.
PaletteBrightnessDown

	CALL DecrementPaletteColors
	CALL bm.NextBrightnessPalette

	RET											; ## END of the function ##

;----------------------------------------------------------;
;              #NextBrightnessPalette                      ;
;----------------------------------------------------------;
; Moves #brL2PaletteAddr to the next palette and copies the previous palette there. Once this is done, the colors in the created palette 
; can be changed by #DecrementPaletteColors.
NextBrightnessPalette

	; Moves #brL2PaletteAddr to the next palette 
	LD HL, (brL2PaletteAddr)
	LD DE, HL
	ADD DE, _BM_PAL2_BYTES_D512					; Move DE to the next (destination) palette.
	LD (brL2PaletteAddr), DE					; Move palette pointer to copied palette.

	LDIR										; Copy palette from HL to DE, size is given by BC (method param).

	RET											; ## END of the function ##

;----------------------------------------------------------;
;              #DecrementPaletteColors                     ;
;----------------------------------------------------------;
; Up to 7 brightness palettes, each 512 bytes, are stored in Bank _BN_PAL2_BR_BANK_D47. This function will modify the palette given by
; #brL2PaletteAddr. Make sure to initialize the palette properly by calling #InitPaletteBrightness or #NextBrightnessPalette.
; The whole brightness change works like this: 
; First, we have to decrease the palette brightness up to 7 times. It will store up to 7 arrays (7*512) containing changed colors for each
; palette. Afterward, you can reverse this process and increase brightness using already created palettes.
; 1) Call #InitPaletteBrightness to copy the initial pallet file (nxp) to the first brightness palette. It will initialize palette number 1,
;    and set pointer to it: #brL2PaletteAddr
; 2) Call #DecrementPaletteColors. It decreases all colors in brightness palette 1 (given by #brL2PaletteAddr) and updates the picture.
; 3) Call #NextBrightnessPalette. It will copy brightness palette 1 to 2, and update #brL2PaletteAddr that it points on 2.
; 4) Call #DecrementPaletteColors. It decreases all colors in brightness balette 2 (given by #brL2PaletteAddr) and updates the picture.
; 5) Repeat 3) and 4). You can create up to 7 brightness palettes (more makes no sense).
;
; Input:
;  - BC:  Sieze of the pallete in bytes.
DecrementPaletteColors

	CALL SetupPaletteLoad
	
	; ##########################################
	; Calculate the palette's address. Load the address of the first palette to HL and left right by A-1.
	LD HL, dbi.brL2Palette

	; ##########################################
	; Copy 9 bit (2 bytes per color) palette. Nubmer of colors is giveb by B (method param).

	CALL BytesToColors							; BC contains color size in bytes, we need number of colors in B.
.loopCopyColor
	PUSH BC

	; ##########################################
	; Decrement the brightness of the current color.

	LD DE, (HL)									; DE contains color the will be changed
	CALL BrightnessDown
	LD (HL), DE									; Update temp color.
	INC HL
	INC HL

	CALL WriteColor

	POP BC
	DJNZ .loopCopyColor

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                     #WriteColor                          ;
;----------------------------------------------------------;
; Input
;  - DE - conatins given color, E: RRRGGGBB, D: Bxxxxxxx
WriteColor

	; - Two consecutive writes are needed to write the 9 bit colour:
	; - 1st write: bits 7-0 = RRRGGGBB
	; - 2nd write: bits 7-1 = 0, bit 0 = LSB B

	; 1st write
	LD A, E
	NEXTREG _DC_REG_LA2_PAL_VAL_H44, A

	; 2nd write
	LD A, D
	NEXTREG _DC_REG_LA2_PAL_VAL_H44, A
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
	NEXTREG _MMU_REG_SLOT6_H56, _BN_PAL2_BANK_D46

	; Memory bank (8KiB) containing layer 2 palette with brightness.
	NEXTREG _MMU_REG_SLOT7_H57, _BN_PAL2_BR_BANK_D47	
	
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
	LD A, _BM_PAL2_COLORS_D255
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
