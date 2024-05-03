;----------------------------------------------------------;
;                    Flying Enemy 01                       ;
;----------------------------------------------------------;
; A simple enemy that flies horizontally from the left screen side to the right or otherwise.
; Hitting the ground or platform causes an explosion.

; The timer ticks with every game loop. When it reaches #EA_RESPOWN_DELAY, a single enemy will respawn, and the timer starts from 0, counting again.
eaRespownTimer
	DB 0

EA_RESPOWN_DELAY			= 100				; Amount of game loops to respawn single enemy

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