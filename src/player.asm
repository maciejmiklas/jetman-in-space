;----------------------------------------------------------;
;                        Globals                           ;
;----------------------------------------------------------;
JetX					WORD 100				; 0-320px
JetY 					BYTE 100				; 0-256px

; Possible move directions
JET_STATE_LEFT_BIT		EQU 0					; Bit 0 - Jetman moving left
JET_STATE_LEFT_BM		EQU %00000001	

JET_STATE_RIGHT_BIT		EQU 1					; Bit 1 - Jetman moving right
JET_STATE_RIGHT_BM		EQU %00000010

JET_STATE_UP_BIT		EQU 2					; Bit 2 - Jetman moving up
JET_STATE_UP_BM			EQU %00000100		

JET_STATE_DOWN_BIT		EQU 3					; Bit 3 - Jetman moving down
JET_STATE_DOWN_BM		EQU %00001000

JET_STATE_HOVER_BIT		EQU 4					; Bit 3 - Jetman hoovers
JET_STATE_HOVER_BM		EQU %00010000

jetState 				BYTE %00010010			; Hoover, face Rright

; #jetSprPaterntIdx and #etSprPaternEnd contain data for currently executed animation, #jetSprPaterntNextID contains an ID 
; for the animation that will play once the current has ended.
jetSprPaterntIdx		BYTE 6					; Current index  of Jetman's sprite pattern
jetSprPaternEnd			BYTE 9					; End offset (inculsive) of Jetman's sprite pattern
jetSprPaterntNextID		BYTE JET_SDB_FLY		; ID in #jetSpriteDB for next animation

; IDs for #jetSpriteDB
JET_SDB_FLY				EQU 201								; Jetman is flaying
JET_SDB_LAND			EQU 202								; The transition from flaying to walking
JET_SDB_WALK			EQU 203								; Jetman is walking
JET_SDB_WF				EQU 203								; The transition from walking to flaying
JET_SDB_DOWN			EQU 205								; Jetman is moving down
JET_SDB_HOVER			EQU 207								; Jetman hoovers
JET_SDB_HU				EQU 207								; The transition from hoovering to going up

JET_SDB_RS				EQU 3								; Sieze of single sprite DB record
JET_SDB_OFF_ST			EQU 0								; DB offset from ID to pattern start
JET_SDB_OFF_EN			EQU 1								; DB offset from ID to pattern end
JET_SDB_OFF_NX			EQU 2								; DB offset from ID to next record
JET_SDB_OFF_NX_ADD		EQU -100							; -100 for OFF_NX that CPIR finds ID and not OFF_NX


; The animation system uses a state machine. It's a DB where each record contains a start and end offset to the animation pattern and 
; finally offset to a new DB record containing animation that will be played next.
; DB Record:[ID], [OFF_ST: sprite offset start], [OFF_EN: sprite offset end], [OFF_NX:next animation ID-100]
jetSpriteDB				DB JET_SDB_FLY,		36, 37, JET_SDB_FLY		+ JET_SDB_OFF_NX_ADD
						DB JET_SDB_LAND,	01, 12, JET_SDB_WALK	+ JET_SDB_OFF_NX_ADD
						DB JET_SDB_WALK,	00, 03, JET_SDB_WALK	+ JET_SDB_OFF_NX_ADD
						DB JET_SDB_WF,		44, 47, JET_SDB_FLY		+ JET_SDB_OFF_NX_ADD
						DB JET_SDB_DOWN, 	06, 09, JET_SDB_DOWN	+ JET_SDB_OFF_NX_ADD						
						DB JET_SDB_HOVER, 	40, 42, JET_SDB_HOVER	+ JET_SDB_OFF_NX_ADD
						DB JET_SDB_HU, 		38, 39, JET_SDB_HOVER	+ JET_SDB_OFF_NX_ADD

JET_SDB_ID				EQU $0					; ID of Jetman/Player sprite

;----------------------------------------------------------;
;                     #IntiJetman                          ;
;----------------------------------------------------------;
IntiJetman

	; Load Sprite
	NEXTREG SPR_NR, JET_SDB_ID					; Set the ID of the Jetman's sprite for the following commands

	CALL UpdateJetmanSpritePosition							

	NEXTREG SPR_ATTR_2, %00000000 				; Palette offset, no mirror, no rotation

	; bit 7 = Visible flag (1 = displayed)
	; bits 5-0 = Pattern used by sprite (0-63), we will use pattern 0
	NEXTREG SPR_ATTR_3, %10000000
	RET

;----------------------------------------------------------;
;               #UpdateJetmanSpritePosition                ;
;----------------------------------------------------------;
UpdateJetmanSpritePosition	

	; ### Move Jetman Sprite to the current X position, the 9-bit value requires a few tricks. ###
	LD BC, (JetX)								
	LD A, C										
	NEXTREG SPR_X, A			; Set LSB from BC into X, below in next lines we handle overflow bit
	LD A, B						; Load MSB from X into A
	AND %00000001				; Keep only an overflow bit

	; ### Rotate sprite for Left/Right movement	####
	LD E, A						; Store A in E to use A for loading data from RAM.
	LD A, (jetState)			
	LD D, A
	LD A, E						; Now, A has it's original value, and D contains a value from #jetState
	BIT JET_STATE_LEFT_BIT, D	; Moving Left bit set?
	JR Z, .rotateRight
	SET 3, A					; Rotate sprite Left	
	JR .afterRotate	
.rotateRight	
	RES 3, A					; Rotate sprite Right
.afterRotate

	; ### Update Attr 2 ###
	NEXTREG SPR_ATTR_2, A		

	; ### Move Jetman Sprite to current Y postion, 8-bit value is easy ####
	LD A, (JetY)								
	NEXTREG SPR_Y, A			; Set Y position

	RET
;----------------------------------------------------------;
;              #ChangeJetmanSpritePattern                  ;
;----------------------------------------------------------;
; Input:
;   - A: Number of a sprite pattern from #jesSprites
ChangeJetmanSpritePattern
	LD (jetSprPaterntNextID), A

	LD (jetSprPaterntIdx), A					; Set both to the same value to quickly end the current animation
	LD (jetSprPaternEnd), A
	RET
;----------------------------------------------------------;
;            #UpdateJetmanSpritePattern                    ;
;----------------------------------------------------------;
; Update sprite pattern - next animation frame.
UpdateJetmanSpritePattern
	NEXTREG SPR_NR, JET_SDB_ID					; Set the ID of the Jetman's sprite for the following commands

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

	LD A, (IX + JET_SDB_OFF_ST)					; Update #jetSprPaterntIdx
	LD (jetSprPaterntIdx), A

	LD A, (IX + JET_SDB_OFF_EN)					; Update #jetSprPaternEnd
	LD (jetSprPaternEnd), A

	LD A, (IX + JET_SDB_OFF_NX)					; Update #jetSprPaterntNextID
	ADD 100
	LD (jetSprPaterntNextID), A					; ID for the following animation pattern that will play once this one is done.

.updateRegister	
	LD A, (jetSprPaterntIdx)
	OR %10000000								; Store pattern number into Sprite Attribute	
	NEXTREG SPR_ATTR_3, A	
	RET
;----------------------------------------------------------;
;                    Handle Movement                       ;
;----------------------------------------------------------;
MoveUp:
	; Decrement Y position
	LD A, (JetY)	
	CP DI_Y_MIN_POS 							; Do not decrement if Jetman has reached the top of the screen.
	JR Z, .afterDec
	DEC A
	LD (JetY), A
.afterDec	

	RET

MoveDown:
	; ### Increment Y position ###
	LD A, (JetY)
	CP DI_Y_MAX_POS								; Do not increment if Jetman has reached the bottom of the screen.
	JR Z, .afterInc						
	INC A
	LD (JetY), A
.afterInc	
/*
	; ### Direction change? ### 
	LD A, (jetState)
	AND JET_STATE_UP_BM							; Are we moving up already?
	CP JET_STATE_UP_BM
	JR Z, .noDirectionChange

	; We have direction change!
	LD A, JET_SDB_FLY							; Play animatin on direction change
	CALL ChangeJetmanSpritePattern
	
	LD A, (jetState)	xxxx					; Update #jetState by reseting hoover/down and setting Right
	RES JET_STATE_LEFT_BIT, A					; Reset Left as we are going now right	
	SET JET_STATE_RIGHT_BIT, A					; Set Right
	LD (jetState), A
	*/
	RET

MoveRight:
	; ### Increment X position ###
	LD BC, (JetX)	
	INC BC

	; If X >= 315 then set it to 0. X is 9-bit value. 
	; 315 = 256 + 59 = %00000001 + %00111011 -> MSB: 1, LSB: 59
	LD A, B										; Load MSB from X into A
	CP 1										; 9-th bit set means X > 256
	JR NZ, .lessThanMaxX
	LD A, C										; Load MSB from X into A
	CP 59										; MSB > 59 
	JR C, .lessThanMaxX
	LD BC, 1									; Jetman is above 320 -> set to 0
.lessThanMaxX
	LD (JetX), BC								; Update new X postion

	; ### Direction change? ### 
	LD A, (jetState)
	AND JET_STATE_RIGHT_BM						; Are we moving right already?
	CP JET_STATE_RIGHT_BM
	JR Z, .noDirectionChange

	; We have direction change!	
	LD A, (jetState)							; Update #jetState by reseting Left and setting Right
	RES JET_STATE_LEFT_BIT, A					; Reset Left as we are going now right	
	SET JET_STATE_RIGHT_BIT, A					; Set Right
	LD (jetState), A

.noDirectionChange
	RET

MoveLeft:
	; ## Decrement X position ##
	LD BC, (JetX)	
	DEC BC

	; If X == 0 then set it to 315. X == 0 when B and C are 0
	LD A, B
	CP DI_X_MIN_POS
	JR NZ, .graterThanMinX
	LD A, C
	CP DI_X_MIN_POS
	JR NZ, .graterThanMinX
	LD BC, DI_X_MAX_POS							; X == 0 -> set X to 315
	JR NZ, .graterThanMinX
.graterThanMinX
	LD (JetX), BC
	
	; ### Direction change? ###
	LD A, (jetState)
	AND JET_STATE_LEFT_BM						; Are we moving right already?
	CP JET_STATE_LEFT_BM
	JR Z, .noDirectionChange

	; We have direction change!	
	LD A, (jetState)							; Update #jetState by reseting Right and setting Left
	RES JET_STATE_RIGHT_BIT, A					; Reset Right and set Left
	SET JET_STATE_LEFT_BIT, A
	LD (jetState), A

.noDirectionChange
	RET	

PressFire:
	RET
