;----------------------------------------------------------;
;                     Jetman Movement                      ;
;----------------------------------------------------------;
	MODULE jm

; Hovering/Standing
jetmanInactivityCnt		BYTE 0					; The counter increases with each frame when no up/down is pressed. 
												; When it reaches #HOVER_START, Jetman will start hovering
HOVER_START				= 40
STAND_START				= 30
JSTAND_START			= 5

GROUND_LEVEL			= 225					; The lowest walking platform

;----------------------------------------------------------;
;                       #StandToWalk                       ; 
;----------------------------------------------------------;
; Transition from standing/landing on ground to walking
StandToWalk
	LD A, (jt.jetState)
	BIT jt.JET_STATE_GND_BIT, A
	RET Z										; Exit if Jetman is not on the ground
	 
	; Jetman is on the ground, is he already walking?
	LD A, (jt.jetGnd)	
	CP jt.GND_WALK
	RET Z										; Exit if Jetman is already walking

	; Jetman is standing and starts walking now
	LD A, jt.GND_WALK
	LD (jt.jetGnd), A
	
	LD A, js.SDB_WALK_ST
	CALL js.ChangeJetSpritePattern	
	RET

;----------------------------------------------------------;
;                     #JoystickMoves                       ;
;----------------------------------------------------------;
; Method gets called on any joystick movement, but not fire pressed
JoystickMoves
	CALL bg.UpdateOnJetmanMove
	CALL ro.UpdateOnJetmanMove
	
	; Reset inactivity counter as we have movement
	XOR A										; Set A to 0
	LD (jetmanInactivityCnt), A

	; Transition from hovering to flying?
	LD A, (jt.jetAir)
	CP jt.AIR_HOOVER							; Is Jemtman hovering?
	JR NZ, .afterHovering						; Jump if not hovering

	; Jetman is hovering, but we have movement, so switch state to fly
	LD A, jt.AIR_FLY
	LD (jt.jetAir), A
	
	; Switch to flaying animation
	LD A, js.SDB_FLY
	CALL js.ChangeJetSpritePattern
.afterHovering	

	RET

;----------------------------------------------------------;
;                      #JoyMoveUp                          ;
;----------------------------------------------------------;
JoyMoveUp

	; Update #joyDirection state
	LD A, (id.joyDirection)
	SET id.MOVE_UP_BIT, A	
	LD (id.joyDirection), A

	CALL JoystickMoves

	; Decrement Y position
	LD A, (jo.jetY)	
	CP sc.SCR_Y_MIN_POS 						; Do not decrement if Jetman has reached the top of the screen
	JR Z, .afterDec
	CALL jo.DecJetY
.afterDec	

	; Direction change: down -> up
	LD A, (id.jetDirection)
	AND id.MOVE_UP_MASK							; Are we moving Up already?
	CP id.MOVE_UP_MASK
	JR Z, .afterDirectionChange

	; We have direction change!
	LD A, (id.jetDirection)						; Update #jetState by resetting down and setting up
	RES id.MOVE_DOWN_BIT, A
	SET id.MOVE_UP_BIT, A
	LD (id.jetDirection), A
.afterDirectionChange

	; Transition from walking to flaying
	CALL jp.JetTakesoff

	; Bumping from below into the platform?
	CALL jp.BumpIntoPlatFormBelow
	RET											; END #JoyMoveUp	

;----------------------------------------------------------;
;                     #JoyMoveRight                        ;
;----------------------------------------------------------;
JoyMoveRight
	; Update temp state
	LD A, (id.joyDirection)
	SET id.MOVE_RIGHT_BIT, A	
	LD (id.joyDirection), A

	CALL JoystickMoves						
	CALL StandToWalk
	CALL jo.IncJetX

	; ##Direction change: left -> right##
	LD A, (id.jetDirection)
	AND id.MOVE_RIGHT_MASK						; Are we moving right already?
	CP id.MOVE_RIGHT_MASK
	JR Z, .afterDirectionChange

	; We have direction change!		
	LD A, (id.jetDirection)						; Reset left and set right
	RES id.MOVE_LEFT_BIT, A
	SET id.MOVE_RIGHT_BIT, A
	LD (id.jetDirection), A
	
.afterDirectionChange

	; Bupm from the left side of the platform?
	LD H, jt.AIR_BUMP_LEFT
	CALL jp.BumpIntoPlatformLR

	CALL jp.FallingFromPlatform
	RET											; END #JoyMoveRight

;----------------------------------------------------------;
;                      #JoyMoveLeft                        ;
;----------------------------------------------------------;
JoyMoveLeft
	; Update #joyDirection state
	LD A, (id.joyDirection)
	SET id.MOVE_LEFT_BIT, A	
	LD (id.joyDirection), A

	CALL JoystickMoves	
	CALL StandToWalk					
	CALL jo.DecJetX

	; Direction change: right -> left
	LD A, (id.jetDirection)
	AND id.MOVE_LEFT_MASK						; Are we moving left already?
	CP id.MOVE_LEFT_MASK
	JR Z, .afterDirectionChange					; Jetman is moving left already -> end

	; We have direction change!		
	LD A, (id.jetDirection)						; Reset right and set left
	RES id.MOVE_RIGHT_BIT, A
	SET id.MOVE_LEFT_BIT, A
	LD (id.jetDirection), A
.afterDirectionChange

	; Bupm from the right side of the platform?
	LD H, jt.AIR_BUMP_RIGHT
	CALL jp.BumpIntoPlatformLR
	CALL jp.FallingFromPlatform

	RET

;----------------------------------------------------------;
;                      #JoyMoveDown                        ;
;----------------------------------------------------------;
JoyMoveDown

	; Update #joyDirection state
	LD A, (id.joyDirection)
	SET id.MOVE_DOWN_BIT, A	
	LD (id.joyDirection), A

	; Cannot move down when walking
	LD A, (jt.jetState)
	BIT jt.JET_STATE_GND_BIT, A
	RET NZ	

	CALL JoystickMoves						

	; Increment Y position
	LD A, (jo.jetY)
	CP GROUND_LEVEL								; Do not increment if Jetman has reached the ground
	JR Z, .afterInc						

	CALL jo.IncJetY								; Move Jetman 1px down
.afterInc	

	; Landing on the ground
	CP GROUND_LEVEL
	CALL Z, jp.JetLanding						; Execute landing on the ground if Jetman has reached the ground
	CALL jp.LandingOnPlatform					; Or should he land on one of the platforms?

	; Direction change? 
	LD A, (id.jetDirection)
	AND id.MOVE_DOWN_MASK						; Are we moving down already?
	CP id.MOVE_DOWN_MASK
	JR Z, .afterDirectionChange

	; We have direction change!	
	LD A, (id.jetDirection)						; Update #jetState by resetting Up/Hover and setting Down
	RES id.MOVE_UP_BIT, A
	SET id.MOVE_DOWN_BIT, A	
	LD (id.jetDirection), A
.afterDirectionChange

	RET

;----------------------------------------------------------;
;                        #JoyStart                         ;
;----------------------------------------------------------;
JoyStart
	LD A, id.MOVE_INACTIVE						; Update #jetState by resetting left/hover and setting right
	LD (id.joyDirection), A

	RET

;----------------------------------------------------------;
;                         #JoyEnd                          ;
;----------------------------------------------------------;
JoyEnd											; After input processing, #JoyEnd gets executed as the last procedure
	; #Jetman inactivity
	LD A, (id.joyDirection)
	CP id.MOVE_INACTIVE
	JR NZ, .afterInactivity						; Jump to the end if there is a movement

	LD A, (jetmanInactivityCnt)					; Increment inactivity counter
	INC A
	LD (jetmanInactivityCnt), A

	; Should Jetman hover?
	LD A, (jt.jetState)
	bit jt.JET_STATE_AIR_BIT, A					; Is Jemtan in the air already?
	JR Z, .afterHoover							; Jump if not flaying

	LD A, (jt.jetAir)
	CP jt.AIR_HOOVER							; Jetman is in the air, but is he hovering already?
	JR Z, .afterHoover							; Jump if already hovering

	; Jetman is in the air, not hovering, but is he not moving long enough?
	LD A, (jetmanInactivityCnt)
	CP HOVER_START
	JR NZ, .afterHoover							; Jetman is not moving, by sill not long enough to start hovering

	; Jetamn starts to hover!
	LD A, jt.AIR_HOOVER
	LD (jt.jetAir), A

	LD A, js.SDB_HOVER
	CALL js.ChangeJetSpritePattern
	JR .afterInactivity							; Alerady hovering, do not check standing	
.afterHoover

	; Jetman is not hovering, but should he stand?
	LD A, (jt.jetState)
	BIT jt.JET_STATE_GND_BIT, A					; Is Jemtan on the ground already?
	JR Z, .afterInactivity						; Jump if not on the ground

	LD A, (jt.jetGnd)
	CP jt.GND_STAND								; Jetman is on the ground, but is he stainding already?
	JR Z, .afterInactivity						; Jump if already standing

	; Jetman is on the ground and does not move, but is he not moving long enough?
	LD A, (jetmanInactivityCnt)
	CP STAND_START
	JR NZ, .afterStand							; Jump if Jetman stands for too short to trigger standing
	
	; Transtion from walking to standing
	LD A, jt.GND_STAND
	LD (jt.jetGnd), A

	LD A, js.SDB_STAND							; Change animation
	CALL js.ChangeJetSpritePattern
	JR .afterInactivity
.afterStand

	; We are here because: jetmanInactivityCnt > 0 and jetmanInactivityCnt < STAND_START 
	; Jetman stands still for a short time, not long enough, to play standing animation, but at least we should stop walking animation.	
	LD A, (jt.jetGnd)
	CP jt.GND_WALK
	JR NZ, .afterInactivity						; Jump is if not walking
	
	CP jt.GND_JSTAND
	JR Z, .afterInactivity						; Jump already j-standing (just standing - for a short time)

	LD A, (jetmanInactivityCnt)
	CP JSTAND_START
	JR NZ, .afterInactivity						; Jump if Jetman stands for too short to trigger j-standing

	LD A, jt.GND_JSTAND
	LD (jt.jetGnd), A

	LD A, js.SDB_JSTAND							; Change animation
	CALL js.ChangeJetSpritePattern

.afterInactivity

	RET

;----------------------------------------------------------;
;                      #JoyDisabled                        ;
;----------------------------------------------------------;
JoyDisabled
	; Handle disabled joystick
	LD A, (id.joyDisabledCnt)
	CP 0
	RET Z										; Jump if joystick is enabled -> #joyDisabledCnt == 0

	CALL jp.AnimateOnJoystickDisabled
	RET

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE