;----------------------------------------------------------;
;                        Globals                           ;
;----------------------------------------------------------;
JetX					BYTE 100				; 0-320px
JetY 					BYTE 100				; 0-256px

; Possible move directions
JET_DIR_LEFT_BIT		EQU 0					; Bit 0 - Jetman moving left
JET_DIR_LEFT_BM			EQU %00000001	

JET_DIR_RIGHT_BIT		EQU 1					; Bit 1 - Jetman moving right
JET_DIR_RIGHT_BM		EQU %00000010

JET_DIR_UP_BIT			EQU 2					; Bit 2 - Jetman moving up
JET_DIR_UP_BM			EQU %00000100		

JET_DIR_DOWN_BIT		EQU 3					; Bit 3 - Jetman moving down
JET_DIR_DOWN_BM			EQU %00001000

jetMoveDirection 		BYTE JET_DIR_DOWN_BM	; Current moving direction.

;  #jetSprPaterntIdx and #etSprPaternEnd contain data for currently executed animation, #jetSprPaterntNextID contains an ID 
; for the animation that will play once the current has ended.
jetSprPaterntIdx		BYTE 6					; Current index  of Jetman's sprite pattern
jetSprPaternEnd			BYTE 9					; End offset (inculsive) of Jetman's sprite pattern
jetSprPaterntNextID		BYTE JET_SDB_FALL		; ID in #jetSpriteDB for next animation

; IDs for #jetSpriteDB
JET_SDB_FLY				EQU 201								; Jetman is flaying
JET_SDB_LAND			EQU 202								; Jetman is landing
JET_SDB_WALK			EQU 203								; Jetman is walking
JET_SDB_START			EQU 203								; Jetman is starting
JET_SDB_FALL			EQU 205								; Jetman is falling down
JET_SDB_DIR				EQU 206								; Jetman changes direction left/right

JET_SDB_RS				EQU 3								; Sieze of single sprite DB record
JET_SDB_OFF_ST			EQU 0								; DB offset from ID to pattern start
JET_SDB_OFF_EN			EQU 1								; DB offset from ID to pattern end
JET_SDB_OFF_NX			EQU 2								; DB offset from ID to next record
JET_SDB_OFF_NX_ADD		EQU -100							; -100 for OFF_NX that CPIR finds ID and not OFF_NX


; The animation system uses a state machine. It's a DB where each record contains a start and end offset to the animation pattern and 
; finally offset to a new DB record containing animation that will be played next.
; DB Record:[ID], [OFF_ST: sprite offset start], [OFF_EN: sprite offset end], [OFF_NX:next animation ID-100]
jetSpriteDB				DB JET_SDB_FLY,		00, 02, JET_SDB_FLY		+ JET_SDB_OFF_NX_ADD
						DB JET_SDB_LAND,	01, 12, JET_SDB_WALK	+ JET_SDB_OFF_NX_ADD
						DB JET_SDB_WALK,	16, 18, JET_SDB_WALK	+ JET_SDB_OFF_NX_ADD
						DB JET_SDB_WALK,	44, 47, JET_SDB_FLY		+ JET_SDB_OFF_NX_ADD
						DB JET_SDB_FALL, 	06, 09, JET_SDB_FLY		+ JET_SDB_OFF_NX_ADD
						DB JET_SDB_DIR, 	06, 07, JET_SDB_FLY		+ JET_SDB_OFF_NX_ADD				

JET_SDB_ID				EQU $0					; ID of Jetman/Player sprite

;----------------------------------------------------------;
;                     #IntiJetman                          ;
;----------------------------------------------------------;
IntiJetman

	; Load Sprite
	NEXTREG SPR_NR, JET_SDB_ID					; Set the ID of the Jetman's sprite for the following commands

	LD A, (JetX)								; Set X position
	NEXTREG SPR_X, A						

	LD A, (JetY)								; Set Y position
	NEXTREG SPR_Y, A						

	NEXTREG SPR_ATTR_2, %00000000 				; Palette offset, no mirror, no rotation

	; bit 7 = Visible flag (1 = displayed)
	; bits 5-0 = Pattern used by sprite (0-63), we will use pattern 0
	NEXTREG SPR_ATTR_3, %10000000
	RET

;----------------------------------------------------------;
;              #ChangeJetmanSpritePattern                  ;
;----------------------------------------------------------;
; Input:
;   - A: Number of a sprite pattern from #jesSprites
ChangeJetmanSpritePattern
	RET
;----------------------------------------------------------;
;            #UpdateJetmanSpritePattern                    ;
;----------------------------------------------------------;
; Update sprite pattern - next animation frame.
UpdateJetmanSpritePattern
	LD HL, jetSprPaterntIdx
	INC (HL)

	LD A, (jetSprPaternEnd)
	LD B, A
	LD A, (HL)
	INC B
	CP B										; Are we at last pattern (#jetSprPaterntIdx == #jetSprPaternEnd)? -> reset to 0	
	JR NZ, .updateRegister

	; The sprite pattern is done, switch to a new one.
	LD HL, jetSpriteDB							; HL points to the beginning of the animation patterns DB
	LD A, (jetSprPaterntNextID)					; CPIR will keep increasing HL until it finds record ID from A
	LD BC, 0									; Do not limit CPIR search
	CPIR

	; Now, HL points to the ID of the next record, which contains data for the new animation pattern.
	LD IX, HL

	LD A, (IX + JET_SDB_OFF_ST)
	LD (jetSprPaterntIdx), A

	LD A, (IX + JET_SDB_OFF_EN)
	LD (jetSprPaternEnd), A

	LD A, (IX + JET_SDB_OFF_NX)
	ADD 100
	LD (jetSprPaterntNextID), A					; ID for the following animation pattern that will play once this one is done.

.updateRegister	
	LD A, (jetSprPaterntIdx)
	OR %10000000								; Store pattern number into Sprite Attribute	
	NEXTREG SPR_ATTR_3, A	
	RET
;----------------------------------------------------------;
;                    #UpdateJetman                         ;
;----------------------------------------------------------;
UpdateJetman:
	; Update Sprite
	NEXTREG SPR_NR, JET_SDB_ID					; Set the ID of the Jetman's sprite for the following commands

	LD A, (JetX)								; Set X position
	NEXTREG SPR_X, A						

	LD A, (JetY)								; Set Y position
	NEXTREG SPR_Y, A	

	RET
;----------------------------------------------------------;
;                    Handle Movement                       ;
;----------------------------------------------------------;
MoveUp:
	; Update Y position
	LD A, (JetY)	
	DEC A
	LD (JetY), A
	RET

MoveDown:
	; Update Y position
	LD A, (JetY)	
	INC A
	LD (JetY), A
	RET

MoveRight:
	; Update X position
	LD A, (JetX)	
	INC A
	LD (JetX), A

	; Direction change?
	LD A, (jetMoveDirection)
	AND JET_DIR_RIGHT_BM						; Are we moving right already?
	CP JET_DIR_RIGHT_BM
	JR Z, .noDirectionChange

	; Nope - we have direction change!
	LD A, JET_SDB_DIR							; Play animatin on direction change
	CALL ChangeJetmanSpritePattern
	
	LD A, (jetMoveDirection)					; Update #jetMoveDirection by reseting Left and setting Right
	RES JET_DIR_LEFT_BIT, A
	SET JET_DIR_RIGHT_BIT, A
	LD (jetMoveDirection), A

.noDirectionChange
	RET

MoveLeft:
	; Update X position
	LD A, (JetX)	
	DEC A
	LD (JetX), A

	; Direction change?
	LD A, (jetMoveDirection)
	AND JET_DIR_LEFT_BM							; Are we moving right already?
	CP JET_DIR_LEFT_BM
	JR Z, .noDirectionChange

	; Nope - we have direction change!
	LD A, JET_SDB_DIR							; Play animatin on direction change
	CALL ChangeJetmanSpritePattern
	
	LD A, (jetMoveDirection)					; Update #jetMoveDirection by reseting Right and setting Left
	RES JET_DIR_RIGHT_BIT, A
	SET JET_DIR_LEFT_BIT, A
	LD (jetMoveDirection), A
	JR $

.noDirectionChange
	RET	

PressFire:
	RET
