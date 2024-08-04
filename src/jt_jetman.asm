;----------------------------------------------------------;
;              Jetman Movement, States and Logic           ;
;----------------------------------------------------------;
	MODULE jt

ENEMY_THICKNESS		= 10

shakeScreenCnt			BYTE 0
shakeScreenState		BYTE 0
SHAKE_SCREEN_DELAY		= 5

RIP_MOVE_LEFT			= 0
RIP_MOVE_RIGHT			= 1
ripMoveState			BYTE 0				; 1 - move right, 0 - move left

; Amount of steps to move in the current direction is given by #ripMoveState. This counter counts down to 0. When that happens, 
; the counter gets initialized from #ripMoveMul, and the direction changes (#ripMoveState)
ripMoveCnt				BYTE RIP_MOVE_MUL_INC

RIP_MOVE_MUL_INC		= 10
ripMoveMul				BYTE RIP_MOVE_MUL_INC

invincibleCnt			BYTE 0				; Makes Jetman invincible when > 0


rotateIdx				BYTE 0				; Rotation counter from 0 to 3

; Rotation (R) and mirror (XM,YM) bits: %0000'XM'YM'R'0
rotateDB				DB %0000'0'0'0'0/*up*/,%0000'0'0'1'0/*right*/,%0000'0'1'0'0/*down*/,%0000'1'0'1'0/*left*/
ROTATE_DB_SIZE			= 3					; Indicates reset for the #rotateIdx to 0

RIP_ANIMATE_DELAY		= 15
ripAnimateCnt			BYTE 0
;----------------------------------------------------------;
;                 #ChangeJetStateAir                       ;
;----------------------------------------------------------;
; Input:
;  - A:										; Air State: #AIR_XXX
ChangeJetStateAir
	
	LD (jd.jetAir), A

	LD A, jd.JET_STATE_AIR
	LD (jd.jetState), A

	LD A, jd.STATE_INACTIVE
	LD (jd.jetGnd), A

	RET

;----------------------------------------------------------;
;                 #ChangeJetStateGnd                       ;
;----------------------------------------------------------;
ChangeJetStateGnd
	LD A, jd.JET_STATE_GND
	LD (jd.jetState), A

	LD A, jd.STATE_INACTIVE
	LD (jd.jetAir), A

	LD A, jd.GND_WALK
	LD (jd.jetGnd), A

	RET	

;----------------------------------------------------------;
;                 #ChangeJetStateRip                       ;
;----------------------------------------------------------;
ChangeJetStateRip
	LD A, jd.STATE_INACTIVE
	LD (jd.jetAir), A
	LD (jd.jetGnd), A

	LD A, jd.JET_STATE_RIP
	LD (jd.jetState), A

	RET	

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
; Transition from standing/landing on ground to walking
StandToWalk
	LD A, (jd.jetState)
	CP jd.JET_STATE_GND
	RET NZ										; Exit if Jetman is not on the ground
	 
	; Jetman is on the ground, is he already walking?
	LD A, (jd.jetGnd)	
	CP jd.GND_WALK
	RET Z										; Exit if Jetman is already walking

	; Jetman is standing and starts walking now
	LD A, jd.GND_WALK
	LD (jd.jetGnd), A
	
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
	LD A, (jd.jetAir)
	CP jd.AIR_HOOVER							; Is Jemtman hovering?
	JR NZ, .afterHovering						; Jump if not hovering

	; Jetman is hovering, but we have movement, so switch state to fly
	LD A, jd.AIR_FLY
	LD (jd.jetAir), A
	
	LD A, js.SDB_FLY							; Switch to flaying animation
	CALL js.ChangeJetmanSpritePattern
.afterHovering	

	RET

;----------------------------------------------------------;
;                      #JoyMoveUp                          ;
;----------------------------------------------------------;
JoyMoveUp
	; Update #joyDirection state
	LD A, (jd.joyDirection)
	SET jd.MOVE_UP_BIT, A	
	LD (jd.joyDirection), A

	CALL JetmanMoves

	; Decrement Y position
	LD A, (jd.jetmanY)	
	CP sc.SCR_Y_MIN_POS 						; Do not decrement if Jetman has reached the top of the screen
	JR Z, .afterDec
	DEC A
	LD (jd.jetmanY), A
.afterDec	

	; Direction change: down -> up
	LD A, (jd.jetDirection)
	AND jd.MOVE_UP_MASK							; Are we moving Up already?
	CP jd.MOVE_UP_MASK
	JR Z, .afterDirectionChange

	; We have direction change!
	LD A, (jd.jetDirection)					; Update #jetState by resetting down and setting up
	RES jd.MOVE_DOWN_BIT, A
	SET jd.MOVE_UP_BIT, A
	LD (jd.jetDirection), A
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
	LD A, (jd.joyDirection)
	SET jd.MOVE_RIGHT_BIT, A	
	LD (jd.joyDirection), A

	CALL JetmanMoves						
	CALL StandToWalk
	CALL IncJetX

	; ##Direction change: left -> right##
	LD A, (jd.jetDirection)
	AND jd.MOVE_RIGHT_MASK						; Are we moving right already?
	CP jd.MOVE_RIGHT_MASK
	JR Z, .afterDirectionChange

	; We have direction change!		
	LD A, (jd.jetDirection)					; Reset left and set right
	RES jd.MOVE_LEFT_BIT, A
	SET jd.MOVE_RIGHT_BIT, A
	LD (jd.jetDirection), A
	
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

	CALL JetmanMoves	
	CALL StandToWalk					
	CALL DecJetX

	; Direction change: right -> left
	LD A, (jd.jetDirection)
	AND jd.MOVE_LEFT_MASK							; Are we moving left already?
	CP jd.MOVE_LEFT_MASK
	JR Z, .afterDirectionChange						; Jetman is moving left already -> end

	; We have direction change!		
	LD A, (jd.jetDirection)						; Reset right and set left
	RES jd.MOVE_RIGHT_BIT, A
	SET jd.MOVE_LEFT_BIT, A
	LD (jd.jetDirection), A
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
	LD A, (jd.jetState)
	CP jd.JET_STATE_GND
	RET Z	

	CALL JetmanMoves						

	; Increment Y position#
	LD A, (jd.jetmanY)
	CP jd.GROUND_LEVEL							; Do not increment if Jetman has reached the ground
	JR Z, .afterInc						

	; Move Jetman 1px down
	INC A
	LD (jd.jetmanY), A

	; Landing on the ground
	CP jd.GROUND_LEVEL
	CALL Z, jp.JetLanding					; Execute landing on the ground if Jetman has reached the ground
	CALL jp.LandingOnPlatform					; Or should he land on one of the platforms?

	; Direction change? 
	LD A, (jd.jetDirection)
	AND jd.MOVE_DOWN_MASK						; Are we moving down already?
	CP jd.MOVE_DOWN_MASK
	JR Z, .afterDirectionChange

	; We have direction change!	
	LD A, (jd.jetDirection)					; Update #jetState by resetting Up/Hover and setting Down
	RES jd.MOVE_UP_BIT, A
	SET jd.MOVE_DOWN_BIT, A	
	LD (jd.jetDirection), A
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
JoyEnd											; After input processing, #JoyEnd gets executed as the last procedure
	; #Jetman inactivity
	LD A, (jd.joyDirection)
	CP jd.MOVE_INACTIVE
	JR NZ, .afterInactivity						; Jump to the end if there is a movement

	LD A, (jd.jetmanInactivityCnt)				; Increment inactivity counter
	INC A
	LD (jd.jetmanInactivityCnt), A

	; Should Jetman hover?
	LD A, (jd.jetState)
	CP jd.JET_STATE_AIR							; Is Jemtan in the air already?
	JR NZ, .afterHoover							; Jump if not flaying

	LD A, (jd.jetAir)
	CP jd.AIR_HOOVER							; Jetman is in the air, but is he hovering already?
	JR Z, .afterHoover							; Jump if already hovering

	; Jetman is in the air, not hovering, but is he not moving long enough?
	LD A, (jd.jetmanInactivityCnt)
	CP jd.HOVER_START
	JR NZ, .afterHoover							; Jetman is not moving, by sill not long enough to start hovering

	; Jetamn starts to hover!
	LD A, jd.AIR_HOOVER
	LD (jd.jetAir), A

	LD A, js.SDB_HOVER
	CALL js.ChangeJetmanSpritePattern
	JR .afterInactivity							; Alerady hovering, do not check standing	
.afterHoover

	; Jetman is not hovering, but should he stand?
	LD A, (jd.jetState)
	CP jd.JET_STATE_GND							; Is Jemtan on the ground already?
	JR NZ, .afterInactivity						; Jump if not on the ground

	LD A, (jd.jetGnd)
	CP jd.GND_STAND								; Jetman is on the ground, but is he stainding already?
	JR Z, .afterInactivity						; Jump if already standing

	; Jetman is on the ground and does not move, but is he not moving long enough?
	LD A, (jd.jetmanInactivityCnt)
	CP jd.STAND_START
	JR NZ, .afterStand							; Jump if Jetman stands for too short to trigger standing
	
	; Transtion from walking to standing
	LD A, jd.GND_STAND
	LD (jd.jetGnd), A

	LD A, js.SDB_STAND							; Change animation
	CALL js.ChangeJetmanSpritePattern
	JR .afterInactivity
.afterStand

	; We are here because: jetmanInactivityCnt > 0 AND jetmanInactivityCnt < STAND_START 
	; Jetman stands still for a short time, not long enough, to play standing animation, but at least we should stop walking animation.	
	LD A, (jd.jetGnd)
	CP jd.GND_WALK
	JR NZ, .afterInactivity						; Jump is if not walking
	
	CP jd.GND_JSTAND
	JR Z, .afterInactivity						; Jump already j-standing (just standing - for a short time)

	LD A, (jd.jetmanInactivityCnt)
	CP jd.JSTAND_START
	JR NZ, .afterInactivity						; Jump if Jetman stands for too short to trigger j-standing

	LD A, jd.GND_JSTAND
	LD (jd.jetGnd), A

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

	CALL jp.AnimateOnJoystickDisabled
	RET

;----------------------------------------------------------;
;                #JetmanEnemiesColision                    ;
;----------------------------------------------------------;
JetmanEnemiesColision
	LD IX, de.sprite01
	LD A, (de.spritesSize)
	LD B, A
	CALL EnemiesColision
	RET	

;----------------------------------------------------------;
;                    #EnemiesColision                      ;
;----------------------------------------------------------;
; Checks all active enemies given by IX for collision with leaser beam
; Input
;  - IX:	Pointer to #MSS, the enemies
;  - B:		Number of enemies in IX
; Modifies: ALL
EnemiesColision
.loop
	PUSH BC										; Preserve B for loop counter

	BIT sr.MSS_ST_VISIBLE_BIT, (IX + sr.MSS.STATE)
	JR Z, .continue								; Jump if enemy is hidden

	; Sprite is visible
	CALL EnemyColision

.continue
	; Move HL to the beginning of the next #shotMssX
	LD DE, sr.MSS
	ADD IX, DE
	POP BC
	DJNZ .loop									; Jump if B > 0

	RET

;----------------------------------------------------------;
;                    #EnemyColision                        ;
;----------------------------------------------------------;
; Checks whether a given enemy has been hit by the laser beam and eventually destroys it
; Input:
;  - IX:	Pointer to concreate single enemy, single #MSS
; Modifies: ALL
EnemyColision

	; Compare X coordinate of enemy and Jetman
	LD BC, (IX + sr.MSS.X)						; X of the enemy
	LD DE, (jd.jetmanX)							; X of the Jetman

	LD A, D
	CP B
	RET NZ										; Jump if MSB of the X for enemy and Jetman does not match (B != D)

	; Check if the Jetman hits the enemy from the left side of its X coordinate
	LD A, C										; A holds the X LSB of the enemy
	SUB ENEMY_THICKNESS						; Include the thickness of the enemy
	CP E
	RET NC										; Jump if "(C - L) >= E" -> "(Xenemy - L) >= Xshot"  -> shot is before the enemy, left of it

	; Check if the Jetman hits the enemy from the right side of its X coordinate
	ADD ENEMY_THICKNESS						; Revert "SUB L" from above
	ADD ENEMY_THICKNESS						; Include the thickness of the enemy
	CP E
	RET C 										; Jump if "(C + L) < E" -> "(Xenemy + L) < Xshot"  -> shot is after the enemy, right of it

	; We are here because the shot is horizontal with the enemy, now check the vertical match
	LD A, (jd.jetmanY)							; B holds Y from the Jetman
	LD B, A
	LD A, (IX + sr.MSS.Y)						; A holds Y from the enemy
	
	; Check upper bounds
	SUB ENEMY_THICKNESS						; Include the thickness of the enemy
	CP B
	RET NC

	; Check lower bounds
	ADD ENEMY_THICKNESS						; Revert "SUB L" from above
	ADD ENEMY_THICKNESS						; Include the thickness of the enemy
	CP B
	RET C

	; We have colision!
	CALL sr.SetSpriteId							; Destroy the enemy
	CALL sr.SpriteHit

	; Is Jetman already dying? If so, do not start the sequence again, just kill the enemy
	LD A, (jd.jetState)							
	CP jd.JET_STATE_RIP
	RET Z										; Exit if RIP

	; This is the first enemy hit
	CALL jt.ChangeJetStateRip
	
	LD A, js.SDB_RIP							; Change animation
	CALL js.ChangeJetmanSpritePattern

	RET

;----------------------------------------------------------;
;                      #RespawnJet                         ;
;----------------------------------------------------------;
RespawnJet
	; Set respawn coordinates
	LD BC, 100
	LD (jd.jetmanX), BC

	LD A, 100
	LD (jd.jetmanY), A

	LD A, 0
	NEXTREG _DC_REG_TILE_X_LSB, A
	NEXTREG _DC_REG_TILE_Y, A

	LD A, jd.AIR_FLY
	CALL ChangeJetStateAir

	RET

;----------------------------------------------------------;
;                        #JetRip                           ;
;----------------------------------------------------------;
JetRip

	LD A, (jd.jetState)
	CP jd.JET_STATE_RIP
	RET NZ										; Exit if not RiP

	CALL ShakeScreen
	CALL RipMove
	CALL RipAnimate

	; Did Jetam reach the top of the screen (the RIP sequence is over)?	
	LD A, (jd.jetmanY)
	CP 0
	RET NZ										; Nope, still going

	; Sequece is over, respown new live
	CALL RespawnJet 
	CALL ResetRipMove
	
	RET

;----------------------------------------------------------;
;                   #JetInvincible                         ;
;----------------------------------------------------------;
; Input:
;  - A: value for invincible count
JetInvincible

	LD (invincibleCnt), A						; Exit if #invincibleCnt == 0
	CP 0
	RET Z

	DEC A
	LD (invincibleCnt), A						; Decrement counter and store

	CP 0										; Check whether this is the last iteration
	JP NZ, .afterReset
	
	; It is the last iteration - reset the sprite to its original state

	RET

.afterReset	
	RET
	
;----------------------------------------------------------;
;                   #ShakeScreen                           ;
;----------------------------------------------------------;
ShakeScreen
	LD A, (shakeScreenCnt)
	INC A
	LD (shakeScreenCnt), A
	CP SHAKE_SCREEN_DELAY
	RET C										; Return if #shakeScreenCnt <  #SHAKE_SCREEN_DELAY	

	LD A, 0
	LD (shakeScreenCnt), A

	; #shakeScreenState will change from 1 to 0, to keep shaking state
	LD A, (shakeScreenState)
	XOR 2
	LD (shakeScreenState), A

	NEXTREG _DC_REG_TILE_X_LSB, A
	NEXTREG _DC_REG_TILE_Y, A

	RET	
	
;----------------------------------------------------------;
;                    #ResetRipMove                         ;
;----------------------------------------------------------;	
ResetRipMove
	LD A, RIP_MOVE_MUL_INC
	LD (ripMoveMul), A
	LD (ripMoveCnt), A
	RET

;----------------------------------------------------------;
;                      #RipMove                            ;
;----------------------------------------------------------;	
; Jetman moves in zig-zac towards the upper side of the screen. 
RipMove
	; Move left or right
	LD A, (ripMoveState)
	CP RIP_MOVE_LEFT
	JR Z, .moveLeft

	; Move right
	CALL DecJetX
	JR .afterMove
.moveLeft
	; Move left
	CALL IncJetX
.afterMove

	; Y gets always decremented by 1 (going up)
	LD A, (jd.jetmanY)
	DEC A
	LD (jd.jetmanY), A

	; Decrement move counter
	LD A, (ripMoveCnt)
	DEC A
	LD (ripMoveCnt), A
	CP 0

	RET NZ										; Counter is still > 0 - keep going

	; Counter has reached 0 - change direction
	LD A, (ripMoveState)
	XOR 1
	LD (ripMoveState), A

	; Increment zig-zag distance (gets bigger with every direction change)
	LD A, (ripMoveMul)
	ADD RIP_MOVE_MUL_INC
	LD (ripMoveMul), A

	; Counter (how far we go left/right in zig-zag) increments with every turn, and ripMoveMul holds the increasing value
	LD (ripMoveCnt), A
	
	RET

;----------------------------------------------------------;
;                      #RipAnimate                         ;
;----------------------------------------------------------;
RipAnimate

	; Set rotation/mirror on _SPR_REG_ATR2_H37 on each game loop
	LD BC, rotateDB								; BC holds pointer value (not the entry value!) to #rotateDB 
	LD A, (rotateIdx)
	ADD BC, A									; Move pointer to #rotateDB to the righs postion
	LD A, (BC)									; Prepare A to be set on _SPR_REG_NR_H34 by loading value from db pointer
	CALL js.UpdateJetSpritePositionRotationPar

	; Change rotation every few game loops
	LD A, (ripAnimateCnt)
	INC A
	LD (ripAnimateCnt), A
	CP RIP_ANIMATE_DELAY
	RET NZ										; Return if the delay has not been reached

	LD A, 0										; #ripAnimateCnt has reached #RIP_ANIMATE_DELAY -> reset to 0
	LD (ripAnimateCnt), A	

	; Next rotation
	LD A, (rotateIdx)
	INC A
	LD (rotateIdx), A
	CP ROTATE_DB_SIZE + 1
	RET NZ										; Return if #rotateIdx != #ROTATE_MAX

	LD A, 0										; #rotateIdx has reached #ROTATE_MAX -> reset to 0
	LD (rotateIdx), A	

	RET
;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE