;----------------------------------------------------------;
;                        Joystick Input                    ;
;----------------------------------------------------------;

; The counter turns off the joystick for a few iterations. Each call #JoInput decreases it by one. 
; It's used for effects like bumping from the platform's edge or falling.
joDisabledCnt		BYTE 0

;----------------------------------------------------------;
;                         #JoInput                         ;
;----------------------------------------------------------;
JoInput

	; Handle disabled joystick
	LD A, (joDisabledCnt)
	CP 0
	JR Z, .afterjoystickDisabled				; Jump if joystick is not disabled -> #joDisabledCnt > 0

	; Joystick is disabled
	DEC A										; Decrement disabled counter
	LD (joDisabledCnt), A
	RET											; Do not process input, as joystick is disabled
.afterjoystickDisabled	

	CALL JoStart
	
	; Key Rright pressed ?
	LD A, _KB_6_TO_0_HEF						; $EF -> A (6...0)
	IN A, (_KB_REG_HFE)							; Read keyboard input into A
	BIT 2, A									; Bit 2 reset -> Rright pessed
	CALL Z, JoMoveRight

	; Joystick right pressed ?
	LD A, _JOY_MASK_H20							; Activete joystick register
	IN A, (_JOY_REG_H1F) 						; Read joystick input into A
	BIT 0, A									; Bit 0 set -> Right pessed
	CALL NZ, JoMoveRight			

	; Key Left pressed ?
	LD A, _KB_5_TO_1_HF7						; $FD -> A (5...1)
	IN A, (_KB_REG_HFE)							; Read keyboard input into A
	BIT 4, A									; Bit 4 reset -> Left pessed
	CALL Z, JoMoveLeft		

	; Joystick left pressed ?
	LD A, _JOY_MASK_H20							; Activete joystick register
	IN A, (_JOY_REG_H1F) 						; Read joystick input into A
	BIT 1, A									; Bit 1 set -> Left pessed
	CALL NZ, JoMoveLeft

	; Key Up pressed ?
	LD A, _KB_6_TO_0_HEF						; $EF -> A (6...0)
	IN A, (_KB_REG_HFE)							; Read keyboard input into A
	BIT 3, A									; Bit 3 reset -> Up pessed
	CALL Z, JoMoveUp	

	; Joystick up pressed ?
	LD A, _JOY_MASK_H20							; Activete joystick register
	IN A, (_JOY_REG_H1F) 						; Read joystick input into A
	BIT 3, A									; Bit 3 set -> Up pessed
	CALL NZ, JoMoveUp

	; Key Down pressed ?
	LD A, _KB_6_TO_0_HEF						; $EF -> A (6...0)
	IN A, (_KB_REG_HFE)							; Read keyboard input into A
	BIT 4, A									; Bit 4 reset -> Down pessed
	CALL Z, JoMoveDown				

	; Joystick down pressed ?
	LD A, _JOY_MASK_H20							; Activete joystick register
	IN A, (_JOY_REG_H1F) 						; Read joystick input into A
	BIT 2, A									; Bit 2 set -> Down pessed
	CALL NZ, JoMoveDown

	; Key Fire (Z) pressed ?
	LD A, _KB_V_TO_Z_HFE						; $FD -> A (5...1)
	IN A, (_KB_REG_HFE)							; Read keyboard input into A
	BIT 1, A									; Bit 1 reset -> Z pessed
	CALL Z, JoPressFire

	; Joystick fire pressed ?
	LD A, _JOY_MASK_H20							; Activete joystick register
	IN A, (_JOY_REG_H1F) 						; Read joystick input into A
	AND %01110000								; Any of three fires pressed?
	CALL NZ, JoPressFire	
	
	CALL JoEnd

	RET											; END JoInput

;----------------------------------------------------------;
;                       #JoMoveUp                          ;
;----------------------------------------------------------;
JoMoveUp

	; Update #jtMove state
	LD A, (jtMove)
	SET JT_MOVE_UP_BIT, A	
	LD (jtMove), A

	CALL JtJetmanMoves							

	; Decrement Y position
	LD A, (jtY)	
	CP SC_Y_MIN_POS 							; Do not decrement if Jetman has reached the top of the screen.
	JR Z, .afterDec
	DEC A
	LD (jtY), A
.afterDec	

	; Direction change: down -> up
	LD A, (jtDirection)
	AND JT_MOVE_UP_BM							; Are we moving Up already?
	CP JT_MOVE_UP_BM
	JR Z, .afterDirectionChange

	; We have direction change!	
	LD A, (jtDirection)							; Update #jetState by reseting down and setting up
	RES JT_MOVE_DOWN_BIT, A
	SET JT_MOVE_UP_BIT, A
	LD (jtDirection), A
.afterDirectionChange

	; Transition from walking to flaying
	LD A, (jtGnd)
	CP JT_GND_INACTIVE							; Check if Jetnan is on the ground/platform
	CALL NZ, JpJetmanTakesoff

	CALL JpBumpIntoPlatformBottom
	RET											; END #JoMoveUp	

;----------------------------------------------------------;
;                      #JoMoveRight                       ;
;----------------------------------------------------------;
JoMoveRight
	; Update temp state
	LD A, (jtMove)
	SET JT_MOVE_RIGHT_BIT, A	
	LD (jtMove), A

	CALL JtJetmanMoves						
	CALL JtStandToWalk
	CALL JtIncJetX

	; ##Direction change: left -> right##
	LD A, (jtDirection)
	AND JT_MOVE_RIGHT_BM						; Are we moving right already?
	CP JT_MOVE_RIGHT_BM
	JR Z, .afterDirectionChange

	; We have direction change!		
	LD A, (jtDirection)							; Reset left and set right						
	RES JT_MOVE_LEFT_BIT, A
	SET JT_MOVE_RIGHT_BIT, A
	LD (jtDirection), A
	
.afterDirectionChange

	; Bupm from the left side of the platform?
	LD IX, jpPlatformBumpLeft
	LD H, JT_AIR_BUMP_LEFT
	CALL JpBumpIntoPlatformLR

	CALL JpFallingFromPlatform
	RET											; END #JoMoveRight

;----------------------------------------------------------;
;                       #JoMoveLeft                       ;
;----------------------------------------------------------;
JoMoveLeft
	; Update #jtMove state
	LD A, (jtMove)
	SET JT_MOVE_LEFT_BIT, A	
	LD (jtMove), A

	CALL JtJetmanMoves	
	CALL JtStandToWalk					
	CALL JtDecJetX

	; Direction change: right -> left
	LD A, (jtDirection)
	AND JT_MOVE_LEFT_BM							; Are we moving left already?
	CP JT_MOVE_LEFT_BM
	JR Z, .afterDirectionChange					; Jetman is moving left already -> end

	; We have direction change!		
	LD A, (jtDirection)							; Reset right and set left 					
	RES JT_MOVE_RIGHT_BIT, A
	SET JT_MOVE_LEFT_BIT, A
	LD (jtDirection), A
.afterDirectionChange

	CALL JpFallingFromPlatform

	; Bupm from the right side of the platform?
	LD IX, jpPlatformBumpRight
	LD H, JT_AIR_BUMP_RIGHT
	CALL JpBumpIntoPlatformLR

	RET											; END #JoMoveLeft

;----------------------------------------------------------;
;                     #JoPressFire                         ;
;----------------------------------------------------------;
JoPressFire

	RET	

;----------------------------------------------------------;
;                       #JoMoveDown                        ;
;----------------------------------------------------------;
JoMoveDown
	; Update #jtMove state
	LD A, (jtMove)
	SET JT_MOVE_DOWN_BIT, A	
	LD (jtMove), A

	; Cannot move down when walking
	LD A, (jtGnd)
	CP JT_GND_INACTIVE
	RET NZ	

	CALL JtJetmanMoves						

	; Increment Y position#
	LD A, (jtY)
	CP JT_GROUND_LEVEL								; Do not increment if Jetman has reached the ground
	JR Z, .afterInc						

	; Move Jetman 1px down
	INC A
	LD (jtY), A

	; Landing on the ground
	CP JT_GROUND_LEVEL
	CALL Z, JpJetmanLanding						; Execute landing on the ground if Jetman has reached the ground.
	CALL JpLandingOnPlatform					; Or should he land on one of the platforms?

	; Direction change? 
	LD A, (jtDirection)
	AND JT_MOVE_DOWN_BM						; Are we moving down already?
	CP JT_MOVE_DOWN_BM
	JR Z, .afterDirectionChange

	; We have direction change!	
	LD A, (jtDirection)						; Update #jetState by reseting Up/Hover and setting Down
	RES JT_MOVE_UP_BIT, A
	SET JT_MOVE_DOWN_BIT, A	
	LD (jtDirection), A
.afterDirectionChange
.afterInc	

	RET										; END #JoMoveDown

;----------------------------------------------------------;
;                         #JoStart                         ;
;----------------------------------------------------------;
JoStart
	LD A, JT_MOVE_INACTIVE						; Update #jetState by reseting left/hover and setting right
	LD (jtMove), A

	RET 										; END #JoStart

;----------------------------------------------------------;
;                          #JoEnd                          ;
;----------------------------------------------------------;
JoEnd											; After input processing, #JoEnd gets executed as the last procedure. 

	; #Jetman inactivity#
	LD A, (jtMove)
	CP JT_MOVE_INACTIVE
	JR NZ, .afterInactivity						; Jump to the end if there is a movement

	LD A, (jtInactivityCnt)						; Increment inactivity counter
	INC A
	LD (jtInactivityCnt), A

	; Should Jetman hover?
	LD A, (jtAir)
	CP JT_AIR_INACTIVE							; Is Jemtan in the air already?
	JR Z, .afterHoover							; Jump if not flaying

	CP JT_AIR_HOOVER							; Jetman is in the air, but is he hovering already?
	JR Z, .afterHoover							; Jump if already hovering

	; Jetman is in the air, not hovering, but is he not moving long enough?
	LD A, (jtInactivityCnt)
	CP JT_HOVER_START
	JR NZ, .afterHoover							; Jetman is not moving, by sill not long enough to start hovering

	; Jetamn starts to hover!
	LD A, JT_AIR_HOOVER
	LD (jtAir), A

	LD A, JS_SDB_HOVER
	CALL JsChangeJetmanSpritePattern
	JR .afterInactivity							; Alerady hovering, do not check standing	
.afterHoover

	; Jetman is not hovering, but should he stand?
	LD A, (jtGnd)
	CP JT_AIR_INACTIVE							; Is Jemtan on the ground already?
	JR Z, .afterInactivity						; Jump if not on the ground

	CP JT_GND_STAND								; Jetman is on the ground, but is he stainding already?
	JR Z, .afterInactivity						; Jump if already standing

	; Jetman is on the ground and does not move, but is he not moving long enough?
	LD A, (jtInactivityCnt)
	CP JT_STAND_START
	JR NZ, .afterStand							; Jump if Jetman stands for too short to trigger standing

	; Transtion from walking to standing
	LD A, JT_GND_STAND
	LD (jtGnd), A

	LD A, JS_SDB_STAND							; Change animation
	CALL JsChangeJetmanSpritePattern
	JR .afterInactivity
.afterStand
	
	; Code is here because: jtInactivityCnt > 0 AND jtInactivityCnt < JT_STAND_START 
	; Jetman stands still for a short time, not long enough, to play standing animation, but at least we should stop walking animation.	
	LD A, (jtGnd)
	CP JT_GND_WALK
	JR NZ, .afterInactivity						; Jump is if not walking
	
	CP JT_GND_JSTAND
	JR Z, .afterInactivity						; Jump already j-standing (just standing - for a short time)

	LD A, (jtInactivityCnt)
	CP JT_JSTAND_START
	JR NZ, .afterInactivity						; Jump if Jetman stands for too short to trigger j-standing

	LD A, JT_GND_JSTAND
	LD (jtGnd), A

	LD A, JS_SDB_JSTAND							; Change animation
	CALL JsChangeJetmanSpritePattern

.afterInactivity

	RET											; END #JoEnd	

;----------------------------------------------------------;
;                       #JoDisabled                        ;
;----------------------------------------------------------;
JoDisabled
	; Handle disabled joystick
	LD A, (joDisabledCnt)
	CP 0
	RET Z										; Jump if joystick is disabled -> #joDisabledCnt == 0

	CALL JpBumpOnJoystickDisabled

	; Reset the #jtAir on the last frame of the disabled joystick
	LD A, (jtAir)
	CP 1
	RET NZ										; Jump if it's not the last frame (!=1)
	LD A, JT_AIR_FLY
	LD (jtAir), A

	RET											; END #JoDisabled	