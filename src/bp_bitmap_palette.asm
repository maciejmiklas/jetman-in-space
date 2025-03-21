;----------------------------------------------------------;
;                     Bitmap Palette                       ;
;----------------------------------------------------------;
	MODULE bp

;----------------------------------------------------------;
;                     #BytesToColors                       ;
;----------------------------------------------------------;
; Input:
;  - BC: Sieze of the palette in bytes.
; Output:
;  - B: Number of colors.
BytesToColors
	
	; Divide BC by 2 -> one color takes two bytes
	SRL B										; Shift the higher byte (B) right by 1 bit
	RR C										; Rotate right through carry the lower byte (C)

	; Now BC contains max 255, because we have 512 colors
	LD B, C

	; In case of 512 colors there is an overflow, and B is 0.
	LD A, B
	CP 0
	RET NZ
	LD B, $FF

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                     #LoadColors                          ;
;----------------------------------------------------------;
; Load palette address, set bank, and finally load colors into hardware.
; Input:
;  - HL: Contains the current palette address.
;  - B:  Number of colors.
LoadColors
	
	CALL bp.SetupPaletteLoad
	CALL bp.WriteColors

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       #WriteColors                       ;
;----------------------------------------------------------;
; Input:
;  - HL: Address of the palette that will be copied
;  - B:  Number of colors.
WriteColors

.loop
	LD DE, (HL)
	CALL bp.WriteColor
	INC HL
	INC HL
	DJNZ .loop

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                   #SetupPaletteLoad                      ;
;----------------------------------------------------------;
SetupPaletteLoad

	CALL bs.SetupPaletteBank

	; Setup palette that is going to be written, bits:
	;  - 0:   0 = Disable ULANext mode
	;  - 1-3: 0 = First palette 
	;  - 6-4: 001 = Write layer 2 first palette
	;  - 7:   0 = enable palette write auto-increment for _DC_REG_LA2_PAL_VAL_H44
	NEXTREG _DC_REG_LA2_PAL_CTR_H43, %0'001'000'1 

	NEXTREG _DC_REG_LA2_PAL_IDX_H40, 0			; Start writing the palette from the first color, we will replace all 256 colors.
		
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

	; Update original color in DE
	LD B, A										; Keep A in B, A contains new RRR value.

	LD A, E										; Load RRR'GGG'BB into A and reset RRR, because we will set it to new value with XOR.
	AND _BM_PAL2_RRR_MASKN
	XOR B										; Set new RRR value to E.
	LD E, A										; Update original input/return value.

.afterDecrementRed

	; ##########################################
	; Decrement green color (xxx'GGG'xxx)

	LD A, E
	AND _BM_PAL2_GGG_MASK						; Reset all bits but green.

	CP _BM_PAL2_MIN								; Do not decrement if green is already at 0.
	JR Z, .afterDecrementGreen

	; Green is above 0, decrement it.
	SUB _BM_PAL2_GGG_INC 

	; Update original color in DE.
	LD B, A										; Keep A in B, A contains new GGG value.

	LD A, E										; Load RRR'GGG'BB into A and reset GGG, because we will set it to new value with XOR.
	AND _BM_PAL2_GGG_MASKN
	XOR B										; Set new GGG value to E.
	LD E, A										; Update original input/return value.

.afterDecrementGreen	

	; ##########################################
	; Decrement blue: E: xxx'xxx'BB D: xxxxxxx'B

	; Prepare BBB for decrement operation: xxx'xxx'BB xxxxxxx'B-> 00000BBB
	LD A, E
	AND _BM_PAL2_BB_MASK						; A contains 000'000'BB.
	RR D										; Rotate D right, if xxxxxxx'B is set, it will set CF.
	RLA											; Rotate left A. It will set CF from the previous operation on bit 0: 000000'BB -> 00000'BB'CF.

	; Ensure that BBB is > 0 before decreasing it.
	CP _BM_PAL2_MIN
	JR Z, .afterDecrementBlue
	
	; A contains BBB as 00000'BBB, decrement it and update DE
	DEC A										; Decrement BBB.

	; Apply new BBB value to original DE.
	RRA											; 00000'BBB -> 000000'BB -> CF
	RL D										; 00000000 -> 0000000'CF -> D now contains proper value.
	
	LD B, A										; Backup A containing BB.
	LD A, E
	AND _BM_PAL2_BB_MASKN						; Load RRR'GGG'BB into A and reset BB, because we will set it to new value with XOR.
	XOR B
	LD E, A
.afterDecrementBlue	

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                      #WriteColor                         ;
;----------------------------------------------------------;
; Input
;  - DE - contains given color, E: RRRGGGBB, D: xxxxxxxB
WriteColor

	; - Two consecutive writes are needed to write the 9 bit color:
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
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE
