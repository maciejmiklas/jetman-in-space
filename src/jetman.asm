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

JET_STATE_HOVER_BIT		EQU 4					; Bit 3 - Jetman hovers
JET_STATE_HOVER_BM		EQU %00010000

JET_STATE_HOVER			EQU	%00001100			; Up/Down reset if hovering

jetState 				BYTE %00010010			; Hover, face Rright

jetHoverCnt				BYTE 0					; The counter increases with each frame when no up/down is pressed. 
												; When it reaches #JET_HOVER_START, Jetman will start hovering
JET_HOVER_START			EQU 15					
 
; #jetSprPaterntIdx and #etSprPaternEnd contain data for currently executed animation, #jetSprPaterntNextID contains an ID 
; for the animation that will play once the current has ended.
jetSprPaterntIdx		BYTE 40					; Current index  of Jetman's sprite pattern
jetSprPaternEnd			BYTE 41					; End offset (inculsive) of Jetman's sprite pattern
jetSprPaterntNextID		BYTE JET_SDB_HOVER		; ID in #jetSpriteDB for next animation

; IDs for #jetSpriteDB
JET_SDB_FLY				EQU 201					; Jetman is flaying
JET_SDB_WALK			EQU 202					; Jetman is walking
JET_SDB_DOWN			EQU 203					; Jetman is moving down
JET_SDB_HOVER			EQU 204					; Jetman hovers

JET_SDB_T_WF			EQU 220					; Transition: walking -> flaying
JET_SDB_T_FW			EQU 221					; TDBransition: flaying -> walking
JET_SDB_T_WL			EQU 222					; Transition: walking -> falling

JET_SDB_RS				EQU 3					; Sieze of single sprite DB record
JET_SDB_OFF_ST			EQU 0					; DB offset from ID to pattern start
JET_SDB_OFF_EN			EQU 1					; DB offset from ID to pattern end
JET_SDB_OFF_NX			EQU 2					; DB offset from ID to next record
JET_SDB_OFF_NX_ADD		EQU -100				; -100 for OFF_NX that CPIR finds ID and not OFF_NX


; The animation system uses a state machine. It's a DB where each record contains a start and end offset to the animation pattern and 
; finally offset to a new DB record containing animation that will be played next.
; DB Record:[ID], [OFF_ST: sprite offset start], [OFF_EN: sprite offset end], [OFF_NX: next animation ID-100]
jetSpriteDB				DB JET_SDB_FLY,		36, 37, JET_SDB_FLY		+ JET_SDB_OFF_NX_ADD						
						DB JET_SDB_WALK,	00, 03, JET_SDB_WALK	+ JET_SDB_OFF_NX_ADD						
						DB JET_SDB_DOWN, 	06, 09, JET_SDB_DOWN	+ JET_SDB_OFF_NX_ADD						
						DB JET_SDB_HOVER, 	40, 41, JET_SDB_HOVER	+ JET_SDB_OFF_NX_ADD
						DB JET_SDB_T_WF,	44, 47, JET_SDB_T_WF	+ JET_SDB_OFF_NX_ADD
						DB JET_SDB_T_FW,	01, 12, JET_SDB_T_FW	+ JET_SDB_OFF_NX_ADD
						DB JET_SDB_T_WL, 	08, 39, JET_SDB_T_WL	+ JET_SDB_OFF_NX_ADD

JET_SPRITE_ID			EQU $0					; ID of Jetman/Player sprite

;----------------------------------------------------------;
;                  #IntiJetmanSprite                       ;
;----------------------------------------------------------;
IntiJetmanSprite
	CALL UpdateJetmanSpritePosition							
	CALL UpdateJetmanSpritePattern

	; bit 7 = Visible flag (1 = displayed)
	; bits 5-0 = Pattern used by sprite (0-63), we will use pattern 0
	NEXTREG SPR_REG_ATTR_3_H38, %10000000

	RET											; END IntiJetmanSprite

;----------------------------------------------------------;
;               #UpdateJetmanSpritePosition                ;
;----------------------------------------------------------;
UpdateJetmanSpritePosition	

	NEXTREG SPR_REG_NR_H34, JET_SPRITE_ID		; Set the ID of the Jetman's sprite for the following commands

	; Move Jetman Sprite to the current X position, the 9-bit value requires a few tricks. 
	LD BC, (JetX)								
	LD A, C										
	NEXTREG SPR_REG_X_H35, A					; Set LSB from BC into X, below in next lines we handle overflow bit
	LD A, B										; Load MSB from X into A
	AND %00000001								; Keep only an overflow bit
	
	; Rotate sprite for Left/Right movement	
	LD E, A										; Store A in E to use A for loading data from RAM.
	LD A, (jetState)			
	LD D, A
	LD A, E										; Now, A has it's original value, and D contains a value from #jetState
	BIT JET_STATE_LEFT_BIT, D					; Moving left bit set?
	JR Z, .rotateRight
	SET 3, A									; Rotate sprite left	
	JR .afterRotate	
.rotateRight	
	RES 3, A									; Rotate sprite right
.afterRotate

	NEXTREG SPR_REG_ATTR_2_H37, A		

	; Move Jetman sprite to current Y postion, 8-bit value is easy 
	LD A, (JetY)								
	NEXTREG SPR_REG_Y_H36, A					; Set Y position

	RET											; END UpdateJetmanSpritePosition
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
	NEXTREG SPR_REG_NR_H34, JET_SPRITE_ID		; Set the ID of the Jetman's sprite for the following commands

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
	NEXTREG SPR_REG_ATTR_3_H38, A	

	RET											; END UpdateJetmanSpritePattern				
;----------------------------------------------------------;
;                    Handle Movement                       ;
;----------------------------------------------------------;
JoyMoveUp:
	CALL JetmanMoves							

	; Decrement Y position
	LD A, (JetY)	
	CP DI_Y_MIN_POS 							; Do not decrement if Jetman has reached the top of the screen.
	JR Z, .afterDec
	DEC A
	LD (JetY), A
.afterDec	

	; Direction change? 
	LD A, (jetState)
	AND JET_STATE_UP_BM							; Are we moving Up already?
	CP JET_STATE_UP_BM
	JR Z, .afterDirectionChange

	; We have direction change!	
	LD A, (jetState)							; Update #jetState by reseting Down/Hover and setting Down
	RES JET_STATE_DOWN_BIT, A
	RES JET_STATE_HOVER_BIT, A
	SET JET_STATE_UP_BIT, A
	LD (jetState), A
.afterDirectionChange

	RET											; END #JoyMoveUp

JoyMoveDown:
	CALL JetmanMoves						

; Increment Y position
	LD A, (JetY)
	CP DI_Y_MAX_POS								; Do not increment if Jetman has reached the bottom of the screen.
	JR Z, .afterInc						
	INC A
	LD (JetY), A

; Direction change? 
	LD A, (jetState)
	AND JET_STATE_DOWN_BM						; Are we moving down already?
	CP JET_STATE_DOWN_BM
	JR Z, .afterDirectionChange

	; We have direction change!	
	LD A, (jetState)							; Update #jetState by reseting Up/Hover and setting Down
	RES JET_STATE_UP_BIT, A
	RES JET_STATE_HOVER_BIT, A
	SET JET_STATE_DOWN_BIT, A	
	LD (jetState), A

.afterDirectionChange
.afterInc	

	RET											; END #JoyMoveDown

JoyMoveRight:
	CALL JetmanMoves						

	; Increment X position
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

	; Direction change? 
	LD A, (jetState)
	AND JET_STATE_RIGHT_BM						; Are we moving right already?
	CP JET_STATE_RIGHT_BM
	JR Z, .afterDirectionChange

	; We have direction change!	
	LD A, (jetState)							; Update #jetState by reseting left/hover and setting right
	RES JET_STATE_LEFT_BIT, A
	RES JET_STATE_HOVER_BIT, A
	SET JET_STATE_RIGHT_BIT, A
	LD (jetState), A
.afterDirectionChange
	RET											; END #JoyMoveRight

JoyMoveLeft:
	CALL JetmanMoves						

	; Decrement X position
	LD BC, (JetX)	
	DEC BC

	; If X == 0 (DI_X_MIN_POS) then set it to 315. X == 0 when B and C are 0
	LD A, B
	CP DI_X_MIN_POS								; If B > 0 then X is also X > 0
	JR NZ, .afterResetX
	LD A, C
	CP DI_X_MIN_POS								; If C > 0 then X is also X > 0
	JR NZ, .afterResetX
	LD BC, DI_X_MAX_POS							; X == 0 (both A and B are 0) -> set X to 315
	JR NZ, .afterResetX
.afterResetX
	LD (JetX), BC
	
	; Direction change?
	LD A, (jetState)
	AND JET_STATE_LEFT_BM						; Are we moving left already?
	CP JET_STATE_LEFT_BM
	JR Z, .afterDirectionChange

	; We have direction change!	
	LD A, (jetState)							; Update #jetState by reseting right and setting left
	RES JET_STATE_RIGHT_BIT, A					; Reset right/hover and set left
	RES JET_STATE_HOVER_BIT, A
	SET JET_STATE_LEFT_BIT, A
	LD (jetState), A
.afterDirectionChange

	RET											; END #JoyMoveLeft

JoyPressFire:
	RET

; Method gets called on any movement, but not fire pressed
JetmanMoves

	; Reset hoover counter as we have movement
	LD A, 0									
	LD (jetHoverCnt), A

	; Transition from hoovering to flying?
	LD A, (jetState)
	BIT JET_STATE_HOVER_BIT, A					; Is Jetman hovering?
	JR Z, .afterHovering

	RES JET_STATE_HOVER_BIT, A					; He was hovering, reset hover bit
	LD (jetState), A
	
	LD A, JET_SDB_FLY							; Switch to flaying animation
	CALL ChangeJetmanSpritePattern
.afterHovering	

	RET 										; END #JetmanMoves

JoyEnd:											; After input processing, #JoyEnd gets executed as the last procedure. 
	LD A, (jetState)							; Load into A the State
	BIT JET_STATE_HOVER_BIT, A					; Already hovering?	
	JR NZ, .afterHovering	

	; Jetman is not hovering. First, increase the counter. It will be reset once any direction button is pressed. 
	; Otherwise, the counter is not reset and gets increased here.
	LD A, (jetHoverCnt)							; Increment hover counter
	INC A
	LD (jetHoverCnt), A

	CP JET_HOVER_START
	JR C, .afterHovering						; Jetman is not moving, by sill not long enough to start hovering

	LD A, (jetState)
	SET JET_STATE_HOVER_BIT, A					; Jetamn hovers!	
	LD (jetState), A

	LD A, JET_SDB_HOVER
	CALL ChangeJetmanSpritePattern

.afterHovering	
	
	LD A, (jetHoverCnt)
	LD H, 0
	LD L, A
	CALL PrintNumHL

	RET	