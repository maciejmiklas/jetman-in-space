;----------------------------------------------------------;
;                       Jetman Logic                       ;
;----------------------------------------------------------;
	MODULE jt

; Hovering/Standing
jetmanInactivityCnt		BYTE 0					; The counter increases with each frame when no up/down is pressed. 
												; When it reaches #HOVER_START, Jetman will start hovering
HOVER_START				= 40
STAND_START				= 30
JSTAND_START			= 5

GROUND_LEVEL			= 230					; The lowest walking platform

ENEMY_THICKNESS			= 10
SHAKE_SCREEN_BY			= 5					; Number of pixels to move the screen by shaking

RIP_MOVE_LEFT			= 0
RIP_MOVE_RIGHT			= 1
ripMoveState			BYTE 0				; 1 - move right, 0 - move left

; Amount of steps to move in a direction is given by #ripMoveState. This counter counts down to 0. When that happens, 
; the counter gets initialized from #ripMoveMul, and the direction changes (#ripMoveState)
ripMoveCnt				BYTE RIP_MOVE_MUL_INC

RIP_MOVE_MUL_INC		= 10
ripMoveMul				BYTE RIP_MOVE_MUL_INC

invincibleCnt			BYTE 0				; Makes Jetman invincible when > 0

RESPOWN_INVINCIBLE_CNT = 250				; Number of loops to keep Jetman invincible	

;----------------------------------------------------------;
;                       #StandToWalk                       ; 
;----------------------------------------------------------;
; Transition from standing/landing on ground to walking
StandToWalk
	LD A, (js.jetState)
	BIT js.JET_STATE_GND_BIT, A
	RET Z										; Exit if Jetman is not on the ground
	 
	; Jetman is on the ground, is he already walking?
	LD A, (js.jetGnd)	
	CP js.GND_WALK
	RET Z										; Exit if Jetman is already walking

	; Jetman is standing and starts walking now
	LD A, js.GND_WALK
	LD (js.jetGnd), A
	
	LD A, js.SDB_WALK_ST
	CALL js.ChangeJetSpritePattern	
	RET

;----------------------------------------------------------;
;                       #JetmanMoves                       ;
;----------------------------------------------------------;
; Method gets called on any movement, but not fire pressed
JetmanMoves

	; Reset inactivity counter as we have movement
	LD A, 0
	LD (jetmanInactivityCnt), A

	; Transition from hovering to flying?
	LD A, (js.jetAir)
	CP js.AIR_HOOVER							; Is Jemtman hovering?
	JR NZ, .afterHovering						; Jump if not hovering

	; Jetman is hovering, but we have movement, so switch state to fly
	LD A, js.AIR_FLY
	LD (js.jetAir), A
	
	LD A, js.SDB_FLY							; Switch to flaying animation
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

	CALL JetmanMoves

	; Decrement Y position
	LD A, (jp.jetmanY)	
	CP sc.SCR_Y_MIN_POS 						; Do not decrement if Jetman has reached the top of the screen
	JR Z, .afterDec
	DEC A
	LD (jp.jetmanY), A
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

	CALL JetmanMoves						
	CALL StandToWalk
	CALL jp.IncJetX

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
	LD H, js.AIR_BUMP_LEFT
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

	CALL JetmanMoves	
	CALL StandToWalk					
	CALL jp.DecJetX

	; Direction change: right -> left
	LD A, (id.jetDirection)
	AND id.MOVE_LEFT_MASK							; Are we moving left already?
	CP id.MOVE_LEFT_MASK
	JR Z, .afterDirectionChange						; Jetman is moving left already -> end

	; We have direction change!		
	LD A, (id.jetDirection)							; Reset right and set left
	RES id.MOVE_RIGHT_BIT, A
	SET id.MOVE_LEFT_BIT, A
	LD (id.jetDirection), A
.afterDirectionChange

	; Bupm from the right side of the platform?
	LD H, js.AIR_BUMP_RIGHT
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
	LD A, (id.joyDirection)
	SET id.MOVE_DOWN_BIT, A	
	LD (id.joyDirection), A

	; Cannot move down when walking
	LD A, (js.jetState)
	BIT js.JET_STATE_GND_BIT, A
	RET NZ	

	CALL JetmanMoves						

	; Increment Y position#
	LD A, (jp.jetmanY)
	CP GROUND_LEVEL							; Do not increment if Jetman has reached the ground
	JR Z, .afterInc						

	; Move Jetman 1px down
	INC A
	LD (jp.jetmanY), A

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
.afterInc	

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

	LD A, (jetmanInactivityCnt)				; Increment inactivity counter
	INC A
	LD (jetmanInactivityCnt), A

	; Should Jetman hover?
	LD A, (js.jetState)
	BIT js.JET_STATE_AIR_BIT, A					; Is Jemtan in the air already?
	JR Z, .afterHoover							; Jump if not flaying

	LD A, (js.jetAir)
	CP js.AIR_HOOVER							; Jetman is in the air, but is he hovering already?
	JR Z, .afterHoover							; Jump if already hovering

	; Jetman is in the air, not hovering, but is he not moving long enough?
	LD A, (jetmanInactivityCnt)
	CP HOVER_START
	JR NZ, .afterHoover							; Jetman is not moving, by sill not long enough to start hovering

	; Jetamn starts to hover!
	LD A, js.AIR_HOOVER
	LD (js.jetAir), A

	LD A, js.SDB_HOVER
	CALL js.ChangeJetSpritePattern
	JR .afterInactivity							; Alerady hovering, do not check standing	
.afterHoover

	; Jetman is not hovering, but should he stand?
	LD A, (js.jetState)
	BIT js.JET_STATE_GND_BIT, A					; Is Jemtan on the ground already?
	JR Z, .afterInactivity						; Jump if not on the ground

	LD A, (js.jetGnd)
	CP js.GND_STAND								; Jetman is on the ground, but is he stainding already?
	JR Z, .afterInactivity						; Jump if already standing

	; Jetman is on the ground and does not move, but is he not moving long enough?
	LD A, (jetmanInactivityCnt)
	CP STAND_START
	JR NZ, .afterStand							; Jump if Jetman stands for too short to trigger standing
	
	; Transtion from walking to standing
	LD A, js.GND_STAND
	LD (js.jetGnd), A

	LD A, js.SDB_STAND							; Change animation
	CALL js.ChangeJetSpritePattern
	JR .afterInactivity
.afterStand

	; We are here because: jetmanInactivityCnt > 0 AND jetmanInactivityCnt < STAND_START 
	; Jetman stands still for a short time, not long enough, to play standing animation, but at least we should stop walking animation.	
	LD A, (js.jetGnd)
	CP js.GND_WALK
	JR NZ, .afterInactivity						; Jump is if not walking
	
	CP js.GND_JSTAND
	JR Z, .afterInactivity						; Jump already j-standing (just standing - for a short time)

	LD A, (jetmanInactivityCnt)
	CP JSTAND_START
	JR NZ, .afterInactivity						; Jump if Jetman stands for too short to trigger j-standing

	LD A, js.GND_JSTAND
	LD (js.jetGnd), A

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
	LD DE, (jp.jetmanX)							; X of the Jetman

	LD A, D
	CP B
	RET NZ										; Jump if MSB of the X for enemy and Jetman does not match (B != D)

	; Check if the Jetman hits the enemy from the left side of its X coordinate
	LD A, C										; A holds the X LSB of the enemy
	SUB ENEMY_THICKNESS							; Include the thickness of the enemy
	CP E
	RET NC										; Jump if "(C - L) >= E" -> "(Xenemy - L) >= Xshot"  -> shot is before the enemy, left of it

	; Check if the Jetman hits the enemy from the right side of its X coordinate
	ADD ENEMY_THICKNESS							; Revert "SUB L" from above
	ADD ENEMY_THICKNESS							; Include the thickness of the enemy
	CP E
	RET C 										; Jump if "(C + L) < E" -> "(Xenemy + L) < Xshot"  -> shot is after the enemy, right of it

	; We are here because the shot is horizontal with the enemy, now check the vertical match
	LD A, (jp.jetmanY)							; B holds Y from the Jetman
	LD B, A
	LD A, (IX + sr.MSS.Y)						; A holds Y from the enemy
	
	; Check upper bounds
	SUB ENEMY_THICKNESS							; Include the thickness of the enemy
	CP B
	RET NC

	; Check lower bounds
	ADD ENEMY_THICKNESS							; Revert "SUB L" from above
	ADD ENEMY_THICKNESS							; Include the thickness of the enemy
	CP B
	RET C

	; We have colision!
	CALL sr.SetSpriteId							; Destroy the enemy
	CALL sr.SpriteHit

	; Is Jetman already dying? If so, do not start the RiP sequence again, just kill the enemy
	LD A, (js.jetState)							
	BIT js.JET_STATE_RIP_BIT, A
	RET NZ										; Exit if RIP

	; Is Jetman invincible? If so, just kill the enemy
	BIT js.JET_STATE_INV_BIT, A
	RET NZ										; Exit if invincible

	; This is the first enemy hit
	CALL js.ChangeJetStateRip
	
	LD A, js.SDB_RIP							; Change animation
	CALL js.ChangeJetSpritePattern

	RET

