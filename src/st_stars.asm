;----------------------------------------------------------;
;          Stars for Layer 2 bitmap at 320x256             ;
;----------------------------------------------------------;
	module st

; The starfield is grouped into columns (#SC). When Jetman moves, the whole starfield and, respectively, all columns move in the 
; opposite direction. 
; The image on Layer 2 splits over 10 banks, each containing 32 columns, 256 pixels long. 
; Each star column (#SC) is assigned to a concrete bank and contains precisely one column with starts that will be injected into the picture.
; This column can be 256 pixels long and contains #SC.SIZE stars. Each star's vertical (Y) position is given as an offset from the top of 
; the screen. 
; #SC.X_OFFSET defines the placement of a star column within the memory bank -  this is the image column within this particular bank where 
; stars will be injected.
; Because starfield moves together with Jetman, a new position for each star in this row is calculated by adding an offset value to each 
; start position with every move. 
; Each column rolls from the bottom to the top when its position byte overflows. Each column also has a maximal horizontal position (#SC.Y_MAX),
; after which the starts will not be painted to avoid overlapping with the background image.

	STRUCT SC									; Stars column.
BANK					BYTE					; Bank number from 0 to 9.
X_OFFSET				BYTE					; X offset from the beginning of the bank, max 32 (32=8192/256)
SIZE					BYTE					; Amount of stars.
	ENDS

SC_BLINK_OFF			= 0

ST_HIDDEN				= 0
ST_C_HIDDEN				= ST_HIDDEN+1			; Value for RET C
ST_SHOW					= 1
ST_MOVE_UP				= 3
ST_MOVE_DOWN			= 4

starsState				BYTE ST_SHOW

starsMoveL1Delay		BYTE _ST_L1_MOVE_DEL_D4 ; Delay counter for stars on layer 1 (there are 2 layers of stars).
starsMoveL2Delay		BYTE _ST_L2_MOVE_DEL_D4 ; Delay counter for stars on layer 1 (there are 2 layers of stars).

randColor				BYTE 0					; Rand value from the previous call.

; Currently rendered palette.
starsPal				WORD 0
starsPalSize			BYTE 0
starsPalOffset			BYTE 0
	

; Currently rendered stars.
starsDataSize			BYTE 27
starsData				WORD 0				; Before using: CALL ut.SetupDataArraysBank
starsDataMaxY			WORD 0				; Before using: CALL ut.SetupDataArraysBank

;----------------------------------------------------------;
;                   #LoadStarsPalette                      ;
;----------------------------------------------------------;
LoadStarsPalette

	; Do not load the stars palette if the layer 2 image has too many colors and no more free space in the palette.
	; Add an amount of colors in the image to the colors required by the stars, and return if the carry flag is set.
	LD A, _ST_PAL_L1_SIZE + _ST_PAL_L2_SIZE
	LD B, A
	LD A, (btd.palColors)
	ADD B
	RET C										; Return if (image colors) + (stars colors ) > 256
	
	; ##########################################
	; Load colors for the stars on layer 1.
	CALL bs.SetupStarsDataBank
	LD HL, db.starsPalL1
	LD A, _ST_PAL_L1_SIZE
	LD B, A
	CALL bp.WriteColors

	; ##########################################
	; Load colors for the stars on layer 2.
	CALL bs.SetupStarsDataBank
	LD HL, db.starsPalL2
	LD A, _ST_PAL_L2_SIZE
	LD B, A
	CALL bp.WriteColors

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       #ShowStars                         ;
;----------------------------------------------------------;
ShowStars

	LD A, ST_SHOW
	LD (starsState), A

	; Render
	CALL _SetupLayer1
	CALL _RenderStars

	CALL _SetupLayer2
	CALL _RenderStars

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       #HideStars                         ;
;----------------------------------------------------------;
HideStars

	LD A, ST_HIDDEN
	LD (starsState), A

	; Render
	CALL _SetupLayer1
	CALL _RenderStars

	CALL _SetupLayer2
	CALL _RenderStars

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                      #MoveStarsUp                        ;
;----------------------------------------------------------;
MoveStarsUp
	
	; Move stars only if enabled.
	LD A, (starsState)
	CP ST_C_HIDDEN
	RET C

	;###########################################
	; Update state
	LD A, ST_MOVE_UP
	LD (starsState), A

	;###########################################
	CALL _MoveStarsL1Up
	CALL _MoveStarsL2Up

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                     #MoveStarsDown                       ;
;----------------------------------------------------------;
MoveStarsDown
	
	; Move stars only if enabled.
	LD A, (starsState)
	CP ST_C_HIDDEN
	RET C

	;###########################################
	; Update state
	LD A, ST_MOVE_DOWN
	LD (starsState), A

	;###########################################
	CALL _MoveStarsL1Down
	CALL _MoveStarsL2Down

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                      #BlinkStarsL1                       ;
;----------------------------------------------------------;
BlinkStarsL1

	CALL _SetupLayer1
	CALL _NextStarsColor

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                      #BlinkStarsL2                       ;
;----------------------------------------------------------;
BlinkStarsL2

	CALL _SetupLayer2
	CALL _NextStarsColor

	RET											; ## END of the function ##	
	
;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                   #_MoveStarsL1Down                      ;
;----------------------------------------------------------;
_MoveStarsL1Down

	; Delay movement
	LD A, (starsMoveL1Delay)
	DEC A
	LD (starsMoveL1Delay), A
	CP 0
	RET NZ										; Do not move yet, wait for 0.
	
	; Reset delay
	LD A, _ST_L1_MOVE_DEL_D4
	LD (starsMoveL1Delay), A


	;###########################################
	; Render
	CALL _SetupLayer1
	CALL _RenderStars

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                   #_MoveStarsL2Down                      ;
;----------------------------------------------------------;
_MoveStarsL2Down

	; Delay movement
	LD A, (starsMoveL2Delay)
	DEC A
	LD (starsMoveL2Delay), A
	CP 0
	RET NZ										; Do not move yet, wait for 0.
	
	; Reset delay
	LD A, _ST_L2_MOVE_DEL_D4
	LD (starsMoveL2Delay), A


	;###########################################
	; Render
	CALL _SetupLayer2
	CALL _RenderStars

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                    #_MoveStarsL1Up                       ;
;----------------------------------------------------------;
_MoveStarsL1Up

	; Delay movement
	LD A, (starsMoveL1Delay)
	DEC A
	LD (starsMoveL1Delay), A
	CP 0
	RET NZ										; Do not move yet, wait for 0.
	
	; Reset delay
	LD A, _ST_L1_MOVE_DEL_D4
	LD (starsMoveL1Delay), A

	;###########################################
	; Render
	CALL _SetupLayer1
	CALL _RenderStars

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                    #_MoveStarsL2Up                       ;
;----------------------------------------------------------;
_MoveStarsL2Up

	; Delay movement
	LD A, (starsMoveL2Delay)
	DEC A
	LD (starsMoveL2Delay), A
	CP 0
	RET NZ										; Do not move yet, wait for 0.
	
	; Reset delay
	LD A, _ST_L2_MOVE_DEL_D4
	LD (starsMoveL2Delay), A

	;###########################################
	; Render
	CALL _SetupLayer2
	CALL _RenderStars

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                     #_SetupLayer1                        ;
;----------------------------------------------------------;
_SetupLayer1

	; Palette
	LD DE, db.starsPalL1
	LD (starsPal), DE

	LD A, _ST_PAL_L1_SIZE
	LD (starsPalSize), A

	; The colors for the first layer do not have offset; they are directly after the palette for the image.
	XOR A
	LD (starsPalOffset), A

	; ##########################################
	; Data
	LD DE, db.starsDataL1
	LD (starsData), DE
	LD A, _ST_L1_SIZE
	LD (starsDataSize), A

	LD DE, db.starsDataL1MaxY
	LD (starsDataMaxY), DE

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                     #_SetupLayer2                        ;
;----------------------------------------------------------;
_SetupLayer2

	; Palette
	LD DE, db.starsPalL2
	LD (starsPal), DE
	
	LD A, _ST_PAL_L2_SIZE
	LD (starsPalSize), A

	; The colors for stars on layer 2 are stored after those for layer 1.
	LD A, _ST_PAL_L1_SIZE
	LD (starsPalOffset), A

	; ##########################################
	; Data
	LD DE, db.starsDataL2
	LD (starsData), DE
	LD A, _ST_L2_SIZE
	LD (starsDataSize), A

	LD DE, db.starsDataL2MaxY
	LD (starsDataMaxY), DE	

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                    #_NextStarsColor                      ;
;----------------------------------------------------------;
_NextStarsColor

	CALL bs.SetupStarsDataBank
	LD HL, (starsData)
	LD A, (starsDataSize)
	LD B, A

	; Loop over stars data.
.columnsLoop
	PUSH BC
	LD IX, HL

	; Move HL to stars pixel data.
	LD A, SC
	ADD HL, A
	LD A, (IX + SC.SIZE)						; Number of stars in column.
	LD B, A

	;###########################################
	; Loop over alls stars in column.
.starsLoop
	INC HL										; Move HL after star position to color info.

	; ##########################################
	; Do not change the color always, randomize it.

	LD A, (randColor)
	LD C, A
	LD A, R 									; Load the random number into A register
	LD (randColor), A
	CP C
	JR C, .nextStarPixel

	; ##########################################
	; Change the color.
	LD A, (starsPalSize)
	LD C, A
	LD A, (HL)									; A contains star color.
	INC A										; Next color.
	LD (HL), A
	CP C										; Did we reach the max color and have to reset it?
	JR NZ, .nextStarPixel

	; Reset color
	LD A, _ST_PAL_FIRST_D1
	LD (HL), A
.nextStarPixel
	INC HL										; Move HL to next star postion.
	DJNZ .starsLoop

.nextColumn
	
	; Move HL to the next stars column.
	POP BC
	DJNZ .columnsLoop
	
	CALL ShowStars
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                   #_RenderStars                          ;
;----------------------------------------------------------;
_RenderStars

	CALL bs.SetupStarsDataBank
	LD A, (starsDataSize)
	LD B, A
	LD HL, (starsData)

	; Loop over all stars
	LD IY, (starsDataMaxY)
.columnsLoop

	LD IX, HL
	PUSH IX, HL, BC
	CALL _RenderStarColumn
	POP BC, HL, IX

	; Move HL to the next stars column.
	LD A, SC									; Move HL after SC
	ADD HL, A

	LD A, (IX + SC.SIZE)						; Move HL after pixel data of the current stars column.
	ADD HL, A									; 2x because each star has color byte.
	ADD HL, A

	INC IY										; Move to the next max-y.
	DJNZ .columnsLoop	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                 #_RenderStarColumn                       ;
;----------------------------------------------------------;
; Input 
;  - IX: Pointer to SC
;  - IY: Points to the current max y postion for the star (from #starsMaxYLevel[0-9]).
_RenderStarColumn
	
	; ##########################################
	; Assign image bank that will be modified to slot 6.
	LD A, (IX + SC.BANK)
	LD B, A
	LD A, _BN_BG_ST_BANK_D18					; First image bank. See "NEXTREG _DC_REG_L2_BANK_H12, _BM_16KBANK_D9".
	ADD A, B
	NEXTREG _MMU_REG_SLOT6_H56, A				; Assign image bank to slot 6

	; ##########################################
	; DE will point to the address of the column that will contain starts. X_OFFSET * 256 = X_OFFSET * 255 + X_OFFSET.
	LD D, (IX + SC.X_OFFSET)
	LD E, _SC_RESY1_D255
	MUL D, E
	LD A, (IX + SC.X_OFFSET)
	ADD DE, A

	LD HL, _RAM_SLOT6_START_HC000				; Beginning of the image
	ADD DE, HL									; DE points to the byte in the image representing the column where we will inject stars.

	; ##########################################
	; HL will point to the first pixel that is right after #SC
	LD HL, IX
	LD A, SC
	ADD HL, A

	; ##########################################
	; Loop over stats and inject those into the image's column.
	LD B, (IX + SC.SIZE)						; Number of pixels in this column = number of iterations
	
	; Register values:
	; B:  Number of stars in the row.
	; HL: Points to the first source pixel from stars column.
	; DE: Points to the top destination pixel (byte) in the column on the background (destination) image.
	; IY: Points to the current max y postion for the star (from #starsMaxYLevel[0-9]).
	; In this loop, we will copy one column of the stars from the source data (HL) into the layer 2 image (DE) column.

.starsLoop
	PUSH DE, BC										;  Keep DE so it always points to the top of the column in the image.

	; ##########################################
	; Move star up/down or just show it.
	LD A, (starsState)
	
	; Do not move star if the command only shows it.
	CP ST_SHOW
	JR NZ, .moveStar

	; Only show the current star without movement?
	LD A, (HL)									; A contains current star position.
	JR .showStar

.moveStar
	; ##########################################
	; Move star up/down
	CP ST_MOVE_UP
	JR NZ, .afterMoveUp
	
	; Move star up.
	LD A, (HL)									; A contains current star position.
	LD B, A 									; Keep the original star position before movement because we have to paint transparent pixel.
	DEC A
	LD (HL), A									; Store new star position.
	JR .afterMoveDown

.afterMoveUp
	; Move star down.
	LD A, (HL)									; A contains current star position
	LD B, A 									; Keep the original star position before movement because we have to paint transparent pixel.
	INC A
	LD (HL), A									; Store new star position.
.afterMoveDown

	; ##########################################
	; Hide star only if it's not being placed on the original image.
	; B contains a star position before it was moved - that's the one that should be hidden.
	
	CALL _CanShowStar
	CP CANSS_YES
	JR NZ, .afterPaintStar						; Skip this star if it cannot be hidden.

	; Hide star
	PUSH DE										; Keep DE to point to the top of the column on the destination image.
	LD A, B										; B contains the position of the star that needs to be hidden.
	ADD DE, A									; DE contains a byte offset to a current column in the destination image, plus A will give the final star position.
	LD A, _ST_PAL_TRANSP_D0
	LD (DE), A
	POP DE

.showStar
	; ##########################################
	; Print the moved (or not moved if #starsState == ST_SHOW) star if it's not behind something on the image.

	LD B, (HL)									; A contains the position of the already moved star.
	CALL _CanShowStar
	
	CP CANSS_YES
	JR NZ, .afterPaintStar						; Skip this star if it cannot be painted.

	; Paint star on new postion
	LD A, (HL)									; A contains the position of the already moved star.
	ADD DE, A									; DE contains a byte offset to a current column in the destination image, plus A will give the final star position.

	POP BC										; Restore B, and keep it for the main loop.
	PUSH BC
	PUSH DE
	CALL _GetStarColor							; Load star color
	POP DE
	LD (DE), A

.afterPaintStar

	; ##########################################
	; Keep looping over stars in the column.

	; Move to the next pixel.
	INC HL										; Pixel postion
	INC HL										; Color info

	POP BC, DE
	
	DJNZ .starsLoop

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                    #_CanShowStar                         ;
;----------------------------------------------------------;
; Input 
;  - B:  Star postion to be checked.
;  - IY: Points to the current max y postion for the star (from #starsMaxYLevel[0-9]).
; Output:
;  - A with value CANSS_XXX
; Modifies: A,C
CANSS_YES			= 1
CANSS_NO			= 0

_CanShowStar

	; Load into C max star y-postion
	LD A, (IY)									; C contains max y-pos from #starsMaxYLevel[0-9].

	; A holds max star y-position and B current.
	CP B
	JR C, .notAllowed							; Jump if the max position (A) is below the current (B).

.allowed
	LD A, CANSS_YES
	RET

.notAllowed

	; Stars could be behind the building, in which case it should be hidden, but it's also possible that the star is 
	; below the building (basement?) in the picture that rolls over to the top of the screen. In this case, the star should be visible.
	LD A, (bg.bgOffset)							; The background image moves down, releasing more room for stars.
	LD C, A
	LD A, _SC_RESY1_D255
	SUB C

	CP B
	JR NC, .notAllowed2							; Jump if the max position (A) is below the current (B).
	LD A, CANSS_YES
	RET

.notAllowed2
 	LD A, CANSS_NO
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                     #_GetStarColor                       ;
;----------------------------------------------------------;
; Input:
;  - HL: Points to the source pixel from stars column.
; Output:
;  A: contains next star color.
; Modifies: A, B, C, DE
_GetStarColor

	LD DE, HL									; DE points to the star position in the column.
	INC DE										; DE points to the color info.

	; DE points to the color offset from #starsPal. Now, we have to move it to the offset in the layer two palette.
	; #btd.palColors points right after the colors registered for the image.
	LD A, (DE)
	LD B, A

	LD A, (starsPalOffset)
	LD C, A

	LD A, (btd.palColors)
	ADD B
	ADD C

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE