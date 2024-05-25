
;----------------------------------------------------------;
;                      Jetman Weapon                       ;
;----------------------------------------------------------;
	MODULE jw

; Adjustment to place the first laser beam next to Jetman so that it looks like it has been fired from the laser gun.
ADJUST_FIRE_X					= 10			
ADJUST_FIRE_Y					= 4

; Sprites for single shots (#shotMss), based on #MSS
shotMss
	sr.MSS {10/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
shotMss2
	sr.MSS {11/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
shotMss3
	sr.MSS {12/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
shotMss4
	sr.MSS {13/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
shotMss5
	sr.MSS {14/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
shotMss6
	sr.MSS {15/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}

; The counter is increased with each animation frame and reset when the fire is pressed. Fire can only be pressed when the counter reaches #FIRE_DELAY
shotMssDelayCnt
	DB 0

FIRE_DELAY						= 3
SHOT_SIZE						= 6				; Amount of shots that can be simultaneously fired

SHOT_HEIGHT						= 0


;----------------------------------------------------------;
;                      #WeaponHit                          ;
;----------------------------------------------------------;
; Checks all active enemies given by IX for collision with leaser beam
; Input
;  - IX:	Pointer to #MSS, the enemies
;  - B:		Number of enemies in IX
;  - H:     Half of the width of the enemy
;  - L:		Half of the height of the enemy
; Modifies: ALL
WeaponHit
.loop
	PUSH BC										; Preserve B for loop counter

	LD A, (IX + sr.MSS.STATE)
	AND sr.MSS_STATE_VISIBLE					; Reset all bits but visibility
	CP 0
	JR Z, .continue								; Jump if enemy is hidden

	; Sprite is visible
	CALL HitEnemy

.continue
	; Move HL to the beginning of the next #shotMssX
	LD DE, sr.MSS
	ADD IX, DE
	POP BC
	DJNZ .loop									; Jump if B > 0

	RET

;----------------------------------------------------------;
;                       #HitEnemy                          ;
;----------------------------------------------------------;
; Checks whether a given enemy has been hit by the laser beam and eventually destroys it
; Input:
;  - IX:	Pointer to concreate single enemy, single #MSS
;  - H:     Half of the width of the enemy
;  - L:		Half of the height of the enemy
; Modifies: ALL
HitEnemy
	; Loop ever all shotMss# skipping hidden sprites
	LD IY, shotMss								; IY points to the enemy
	LD B, SHOT_SIZE 

.loop
	PUSH BC										; Preserve B for loop counter

	; Skipp invisible laser shoots
	LD A, (IY + sr.MSS.STATE)
	AND sr.MSS_STATE_VISIBLE					; Reset all bits but visibility
	CP 0
	JR Z, .continue								; Jump if visibility is not set (sprite is hidden)

	; Skip collision detection if the enemy is not alive - it has hit something already, and it's exploding.
	LD A, (IX + sr.MSS.STATE)
	AND sr.MSS_STATE_ALIVE						; Reset all bits but alive
	CP sr.MSS_STATE_ALIVE
	JR NZ, .continue							; Jump if sprite is not alive
	
	; Shot is visible, check colision with given sprite

	; Compare X coordinate of enemy and shot
	LD BC, (IX + sr.MSS.X)						; X of the enemy
	LD DE, (IY + sr.MSS.X)						; X of the shot

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
	LD A, (IX + sr.MSS.Y)						; A holds Y from the enemy
	LD B, (IY + sr.MSS.Y)						; B holds Y from the laser beam

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
	CALL sr.SetSpriteId
	CALL sr.SpriteHit

	; Hide shot
	LD IX, IY
	CALL sr.SetSpriteId
	CALL sr.HideSprite

	POP BC
	RET											; Given enemy has been hit, nothing more to do.

.continue
	; Move IY to the beginning of the next #shotMssXX
	LD DE, sr.MSS
	ADD IY, DE
	POP BC
	DJNZ .loop									; Jump if B > 0 (loop starts with B = #MSS)

	RET

;----------------------------------------------------------;
;                      #MoveShots                          ;
;----------------------------------------------------------;
; Modifies: ALL
MoveShots
	; Loop ever all shotMss# skipping hidden sprites
	LD IX, shotMss	
	LD B, SHOT_SIZE 

.loop
	PUSH BC										; Preserve B for loop counter

	LD A, (IX + sr.MSS.STATE)
	AND sr.MSS_STATE_VISIBLE					; Reset all bits but visibility
	CP 0
	JR Z, .continue								;  Jump if visibility is not set (sprite is hidden)

	; Shot is visible
	CALL sr.SetSpriteId							; Set the ID of the sprite for the following commands

	LD A, (IX + sr.MSS.STATE)
	AND sr.MSS_STATE_RIGHT_MASK					; Reset all bits but right
	CP sr.MSS_STATE_RIGHT_MASK
	JR Z, .afterMovingLeft						; Jump if moving right

	; Moving left - decrease X coordinate
	LD BC, (IX + sr.MSS.X)	
	DEC BC
	DEC BC

	; Check whether a shot is outside the screen 
	LD A, B
	CP sc.SCR_X_MIN_POS							; B holds MSB from X, if B > 0 than X > 256
	JR NZ, .afterMoving
	LD A, C
	CP sc.SCR_X_MIN_POS + 5						; C holds LSB from X, ff C != 5 then X is> 5
	JR NC, .afterMoving
	; X == 0 (both A and B are 0) -> shot out of screen - hide it
	CALL sr.HideSprite
	JR .continue	

.afterMovingLeft

	; Moving right - increase X coordinate
	LD BC, (IX + sr.MSS.X)	
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
	CALL sr.HideSprite
	JR .continue
.afterMoving
	LD (IX + sr.MSS.X), BC						; Update new X position
	CALL sr.UpdateSpritePosition

	; Skip collision detection if the shot is not alive - it has hit something already, and it's exploding.
	LD A, (IX + sr.MSS.STATE)
	AND sr.MSS_STATE_ALIVE						; Reset all bits but alive
	CP sr.MSS_STATE_ALIVE
	JR NZ, .afterColisionDetection				; Exit if sprite is not alive

	; Check the collision with the platform
	LD IY, jp.platformBump
	LD L, SHOT_HEIGHT
	CALL sr.PlaftormColision
	CP A, sr.PL_COL_RET_A_NO
	JR Z, .afterColisionDetection
	CALL sr.SpriteHit
.afterColisionDetection

.continue
	; Move IX to the beginning of the next #shotMssXX
	LD DE, sr.MSS
	ADD IX, DE
	POP BC
	DJNZ .loop									; Jump if B > 0 (loop starts with B = #MSS)

	RET

;----------------------------------------------------------;
;                    #AnimateShots                         ;
;----------------------------------------------------------;
AnimateShots
	; Increase shot counter
	LD A, (shotMssDelayCnt)
	CP A, FIRE_DELAY
	JR NC, .afterIncDelay						; Do increase the delay counter when it has reached the required value
	INC A
	LD (shotMssDelayCnt), A
.afterIncDelay
	 
	; Animate shots
	LD IX, shotMss	
	LD B, SHOT_SIZE 
	CALL sr.AnimateSprites

	RET

;----------------------------------------------------------;
;                          #Fire                           ;
;----------------------------------------------------------;
Fire

	; Check delay to limit fire speed
	LD A, (shotMssDelayCnt)
	CP FIRE_DELAY
	RET C										; Return if the delay counter did not reach the defined value
	; we can fire, reset counter
	LD A, 0
	LD (shotMssDelayCnt), A

	; Find the first inactive (sprite hidden) shot
	LD IX, shotMss
	LD DE, sr.MSS
	LD B, SHOT_SIZE 
.findLoop

	; Check whether the current #shotMssX is not visible and can be reused
	LD A, (IX + sr.MSS.STATE)
	AND sr.MSS_STATE_VISIBLE					; Reset all bits but visibility
	CP 0
	JR Z, .afterFound							; Jump if visibility is not set -> hidden, can be reused

	; Move HL to the beginning of the next #shotMssX (see "LD DE, MSS" above)
	ADD IX, DE
	DJNZ .findLoop								; Jump if B > 0 (starts with B = #MSS)
	RET											; Loop has ended without finding free #shotMssX

.afterFound										
	; We are here because free #shotMssX has been found, and IX points to it

	; Take over direction from Jetman to laser beam 

	; Is Jetman moving left?
	LD A, (jd.jetmanDirection)
	AND jd.MOVE_LEFT_MASK						
	CP jd.MOVE_LEFT_MASK
	JR Z, .afterMovingRight						; Jump if Jetman is not moving right
	
	; Jetman is moving right
	LD A, 0										; Start building sprite state
	SET sr.MSS_STATE_DIRECTION_BIT, A

	; Set X coordinate for laser beam
	LD HL, (jd.jetmanX)
	ADD HL, ADJUST_FIRE_X
	LD (IX + sr.MSS.X), HL

	JR .afterMoving
.afterMovingRight
	; Jetman is moving left

	; Set X coordinate for laser beam
	LD HL, (jd.jetmanX)
	ADD HL, -ADJUST_FIRE_X
	LD (IX + sr.MSS.X), HL

	LD A, 0										; Start building sprite state
	RES sr.MSS_STATE_DIRECTION_BIT, A

.afterMoving
	CALL sr.SetVisible
	LD (IX + sr.MSS.STATE), A					; Store state

	; Set Y coordinate for laser beam
	LD A, (jd.jetmanY)
	ADD A, ADJUST_FIRE_Y
	LD (IX + sr.MSS.Y), A

	; Setup laser beam pattern, IX already points to the right memory address
	CALL sr.ShowSprite

	RET

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE