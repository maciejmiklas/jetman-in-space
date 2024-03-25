;----------------------------------------------------------;
;                        Globals                           ;
;----------------------------------------------------------;
JetX					WORD 100				; 0-320px
JetY 					BYTE 100				; 0-256px

; ###### Possible move directions #####
JET_MOVE_INACTIVE		= 0						; No movement

JET_MOVE_LEFT_BIT		= 0						; Bit 0 - Jetman moving left
JET_MOVE_LEFT_BM		= %0000'0001

JET_MOVE_RIGHT_BIT		= 1						; Bit 1 - Jetman moving right
JET_MOVE_RIGHT_BM		= %0000'0010

JET_MOVE_UP_BIT			= 2						; Bit 2 - Jetman moving up
JET_MOVE_UP_BM			= %0000'0100

JET_MOVE_DOWN_BIT		= 3						; Bit 3 - Jetman moving down
JET_MOVE_DOWN_BM		= %0000'1000

jetMove 				BYTE JET_MOVE_INACTIVE	; Jetman initially hovers, no movement
jetLoopMove 			BYTE JET_MOVE_INACTIVE	; State will be reset right on the beginnig of each joysting loop

; ###### States for Jetmain in the air, 0 for not in the air ######
JET_AIR_INACTIVE		= 0						; Jetman is not in the air
JET_AIR_FLY				= 1						; Jetman is flaying
JET_AIR_HOOVER			= 2						; Jetman is hovering
JET_AIR_FALL			= 3						; jetman falls from platform

jetAir					BYTE JET_AIR_FLY		; Jetman initially hovers, no movement

; ###### States for Jetman on the platform/ground ######
JET_GND_INACTIVE		= 0					; Jetman is not on platform/ground
JET_GND_WALK			= 1					; Jetman walks on the platform/ground
JET_GND_STAND			= 2					; Jetman stands on the platform/ground

jetGnd					BYTE JET_GND_INACTIVE; Jetman initially hovers, no movement

; ###### Hovering ######
jetHoverCnt				BYTE 0				; The counter increases with each frame when no up/down is pressed. 
											; When it reaches #JET_HOVER_START, Jetman will start hovering
JET_HOVER_START			= 50					
 
; ###### Sprites ######

; #jetSprPaterntIdx and #etSprPaternEnd contain data for currently executed animation, #jetSprPaterntNextID contains an ID 
; for the animation that will play once the current has ended.
jetSprPaterntIdx		BYTE 40					; Current index  of Jetman's sprite pattern
jetSprPaternEnd			BYTE 41					; End offset (inculsive) of Jetman's sprite pattern
jetSprPaterntNextID		BYTE JET_SDB_FLY		; ID in #jetSpriteDB for next animation

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

; ###### Misc ######
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
	LD A, (jetMove)			
	LD D, A
	LD A, E										; Now, A has it's original value, and D contains a value from #jetState
	BIT JET_MOVE_LEFT_BIT, D					; Moving left bit set?
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
	LD A, (jetLoopMove)
	SET JET_MOVE_UP_BIT, A	
	LD (jetLoopMove), A

	CALL JetmanMoves							

	; Decrement Y position
	LD A, (JetY)	
	CP DI_Y_MIN_POS 							; Do not decrement if Jetman has reached the top of the screen.
	JR Z, .afterDec
	DEC A
	LD (JetY), A
.afterDec	

	; ##### Direction change: down -> up #####
	LD A, (jetMove)
	AND JET_MOVE_UP_BM							; Are we moving Up already?
	CP JET_MOVE_UP_BM
	JR Z, .afterDirectionChange

	; We have direction change!	
	LD A, (jetMove)								; Update #jetState by reseting down and setting up
	RES JET_MOVE_DOWN_BIT, A
	SET JET_MOVE_UP_BIT, A
	LD (jetMove), A
.afterDirectionChange

	; ###### Transition from walking to flaying ######
	LD A, (jetGnd)
	CP JET_GND_INACTIVE							; Check if Jetnan is on the ground/platform
	JR Z, .afterTakeoff

	; Jetman is taking off - set #jetAir and reset #jetGnd
	LD A, JET_AIR_FLY
	LD (jetAir), A

	LD A, JET_GND_INACTIVE
	LD (jetGnd), A

	; Play takeoff animation					
	LD A, JET_SDB_T_WL
	CALL ChangeJetmanSpritePattern
	JR .afterTakeoff
.afterTakeoff

	RET											; END #JoyMoveUp

JoyMoveDown:
	; Update temp state
	LD A, (jetLoopMove)
	SET JET_MOVE_DOWN_BIT, A	
	LD (jetLoopMove), A

	CALL JetmanMoves						

	; Increment Y position
	LD A, (JetY)
	CP GROUND_LEVEL								; Do not increment if Jetman has reached the ground
	JR Z, .afterInc						

	; Move Jetman 1px down
	INC A
	LD (JetY), A

	; ##### Landing on the ground ######
	CP GROUND_LEVEL
	JR NZ, .afterLanding

	; Yes, Jemans is landing, trigger ransition: falying -> landing -> walking
	LD A, JET_SDB_T_FW
	CALL ChangeJetmanSpritePattern

	; Reset #jetAir as we are walking
	LD A, JET_AIR_INACTIVE						
	LD (jetAir), A

	; Update #jetGnd as we are walking
	LD A, JET_GND_WALK						
	LD (jetGnd), A	

.afterLanding

	; Direction change? 
	LD A, (jetMove)
	AND JET_MOVE_DOWN_BM						; Are we moving down already?
	CP JET_MOVE_DOWN_BM
	JR Z, .afterDirectionChange

	; We have direction change!	
	LD A, (jetMove)							; Update #jetState by reseting Up/Hover and setting Down
	RES JET_MOVE_UP_BIT, A
	//RES JET_STATE_HOVER_BIT, A
	SET JET_MOVE_DOWN_BIT, A	
	LD (jetMove), A
.afterDirectionChange
.afterInc	

	RET											; END #JoyMoveDown

JoyMoveRight:
	; Update temp state
	LD A, (jetLoopMove)
	SET JET_MOVE_RIGHT_BIT, A	
	LD (jetLoopMove), A

	CALL JetmanMoves						

	; ###### Increment X position ######
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

	; ##### Direction change: left -> right #####
	LD A, (jetMove)
	AND JET_MOVE_RIGHT_BM						; Are we moving right already?
	CP JET_MOVE_RIGHT_BM
	JR Z, .afterDirectionChange

	; We have direction change!	
/*
	; Transition from standing on platform/ground to walking?
	LD A, (jetMove)
	BIT JET_STATE_STAND_BIT, A
	JR Z, .afterWalking							; Jerman is not standing on platform/ground -> end
	 
	; Jetman was standing and starts walking now
	LD A, JET_SDB_WALK
	CALL ChangeJetmanSpritePattern
.afterWalking
*/
	; Update #jetMove: reset left and set right
	LD A, (jetMove)								
	RES JET_MOVE_LEFT_BIT, A
	SET JET_MOVE_RIGHT_BIT, A
	LD (jetMove), A
	
.afterDirectionChange
	
	RET											; END #JoyMoveRight

JoyMoveLeft:
	; Update temp state
	LD A, (jetLoopMove)
	SET JET_MOVE_LEFT_BIT, A	
	LD (jetLoopMove), A

	CALL JetmanMoves						

	; ###### Decrement X position ######
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

	; ##### Direction change: right -> left #####
	LD A, (jetMove)
	AND JET_MOVE_LEFT_BM						; Are we moving left already?
	CP JET_MOVE_LEFT_BM
	JR Z, .afterDirectionChange					; Jetman is moving left already -> end

	; We have direction change!	
/*
	; Transition from standing on platform/ground to walking?
	LD A, (jetMove)
	BIT JET_STATE_STAND_BIT, A
	JR Z, .afterWalking							; Jerman is not standing on platform/ground -> end
	 
	; Jetman was standing and starts walking now
	LD A, JET_SDB_WALK
	CALL ChangeJetmanSpritePattern
.afterWalking
*/
	; Update #jetMove: reset right and set left 
	LD A, (jetMove)							
	RES JET_MOVE_RIGHT_BIT, A
	SET JET_MOVE_LEFT_BIT, A
	LD (jetMove), A
.afterDirectionChange

	RET											; END #JoyMoveLeft

JoyPressFire:

	RET

; Method gets called on any movement, but not fire pressed
JetmanMoves

	; ####### Reset hover counter as we have movement #######
	LD A, 0
	LD (jetHoverCnt), A

	; ####### Transition from hovering to flying? #######
	LD A, (jetAir)
	CP JET_AIR_HOOVER							; Is Jemtman hovering?			
	JR NZ, .afterHovering						; Jump if not hovering

	; Jetman is hovering, but be have movement, so switch state to fly
	LD A, JET_AIR_FLY
	LD (jetAir), A
	
	LD A, JET_SDB_FLY							; Switch to flaying animation
	CALL ChangeJetmanSpritePattern
.afterHovering	

	RET 										; END #JetmanMoves

JoyStart:
	; Reset temp state
	LD A, 0										; Update #jetState by reseting left/hover and setting right
	LD (jetLoopMove), A

	RET 										; END #JoyStart

JoyEnd:											; After input processing, #JoyEnd gets executed as the last procedure. 

	; ####### Hovering #######
	LD A, (jetAir)
	CP JET_AIR_INACTIVE							; Is Jemtan in the air already?
	JR Z, .afterHovering						; Jump if #jetAir inactive -> not flaying

	CP JET_AIR_HOOVER							; #jetAir is set, but is Jemtman already hovering?			
	JR Z, .afterHovering						; Jump if already hovering

	LD A, (jetLoopMove)
	CP JET_MOVE_INACTIVE
	JR NZ, .afterHovering						; We have movement - ignore hovering

	; Jetman is in the air, but is he not moving long enough?
	; Increase the counter. It will be reset once any direction button is pressed. 
	; Otherwise, the counter is not reset and gets increased here.
	LD A, (jetHoverCnt)							; Increment hover counter
	INC A
	LD (jetHoverCnt), A

	CP JET_HOVER_START
	JR NZ, .afterHovering						; Jetman is not moving, by sill not long enough to start hovering

	; Jetamn starts to hover!
	LD A, JET_AIR_HOOVER
	LD (jetAir), A

	LD A, JET_SDB_HOVER
	CALL ChangeJetmanSpritePattern
	JR .afterStanding							; Alerady hovering, do not check standing	
.afterHovering

	; ####### Jetman standing without movement #######
	
	; End procedure if there is movement
	LD A, (jetLoopMove)
	CP JET_MOVE_INACTIVE
	JR NZ, .afterStanding

	; End procedure if Jetman is not walking
	LD A, (jetGnd)
	CP JET_GND_WALK
	JR NZ, .afterStanding						; Jump is if not walking

	; Jetman is on the platform/ground and does not move!
	LD A, JET_GND_STAND							; Store new state
	LD (jetGnd), A

	LD A, JET_SDB_STAND							; Change animation
	CALL ChangeJetmanSpritePattern
.afterStanding

	; PRINT START
	LD B, 0
	LD H, 0
	LD A, (jetMove)
	LD L, A
	CALL PrintNumHL

	LD B, 10
	LD H, 0
	LD A, (jetLoopMove)
	LD L, A
	CALL PrintNumHL		

	LD B, 20
	LD H, 0
	LD A, (jetAir)
	LD L, A
	CALL PrintNumHL	

	LD B, 30
	LD H, 0
	LD A, (jetGnd)
	LD L, A
	CALL PrintNumHL		

	; PRINT END

	RET											; END #JoyEnd