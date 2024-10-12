;----------------------------------------------------------;
;                      Jetman Weapon                       ;
;----------------------------------------------------------;
	MODULE jw

; Adjustment to place the first laser beam next to Jetman so that it looks like it has been fired from the laser gun.
ADJUST_FIRE_X			= 10			
ADJUST_FIRE_Y			= 4

FIRE_THICKNESS			= 10

; Sprites for single shots (#shots), based on #SPRITE
shots
	sr.SPRITE {10/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
shots2
	sr.SPRITE {11/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
shots3
	sr.SPRITE {12/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
shots4
	sr.SPRITE {13/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
shots5
	sr.SPRITE {14/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
shots6
	sr.SPRITE {15/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
shots7
	sr.SPRITE {16/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
shots8
	sr.SPRITE {17/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
shots9
	sr.SPRITE {18/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
shots10
	sr.SPRITE {19/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}

SHOTS_SIZE				= 10					; Amount of shots that can be simultaneously fired. Max is limited by #shotsXX

FIRE_DELAY				= 15
; The counter is increased with each animation frame and reset when the fire is pressed. Fire can only be pressed when the counter reaches #FIRE_DELAY
shotsDelayCnt
	DB 0

SHOT_HEIGHT_PLATFORM	= 1

STATE_SHOT_DIR_BIT		= 5						; Bit for #sr.SPRITE.STATE, 1 - shot moves right, 0 - shot moves left

;----------------------------------------------------------;
;                   #WeaponHitEnemies                      ;
;----------------------------------------------------------;
WeaponHitEnemies

	LD IX, ed.sprite01
	LD A, (ed.spritesSize)
	LD B, A
	CALL CheckHitEnemies
	RET	

;----------------------------------------------------------;
;                    #CheckHitEnemies                      ;
;----------------------------------------------------------;
; Checks all active enemies given by IX for collision with leaser beam
; Input
;  - IX:	Pointer to #SPRITE, the enemies
;  - B:		Number of enemies in IX
; Modifies: ALL
CheckHitEnemies


.loop											; Loop over every enemy
	PUSH BC										; Preserve B for loop counter
	LD A, (IX + sr.SPRITE.STATE)
	BIT sr.SPRITE_ST_VISIBLE_BIT, A
	JR Z, .continue								; Jump if enemy is hidden

	; Skip collision detection if the enemy is not alive - it has hit something already, and it's exploding
	BIT sr.SPRITE_ST_ACTIVE_BIT, A
	JR Z, .continue	
	
	; Enemy is visible, check colision with leaser beam
	LD DE, (IX + sr.SPRITE.X)					; X of the enemy
	LD C, (IX + sr.SPRITE.Y)					; Y of the enemy

	PUSH IX
	CALL ShotsColision
	POP IX
	CP SHOT_HIT
	JR NZ, .continue							; Jump if there is no hit

	; We have hit!
	CALL sr.SetSpriteId
	CALL sr.SpriteHit

.continue
	; Move HL to the beginning of the next enemy
	LD DE, sr.SPRITE
	ADD IX, DE

	POP BC
	DJNZ .loop									; Jump if B > 0

	RET

;----------------------------------------------------------;
;                    #ShotsColision                        ;
;----------------------------------------------------------;
; The method checks whether any active laser beam has hit the sprite given by X/Y
; Input:
; - DE:  X of the sprite 
; - C:   Y of the sprite
; Output:
; - A:   values:
; Modifies: All
SHOT_HIT					= 1
SHOT_MISS					= 0

ShotsColision

	; Loop ever all shots# skipping hidden shots
	LD IX, shots								; IX points to the shot
	LD B, SHOTS_SIZE 
.shotsLoop
	PUSH BC, DE
	LD A, (IX + sr.SPRITE.STATE)

	; Skipp hidden laser shoots for collision detection
	BIT sr.SPRITE_ST_VISIBLE_BIT, A
	JR Z, .continueShotsLoop

	; Skipp inactive laser shoots for collision detection
	BIT sr.SPRITE_ST_ACTIVE_BIT, A
	JR Z, .continueShotsLoop

	; Compare X coordinate of the sprite and the shot, HL holds X of the sprite
	LD HL, (IX + sr.SPRITE.X)					; X of the shot
	
	; Subtracts DE from HL and check whether the result is less than or equal to A
	SBC DE, HL
	CALL ut.AbsDE

	; We will compare E with FIRE_THICKNESS but first ensure that D is 0. Otherwise, the following can happen: DE = 300, HL = 30. 
	; The distance is 270. However, 270 occupies two bytes: D=1, E=14. If we compare only E and ignore that D is 1, we will have a hit!
	XOR A										; Set A to 0
	CP D
	JR NZ, .continueShotsLoop

	LD A, FIRE_THICKNESS
	CP E										; SUB result is < 256, we can ignore H
	JR C, .continueShotsLoop					; Jump if A(#FIRE_THICKNESS) < L
	
	; We are here because the shot is horizontal with the enemy, now check the vertical match
	LD A, (IX + sr.SPRITE.Y)					; A holds Y from the shot

	; Subtracts C from A and check whether the result is less than or equal to #FIRE_THICKNESS
	SUB C
	CALL ut.AbsA
	LD D, A
	LD A, FIRE_THICKNESS
	CP D
	JR C, .continueShotsLoop					; Jump if A(#FIRE_THICKNESS) < D

	; We have hit! Hide shot and return
	CALL sr.SetSpriteId
	CALL sr.HideSprite

	LD A, SHOT_HIT
	POP DE, BC
	RET

.continueShotsLoop
	; Move IX to the beginning of the next #shotsXX
	LD DE, sr.SPRITE
	ADD IX, DE

	POP DE, BC
	DJNZ .shotsLoop									; Jump if B > 0 (loop starts with B = #SPRITE)

	; There was no hit
	LD A, SHOT_MISS

	RET

;----------------------------------------------------------;
;                      #MoveShots                          ;
;----------------------------------------------------------;
; Modifies: ALL
MoveShots
	; Loop ever all shots# skipping hidden sprites
	LD IX, shots	
	LD B, SHOTS_SIZE 

.loop
	PUSH BC										; Preserve B for loop counter

	; Skipp hidden laser shoots
	BIT sr.SPRITE_ST_VISIBLE_BIT, (IX + sr.SPRITE.STATE)
	JR Z, .continue

	; Shot is visible, move it and update postion
	CALL sr.SetSpriteId							; Set the ID of the sprite for the following commands
	
	LD D, sr.MVX_IN_D_6PX_HIDE

	; Setup move direction for shot
	BIT STATE_SHOT_DIR_BIT, (IX + sr.SPRITE.STATE)	
	JR Z, .shotDirLeft	
	
	; Shot moves right
	SET sr.MVX_IN_D_DIR_BIT, D
	JR .afterShotDir	
.shotDirLeft	
	; Shot moves left
	RES sr.MVX_IN_D_DIR_BIT, D
.afterShotDir	
	
	CALL sr.MoveX	
	CALL sr.UpdateSpritePosition

	; Skip collision detection if the shot is not alive - it has hit something already, and it's exploding.
	BIT sr.SPRITE_ST_ACTIVE_BIT, (IX + sr.SPRITE.STATE)
	JR Z, .afterPlatformColision				; Exit if sprite is not alive

	; Check the collision with the platform
	LD L, SHOT_HEIGHT_PLATFORM
	CALL jp.LevelPlaftormColision
	CP A, jp.PL_COL_RET_A_NO
	JR Z, .afterPlatformColision
	CALL sr.SpriteHit
.afterPlatformColision

.continue
	; Move IX to the beginning of the next #shotsXX
	LD DE, sr.SPRITE
	ADD IX, DE
	POP BC
	DJNZ .loop									; Jump if B > 0 (loop starts with B = #SPRITE)

	RET

;----------------------------------------------------------;
;                  #FireDelayCounter                       ;
;----------------------------------------------------------;
FireDelayCounter
	; Increase shot counter
	LD A, (shotsDelayCnt)
	CP FIRE_DELAY
	RET Z										; Do increase the delay counter when it has reached the required value
	INC A
	LD (shotsDelayCnt), A
	 
	RET


;----------------------------------------------------------;
;                    #AnimateShots                         ;
;----------------------------------------------------------;
AnimateShots
	LD IX, shots	
	LD B, SHOTS_SIZE 
	CALL sr.AnimateSprites

	RET

;----------------------------------------------------------;
;                          #Fire                           ;
;----------------------------------------------------------;
Fire
	; Check delay to limit fire speed
	LD A, (shotsDelayCnt)
	CP FIRE_DELAY
	RET NZ										; Return if the delay counter did not reach the defined value

	; We can fire, reset counter
	XOR A										; Set A to 0
	LD (shotsDelayCnt), A

	; Find the first inactive (sprite hidden) shot
	LD IX, shots
	LD DE, sr.SPRITE
	LD B, SHOTS_SIZE 
.findLoop

	; Check whether the current #shotsX is not visible and can be reused
	BIT sr.SPRITE_ST_VISIBLE_BIT, (IX + sr.SPRITE.STATE)
	JR Z, .afterFound							; Jump if visibility is not set -> hidden, can be reused

	; Move HL to the beginning of the next #shotsX (see "LD DE, SPRITE" above)
	ADD IX, DE
	DJNZ .findLoop								; Jump if B > 0 (starts with B = #SPRITE)
	RET											; Loop has ended without finding free #shotsX

.afterFound										
	; We are here because free #shotsX has been found, and IX points to it

	; Is Jetman moving left or right?
	LD A, (id.jetDirection)
	BIT id.MOVE_LEFT_BIT, A
	JR NZ, .movingLeft							; Jump if Jetman is moving left
	
	XOR A										; A will hold sr.SPRITE.STATE
	; Jetman is moving right, shot will move right also
	SET STATE_SHOT_DIR_BIT, A					; Store shot direction in state

	; Set X coordinate for laser beam
	LD HL, (jo.jetX)
	ADD HL, ADJUST_FIRE_X
	LD (IX + sr.SPRITE.X), HL

	JR .afterMoving
.movingLeft

	XOR A										; A will hold sr.SPRITE.STATE
	; Jetman is moving left
	RES STATE_SHOT_DIR_BIT, A					; Store shot direction in state

	; Set X coordinate for laser beam
	LD HL, (jo.jetX)
	ADD HL, -ADJUST_FIRE_X
	LD (IX + sr.SPRITE.X), HL
.afterMoving

	CALL sr.SetStateVisible							; It will show sprite and store state from A

	; Set Y coordinate for laser beam
	LD A, (jo.jetY)
	ADD a, ADJUST_FIRE_Y
	LD (IX + sr.SPRITE.Y), A

	; Setup laser beam pattern, IX already points to the right memory address
	CALL sr.SetSpriteId							; Set the ID of the sprite for the following commands	
	CALL sr.ShowSprite

	RET

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE