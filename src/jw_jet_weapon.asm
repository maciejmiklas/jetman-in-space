;----------------------------------------------------------;
;                      Jetman Weapon                       ;
;----------------------------------------------------------;
	MODULE jw

; Adjustment to place the first laser beam next to Jetman so that it looks like it has been fired from the laser gun.
ADJUST_FIRE_X			= 10			
ADJUST_FIRE_Y			= 4

FIRE_THICKNESS			= 8

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
shotMss7
	sr.MSS {16/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
shotMss8
	sr.MSS {17/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
shotMss9
	sr.MSS {18/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
shotMss10
	sr.MSS {19/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}

; The counter is increased with each animation frame and reset when the fire is pressed. Fire can only be pressed when the counter reaches #FIRE_DELAY
shotMssDelayCnt
	DB 0

FIRE_DELAY				= 2
SHOT_SIZE				= 10			; Amount of shots that can be simultaneously fired

SHOT_HEIGHT				= 0

MOVE_X_IN_D				= %000'1'0001	; Input mask for MoveX. Move the sprite by 2 pixels and hide on the screen end

STATE_SHOT_DIR_BIT		= 5				; Bit for #sr.MSS.STATE, 1 - shot moves right, 0 - shot moves left


;----------------------------------------------------------;
;                #WeaponHitEnemies                         ;
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
;  - IX:	Pointer to #MSS, the enemies
;  - B:		Number of enemies in IX
; Modifies: ALL
CheckHitEnemies
.loop
	PUSH BC										; Preserve B for loop counter

	BIT sr.MSS_ST_VISIBLE_BIT, (IX + sr.MSS.STATE)
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
; Modifies: ALL
HitEnemy
	; Loop ever all shotMss# skipping hidden sprites
	LD IY, shotMss								; IY points to the enemy
	LD B, SHOT_SIZE 

.loop
	PUSH BC										; Preserve B for loop counter

	; Skipp invisible laser shoots
	BIT sr.MSS_ST_VISIBLE_BIT, (IY + sr.MSS.STATE)
	JR Z, .continue								; Jump if visibility is not set (sprite is hidden)

	; Skip collision detection if the enemy is not alive - it has hit something already, and it's exploding
	BIT sr.MSS_ST_ALIVE_BIT, (IX + sr.MSS.STATE)
	JR Z, .continue							; Jump if sprite is not alive
	
	; Shot is visible, check colision with given sprite

	; Compare X coordinate of enemy and shot
	LD HL, (IX + sr.MSS.X)						; X of the enemy
	LD DE, (IY + sr.MSS.X)						; X of the shot

	; Subtracts DE from HL and check whether the result is less than or equal to A
	SBC HL, DE
	CALL ut.AbsHL

	; We will compare L with FIRE_THICKNESS but first ensure that H is 0. Otherwise, the following can happen: HL = 300, DE = 30. 
	; The distance is 270. However, 270 occupies two bytes: H = 1, L=14. If we compare only L and ignore that H is 1, we will have a hit!
	LD A, 0
	CP H
	JR NZ, .continue

	LD A, FIRE_THICKNESS
	CP L										; SUB result is < 256, we can ignore H
	JR C, .continue								; Jump if A(#FIRE_THICKNESS) < L

	; We are here because the shot is horizontal with the enemy, now check the vertical match
	LD A, (IX + sr.MSS.Y)						; A holds Y from the enemy
	LD B, (IY + sr.MSS.Y)						; B holds Y from the laser beam

	; Subtracts B from A and check whether the result is less than or equal to #FIRE_THICKNESS
	SUB B
	CALL ut.AbsA
	LD B, A
	LD A, FIRE_THICKNESS
	CP B
	JR C, .continue								; Jump if A(#FIRE_THICKNESS) < B

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

	BIT sr.MSS_ST_VISIBLE_BIT, (IX + sr.MSS.STATE)  
	JR Z, .continue								;  Jump if visibility is not set (sprite is hidden)

	; Shot is visible, move it and update postion
	CALL sr.SetSpriteId							; Set the ID of the sprite for the following commands
	
	LD D, MOVE_X_IN_D

	; Setup move direction for shot
	BIT STATE_SHOT_DIR_BIT, (IX + sr.MSS.STATE)	
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
	BIT sr.MSS_ST_ALIVE_BIT, (IX + sr.MSS.STATE)
	JR Z, .afterColisionDetection				; Exit if sprite is not alive

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
	CP FIRE_DELAY
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
	bit sr.MSS_ST_VISIBLE_BIT, (IX + sr.MSS.STATE)
	JR Z, .afterFound							; Jump if visibility is not set -> hidden, can be reused

	; Move HL to the beginning of the next #shotMssX (see "LD DE, MSS" above)
	ADD IX, DE
	DJNZ .findLoop								; Jump if B > 0 (starts with B = #MSS)
	RET											; Loop has ended without finding free #shotMssX

.afterFound										
	; We are here because free #shotMssX has been found, and IX points to it

	; Is Jetman moving left or right?
	LD A, (id.jetDirection)
	bit id.MOVE_LEFT_BIT, A
	JR NZ, .movingLeft							; Jump if Jetman is moving left
	
	LD A, 0										; A will hold sr.MSS.STATE
	; Jetman is moving right, shot will move right also
	set STATE_SHOT_DIR_BIT, A					; Store shot direction in state

	; Set X coordinate for laser beam
	LD HL, (jo.jetX)
	ADD HL, ADJUST_FIRE_X
	LD (IX + sr.MSS.X), HL

	JR .afterMoving
.movingLeft
	; Jetman is moving left
	RES STATE_SHOT_DIR_BIT, A					; Store shot direction in state

	; Set X coordinate for laser beam
	LD HL, (jo.jetX)
	ADD HL, -ADJUST_FIRE_X
	LD (IX + sr.MSS.X), HL
.afterMoving

	CALL sr.SetVisible							; It will show sprite and store state from A

	; Set Y coordinate for laser beam
	LD A, (jo.jetY)
	ADD a, ADJUST_FIRE_Y
	LD (IX + sr.MSS.Y), A

	; Setup laser beam pattern, IX already points to the right memory address
	CALL sr.ShowSprite

	RET

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE