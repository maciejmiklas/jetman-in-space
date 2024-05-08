;----------------------------------------------------------;
;                      Jetman Weapon                       ;
;----------------------------------------------------------;

; Adjustment to place the first laser beam next to Jetman so that it looks like it has been fired from the laser gun.
JW_ADJUST_FIRE_X				= 10			
JW_ADJUST_FIRE_Y				= 4

; Sprites for single shots (#jwSprite), based on "Memory Structure for Single Sprite" from "sr_simple_sprite.asm"
jwSprite
	DB 10/*SR_MS_SPRITE_ID*/, 00,00/*SR_MS_DB_POINTER*/, 00,00/*SR_MS_X*/, 00/*SR_MS_Y*/, 00/*SR_MS_STATE*/, 00/*SR_MS_NEXT*/
	DB 00/*SR_MS_REMAINING*/, 00/*SR_MS_MOVE_DELAY*/, 00/*SR_MS_MOVE_DELAY_CNT*/, 00/*SR_MS_MOVE_PATTERN_CNT*/, 00,00/*SR_MS_MOVE_PATTERN_POINTER*/ 
jwSprite2
	DB 11/*SR_MS_SPRITE_ID*/, 00,00/*SR_MS_DB_POINTER*/, 00,00/*SR_MS_X*/, 00/*SR_MS_Y*/, 00/*SR_MS_STATE*/, 00/*SR_MS_NEXT*/
	DB 00/*SR_MS_REMAINING*/, 00/*SR_MS_MOVE_DELAY*/, 00/*SR_MS_MOVE_DELAY_CNT*/, 00/*SR_MS_MOVE_PATTERN_CNT*/, 00,00/*SR_MS_MOVE_PATTERN_POINTER*/ 
jwSprite3
	DB 12/*SR_MS_SPRITE_ID*/, 00,00/*SR_MS_DB_POINTER*/, 00,00/*SR_MS_X*/, 00/*SR_MS_Y*/, 00/*SR_MS_STATE*/, 00/*SR_MS_NEXT*/
	DB 00/*SR_MS_REMAINING*/, 00/*SR_MS_MOVE_DELAY*/, 00/*SR_MS_MOVE_DELAY_CNT*/, 00/*SR_MS_MOVE_PATTERN_CNT*/, 00,00/*SR_MS_MOVE_PATTERN_POINTER*/ 
jwSprite4
	DB 13/*SR_MS_SPRITE_ID*/, 00,00/*SR_MS_DB_POINTER*/, 00,00/*SR_MS_X*/, 00/*SR_MS_Y*/, 00/*SR_MS_STATE*/, 00/*SR_MS_NEXT*/
	DB 00/*SR_MS_REMAINING*/, 00/*SR_MS_MOVE_DELAY*/, 00/*SR_MS_MOVE_DELAY_CNT*/, 00/*SR_MS_MOVE_PATTERN_CNT*/, 00,00/*SR_MS_MOVE_PATTERN_POINTER*/ 
jwSprite5
	DB 14/*SR_MS_SPRITE_ID*/, 00,00/*SR_MS_DB_POINTER*/, 00,00/*SR_MS_X*/, 00/*SR_MS_Y*/, 00/*SR_MS_STATE*/, 00/*SR_MS_NEXT*/
	DB 00/*SR_MS_REMAINING*/, 00/*SR_MS_MOVE_DELAY*/, 00/*SR_MS_MOVE_DELAY_CNT*/, 00/*SR_MS_MOVE_PATTERN_CNT*/, 00,00/*SR_MS_MOVE_PATTERN_POINTER*/ 
jwSprite6
	DB 15/*SR_MS_SPRITE_ID*/, 00,00/*SR_MS_DB_POINTER*/, 00,00/*SR_MS_X*/, 00/*SR_MS_Y*/, 00/*SR_MS_STATE*/, 00/*SR_MS_NEXT*/
	DB 00/*SR_MS_REMAINING*/, 00/*SR_MS_MOVE_DELAY*/, 00/*SR_MS_MOVE_DELAY_CNT*/, 00/*SR_MS_MOVE_PATTERN_CNT*/, 00,00/*SR_MS_MOVE_PATTERN_POINTER*/ 

; The counter is increased with each animation frame and reset when the fire is pressed. Fire can only be pressed when the counter reaches #JW_FIRE_DELAY
jwSpriteDelayCnt
	DB 0

JW_FIRE_DELAY					= 3
JW_SHOT_SIZE					= 6				; Amount of shots that can be simultaneously fired

JW_SHOT_HEIGHT					= 0

;----------------------------------------------------------;
;                     #JwHitEnemy                          ;
;----------------------------------------------------------;
; Checks whether a given enemy has been hit by the laser beam and eventually destroys it
; Input:
;  - IX:	Pointer to "Memory Structure for Single Sprite", the enemy to check for hit
;  - H:     Half of the width of the enemy
;  - L:		Half of the height of the enemy
; Modifies: ALL
JwHitEnemy
	; Loop ever all jwSprite# skipping hidden sprites
	LD IY, jwSprite								; IY points to the enemy
	LD B, JW_SHOT_SIZE 

.loop
	PUSH BC										; Preserve B for loop counter

	; Skipp invisible laser shoots
	LD A, (IY + SR_MS_STATE)
	AND SR_MS_STATE_VISIBLE						; Reset all bits but visibility
	CP 0
	JR Z, .continue								; Jump if visibility is not set (sprite is hidden)


	; Skip collision detection if the enemy is not alive - it has hit something already, and it's exploding.
	LD A, (IX + SR_MS_STATE)
	AND SR_MS_STATE_ALIVE						; Reset all bits but alive
	CP SR_MS_STATE_ALIVE
	JR NZ, .continue							; Exit if sprite is not alive
	
	; Shot is visible, check colision with given sprite

	; Compare X coordinate of enemy and shot
	LD BC, (IX + SR_MS_X)						; X of the enemy
	LD DE, (IY + SR_MS_X)						; X of the shot

	LD A, D
	CP B
	JR NZ, .continue							; Jump if MSB of the X for enemy and shot does not match (B != D)

	; Check if the shot hits the enemy from the left side of its X coordinate
	LD A, C										; A holds the X LSB of the enemy
	SUB H										; Include the thickness of the enemy
	CP E
	JR NC, .continue							; Jump if "(C - L) >= E" -> "(Xenemy - L) >= Xshot"  -> shot is before the enemy, left of it

	; Check if the shot hits the enemy from the right side of its X coordinate
	ADD H										; Revert "SUB L" from above
	ADD H										; Include the thickness of the enemy
	CP E
	JR C, .continue								; Jump if "(C + L) < E" -> "(Xenemy + L) < Xshot"  -> shot is after the enemy, right of it

	; We are here because the shot is horizontal with the enemy, now check the vertical match
	LD A, (IX + SR_MS_Y)						; A holds Y from the enemy
	LD B, (IY + SR_MS_Y)						; B holds Y from the laser beam

	; Check upper bounds
	SUB L										; Include the thickness of the enemy
	CP B
	JR NC, .continue

	; Check lower bounds
	ADD L										; Revert "SUB L" from above
	ADD L										; Include the thickness of the enemy
	CP B
	JR C, .continue

	; We have hit!
	CALL SrSetSpriteId
	CALL SrSpriteHit

	; Hide shot
	LD IX, IY
	CALL SrSetSpriteId
	CALL SrHideSprite

	POP BC
	RET											; Given enemy has been hit, nothing more to do.

.continue
	; Move IY to the beginning of the next #jwSpriteXX
	LD DE, SR_MS_SIZE
	ADD IY, DE
	POP BC
	DJNZ .loop									; Jump if B > 0 (loop starts with B = #SR_MS_SIZE)

	RET

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
	JR Z, .continue								;  Jump if visibility is not set (sprite is hidden)

	; Shot is visible
	CALL SrSetSpriteId							; Set the ID of the sprite for the following commands

	LD A, (IX + SR_MS_STATE)
	AND SR_MS_STATE_RIGHT_MASK					; Reset all bits but right
	CP SR_MS_STATE_RIGHT_MASK
	JR Z, .afterMovingLeft						; Jump if moving right

	; Moving left - decrease X coordinate
	LD BC, (IX + SR_MS_X)	
	DEC BC
	DEC BC

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

	; Skip collision detection if the shot is not alive - it has hit something already, and it's exploding.
	LD A, (IX + SR_MS_STATE)
	AND SR_MS_STATE_ALIVE						; Reset all bits but alive
	CP SR_MS_STATE_ALIVE
	JR NZ, .afterColisionDetection				; Exit if sprite is not alive

	; Check the collision with the platform
	PUSH BC
	LD IY, jpPlatformBump
	LD L, JW_SHOT_HEIGHT
	CALL SrPlaftormColision
	POP BC
.afterColisionDetection

.continue
	; Move IX to the beginning of the next #jwSpriteXX
	LD DE, SR_MS_SIZE
	ADD IX, DE
	POP BC
	DJNZ .loop									; Jump if B > 0 (loop starts with B = #SR_MS_SIZE)

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
	 
	; Animate shots
	LD IX, jwSprite	
	LD B, JW_SHOT_SIZE 
	CALL SrAnimateSprites

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

	; Take over direction from Jetman to laser beam 

	; Is Jetman moving left?
	LD A, (joJetmanDirection)
	AND JO_MOVE_LEFT_MASK						
	CP JO_MOVE_LEFT_MASK
	JR Z, .afterMovingRight						; Jump if Jetman is not moving right
	
	; Jetman is moving right
	LD A, 0										; Start building sprite state
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

	LD A, 0										; Start building sprite state
	RES SR_MS_STATE_DIRECTION_BIT, A

.afterMoving
	CALL SrShowSprite
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