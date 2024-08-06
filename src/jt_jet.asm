;----------------------------------------------------------;
;                       Jetman Logic                       ;
;----------------------------------------------------------;
	MODULE jt


;----------------------------------------------------------;
;                       #StandToWalk                       ; 
;----------------------------------------------------------;
; Transition from standing/landing on ground to walking
StandToWalk
	LD A, (jd.jetState)
	BIT jd.JET_STATE_GND_BIT, A
	RET Z										; Exit if Jetman is not on the ground
	 
	; Jetman is on the ground, is he already walking?
	LD A, (jd.jetGnd)	
	CP jd.GND_WALK
	RET Z										; Exit if Jetman is already walking

	; Jetman is standing and starts walking now
	LD A, jd.GND_WALK
	LD (jd.jetGnd), A
	
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
	LD (jd.jetmanInactivityCnt), A

	; Transition from hovering to flying?
	LD A, (jd.jetAir)
	CP jd.AIR_HOOVER							; Is Jemtman hovering?
	JR NZ, .afterHovering						; Jump if not hovering

	; Jetman is hovering, but we have movement, so switch state to fly
	LD A, jd.AIR_FLY
	LD (jd.jetAir), A
	
	LD A, js.SDB_FLY							; Switch to flaying animation
	CALL js.ChangeJetSpritePattern
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
	LD A, (jd.jetDirection)						; Update #jetState by resetting down and setting up
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
	CALL jp.IncJetX

	; ##Direction change: left -> right##
	LD A, (jd.jetDirection)
	AND jd.MOVE_RIGHT_MASK						; Are we moving right already?
	CP jd.MOVE_RIGHT_MASK
	JR Z, .afterDirectionChange

	; We have direction change!		
	LD A, (jd.jetDirection)						; Reset left and set right
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
	CALL jp.DecJetX

	; Direction change: right -> left
	LD A, (jd.jetDirection)
	AND jd.MOVE_LEFT_MASK							; Are we moving left already?
	CP jd.MOVE_LEFT_MASK
	JR Z, .afterDirectionChange						; Jetman is moving left already -> end

	; We have direction change!		
	LD A, (jd.jetDirection)							; Reset right and set left
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
	BIT jd.JET_STATE_GND_BIT, A
	RET NZ	

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
	CALL Z, jp.JetLanding						; Execute landing on the ground if Jetman has reached the ground
	CALL jp.LandingOnPlatform					; Or should he land on one of the platforms?

	; Direction change? 
	LD A, (jd.jetDirection)
	AND jd.MOVE_DOWN_MASK						; Are we moving down already?
	CP jd.MOVE_DOWN_MASK
	JR Z, .afterDirectionChange

	; We have direction change!	
	LD A, (jd.jetDirection)						; Update #jetState by resetting Up/Hover and setting Down
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
	BIT jd.JET_STATE_AIR_BIT, A					; Is Jemtan in the air already?
	JR Z, .afterHoover							; Jump if not flaying

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
	CALL js.ChangeJetSpritePattern
	JR .afterInactivity							; Alerady hovering, do not check standing	
.afterHoover

	; Jetman is not hovering, but should he stand?
	LD A, (jd.jetState)
	BIT jd.JET_STATE_GND_BIT, A					; Is Jemtan on the ground already?
	JR Z, .afterInactivity						; Jump if not on the ground

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
	CALL js.ChangeJetSpritePattern
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
	CALL js.ChangeJetSpritePattern

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
	SUB jd.ENEMY_THICKNESS							; Include the thickness of the enemy
	CP E
	RET NC										; Jump if "(C - L) >= E" -> "(Xenemy - L) >= Xshot"  -> shot is before the enemy, left of it

	; Check if the Jetman hits the enemy from the right side of its X coordinate
	ADD jd.ENEMY_THICKNESS							; Revert "SUB L" from above
	ADD jd.ENEMY_THICKNESS							; Include the thickness of the enemy
	CP E
	RET C 										; Jump if "(C + L) < E" -> "(Xenemy + L) < Xshot"  -> shot is after the enemy, right of it

	; We are here because the shot is horizontal with the enemy, now check the vertical match
	LD A, (jd.jetmanY)							; B holds Y from the Jetman
	LD B, A
	LD A, (IX + sr.MSS.Y)						; A holds Y from the enemy
	
	; Check upper bounds
	SUB jd.ENEMY_THICKNESS							; Include the thickness of the enemy
	CP B
	RET NC

	; Check lower bounds
	ADD jd.ENEMY_THICKNESS							; Revert "SUB L" from above
	ADD jd.ENEMY_THICKNESS							; Include the thickness of the enemy
	CP B
	RET C

	; We have colision!
	CALL sr.SetSpriteId							; Destroy the enemy
	CALL sr.SpriteHit

	; Is Jetman already dying? If so, do not start the RiP sequence again, just kill the enemy
	LD A, (jd.jetState)							
	BIT jd.JET_STATE_RIP_BIT, A
	RET NZ										; Exit if RIP

	; Is Jetman invincible? If so, just kill the enemy
	BIT jd.JET_STATE_INV_BIT, A
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
	LD (jd.jetmanX), BC

	LD A, 100
	LD (jd.jetmanY), A

	LD A, 0
	NEXTREG _DC_REG_TILE_X_LSB, A
	NEXTREG _DC_REG_TILE_Y, A

	CALL js.ChangeJetStateRespown

	LD A, (jd.RESPOWN_INVINCIBLE_LOOPS)
	CALL MakeJetInvincible

	RET

;----------------------------------------------------------;
;                        #JetRip                           ;
;----------------------------------------------------------;
JetRip

	LD A, (jd.jetState)
	BIT jd.JET_STATE_RIP_BIT, A
	RET Z										; Exit if not RiP

	CALL ShakeScreen
	CALL RipMove

	; Did Jetam reach the top of the screen (the RIP sequence is over)?	
	LD A, (jd.jetmanY)
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
;  - A:		Number of loops (#counter10) to keep Jemtan invincible
MakeJetInvincible
	LD (jd.invincibleCnt), A
	
	LD A, (jd.jetState)
	SET jd.JET_STATE_INV_BIT, A
	LD (jd.jetState), A

	RET

;----------------------------------------------------------;
;                   #JetInvincible                         ;
;----------------------------------------------------------;
JetInvincible
	LD A, (jd.invincibleCnt)						; Exit if #jd.invincibleCnt == 0
	CP 0
	RET Z

	DEC A
	LD (jd.invincibleCnt), A						; Decrement counter and store it
	CP 0											; Check whether this is the last iteration (#jd.invincibleCnt changes from 1 to 0)
	JR Z, .lastIteration

	; Still invincible - blink Jetman sprite
	CALL BlinkJetSprite
	RET
.lastIteration	
	; It is the last iteration, remove invincibility
	LD A, (jd.jetState)
	RES jd.JET_STATE_INV_BIT, A
	LD (jd.jetState), A

	RET

;----------------------------------------------------------;
;                    #BlinkJetSprite                       ;
;----------------------------------------------------------;
BlinkJetSprite
	LD A, (dc.counter5FliFLop)
	CP dc.FLIP_ON
	JR NZ, .flipOff
	
	; Show sprite
	LD B, _SPR_PATTERN_SHOW
	CALL js.ShowJetSprite
	RET
.flipOff
	; Hide sprite
	LD B, _SPR_PATTERN_HIDE
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
	LD E, jd.SHAKE_SCREEN_BY
	MUL D, E
	LD A, E
	NEXTREG _DC_REG_TILE_X_LSB, A

	RET	
	
;----------------------------------------------------------;
;                    #ResetRipMove                         ;
;----------------------------------------------------------;	
ResetRipMove
	LD A, jd.RIP_MOVE_MUL_INC
	LD (jd.ripMoveMul), A
	LD (jd.ripMoveCnt), A
	RET

;----------------------------------------------------------;
;                      #RipMove                            ;
;----------------------------------------------------------;	
; Jetman moves in zig-zac towards the upper side of the screen. 
RipMove
	; Move left or right
	LD A, (jd.ripMoveState)
	CP jd.RIP_MOVE_LEFT
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
	LD A, (jd.jetmanY)
	ADD A, -2
	LD (jd.jetmanY), A

	; Decrement move counter
	LD A, (jd.ripMoveCnt)
	DEC A
	LD (jd.ripMoveCnt), A
	CP 0

	RET NZ										; Counter is still > 0 - keep going

	; Counter has reached 0 - change direction
	LD A, (jd.ripMoveState)
	XOR 1
	LD (jd.ripMoveState), A

	; Increment zig-zag distance (gets bigger with every direction change)
	LD A, (jd.ripMoveMul)
	ADD jd.RIP_MOVE_MUL_INC
	LD (jd.ripMoveMul), A

	; Counter (how far we go left/right in zig-zag) increments with every turn, and jd.ripMoveMul holds the increasing value
	LD (jd.ripMoveCnt), A
	
	RET

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE