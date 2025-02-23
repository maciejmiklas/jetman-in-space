;----------------------------------------------------------;
;          Stars for Layer 2 bitmap at 320x256              ;
;----------------------------------------------------------;
	module st

; The starfield (#SF) is grouped into columns (#SC). When Jetman moves, the whole starfield and, respectively, all columns move in the 
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
;   [SF.COLOR], [SK.SIZE],  SK.SIZE*([SC.X_OFSET], [SC.Y_MAX], [SC.SIZE], SC.SIZE*[star y postion])

	STRUCT SF									; Starfield
; Static data	
COLOR					BYTE					; Color for the sky.
SIZE					BYTE					; Amount ot the columns.
	ENDS

	STRUCT SC									; Stars column.
BANK					BYTE					; Bank number from 0 to 9.
X_OFSET					BYTE					; X offset from the beginning of the bank, max 32 (32=8192/256)
Y_MAX					BYTE					; Max horizontal position (0-255) for this column. Starts reaching it will be hidden.
SIZE					BYTE
	ENDS

stars
	SF {240/*COLOR*/, 027/*SIZE*/}

	SC {0/*BANK*/, 05/*X_OFSET*/, 100/*Y_MAX*/, 04/*SIZE*/}
	DB 12, 15, 70, 94

	SC {0/*BANK*/, 10/*X_OFSET*/, 100/*Y_MAX*/, 04/*SIZE*/}
	DB 5, 38, 120, 158

	SC {0/*BANK*/, 20/*X_OFSET*/, 100/*Y_MAX*/, 03/*SIZE*/}
	DB 4, 42, 133

	SC {1/*BANK*/, 05/*X_OFSET*/, 100/*Y_MAX*/, 04/*SIZE*/}
	DB 20, 80, 104, 150

	SC {1/*BANK*/, 15/*X_OFSET*/, 100/*Y_MAX*/, 04/*SIZE*/}
	DB 10, 115, 130, 155

	SC {1/*BANK*/, 17/*X_OFSET*/, 100/*Y_MAX*/, 04/*SIZE*/}
	DB 4, 90, 144, 148

	SC {2/*BANK*/, 04/*X_OFSET*/, 100/*Y_MAX*/, 03/*SIZE*/}
	DB 14, 52, 113

	SC {2/*BANK*/, 11/*X_OFSET*/, 100/*Y_MAX*/, 03/*SIZE*/}
	DB 21, 92, 158

	SC {2/*BANK*/, 20/*X_OFSET*/, 100/*Y_MAX*/, 03/*SIZE*/}
	DB 31, 93, 159

	SC {3/*BANK*/, 05/*X_OFSET*/, 100/*Y_MAX*/, 05/*SIZE*/}
	DB 26, 45, 125, 138, 160

	SC {3/*BANK*/, 20/*X_OFSET*/, 100/*Y_MAX*/, 03/*SIZE*/}
	DB 10, 104, 145

	SC {3/*BANK*/, 28/*X_OFSET*/, 100/*Y_MAX*/, 03/*SIZE*/}
	DB 86, 123, 158

	SC {4/*BANK*/, 02/*X_OFSET*/, 100/*Y_MAX*/, 05/*SIZE*/}
	DB 21, 55, 80, 144, 148

	SC {4/*BANK*/, 15/*X_OFSET*/, 100/*Y_MAX*/, 04/*SIZE*/}
	DB 47, 77, 93, 139

	SC {4/*BANK*/, 23/*X_OFSET*/, 100/*Y_MAX*/, 04/*SIZE*/}
	DB 5, 84, 98, 142

	SC {5/*BANK*/, 11/*X_OFSET*/, 100/*Y_MAX*/, 04/*SIZE*/}
	DB 38, 78, 132, 149

	SC {5/*BANK*/, 20/*X_OFSET*/, 100/*Y_MAX*/, 04/*SIZE*/}
	DB 24, 44, 126, 160

	SC {6/*BANK*/, 05/*X_OFSET*/, 100/*Y_MAX*/, 02/*SIZE*/}
	DB 64, 116

	SC {6/*BANK*/, 20/*X_OFSET*/, 100/*Y_MAX*/, 04/*SIZE*/}
	DB 13, 44, 100, 143

	SC {7/*BANK*/, 03/*X_OFSET*/, 100/*Y_MAX*/, 03/*SIZE*/}
	DB 55, 98, 120

	SC {7/*BANK*/, 12/*X_OFSET*/, 100/*Y_MAX*/, 03/*SIZE*/}
	DB 11, 82, 148

	SC {7/*BANK*/, 30/*X_OFSET*/, 100/*Y_MAX*/, 02/*SIZE*/}
	DB 44, 113

	SC {8/*BANK*/, 8/*X_OFSET*/, 100/*Y_MAX*/, 5/*SIZE*/}
	DB 4, 39, 88, 133, 152

	SC {8/*BANK*/, 16/*X_OFSET*/, 100/*Y_MAX*/, 02/*SIZE*/}
	DB 3, 142

	SC {8/*BANK*/, 31/*X_OFSET*/, 100/*Y_MAX*/, 03/*SIZE*/}
	DB 30, 103, 150

	SC {9/*BANK*/, 20/*X_OFSET*/, 100/*Y_MAX*/, 03/*SIZE*/}
	DB 5, 36, 120

	SC {9/*BANK*/, 31/*X_OFSET*/, 100/*Y_MAX*/, 03/*SIZE*/}
	DB 5, 102, 142
;----------------------------------------------------------;
;                     #LoadStars                           ;
;----------------------------------------------------------;
LoadStars

	; HL will point to the first stars column
	LD HL, stars
	LD A, SF									; Move HL after #SF, where the first #SC begins.
	ADD HL, A

	; Loop over all stars
	LD IX, stars
	LD B, (IX + SF.SIZE)
.columnsLoop

	LD IX, HL
	PUSH IX, HL, BC
	CALL _LoadStarColumn
	POP BC, HL, IX

	; Move HL to the next stars column.
	LD A, SC									; Move HL after SC
	ADD HL, A

	LD A, (IX + SC.SIZE)						;  Move HL after pixel data of the current stars column.
	ADD HL, A

	DJNZ .columnsLoop	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                   #_LoadStarColumn                       ;
;----------------------------------------------------------;
; Input 
;  - IX - Pointer to SC
_LoadStarColumn

	;call ut.Pause
	;call ut.Pause

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
	
.pixelLoop
	PUSH DE										;  Keep DE so it always points to the top of the column in the picture.

	; Move DE to current pixel in the column on the picure.
	LD A, (HL)
	ADD DE, A

	LD A, $17
	LD (DE), A									; Set star color
	INC HL										; Move to the next pixel

	POP DE
	DJNZ .pixelLoop

	RET											; ## END of the function ##
;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE