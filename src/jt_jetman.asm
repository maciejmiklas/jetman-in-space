;----------------------------------------------------------;
;              Jetman Movement, States and Logic           ;
;----------------------------------------------------------;
	MODULE jt

;----------------------------------------------------------;
;                          #IncJetX                        ;
;----------------------------------------------------------;
; Increment X position
IncJetX
	LD BC, (jd.jetmanX)	
	INC BC

	; If X >= 315 then set it to 0. X is 9-bit value. 
	; 315 = 256 + 59 = %00000001 + %00111011 -> MSB: 1, LSB: 59
	LD A, B										; Load MSB from X into A
	CP 1										; 9-th bit set means X > 256
	JR NZ, .lessThanMaxX
	LD A, C										; Load MSB from X into A
	CP 59										; MSB > 59 
	JR C, .lessThanMaxX
	LD BC, 1									; Jetman is above 315 -> set to 1
.lessThanMaxX
	LD (jd.jetmanX), BC							; Update new X position

	RET

;----------------------------------------------------------;
;                        #DecJetX                          ;
;----------------------------------------------------------;
; Decrement X position
DecJetX
	LD BC, (jd.jetmanX)	
	DEC BC

	; If X == 0 (SCR_X_MIN_POS) then set it to 315. X == 0 when B and C are 0
	LD A, B
	CP sc.SCR_X_MIN_POS							; If B > 0 then X is also > 0
	JR NZ, .afterResetX
	LD A, C
	CP sc.SCR_X_MIN_POS							; If C > 0 then X is also > 0
	JR NZ, .afterResetX
	LD BC, sc.SCR_X_MAX_POS						; X == 0 (both A and B are 0) -> set X to 315
.afterResetX
	LD (jd.jetmanX), BC
	RET

;----------------------------------------------------------;
;                       #StandToWalk                       ; 
;----------------------------------------------------------;
; Transition from standing on ground to walking
StandToWalk
	LD A, (jd.jetmanGnd)
	CP jd.GND_INACTIVE
	RET Z										; Exit if Jetman is not on the ground
	 
	; Jetman is on the ground, is he already walking?
	CP jd.GND_WALK
	RET Z										; Exit if Jetman is already walking

	; Jetman is standing and starts walking now
	LD A, jd.GND_WALK
	LD (jd.jetmanGnd), A

	LD A, js.SDB_WALK_ST
	CALL js.ChangeJetmanSpritePattern	
	RET

;----------------------------------------------------------;
;                       #JetmanMoves                       ;
;----------------------------------------------------------;
; Method gets called on any movement, but not fire pressed
JetmanMoves

	; Reset inactivity counter as we have movement
	LD A, 0
	LD (jd.jetmanInactivityCnt), A

	; Transition from hovering to flying?
	LD A, (jd.jetmanAir)
	CP jd.AIR_HOOVER							; Is Jemtman hovering?			
	JR NZ, .afterHovering						; Jump if not hovering

	; Jetman is hovering, but we have movement, so switch state to fly
	LD A, jd.AIR_FLY
	LD (jd.jetmanAir), A
	
	LD A, js.SDB_FLY							; Switch to flaying animation
	CALL js.ChangeJetmanSpritePattern
.afterHovering	

	RET

;----------------------------------------------------------;
;                       #JoySlowdown                       ;
;----------------------------------------------------------;
; Slow down/disable joystick input and, therefore, speed of Jetman movement
; Input:
; Output:
;	A containing one of the values given by #JOY_SLOWDOWN_RET_XXX
JoySlowdown
	LD A, (jd.joyDelayCnt)
	INC A
	LD (jd.joyDelayCnt), A

	CP jd.JOY_DELAY
	JR NC, .afterDelay
	LD A, in.JOY_SLOWDOWN_RET_BREAK				; Return because #joyDelayCnt <  #JOY_DELAY
	RET
.afterDelay	
	LD A, 0										; Reset delay counter
	LD (jd.joyDelayCnt), A

	; Handle disabled joystick
	LD A, (jd.joyDisabledCnt)
	CP 0
	JR Z, .afterjoystickDisabled				; Jump if joystick is enabled -> #joyDisabledCnt > 0

	; Joystick is disabled
	DEC A										; Decrement disabled counter
	LD (jd.joyDisabledCnt), A
	LD A, in.JOY_SLOWDOWN_RET_BREAK
	RET											; Do not process input, as the joystick is disabled

.afterjoystickDisabled							; Process input
	LD A, in.JOY_SLOWDOWN_RET_CONT
	RET

;----------------------------------------------------------;
;                      #JoyMoveUp                          ;
;----------------------------------------------------------;
JoyMoveUp
	; Update #joyDirection state
	LD A, (jd.joyDirection)
	SET jd.MOVE_UP_BIT, A	
	LD (jd.joyDirection), A

	CALL jt.JetmanMoves							

	; Decrement Y position
	LD A, (jd.jetmanY)	
	CP sc.SCR_Y_MIN_POS 						; Do not decrement if Jetman has reached the top of the screen.
	JR Z, .afterDec
	DEC A
	LD (jd.jetmanY), A
.afterDec	

	; Direction change: down -> up
	LD A, (jd.jetmanDirection)
	AND jd.MOVE_UP_MASK							; Are we moving Up already?
	CP jd.MOVE_UP_MASK
	JR Z, .afterDirectionChange

	; We have direction change!
	LD A, (jd.jetmanDirection)					; Update #jetState by resetting down and setting up
	RES jd.MOVE_DOWN_BIT, A
	SET jd.MOVE_UP_BIT, A
	LD (jd.jetmanDirection), A
.afterDirectionChange

	; Transition from walking to flaying
	CALL jp.JetmanTakesoff

	; Bumping from below into the platform?
	CALL jp.BumpIntoPlatFormBelow
	RET											; END #JoyMoveUp	

;----------------------------------------------------------;
;                     #JoyMoveRight                        ;
;----------------------------------------------------------;
JoyMoveRight
	; Update temp state
	LD A, (jd.joyDirection)
	SET jd.MOVE_RIGHT_BIT, A	
	LD (jd.joyDirection), A

	CALL jt.JetmanMoves						
	CALL jt.StandToWalk
	CALL jt.IncJetX

	; ##Direction change: left -> right##
	LD A, (jd.jetmanDirection)
	AND jd.MOVE_RIGHT_MASK						; Are we moving right already?
	CP jd.MOVE_RIGHT_MASK
	JR Z, .afterDirectionChange

	; We have direction change!		
	LD A, (jd.jetmanDirection)					; Reset left and set right						
	RES jd.MOVE_LEFT_BIT, A
	SET jd.MOVE_RIGHT_BIT, A
	LD (jd.jetmanDirection), A
	
.afterDirectionChange

	; Bupm from the left side of the platform?
	LD H, jd.AIR_BUMP_LEFT
	CALL jp.BumpIntoPlatformLR

	CALL jp.FallingFromPlatform
	RET											; END #JoyMoveRight

;----------------------------------------------------------;
;                      #JoyMoveLeft                        ;
;----------------------------------------------------------;
JoyMoveLeft
	; Update #joyDirection state
	LD A, (jd.joyDirection)
	SET jd.MOVE_LEFT_BIT, A	
	LD (jd.joyDirection), A

	CALL jt.JetmanMoves	
	CALL jt.StandToWalk					
	CALL jt.DecJetX

	; Direction change: right -> left
	LD A, (jd.jetmanDirection)
	AND jd.MOVE_LEFT_MASK							; Are we moving left already?
	CP jd.MOVE_LEFT_MASK
	JR Z, .afterDirectionChange					; Jetman is moving left already -> end

	; We have direction change!		
	LD A, (jd.jetmanDirection)						; Reset right and set left 					
	RES jd.MOVE_RIGHT_BIT, A
	SET jd.MOVE_LEFT_BIT, A
	LD (jd.jetmanDirection), A
.afterDirectionChange

	; Bupm from the right side of the platform?
	LD H, jd.AIR_BUMP_RIGHT
	CALL jp.BumpIntoPlatformLR
	CALL jp.FallingFromPlatform
	RET											; END #JoyMoveLeft

;----------------------------------------------------------;
;                    #JoyPressFire                         ;
;----------------------------------------------------------;
JoyPressFire
	CALL jw.Fire
	RET											; END #JoyPressFire

;----------------------------------------------------------;
;                      #JoyMoveDown                        ;
;----------------------------------------------------------;
JoyMoveDown
	; Update #joyDirection state
	LD A, (jd.joyDirection)
	SET jd.MOVE_DOWN_BIT, A	
	LD (jd.joyDirection), A

	; Cannot move down when walking
	LD A, (jd.jetmanGnd)
	CP jd.GND_INACTIVE
	RET NZ	

	CALL jt.JetmanMoves						

	; Increment Y position#
	LD A, (jd.jetmanY)
	CP jd.GROUND_LEVEL							; Do not increment if Jetman has reached the ground
	JR Z, .afterInc						

	; Move Jetman 1px down
	INC A
	LD (jd.jetmanY), A

	; Landing on the ground
	CP jd.GROUND_LEVEL
	CALL Z, jp.JetmanLanding					; Execute landing on the ground if Jetman has reached the ground.
	CALL jp.LandingOnPlatform					; Or should he land on one of the platforms?

	; Direction change? 
	LD A, (jd.jetmanDirection)
	AND jd.MOVE_DOWN_MASK						; Are we moving down already?
	CP jd.MOVE_DOWN_MASK
	JR Z, .afterDirectionChange

	; We have direction change!	
	LD A, (jd.jetmanDirection)					; Update #jetState by resetting Up/Hover and setting Down
	RES jd.MOVE_UP_BIT, A
	SET jd.MOVE_DOWN_BIT, A	
	LD (jd.jetmanDirection), A
.afterDirectionChange
.afterInc	

	RET

;----------------------------------------------------------;
;                        #JoyStart                         ;
;----------------------------------------------------------;
JoyStart
	LD A, jd.MOVE_INACTIVE						; Update #jetState by resetting left/hover and setting right
	LD (jd.joyDirection), A

	RET

;----------------------------------------------------------;
;                         #JoyEnd                          ;
;----------------------------------------------------------;
JoyEnd											; After input processing, #JoyEnd gets executed as the last procedure. 

	; #Jetman inactivity#
	LD A, (jd.joyDirection)
	CP jd.MOVE_INACTIVE
	JR NZ, .afterInactivity						; Jump to the end if there is a movement

	LD A, (jd.jetmanInactivityCnt)				; Increment inactivity counter
	INC A
	LD (jd.jetmanInactivityCnt), A

	; Should Jetman hover?
	LD A, (jd.jetmanAir)
	CP jd.AIR_INACTIVE							; Is Jemtan in the air already?
	JR Z, .afterHoover							; Jump if not flaying

	CP jd.AIR_HOOVER							; Jetman is in the air, but is he hovering already?
	JR Z, .afterHoover							; Jump if already hovering

	; Jetman is in the air, not hovering, but is he not moving long enough?
	LD A, (jd.jetmanInactivityCnt)
	CP jd.HOVER_START
	JR NZ, .afterHoover							; Jetman is not moving, by sill not long enough to start hovering

	; Jetamn starts to hover!
	LD A, jd.AIR_HOOVER
	LD (jd.jetmanAir), A

	LD A, js.SDB_HOVER
	CALL js.ChangeJetmanSpritePattern
	JR .afterInactivity							; Alerady hovering, do not check standing	
.afterHoover

	; Jetman is not hovering, but should he stand?
	LD A, (jd.jetmanGnd)
	CP jd.AIR_INACTIVE							; Is Jemtan on the ground already?
	JR Z, .afterInactivity						; Jump if not on the ground

	CP jd.GND_STAND								; Jetman is on the ground, but is he stainding already?
	JR Z, .afterInactivity						; Jump if already standing

	; Jetman is on the ground and does not move, but is he not moving long enough?
	LD A, (jd.jetmanInactivityCnt)
	CP jd.STAND_START
	JR NZ, .afterStand							; Jump if Jetman stands for too short to trigger standing

	; Transtion from walking to standing
	LD A, jd.GND_STAND
	LD (jd.jetmanGnd), A

	LD A, js.SDB_STAND							; Change animation
	CALL js.ChangeJetmanSpritePattern
	JR .afterInactivity
.afterStand
	
	; Code is here because: jetmanInactivityCnt > 0 AND jetmanInactivityCnt < STAND_START 
	; Jetman stands still for a short time, not long enough, to play standing animation, but at least we should stop walking animation.	
	LD A, (jd.jetmanGnd)
	CP jd.GND_WALK
	JR NZ, .afterInactivity						; Jump is if not walking
	
	CP jd.GND_JSTAND
	JR Z, .afterInactivity						; Jump already j-standing (just standing - for a short time)

	LD A, (jd.jetmanInactivityCnt)
	CP jd.JSTAND_START
	JR NZ, .afterInactivity						; Jump if Jetman stands for too short to trigger j-standing

	LD A, jd.GND_JSTAND
	LD (jd.jetmanGnd), A

	LD A, js.SDB_JSTAND							; Change animation
	CALL js.ChangeJetmanSpritePattern

.afterInactivity

	RET

;----------------------------------------------------------;
;                      #JoyDisabled                        ;
;----------------------------------------------------------;
JoyDisabled
	; Handle disabled joystick
	LD A, (jd.joyDisabledCnt)
	CP 0
	RET Z										; Jump if joystick is enabled -> #joyDisabledCnt == 0

	CALL jp.BumpOnJoystickDisabled

	; Reset the #jetmanAir on the last frame of the disabled joystick
	LD A, (jd.jetmanAir)
	CP 1
	RET NZ										; Jump if it's not the last frame (!=1)
	LD A, jd.AIR_FLY
	LD (jd.jetmanAir), A

	RET

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE	