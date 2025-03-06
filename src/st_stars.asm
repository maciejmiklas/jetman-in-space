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
; #SC.X_OFSET defines the placement of a star column within the memory bank -  this is the image column within this particular bank where 
; stars will be injected.
; Because starfield moves together with Jetmanl, a new position for each star in this row is calculated by adding an offset value to each 
; start position with every move. Each column rolls from the bottom to the top when its position byte overflows. Each column also has a 
; maximal horizontal position (#SC.Y_MAX), after which the starts will not be painted to avoid overlapping with the background image.
; Memory organization: _ST_SC_D27*([SC], SC.SIZE*[star y position])


	STRUCT SC									; Stars column.
BANK					BYTE					; Bank number from 0 to 9.
X_OFSET					BYTE					; X offset from the beginning of the bank, max 32 (32=8192/256)
SIZE					BYTE					; Amount of stars.

; Reversed position of a blinking star. 0 for none, #SIZE for the first, 1 for last.
; For "DB 10, 20, 30, 40" and SIZE 4, we have: BLINK=1 -> 40, BLINK=3 -> 20. 
BLINK					BYTE
BCOLOR					BYTE					; Current color is the blinking star, set during runtime.
	ENDS

SC_BLINK_OFF			= 0

ST_HIDDEN				= 0
ST_C_HIDDEN				= ST_HIDDEN +1			; Value for RET C
ST_SHOW					= 1
ST_MOVE_UP				= 3
ST_MOVE_DOWN			= 4

starsState				BYTE ST_SHOW

starsMoveDelay			BYTE _ST_L1_MOVE_DEL_D4 ; Delay counter for stars on layer 1 (there are 2 layers of stars).

starsPal
	;DW $01FF, $01F8, $0037, $0015, $01E0, $01EF, $003B, $0023
	DW $0180, $01C7, $0180, $01C0, $0003, $0038, $01C0, $0003, $0038
    //  R,    B,     G      R       B     G      R      B       G   
starsPalPos				BYTE _ST_PAL_FIRST_D1	; From 0 to _ST_PAL_D8 - _ST_PAL_FIRST_D1

; Max horizontal star position for each column (#SC). Starts reaching it will be hidden.
starsLayer1MaxY
	DB 143/*X=002*/, 154/*X=008*/, 159/*X=020*/, 196/*X=037*/, 195/*X=047*/, 195/*X=051*/, 140/*X=068*/, 134/*X=075*/, 105/*X=084*/, 192/*X=097*/
	DB 049/*X=116*/, 039/*X=124*/, 023/*X=130*/, 019/*X=143*/, 023/*X=151*/, 123/*X=171*/, 063/*X=180*/, 082/*X=197*/, 104/*X=212*/, 187/*X=227*/
	DB 187/*X=236*/, 187/*X=232*/, 127/*X=264*/, 119/*X=272*/, 102/*X=287*/, 220/*X=308*/, 230/*X=319*/

starsLayer1

	SC {0/*BANK*/, 02/*X_OFSET*/, 6/*SIZE*/, 6/*BLINK*/, 0/*BCOLOR*/}	; X=2
	DB 12, 15, 70, 94, 160, 250

	SC {0/*BANK*/, 08/*X_OFSET*/, 5/*SIZE*/, 2/*BLINK*/, 0/*BCOLOR*/}	; X=8
	DB 5, 38, 120, 158, 245

	SC {0/*BANK*/, 20/*X_OFSET*/, 4/*SIZE*/, 4/*BLINK*/, 0/*BCOLOR*/}	; X=20
	DB 4, 42, 133, 245

	SC {1/*BANK*/, 05/*X_OFSET*/, 5/*SIZE*/, 1/*BLINK*/, 0/*BCOLOR*/}	; X=37
	DB 20, 80, 104, 150, 255

	SC {1/*BANK*/, 15/*X_OFSET*/, 5/*SIZE*/, 1/*BLINK*/, 0/*BCOLOR*/}	; X=47
	DB 10, 115, 130, 155, 230

	SC {1/*BANK*/, 19/*X_OFSET*/, 6/*SIZE*/, 2/*BLINK*/, 0/*BCOLOR*/}	; X=51
	DB 4, 90, 144, 148, 202, 251

	SC {2/*BANK*/, 04/*X_OFSET*/, 5/*SIZE*/, 5/*BLINK*/, 0/*BCOLOR*/}	; X=68
	DB 14, 52, 113, 189, 241

	SC {2/*BANK*/, 11/*X_OFSET*/, 4/*SIZE*/, 2/*BLINK*/, 0/*BCOLOR*/}	; X=75
	DB 21, 92, 158, 221

	SC {2/*BANK*/, 20/*X_OFSET*/, 5/*SIZE*/, 4/*BLINK*/, 0/*BCOLOR*/}	; X=84
	DB 31, 93, 159, 178, 248

	SC {3/*BANK*/, 01/*X_OFSET*/, 6/*SIZE*/, 1/*BLINK*/, 0/*BCOLOR*/}	; X=97
	DB 26, 45, 125, 138, 160, 193

	SC {3/*BANK*/, 20/*X_OFSET*/, 5/*SIZE*/, 3/*BLINK*/, 0/*BCOLOR*/}	; X=116
	DB 10, 104, 145, 190, 249

	SC {3/*BANK*/, 28/*X_OFSET*/, 4/*SIZE*/, 1/*BLINK*/, 0/*BCOLOR*/}	; X=124
	DB 86, 123, 158, 233

	SC {4/*BANK*/, 02/*X_OFSET*/, 6/*SIZE*/, 2/*BLINK*/, 0/*BCOLOR*/}	; X=130
	DB 21, 55, 80, 144, 148, 243

	SC {4/*BANK*/, 15/*X_OFSET*/, 6/*SIZE*/, 3/*BLINK*/, 0/*BCOLOR*/}	; X=143
	DB 47, 77, 93, 139, 188, 233

	SC {4/*BANK*/, 23/*X_OFSET*/, 6/*SIZE*/, 6/*BLINK*/, 0/*BCOLOR*/}	; X=151
	DB 5, 84, 98, 142, 168, 201

	SC {5/*BANK*/, 11/*X_OFSET*/, 5/*SIZE*/, 1/*BLINK*/, 0/*BCOLOR*/}	; X=171
	DB 38, 78, 132, 149, 231

	SC {5/*BANK*/, 20/*X_OFSET*/, 5/*SIZE*/, 4/*BLINK*/, 0/*BCOLOR*/}	; X=180
	DB 24, 44, 126, 160, 243

	SC {6/*BANK*/, 05/*X_OFSET*/, 3/*SIZE*/, 1/*BLINK*/, 0/*BCOLOR*/}	; X=197
	DB 64, 116, 174

	SC {6/*BANK*/, 20/*X_OFSET*/, 5/*SIZE*/, 3/*BLINK*/, 0/*BCOLOR*/}	; X=212
	DB 13, 44, 100, 143, 199

	SC {7/*BANK*/, 03/*X_OFSET*/, 5/*SIZE*/, 5/*BLINK*/, 0/*BCOLOR*/}	; X=227
	DB 55, 98, 120, 187, 255

	SC {7/*BANK*/, 12/*X_OFSET*/, 4/*SIZE*/, 2/*BLINK*/, 0/*BCOLOR*/}	; X=236
	DB 11, 82, 148, 213

	SC {7/*BANK*/, 30/*X_OFSET*/, 4/*SIZE*/, 4/*BLINK*/, 0/*BCOLOR*/}	; X=232
	DB 44, 113, 192, 253

	SC {8/*BANK*/, 08/*X_OFSET*/, 5/*SIZE*/, 0/*BLINK*/, 0/*BCOLOR*/}	; X=264
	DB 4, 39, 88, 133, 152

	SC {8/*BANK*/, 16/*X_OFSET*/, 3/*SIZE*/, 2/*BLINK*/, 0/*BCOLOR*/}	; X=272
	DB 3, 142, 241

	SC {8/*BANK*/, 31/*X_OFSET*/, 4/*SIZE*/, 4/*BLINK*/, 0/*BCOLOR*/}	; X=287
	DB 30, 103, 150, 189

	SC {9/*BANK*/, 20/*X_OFSET*/, 4/*SIZE*/, 4/*BLINK*/, 0/*BCOLOR*/}	; X=308
	DB 5, 36, 120, 211

	SC {9/*BANK*/, 31/*X_OFSET*/, 4/*SIZE*/, 1/*BLINK*/, 0/*BCOLOR*/}	; X=319
	DB 5, 102, 142, 240


;----------------------------------------------------------;
;                      #BlinkStars                         ;
;----------------------------------------------------------;
BlinkStars
	LD A, ST_SHOW
	LD (starsState), A

	CALL _RenderLayer1Stars

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                   #LoadStarsPalette                      ;
;----------------------------------------------------------;
LoadStarsPalette

	; Load colors for the stars.
	LD HL, starsPal
	LD A, _ST_PAL_D8
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
	CALL _RenderLayer1Stars

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       #HideStars                         ;
;----------------------------------------------------------;
HideStars

	LD A, ST_HIDDEN
	LD (starsState), A

	; Render
	CALL _RenderLayer1Stars

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                      #ReloadStars                        ;
;----------------------------------------------------------;
ReloadStars

	; Show stars only if enabled.
	LD A, (starsState)
	CP ST_C_HIDDEN
	RET C

	; Render
	CALL _RenderLayer1Stars

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                      #MoveStarsUp                        ;
;----------------------------------------------------------;
MoveStarsUp
	
	;###########################################
	; Move stars only if enabled.
	LD A, (starsState)
	CP ST_C_HIDDEN
	RET C

	;###########################################
	; Delay movement
	LD A, (starsMoveDelay)
	DEC A
	LD (starsMoveDelay), A
	CP 0
	RET NZ										; Do not move yet, wait for 0.
	
	; Reset delay
	LD A, _ST_L1_MOVE_DEL_D4
	LD (starsMoveDelay), A

	;###########################################
	; Update state
	LD A, ST_MOVE_UP
	LD (starsState), A

	;###########################################
	; Render
	CALL _RenderLayer1Stars

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                     #MoveStarsDown                       ;
;----------------------------------------------------------;
MoveStarsDown
	
	;###########################################
	; Move stars only if enabled.
	LD A, (starsState)
	CP ST_C_HIDDEN
	RET C

	;###########################################
	; Delay movement
	LD A, (starsMoveDelay)
	DEC A
	LD (starsMoveDelay), A
	CP 0
	RET NZ										; Do not move yet, wait for 0.
	
	; Reset delay
	LD A, _ST_L1_MOVE_DEL_D4
	LD (starsMoveDelay), A

	;###########################################
	; Update state
	LD A, ST_MOVE_DOWN
	LD (starsState), A

	;###########################################
	; Render
	CALL _RenderLayer1Stars

	RET											; ## END of the function ##

randColorCnt			BYTE 0
;----------------------------------------------------------;
;                     #NextStarColor                       ;
;----------------------------------------------------------;
NextStarColor

	; ##########################################
	; Move the color index to the next position.
	LD A, (starsPalPos)
	INC A
	LD (starsPalPos), A

	CP _ST_PAL_D8
	JR NZ, .afterColorIndex

	; The counter reached the max value, reset it.
	LD A, _ST_PAL_FIRST_D1						; Reset to the second color in the stars palette, the first color is used for all remaining stars.
	LD (starsPalPos), A

.afterColorIndex

	; ##########################################
	; Store color index in #SC

	LD HL, starsLayer1							; HL points to the first stars column
	
	LD B, _ST_SC_D27
.columnsLoop
	LD IX, HL

	LD A, (IX + SC.BLINK)
	CP SC_BLINK_OFF
	JR Z, .nextColumn

	; ##########################################
	; The star in this column is blinking. However, it changes the color randomly.
	LD A, (randColorCnt)
	INC A
	LD (randColorCnt), A
	LD A, C
	LD A, R 									; Load the random number into A register
	CP C
	JR C, .nextColumn

	; Change the color
	LD A, (btd.palColors)
	LD C, A
	LD A, (starsPalPos)
	ADD C
	LD (IX + SC.BCOLOR), A

.nextColumn
	; ##########################################
	; Move HL to the next stars column.
	LD A, SC									; Move HL after SC
	ADD HL, A

	LD A, (IX + SC.SIZE)						; Move HL after pixel data of the current stars column.
	ADD HL, A
	DJNZ .columnsLoop
	
	RET											; ## END of the function ##
	
;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;               #_RenderLayer1Stars                        ;
;----------------------------------------------------------;
_RenderLayer1Stars

	LD A, _ST_SC_D27
	LD HL, starsLayer1							; HL points to the first stars column
	CALL _RenderStars

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                   #_RenderStars                          ;
;----------------------------------------------------------;
; Input:
;  - A:  Number of stars columns (#SC)
;  - HL: Pointer to first #SC
_RenderStars
	LD B, A

	; Loop over all stars
	LD IY, starsLayer1MaxY
.columnsLoop

	LD IX, HL
	PUSH IX, HL, BC
	CALL _RenderStarColumn
	POP BC, HL, IX

	; Move HL to the next stars column.
	LD A, SC									; Move HL after SC
	ADD HL, A

	LD A, (IX + SC.SIZE)						; Move HL after pixel data of the current stars column.
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
	; DE will point to the address of the column that will contain starts. X_OFSET * 256 = X_OFSET * 255 + X_OFSET.
	LD D, (IX + SC.X_OFSET)
	LD E, _SC_RESY1_D255
	MUL D, E
	LD A, (IX + SC.X_OFSET)
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
	; HL: Ppoints to the first source pixel from stars column.
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
	JR NZ, .afterPaintStar						; Skipp this star if it cannot be hidden.

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

	PUSH DE										; Keep DE to point to the top of the column on the destination image.
	LD B, (HL)									; A contains the position of the already moved star.
	CALL _CanShowStar
	POP DE
	
	CP CANSS_YES
	JR NZ, .afterPaintStar						; Skipp this star if it cannot be painted.

	; Paint star on new postion
	LD A, (HL)									; A contains the position of the already moved star.
	ADD DE, A									; DE contains a byte offset to a current column in the destination image, plus A will give the final star position.

	POP BC										; Restore B
	PUSH BC
	CALL _GetStarColor							; Load star color
	;LD A, 2
	LD (DE), A

.afterPaintStar

	; ##########################################
	; Keep looping over stars in the column.
	INC HL										; Move to the next pixel.

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
;  - B:  Reversed position of a blinking star.
;  - IX: Pointer to SC
; Output:
;  A: contains next star color.
; Modifies: A, B
_GetStarColor

	; Is blinking enabled?
	LD A, (IX + SC.BLINK)
	CP SC_BLINK_OFF
	JR Z, .loadFirstColor

	; Blink is enabled, now check whether the star position in the column matches SC.BLINK.
	CP B
	JR NZ, .loadFirstColor
	
	; This star is blinking
	LD A, (IX + SC.BCOLOR)

	RET

.loadFirstColor

	LD A, (btd.palColors)						; Return the first color.

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE