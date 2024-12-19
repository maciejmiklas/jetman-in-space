;----------------------------------------------------------;
;                     Jetman Movement                      ;
;----------------------------------------------------------;
	MODULE jm

; Hovering/Standing
; The counter increases with each frame when no up/down is pressed.
; When it reaches #_CF_HOVER_START, Jetman will start hovering
jetInactivityCnt		BYTE 0

;----------------------------------------------------------;
;                       #StandToWalk                       ; 
;----------------------------------------------------------;
; Transition from standing/landing on ground to walking
StandToWalk

	LD A, (jt.jetGnd)
	CP jt.STATE_INACTIVE
	RET Z										; Exit if Jetman is not on the ground

	; Jetman is on the ground, is he already walking?
	LD A, (jt.jetGnd)	
	CP jt.GND_WALK
	RET Z										; Exit if Jetman is already walking

	; Jetman is standing and starts walking now
	LD A, jt.GND_WALK
	CALL jt.SetJetStateGnd
	
	LD A, js.SDB_WALK_ST
	CALL js.ChangeJetSpritePattern

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                     #JoystickMoves                       ;
;----------------------------------------------------------;
; Method gets called on any joystick movement (only real key press), but not fire pressed
JoystickMoves

	CALL pl.ResetJoyOffBump
	CALL bg.UpdateBackgroundOnJetmanMove
	CALL ro.UpdateRocketOnJetmanMove
	CALL pl.JetPlatformHitOnJoyMove
	
	; ##########################################
	; Reset inactivity counter as we have movement
	XOR A										; Set A to 0
	LD (jetInactivityCnt), A

	; ##########################################
	; Transition from hovering to flying?
	LD A, (jt.jetAir)
	CP jt.AIR_HOOVER							; Is Jemtman hovering?
	JR NZ, .afterHovering						; Jump if not hovering

	; Jetman is hovering, but we have movement, so switch state to fly
	LD A, jt.AIR_FLY
	CALL jt.SetJetStateAir
	
	; Switch to flaying animation
	LD A, js.SDB_FLY
	CALL js.ChangeJetSpritePattern
.afterHovering	

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                      #JoyMoveUp                          ;
;----------------------------------------------------------;
JoyMoveUp

	CALL CanJetMove
	CP _CF_RET_ON
	RET NZ										; Do not process input on disabled joystick

.afterJoyCntEnabled

	; ##########################################
	CALL JoystickMoves

	; ##########################################
	; Decrement Y position
	LD A, (jpo.jetY)	
	CP _CF_GSC_Y_MIN 							; Do not decrement if Jetman has reached the top of the screen
	JR Z, .afterDec
	CALL jpo.DecJetY
.afterDec	

	; ##########################################
	; Direction change: down -> up
	LD A, (ind.jetDirection)
	AND ind.MOVE_UP_MASK						; Are we moving Up already?
	CP ind.MOVE_UP_MASK
	JR Z, .afterDirectionChange

	; We have direction change!
	LD A, (ind.jetDirection)					; Update #jetState by resetting down and setting up
	RES ind.MOVE_DOWN_BIT, A
	SET ind.MOVE_UP_BIT, A
	LD (ind.jetDirection), A
.afterDirectionChange

	; ##########################################	
	CALL pl.JetPlatformTakesoff					; Transition from walking to flaying
	CALL js.ChangeJetSpriteOnFlyUp	

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                     #JoyMoveRight                        ;
;----------------------------------------------------------;
JoyMoveRight

	CALL CanJetMove
	CP _CF_RET_ON
	RET NZ										; Do not process input on disabled joystick

	; ##########################################
	CALL JoystickMoves
	CALL StandToWalk
	CALL jpo.IncJetX

	; ##########################################
	; Direction change: left -> right
	LD A, (ind.jetDirection)
	AND ind.MOVE_RIGHT_MASK						; Are we moving right already?
	CP ind.MOVE_RIGHT_MASK
	JR Z, .afterDirectionChange

	; We have direction change!
	LD A, (ind.jetDirection)					; Reset left and set right
	RES ind.MOVE_LEFT_BIT, A
	SET ind.MOVE_RIGHT_BIT, A
	LD (ind.jetDirection), A
	
.afterDirectionChange

	; ##########################################
	; Fall from the platform?
	CALL pl.JetFallingFromPlatform

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                      #JoyMoveLeft                        ;
;----------------------------------------------------------;
JoyMoveLeft

	CALL CanJetMove
	CP _CF_RET_ON
	RET NZ										; Do not process input on disabled joystick

	; ##########################################
	CALL JoystickMoves	
	CALL StandToWalk
	CALL jpo.DecJetX

	; ##########################################
	; Direction change: right -> left
	LD A, (ind.jetDirection)
	AND ind.MOVE_LEFT_MASK						; Are we moving left already?
	CP ind.MOVE_LEFT_MASK
	JR Z, .afterDirectionChange					; Jetman is moving left already -> end

	; We have direction change!		
	LD A, (ind.jetDirection)					; Reset right and set left
	RES ind.MOVE_RIGHT_BIT, A
	SET ind.MOVE_LEFT_BIT, A
	LD (ind.jetDirection), A
.afterDirectionChange

	; ##########################################
	; Fall from the platform?
	CALL pl.JetFallingFromPlatform

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                      #JoyMoveDown                        ;
;----------------------------------------------------------;
JoyMoveDown

	CALL CanJetMove
	CP _CF_RET_ON
	RET NZ										; Do not process input on disabled joystick

	; ##########################################
	; Cannot move down when walking
	LD A, (jt.jetGnd)
	CP jt.STATE_INACTIVE
	RET NZ

	; ##########################################
	CALL JoystickMoves

	; ##########################################
	; Increment Y position
	LD A, (jpo.jetY)
	CP _CF_GSC_JET_GND							; Do not increment if Jetman has reached the ground
	JR Z, .afterInc						

	CALL jpo.IncJetY							; Move Jetman 1px down
.afterInc	

	; ##########################################
	; Landing on the ground
	CP _CF_GSC_JET_GND
	CALL Z, pl.JetLanding						; Execute landing on the ground if Jetman has reached the ground

	; ##########################################
	; Direction change? 
	LD A, (ind.jetDirection)
	AND ind.MOVE_DOWN_MASK						; Are we moving down already?
	CP ind.MOVE_DOWN_MASK
	JR Z, .afterDirectionChange

	; We have direction change!
	LD A, (ind.jetDirection)					; Update #jetState by resetting Up/Hover and setting Down
	RES ind.MOVE_UP_BIT, A
	SET ind.MOVE_DOWN_BIT, A	
	LD (ind.jetDirection), A
	
	; ##########################################
	CALL js.ChangeJetSpriteOnFlyDown

.afterDirectionChange

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                 #JoyMoveDownRelease                      ;
;----------------------------------------------------------;
JoyMoveDownRelease

	CALL js.ChangeJetSpriteOnFlyUp
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                      #CanJetMove                         ;
;----------------------------------------------------------;
; Output:
;	A containing one of the values:
;     - _CF_RET_ON:		Process joystick input
;     - _CF_RET_OFF:	Disable joystick input processing for this loop
CanJetMove

	CALL JoyCntEnabled
	CP _CF_RET_OFF
	RET Z

	; ##########################################
	; Joystic disabled if Jetman is inactive
	LD A, (jt.jetState)
	CP jt.STATE_INACTIVE
	JR NZ, .jetActive

	; Do not process input
	LD A, _CF_RET_OFF
	RET
.jetActive	

	; ##########################################
	CALL JoySlowdown
	CP _CF_RET_OFF
	RET Z

	; ##########################################
	LD A, (jt.jetState)
	CP jt.JET_ST_RIP
	JR NZ, .afterRip							; Do not process input if Jetman is dying

	; Do not process input, Jet is dying
	LD A, _CF_RET_OFF
	RET
.afterRip

	; ##########################################
	; Process input

	LD A, _CF_RET_ON

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       #JoySlowdown                       ;
;----------------------------------------------------------;
; Slow down joystick input and, therefore, speed of Jetman movement
; Output:
;	A containing one of the values:
;     - _CF_RET_ON:		Process joystick input
;     - _CF_RET_OFF:	Disable joystick input processing for this loop
JoySlowdown
	LD A, (ind.joyDelayCnt)
	INC A
	LD (ind.joyDelayCnt), A

	CP _CF_PL_JOY_DELAY
	JR Z, .delayReached

	LD A, _CF_RET_OFF							; Return because #joyDelayCnt !=  #_CF_PL_JOY_DELAY
	RET
.delayReached									; Delay counter has been reached	

	XOR A										; Set A to 0						
	LD (ind.joyDelayCnt), A						; Reset delay counter

	LD A, _CF_RET_ON							; Process input, because counter has been reached

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                     #JoyCntEnabled                       ;
;----------------------------------------------------------;
; Disable joystick and, therefore, control over the Jetman 
; Output:
;	A containing one of the values:
;     - _CF_RET_ON:		Process joystick input
;     - _CF_RET_OFF:	Disable joystick input processing for this loop
JoyCntEnabled

	LD A, (ind.joyOffCnt)
	CP 0
	JR Z, .joyEnabled							; Jump if joystick is enabled -> #joyOffCnt > 0

	; ##########################################
	; Joystick is disabled
	DEC A										; Decrement disabled counter
	LD (ind.joyOffCnt), A

	; Joystick will enable on the next loop?
	CP 0
	JR NZ, .afterEnableCheck

	; Yes, this was the last blocking loop
	CALL gc.JoyWillEnable
.afterEnableCheck	

	; ##########################################
	; Allow input processing if Jetman is close to the platform and #joyOffCnt is > 0. It allows, for example, to move left/right when
	; hitting the platform from below and pressing up + left (or right). 
	; We can have the following situation: Jemtan is below the platform and is not bumping off anymore because it's close long enough.
	; The player still keeps pressing up and simultaneously, let's say, left. We want to allow movement to the left, but not up.
	; Because #joyOffCnt > 0, the function #GameLoop000OnDisabledJoy will be executed. It will move Jetman one pixel down, which is good
	; because pressing up has moved him one pixel up. To allow movement left, we ignore #joyOffBump because it is so small that we know
	; that Jetman is right below the platform. Keeping #joyOffCnt > 0 reverses Jaystick's movement up, ignoring #joyOffBump allows movement to the left.

	LD A, (pl.joyOffBump)
	CP _CF_PL_BUMP_JOY_OFF_DEC+1
	JR C, .joyEnabled

	LD A, _CF_RET_OFF
	RET											; Do not process input, as the joystick is disabled

.joyEnabled							; Process input
	LD A, _CF_RET_ON

	RET											; ## END of the function ##

;----------------------------------------------------------;
;               #JoystickInputProcessed                    ;
;----------------------------------------------------------;
; It gets executed as a last procedure after the input has been processed, regardless of whether there was movement, or not
JoystickInputProcessed

	CALL jm.CanJetMove
	CP _CF_RET_ON
	RET NZ										; Do not process input on disabled joystick

	; ##########################################
	; Ignore the situation when Jetman stands on the ground and only down is present. This does not count as movement
	LD A, (jt.jetGnd)
	CP jt.STATE_INACTIVE
	JR Z, .afterDownOnGround

	; Jetman is on the ground, but is only down key pressed (without left/right)?
	LD A, (ind.joyDirection)
	CP ind.MOVE_DOWN_MASK
	JR Z, .inactive								; Jump if, Jetman is on the ground and only down is pressed, we have inactivity, skip other checks

.afterDownOnGround
	
	; ##########################################
	; Is there a movement?
	LD A, (ind.joyDirection)
	CP ind.MOVE_INACTIVE
	RET NZ										; Jump if there is a movement

.inactive

	CALL gc.MovementInactivity

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE