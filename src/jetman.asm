;----------------------------------------------------------;
;                        Globals                           ;
;----------------------------------------------------------;
JetX					WORD 100				; 0-320px
JetY 					BYTE 100				; 0-256px

; Possible move directions
JET_STATE_LEFT_BIT		= 0						; Bit 0 - Jetman moving left
JET_STATE_LEFT_BM		= %00000001	

JET_STATE_RIGHT_BIT		= 1						; Bit 1 - Jetman moving right
JET_STATE_RIGHT_BM		= %00000010

JET_STATE_UP_BIT		= 2						; Bit 2 - Jetman moving up
JET_STATE_UP_BM			= %00000100		

JET_STATE_DOWN_BIT		= 3						; Bit 3 - Jetman moving down
JET_STATE_DOWN_BM		= %00001000

JET_STATE_HOVER_BIT		= 4						; Bit 4 - Jetman hovers
JET_STATE_HOVER_BM		= %00010000

JET_STATE_GROUND_BIT	= 5						; Bit 5 - Jetman walks on the ground
JET_STATE_GROUND_BM		= %00100000

JET_STATE_PLATFORM_BIT	= 6						; Bit 6 - Jetman walks on the platform
JET_STATE_PLATFORM_BM	= %01000000

JET_STATE_STAND_BIT		= 7						; Bit 7 - Jetman stands on the platform/ground
JET_STATE_STAND_BM		= %10000000

JET_STATE_PLATFORM_BITS	= JET_STATE_GROUND_BM | JET_STATE_PLATFORM_BM

jetState 				BYTE %00010010			; Hover, face Rright
jetLoopState 			BYTE 0					; State will be reset right on the beginnig of each joysting loop

jetHoverCnt				BYTE 0					; The counter increases with each frame when no up/down is pressed. 
												; When it reaches #JET_HOVER_START, Jetman will start hovering
JET_HOVER_START			= 15					
 
; #jetSprPaterntIdx and #etSprPaternEnd contain data for currently executed animation, #jetSprPaterntNextID contains an ID 
; for the animation that will play once the current has ended.
jetSprPaterntIdx		BYTE 40					; Current index  of Jetman's sprite pattern
jetSprPaternEnd			BYTE 41					; End offset (inculsive) of Jetman's sprite pattern
jetSprPaterntNextID		BYTE JET_SDB_HOVER		; ID in #jetSpriteDB for next animation

; IDs for #jetSpriteDB
JET_SDB_FLY				= 201					; Jetman is flaying
JET_SDB_WALK			= 202					; Jetman is walking
JET_SDB_DOWN			= 203					; Jetman is moving down
JET_SDB_HOVER			= 204					; Jetman hovers
JET_SDB_STAND			= 205					; Jetman stands in place

JET_SDB_T_WF			= 220					; Transition: walking -> flaying
JET_SDB_T_FW			= 221					; Transition: flaying -> walking
JET_SDB_T_WL			= 222					; Transition: walking -> falling

JET_SDB_RS				= 3						; Sieze of single sprite DB record
JET_SDB_OFF_ST			= 0						; DB offset from ID to pattern start
JET_SDB_OFF_EN			= 1						; DB offset from ID to pattern end
JET_SDB_OFF_NX			= 2						; DB offset from ID to next record
JET_SDB_OFF_NX_ADD		= -100					; -100 for OFF_NX that CPIR finds ID and not OFF_NX (see record docu below, look for: OFF_NX)


; The animation system uses a state machine. It's a DB where each record contains a start and end offset to the animation pattern and 
; finally offset to a new DB record containing animation that will be played next.
; DB Record:[ID], [OFF_ST: sprite offset start], [OFF_EN: sprite offset end], [OFF_NX: next animation ID - 100]
jetSpriteDB				DB JET_SDB_FLY,		36, 37, JET_SDB_FLY		+ JET_SDB_OFF_NX_ADD						
						DB JET_SDB_WALK,	00, 03, JET_SDB_WALK	+ JET_SDB_OFF_NX_ADD						
						DB JET_SDB_DOWN, 	06, 09, JET_SDB_DOWN	+ JET_SDB_OFF_NX_ADD						
						DB JET_SDB_HOVER, 	40, 41, JET_SDB_HOVER	+ JET_SDB_OFF_NX_ADD
						DB JET_SDB_T_WF,	44, 47, JET_SDB_FLY		+ JET_SDB_OFF_NX_ADD
						DB JET_SDB_T_FW,	12, 14, JET_SDB_WALK	+ JET_SDB_OFF_NX_ADD
						DB JET_SDB_T_WL, 	05, 07, JET_SDB_FLY		+ JET_SDB_OFF_NX_ADD
						DB JET_SDB_STAND, 	05, 05, JET_SDB_STAND	+ JET_SDB_OFF_NX_ADD
						

JET_SPRITE_ID			= $0					; ID of Jetman/Player sprite

GROUND_LEVEL			= 235					; The lowest walking platform.
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

	; Move Jetman Sprite to the current X position, the 9-bit value r=ires a few tricks. 
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

	; Update temp state
	LD A, (jetLoopState)
	SET JET_STATE_UP_BIT, A	
	LD (jetLoopState), A

	CALL JetmanMoves							

	; Decrement Y position
	LD A, (JetY)	
	CP DI_Y_MIN_POS 							; Do not decrement if Jetman has reached the top of the screen.
	JR Z, .afterDec
	DEC A
	LD (JetY), A
.afterDec	

	; Transition from walking to flaying?
	LD A, (jetState)
	AND JET_STATE_PLATFORM_BITS						
	CP 0										; Check if one on the walking bits is set
	JR Z, .afterTakeoff

	; Takingoff
	LD A, (jetState)
	RES JET_STATE_GROUND_BIT, A					; Reset walking bits	
	RES JET_STATE_PLATFORM_BIT, A
	RES JET_STATE_STAND_BIT, A
	SET JET_STATE_UP_BIT, A						; Set flaying bit
	LD (jetState), A

	; Play takeoff animation					
	LD A, JET_SDB_T_WL
	CALL ChangeJetmanSpritePattern
	JR .afterTakeoff

	; Direction change? 
	LD A, (jetState)
	AND JET_STATE_UP_BM							; Are we moving Up already?
	CP JET_STATE_UP_BM
	JR Z, .afterDirectionChange

	; We have direction change!	
	LD A, (jetState)							; Update #jetState by reseting Down/Hover and setting Down
	RES JET_STATE_DOWN_BIT, A
	RES JET_STATE_HOVER_BIT, A
	RES JET_STATE_STAND_BIT, A
	SET JET_STATE_UP_BIT, A
	LD (jetState), A

.afterDirectionChange
.afterTakeoff

	RET											; END #JoyMoveUp

JoyMoveDown:
	; Update temp state
	LD A, (jetLoopState)
	SET JET_STATE_DOWN_BIT, A	
	LD (jetLoopState), A

	CALL JetmanMoves						

	; Increment Y position
	LD A, (JetY)
	CP GROUND_LEVEL								; Do not increment if Jetman has reached the ground
	JR Z, .afterInc						

	; Move Jetman 1px down
	INC A
	LD (JetY), A

	; Landing on the ground?
	CP GROUND_LEVEL
	JR NZ, .afterLanding
	; Yes, Jemans is landing, trigger ransition: falying -> landing -> walking
	LD A, JET_SDB_T_FW
	CALL ChangeJetmanSpritePattern
	
	LD A, (jetState)							; Update state
	SET JET_STATE_GROUND_BIT, A	
	LD (jetState), A
.afterLanding

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
	; Update temp state
	LD A, (jetLoopState)
	SET JET_STATE_RIGHT_BIT, A	
	LD (jetLoopState), A

	CALL JetmanMoves						

	; ###### START: Increment X position ######
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
	; ###### END: Increment X position ######

	; ##### START: Direction change (left -> right) #####
	LD A, (jetState)
	AND JET_STATE_RIGHT_BM						; Are we moving right already?
	CP JET_STATE_RIGHT_BM
	JR Z, .afterDirectionChange

	; We have direction change!	

	; Transition from standing on platform/ground to walking?
	LD A, (jetState)
	BIT JET_STATE_STAND_BIT, A
	JR Z, .afterWalking							; Jerman is not standing on platform/ground -> end
	 
	; Jetman was standing and starts walking now
	LD A, JET_SDB_WALK
	CALL ChangeJetmanSpritePattern
.afterWalking

	; Update state
	LD A, (jetState)							; Update #jetState by reseting left/hover and setting right
	RES JET_STATE_LEFT_BIT, A					; Reset left/hover/stand and set right
	RES JET_STATE_HOVER_BIT, A
	RES JET_STATE_STAND_BIT, A
	SET JET_STATE_RIGHT_BIT, A
	LD (jetState), A
.afterDirectionChange
	; ##### END: Direction change (left -> right) #####
	
	RET											; END #JoyMoveRight

JoyMoveLeft:
	; Update temp state
	LD A, (jetLoopState)
	SET JET_STATE_LEFT_BIT, A	
	LD (jetLoopState), A

	CALL JetmanMoves						

	; ###### START: Decrement X position ######
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
	; ###### END: Decrement X position ######

	; ###### START: Direction change ######
	LD A, (jetState)
	AND JET_STATE_LEFT_BM						; Are we moving left already?
	CP JET_STATE_LEFT_BM
	JR Z, .afterDirectionChange					; Jetman is moving left already -> end

	; We have direction change!	

	; Transition from standing on platform/ground to walking?
	LD A, (jetState)
	BIT JET_STATE_STAND_BIT, A
	JR Z, .afterWalking							; Jerman is not standing on platform/ground -> end
	 
	; Jetman was standing and starts walking now
	LD A, JET_SDB_WALK
	CALL ChangeJetmanSpritePattern
.afterWalking

	; Update state 
	LD A, (jetState)							; Update #jetState by reseting right and setting left
	RES JET_STATE_RIGHT_BIT, A					; Reset right/hover/stand and set left
	RES JET_STATE_HOVER_BIT, A
	RES JET_STATE_STAND_BIT, A
	SET JET_STATE_LEFT_BIT, A
	LD (jetState), A
.afterDirectionChange
	; ###### END: Direction change ######

	RET											; END #JoyMoveLeft

JoyPressFire:

	RET

; Method gets called on any movement, but not fire pressed
JetmanMoves

	; ####### START: Hoovering #######
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
	; ####### END: Hoovering #######

	RET 										; END #JetmanMoves

JoyStart:
	; Reset temp state
	LD A, 0										; Update #jetState by reseting left/hover and setting right
	LD (jetLoopState), A

	RET 										; END #JoyStart

JoyEnd:											; After input processing, #JoyEnd gets executed as the last procedure. 
	; ####### START: Hoovering #######
	LD A, (jetState)
	BIT JET_STATE_HOVER_BIT, A					; Already hovering?				
	JR NZ, .afterHovering	

	; Jetman is not hovering, should he?
	AND JET_STATE_PLATFORM_BITS						; Hoovering is only possible when not walking
	CP 0										; Check if one on the walking bits is set
	JR NZ, .afterHovering
	
	; First, increase the counter. It will be reset once any direction button is pressed. 
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
	JR .afterStanding							; Alerady hoovering, do not check standing	
.afterHovering
	; ####### END: Hoovering #######

	; ####### START: Jetman standing without movement #######
	LD A, (jetState)
	BIT JET_STATE_STAND_BIT, A
	JR NZ, .afterStanding						; Jerman is already standing -> end procedure. 

	AND JET_STATE_PLATFORM_BITS					; Is Jetman on the a platform/ground?
	CP 0										
	JR Z, .afterStanding						; Jerman is not on the platform/ground -> end procedure. 

	LD A, (jetLoopState)
	AND JET_STATE_LEFT_BM | JET_STATE_RIGHT_BM	; Is Jetman moving right or left?
	CP 0
	JR NZ, .afterStanding						; Jerman going left or right -> end procedure. 

	; Jetman is on the platform/ground and dnoes not move!
	LD A, (jetState)
	RES JET_STATE_LEFT_BIT, A					; Reset left/right and set stand bits
	RES JET_STATE_RIGHT_BIT, A
	SET JET_STATE_STAND_BIT, A
	LD (jetState), A

	LD A, JET_SDB_STAND							; Change animation
	CALL ChangeJetmanSpritePattern
.afterStanding	
	; ####### END: Jetman standing without movement #######


	RET											; END #JoyEnd