;----------------------------------------------------------;
;                      Jetman Weapon                       ;
;----------------------------------------------------------;

; Sprites for single shots (#jwShot), based on "Memory Structure for Single Sprite" from "sr_simple_sprite.asm"
;
; Possible values for #SR_MS_STATE
; Bits:
;   - 0: 	Visible flag, 1 = displayed, 0 = hidden (reserved in sr_simple_sprite.asm)
;   - 1: 	1 = shot moving left, 0 = shot moving right
;   - 2-7: 	Not used

JW_MS_STATE_DIRECTION_BIT		= 1

JW_MS_STATE_LEFT_MASK			= %00000010
JW_MS_STATE_LEFT_VAL			= 1

JW_MS_STATE_RIGHT_MASK			= %00000000
JW_MS_STATE_RIGHT_VAL			= 0

JW_MS_STATE_LEFT				= 1
JW_MS_STATE_LEFT				= 1

; Adjustment to place the first laser beam next to Jetman so that it looks like it has been fired from the laser gun.
JW_ADJUST_FIRE_X				= 10			
JW_ADJUST_FIRE_Y				= 4

jwShot
	WORD 0
	DB 0, 0, 10, SR_SDB_FIRE, 0, 0
	WORD 0
jwShot2
	WORD 0
	DB 0, 0, 11, SR_SDB_FIRE, 0, 0
	WORD 0
jwShot3
	WORD 0
	DB 0, 0, 12, SR_SDB_FIRE, 0, 0
	WORD 0
jwShot4
	WORD 0
	DB 0, 0, 13, SR_SDB_FIRE, 0, 0
	WORD 0
jwShot5
	WORD 0
	DB 0, 0, 14, SR_SDB_FIRE, 0, 0
	WORD 0
jwShot6
	WORD 0
	DB 0, 0, 15, SR_SDB_FIRE, 0, 0
	WORD 0						

; The counter is increased with each animation frame and reset when the fire is pressed. Fire can only be pressed when the counter reaches #JW_FIRE_DELAY
jwShotDelayCnt
	DB 0

JW_FIRE_DELAY					= 3

JW_SHOT_SIZE					= 6				; Amount of shots that can be simultaneously fired
JW_SHOT_INC_X					= 3				; The amount of pixels to move a single shot horizontally on a single frame

;----------------------------------------------------------;
;                    #JwMoveShots                          ;
;----------------------------------------------------------;
JwMoveShots
	; Loop ever all jwShot# skipping hidden sprites
	LD IX, jwShot	
	LD B, JW_SHOT_SIZE 

.loop
	PUSH BC										; Preserve B for loop counter

	LD A, (IX + SR_MS_STATE)
	AND SR_MS_STATE_VISIBLE						; Reset all bits but visibility
	CP 0
	JR Z, .continue								; Jump if visibility is not set -> hidden, can be reused
	; Shot is visible

	CALL SrSetSpriteId							; Set the ID of the sprite for the following commands

	LD A, (IX + SR_MS_STATE)
	AND JW_MS_STATE_LEFT_MASK					; Reset all bits but left
	CP JW_MS_STATE_LEFT_MASK
	JR NZ, .afterMovingLeft						; Jump if moving right

	; Moving left - decrease X coordinate
	LD BC, (IX + SR_MS_X)	
	ADD BC, -JW_SHOT_INC_X

	; Check whether a shot is outside the screen 
	LD A, B
	CP SC_X_MIN_POS								; If B > 0 then X is also > 0
	JR NZ, .afterMoving
	LD A, C
	CP SC_X_MIN_POS + 2 * JW_SHOT_INC_X			; If C > 0 then X is also > 0
	JR NC, .afterMoving
	; X == 0 (both A and B are 0) -> shot out of screen - hide it
	CALL SrHideSprite
	JR .continue	

.afterMovingLeft

	; Moving right - increase X coordinate
	LD BC, (IX + SR_MS_X)	
	ADD BC, JW_SHOT_INC_X
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
	; Move HL to the beginning of the next #jwShotX
	LD DE, SR_MS_SIZE
	ADD IX, DE
	POP BC
	DJNZ .loop									; Jump if B > 0 (starts with B = #SR_MS_SIZE)

	RET 										; END #JwMoveShots

;----------------------------------------------------------;
;                  #JwAnimateShots                         ;
;----------------------------------------------------------;
JwAnimateShots
	; Increase shot counter
	LD A, (jwShotDelayCnt)
	CP A, JW_FIRE_DELAY
	JR NC, .afterIncDelay						; Do increase the delay counter when it has reached the required value
	INC A
	LD (jwShotDelayCnt), A
.afterIncDelay
	 
	; Loop ever all jwShot# skipping hidden sprites
	LD IX, jwShot	
	LD B, JW_SHOT_SIZE 

.loop
	PUSH BC										; Preserve B for loop counter

	LD A, (IX + SR_MS_STATE)
	AND SR_MS_STATE_VISIBLE						; Reset all bits but visibility
	CP 0
	JR Z, .continue								; Jump if visibility is not set -> hidden, can be reused
	; Shot is visible


	CALL SrSetSpriteId							; Set the ID of the sprite for the following commands
	CALL SrUpdateSpritePattern

.continue
	; Move HL to the beginning of the next #jwShotX
	LD DE, SR_MS_SIZE
	ADD IX, DE
	POP BC
	DJNZ .loop									; Jump if B > 0 (starts with B = #SR_MS_SIZE)

	RET											; END #JwAnimateShots

;----------------------------------------------------------;
;                        #JwFire                           ;
;----------------------------------------------------------;
JwFire

	; Check delay to limit fire speed
	LD A, (jwShotDelayCnt)
	CP JW_FIRE_DELAY
	RET C										; Return if the delay counter did not reach the defined value
	; we can fire, reset counter
	LD A, 0
	LD (jwShotDelayCnt), A

	; Find the first inactive (sprite hidden) shot
	LD IX, jwShot
	LD DE, SR_MS_SIZE
	LD B, JW_SHOT_SIZE 
.findLoop

	; Check whether the current #jwShotX is not visible and can be reused
	LD A, (IX + SR_MS_STATE)
	AND SR_MS_STATE_VISIBLE						; Reset all bits but visibility
	CP 0
	JR Z, .afterFound							; Jump if visibility is not set -> hidden, can be reused

	; Move HL to the beginning of the next #jwShotX (see "LD DE, SR_MS_SIZE" above)
	ADD IX, DE
	DJNZ .findLoop								; Jump if B > 0 (starts with B = #SR_MS_SIZE)
	RET											; Loop has ended without finding free #jwShotX

.afterFound										
	; We are here because free #jwShotX has been found, and IX points to it

	; Set sprite flags
	LD A, SR_MS_STATE_VISIBLE					; Sprite is visible
	LD B, A										; Store A in B terporarly

	; Take over direction from Jetman to laser beam 

	; Is Jetman moving left?
	LD A, (joJetmanDirection)
	AND JO_MOVE_LEFT_MASK						
	CP JO_MOVE_LEFT_MASK
	JR Z, .afterMovingRight						; Jump if Jetman is not moving right
	; Jetman is moving right
	LD A, B										; Restore A
	RES JW_MS_STATE_DIRECTION_BIT, A

	; Set X coordinate for laser beam
	LD HL, (jtX)
	ADD HL, JW_ADJUST_FIRE_X
	LD (IX + SR_MS_X), HL

	JR .afterMoving
.afterMovingRight
	; Jetman is moving left

	; Set X coordinate for laser beam
	LD HL, (jtX)
	ADD HL, -JW_ADJUST_FIRE_X
	LD (IX + SR_MS_X), HL

	LD A, B										; Restore A
	SET JW_MS_STATE_DIRECTION_BIT, A

.afterMoving
	LD (IX + SR_MS_STATE), A					; Store state

	; Set Y coordinate for laser beam
	LD A, (jtY)
	ADD A, JW_ADJUST_FIRE_Y
	LD (IX + SR_MS_Y), A

	; Setup laser beam pattern, IX already points to the right memory address
	CALL SrSetSpriteId							; Set the ID of the sprite for the following commands

	LD A, SR_SDB_FIRE
	CALL SrSetSpritePattern						; Set sprite pattern to laser beam

	CALL SrUpdateSpritePosition					; Set X, Y position for laser beam
	CALL SrUpdateSpritePattern					; Render laser beam

	RET											; END #JoPressFire