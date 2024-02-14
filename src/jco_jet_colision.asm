;----------------------------------------------------------;
;                    Jetman Collision                      ;
;----------------------------------------------------------;
	MODULE jco


RIP_MOVE_LEFT			= 0
RIP_MOVE_RIGHT			= 1
ripMoveState			BYTE 0					; 1 - move right, 0 - move left

; Amount of steps to move in a direction is given by #ripMoveState. This counter counts down to 0. When that happens, 
; the counter gets initialized from #ripMoveMul, and the direction changes (#ripMoveState)
ripMoveCnt				BYTE RIP_MOVE_MUL_INC

RIP_MOVE_MUL_INC		= 5
ripMoveMul				BYTE RIP_MOVE_MUL_INC

invincibleCnt			WORD 0					; Makes Jetman invincible when > 0

;----------------------------------------------------------;
;                #JetmanEnemiesColision                    ;
;----------------------------------------------------------;
JetmanEnemiesColision
	; Collision disabled if flying rocket
	LD A, (jt.jetAir)
	CP jt.AIR_FLY_RO
	RET Z

	LD IX, ed.sprite01
	LD A, (ed.spritesSize)
	LD B, A
	CALL EnemiesColision

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                    #EnemiesColision                      ;
;----------------------------------------------------------;
; Checks all active enemies given by IX for collision with leaser beam
; Input
;  - IX:	Pointer to #SPR, the enemies
;  - B:		Number of enemies in IX
; Modifies: ALL
EnemiesColision
.loop
	PUSH BC										; Preserve B for loop counter
	CALL EnemyColision
.continue
	; Move HL to the beginning of the next #shotsX
	LD DE, sr.SPR
	ADD IX, DE
	POP BC
	DJNZ .loop									; Jump if B > 0

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                    #CheckCollision                       ;
;----------------------------------------------------------;
; Checks whether a given enemy has been hit by the laser beam and eventually destroys it
; Input:
;  - IX:	Pointer to concreate single enemy, single #SPR
;  - D:		Upper thickness of the enemy (enemy above Jetman)
;  - E:		Lower thickness of the enemy (enemy below Jetman)
; Return:
;  - A:		COLLISION_NO or COLLISION_YES
COLLISION_NO			= 0
COLLISION_YES			= 1

CheckCollision
	; Compare X coordinate of enemy and Jetman
	LD BC, (IX + sr.SPR.X)						; X of the enemy
	LD HL, (jpo.jetX)							; X of the Jetman

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
	LD B, _CF_ENP_MARG_HOR
	CP B
	JR C, .checkVertical						; Jump if there is horizontal collision, check vertical
	LD A, COLLISION_NO							; L >= D (Horizontal thickness of the enemy) -> no collision	
	RET
.checkVertical

	; We are here because Jemtman's horizontal position matches that of the enemy, now check vertical
	LD B, (IX + sr.SPR.Y)						; Y of the enemy
	LD A, (jpo.jetY)								; Y of the Jetman

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
	LD A, (jpo.jetY)
	LD B, A										; B: Y of the Jetman
	LD A, (IX + sr.SPR.Y)						; A: Y of the enemy
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
;                    #EnemyColision                        ;
;----------------------------------------------------------;
; Checks whether a given enemy has been hit by the laser beam and eventually destroys it
; Input:
;  - IX:	Pointer to concreate single enemy, single #SPR
EnemyColision

	; Exit if enemy is not alive
	BIT sr.SPRITE_ST_ACTIVE_BIT, (IX + sr.SPR.STATE)
	RET Z

	; At first, check if Jetman is close to the enemy from above, enough to play "kick legs" animation, but still insufficient to kill the Jetman
	LD E, 0
	LD D, _CF_ENP_MARG_VERT_KICK
	CALL CheckCollision
	CP COLLISION_YES
	JR NZ, .noKicking
	
	; Jetman is close enough to start kicking (to far to die), but first check if the animation does not play already
	LD A, (jt.jetState)
	BIT jt.JET_STATE_KICK_BIT, A
	RET NZ										; Animation playes already
	
	; Play animation and set state
	LD A, (jt.jetState)
	SET jt.JET_STATE_KICK_BIT, A
	LD (jt.jetState), A

	LD A, js.SDB_T_KF
	CALL js.ChangeJetSpritePattern				; Play the animation and keep checking for RiP collision

.noKicking
	; The distance to the enemy is not large enough for Jetman to start kicking. Now, check whether Jetman is close enough to the enemy to die
	LD D, _CF_ENP_MARG_VERT_UP
	LD E, _CF_ENP_MARG_VERT_LOW
	CALL CheckCollision
	CP COLLISION_YES
	RET NZ

	; We have colision!
	CALL gc.EnemyHitsJet

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                        #JetRip                           ;
;----------------------------------------------------------;
JetRip
	LD A, (jt.jetState)
	BIT jt.JET_STATE_RIP_BIT, A
	RET Z										; Exit if not RiP

	CALL RipMove

	; Did Jetam reach the top of the screen (the RIP sequence is over)?	
	LD A, (jpo.jetY)
	CP 4										; Going up is incremented by 2
	RET NC										; Nope, still going up (#jetY >= 4)

	; Sequece is over, respown new live
	CALL ResetRipMove
	CALL gc.RespawnJet 

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                   #MakeJetInvincible                     ;
;----------------------------------------------------------;
; Input
;  - HL:	Number of loops (#counter002) to keep Jemtan invincible
MakeJetInvincible
	LD (invincibleCnt), HL						; Store invincibility duration
	
	; Update state
	LD A, (jt.jetState)
	SET jt.JET_STATE_INV_BIT, A
	LD (jt.jetState), A

	RET											; ## END of the function ##

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
	CP _CF_INVINCIBLE_BLINK
	JR NC, .blinkFast							; #invincibleCnt > #_CF_INVINCIBLE_BLINK -> blink fast

	;  #invincibleCnt < #_CF_INVINCIBLE_BLINK -> blink slow (invincibility is almost over)
	LD A, (gld.counter004FliFLop)
	JR .afterBlinkSet
.blinkFast	
	LD A, (gld.counter002FliFLop)
.afterBlinkSet	

	CALL js.BlinkJetSprite
	RET
.lastIteration	
	; It is the last iteration, remove invincibility

	LD A, (jt.jetState)
	RES jt.JET_STATE_INV_BIT, A
	LD (jt.jetState), A

	CALL js.ShowJetSprite

	RET											; ## END of the function ##
	
;----------------------------------------------------------;
;                    #ResetRipMove                         ;
;----------------------------------------------------------;	
ResetRipMove
	LD A, RIP_MOVE_MUL_INC
	LD (ripMoveMul), A
	LD (ripMoveCnt), A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                      #RipMove                            ;
;----------------------------------------------------------;	
; Jetman moves in zig-zac towards the upper side of the screen. 
RipMove
	CALL bg.UpdateBackgroundOnJetmanMove

	; Move left or right
	LD A, (ripMoveState)
	CP RIP_MOVE_LEFT
	JR Z, .moveLeft

	; Move right
	CALL jpo.DecJetX
	CALL jpo.DecJetX
	CALL jpo.DecJetX
	JR .afterMove
.moveLeft
	; Move left
	CALL jpo.IncJetX
	CALL jpo.IncJetX
	CALL jpo.IncJetX
.afterMove

	LD B, 4									; Going up
	CALL jpo.DecJetYbyB

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
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE