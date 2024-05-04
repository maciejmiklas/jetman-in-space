;----------------------------------------------------------;
;                    Flying Enemy 01                       ;
;----------------------------------------------------------;
; A simple enemy that flies horizontally from the left screen side to the right or otherwise.
; Hitting the ground or platform causes an explosion.

; The timer ticks with every game loop. When it reaches #EA_RESPOWN_DELAY, a single enemy will respawn, and the timer starts from 0, counting again.
eaRespownTimer
	DB 0

EA_RESPOWN_DELAY			= 20				; Amount of game loops to respawn single enemy

; Sprites for single enemy (#eaSprite), based on "Memory Structure for Single Sprite" from "sr_simple_sprite.asm"
; Each sprite has hardcoded respawn coordinates and the direction in which it moves
eaSprite
	WORD 0
	DB 0, SR_MS_STATE_LEFT_MASK, 20, 0, 0, 0
	WORD 0
eaSprite2
	WORD 0
	DB 0, SR_MS_STATE_RIGHT_MASK, 22, 0, 0, 0
	WORD 0
eaSprite3
	WORD 0
	DB 0, SR_MS_STATE_LEFT_MASK, 23, 0, 0, 0
	WORD 0
eaSprite4
	WORD 0
	DB 0, SR_MS_STATE_RIGHT_MASK, 24, 0, 0, 0
	WORD 0
eaSprite5
	WORD 0
	DB 0, SR_MS_STATE_LEFT_MASK, 25, 0, 0, 0
	WORD 0
eaSprite6
	WORD 0
	DB 0, SR_MS_STATE_RIGHT_MASK, 26, 0, 0, 0
	WORD 0
eaSprite7
	WORD 0
	DB 0, SR_MS_STATE_LEFT_MASK, 27, 0, 0, 0
	WORD 0						
eaSprite8
	WORD 0
	DB 0, SR_MS_STATE_RIGHT_MASK, 28, 0, 0, 0
	WORD 0
eaSprite9
	WORD 0
	DB 0, SR_MS_STATE_RIGHT_MASK, 29, 0, 0, 0
	WORD 0
eaSprite10
	WORD 0
	DB 0, SR_MS_STATE_LEFT_MASK, 30, 0, 0, 0
	WORD 0	

EA_SPRITES_SIZE				= 10				; The maximum amount of visible enemies			
EA_SPRITE_HEIGHT_PLATFORM	= 3

EA_SPRITE_HEIGHT_WEAPON		= 8
EA_SPRITE_WIDTH_WEAPON		= 8

EA_MOVE_DELAY				= 2					; Number of game loops to delay movement  
esMoveDelayCnt				BYTE 0				; The delay counter for enemy movement

;----------------------------------------------------------;
;                      #EaRespown                          ;
;----------------------------------------------------------;
EaRespown
	; Increment respawn timer and exit function if it's not time to respawn a new enemy
	LD A, (eaRespownTimer)
	INC A
	CP EA_RESPOWN_DELAY
	JR Z, .startRespown							; Jump if the timer reaches respawn delay
	LD (eaRespownTimer), A
	RET
.startRespown	
	LD A, 0
	LD (eaRespownTimer), A						; Reset timer

	; It would be the time to respawn the enemy. However, to archive random respawn time, we will respawn only when the loop counter 
	; is within the Y coordinate, where movement is allowed:  #SC_Y_MIN_POS < Y < #SC_Y_MAX_POS
	LD A, (gmLoopCnt)

	CP SC_Y_MIN_POS
	RET C										; Return if Y is below game screen

	CP SC_Y_MAX_POS
	RET NC										; Return if Y is above game screen

	; Find the first hidden enemy and show it
	LD IX, eaSprite	
	LD B, EA_SPRITES_SIZE 
.loop
	PUSH BC										; Preserve B for loop counter
	
	LD A, (IX + SR_MS_STATE)
	AND SR_MS_STATE_VISIBLE						; Reset all bits but visibility
	CP SR_MS_STATE_VISIBLE
	JR Z, .continue								; Skipp this sprite if it's already visible

	; Sprite is hidden - respawn it!

	; Mark sprite as visible
	LD A, (IX + SR_MS_STATE)					
	SET SR_MS_STATE_VISIBLE_BIT, A
	LD (IX + SR_MS_STATE), A

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
	DJNZ .loop									; Jump if B > 0 (loop starts with B = #EA_SPRITES_SIZE)

	RET

;----------------------------------------------------------;
;                 #EaAnimateEnemies                        ;
;----------------------------------------------------------;
EaAnimateEnemies
	 
	; Animate shots
	LD IX, eaSprite	
	LD B, EA_SPRITES_SIZE 
	CALL SrAnimateSprites

	RET	

;----------------------------------------------------------;
;                     #EaWeaponHit                         ;
;----------------------------------------------------------;
EaWeaponHit
	LD IX, eaSprite
	LD L, EA_SPRITE_HEIGHT_WEAPON
	LD H, EA_SPRITE_WIDTH_WEAPON
	LD B, EA_SPRITES_SIZE
	CALL SrWeaponHit
	RET	

;----------------------------------------------------------;
;                      #EaMoveEnemies                      ;
;----------------------------------------------------------;
; Modifies: ALL
EaMoveEnemies

	; Slow down movement
	LD A, (esMoveDelayCnt)
	INC A
	LD (esMoveDelayCnt), A

	CP EA_MOVE_DELAY
	RET C										; Return if #joDelayCnt <  #JO_JOY_DELAY

	LD A, 0										; Reset delay counter
	LD (esMoveDelayCnt), A

	; Loop ever al enemies skipping hidden 
	LD IX, eaSprite	
	LD B, EA_SPRITES_SIZE 

.loop
	PUSH BC										; Preserve B for loop counter

	LD A, (IX + SR_MS_STATE)
	AND SR_MS_STATE_VISIBLE						; Reset all bits but visibility
	CP 0
	JR Z, .continue								; Jump if visibility is not set (sprite is hidden)

	; Sprite is visible
	CALL SrSetSpriteId							; Set the ID of the sprite for the following commands

	LD A, (IX + SR_MS_STATE)
	AND SR_MS_STATE_RIGHT_MASK					; Reset all bits but right
	CP SR_MS_STATE_RIGHT_MASK
	JR NZ, .afterMovingLeft						; Jump if moving right

	; Moving left - decrease X coordinate
	LD BC, (IX + SR_MS_X)	
	DEC BC

	; Check the collision with the platform from the left side
	
	PUSH BC
	LD IY, jpPlatformBump						; Jetman faces left, the shot can hit platform from the right
	LD H, JT_AIR_BUMP_RIGHT
	LD L, EA_SPRITE_HEIGHT_PLATFORM
	CALL SrPlaftormColision
	POP BC

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


	; Check the collision with the platform from the right side
	PUSH BC
	LD IY, jpPlatformBump					; Jetman faces rgiht, the shot can hit platform from the left
	LD H, JT_AIR_BUMP_LEFT
	LD L, EA_SPRITE_HEIGHT_PLATFORM
	CALL SrPlaftormColision
	POP BC

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

.continue
	; Move IX to the beginning of the next #jwSpriteXX
	LD DE, SR_MS_SIZE
	ADD IX, DE
	POP BC
	DJNZ .loop									; Jump if B > 0 (loop starts with B = #SR_MS_SIZE)

	RET	