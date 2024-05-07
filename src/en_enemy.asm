;----------------------------------------------------------;
;                     Flying Enemy                         ;
;----------------------------------------------------------;

; The timer ticks with every game loop. When it reaches #EN_RESPOWN_DELAY, a single enemy will respawn, and the timer starts from 0, counting again.
enRespownTimer DB 0
enRespownDelay DB 20						; Amount of game loops to respawn single enemy

; Sprites for single enemy (#enSprite), based on "Memory Structure for Single Sprite" from "sr_simple_sprite.asm"
; Each sprite has hardcoded respawn coordinates and the direction in which it moves
enSprite
	WORD 00, 00
	DB 00, SR_MS_STATE_LEFT_MASK,	20, 00, 00, 00, 00, 00, 00, 00
enSprite2
	WORD 00, 00
	DB 00, SR_MS_STATE_RIGHT_MASK,	22, 00, 00, 00, 01, 00, 00, 00
enSprite3
	WORD 00, 00
	DB 00, SR_MS_STATE_LEFT_MASK,	23, 00, 00, 00, 02, 00, 00, 00
enSprite4
	WORD 00, 00
	DB 00, SR_MS_STATE_RIGHT_MASK,	24, 00, 00, 00, 03, 00, 00, 00
enSprite5
	WORD 00, 00
	DB 00, SR_MS_STATE_LEFT_MASK,	25, 00, 00, 00, 04, 00, 00, 00
enSprite6
	WORD 00, 00
	DB 00, SR_MS_STATE_RIGHT_MASK,	26, 00, 00, 00, 05, 00, 00, 00
enSprite7
	WORD 00, 00
	DB 00, SR_MS_STATE_LEFT_MASK,	27, 00, 00, 00, 02, 00, 00, 00
enSprite8
	WORD 00, 00
	DB 00, SR_MS_STATE_RIGHT_MASK,	28, 00, 00, 00, 02, 00, 00, 00
enSprite9
	WORD 00, 00
	DB 00, SR_MS_STATE_RIGHT_MASK,	29, 00, 00, 00, 02, 00, 00, 00
enSprite10
	WORD 00, 00
	DB 00, SR_MS_STATE_LEFT_MASK,	30, 00, 00, 00, 02, 00, 00, 00

EN_SPRITES_SIZE				= 10				; The maximum amount of visible enemies			
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
	LD B, EN_SPRITES_SIZE 
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
	DJNZ .loop									; Jump if B > 0 (loop starts with B = #EN_SPRITES_SIZE)

	RET

;----------------------------------------------------------;
;                 #EnAnimateEnemies                        ;
;----------------------------------------------------------;
EnAnimateEnemies
	 
	; Animate shots
	LD IX, enSprite	
	LD B, EN_SPRITES_SIZE 
	CALL SrAnimateSprites

	RET	

;----------------------------------------------------------;
;                     #EnWeaponHit                         ;
;----------------------------------------------------------;
EnWeaponHit
	LD IX, enSprite
	LD L, EN_SPRITE_HEIGHT_WEAPON
	LD H, EN_SPRITE_WIDTH_WEAPON
	LD B, EN_SPRITES_SIZE
	CALL SrWeaponHit
	RET	

;----------------------------------------------------------;
;                      #EnMoveEnemies                      ;
;----------------------------------------------------------;
; Modifies: ALL
EnMoveEnemies
	; Loop ever al enemies skipping hidden 
	LD IX, enSprite	
	LD B, EN_SPRITES_SIZE 
.loop
	PUSH BC										; Preserve B for loop counter

	; Slow down movement
	LD A, (IX + SR_MS_MOVE_DELAY)
	LD B, A										; Load goal for delay counter into B
	
	CP 0										; No delay? -> move with full speed
	JR Z, .afterDelayMove

	LD A, (IX + SR_MS_MOVE_DELAY_CNT)
	INC A
	LD (IX + SR_MS_MOVE_DELAY_CNT), A

	CP B
	JR NZ, .continue							; Return if the delay counter does not reach the required value.

	LD A, 0										; Reset movement delay counter
	LD (IX + SR_MS_MOVE_DELAY_CNT), A


	LD A, (IX + SR_MS_STATE)
	AND SR_MS_STATE_VISIBLE						; Reset all bits but visibility
	CP 0
	JR Z, .continue								; Jump if visibility is not set (sprite is hidden)
.afterDelayMove

	; Sprite is visible
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