;----------------------------------------------------------;
;          Stars for Layer 2 bitmap at 320x256              ;
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

starsPalL1
	DW $1FF, $1FF, $1FF, $120, $123, $125, $127, $128, $12B, $12D, $12F, $130, $133, $135, $137, $138, $13B, $13D, $13F, $0, $0, $0, $0, $0, $0

starsPalL2
	DW  $40, $36, $48, $8, $B, $0, $0, $0, $0, $0

; Currently rendered palette.
starsPal				WORD 0
starsPalSize			BYTE 0
starsPalOffset			BYTE 0

; Max horizontal star position for each column (#SC). Starts reaching it will be hidden.
starsDataL1MaxY
	DB 143/*X=002*/, 154/*X=008*/, 159/*X=020*/, 196/*X=037*/, 195/*X=047*/, 195/*X=051*/, 140/*X=068*/, 134/*X=075*/, 106/*X=084*/, 192/*X=097*/
	DB 049/*X=116*/, 039/*X=124*/, 023/*X=130*/, 019/*X=143*/, 023/*X=151*/, 123/*X=171*/, 062/*X=180*/, 082/*X=197*/, 104/*X=212*/, 187/*X=227*/
	DB 187/*X=236*/, 187/*X=254*/, 128/*X=264*/, 119/*X=272*/, 102/*X=287*/, 221/*X=308*/, 230/*X=318*/

starsDataL2MaxY
	DB 153/*X=010*/, 196/*X=042*/, 195/*X=052*/, 142/*X=066*/, 106/*X=082*/, 086/*X=108*/, 082/*X=114*/, 037/*X=129*/, 024/*X=153*/
	DB 121/*X=175*/, 063/*X=180*/, 080/*X=194*/, 087/*X=202*/, 187/*X=235*/, 123/*X=268*/, 106/*X=281*/, 222/*X=301*/
	
starsDataL1Size			BYTE 27						; Number of #SC elements for stars.
starsDataL1
	SC {0/*BANK*/, 02/*X_OFFSET*/, 6/*SIZE*/}	; X=2
	DB 12,1, 15,4, 70,5, 94,15, 160,8, 250,19

	SC {0/*BANK*/, 08/*X_OFFSET*/, 5/*SIZE*/}	; X=8
	DB 5,3, 38,6, 120,10, 158,4, 245,18

	SC {0/*BANK*/, 20/*X_OFFSET*/, 4/*SIZE*/}	; X=20
	DB 4,4, 42,8, 133,1, 245,15

	SC {1/*BANK*/, 05/*X_OFFSET*/, 5/*SIZE*/}	; X=37
	DB 20,3, 80,8, 104,12, 150,9, 255,5

	SC {1/*BANK*/, 15/*X_OFFSET*/, 5/*SIZE*/}	; X=47
	DB 10,1, 115,4, 130,9, 155,2, 230,15

	SC {1/*BANK*/, 19/*X_OFFSET*/, 6/*SIZE*/}	; X=51
	DB 4,4, 90,1, 144,8, 148,2, 202,5, 251,16

	SC {2/*BANK*/, 04/*X_OFFSET*/, 5/*SIZE*/}	; X=68
	DB 14,2, 52,4, 113,6, 189,8, 241,16

	SC {2/*BANK*/, 11/*X_OFFSET*/, 4/*SIZE*/}	; X=75
	DB 21,1, 92,6, 158,9, 221,19

	SC {2/*BANK*/, 20/*X_OFFSET*/, 5/*SIZE*/}	; X=84
	DB 31,5, 93,4, 159,13, 178,8, 248,19

	SC {3/*BANK*/, 01/*X_OFFSET*/, 6/*SIZE*/}	; X=97
	DB 26,3, 45,8, 125,4, 138,11, 160,9, 193,12

	SC {3/*BANK*/, 20/*X_OFFSET*/, 5/*SIZE*/}	; X=116
	DB 10,4, 104,5, 145,6, 190,8, 249,12

	SC {3/*BANK*/, 28/*X_OFFSET*/, 4/*SIZE*/}	; X=124
	DB 86,11, 123,7, 158,1, 233,19

	SC {4/*BANK*/, 02/*X_OFFSET*/, 6/*SIZE*/}	; X=130
	DB 21,19, 55,11, 80,8, 144,3, 148,13, 243,2

	SC {4/*BANK*/, 15/*X_OFFSET*/, 6/*SIZE*/}	; X=143
	DB 47,13, 77,2, 93,18, 139,1, 188,5, 233,7

	SC {4/*BANK*/, 23/*X_OFFSET*/, 6/*SIZE*/}	; X=151
	DB 5,3, 84,5, 98,9, 142,12, 168,11, 201,10

	SC {5/*BANK*/, 11/*X_OFFSET*/, 5/*SIZE*/}	; X=171
	DB 38,1, 78,5, 132,9, 149,12, 231,11

	SC {5/*BANK*/, 20/*X_OFFSET*/, 5/*SIZE*/}	; X=180
	DB 24,2, 44,9, 126,3, 160,7, 243,17

	SC {6/*BANK*/, 05/*X_OFFSET*/, 3/*SIZE*/}	; X=197
	DB 64,11, 116,3, 174,15

	SC {6/*BANK*/, 20/*X_OFFSET*/, 5/*SIZE*/}	; X=212
	DB 13,15, 44,3, 100,5, 143,7, 199,2

	SC {7/*BANK*/, 03/*X_OFFSET*/, 5/*SIZE*/}	; X=227
	DB 55,2, 98,3, 120,7, 187,11, 255,19

	SC {7/*BANK*/, 12/*X_OFFSET*/, 4/*SIZE*/}	; X=236
	DB 11,14, 82,16, 148,11, 213,9

	SC {7/*BANK*/, 30/*X_OFFSET*/, 4/*SIZE*/}	; X=254
	DB 44,1, 113,12, 192,15, 253,12

	SC {8/*BANK*/, 08/*X_OFFSET*/, 5/*SIZE*/}	; X=264
	DB 4,3, 39,1, 88,13, 133,2, 152,15

	SC {8/*BANK*/, 16/*X_OFFSET*/, 3/*SIZE*/}	; X=272
	DB 3,1, 142,4, 241,9

	SC {8/*BANK*/, 31/*X_OFFSET*/, 4/*SIZE*/}	; X=287
	DB 30,12, 103,3, 150,8, 189,2

	SC {9/*BANK*/, 20/*X_OFFSET*/, 4/*SIZE*/}	; X=308
	DB 5,4, 36,11, 120,14, 211,2

	SC {9/*BANK*/, 30/*X_OFFSET*/, 4/*SIZE*/}	; X=318
	DB 5,3, 102,6, 142,9, 240,12

starsDataL2Size			BYTE 17						; Number of #SC elements for stars.
starsDataL2

	SC {0/*BANK*/, 10/*X_OFFSET*/, 4/*SIZE*/}	; X=10
	DB 4,4, 42,8, 133,1, 245,9

	SC {1/*BANK*/, 10/*X_OFFSET*/, 6/*SIZE*/}	; X=42
	DB 26,3, 45,8, 125,4, 138,3, 160,9, 193,2

	SC {1/*BANK*/, 20/*X_OFFSET*/, 5/*SIZE*/}	; X=52
	DB 14,2, 52,4, 113,6, 189,8, 241,1

	SC {2/*BANK*/, 02/*X_OFFSET*/, 5/*SIZE*/}	; X=66
	DB 10,1, 115,4, 130,9, 155,2, 230,4

	SC {2/*BANK*/, 18/*X_OFFSET*/, 5/*SIZE*/}	; X=82
	DB 38,1, 78,5, 132,9, 149,2, 231,5

	SC {3/*BANK*/, 12/*X_OFFSET*/, 5/*SIZE*/}	; X=108
	DB 5,3, 38,6, 120,9, 158,4, 245,1

	SC {3/*BANK*/, 18/*X_OFFSET*/, 5/*SIZE*/}	; X=114
	DB 31,5, 93,4, 159,1, 178,8, 248,4

	SC {4/*BANK*/, 1/*X_OFFSET*/, 5/*SIZE*/}	; X=129
	DB 10,4, 104,5, 145,6, 190,8, 249,3

	SC {4/*BANK*/, 25/*X_OFFSET*/, 4/*SIZE*/}	; X=153
	DB 21,1, 92,6, 158,9, 221,6

	SC {5/*BANK*/, 15/*X_OFFSET*/, 6/*SIZE*/}	; X=175
	DB 4,4, 90,1, 144,8, 148,2, 202,5, 251,7

	SC {5/*BANK*/, 20/*X_OFFSET*/, 5/*SIZE*/}	; X=180
	DB 24,2, 44,9, 126,3, 160,7, 243,9

	SC {6/*BANK*/, 04/*X_OFFSET*/, 6/*SIZE*/}	; X=194
	DB 12,1, 15,4, 70,5, 94,3, 160,8, 250,2

	SC {6/*BANK*/, 10/*X_OFFSET*/, 4/*SIZE*/}	; X=202
	DB 86,3, 123,7, 158,1, 233,9

	SC {7/*BANK*/, 11/*X_OFFSET*/, 5/*SIZE*/}	; X=235
	DB 20,3, 80,8, 104,2, 150,9, 255,5

	SC {8/*BANK*/, 12/*X_OFFSET*/, 6/*SIZE*/}	; X=268
	DB 21,3, 55,4, 80,8, 144,5, 148,8, 243,6

	SC {8/*BANK*/, 25/*X_OFFSET*/, 6/*SIZE*/}	; X=281
	DB 47,3, 77,2, 93,5, 139,7, 188,4, 233,1

	SC {9/*BANK*/, 13/*X_OFFSET*/, 6/*SIZE*/}	; X=301
	DB 5,3, 84,5, 98,9, 142,1, 168,4, 201,5

; Currently rendered stars.
starsDataSize			BYTE 27
starsData				WORD 0
starsDataMaxY			WORD 0

;----------------------------------------------------------;
;                   #LoadStarsPalette                      ;
;----------------------------------------------------------;
LoadStarsPalette

	; Do not load the stars palette if the image has too many colors and no more free space.
	; Add an amount of colors in the image to the colors required by the stars, and return if the carry flag is set.
	LD A, _ST_PAL_L1_SIZE + _ST_PAL_L2_SIZE
	LD B, A
	LD A, (btd.palColors)
	ADD B
	RET C										; Return if (image colors) + (stars colors ) > 256
	
	; ##########################################
	; Load colors for the stars on layer 1.
	LD HL, starsPalL1
	LD A, _ST_PAL_L1_SIZE
	LD B, A
	CALL bp.WriteColors

	; ##########################################
	; Load colors for the stars on layer 2.
	LD HL, starsPalL2
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
	CALL _BlinkStars

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                      #BlinkStarsL2                       ;
;----------------------------------------------------------;
BlinkStarsL2

	CALL _SetupLayer2
	CALL _BlinkStars

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
	LD DE, starsPalL1
	LD (starsPal), DE

	LD A, _ST_PAL_L1_SIZE
	LD (starsPalSize), A

	; The colors for the first layer do not have offset; they are directly after the palette for the image.
	XOR A
	LD (starsPalOffset), A

	; ##########################################
	; Data
	LD DE, starsDataL1
	LD (starsData), DE

	LD A, (starsDataL1Size)
	LD (starsDataSize), A

	LD DE, starsDataL1MaxY
	LD (starsDataMaxY), DE

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                     #_SetupLayer2                        ;
;----------------------------------------------------------;
_SetupLayer2

	; Palette
	LD DE, starsPalL2
	LD (starsPal), DE
	
	LD A, _ST_PAL_L2_SIZE
	LD (starsPalSize), A

	; The colors for stars on layer 2 are stored after those for layer 1.
	LD A, _ST_PAL_L1_SIZE
	LD (starsPalOffset), A

	; ##########################################
	; Data
	LD DE, starsDataL2
	LD (starsData), DE

	LD A, (starsDataL2Size)
	LD (starsDataSize), A

	LD DE, starsDataL1MaxY
	LD (starsDataMaxY), DE	

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                      #_BlinkStars                        ;
;----------------------------------------------------------;
_BlinkStars

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
	; Assing image bank that will be modified to slot 6.
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