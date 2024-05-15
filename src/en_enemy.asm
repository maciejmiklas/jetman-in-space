;----------------------------------------------------------;
;                     Flying Enemy                         ;
;----------------------------------------------------------;
	MODULE en

; The timer ticks with every game loop. When it reaches #EN_RESPOWN_DELAY, a single enemy will respawn, and the timer starts from 0, counting again.
respownDelayCnt 			DB 0
respownDelay 				DB 20				; Amount of game loops to respawn single enemy

; Extends #MSS by additional params.
	STRUCT ESS
MOVE_DELAY				BYTE					; Number of game loops to skip before moving enemy (delays movement speed)
MOVE_DELAY_CNT			BYTE					; Move delay counter
MOVE_PATTERN_POINTER	WORD					; Pointer to the movement pattern
MOVE_PATTERN_CNT 		BYTE					; Counter for current position in the movement pattern
RESPOWN_DELAY			BYTE					; Number of game loops delaying respawn
RESPOWN_DELAY_CNT		BYTE					; Respawn delay counter
	ENDS

; Sprites for single enemy (#sprite), based on #MSS
; Each sprite has hardcoded respawn coordinates and the direction in which it moves
spriteEx01
	ESS {1/*MOVE_DELAY*/, 0/*MOVE_DELAY_CNT*/, 0/*MOVE_PATTERN_POINTER*/, 0/*MOVE_PATTERN_CNT*/, 0/*RESPOWN_DELAY*/ ,0/*RESPOWN_DELAY_CNT*/}
spriteEx02
	ESS {2/*MOVE_DELAY*/, 0/*MOVE_DELAY_CNT*/, 0/*MOVE_PATTERN_POINTER*/, 0/*MOVE_PATTERN_CNT*/, 0/*RESPOWN_DELAY*/ ,0/*RESPOWN_DELAY_CNT*/}
spriteEx03
	ESS {3/*MOVE_DELAY*/, 0/*MOVE_DELAY_CNT*/, 0/*MOVE_PATTERN_POINTER*/, 0/*MOVE_PATTERN_CNT*/, 0/*RESPOWN_DELAY*/ ,0/*RESPOWN_DELAY_CNT*/}
spriteEx04
	ESS {4/*MOVE_DELAY*/, 0/*MOVE_DELAY_CNT*/, 0/*MOVE_PATTERN_POINTER*/, 0/*MOVE_PATTERN_CNT*/, 0/*RESPOWN_DELAY*/ ,0/*RESPOWN_DELAY_CNT*/}
spriteEx05
	ESS {0/*MOVE_DELAY*/, 0/*MOVE_DELAY_CNT*/, 0/*MOVE_PATTERN_POINTER*/, 0/*MOVE_PATTERN_CNT*/, 5/*RESPOWN_DELAY*/ ,0/*RESPOWN_DELAY_CNT*/}
spriteEx06
	ESS {0/*MOVE_DELAY*/, 0/*MOVE_DELAY_CNT*/, 0/*MOVE_PATTERN_POINTER*/, 0/*MOVE_PATTERN_CNT*/, 5/*RESPOWN_DELAY*/ ,0/*RESPOWN_DELAY_CNT*/}
spriteEx07
	ESS {0/*MOVE_DELAY*/, 0/*MOVE_DELAY_CNT*/, 0/*MOVE_PATTERN_POINTER*/, 0/*MOVE_PATTERN_CNT*/, 5/*RESPOWN_DELAY*/ ,0/*RESPOWN_DELAY_CNT*/}
spriteEx08
	ESS {1/*MOVE_DELAY*/, 0/*MOVE_DELAY_CNT*/, 0/*MOVE_PATTERN_POINTER*/, 0/*MOVE_PATTERN_CNT*/, 0/*RESPOWN_DELAY*/ ,0/*RESPOWN_DELAY_CNT*/}
spriteEx09
	ESS {2/*MOVE_DELAY*/, 0/*MOVE_DELAY_CNT*/, 0/*MOVE_PATTERN_POINTER*/, 0/*MOVE_PATTERN_CNT*/, 0/*RESPOWN_DELAY*/ ,0/*RESPOWN_DELAY_CNT*/}
spriteEx10
	ESS {2/*MOVE_fDELAY*/, 0/*MOVE_DELAY_CNT*/, 0/*MOVE_PATTERN_POINTER*/, 0/*MOVE_PATTERN_CNT*/, 0/*RESPOWN_DELAY*/ ,0/*RESPOWN_DELAY_CNT*/}

sprite01
	sr.MSS {20/*ID*/, sr.SDB_COMET1/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, sr.MSS_STATE_LEFT_MASK/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx01/*EXT_DATA_POINTER*/}
sprite02
	sr.MSS {21/*ID*/, sr.SDB_COMET1/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, sr.MSS_STATE_LEFT_MASK/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx02/*EXT_DATA_POINTER*/}
sprite03
	sr.MSS {22/*ID*/, sr.SDB_COMET1/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, sr.MSS_STATE_RIGHT_MASK/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx03/*EXT_DATA_POINTER*/}
sprite04
	sr.MSS {23/*ID*/, sr.SDB_COMET1/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, sr.MSS_STATE_LEFT_MASK/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx04/*EXT_DATA_POINTER*/}
sprite05
	sr.MSS {24/*ID*/, sr.SDB_COMET2/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, sr.MSS_STATE_RIGHT_MASK/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx05/*EXT_DATA_POINTER*/}
sprite06
	sr.MSS {25/*ID*/, sr.SDB_COMET2/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, sr.MSS_STATE_LEFT_MASK/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx06/*EXT_DATA_POINTER*/}
sprite07
	sr.MSS {26/*ID*/, sr.SDB_COMET2/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, sr.MSS_STATE_RIGHT_MASK/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx07/*EXT_DATA_POINTER*/}
sprite08
	sr.MSS {27/*ID*/, sr.SDB_COMET1/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, sr.MSS_STATE_LEFT_MASK/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx08/*EXT_DATA_POINTER*/}
sprite09
	sr.MSS {28/*ID*/, sr.SDB_COMET1/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, sr.MSS_STATE_RIGHT_MASK/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx09/*EXT_DATA_POINTER*/}
sprite10
	sr.MSS {29/*ID*/, sr.SDB_COMET1/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, sr.MSS_STATE_LEFT_MASK/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx10/*EXT_DATA_POINTER*/}

spritesSize					DB 10				; The maximum amount of visible enemies			
SPRITE_HEIGHT_PLATFORM		= 3

SPRITE_HEIGHT_WEAPON		= 8
SPRITE_WIDTH_WEAPON			= 8

;----------------------------------------------------------;
;                        #Respown                          ;
;----------------------------------------------------------;
Respown
	; Increment respawn timer and exit function if it's not time to respawn a new enemy
	LD A, (respownDelay)
	LD B, A
	LD A, (respownDelayCnt)
	INC A
	CP B
	JR Z, .startRespown							; Jump if the timer reaches respawn delay
	LD (respownDelayCnt), A
	RET
.startRespown	
	LD A, 0
	LD (respownDelayCnt), A						; Reset delay timer

	; It would be the time to respawn the enemy. However, to archive random respawn time, we will respawn only when the loop counter 
	; is within the Y coordinate, where movement is allowed:  #SCR_Y_MIN_POS < Y < #SCR_Y_MAX_POS
	LD A, (gm.loopCnt)

	CP sc.SCR_Y_MIN_POS
	RET C										; Return if Y is below game screen

	CP sc.SCR_Y_MAX_POS
	RET NC										; Return if Y is above game screen

	LD IX, sprite01								; Iterate over all enemies to find the first hidden, respawn it, and exit function

	LD A, (spritesSize)
	LD B, A 
.loop
	PUSH BC										; Preserve B for loop counter
		
	LD A, (IX + sr.MSS.STATE)
	AND sr.MSS_STATE_VISIBLE					; Reset all bits but visibility
	CP sr.MSS_STATE_VISIBLE
	JR Z, .continue								; Skipp this sprite if it's already visible

	; Sprite is hidden; check the dedicated delay before respawning

	; Load extra sprite data (#ESS) to IY
	LD BC, (IX + sr.MSS.EXT_DATA_POINTER)
	LD IY, BC
	
	; There are two respawn delay timers. The first is global (#respownDelayCnt) and ensures that multiple enemies do not respawn at the same time. 
	; The second timer can be configured for a single enemy, which further delays its comeback. 
	LD A, (IY + ESS.RESPOWN_DELAY)
	CP 0
	
	JR Z, .afterEnemyRespownDisabled			; Jump if there is no extra delay for this enemy
		
	LD B, A	
	LD A, (IY + ESS.RESPOWN_DELAY_CNT)
	INC A
	CP B
	JR Z, .afterEnemyRespownDelay				; Jump if the timer reaches respawn delay

	LD (IY + ESS.RESPOWN_DELAY_CNT), A			; The delay timer for the enemy is still ticking
	POP BC
	RET

.afterEnemyRespownDelay
	LD A, 0
	LD (IY + ESS.RESPOWN_DELAY_CNT), A			; Reset delay timer
.afterEnemyRespownDisabled	

	; Show sprite, first mark it as visible
	LD A, (IX + sr.MSS.STATE)
	CALL sr.SetVisible

	; Reset delay move counter
	LD A, 0
	LD A, (IY + ESS.MOVE_DELAY_CNT)

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

	CALL sr.ShowSprite

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
	LD IX, sprite01	
	LD A, (spritesSize)
	LD B, A 
	CALL sr.AnimateSprites

	RET	

;----------------------------------------------------------;
;                      #WeaponHit                          ;
;----------------------------------------------------------;
WeaponHit
	LD IX, sprite01
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
	LD IX, sprite01	
	LD A, (spritesSize)
	LD B, A 

.loop
	PUSH BC										; Preserve B for loop counter

	; Ignore this sprite if it's hidden
	LD A, (IX + sr.MSS.STATE)
	AND sr.MSS_STATE_VISIBLE					; Reset all bits but visibility
	CP 0
	JR Z, .continue								; Jump if visibility is not set (sprite is hidden)

	; Load extra data for this sprite to IY
	LD BC, (IX + sr.MSS.EXT_DATA_POINTER)
	LD IY, BC

	; Slow down movement by incrementing the counter until it reaches the configured value
	LD A, (IY + ESS.MOVE_DELAY)
	CP 0										; No delay? -> move at full speed
	JR Z, .afterDelayMove

	LD B, A										; Load goal for delay counter into B

	; Delaying movement, increment delay counter
	LD A, (IY + ESS.MOVE_DELAY_CNT)
	INC A
	LD (IY + ESS.MOVE_DELAY_CNT), A

	CP B										; B already contains #MOVE_DELAY
	JR NZ, .continue							; Return if the delay counter does not reach the required value.

	LD A, 0										; Reset the movement delay counter because it has reached the configured value
	LD (IY + ESS.MOVE_DELAY_CNT), A

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

	; If X >= 315 then hide sprite 
	; X is 9-bit value: 315 = 256 + 59 = %00000001 + %00111011 -> MSB: 1, LSB: 59
	LD A, B										; Load MSB from X into A
	CP 1										; 9-th bit set means X > 256
	JR NZ, .afterMoving
	LD A, C										; Load MSB from X into A
	CP 59										; MSB > 59 
	JR C, .afterMoving
	
	; Sprite is after 315 -> hide it
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

	; Jump if B > 0 (loop starts with B = #MSS)
	POP BC
	DEC B
	LD A, B
	CP 0
	RET Z									; Exit if B has reached 0

	; Move IX to the beginning of the next #shotMssXX
	LD DE, sr.MSS
	ADD IX, DE

	JP .loop

	RET	

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE			