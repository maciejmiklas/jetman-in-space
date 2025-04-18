;----------------------------------------------------------;
;              Bitmap on Layer 2 at 320x256                ;
;----------------------------------------------------------;
; The image on Layer Two has a resolution of 320x256 and occupies 81920 bytes (80KiB) in 10 banks.
; The pixel orientation is from top to bottom, left to right. 
; Each bank has 8KiB = 8192 bytes and can hold 32 horizontal lines. 10 banks hold 320 lines.

	MODULE bm

imageBank				BYTE 0					; Bank containing the image.

BM_16KBANK_D9			= 9						; 16K bank 9 = 8k bank 18.


;----------------------------------------------------------;
;                     #LoadImage                           ;
;----------------------------------------------------------;
; Copies data from slot 6 to 7. Slot 6 points to the bank containing the source of the image, and slot 7 points to the bank that contains 
; display data (NEXTREG _DC_REG_L2_BANK_H12).
LoadImage
	
	; Load into D the start bank containing background image source
	LD D, dbs.BGST_BANK_D35

	; Copy image data from temp RAM into screen memory
	NEXTREG _DC_REG_L2_BANK_H12, BM_16KBANK_D9 ; Layer 2 image (background) starts at 16k-bank 9 (default).
	LD E, dbs.BGST_BANK_D18					; Destination bank where layer 2 image is expected. See "NEXTREG _DC_REG_L2_BANK_H12 ....".
	LD B, dbs.BM_BANKS_D10						; Amount of banks occupied by the image. 320x256 has 10, 256x192 has 6, 256x128 has 4.
.slotLoop										; Each loop copies single bank, there are 10 iterations.
	PUSH BC
	LD A, D
	NEXTREG _MMU_REG_SLOT6_H56, A				; Read from.

	LD A, E
	NEXTREG _MMU_REG_SLOT7_H57, A				; Write to.

	PUSH DE
	LD HL, _RAM_SLOT6_STA_HC000				; Source
	LD DE, _RAM_SLOT7_STA_HE000				; Destination
	LD BC, _BANK_BYTES_D8192
	LDIR
	POP DE

	INC D										; Next source bank.
	INC E										; Next destination bank.
	
	POP BC
	DJNZ .slotLoop

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                        #HideImage                        ;
;----------------------------------------------------------;
HideImage

	LD C, 0
.bankLoop										; Loop from 10 (dbs.BM_BANKS_D10) to 0.

	; ##########################################
	; Setup image bank.
	LD A, dbs.BGST_BANK_D18
	ADD C
	NEXTREG _MMU_REG_SLOT6_H56, A				; Use slot 7 to modify displayed image.

	; ##########################################
	; Horizontal line within bank loop. The bank has 8192 bytes, the picture has 256 lines, 
	; and each horozontal line in the single bank has 32 pixels (8192/256 = 32).
	LD B, _BM_YRES_D256-1
.linesLoop										; 255 to 0
	PUSH BC

	; Move HL to a pixel corresponding to this loop's horizontal line.
	LD HL, _RAM_SLOT6_STA_HC000
	LD A, B
	ADD HL, A

	; ##########################################
	LD B, _BANK_BYTES_D8192/_BM_YRES_D256		; 32 to 0
.pixelsLoop
	LD (HL), _COL_BLACK_D0
	ADD HL, _BM_YRES_D256						; Move HL to the next pixel to the right by adding 256 pixels.
	DJNZ .pixelsLoop

	POP BC
	DJNZ .linesLoop

	; ##########################################
	INC C
	LD A, C
	CP dbs.BM_BANKS_D10
	JR NZ, .bankLoop

	CALL ut.Pause

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                     #HideImageLine                       ;
;----------------------------------------------------------;
; Replaces horizontal line of the image with transparent color.
; Input:
;  - E:  Line number
HideImageLine

	LD B, dbs.BM_BANKS_D10
.bankLoop										; Loop from 10 (dbs.BM_BANKS_D10) to 0.

	; We will iterate over 10 banks ascending from dbs.BGST_BANK_D18 to dbs.BG_END_BANK_D27.
	; However, the loop starts at 10 (inclusive) and goes to 0 (exclusive)
	LD A, dbs.BG_END_BANK_D27 + 1				; 27 + 1 - 10 = 18 -> dbs.BG_END_BANK_D27 + 1 - dbs.BM_BANKS_D10 = dbs.BGST_BANK_D18
	SUB B
	NEXTREG _MMU_REG_SLOT7_H57, A				; Use slot 7 to modify displayed image.

	; Each bank contains columns, each having 256 bytes/pixels. To draw the horizontal line at pixel 12 (y position from the top of the 
	; picture), we have to start at byte 12, then 12+256, 12+(256*2), 12+(256*3), and so on.
	LD HL, _RAM_SLOT7_STA_HE000
	LD D, 0										; E contains the line number, reset only D to use DE for 16-bit math.
	ADD HL, DE									; HL points at line that will be replaced.

	; ##########################################
	; Iterate over each picture line in the current bank. Each bank has 8*1024/256=32 lines.
	PUSH BC

	LD B, _BANK_BYTES_D8192/_BM_YRES_D256		; 8*1024/256=32
.linesLoop
	LD (HL), _COL_BLACK_D0
	ADD HL, _BM_YRES_D256						; Move HL to the next pixel to the right by adding 256 pixels.

	DJNZ .linesLoop
	POP BC
	
	DJNZ .bankLoop

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                   #ReplaceImageLine                      ;
;----------------------------------------------------------;
; Replaces the line of the displayed layer 2 image with the corresponding line of the given image.
; Input:
;  - E:  Line number.
ReplaceImageLine

	LD B, 0
.bankLoop										; Loop from 0 to dbs.BM_BANKS_D10 - 1.
	
	; ##########################################
	; Setup banks. The source image will be stored in bank 6, destination image in bank 7. We will copy line from 6 to 7.

	; Setup slot 6 with source.
	LD A, dbs.BGST_BANK_D35
	ADD B										; A points to current bank from the source image.
	NEXTREG _MMU_REG_SLOT6_H56, A				; Slot 6 contains source of the image.
	
	; Setup slot 7 with destination.
	LD A, dbs.BGST_BANK_D18
	ADD B										; A points to current bank of the source image.
	NEXTREG _MMU_REG_SLOT7_H57, A				; Use slot 7 to modify displayed image.

	; ##########################################
	; Copy line from source to destination image.  Iterate over each picture line's pixel in current bank. Each bank has 8*1024/256=32 lines.
	PUSH BC

	LD B, _BANK_BYTES_D8192/_BM_YRES_D256		; 8*1024/256=32
	LD D, 0										; E contains the line number, reset only D to use DE for 16-bit math.
.linesLoop

	; Copy a pixel from the source image into C.
	LD HL, _RAM_SLOT6_STA_HC000
	ADD HL, DE									; Move DE from the beginning of the bank to the current pixel.
	LD C, (HL)									; C contains pixel value.
	
	; Copy pixel value from C into the destination image.
	LD HL, _RAM_SLOT7_STA_HE000
	ADD HL, DE									; Move DE from the beginning of the bank to the current pixel.
	LD (HL), C									; Store pixel value.

	ADD DE, _BM_YRES_D256						; Move DE to the next pixel to the right by adding 256 pixels.

	DJNZ .linesLoop
	POP BC
	
	; ##########################################
	; Loop from 0 to dbs.BM_BANKS_D10 - 1.
	LD A, B
	INC A
	LD B, A
	CP dbs.BM_BANKS_D10
	JR NZ, .bankLoop

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
