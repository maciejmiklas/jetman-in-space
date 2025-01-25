;----------------------------------------------------------;
;                     Bitmap Palette                       ;
;----------------------------------------------------------;
	MODULE bp

palBytes				WORD 0					; Size in bytes of background palette, max 512.
palColors				BYTE 0					; Amount of colors in background palette, max 255.
palAdr					WORD 0					; Address of the orginal palette data. Must be in slot 6 ($C000-$DFFF).
todPalAddr 				WORD 0					; Pointer to current brightness palette.

;----------------------------------------------------------;
;                  #PaletteBrightnessUp                    ;
;----------------------------------------------------------;
; Input
;  - BC:  Sieze of the pallete in bytes.
PaletteBrightnessUp
	
	CALL SetupPaletteLoad

	; Moves #todPalAddr to the previous palette
	LD HL, (todPalAddr)
	ADD HL, -_BM_PAL2_BYTES_D512
	LD (todPalAddr), HL
	
	CALL WriteTodColors

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                 #PaletteBrightnessDown                   ;
;----------------------------------------------------------;
; Input:
;  - BC:  Sieze of the pallete in bytes.
PaletteBrightnessDown
	
	CALL SetupPaletteLoad

	; Moves #todPalAddr to the next palette
	LD HL, (todPalAddr)
	ADD HL, _BM_PAL2_BYTES_D512
	LD (todPalAddr), HL
	
	CALL WriteTodColors

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                     #WriteTodColors                      ;
;----------------------------------------------------------;
; Input:
;  - HL: Address of the pallete that will be copied
WriteTodColors

	; Load colors
	CALL BytesToColors							; BC contains color size in bytes, we need number of colors in B.

	LD A, (palColors)
	LD B, A
.loop
	LD DE, (HL)
	CALL WriteColor
	INC HL
	INC HL
	DJNZ .loop

	RET											; ## END of the function ##

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
	; Decrement blue color part 1: E: xxx'xxx'BB D: xxxxxxx'B

	; Prepare BBB for decrement oparation: xxx'xxx'BB xxxxxxx'B-> 00000BBB
	LD A, E
	AND _BM_PAL2_BB_MASK						; A contains 000'000'BB.
	RR D										; Rotate D right, if xxxxxxx'B is set, it will set CF.
	RLA											; Rotale left A. It will set CF from the previous operation on bit 0: 000000'BB -> 00000'BB'CF.
	
	; Ensure that BBB is > 0 before decreasing it.
	CP _BM_PAL2_MIN
	JR Z, .afterDecrementBlue

	; A contains BBB as 00000'BBB, decrement it and update DE
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
;               #CreateTimeOfDayPalettes                   ;
;----------------------------------------------------------;
; This function creates up to 6 palettes for the transition from day to night from the palette given by HL.
; Palettes are stored in #todL2Palettes; each one has 512 bytes. #todPalAddr points to the first palette.
CreateTimeOfDayPalettes

	CALL SetupPaletteLoad

	; ##########################################
	; Copy the original palette into the address given by #todPalAddr, creating the first palette to be modified by the loop below.

	; Set the palette address to the beginning of the bank holding it, and copy initial palette.
	LD HL, (palAdr)
	LD BC, (palColors)
	CALL ResetTimeOfDayPaletteArrd				; Sets bank and DE as destination for LDIR
	LDIR										; HL (source) and BC (amount) are method params

	; ##########################################
	; Copy remaining palettes.

	LD B, _TOD_STEP_NIGHT						; Maximal darkness level, also number of palettes.
.copyLoop
	PUSH BC

	CALL DecrementPaletteColors
	CALL NextBrightnessPalette

	POP BC
	DJNZ .copyLoop

	; ##########################################
	;Reset palette pointer
	CALL ResetTimeOfDayPaletteArrd

	RET											; ## END of the function ##

;----------------------------------------------------------;
;             #ResetTimeOfDayPaletteArrd                  ;
;----------------------------------------------------------;
ResetTimeOfDayPaletteArrd

	CALL SetupPaletteBank
	
	; Set the palette address to the beginning of the bank holding it.
	LD DE, dbi.todL2Palettes
	LD (todPalAddr), DE

	RET											; ## END of the function ##	

;----------------------------------------------------------;
;                 #BgImageVariablesSet                     ;
;----------------------------------------------------------;
BgImageVariablesSet

	; Set #palColors from #palBytes
	LD BC, (palBytes)
	CALL BytesToColors
	LD A, B
	LD (palColors), A

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
;              #NextBrightnessPalette                      ;
;----------------------------------------------------------;
; Moves #todPalAddr to the next palette and copies the previous palette there.
NextBrightnessPalette

	; ##########################################
	; Moves #todPalAddr to the next palette 
	LD HL, (todPalAddr)
	LD DE, HL
	ADD DE, _BM_PAL2_BYTES_D512					; Move DE to the next (destination) palette.
	LD (todPalAddr), DE							; Move palette pointer to copied palette.

	; ##########################################
	; Copy current palette to new addres given by #todPalAddr
	LD BC, (palBytes)							; Number of bytes to be copied by LDIR
	LDIR										; Copy palette from HL to DE

	RET											; ## END of the function ##
	
;----------------------------------------------------------;
;                #DecrementPaletteColors                   ;
;----------------------------------------------------------;
; This function will decrease palette brighteners given by #todPalAddr.
DecrementPaletteColors

	; ##########################################
	; Copy 9 bit (2 bytes per color) palette
	LD HL, (todPalAddr)					; The address of current palette set by #NextBrightnessPalette.

	LD A, (palColors)
	LD B, A
.loopColor
	PUSH BC

	; ##########################################
	; Decrement the brightness of the current color.
	LD DE, (HL)									; DE contains color that will be changed.
	CALL BrightnessDown
	LD (HL), DE									; Update temp color.
	INC HL
	INC HL

	POP BC
	DJNZ .loopColor

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                     #WriteColor                          ;
;----------------------------------------------------------;
; Input
;  - DE - conatins given color, E: RRRGGGBB, D: xxxxxxxB
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
LoadLayer2Palette

	CALL SetupPaletteLoad

	; ##########################################
	; Copy 9 bit (2 bytes per color) palette. Nubmer of colors is giveb by B (method param).
	LD A, (palColors)					; Number of colors/iterations.
	LD B, A

	LD HL, (palAdr)					; Address of the palette.
.loopCopyColor
	
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
__FillLayer2Palette

	LD A, (palColors)					; Number of colors/iterations.
	LD B, A

	; We copied the number of colors given by B, but we had to copy 256 colors (512 bytes).
	LD A, _BM_PAL2_COLORS_D255
	SUB B
	LD B, A										; B contains the number of colors that must be filled to complete 256.
	
	LD A, _COL_TRANSPARENT_D0					; Fill remaining colors with transparent
.loopFillBlank

	NEXTREG _DC_REG_LA2_PAL_VAL_H44, A			; 1st write
	NEXTREG _DC_REG_LA2_PAL_VAL_H44, A			; 2nd write

	DJNZ .loopFillBlank

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE
