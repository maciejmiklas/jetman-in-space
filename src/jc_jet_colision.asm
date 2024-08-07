;----------------------------------------------------------;
;                    Jetman Collision                      ;
;----------------------------------------------------------;
	MODULE jc

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