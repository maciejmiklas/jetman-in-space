;----------------------------------------------------------;
;                     Flying Enemy                         ;
;----------------------------------------------------------;

; The timer ticks with every game loop. When it reaches #EN_RESPOWN_DELAY, a single enemy will respawn, and the timer starts from 0, counting again.
enRespownTimer DB 0
enRespownDelay DB 20						; Amount of game loops to respawn single enemy

; Sprites for single enemy (#enSprite), based on "Memory Structure for Single Sprite" from "sr_simple_sprite.asm"
; Each sprite has hardcoded respawn coordinates and the direction in which it moves
enSprite
	DB 20/*SR_MS_SPRITE_ID*/, 00,00/*SR_MS_DB_POINTER*/, 00,00/*SR_MS_X*/, 00/*SR_MS_Y*/, SR_MS_STATE_LEFT_MASK/*SR_MS_STATE*/, 00/*SR_MS_NEXT*/
	DB 00/*SR_MS_REMAINING*/, 00/*SR_MS_MOVE_DELAY*/, 00/*SR_MS_MOVE_DELAY_CNT*/, 00/*SR_MS_MOVE_PATTERN_CNT*/, 00,00/*SR_MS_MOVE_PATTERN_POINTER*/ 
enSprite2
	DB 21/*SR_MS_SPRITE_ID*/, 00,00/*SR_MS_DB_POINTER*/, 00,00/*SR_MS_X*/, 00/*SR_MS_Y*/, SR_MS_STATE_LEFT_MASK/*SR_MS_STATE*/, 00/*SR_MS_NEXT*/
	DB 00/*SR_MS_REMAINING*/, 01/*SR_MS_MOVE_DELAY*/, 00/*SR_MS_MOVE_DELAY_CNT*/, 00/*SR_MS_MOVE_PATTERN_CNT*/, 00,00/*SR_MS_MOVE_PATTERN_POINTER*/ 
enSprite3
	DB 22/*SR_MS_SPRITE_ID*/, 00,00/*SR_MS_DB_POINTER*/, 00,00/*SR_MS_X*/, 00/*SR_MS_Y*/, SR_MS_STATE_RIGHT_MASK/*SR_MS_STATE*/, 00/*SR_MS_NEXT*/
	DB 00/*SR_MS_REMAINING*/, 02/*SR_MS_MOVE_DELAY*/, 00/*SR_MS_MOVE_DELAY_CNT*/, 00/*SR_MS_MOVE_PATTERN_CNT*/, 00,00/*SR_MS_MOVE_PATTERN_POINTER*/ 
enSprite4
	DB 23/*SR_MS_SPRITE_ID*/, 00,00/*SR_MS_DB_POINTER*/, 00,00/*SR_MS_X*/, 00/*SR_MS_Y*/, SR_MS_STATE_LEFT_MASK/*SR_MS_STATE*/, 00/*SR_MS_NEXT*/
	DB 00/*SR_MS_REMAINING*/, 03/*SR_MS_MOVE_DELAY*/, 00/*SR_MS_MOVE_DELAY_CNT*/, 00/*SR_MS_MOVE_PATTERN_CNT*/, 00,00/*SR_MS_MOVE_PATTERN_POINTER*/ 
enSprite5
	DB 24/*SR_MS_SPRITE_ID*/, 00,00/*SR_MS_DB_POINTER*/, 00,00/*SR_MS_X*/, 00/*SR_MS_Y*/, SR_MS_STATE_RIGHT_MASK/*SR_MS_STATE*/, 00/*SR_MS_NEXT*/
	DB 00/*SR_MS_REMAINING*/, 04/*SR_MS_MOVE_DELAY*/, 00/*SR_MS_MOVE_DELAY_CNT*/, 00/*SR_MS_MOVE_PATTERN_CNT*/, 00,00/*SR_MS_MOVE_PATTERN_POINTER*/ 
enSprite6
	DB 25/*SR_MS_SPRITE_ID*/, 00,00/*SR_MS_DB_POINTER*/, 00,00/*SR_MS_X*/, 00/*SR_MS_Y*/, SR_MS_STATE_LEFT_MASK/*SR_MS_STATE*/, 00/*SR_MS_NEXT*/
	DB 00/*SR_MS_REMAINING*/, 05/*SR_MS_MOVE_DELAY*/, 00/*SR_MS_MOVE_DELAY_CNT*/, 00/*SR_MS_MOVE_PATTERN_CNT*/, 00,00/*SR_MS_MOVE_PATTERN_POINTER*/ 
enSprite7
	DB 26/*SR_MS_SPRITE_ID*/, 00,00/*SR_MS_DB_POINTER*/, 00,00/*SR_MS_X*/, 00/*SR_MS_Y*/, SR_MS_STATE_RIGHT_MASK/*SR_MS_STATE*/, 00/*SR_MS_NEXT*/
	DB 00/*SR_MS_REMAINING*/, 00/*SR_MS_MOVE_DELAY*/, 00/*SR_MS_MOVE_DELAY_CNT*/, 00/*SR_MS_MOVE_PATTERN_CNT*/, 00,00/*SR_MS_MOVE_PATTERN_POINTER*/ 
enSprite8
	DB 27/*SR_MS_SPRITE_ID*/, 00,00/*SR_MS_DB_POINTER*/, 00,00/*SR_MS_X*/, 00/*SR_MS_Y*/, SR_MS_STATE_LEFT_MASK/*SR_MS_STATE*/, 00/*SR_MS_NEXT*/
	DB 00/*SR_MS_REMAINING*/, 02/*SR_MS_MOVE_DELAY*/, 00/*SR_MS_MOVE_DELAY_CNT*/, 00/*SR_MS_MOVE_PATTERN_CNT*/, 00,00/*SR_MS_MOVE_PATTERN_POINTER*/ 
enSprite9
	DB 28/*SR_MS_SPRITE_ID*/, 00,00/*SR_MS_DB_POINTER*/, 00,00/*SR_MS_X*/, 00/*SR_MS_Y*/, SR_MS_STATE_RIGHT_MASK/*SR_MS_STATE*/, 00/*SR_MS_NEXT*/
	DB 00/*SR_MS_REMAINING*/, 02/*SR_MS_MOVE_DELAY*/, 00/*SR_MS_MOVE_DELAY_CNT*/, 00/*SR_MS_MOVE_PATTERN_CNT*/, 00,00/*SR_MS_MOVE_PATTERN_POINTER*/ 
enSprite10
	DB 29/*SR_MS_SPRITE_ID*/, 00,00/*SR_MS_DB_POINTER*/, 00,00/*SR_MS_X*/, 00/*SR_MS_Y*/, SR_MS_STATE_RIGHT_MASK/*SR_MS_STATE*/, 00/*SR_MS_NEXT*/
	DB 00/*SR_MS_REMAINING*/, 02/*SR_MS_MOVE_DELAY*/, 00/*SR_MS_MOVE_DELAY_CNT*/, 00/*SR_MS_MOVE_PATTERN_CNT*/, 00,00/*SR_MS_MOVE_PATTERN_POINTER*/ 

enSpritesSize				DB 10				; The maximum amount of visible enemies			
EN_SPRITE_HEIGHT_PLATFORM	= 3

EN_SPRITE_HEIGHT_WEAPON		= 8
EN_SPRITE_WIDTH_WEAPON		= 8

;----------------------------------------------------------;
;                      #EnRespown                          ;
;----------------------------------------------------------;
EnRespown
	; Increment respawn timer and exit function if it's not time to respawn a new enemy
	LD A, (enRespownDelay)
	LD B, A
	LD A, (enRespownTimer)
	INC A
	CP B
	JR Z, .startRespown							; Jump if the timer reaches respawn delay
	LD (enRespownTimer), A
	RET
.startRespown	
	LD A, 0
	LD (enRespownTimer), A						; Reset timer

	; It would be the time to respawn the enemy. However, to archive random respawn time, we will respawn only when the loop counter 
	; is within the Y coordinate, where movement is allowed:  #SC_Y_MIN_POS < Y < #SC_Y_MAX_POS
	LD A, (gmLoopCnt)

	CP SC_Y_MIN_POS
	RET C										; Return if Y is below game screen

	CP SC_Y_MAX_POS
	RET NC										; Return if Y is above game screen

	; Iterate over all enemies
	LD IX, enSprite	
	LD A, (enSpritesSize)
	LD B, A 
.loop
	PUSH BC										; Preserve B for loop counter
	
	LD A, (IX + SR_MS_STATE)
	AND SR_MS_STATE_VISIBLE						; Reset all bits but visibility
	CP SR_MS_STATE_VISIBLE
	JR Z, .continue								; Skipp this sprite if it's already visible

	; Sprite is hidden - respawn it!

	; Mark sprite as visible
	LD A, (IX + SR_MS_STATE)
	CALL SrShowSprite

	; Reset delay counter
	LD A, 0
	LD A, (IX + SR_MS_MOVE_DELAY_CNT)

	; Set Y (horizontal respown) to a random value
	LD A, (gmLoopCnt)
	LD (IX + SR_MS_Y), A
	
	; Set X to left or right side of the screen
	LD A, (IX + SR_MS_STATE)
	AND SR_MS_STATE_RIGHT_MASK
	CP SR_MS_STATE_RIGHT_MASK
	JR NZ, .left
	LD BC, SC_X_MAX_POS
	JR .afterLR
.left	
	LD BC, SC_X_MIN_POS
.afterLR
	LD (IX + SR_MS_X), BC

	; Setup sprite
	CALL SrSetSpriteId							; Set the ID of the sprite for the following commands

	; Set sprite pattern
	LD A, SR_SDB_COMET1
	CALL SrSetSpritePattern

	CALL SrUpdateSpritePosition					; Set X, Y and rotation
	CALL SrUpdateSpritePattern					; Render sprite

	; Exit after respawning first enemy
	POP BC
	RET											
.continue
	; Move IX to the beginning of the next #jwSpriteXX
	LD DE, SR_MS_SIZE
	ADD IX, DE
	POP BC
	DJNZ .loop									; Jump if B > 0 (loop starts with B = #enSpritesSize)

	RET

;----------------------------------------------------------;
;                 #EnAnimateEnemies                        ;
;----------------------------------------------------------;
EnAnimateEnemies
	 
	; Animate shots
	LD IX, enSprite	
	LD A, (enSpritesSize)
	LD B, A 
	CALL SrAnimateSprites

	RET	

;----------------------------------------------------------;
;                     #EnWeaponHit                         ;
;----------------------------------------------------------;
EnWeaponHit
	LD IX, enSprite
	LD L, EN_SPRITE_HEIGHT_WEAPON
	LD H, EN_SPRITE_WIDTH_WEAPON
	LD A, (enSpritesSize)
	LD B, A
	CALL SrWeaponHit
	RET	

;----------------------------------------------------------;
;                      #EnMoveEnemies                      ;
;----------------------------------------------------------;
; Modifies: ALL
EnMoveEnemies
	; Loop ever al enemies skipping hidden 
	LD IX, enSprite	
	LD A, (enSpritesSize)
	LD B, A 
.loop
	PUSH BC										; Preserve B for loop counter

	; Ignore this sprite if it's hidden
	LD A, (IX + SR_MS_STATE)
	AND SR_MS_STATE_VISIBLE						; Reset all bits but visibility
	CP 0
	JR Z, .continue								; Jump if visibility is not set (sprite is hidden)

	; Slow down movement by incrementing the counter until it reaches the configured value
	LD A, (IX + SR_MS_MOVE_DELAY)
	CP 0										; No delay? -> move at full speed
	JR Z, .afterDelayMove

	LD B, A										; Load goal for delay counter into B

	; Delaying movement, increment delay counter
	LD A, (IX + SR_MS_MOVE_DELAY_CNT)
	INC A
	LD (IX + SR_MS_MOVE_DELAY_CNT), A

	CP B
	JR NZ, .continue							; Return if the delay counter does not reach the required value.

	LD A, 0										; Reset the movement delay counter because it has reached the configured value
	LD (IX + SR_MS_MOVE_DELAY_CNT), A

.afterDelayMove

	; Sprite is visible, move it!
	CALL SrSetSpriteId							; Set the ID of the sprite for the following commands

	LD A, (IX + SR_MS_STATE)
	AND SR_MS_STATE_RIGHT_MASK					; Reset all bits but right
	CP SR_MS_STATE_RIGHT_MASK
	JR NZ, .afterMovingLeft						; Jump if moving right

	; Moving left - decrease X coordinate
	LD BC, (IX + SR_MS_X)	
	DEC BC

	; Check whether a enemy is outside the screen 
	LD A, B
	CP SC_X_MIN_POS								; B holds MSB from X, if B > 0 than X > 256
	JR NZ, .afterMoving
	LD A, C
	CP SC_X_MIN_POS + 5							; C holds LSB from X, ff C != 5 then X is> 5
	JR NC, .afterMoving

	; X == 0 (both A and B are 0) -> enemy out of screen - hide it
	CALL SrHideSprite
	JR .continue	

.afterMovingLeft

	; Moving right - increase X coordinate
	LD BC, (IX + SR_MS_X)	
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
	CALL SrHideSprite
	JR .continue
.afterMoving
	LD (IX + SR_MS_X), BC						; Update new X position
	CALL SrUpdateSpritePosition

	; Check the collision with the platform
	PUSH BC
	LD IY, jpPlatformBump
	LD L, EN_SPRITE_HEIGHT_PLATFORM
	CALL SrPlaftormColision
	POP BC

.continue
	; Move IX to the beginning of the next #jwSpriteXX
	LD DE, SR_MS_SIZE
	ADD IX, DE
	POP BC
	DJNZ .loop									; Jump if B > 0 (loop starts with B = #SR_MS_SIZE)

	RET	