;----------------------------------------------------------;
;                      #RespawnJet                         ;
;----------------------------------------------------------;
RespawnJet
	; Set respawn coordinates
	LD BC, 100
	LD (jp.jetmanX), BC

	LD A, 100
	LD (jp.jetmanY), A

	LD A, 0
	NEXTREG _DC_REG_TILE_X_LSB, A
	NEXTREG _DC_REG_TILE_Y, A

	CALL js.ChangeJetStateRespown

	LD A, RESPOWN_INVINCIBLE_CNT
	CALL MakeJetInvincible

	RET

;----------------------------------------------------------;
;                        #JetRip                           ;
;----------------------------------------------------------;
JetRip
	LD A, (js.jetState)
	BIT js.JET_STATE_RIP_BIT, A
	RET Z										; Exit if not RiP

	CALL ShakeScreen
	CALL RipMove

	; Did Jetam reach the top of the screen (the RIP sequence is over)?	
	LD A, (jp.jetmanY)
	CP 4										; Going up is incremented by 2
	RET NC										; Nope, still going up (#jetmanY >= 4)

	; Sequece is over, respown new live
	CALL RespawnJet 
	CALL ResetRipMove
	RET

;----------------------------------------------------------;
;                   #MakeJetInvincible                     ;
;----------------------------------------------------------;
; Input
;  - A:		Number of loops (#counter2) to keep Jemtan invincible
MakeJetInvincible
	LD (invincibleCnt), A					; Store invincibility duration
	
	; Update state
	LD A, (js.jetState)
	SET js.JET_STATE_INV_BIT, A
	LD (js.jetState), A

	RET

;----------------------------------------------------------;
;                   #JetInvincible                         ;
;----------------------------------------------------------;
JetInvincible
	LD A, (invincibleCnt)						; Exit if #invincibleCnt == 0
	CP 0
	RET Z

	DEC A
	LD (invincibleCnt), A						; Decrement counter and store it
	CP 0											; Check whether this is the last iteration (#invincibleCnt changes from 1 to 0)
	JR Z, .lastIteration

	; Still invincible - blink Jetman sprite
	CALL js.BlinkJetSprite
	RET
.lastIteration	
	; It is the last iteration, remove invincibility

	LD A, (js.jetState)
	RES js.JET_STATE_INV_BIT, A
	LD (js.jetState), A

	CALL js.ShowJetSprite
	RET

;----------------------------------------------------------;
;                   #ShakeScreen                           ;
;----------------------------------------------------------;
ShakeScreen
	LD A, (dc.counter5)
	CP 0
	RET NZ										; Return if counter to 5 did not reset	

	LD A, (dc.counter5FliFLop)					; Oscilates beetwen 1 and 0
	LD D, A
	LD E, SHAKE_SCREEN_BY
	MUL D, E
	LD A, E
	NEXTREG _DC_REG_TILE_X_LSB, A

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
	CALL jp.DecJetX
	CALL jp.DecJetX
	JR .afterMove
.moveLeft
	; Move left
	CALL jp.IncJetX
	CALL jp.IncJetX
.afterMove

	; going up
	LD A, (jp.jetmanY)
	ADD A, -2
	LD (jp.jetmanY), A

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
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE