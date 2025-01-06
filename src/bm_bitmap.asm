;----------------------------------------------------------;
;                   Bitmap Manipulation                    ;
;----------------------------------------------------------;
	MODULE bm

;----------------------------------------------------------;
;                    #FillLevel2Image                      ;
;----------------------------------------------------------;
; Fill last two banks of layer 2 image with transparent color.
FillLevel2Image

	NEXTREG _MMU_REG_SLOT7_H57, _BIN_BGR_END_BANK_D27-1
	LD HL, _RAM_SLOT7_START_HE000				; Start address of bank in slot 6.
	LD D, _COL_TRANSPARENT_D0
	CALL ut.FillBank

	NEXTREG _MMU_REG_SLOT7_H57, _BIN_BGR_END_BANK_D27
	LD HL, _RAM_SLOT7_START_HE000				; Start address of bank in slot 6.
	LD D, _COL_TRANSPARENT_D0
	CALL ut.FillBank

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                    #LoadLevel2Image                      ;
;----------------------------------------------------------;
; Copies data from slots 6 to 7. Slot 6 points to the bank containing the source of the image, and slot 7 points to the bank that contains 
; display data (NEXTREG _DC_REG_L2_BANK_H12).
; Input:
;  - D:  Start bank containing background image source
;  - HL: Address of layer 2 palette data. Must be in slot 6 ($C000-$DFFF)
LoadLevel2Image
	
	; Setup layer 2 palette.
	CALL LoadLayer2Palette

	; ##########################################
	; Copy image data from temp RAM into screen memory
	NEXTREG _DC_REG_L2_BANK_H12, _BM_16KBANK_D9 ; Layer 2 image (background) starts at 16k-bank 9 (default).
	LD E, _BIN_BGR_ST_BANK_D18					; Destination bank where layer 2 image is expected. See "NEXTREG _DC_REG_L2_BANK_H12 ....".
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

xxx
	INCBIN  "assets/l001_background.nxp", 0, _BM_PAL_BYTES_D512

;----------------------------------------------------------;
;                  #LoadLayer2Palette                      ;
;----------------------------------------------------------;
; Input:
;  - HL: Address of layer 2 palette data. Must be in slot 6 ($C000-$DFFF).
; Modifies: A,B,HL
LoadLayer2Palette

	; Setup palette that is going to be written, bits:
	;  - 0:   0 = Disable ULANext mode
	;  - 1-3: 0 = First palette 
	;  - 6-4: 001 = Write layer 2 first palette
	;  - 7:   0 = enable palette write auto-increment for _DC_REG_LA2_PAL_VAL_H44
	NEXTREG _DC_REG_LA2_PAL_CTR_H43, %0'001'000'1 

	NEXTREG _DC_REG_LA2_PAL_IDX_H40, 0			; Start writing the palette from the first color, we will replace all 256 colors.
		
	; Memory bank (8KiB) containing layer 2 palette data.
	NEXTREG _MMU_REG_SLOT6_H56, _BIN_BGR_PAL_BANK_D46

	; Copy 9 bit (2 bytes per color) palette.
	LD B, 255									; 256 colors (loop counter), palette has 512 bytes, but we read two bytes in one iteration.
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
;                   #HideImageLine                         ;
;----------------------------------------------------------;
; Replaces line of the image with transparent color.
; Input:
;  - E:  Line number
HideImageLine

	LD B, _BM_BANKS_D10
.bankLoop										; Loop from 10 (_BM_BANKS_D10) to 0.

	; We will iterate over 10 banks ascending from _BIN_BGR_ST_BANK_D18 to _BIN_BGR_END_BANK_D27.
	; However, the loop starts at 10 (inclusive) and goes to 0 (exclusive)
	LD A, _BIN_BGR_END_BANK_D27 + 1				; 27 + 1 - 10 = 18 -> _BIN_BGR_END_BANK_D27 + 1 - _BM_BANKS_D10 = _BIN_BGR_ST_BANK_D18
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
	LD A, _BIN_BGR_ST_BANK_D18
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
