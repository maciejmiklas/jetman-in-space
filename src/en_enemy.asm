;----------------------------------------------------------;
;                     Flying Enemy                         ;
;----------------------------------------------------------;
	MODULE en

; The timer ticks with every game loop. When it reaches #EN_RESPOWN_DELAY, a single enemy will respawn, and the timer starts from 0, counting again.
respownTimer 				DB 0
respownDelay 				DB 20				; Amount of game loops to respawn single enemy

; Sprites for single enemy (#sprite), based on #MSS
; Each sprite has hardcoded respawn coordinates and the direction in which it moves
sprite
	sr.MSS {20/*ID*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, sr.MSS_STATE_LEFT_MASK/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 1/*MOVE_DELAY_LOOPS*/, 
		0/*MOVE_DELAY_CNT*/, 0/*MOVE_PATTERN_POINTER*/, 0/*MOVE_PATTERN_CNT*/, 0/*RESPOWN_DELAY_LOOPS*/ ,0/*RESPOWN_DELAY_CNT*/}
sprite2
	sr.MSS {21/*ID*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, sr.MSS_STATE_LEFT_MASK/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 2/*MOVE_DELAY_LOOPS*/, 
		0/*MOVE_DELAY_CNT*/, 0/*MOVE_PATTERN_POINTER*/, 0/*MOVE_PATTERN_CNT*/, 0/*RESPOWN_DELAY_LOOPS*/ ,0/*RESPOWN_DELAY_CNT*/}
sprite3
	sr.MSS {22/*ID*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, sr.MSS_STATE_RIGHT_MASK/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 3/*MOVE_DELAY_LOOPS*/, 
		0/*MOVE_DELAY_CNT*/, 0/*MOVE_PATTERN_POINTER*/, 0/*MOVE_PATTERN_CNT*/, 0/*RESPOWN_DELAY_LOOPS*/ ,0/*RESPOWN_DELAY_CNT*/}
sprite4
	sr.MSS {23/*ID*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, sr.MSS_STATE_LEFT_MASK/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 4/*MOVE_DELAY_LOOPS*/, 
		0/*MOVE_DELAY_CNT*/, 0/*MOVE_PATTERN_POINTER*/, 0/*MOVE_PATTERN_CNT*/, 0/*RESPOWN_DELAY_LOOPS*/ ,0/*RESPOWN_DELAY_CNT*/}
sprite5
	sr.MSS {24/*ID*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, sr.MSS_STATE_RIGHT_MASK/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*MOVE_DELAY_LOOPS*/, 
		0/*MOVE_DELAY_CNT*/, 0/*MOVE_PATTERN_POINTER*/, 0/*MOVE_PATTERN_CNT*/, 0/*RESPOWN_DELAY_LOOPS*/ ,0/*RESPOWN_DELAY_CNT*/}
sprite6
	sr.MSS {25/*ID*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, sr.MSS_STATE_LEFT_MASK/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*MOVE_DELAY_LOOPS*/, 
		0/*MOVE_DELAY_CNT*/, 0/*MOVE_PATTERN_POINTER*/, 0/*MOVE_PATTERN_CNT*/, 0/*RESPOWN_DELAY_LOOPS*/ ,0/*RESPOWN_DELAY_CNT*/}
sprite7
	sr.MSS {26/*ID*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, sr.MSS_STATE_RIGHT_MASK/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 1/*MOVE_DELAY_LOOPS*/, 
		0/*MOVE_DELAY_CNT*/, 0/*MOVE_PATTERN_POINTER*/, 0/*MOVE_PATTERN_CNT*/, 0/*RESPOWN_DELAY_LOOPS*/ ,0/*RESPOWN_DELAY_CNT*/}
sprite8
	sr.MSS {27/*ID*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, sr.MSS_STATE_LEFT_MASK/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 1/*MOVE_DELAY_LOOPS*/, 
		0/*MOVE_DELAY_CNT*/, 0/*MOVE_PATTERN_POINTER*/, 0/*MOVE_PATTERN_CNT*/, 0/*RESPOWN_DELAY_LOOPS*/ ,0/*RESPOWN_DELAY_CNT*/}
sprite9
	sr.MSS {28/*ID*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, sr.MSS_STATE_RIGHT_MASK/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 2/*MOVE_DELAY_LOOPS*/, 
		0/*MOVE_DELAY_CNT*/, 0/*MOVE_PATTERN_POINTER*/, 0/*MOVE_PATTERN_CNT*/, 0/*RESPOWN_DELAY_LOOPS*/ ,0/*RESPOWN_DELAY_CNT*/}
sprite10
	sr.MSS {29/*ID*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, sr.MSS_STATE_LEFT_MASK/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 2/*MOVE_DELAY_LOOPS*/, 
		0/*MOVE_DELAY_CNT*/, 0/*MOVE_PATTERN_POINTER*/, 0/*MOVE_PATTERN_CNT*/, 0/*RESPOWN_DELAY_LOOPS*/ ,0/*RESPOWN_DELAY_CNT*/}

spritesSize					DB 10				; The maximum amount of visible enemies			
SPRITE_HEIGHT_PLATFORM		= 3

SPRITE_HEIGHT_WEAPON		= 8
SPRITE_WIDTH_WEAPON			= 8

;----------------------------------------------------------;
;                      #respown                          ;
;----------------------------------------------------------;
respown
	; Increment respawn timer and exit function if it's not time to respawn a new enemy
	LD A, (respownDelay)
	LD B, A
	LD A, (respownTimer)
	INC A
	CP B
	JR Z, .startRespown							; Jump if the timer reaches respawn delay
	LD (respownTimer), A
	RET
.startRespown	
	LD A, 0
	LD (respownTimer), A						; Reset timer

	; It would be the time to respawn the enemy. However, to archive random respawn time, we will respawn only when the loop counter 
	; is within the Y coordinate, where movement is allowed:  #SCR_Y_MIN_POS < Y < #SCR_Y_MAX_POS
	LD A, (gm.loopCnt)

	CP sc.SCR_Y_MIN_POS
	RET C										; Return if Y is below game screen

	CP sc.SCR_Y_MAX_POS
	RET NC										; Return if Y is above game screen

	; Iterate over all enemies
	LD IX, sprite	
	LD A, (spritesSize)
	LD B, A 
.loop
	PUSH BC										; Preserve B for loop counter
	
	LD A, (IX + sr.MSS.STATE)
	AND sr.MSS_STATE_VISIBLE					; Reset all bits but visibility
	CP sr.MSS_STATE_VISIBLE
	JR Z, .continue								; Skipp this sprite if it's already visible

	; Sprite is hidden - respawn it!

	; Mark sprite as visible
	LD A, (IX + sr.MSS.STATE)
	CALL sr.ShowSprite

	; Reset delay move counter
	LD A, 0
	LD A, (IX + sr.MSS.MOVE_DELAY_CNT)

	; Set Y (horizontal respown) to a random value
	LD A, (gm.loopCnt)
	LD (IX + sr.MSS.Y), A
	
	; Set X to left or right side of the screen
	LD A, (IX + sr.MSS.STATE)
	AND sr.MSS_STATE_RIGHT_MASK
	CP sr.MSS_STATE_RIGHT_MASK
	JR NZ, .left
	LD BC, sc.SCR_X_MAX_POS
	JR .afterLR
.left	
	LD BC, sc.SCR_X_MIN_POS
.afterLR
	LD (IX + sr.MSS.X), BC

	; Setup sprite
	CALL sr.SetSpriteId							; Set the ID of the sprite for the following commands

	; Set sprite pattern
	LD A, sr.SDB_COMET1
	CALL sr.SetSpritePattern

	CALL sr.UpdateSpritePosition				; Set X, Y and rotation
	CALL sr.UpdateSpritePattern					; Render sprite

	; Exit after respawning first enemy
	POP BC
	RET											
.continue
	; Move IX to the beginning of the next #shotMssXX
	LD DE, sr.MSS
	ADD IX, DE
	POP BC
	DJNZ .loop									; Jump if B > 0 (loop starts with B = #spritesSize)

	RET

;----------------------------------------------------------;
;                  #AnimateEnemies                         ;
;----------------------------------------------------------;
AnimateEnemies
	 
	; Animate shots
	LD IX, sprite	
	LD A, (spritesSize)
	LD B, A 
	CALL sr.AnimateSprites

	RET	

;----------------------------------------------------------;
;                      #WeaponHit                          ;
;----------------------------------------------------------;
WeaponHit
	LD IX, sprite
	LD L, SPRITE_HEIGHT_WEAPON
	LD H, SPRITE_WIDTH_WEAPON
	LD A, (spritesSize)
	LD B, A
	CALL jw.WeaponHit
	RET	

;----------------------------------------------------------;
;                       #MoveEnemies                       ;
;----------------------------------------------------------;
; Modifies: ALL
MoveEnemies
	; Loop ever al enemies skipping hidden 
	LD IX, sprite	
	LD A, (spritesSize)
	LD B, A 
.loop
	PUSH BC										; Preserve B for loop counter

	; Ignore this sprite if it's hidden
	LD A, (IX + sr.MSS.STATE)
	AND sr.MSS_STATE_VISIBLE					; Reset all bits but visibility
	CP 0
	JR Z, .continue								; Jump if visibility is not set (sprite is hidden)

	; Slow down movement by incrementing the counter until it reaches the configured value
	LD A, (IX + sr.MSS.MOVE_DELAY_LOOPS)
	CP 0										; No delay? -> move at full speed
	JR Z, .afterDelayMove

	LD B, A										; Load goal for delay counter into B

	; Delaying movement, increment delay counter
	LD A, (IX + sr.MSS.MOVE_DELAY_CNT)
	INC A
	LD (IX + sr.MSS.MOVE_DELAY_CNT), A

	CP B
	JR NZ, .continue							; Return if the delay counter does not reach the required value.

	LD A, 0										; Reset the movement delay counter because it has reached the configured value
	LD (IX + sr.MSS.MOVE_DELAY_CNT), A

.afterDelayMove

	; Sprite is visible, move it!
	CALL sr.SetSpriteId							; Set the ID of the sprite for the following commands

	LD A, (IX + sr.MSS.STATE)
	AND sr.MSS_STATE_RIGHT_MASK					; Reset all bits but right
	CP sr.MSS_STATE_RIGHT_MASK
	JR NZ, .afterMovingLeft						; Jump if moving right

	; Moving left - decrease X coordinate
	LD BC, (IX + sr.MSS.X)	
	DEC BC

	; Check whether a enemy is outside the screen 
	LD A, B
	CP sc.SCR_X_MIN_POS							; B holds MSB from X, if B > 0 than X > 256
	JR NZ, .afterMoving
	LD A, C
	CP sc.SCR_X_MIN_POS + 5						; C holds LSB from X, ff C != 5 then X is> 5
	JR NC, .afterMoving

	; X == 0 (both A and B are 0) -> enemy out of screen - hide it
	CALL sr.HideSprite
	JR .continue	

.afterMovingLeft

	; Moving right - increase X coordinate
	LD BC, (IX + sr.MSS.X)	
	INC BC

	; If X >= 315 then hide shot 
	; X is 9-bit value: 315 = 256 + 59 = %00000001 + %00111011 -> MSB: 1, LSB: 59
	LD A, B										; Load MSB from X into A
	CP 1										; 9-th bit set means X > 256
	JR NZ, .afterMoving
	LD A, C										; Load MSB from X into A
	CP 59										; MSB > 59 
	JR C, .afterMoving
	
	; Shot is after 315 -> hide it
	CALL sr.HideSprite
	JR .continue
.afterMoving
	LD (IX + sr.MSS.X), BC						; Update new X position
	CALL sr.UpdateSpritePosition

	; Check the collision with the platform
	PUSH BC
	LD IY, platformBump
	LD L, SPRITE_HEIGHT_PLATFORM
	CALL sr.PlaftormColision
	POP BC

.continue
	; Move IX to the beginning of the next #shotMssXX
	LD DE, sr.MSS
	ADD IX, DE
	POP BC
	DJNZ .loop									; Jump if B > 0 (loop starts with B = #MSS)

	RET	

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE			