;----------------------------------------------------------;
;                        Globals                           ;
;----------------------------------------------------------;
jetX					WORD 100				; 0-320px
jetY 					BYTE 100				; 0-256px

; ### Possible move directions #####
JET_MOVE_INACTIVE		= 0						; No movement

JET_MOVE_LEFT_BIT		= 0						; Bit 0 - Jetman moving left
JET_MOVE_LEFT_BM		= %0000'0001

JET_MOVE_RIGHT_BIT		= 1						; Bit 1 - Jetman moving right
JET_MOVE_RIGHT_BM		= %0000'0010

JET_MOVE_UP_BIT			= 2						; Bit 2 - Jetman moving up
JET_MOVE_UP_BM			= %0000'0100

JET_MOVE_DOWN_BIT		= 3						; Bit 3 - Jetman moving down
JET_MOVE_DOWN_BM		= %0000'1000

; This byte holds the direction in which Jetman is facing. It takes movement bits as arguments but gets updated only when 
; the opsite direction changes. Pressing left will reset the right bit and set left; pressing up will reset the down bit and set up. 
; However, only opposite directions are reset, so for example, when Jetman is facing right, and the right button is released, 
; it still looks right; now, when up is pressed, it will look upright, and the right will be reset only when left is pressed. 
; Prolonged inactivity resets #jetDirection to #JET_MOVE_INACTIVE.
jetDirection 		BYTE JET_MOVE_INACTIVE		; Jetman initially hovers, no movement

; Holds currently pressed direction button. State will be reset right on the beginnig of each joysting loop.
jetMove 			BYTE JET_MOVE_INACTIVE

; ### States for Jetmain in the air, 0 for not in the air ###
JET_AIR_INACTIVE		= 0						; Jetman is not in the air
JET_AIR_FLY				= 1						; Jetman is flaying
JET_AIR_HOOVER			= 2						; Jetman is hovering

jetAir					BYTE JET_AIR_FLY		; Jetman initially hovers, no movement

; ### States for Jetman on the platform/ground ###
JET_GND_INACTIVE		= 0						; Jetman is not on ground
JET_GND_WALK			= 1						; Jetman walks on the ground
JET_GND_JSTAND			= 3						; Jetman stands on the ground for a very short time, not enougt to switch to #JET_GND_STAND
JET_GND_STAND			= 4						; Jetman stands on the ground

jetGnd					BYTE JET_GND_INACTIVE	; Jetman initially hovers, no movement

; ### Hovering/Standing ###
jetInactivityCnt		BYTE 0					; The counter increases with each frame when no up/down is pressed. 
												; When it reaches #JET_HOVER_START, Jetman will start hovering
JET_HOVER_START			= 40
JET_STAND_START			= 30

; ### Sprites ###

; IDs for #jetSpriteDB
JET_SDB_FLY				= 201					; Jetman is flaying
JET_SDB_WALK			= 202					; Jetman is walking
JET_SDB_WALK_ST			= 203					; Jetman starts walking with raised feet to avoid moving over the ground and standing still.
JET_SDB_HOVER			= 204					; Jetman hovers
JET_SDB_STAND			= 205					; Jetman stands in place
JET_SDB_JSTAND			= 206					; Jetman quickly stops walking

JET_SDB_T_WF			= 220					; Transition: walking -> flaying
JET_SDB_T_FW			= 221					; Transition: flaying -> walking
JET_SDB_T_WL			= 222					; Transition: walking -> falling

JET_SDB_SUB				= 100					; 100 for OFF_NX that CPIR finds ID and not OFF_NX (see record docu below, look for: OFF_NX)
JET_SDB_FRAME_SIZE		= 2

; The animation system uses a state machine. It's a DB where each record contains a start and end offset to the animation pattern and 
; finally offset to a new DB record containing animation that will be played next.
; DB Record:
;	- ID: 			Entry ID for lookup via CPIR
;	- SIZE:			Amount of bytes in this record
;	- FRAME_UP:		Start offset for the upper part of the Jetman
;	- FRAME_LW: 	Start offset for the lower part of the Jetman
;	- OFF_NX:		ID of the following animation DB record. We subtract from this ID the 100 so that CPIR does not find OFF_NX but ID
; 	
;	DB [ID], [SIZE], [OFF_NX], [[FRAME_UP],[FRAME_LW] ,...], 
;
; Jetman sprite frames:
;   - 00-03: top, breathe 
;   - 03-05: top, no breathe
;   - 06-11: low, walk
;   - 12-17: low, fly
;   - 18-21: low, hover
;   - 22-25: low, walk -> fly
;   - 26-29: low, fly -> walk
;   - 30-33: low, walk -> fall
;   - 34-37: low, stand
jetSpriteDB
	; Jetman is flaying
	DB JET_SDB_FLY,		JET_SDB_FLY 	- JET_SDB_SUB,	48, 00,12, 00,13, 01,14, 01,15, 02,16, 02,17, 03,12, 03,13, 04,14, 04,15, 05,16, 05,17, 03,12, 03,13, 04,14, 04,15, 05,16, 05,17, 03,12, 03,13, 04,14, 04,15, 05,16, 05,17

	; Jetman starts walking with raised feet to avoid moving over the ground and standing still.
	DB JET_SDB_WALK_ST,	JET_SDB_WALK 	- JET_SDB_SUB, 	02, 00,07

	; Jetman is walking
	DB JET_SDB_WALK, 	JET_SDB_WALK 	- JET_SDB_SUB,	48, 00,06, 00,07, 01,08, 01,09, 02,10, 02,11, 03,06, 03,07, 04,08, 04,09, 05,10, 05,11, 03,06, 03,07, 04,08, 04,09, 05,10, 05,11, 03,06, 03,07, 04,08, 04,09, 05,10, 05,11

	; Jetman hovers
	DB JET_SDB_HOVER,	JET_SDB_HOVER 	- JET_SDB_SUB, 	48, 00,18, 00,19, 01,20, 01,21, 02,16, 02,17, 03,12, 03,13, 04,14, 04,15, 05,16, 05,17, 03,12, 03,13, 04,14, 04,15, 05,16, 05,17, 03,12, 03,13, 04,14, 04,15, 05,16, 05,17

	; Transition: walking -> flaying
	DB JET_SDB_T_WF,	JET_SDB_FLY 	- JET_SDB_SUB, 	08, 03,22, 04,23, 05,24, 03,25

	; Transition: flaying -> walking
	DB JET_SDB_T_FW, 	JET_SDB_WALK	- JET_SDB_SUB,	08, 03,26, 04,27, 05,28, 03,29

	; Transition: walking -> falling
	DB JET_SDB_T_WL,	JET_SDB_FLY		- JET_SDB_SUB, 	08, 03,30, 04,31, 05,32, 03,33

	; Jetman stands in place
	DB JET_SDB_STAND,	JET_SDB_STAND	- JET_SDB_SUB, 	48, 00,34, 00,35, 01,36, 01,37, 02,34, 02,35, 03,36, 03,37, 04,34, 04,35, 05,36, 05,37, 03,34, 03,35, 04,36, 04,37, 05,34, 05,35, 03,36, 03,37, 04,34, 04,35, 05,36, 05,37

	; Jetman stands on the ground for a very short time
	DB JET_SDB_JSTAND,	JET_SDB_JSTAND	- JET_SDB_SUB, 	02, 00,36

jetSpriteDBIdx			WORD 0					; Current position in DB
jetSpriteDBRemain		BYTE 0					; Amount of bytes that have to be still processed from the current record
jetSprDBNextID			BYTE JET_SDB_FLY		; ID in #jetSpriteDB for next animation/DB record						

JET_SPRITE_UP_ID		= $0					; ID of Jetman upper sprite

; bit 7 = Visible flag (1 = displayed)
; bits 5-0 = Pattern used by sprite (0-63), we will use pattern 0
JET_SPRITE_PAT			= %10000000

JET_SPRITE_LW_ID		= $1					; ID of Jetman lower sprite

; ### Misc ###
GROUND_LEVEL			= 230					; The lowest walking platform.

; [amount of plaftorms], [[Y], [X start], [X end]],...,[[Y], [X start], [X end]]
platforms DB 3, 94,6,50, 142,76,121, 54,196,255
	
;----------------------------------------------------------;
;                  #IntiJetmanSprite                       ;
;----------------------------------------------------------;
IntiJetmanSprite
	CALL UpdateJetmanSpritePosition							
	CALL UpdateJetmanSpritePattern

	NEXTREG SPR_REG_ATTR_3_H38, JET_SPRITE_PAT

	RET											; END IntiJetmanSprite

;----------------------------------------------------------;
;               #UpdateJetmanSpritePosition                ;
;----------------------------------------------------------;
UpdateJetmanSpritePosition	
	; Move Jetman Sprite to the current X position, the 9-bit value r=ires a few tricks. 
	LD BC, (jetX)								
	LD A, C			

	NEXTREG SPR_REG_NR_H34, JET_SPRITE_UP_ID	; Set the ID of the Jetman's sprite for the following commands								
	NEXTREG SPR_REG_X_H35, A					; Set LSB from BC into X, below in next lines we handle overflow bit

	NEXTREG SPR_REG_NR_H34, JET_SPRITE_LW_ID	; Set the ID of the Jetman's sprite for the following commands								
	NEXTREG SPR_REG_X_H35, A					; Set LSB from BC into X, below in next lines we handle overflow bit

	LD A, B										; Load MSB from X into A
	AND %00000001								; Keep only an overflow bit
	
	; Rotate sprite for Left/Right movement	
	LD E, A										; Store A in E to use A for loading data from RAM.
	LD A, (jetDirection)			
	LD D, A
	LD A, E										; Now, A has it's original value, and D contains a value from #jetState
	BIT JET_MOVE_LEFT_BIT, D					; Moving left bit set?
	JR Z, .rotateRight
	SET 3, A									; Rotate sprite left	
	JR .afterRotate	
.rotateRight	
	RES 3, A									; Rotate sprite right
.afterRotate

	NEXTREG SPR_REG_NR_H34, JET_SPRITE_UP_ID	; Set the ID of the Jetman's sprite for the following commands	
	NEXTREG SPR_REG_ATTR_2_H37, A

	NEXTREG SPR_REG_NR_H34, JET_SPRITE_LW_ID	; Set the ID of the Jetman's sprite for the following commands	
	NEXTREG SPR_REG_ATTR_2_H37, A

	; Move Jetman sprite to current Y postion, 8-bit value is easy 
	LD A, (jetY)		
	
	NEXTREG SPR_REG_NR_H34, JET_SPRITE_UP_ID	; Set the ID of the Jetman's sprite for the following commands							
	NEXTREG SPR_REG_Y_H36, A					; Set Y position

	NEXTREG SPR_REG_NR_H34, JET_SPRITE_LW_ID	; Set the ID of the Jetman's sprite for the following commands		
	ADD 16										; Lower part is 16px below upper					
	NEXTREG SPR_REG_Y_H36, A					; Set Y position

	RET											; END UpdateJetmanSpritePosition
;----------------------------------------------------------;
;              #ChangeJetmanSpritePattern                  ;
;----------------------------------------------------------;
; Input:
;   - A: ID for #jesSprites, to siwtch to the next animation record
ChangeJetmanSpritePattern
	LD (jetSprDBNextID), A						; Next animation record

	LD A, 0
	LD (jetSpriteDBRemain), A					; No more bytes to process within the current DB record will cause the fast switch to the next.

	CALL UpdateJetmanSpritePattern				; Update next animation frame imedatelly
	
	RET
;----------------------------------------------------------;
;            #UpdateJetmanSpritePattern                    ;
;----------------------------------------------------------;
; Update sprite pattern for the next animation frame
UpdateJetmanSpritePattern	

	; Switch to the next DB record if all bytes from the current one have been used
	LD A, (jetSpriteDBRemain)
	CP 0
	JR NZ, .afterRecordChange					; Jump if there are still bytes to be processed
	
	; ### Load new record ###
	LD HL, jetSpriteDB							; HL points to the beginning of the DB
	LD A, (jetSprDBNextID)						; CPIR will keep increasing HL until it finds record ID from A
	LD BC, 0									; Do not limit CPIR search
	CPIR

	;  Now, HL points to the next byte after the ID of the record, which contains data for the new animation pattern. 	
	LD A, (HL)									; Update next pointer to next animiation record
	ADD JET_SDB_SUB								; Add 100 because DB value had  -100, to avoid collision with ID
	LD (jetSprDBNextID), A

	INC HL										; HL points to [SIZE]
	LD A, (HL)									; Update SIZE
	LD (jetSpriteDBRemain), A

	INC HL										; HL points to first sprite data (uper/lower parts)
	LD (jetSpriteDBIdx), HL						; Database offset points to be bytes containing sprite offsets from sprite file

.afterRecordChange

	; 2 bytes will be consumed from current DB record -> upper and lower sprite for Jetman
	LD A, (jetSpriteDBRemain)
	ADD -JET_SDB_FRAME_SIZE
	LD (jetSpriteDBRemain), A

	LD HL, (jetSpriteDBIdx)

	; Update upper sprite
	NEXTREG SPR_REG_NR_H34, JET_SPRITE_UP_ID	; Set the ID of the Jetman's sprite for the following commands
	LD A, (HL)
	OR JET_SPRITE_PAT							; Store pattern number into Sprite Attribute	
	NEXTREG SPR_REG_ATTR_3_H38, A	

	; Update lower sprite
	NEXTREG SPR_REG_NR_H34, JET_SPRITE_LW_ID	; Set the ID of the Jetman's sprite for the following commands
	INC HL
	LD A, (HL)
	OR JET_SPRITE_PAT							; Store pattern number into Sprite Attribute	
	NEXTREG SPR_REG_ATTR_3_H38, A	

	; Update pointer to DB
	INC HL
	LD (jetSpriteDBIdx), HL

	RET											; END #UpdateJetmanSpritePattern				
;----------------------------------------------------------;
;                    Handle Movement                       ;
;----------------------------------------------------------;
JoyMoveUp

	; ### Update temp state ###
	LD A, (jetMove)
	SET JET_MOVE_UP_BIT, A	
	LD (jetMove), A

	CALL JetmanMoves							

	; ### Decrement Y position ###
	LD A, (jetY)	
	CP DI_Y_MIN_POS 							; Do not decrement if Jetman has reached the top of the screen.
	JR Z, .afterDec
	DEC A
	LD (jetY), A
.afterDec	

	; ### Direction change: down -> up ###
	LD A, (jetDirection)
	AND JET_MOVE_UP_BM							; Are we moving Up already?
	CP JET_MOVE_UP_BM
	JR Z, .afterDirectionChange

	; We have direction change!	
	LD A, (jetDirection)						; Update #jetState by reseting down and setting up
	RES JET_MOVE_DOWN_BIT, A
	SET JET_MOVE_UP_BIT, A
	LD (jetDirection), A
.afterDirectionChange

	; ### Transition from walking to flaying ###
	LD A, (jetGnd)
	CP JET_GND_INACTIVE							; Check if Jetnan is on the ground/platform
	CALL NZ, JetmanTakesoff

	RET											; END #JoyMoveUp

JetmanTakesoff
	; Jetman is taking off - set #jetAir and reset #jetGnd
	LD A, JET_AIR_FLY
	LD (jetAir), A

	LD A, JET_GND_INACTIVE
	LD (jetGnd), A

	; Play takeoff animation					
	LD A, JET_SDB_T_WF
	CALL ChangeJetmanSpritePattern
	RET											; END #JetmanTakesoff

JoyMoveDown
	; ### Cannot move down when walking ###
	LD A, (jetGnd)
	CP JET_GND_INACTIVE
	RET NZ	

	; ### Update temp state ###
	LD A, (jetMove)
	SET JET_MOVE_DOWN_BIT, A	
	LD (jetMove), A

	CALL JetmanMoves						

	; ### Increment Y position ####
	LD A, (jetY)
	CP GROUND_LEVEL								; Do not increment if Jetman has reached the ground
	JR Z, .afterInc						

	; Move Jetman 1px down
	INC A
	LD (jetY), A

	; ### Landing on the ground ###
	CP GROUND_LEVEL
	CALL Z, JetmanLanding						; Execute landing on the ground if Jetman has reached the ground.
	CALL HandleLandingOnPlatform					; Or should he land on one of the platforms?

	; ### Direction change?  ###
	LD A, (jetDirection)
	AND JET_MOVE_DOWN_BM						; Are we moving down already?
	CP JET_MOVE_DOWN_BM
	JR Z, .afterDirectionChange

	; We have direction change!	
	LD A, (jetDirection)						; Update #jetState by reseting Up/Hover and setting Down
	RES JET_MOVE_UP_BIT, A
	SET JET_MOVE_DOWN_BIT, A	
	LD (jetDirection), A
.afterDirectionChange
.afterInc	

	RET											; END #JoyMoveDown

JetmanLanding
	; Jemans is landing, trigger ransition: falying -> landing -> walking
	LD A, JET_SDB_T_FW
	CALL ChangeJetmanSpritePattern

	; Reset #jetAir as we are walking
	LD A, JET_AIR_INACTIVE						
	LD (jetAir), A

	; Update #jetGnd as we are walking
	LD A, JET_GND_WALK						
	LD (jetGnd), A	
	RET											; END JetmanLanding	

; [amount of plaftorms], [[Y], [X start], [X end]],...,[[Y], [X start], [X end]]
; platforms DB 3, 92,6,50, 140,76,121, 51,196,266

; Is Jetman landing on one of the platforms?
HandleLandingOnPlatform
	LD A, (jetAir)
	CP JET_AIR_INACTIVE							; Is Jemtan in the air?
	RET Z										; Return if not flaying, no flying - no landing ;)

	LD HL, platforms
	LD B, (HL)									; Load into B the number of platforms to check
.platformsLoop	
	INC HL										; HL points to [Y]
	LD C, (HL)									; C contains [Y]

	INC HL										; HL points to [X start]
	LD D, (HL)									; D contains [X start]	

	INC HL										; HL points to [X end]
	LD E, (HL)									; E contains [X end]		
	
	LD A, (jetY)								; A holds current Y position
	CP C
	JR NZ, .platformsLoopEnd					; Jump if Jetman is on a different level than the current platform

	; Jetman is on Y of the current platform, now check X
	LD A, (jetX)								; A holds current X position
	CP D										; Compare #jetX postion to [X start]
	JR C, .platformsLoopEnd						; Jump if #jetX < [X start]

	; Jetman is on the current platform level after it's begun, we have to check if he is not too far to the right
	CP E
	JR NC, .platformsLoopEnd					; Jump if #jetX > [X end]

	; Jetman is landing on the platform!
	CALL JetmanLanding
	RET

.platformsLoopEnd
	DJNZ .platformsLoop							; Decrease B until all platforms have been evaluated
	RET											; END HandleLandingOnPlatform

; Jetman walks to the edge of the platform and falls 
HandleFallingFromPlatform
	LD A, (jetGnd)
	CP JET_GND_WALK								; Is Jemtan in the air?
	RET NZ										; Return if not walking, no walking - no falling ;)

	LD HL, platforms							
	LD B, (HL)									; Load into B the number of platforms to check
.platformsLoop	
	INC HL										; HL points to [Y]
	LD C, (HL)									; C contains [Y]

	INC HL										; HL points to [X start]
	LD D, (HL)									; D contains [X start]	

	INC HL										; HL points to [X end]
	LD E, (HL)									; E contains [X end]		

	LD A, (jetY)								; A holds current Y position
	CP C
	JR NZ, .platformsLoopEnd						; Jump if Jetman is on a different level than the current platform

	; Jetman is on Y of the current platform, now check X
	LD A, (jetX)								; A holds current X position
	CP D										; Compare #jetX postion to [X start]
	JR C, .falling								; Jump if #jetX < [X start], meaning Jetman is falling from the left side of the platform

	CP E
	JR NC, .falling								; Jump if #jetX > [X end], meaning Jetman is falling from the right side of the platform

.platformsLoopEnd
	DJNZ .platformsLoop							; Decrease B until all platforms have been evaluated
	RET											; Jetman is still on the platform

.falling										; Jetman is falling from the platform!

	; Jemans is falling, trigger ransition: walking -> falling
	LD A, JET_SDB_T_WL
	CALL ChangeJetmanSpritePattern

	; Update #jetAir as we are flaying 
	LD A, JET_AIR_FLY						
	LD (jetAir), A

	; Reset #jetGnd as we are not walking anymore
	LD A, JET_GND_INACTIVE						
	LD (jetGnd), A	

	RET											; END HandleFallingFromPlatform

JoyMoveRight
	; ### Update temp state ###
	LD A, (jetMove)
	SET JET_MOVE_RIGHT_BIT, A	
	LD (jetMove), A

	CALL JetmanMoves						
	CALL WalkToStand

	; ### Increment X position ###
	LD BC, (jetX)	
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
	LD (jetX), BC								; Update new X postion

	; ##### Direction change: left -> right #####
	LD A, (jetDirection)
	AND JET_MOVE_RIGHT_BM						; Are we moving right already?
	CP JET_MOVE_RIGHT_BM
	JR Z, .afterDirectionChange

	; We have direction change!		
	LD A, (jetDirection)						; Reset left and set right						
	RES JET_MOVE_LEFT_BIT, A
	SET JET_MOVE_RIGHT_BIT, A
	LD (jetDirection), A
	
.afterDirectionChange

	CALL HandleFallingFromPlatform
	RET											; END #JoyMoveRight

JoyMoveLeft
	; Update temp state
	LD A, (jetMove)
	SET JET_MOVE_LEFT_BIT, A	
	LD (jetMove), A

	CALL JetmanMoves	
	CALL WalkToStand					

	; ### Decrement X position ###
	LD BC, (jetX)	
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
	LD (jetX), BC

	; ##### Direction change: right -> left #####
	LD A, (jetDirection)
	AND JET_MOVE_LEFT_BM						; Are we moving left already?
	CP JET_MOVE_LEFT_BM
	JR Z, .afterDirectionChange					; Jetman is moving left already -> end

	; We have direction change!		
	LD A, (jetDirection)						; Reset right and set left 					
	RES JET_MOVE_RIGHT_BIT, A
	SET JET_MOVE_LEFT_BIT, A
	LD (jetDirection), A
.afterDirectionChange

	CALL HandleFallingFromPlatform
	RET											; END #JoyMoveLeft

; Transition from standing on ground to walking
WalkToStand
	LD A, (jetGnd)
	CP JET_GND_INACTIVE
	RET Z										; Exit if Jetman is not on the ground
	 
	; Jetman is on the ground, is he already walking?
	CP JET_GND_WALK
	RET Z										; Exit if Jetman is already walking

	; Jetman is standing and starts walking now
	LD A, JET_GND_WALK
	LD (jetGnd), A

	LD A, JET_SDB_WALK_ST
	CALL ChangeJetmanSpritePattern	
	RET											; END #WalkToStand

; Method gets called on any movement, but not fire pressed
JetmanMoves

	; #### Reset hover counter as we have movement ####
	LD A, 0
	LD (jetInactivityCnt), A

	; #### Transition from hovering to flying? ####
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

JoyStart
	; Reset temp state
	LD A, 0										; Update #jetState by reseting left/hover and setting right
	LD (jetMove), A

	RET 										; END #JoyStart

JoyEnd											; After input processing, #JoyEnd gets executed as the last procedure. 

	; #### Jetman inactivity ####
	LD A, (jetMove)
	CP JET_MOVE_INACTIVE
	JR NZ, .afterInactivity						; Jump to the end if there is a movement

	LD A, (jetInactivityCnt)					; Increment inactivity counter
	INC A
	LD (jetInactivityCnt), A

	; ### Should Jetman hover? ###
	LD A, (jetAir)
	CP JET_AIR_INACTIVE							; Is Jemtan in the air already?
	JR Z, .afterHoover							; Jump if not flaying

	CP JET_AIR_HOOVER							; Jetman is in the air, but is he hovering already?
	JR Z, .afterHoover							; Jump if already hovering

	; Jetman is in the air, not hovering, but is he not moving long enough?
	LD A, (jetInactivityCnt)
	CP JET_HOVER_START
	JR NZ, .afterHoover							; Jetman is not moving, by sill not long enough to start hovering

	; Jetamn starts to hover!
	LD A, JET_AIR_HOOVER
	LD (jetAir), A

	LD A, JET_SDB_HOVER
	CALL ChangeJetmanSpritePattern
	JR .afterInactivity							; Alerady hovering, do not check standing	
.afterHoover

	; ### Jetman is not hovering, but should he stand? ####
	LD A, (jetGnd)
	CP JET_AIR_INACTIVE							; Is Jemtan on the ground already?
	JR Z, .afterInactivity						; Jump if not on the ground

	CP JET_GND_STAND							; Jetman is on the ground, but is he stainding already?
	JR Z, .afterInactivity						; Jump if already standing

	; Jetman is on the ground and does not move, but is he not moving long enough?
	LD A, (jetInactivityCnt)
	CP JET_STAND_START
	JR NZ, .afterStand							; Jump if Jetman stands for too short to trigger standing

	; Transtion from walking to standing
	LD A, JET_GND_STAND
	LD (jetGnd), A

	LD A, JET_SDB_STAND							; Change animation
	CALL ChangeJetmanSpritePattern
	JR .afterInactivity
.afterStand
	
	; Code is here because: jetInactivityCnt > 0 AND jetInactivityCnt < JET_STAND_START 
	; Jetman stands still for a short time, not long enough, to play standing animation, but at least we should stop walking animation.	
	LD A, (jetGnd)
	CP JET_GND_WALK
	JR NZ, .afterInactivity						; Jump is if not walking
	
	CP JET_GND_JSTAND
	JR Z, .afterInactivity						; Jump already j-standing (just standing - for a short time)

	LD A, JET_GND_JSTAND
	LD (jetGnd), A

	LD A, JET_SDB_JSTAND						; Change animation
	CALL ChangeJetmanSpritePattern

.afterInactivity

	; PRINT START
	LD B, 0
	LD H, 0
	LD HL, (jetX)
	CALL PrintNumHL

	LD B, 10
	LD H, 0
	LD A,  (jetY)
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

JoyPressFire

	RET	
