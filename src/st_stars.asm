;----------------------------------------------------------;
;          Stars for Layer 2 bitmap at 320x256              ;
;----------------------------------------------------------;
	module st

; The starfield is grouped into columns (#SC). When Jetman moves, the whole starfield and, respectively, all columns move in the 
; opposite direction. 
; The image on Layer 2 splits over 10 banks, each containing 32 columns, 256 pixels long. 
; Each star column (#SC) is assigned to a concrete bank and contains precisely one column with starts that will be injected into the picture.
; This column can be 256 pixels long and contains #SF.SIZE stars. Each star's vertical (Y) position is given as an offset from the top of 
; the screen. 
; #SC.X_OFSET defines the placement of a star column within the memory bank -  this is the image column within this particular bank where 
; stars will be injected.
; Because starfield moves together with Jetmanl, a new position for each star in this row is calculated by adding an offset value to each 
; start position with every move. Each column rolls from the bottom to the top when its position byte overflows. Each column also has a 
; maximal horizontal position (#SC.Y_MAX), after which the starts will not be painted to avoid overlapping with the background image.
; Memory organization:
;   [SF.COLOR], [SK.SIZE],  SK.SIZE*([SC.X_OFSET], [SC.Y_MAX], [SC.SIZE], SC.SIZE*[star y position])

	STRUCT SF									; Starfield
; Static data	
COLOR					BYTE					; Color for the sky.
SIZE					BYTE					; Amount ot the columns.
	ENDS

	STRUCT SC									; Stars column.
BANK					BYTE					; Bank number from 0 to 9.
X_OFSET					BYTE					; X offset from the beginning of the bank, max 32 (32=8192/256)
SIZE					BYTE					; Amount of stars.
	ENDS


ST_HIDDEN				= 0
ST_C_HIDDEN				= ST_HIDDEN +1			; Value for RET C
ST_SHOW					= 1
ST_MOVE_UP				= 3
ST_MOVE_DOWN			= 4
starsState				BYTE ST_SHOW

starsDelay1				BYTE _GB_LAYER1_DELAY_D4 ; Delay counter for stars on layer 1 (there are 2 layers of stars).

; Max horizontal star position for each column (#SC). Starts reaching it will be hidden.
starsLayer1MaxY
	DB 143/*X=2*/, 154/*X=8*/, 159/*X=20*/, 196/*X=37*/, 195/*X=47*/, 195/*X=51*/, 140/*X=68*/, 134/*X=75*/, 105/*X=84*/, 192/*X=97*/
	DB 049/*X=116*/, 039/*X=124*/, 023/*X=130*/, 019/*X=143*/, 023/*X=151*/, 123/*X=171*/, 063/*X=180*/, 082/*X=197*/, 104/*X=212*/
	DB 187/*X=227*/, 187/*X=236*/, 187/*X=232*/, 127/*X=264*/, 119/*X=272*/, 102/*X=287*/, 220/*X=308*/, 230/*X=319*/

starsLayer1
	;SC {0/*BANK*/, 02/*X_OFSET*/, 1/*SIZE*/}	; X=2
	;DB 40, 50, 60, 70, 80, 90, 100, 105, 110, 115, 120, 130, 140, 142, 144, 146, 148, 150, 160, 170, 180, 190, 200, 210, 220, 230, 240, 250

	SC {0/*BANK*/, 02/*X_OFSET*/, 06/*SIZE*/}	; X=2
	DB 12, 15, 70, 94, 160, 250

	SC {0/*BANK*/, 08/*X_OFSET*/, 05/*SIZE*/}	; X=8
	DB 5, 38, 120, 158, 245

	SC {0/*BANK*/, 20/*X_OFSET*/, 04/*SIZE*/}	; X=20
	DB 4, 42, 133, 245

	SC {1/*BANK*/, 05/*X_OFSET*/, 05/*SIZE*/}	; X=37
	DB 20, 80, 104, 150, 255

	SC {1/*BANK*/, 15/*X_OFSET*/, 05/*SIZE*/}	; X=47
	DB 10, 115, 130, 155, 230

	SC {1/*BANK*/, 19/*X_OFSET*/, 06/*SIZE*/}	; X=51
	DB 4, 90, 144, 148, 202, 251

	SC {2/*BANK*/, 04/*X_OFSET*/, 05/*SIZE*/}	; X=68
	DB 14, 52, 113, 189, 241

	SC {2/*BANK*/, 11/*X_OFSET*/, 04/*SIZE*/}	; X=75
	DB 21, 92, 158, 221

	SC {2/*BANK*/, 20/*X_OFSET*/, 05/*SIZE*/}	; X=84
	DB 31, 93, 159, 178, 248

	SC {3/*BANK*/, 01/*X_OFSET*/, 06/*SIZE*/}	; X=97
	DB 26, 45, 125, 138, 160, 193

	SC {3/*BANK*/, 20/*X_OFSET*/, 05/*SIZE*/}	; X=116
	DB 10, 104, 145, 190, 249

	SC {3/*BANK*/, 28/*X_OFSET*/, 04/*SIZE*/}	; X=124
	DB 86, 123, 158, 233

	SC {4/*BANK*/, 02/*X_OFSET*/, 06/*SIZE*/}	; X=130
	DB 21, 55, 80, 144, 148, 243

	SC {4/*BANK*/, 15/*X_OFSET*/, 06/*SIZE*/}	; X=143
	DB 47, 77, 93, 139, 188, 233

	SC {4/*BANK*/, 23/*X_OFSET*/, 06/*SIZE*/}	; X=151
	DB 5, 84, 98, 142, 168, 201

	SC {5/*BANK*/, 11/*X_OFSET*/, 05/*SIZE*/}	; X=171
	DB 38, 78, 132, 149, 231

	SC {5/*BANK*/, 20/*X_OFSET*/, 05/*SIZE*/}	; X=180
	DB 24, 44, 126, 160, 243

	SC {6/*BANK*/, 05/*X_OFSET*/, 03/*SIZE*/}	; X=197
	DB 64, 116, 174

	SC {6/*BANK*/, 20/*X_OFSET*/, 05/*SIZE*/}	; X=212
	DB 13, 44, 100, 143, 199

	SC {7/*BANK*/, 03/*X_OFSET*/, 05/*SIZE*/}	; X=227
	DB 55, 98, 120, 187, 255

	SC {7/*BANK*/, 12/*X_OFSET*/, 04/*SIZE*/}	; X=236
	DB 11, 82, 148, 213

	SC {7/*BANK*/, 30/*X_OFSET*/, 04/*SIZE*/}	; X=232
	DB 44, 113, 192, 253

	SC {8/*BANK*/, 8/*X_OFSET*/, 05/*SIZE*/}	; X=264
	DB 4, 39, 88, 133, 152

	SC {8/*BANK*/, 16/*X_OFSET*/, 03/*SIZE*/}	; X=272
	DB 3, 142, 241

	SC {8/*BANK*/, 31/*X_OFSET*/, 04/*SIZE*/}	; X=287
	DB 30, 103, 150, 189

	SC {9/*BANK*/, 20/*X_OFSET*/, 04/*SIZE*/}	; X=308
	DB 5, 36, 120, 211

	SC {9/*BANK*/, 31/*X_OFSET*/, 04/*SIZE*/}	; X=319
	DB 5, 102, 142, 240


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
	LD A, (starsDelay1)
	DEC A
	LD (starsDelay1), A
	CP 0
	RET NZ										; Do not move yet, wait for 0.
	
	; Reset delay
	LD A, _GB_LAYER1_DELAY_D4
	LD (starsDelay1), A

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
	LD A, (starsDelay1)
	DEC A
	LD (starsDelay1), A
	CP 0
	RET NZ										; Do not move yet, wait for 0.
	
	; Reset delay
	LD A, _GB_LAYER1_DELAY_D4
	LD (starsDelay1), A

	;###########################################
	; Update state
	LD A, ST_MOVE_DOWN
	LD (starsState), A

	;###########################################
	; Render
	CALL _RenderLayer1Stars

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

	LD A, _GB_LAYER1_STARSC_D27
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

	; Loop over all stars
	LD B, A
	LD IY, starsLayer1MaxY
.columnsLoop

	LD IX, HL
	PUSH IX, HL, BC
	CALL _RenderStarColumn
	POP BC, HL, IX

	; Move HL to the next stars column.
	LD A, SC									; Move HL after SC
	ADD HL, A

	LD A, (IX + SC.SIZE)						;  Move HL after pixel data of the current stars column.
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
	; DE: Ppoints to the top destination pixel (byte) in the column on the background (destination) image.
	; IY: Points to the current max y postion for the star (from #starsMaxYLevel[0-9]).
	; In this loop, we will copy one column of the stars from the source data (HL) into the layer 2 image (DE) column.

.pixelLoop
	PUSH DE, BC										;  Keep DE so it always points to the top of the column in the image.

	; ##########################################
	; Move star up/down or just show it.
	LD A, (starsState)
	
	; Do not move star if the command only shows it.
	CP ST_SHOW
	JR NZ, .afterOnlyShow

	; Only show the current star without movement?
	LD A, (HL)									; A contains current star position.
	JR .showStar

.afterOnlyShow

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
	LD A, _GB_PAL_TRANSP_D0
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
	LD A, 47 ;TODO
	LD (DE), A

.afterPaintStar

	; ##########################################
	; Keep looping over stars in the column.
	INC HL										; Move to the next pixel.
	POP BC, DE
	DJNZ .pixelLoop

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
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE