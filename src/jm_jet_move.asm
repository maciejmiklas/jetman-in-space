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
	LD (jt.jetAir), A
	
	; Switch to flaying animation
	LD A, js.SDB_FLY
	CALL js.ChangeJetSpritePattern
.afterHovering	

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                      #JoyMoveUp                          ;
;----------------------------------------------------------;
JoyMoveUp

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

	; Cannot move down when walking
	LD A, (jt.jetState)
	BIT jt.JET_STATE_GND_BIT, A
	RET NZ	

	; ##########################################
	CALL JoystickMoves

	; ##########################################
	; Increment Y position
	LD A, (jpo.jetY)
	CP _CF_GSC_GROUND							; Do not increment if Jetman has reached the ground
	JR Z, .afterInc						

	CALL jpo.IncJetY							; Move Jetman 1px down
.afterInc	

	; ##########################################
	; Landing on the ground
	CP _CF_GSC_GROUND
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
;                      #JoyMoveEnd                         ;
;----------------------------------------------------------;
; After input processing, #JoyEnd gets executed as the last procedure
JoyMoveEnd
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
	JR NZ, .afterInactivity						; Jump if there is a movement

.inactive
	
	; ##########################################
	; Increment inactivity counter
	LD A, (jetInactivityCnt)
	INC A
	LD (jetInactivityCnt), A	

	; ##########################################
	; Should Jetman hover?
	LD A, (jt.jetState)
	bit jt.JET_STATE_AIR_BIT, A					; Is Jemtan in the air already?
	JR Z, .afterHoover							; Jump if not flaying

	LD A, (jt.jetAir)
	CP jt.AIR_HOOVER							; Jetman is in the air, but is he hovering already?
	JR Z, .afterHoover							; Jump if already hovering

	; Jetman is in the air, not hovering, but is he not moving long enough?
	LD A, (jetInactivityCnt)
	CP _CF_HOVER_START
	JR NZ, .afterHoover							; Jetman is not moving, by sill not long enough to start hovering

	; Jetamn starts to hover!
	LD A, jt.AIR_HOOVER
	LD (jt.jetAir), A

	LD A, js.SDB_HOVER
	CALL js.ChangeJetSpritePattern
	JR .afterInactivity							; Alerady hovering, do not check standing	
.afterHoover

	; ##########################################
	; Jetman is not hovering, but should he stand?
	LD A, (jt.jetState)
	BIT jt.JET_STATE_GND_BIT, A					; Is Jemtan on the ground already?
	JR Z, .afterInactivity						; Jump if not on the ground

	LD A, (jt.jetGnd)
	CP jt.GND_STAND								; Jetman is on the ground, but is he stainding already?
	JR Z, .afterInactivity						; Jump if already standing

	; ##########################################
	; Jetman is on the ground and does not move, but is he not moving long enough?
	LD A, (jetInactivityCnt)
	CP _CF_STAND_START
	JR NZ, .afterStand							; Jump if Jetman stands for too short to trigger standing
	
	; Transtion from walking to standing
	LD A, jt.GND_STAND
	LD (jt.jetGnd), A

	LD A, js.SDB_STAND							; Change animation
	CALL js.ChangeJetSpritePattern
	JR .afterInactivity
.afterStand

	; We are here because: jetInactivityCnt > 0 and jetInactivityCnt < _CF_STAND_START 
	; Jetman stands still for a short time, not long enough, to play standing animation, but at least we should stop walking animation.	
	LD A, (jt.jetGnd)
	CP jt.GND_WALK
	JR NZ, .afterInactivity						; Jump is if not walking
	
	CP jt.GND_JSTAND
	JR Z, .afterInactivity						; Jump already j-standing (just standing - for a short time)

	LD A, (jetInactivityCnt)
	CP _CF_JSTAND_START
	JR NZ, .afterInactivity						; Jump if Jetman stands for too short to trigger j-standing

	LD A, jt.GND_JSTAND
	LD (jt.jetGnd), A

	LD A, js.SDB_JSTAND							; Change animation
	CALL js.ChangeJetSpritePattern

.afterInactivity

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE