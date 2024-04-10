;----------------------------------------------------------;
;                      #JoystickInput                      ;
;----------------------------------------------------------;

; The counter turns off the joystick for a few iterations. Each call #JoystickInput decreases it by one. 
; It's used for effects like bumping from the platform's edge or falling.
joystickDisabledCnt		BYTE 0

JoystickInput

	; Handle disabled joystick
	LD A, (joystickDisabledCnt)
	CP 0
	JR Z, .afterjoystickDisabled				; Jump if joystick is not disabled -> #joystickDisabledCnt > 0

	; Joystick is disabled
	DEC A										; Decrement disabled counter
	LD (joystickDisabledCnt), A
	RET											; Do not process input, as joystick is disabled
.afterjoystickDisabled	

	CALL JoyStart
	
	; Key Rright pressed ?
	LD A, KB_6_TO_0_HEF							; $EF -> A (6...0)
	IN A, (KB_REG_HFE) 							; Read keyboard input into A
	BIT 2, A									; Bit 2 reset -> Rright pessed
	CALL Z, JoyMoveRight

	; Joystick right pressed ?
	LD A, JOY_MASK_H20							; Activete joystick register
	IN A, (JOY_REG_H1F) 						; Read joystick input into A
	BIT 0, A									; Bit 0 set -> Right pessed
	CALL NZ, JoyMoveRight			

	; Key Left pressed ?
	LD A, KB_5_TO_1_HF7							; $FD -> A (5...1)
	IN A, (KB_REG_HFE) 							; Read keyboard input into A
	BIT 4, A									; Bit 4 reset -> Left pessed
	CALL Z, JoyMoveLeft		

	; Joystick left pressed ?
	LD A, JOY_MASK_H20							; Activete joystick register
	IN A, (JOY_REG_H1F) 						; Read joystick input into A
	BIT 1, A									; Bit 1 set -> Left pessed
	CALL NZ, JoyMoveLeft

	; Key Up pressed ?
	LD A, KB_6_TO_0_HEF							; $EF -> A (6...0)
	IN A, (KB_REG_HFE) 							; Read keyboard input into A
	BIT 3, A									; Bit 3 reset -> Up pessed
	CALL Z, JoyMoveUp	

	; Joystick up pressed ?
	LD A, JOY_MASK_H20							; Activete joystick register
	IN A, (JOY_REG_H1F) 						; Read joystick input into A
	BIT 3, A									; Bit 3 set -> Up pessed
	CALL NZ, JoyMoveUp

	; Key Down pressed ?
	LD A, KB_6_TO_0_HEF							; $EF -> A (6...0)
	IN A, (KB_REG_HFE) 							; Read keyboard input into A
	BIT 4, A									; Bit 4 reset -> Down pessed
	CALL Z, JoyMoveDown				

	; Joystick down pressed ?
	LD A, JOY_MASK_H20							; Activete joystick register
	IN A, (JOY_REG_H1F) 						; Read joystick input into A
	BIT 2, A									; Bit 2 set -> Down pessed
	CALL NZ, JoyMoveDown

	; Key Fire (Z) pressed ?
	LD A, KB_V_TO_Z_HFE							; $FD -> A (5...1)
	IN A, (KB_REG_HFE) 							; Read keyboard input into A
	BIT 1, A									; Bit 1 reset -> Z pessed
	CALL Z, JoyPressFire

	; Joystick fire pressed ?
	LD A, JOY_MASK_H20							; Activete joystick register
	IN A, (JOY_REG_H1F) 						; Read joystick input into A
	AND %01110000								; Any of three fires pressed?
	CALL NZ, JoyPressFire	
	
	CALL JoyEnd

	RET											; END JoystickInput

;----------------------------------------------------------;
;                       #JoyMoveUp                         ;
;----------------------------------------------------------;
JoyMoveUp

	; Update #jetMove state
	LD A, (jetMove)
	SET JET_MOVE_UP_BIT, A	
	LD (jetMove), A

	CALL JetmanMoves							

	; Decrement Y position
	LD A, (jetY)	
	CP DI_Y_MIN_POS 							; Do not decrement if Jetman has reached the top of the screen.
	JR Z, .afterDec
	DEC A
	LD (jetY), A
.afterDec	

	; Direction change: down -> up
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

	; Transition from walking to flaying
	LD A, (jetGnd)
	CP JET_GND_INACTIVE							; Check if Jetnan is on the ground/platform
	CALL NZ, JetmanTakesoff

	CALL BumpIntoPlatformBottom
	RET											; END #JoyMoveUp	

;----------------------------------------------------------;
;                      #JoyMoveRight                       ;
;----------------------------------------------------------;
JoyMoveRight
	; Update temp state
	LD A, (jetMove)
	SET JET_MOVE_RIGHT_BIT, A	
	LD (jetMove), A

	CALL JetmanMoves						
	CALL StandToWalk
	CALL incJetX

	; ##Direction change: left -> right##
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

	; Bupm from the left side of the platform?
	LD IX, platformBumpLeft
	LD H, JET_AIR_BUMP_LEFT
	CALL BumpIntoPlatformLR

	CALL FallingFromPlatform
	RET											; END #JoyMoveRight

;----------------------------------------------------------;
;                       #JoyMoveLeft                       ;
;----------------------------------------------------------;
JoyMoveLeft
	; Update #jetMove state
	LD A, (jetMove)
	SET JET_MOVE_LEFT_BIT, A	
	LD (jetMove), A

	CALL JetmanMoves	
	CALL StandToWalk					
	CALL decJetX

	; Direction change: right -> left
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

	CALL FallingFromPlatform

	; Bupm from the right side of the platform?
	LD IX, platformBumpRight
	LD H, JET_AIR_BUMP_RIGHT
	CALL BumpIntoPlatformLR

	RET											; END #JoyMoveLeft

;----------------------------------------------------------;
;                     #JoyPressFire                        ;
;----------------------------------------------------------;
JoyPressFire

	RET	

;----------------------------------------------------------;
;                       #JoyMoveDown                       ;
;----------------------------------------------------------;
JoyMoveDown
	; Update #jetMove state
	LD A, (jetMove)
	SET JET_MOVE_DOWN_BIT, A	
	LD (jetMove), A

	; Cannot move down when walking
	LD A, (jetGnd)
	CP JET_GND_INACTIVE
	RET NZ	

	CALL JetmanMoves						

	; Increment Y position#
	LD A, (jetY)
	CP GROUND_LEVEL								; Do not increment if Jetman has reached the ground
	JR Z, .afterInc						

	; Move Jetman 1px down
	INC A
	LD (jetY), A

	; Landing on the ground
	CP GROUND_LEVEL
	CALL Z, JetmanLanding						; Execute landing on the ground if Jetman has reached the ground.
	CALL LandingOnPlatform				; Or should he land on one of the platforms?

	; Direction change? 
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

;----------------------------------------------------------;
;                         #JoyStart                        ;
;----------------------------------------------------------;
JoyStart
	LD A, JET_MOVE_INACTIVE						; Update #jetState by reseting left/hover and setting right
	LD (jetMove), A

	RET 										; END #JoyStart

;----------------------------------------------------------;
;                          #JoyEnd                         ;
;----------------------------------------------------------;
JoyEnd											; After input processing, #JoyEnd gets executed as the last procedure. 

	; #Jetman inactivity#
	LD A, (jetMove)
	CP JET_MOVE_INACTIVE
	JR NZ, .afterInactivity						; Jump to the end if there is a movement

	LD A, (jetInactivityCnt)					; Increment inactivity counter
	INC A
	LD (jetInactivityCnt), A

	; Should Jetman hover?
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

	; Jetman is not hovering, but should he stand?
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

	LD A, (jetInactivityCnt)
	CP JET_JSTAND_START
	JR NZ, .afterInactivity						; Jump if Jetman stands for too short to trigger j-standing

	LD A, JET_GND_JSTAND
	LD (jetGnd), A

	LD A, JET_SDB_JSTAND						; Change animation
	CALL ChangeJetmanSpritePattern

.afterInactivity

	RET											; END #JoyEnd	

;----------------------------------------------------------;
;                     #JoystickDisabled                    ;
;----------------------------------------------------------;
JoystickDisabled
	; Handle disabled joystick
	LD A, (joystickDisabledCnt)
	CP 0
	RET Z										; Jump if joystick is disabled -> #joystickDisabledCnt == 0

	CALL BumpOnJoystickDisabled

	; Reset the #jetAir on the last frame of the disabled joystick
	LD A, (jetAir)
	CP 1
	RET NZ 											; Jump if it's not the last frame (!=1)
	LD A, JET_AIR_FLY
	LD (jetAir), A

	RET												; END #JoystickDisabled	