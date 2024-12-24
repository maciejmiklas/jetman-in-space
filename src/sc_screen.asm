;----------------------------------------------------------;
;          Screen Setup, Synchronization and Timing        ;
;----------------------------------------------------------;
	MODULE sc

;----------------------------------------------------------;
;                      #SetupScreen                        ;
;----------------------------------------------------------;
SetupScreen

	; Sprite and Layers system. Bits:
	;  - 7: 0 - low RES mode off
	;  - 6: 1 - sprite on top
	;  - 5: 0 - sprite clipping disabled
	;  - 4-2: 110 - S(U+L) ULA and Layer 2 combined (tiles + background)
	;  - 1: 1 - sprite over border
	;  - 0: 1 - sprites visible
	NEXTREG _SPR_REG_SETUP_H15, %0'1'0'110'1'1

	NEXTREG _DC_REG_TI_Y_H31, _CF_SC_3MAX_Y		; Reverses scrolling of the tiles, required by tl.NextStarsRow

	; Setup Layer 2
	NEXTREG _DC_REG_CONTROL1_H69, %1'0'0'00000	; Enable Layer 2

	; Layer 2 image (background) starts at 16k-bank 9 (default)
	NEXTREG _DC_REG_L2_BANK_H12, _CF_BIN_BGR_16KBANK 

	; Global transparency
	NEXTREG _GL_REG_TRANP_COL_H14, _COL_TRANSPARENT 

	LD	A, _COL_BLACK							; Set border color
	OUT (_BORDER_IO_HFE), A

	CALL SetupScreen256

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                    #SetupScreen320                       ;
;----------------------------------------------------------;
; Setup for 320x256
SetupScreen320

	NEXTREG _DC_REG_LA2_H70, %00'01'0000		; Layer 2 320x256x8bpp   TODO use for lobby!

	; Clip window for layer 2, required to display full picture at 320x256
	NEXTREG _DC_REG_L2_CLIP_H18, 0
	NEXTREG _DC_REG_L2_CLIP_H18, 159
	NEXTREG _DC_REG_L2_CLIP_H18, 0
	NEXTREG _DC_REG_L2_CLIP_H18, 255	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                    #SetupScreen256                       ;
;----------------------------------------------------------;
; Setup for 256x192
SetupScreen256

	NEXTREG _DC_REG_LA2_H70, %00'00'0000		; Layer 2 256x192x8bpp

	; Clip window for layer 2, required to display  picture at 256x192
	NEXTREG _DC_REG_L2_CLIP_H18, 0
	NEXTREG _DC_REG_L2_CLIP_H18, 255
	NEXTREG _DC_REG_L2_CLIP_H18, 0
	NEXTREG _DC_REG_L2_CLIP_H18, 191

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

;----------------------------------------------------------;
;                     #WaitForScanline                     ;
;----------------------------------------------------------;
; Pauses executing for single frame, 1/60 or 1/50 of a second.
; Based on: https://github.com/robgmoran/DougieDoSource
WaitForScanline     

; Read NextReg $1F - LSB of current raster line
	LD BC, _GL_REG_SELECT_H243B					; TBBlue Register Select
	LD A, _GL_REG_VL_H1F						; Port to access - Active Video Line LSB Register
	OUT (C), A									; Select NextReg $1F
	INC B										; TBBlue Register Access

; Wait for scanline (#_CF_SC_SYNC_SL)
.waitForScanline
	IN A, (C)									; Read the raster line LSB into A
	CP _CF_SC_SYNC_SL
	JR NZ, .waitForScanline

	RET											; ## END of the function ##

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
	; Layer 2 Palette
	NEXTREG _MMU_REG_SLOT6_H56, _CF_BIN_BGR_PAL_BANK ; Memory bank (8KiB) containing layer 2 palette data
	CALL SetupLayer2Palette

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
;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE