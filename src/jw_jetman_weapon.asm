;----------------------------------------------------------;
;                      Jetman Weapon                       ;
;----------------------------------------------------------;

; Adjustment to place the first laser beam next to Jetman so that it looks like it has been fired from the laser gun.
JW_ADJUST_FIRE_X				= 10			
JW_ADJUST_FIRE_Y				= 4

; Sprites for single shots (#jwSprite), based on "Memory Structure for Single Sprite" from "sr_simple_sprite.asm"
jwSprite
	WORD 0
	DB 0, 0, 10, 0, 0, 0
	WORD 0
jwSprite2
	WORD 0
	DB 0, 0, 11, 0, 0, 0
	WORD 0
jwSprite3
	WORD 0
	DB 0, 0, 12, 0, 0, 0
	WORD 0
jwSprite4
	WORD 0
	DB 0, 0, 13, 0, 0, 0
	WORD 0
jwSprite5
	WORD 0
	DB 0, 0, 14, 0, 0, 0
	WORD 0
jwSprite6
	WORD 0
	DB 0, 0, 15, 0, 0, 0
	WORD 0						

; The counter is increased with each animation frame and reset when the fire is pressed. Fire can only be pressed when the counter reaches #JW_FIRE_DELAY
jwSpriteDelayCnt
	DB 0

JW_FIRE_DELAY					= 3
JW_SHOT_SIZE					= 6				; Amount of shots that can be simultaneously fired

; We are using platform coordinates for bumping, which are too thick for the thin shot
JW_PLATFROM_MARGIN_UP			= 12
JW_PLATFROM_MARGIN_DOWN			= 5

;----------------------------------------------------------;
;                    #JwMoveShots                          ;
;----------------------------------------------------------;
; Modifies: ALL
JwMoveShots
	; Loop ever all jwSprite# skipping hidden sprites
	LD IX, jwSprite	
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
	AND SR_MS_STATE_RIGHT_MASK					; Reset all bits but right
	CP SR_MS_STATE_RIGHT_MASK
	JR Z, .afterMovingLeft						; Jump if moving right

	; Moving left - decrease X coordinate
	LD BC, (IX + SR_MS_X)	
	DEC BC

	; Check the collision with the platform from the left side
	PUSH BC
	LD IY, jpPlatformBump						; Jetman faces left, the shot can hit platform from the right
	LD H, JT_AIR_BUMP_RIGHT
	CALL JwHitPlaftormLR
	POP BC

	; Check whether a shot is outside the screen 
	LD A, B
	CP SC_X_MIN_POS								; B holds MSB from X, if B > 0 than X > 256
	JR NZ, .afterMoving
	LD A, C
	CP SC_X_MIN_POS + 5							; C holds LSB from X, ff C != 5 then X is> 5
	JR NC, .afterMoving
	; X == 0 (both A and B are 0) -> shot out of screen - hide it
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
	CALL JwHitPlaftormLR
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

;----------------------------------------------------------;
;                  #JwHitPlaftormLR                        ;
;----------------------------------------------------------;
; A shot can hit platform from left or right
; Input
;  - IX: 	#jwSpriteXX - shot data
;  - IY:	jpPlatformBump
;  - H: 	JT_AIR_BUMP_LEFT or JT_AIR_BUMP_RIGHT
; Modifies: ALL
JwHitPlaftormLR

	LD B, (IY)									; Load into B the number of platforms to check
.platformsLoop	

	; Check whether we should consider the left or right side of the platform.
	LD A, H										; A holds JT_AIR_BUMP_LEFT or JT_AIR_BUMP_RIGHT
	CP JT_AIR_BUMP_LEFT
	JR Z, .bumpLeft

	; We will check whether Jetman bumps into the platform from the right
	INC IY										; HL points to [X start]
	INC IY										; HL points to [X end]
	LD C, (IY)									; C contains [X end]
	JR .afterBumpSideCheck
.bumpLeft	
	; We will check whether Jetman bumps into the platform from the left
	INC IY										; HL points to [X start]
	LD C, (IY)									; C contains [X start]
	INC IY										; Moving the pointer to the correct position for further reading
.afterBumpSideCheck

	INC IY										; HL points to [Y start]
	LD A, (IY)	
	ADD JW_PLATFROM_MARGIN_UP					; Increase start Y to make platform thinner
	LD D, A										; D contains [Y start]								

	INC IY										; HL points to [Y end]
	LD A, (IY)
	SUB JW_PLATFROM_MARGIN_DOWN					; Decrease end Y to make the platform thinner
	LD E, A										; E contains [Y end]

	LD A, (IX + SR_MS_X)						; A holds shot current X position (only LSB, platrofrm are limited to X <= 255)
	CP C

	JR NZ, .platformsLoopEnd					; Jump if shot is not close to the let/right edge of the platform

	; Shot is close to the let/right edge of the platform. Now, check whether it's within vertical bounds
	LD A, (IX + SR_MS_Y)						; A holds current shot Y position
	
	CP D										; Compare shot position to [Y start]
	JR C, .platformsLoopEnd						; Jump if shot < [Y start]

	CP E
	JR NC, .platformsLoopEnd					; Jump if shot > [Y end]

	; Shot hits the platform from the let/right!
	PUSH BC
	CALL SrSetSpriteId
	LD A, SR_SDB_EXPLODE
	CALL SrSetSpritePattern						; shot expoldes
	POP BC

.platformsLoopEnd
	DJNZ .platformsLoop							; Decrease B until all platforms have been evaluated
	RET

;----------------------------------------------------------;
;                  #JwAnimateShots                         ;
;----------------------------------------------------------;
JwAnimateShots
	; Increase shot counter
	LD A, (jwSpriteDelayCnt)
	CP A, JW_FIRE_DELAY
	JR NC, .afterIncDelay						; Do increase the delay counter when it has reached the required value
	INC A
	LD (jwSpriteDelayCnt), A
.afterIncDelay
	 
	; Loop ever all jwSprite# skipping hidden sprites
	LD IX, jwSprite	
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
	; Move HL to the beginning of the next #jwSpriteX
	LD DE, SR_MS_SIZE
	ADD IX, DE
	POP BC
	DJNZ .loop									; Jump if B > 0 (starts with B = #SR_MS_SIZE)

	RET

;----------------------------------------------------------;
;                        #JwFire                           ;
;----------------------------------------------------------;
JwFire

	; Check delay to limit fire speed
	LD A, (jwSpriteDelayCnt)
	CP JW_FIRE_DELAY
	RET C										; Return if the delay counter did not reach the defined value
	; we can fire, reset counter
	LD A, 0
	LD (jwSpriteDelayCnt), A

	; Find the first inactive (sprite hidden) shot
	LD IX, jwSprite
	LD DE, SR_MS_SIZE
	LD B, JW_SHOT_SIZE 
.findLoop

	; Check whether the current #jwSpriteX is not visible and can be reused
	LD A, (IX + SR_MS_STATE)
	AND SR_MS_STATE_VISIBLE						; Reset all bits but visibility
	CP 0
	JR Z, .afterFound							; Jump if visibility is not set -> hidden, can be reused

	; Move HL to the beginning of the next #jwSpriteX (see "LD DE, SR_MS_SIZE" above)
	ADD IX, DE
	DJNZ .findLoop								; Jump if B > 0 (starts with B = #SR_MS_SIZE)
	RET											; Loop has ended without finding free #jwSpriteX

.afterFound										
	; We are here because free #jwSpriteX has been found, and IX points to it

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
	SET SR_MS_STATE_DIRECTION_BIT, A

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
	RES SR_MS_STATE_DIRECTION_BIT, A

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

	RET