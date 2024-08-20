;----------------------------------------------------------;
;                    Jetman Collision                      ;
;----------------------------------------------------------;
	MODULE jc

ENEMY_MARGIN_HORIZONTAL	= 12
ENEMY_MARGIN_VER_UP		= 18
ENEMY_MARGIN_VER_LOW	= 15
ENEMY_MARGIN_VER_KICK	= 25

RIP_MOVE_LEFT			= 0
RIP_MOVE_RIGHT			= 1
ripMoveState			BYTE 0					; 1 - move right, 0 - move left

; Amount of steps to move in a direction is given by #ripMoveState. This counter counts down to 0. When that happens, 
; the counter gets initialized from #ripMoveMul, and the direction changes (#ripMoveState)
ripMoveCnt				BYTE RIP_MOVE_MUL_INC

RIP_MOVE_UP_BY 			= -1
RIP_MOVE_MUL_INC		= 5
ripMoveMul				BYTE RIP_MOVE_MUL_INC

invincibleCnt			WORD 0					; Makes Jetman invincible when > 0

INVINCIBLE_DURATION 	= 200					; Number of loops to keep Jetman invincible	
INVINCIBLE_FAST_BLINK	= 150
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
;                    #CheckCollision                       ;
;----------------------------------------------------------;
; Checks whether a given enemy has been hit by the laser beam and eventually destroys it
; Input:
;  - IX:	Pointer to concreate single enemy, single #MSS
;  - D:		Upper thickness of the enemy (enemy above Jetman)
;  - E:		Lower thickness of the enemy (enemy below Jetman)
; Return:
;  - A:		COLLISION_NO or COLLISION_YES
COLLISION_NO			= 0
COLLISION_YES			= 1

CheckCollision
	; Compare X coordinate of enemy and Jetman
	LD BC, (IX + sr.MSS.X)						; X of the enemy
	LD HL, (jp.jetX)							; X of the Jetman

	; Check whether Jetman is horizontal with the enemy
	SBC HL, BC	
	CALL ut.AbsHL								; HL contains a positive distance between the enemy and Jetman
	LD A, H
	CP 0
	JR Z, .keepCheckingHorizontal				; HL > 256 -> no collision
	LD A, COLLISION_NO
	RET		
.keepCheckingHorizontal	
	LD A, L
	LD B, ENEMY_MARGIN_HORIZONTAL
	CP B
	JR C, .checkVertical						; Jump if there is horizontal collision, check vertical
	LD A, COLLISION_NO							; L >= D (Horizontal thickness of the enemy) -> no collision	
	RET
.checkVertical

	; We are here because Jemtman's horizontal position matches that of the enemy, now check vertical
	LD B, (IX + sr.MSS.Y)						; Y of the enemy
	LD A, (jp.jetY)								; Y of the Jetman

	; Is Jemtan above or below the enemy?
	CP B
	JR C, .jetmanAboveEnemy						; Jump if "Jet Y" < "eneymy Y". Jet is above enemy (0 is at the top, 256 bottom)

	; Jetman is below enemy
	SUB B
	CP E
	JR C, .collision							; Jump if A - B < D
	JR .noCollision

.jetmanAboveEnemy
	; Jetman is above enemy

	; Swap A and B (compared to above) to avoid negative value
	LD A, (jp.jetY)
	LD B, A										; B: Y of the Jetman
	LD A, (IX + sr.MSS.Y)						; A: Y of the enemy
	SUB B
	CP D
	JR C, .collision
	JR .noCollision

.noCollision
	LD A, COLLISION_NO
	RET
.collision
	LD A, COLLISION_YES
	RET	
;----------------------------------------------------------;
;                    #EnemyColision                        ;
;----------------------------------------------------------;
; Checks whether a given enemy has been hit by the laser beam and eventually destroys it
; Input:
;  - IX:	Pointer to concreate single enemy, single #MSS
EnemyColision
	; At first, check if Jetman is close to the enemy from above, enough to play "kick legs" animation, but still insufficient to kill the Jetman
	LD E, 0
	LD D, ENEMY_MARGIN_VER_KICK
	CALL CheckCollision
	CP COLLISION_YES
	JR NZ, .noKicking
	
	; Jetman is close enough to start kicking, but first check if the animation does not play already
	LD A, (jt.jetState)
	BIT jt.JET_STATE_KICK_BIT, A
	RET NZ										; Animation playes already
	
	; Play animation and set state
	LD A, (jt.jetState)
	SET jt.JET_STATE_KICK_BIT, A
	LD (jt.jetState), A

	LD A, js.SDB_T_WL
	CALL js.ChangeJetSpritePattern				; Play the animation and keep checking for RiP collision because there is overlapping

.noKicking
	LD D, ENEMY_MARGIN_VER_UP
	LD E, ENEMY_MARGIN_VER_LOW
	CALL CheckCollision
	CP COLLISION_YES
	RET NZ

	; We have colision!
	CALL sr.SetSpriteId							; Destroy the enemy
	CALL sr.SpriteHit

	; Is Jetman already dying? If so, do not start the RiP sequence again, just kill the enemy
	LD A, (jt.jetState)							
	BIT jt.JET_STATE_RIP_BIT, A
	RET NZ										; Exit if RIP

	; Is Jetman invincible? If so, just kill the enemy
	BIT jt.JET_STATE_INV_BIT, A
	RET NZ										; Exit if invincible

	; This is the first enemy hit
	CALL jt.ChangeJetStateRip
	
	LD A, js.SDB_RIP							; Change animation
	CALL js.ChangeJetSpritePattern

	RET

;----------------------------------------------------------;
;                      #RespawnJet                         ;
;----------------------------------------------------------;
RespawnJet
	; Set respawn coordinates
	LD BC, 100
	LD (jp.jetX), BC

	LD A, 100
	LD (jp.jetY), A

	LD A, 0
	NEXTREG _DC_REG_TILE_X_LSB_H30, A
	NEXTREG _DC_REG_TILE_Y_H31, A

	CALL jt.ChangeJetStateRespown

	LD HL, INVINCIBLE_DURATION
	CALL MakeJetInvincible

	CALL bg.UpdateOnMove
	RET

;----------------------------------------------------------;
;                        #JetRip                           ;
;----------------------------------------------------------;
JetRip
	LD A, (jt.jetState)
	BIT jt.JET_STATE_RIP_BIT, A
	RET Z										; Exit if not RiP

	CALL RipMove

	; Did Jetam reach the top of the screen (the RIP sequence is over)?	
	LD A, (jp.jetY)
	CP 4										; Going up is incremented by 2
	RET NC										; Nope, still going up (#jetY >= 4)

	; Sequece is over, respown new live
	CALL RespawnJet 
	CALL ResetRipMove
	RET

;----------------------------------------------------------;
;                   #MakeJetInvincible                     ;
;----------------------------------------------------------;
; Input
;  - HL:	Number of loops (#counter2) to keep Jemtan invincible
MakeJetInvincible
	LD (invincibleCnt), HL						; Store invincibility duration
	
	; Update state
	LD A, (jt.jetState)
	SET jt.JET_STATE_INV_BIT, A
	LD (jt.jetState), A

	RET

;----------------------------------------------------------;
;                   #JetInvincible                         ;
;----------------------------------------------------------;
JetInvincible
	; Exit if #invincibleCnt == 0 (HL == B)
	LD HL, (invincibleCnt)
	LD B, 0
	CALL ut.HlEqualB
	CP ut.HL_IS_B
	RET Z
.after0Check

	DEC HL
	LD (invincibleCnt), HL						; Decrement counter and store it

	; Check whether this is the last iteration (#invincibleCnt changes from 1 to 0)
	LD B, 0
	CALL ut.HlEqualB
	CP ut.HL_IS_B
	JR Z, .lastIteration						; HL == 0

	; Still invincible - blink Jetman sprite (at first blink fast, last few seconds blink slow)
	; Shold blink slow or fast?
	LD A, H										; H should be 0 because the last blink phase (slow blink) is 8 bits
	CP 0
	JR NZ, .blinkFast							; #invincibleCnt > 255 (H != 0) -> blink fast

	LD A, L
	CP INVINCIBLE_FAST_BLINK
	JR NC, .blinkFast							; #invincibleCnt > #INVINCIBLE_FAST_BLINK -> blink fast

	;  #invincibleCnt < #INVINCIBLE_FAST_BLINK -> blink slow (invincibility is almost over)
	LD A, (cd.counter4FliFLop)
	JR .afterBlinkSet
.blinkFast	
	LD A, (cd.counter2FliFLop)
.afterBlinkSet	

	CALL js.BlinkJetSprite
	RET
.lastIteration	
	; It is the last iteration, remove invincibility

	LD A, (jt.jetState)
	RES jt.JET_STATE_INV_BIT, A
	LD (jt.jetState), A

	CALL js.ShowJetSprite
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
	CALL bg.UpdateOnMove

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
	LD A, (jp.jetY)
	ADD A, RIP_MOVE_UP_BY
	LD (jp.jetY), A

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