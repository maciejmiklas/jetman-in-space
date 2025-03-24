;----------------------------------------------------------;
;                    Jetman Collision                      ;
;----------------------------------------------------------;
	MODULE jco

RIP_MOVE_LEFT			= 0
RIP_MOVE_RIGHT			= 1
ripMoveState			BYTE 0					; 1 - move right, 0 - move left

; Amount of steps to move in a direction is given by #ripMoveState. This counter counts down to 0. When that happens, 
; the counter gets initialized from #ripMoveMul, and the direction changes (#ripMoveState).
ripMoveCnt				BYTE RIP_MOVE_MUL_INC

RIP_MOVE_MUL_INC		= 5
ripMoveMul				BYTE RIP_MOVE_MUL_INC

invincibleCnt			WORD 0					; Makes Jetman invincible when > 0.

;----------------------------------------------------------;
;               #JetmanEnemiesCollision                    ;
;----------------------------------------------------------;
JetmanEnemiesCollision

	CALL bs.SetupArraysDataBank
	LD IX, db.sprite01
	LD A, (db.enemiesSize)
	LD B, A
	CALL _EnemiesCollision

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                        #JetRip                           ;
;----------------------------------------------------------;
JetRip

	LD A, (jt.jetState)
	CP jt.JET_ST_RIP
	RET NZ										; Exit if not RiP.

	CALL _RipMove

	; Did Jetman reach the top of the screen (the RIP sequence is over)?
	LD A, (jpo.jetY)
	CP 4										; Going up is incremented by 2.
	RET NC										; Nope, still going up (#jetY >= 4).

	; Sequence is over, respawn new live.
	CALL _ResetRipMove
	CALL gc.RespawnJet 

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                   #MakeJetInvincible                     ;
;----------------------------------------------------------;
; Input
;  - HL:	Number of loops (#counter002) to keep Jetman invincible.
MakeJetInvincible
	LD (invincibleCnt), HL						; Store invincibility duration.
	
	; Update state
	LD A, jt.JET_ST_INV
	CALL jt.SetJetState

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                   #JetInvincible                         ;
;----------------------------------------------------------;
JetInvincible

	LD A, (jt.jetState)
	CP jt.JET_ST_INV
	RET NZ

	; ##########################################
	; Exit if #invincibleCnt == 0 (B == 0 -> H == B and L == B).
	LD HL, (invincibleCnt)
	LD B, 0
	CALL ut.HlEqualB
	CP ut.HL_IS_B
	RET Z
.after0Check

	DEC HL
	LD (invincibleCnt), HL						; Decrement counter and store it.

	; ##########################################
	; Check whether this is the last iteration (#invincibleCnt changes from 1 to 0).
	LD B, 0
	CALL ut.HlEqualB
	CP ut.HL_IS_B
	JR Z, .lastIteration						; HL == 0

	; ##########################################
	; Still invincible - blink Jetman sprite (at first blink fast, last few seconds blink slow).
	; Should blink slow or fast?
	LD A, H										; H should be 0 because the last blink phase (slow blink) is 8 bits.
	CP 0
	JR NZ, .blinkFast							; #invincibleCnt > 255 (H != 0) -> blink fast.

	LD A, L
	CP _INVINCIBLE_BLINK_D100
	JR NC, .blinkFast							; #invincibleCnt > #_INVINCIBLE_BLINK_D100 -> blink fast.

	;  #invincibleCnt < #_INVINCIBLE_BLINK_D100 -> blink slow (invincibility is almost over).
	LD A, (gld.counter004FliFLop)
	JR .afterBlinkSet
.blinkFast	
	LD A, (gld.counter002FliFLop)
.afterBlinkSet	

	CALL js.BlinkJetSprite
	RET
	
.lastIteration	
	; ##########################################
	; It is the last iteration, remove invincibility.
	LD A, jt.JET_ST_NORMAL
	CALL jt.SetJetState

	CALL js.ShowJetSprite

	RET											; ## END of the function ##
	
;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                    #_EnemyCollision                       ;
;----------------------------------------------------------;
; Checks whether a given enemy has been hit by the laser beam and eventually destroys it.
; Input:
;  - IX:	Pointer to concrete single enemy, single #SPR.
_EnemyCollision

	; Exit if enemy is not alive.
	BIT sr.SPRITE_ST_ACTIVE_BIT, (IX + sr.SPR.STATE)
	RET Z

	; ################################
	; At first, check if Jetman is close to the enemy from above, enough to play "kick legs" animation, but still insufficient to kill the Jetman.

	; It's flying, now check the collision.
	LD E, 0
	LD D, _ENP_MARG_VERT_KICK_D25
	CALL _CheckCollision
	CP COLLISION_YES
	JR NZ, .noKicking
	
	; Jetman is close enough to start kicking (to far to die), but first check if the animation does not play already.
	LD A, (jt.jetAir)
	CP jt.AIR_ENEMY_KICK
	RET Z										; Animation plays already.
	
	; Play animation and set state
	LD A, jt.AIR_ENEMY_KICK
	CALL jt.SetJetStateAir

	LD A, js.SDB_T_KF
	CALL js.ChangeJetSpritePattern				; Play the animation and keep checking for RiP collision.

.noKicking

	; ################################
	; Check if we should reset kicking state.
	LD A, (jt.jetAir)
	CP jt.AIR_ENEMY_KICK
	JR NZ, .afterKickReset

	; Reset kick state
	LD A, jt.AIR_FLY
	CALL jt.SetJetStateAir

	JR NZ, .afterKickReset
.afterKickReset	

	; ################################
	; The distance to the enemy is not large enough for Jetman to start kicking. Now, check whether Jetman is close enough to the enemy to die.
	LD D, _ENP_MARG_VERT_UP_D18
	LD E, _ENP_MARG_VERT_LOW_D15
	CALL _CheckCollision
	CP COLLISION_YES
	RET NZ

	; We have collision!
	CALL gc.EnemyHitsJet

	RET											; ## END of the function ##


;----------------------------------------------------------;
;                    #_ResetRipMove                        ;
;----------------------------------------------------------;
_ResetRipMove

	LD A, RIP_MOVE_MUL_INC
	LD (ripMoveMul), A
	LD (ripMoveCnt), A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                     #_RipMove                            ;
;----------------------------------------------------------;
; Jetman moves in zig-zac towards the upper side of the screen.
_RipMove

	; Move left or right.
	LD A, (ripMoveState)
	CP RIP_MOVE_LEFT
	JR Z, .moveLeft

	; Move right.
	LD B, _RIP_MOVE_L_D3
	CALL jpo.DecJetXbyB
	JR .afterMove

.moveLeft
	; Move left.
	LD B, _RIP_MOVE_R_D3
	CALL jpo.IncJetXbyB
.afterMove

	LD B, _RIP_MOVE_Y_D4						; Going up.
	CALL jpo.DecJetYbyB

	; Decrement move counter.
	LD A, (ripMoveCnt)
	DEC A
	LD (ripMoveCnt), A
	CP 0

	RET NZ										; Counter is still > 0 - keep going.

	; Counter has reached 0 - change direction.
	LD A, (ripMoveState)
	XOR 1
	LD (ripMoveState), A

	; Increment zig-zag distance (gets bigger with every direction change).
	LD A, (ripMoveMul)
	ADD RIP_MOVE_MUL_INC
	LD (ripMoveMul), A

	; Counter (how far we go left/right in zig-zag) increments with every turn, and ripMoveMul holds the increasing value.
	LD (ripMoveCnt), A
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                    #_CheckCollision                      ;
;----------------------------------------------------------;
; Checks whether a given enemy has been hit by the laser beam and eventually destroys it.
; Input:
;  - IX:	Pointer to concrete single enemy, single #SPR.
;  - D:		Upper thickness of the enemy (enemy above Jetman).
;  - E:		Lower thickness of the enemy (enemy below Jetman).
; Return:
;  - A:		COLLISION_NO or COLLISION_YES.
COLLISION_NO			= 0
COLLISION_YES			= 1

_CheckCollision

	; Compare X coordinate of enemy and Jetman.
	LD BC, (IX + sr.SPR.X)						; X of the enemy.
	LD HL, (jpo.jetX)							; X of the Jetman.

	; Check whether Jetman is horizontal with the enemy
	SBC HL, BC	
	CALL ut.AbsHL								; HL contains a positive distance between the enemy and Jetman.
	LD A, H
	CP 0
	JR Z, .keepCheckingHorizontal				; HL > 256 -> no collision.
	LD A, COLLISION_NO
	RET		
.keepCheckingHorizontal	
	LD A, L
	LD B, _ENP_MARG_HOR_D12
	CP B
	JR C, .checkVertical						; Jump if there is horizontal collision, check vertical.
	LD A, COLLISION_NO							; L >= D (Horizontal thickness of the enemy) -> no collision.
	RET
.checkVertical

	; We are here because Jetman's horizontal position matches that of the enemy, now check vertical.
	LD B, (IX + sr.SPR.Y)						; Y of the enemy.
	LD A, (jpo.jetY)							; Y of the Jetman.

	; Is Jetman above or below the enemy?
	CP B
	JR C, .jetmanAboveEnemy						; Jump if "Jet Y" < "enemy Y". Jet is above enemy (0 is at the top, 256 bottom).

	; Jetman is below enemy.
	SUB B
	CP E
	JR C, .collision							; Jump if A - B < D.
	JR .noCollision

.jetmanAboveEnemy
	; Jetman is above enemy.

	; Swap A and B (compared to above) to avoid negative value.
	LD A, (jpo.jetY)
	LD B, A										; B: Y of the Jetman.
	LD A, (IX + sr.SPR.Y)						; A: Y of the enemy.
	SUB B
	CP D
	JR C, .collision
	JR .noCollision

.noCollision
	LD A, COLLISION_NO
	RET
.collision
	LD A, COLLISION_YES
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                    #_EnemiesCollision                     ;
;----------------------------------------------------------;
; Checks all active enemies given by IX for collision with leaser beam.
; Input
;  - IX:	Pointer to #SPR, the enemies.
;  - B:		Number of enemies in IX.
; Modifies: ALL
_EnemiesCollision

.loop
	PUSH BC										; Preserve B for loop counter.
	CALL _EnemyCollision
.continue
	; Move HL to the beginning of the next #shotsX
	LD DE, sr.SPR
	ADD IX, DE
	POP BC
	DJNZ .loop									; Jump if B > 0.

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE