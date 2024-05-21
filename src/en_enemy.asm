;----------------------------------------------------------;
;                     Flying Enemy                         ;
;----------------------------------------------------------;
	MODULE en

; The timer ticks with every game loop. When it reaches #EN_RESPOWN_DELAY, a single enemy will respawn, and the timer starts from 0, counting again.
respownDelayCnt 			DB 0
respownDelay 				DB 20				; Amount of game loops to respawn single enemy

; Extends #MSS by additional params.
	STRUCT ESS
MOVE_DELAY				BYTE					; Number of game loops to skip before moving enemy (delays movement speed)
MOVE_DELAY_CNT			BYTE					; Move delay counter
RESPOWN_DELAY			BYTE					; Number of game loops delaying respawn
RESPOWN_DELAY_CNT		BYTE					; Respawn delay counter
MOVE_PATTERN			WORD					; Pointer to the movement pattern
MOVE_PATTERN_CNT		WORD					; Position in #MOVE_PATTERN. Counts from 0 to size-1
MOVE_PATTERN_STEP 		BYTE					; Counters for current byte in move pattern
	ENDS

;----------------------------------------------------------;
;          Memory Structure for Sprite Move Patern         ;
;----------------------------------------------------------;
; Move pattern (given by #ESS.MOVE_PATTERN) consists of a byte array. The first byte determines the number of elements in this array, 
; and the remaining move pattern, where each byte carries the same information:
; bit 0-4: amount of iterations, each iteration will change X and Y based following bits
; bit 5-6: number of pixels to change X in a single iteration, from 0 to 3. 
;          The X will increase or decrease depending on the movement direction given by bit 3 in #MSS.STATE.
; bit 7-8: number of pixels to change Y in a single iteration, from 0 to 3. 
;          The Y will increase or decrease depending on the movement direction given by bit 2 in #MSS.STATE.


; Sprites for single enemy (#sprite), based on #MSS
; Each sprite has hardcoded respawn coordinates and the direction in which it moves
spriteEx01
	ESS {1/*MOVE_DELAY*/, 0/*MOVE_DELAY_CNT*/, 0/*RESPOWN_DELAY*/ ,0/*RESPOWN_DELAY_CNT*/, movePattern01/*MOVE_PATTERN*/, /*MOVE_PATTERN_CNT*/0, 0/*MOVE_PATTERN_STEP*/}
spriteEx02
	ESS {2/*MOVE_DELAY*/, 0/*MOVE_DELAY_CNT*/, 0/*RESPOWN_DELAY*/ ,0/*RESPOWN_DELAY_CNT*/, movePattern01/*MOVE_PATTERN*/, /*MOVE_PATTERN_CNT*/0, 0/*MOVE_PATTERN_STEP*/}
spriteEx03
	ESS {3/*MOVE_DELAY*/, 0/*MOVE_DELAY_CNT*/, 0/*RESPOWN_DELAY*/ ,0/*RESPOWN_DELAY_CNT*/, movePattern01/*MOVE_PATTERN*/, /*MOVE_PATTERN_CNT*/0, 0/*MOVE_PATTERN_STEP*/}
spriteEx04
	ESS {4/*MOVE_DELAY*/, 0/*MOVE_DELAY_CNT*/, 0/*RESPOWN_DELAY*/ ,0/*RESPOWN_DELAY_CNT*/, movePattern01/*MOVE_PATTERN*/, /*MOVE_PATTERN_CNT*/0, 0/*MOVE_PATTERN_STEP*/}
spriteEx05
	ESS {0/*MOVE_DELAY*/, 0/*MOVE_DELAY_CNT*/, 5/*RESPOWN_DELAY*/ ,0/*RESPOWN_DELAY_CNT*/, movePattern01/*MOVE_PATTERN*/, /*MOVE_PATTERN_CNT*/0, 0/*MOVE_PATTERN_STEP*/}
spriteEx06
	ESS {0/*MOVE_DELAY*/, 0/*MOVE_DELAY_CNT*/, 5/*RESPOWN_DELAY*/ ,0/*RESPOWN_DELAY_CNT*/, movePattern01/*MOVE_PATTERN*/, /*MOVE_PATTERN_CNT*/0, 0/*MOVE_PATTERN_STEP*/}
spriteEx07
	ESS {0/*MOVE_DELAY*/, 0/*MOVE_DELAY_CNT*/, 5/*RESPOWN_DELAY*/ ,0/*RESPOWN_DELAY_CNT*/, movePattern01/*MOVE_PATTERN*/, /*MOVE_PATTERN_CNT*/0, 0/*MOVE_PATTERN_STEP*/}
spriteEx08
	ESS {1/*MOVE_DELAY*/, 0/*MOVE_DELAY_CNT*/, 0/*RESPOWN_DELAY*/ ,0/*RESPOWN_DELAY_CNT*/, movePattern01/*MOVE_PATTERN*/, /*MOVE_PATTERN_CNT*/0, 0/*MOVE_PATTERN_STEP*/}
spriteEx09
	ESS {2/*MOVE_DELAY*/, 0/*MOVE_DELAY_CNT*/, 0/*RESPOWN_DELAY*/ ,0/*RESPOWN_DELAY_CNT*/, movePattern01/*MOVE_PATTERN*/, /*MOVE_PATTERN_CNT*/0, 0/*MOVE_PATTERN_STEP*/}
spriteEx10
	ESS {2/*MOVE_fDELAY*/, 0/*MOVE_DELAY_CNT*/, 0/*RESPOWN_DELAY*/ ,0/*RESPOWN_DELAY_CNT*/, movePattern01/*MOVE_PATTERN*/, /*MOVE_PATTERN_CNT*/0, 0/*MOVE_PATTERN_STEP*/}

sprite01
	sr.MSS {20/*ID*/, sr.SDB_COMET1/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, sr.MSS_STATE_LEFT_MASK/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx01/*EXT_DATA_POINTER*/}
sprite02
	sr.MSS {21/*ID*/, sr.SDB_COMET1/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, sr.MSS_STATE_LEFT_MASK/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx02/*EXT_DATA_POINTER*/}
sprite03
	sr.MSS {22/*ID*/, sr.SDB_COMET1/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, sr.MSS_STATE_RIGHT_MASK/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx03/*EXT_DATA_POINTER*/}
sprite04
	sr.MSS {23/*ID*/, sr.SDB_COMET1/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, sr.MSS_STATE_LEFT_MASK/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx04/*EXT_DATA_POINTER*/}
sprite05
	sr.MSS {24/*ID*/, sr.SDB_COMET2/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, sr.MSS_STATE_RIGHT_MASK/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx05/*EXT_DATA_POINTER*/}
sprite06
	sr.MSS {25/*ID*/, sr.SDB_COMET2/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, sr.MSS_STATE_LEFT_MASK/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx06/*EXT_DATA_POINTER*/}
sprite07
	sr.MSS {26/*ID*/, sr.SDB_COMET2/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, sr.MSS_STATE_RIGHT_MASK/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx07/*EXT_DATA_POINTER*/}
sprite08
	sr.MSS {27/*ID*/, sr.SDB_COMET1/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, sr.MSS_STATE_LEFT_MASK/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx08/*EXT_DATA_POINTER*/}
sprite09
	sr.MSS {28/*ID*/, sr.SDB_COMET1/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, sr.MSS_STATE_RIGHT_MASK/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx09/*EXT_DATA_POINTER*/}
sprite10
	sr.MSS {29/*ID*/, sr.SDB_COMET1/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, sr.MSS_STATE_LEFT_MASK/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx10/*EXT_DATA_POINTER*/}

spritesSize					DB 10				; The maximum amount of visible enemies			
SPRITE_HEIGHT_PLATFORM		= 3

SPRITE_HEIGHT_WEAPON		= 8
SPRITE_WIDTH_WEAPON			= 8


; The move pattern is stored as a byte array, with the first byte giving the number of elements in this array. 
; Each element determines a single step in this movement pattern: the number of pixels to move horizontally, vertically and the number 
; of times it should be repeated. 
; Bits:
; 0-1: number of pixels to move on X axis
; 2-3: number of pixels to move on Y axis
; 4	 : 1 to increase Y, 0 to decrease. X will be increased/decreased depending on #sr.STATE -> bit 3
; 5-7: repetition amount
; In each animation loop, the sprite travels only one pixel in each direction. If possible, it travels in both directions 
; (increasing X and Y by one). If the number of pixels in a particular direction has been reached, it will continue vertically or horizontally. 
; 
; Example: for a move pattern %100'001'11 the sprite will move 3 pixels on the X axis, 1 pixel on the Y axis, 
; and it will be repeated 4 times (A-D):
; A 1) INC X, INC Y:	%001'1'01'01
; A 2) INC X			%001'1'01'10
; A 3) INC X			%001'1'01'11	
;
; B 1) INC X, INC Y:	%010'1'01'01
; B 2) INC X			%010'1'01'10
; B 3) INC X			%010'1'01'11	
;
; C 1) INC X, INC Y:	%011'1'01'01
; C 2) INC X			%011'1'01'10
; C 3) INC X			%011'1'01'11	
;
; D 1) INC X, INC Y:	%100'1'01'01
; D 2) INC X			%100'1'01'10
; D 3) INC X			%100'1'01'11	

MOVE_PAT_X_MASK			= %000'0'00'11
MOVE_PAT_X_MASK_RES		= %111'1'11'00
MOVE_PAT_X_ADD			= %000'0'00'01

MOVE_PAT_Y_MASK			= %000'0'11'00
MOVE_PAT_Y_MASK_RES		= %111'1'00'11
MOVE_PAT_Y_ADD			= %000'0'01'00

MOVE_PAT_Y_INC_MASK		= %000'1'00'00
MOVE_PAT_Y_INC_MASK_RES	= %111'0'00'00

MOVE_PAT_XY_MASK		= %000'0'11'11
MOVE_PAT_XY_MASK_RES	= %111'0'00'00

MOVE_PAT_CNT_MASK		= %111'0'00'00
MOVE_PAT_CNT_ADD		= %001'0'00'00

movePattern01
	DB 8, %111'1'01'11, %111'1'01'11,  %111'1'01'11, %111'1'01'11, %111'0'01'11, %111'0'01'11,  %111'0'01'11, %111'0'01'11 

;----------------------------------------------------------;
;                     #InitMoveEnemy                       ;
;----------------------------------------------------------;
; Input
;  - IX:	pointer to #MSS holding data for single spreite that will be moved
; Modifies: A, IY, BC
InitMoveEnemy

	; Load #ESS for this sprite to IY
	LD BC, (IX + sr.MSS.EXT_DATA_POINTER)
	LD IY, BC
	LD HL, (IY + ESS.MOVE_PATTERN)				; HL points to start of the #movePattern

	; Setup MOVE_PATTERN_STEP that we will use to track progress of current move pattern.
	; Set the repetition counter for the current pattern to the max value, as we will count it down to 0. Set X and Y to 0, 
	; as those counters will be increased.
	INC HL										; Move HL to the first move pattern (the first byte holds the amount)
	LD A, (HL)
	AND MOVE_PAT_CNT_MASK 
	LD (IY + ESS.MOVE_PATTERN_STEP), A	

	; Reset move counter
	LD A, 0
	LD (IY + ESS.MOVE_PATTERN_CNT), A
	RET	
;----------------------------------------------------------;
;                      #MoveEnemy                          ;
;----------------------------------------------------------;
; Input
;  - IX:	pointer to #MSS holding data for single spreite that will be moved
; Modifies: all
MoveEnemy

	; Ignore this sprite if it's hidden
	LD A, (IX + sr.MSS.STATE)
	AND sr.MSS_STATE_VISIBLE					; Reset all bits but visibility
	CP 0
	RET Z										; Return if visibility is not set (sprite is hidden)

	;LD A, $30
	;nextreg 2,8

	; Load #ESS for this sprite to IY
	LD BC, (IX + sr.MSS.EXT_DATA_POINTER)
	LD IY, BC

	LD HL, (IY + ESS.MOVE_PATTERN)				; HL points to start of the #movePattern
	LD B, (HL)									; B contains  the amount of bytes in the move pattern

	; Check if we should restart the move pattern, as it might have reached the last element
	LD A, (IY + ESS.MOVE_PATTERN_CNT) 
	CP B
	JR C, .afterResetMoveCounter				; Jump if move counter can be increased

	; Reset move counter
	CALL InitMoveEnemy

.afterResetMoveCounter

	; Move HL from the beginning of the move pattern to current position
	LD A, (IY + ESS.MOVE_PATTERN_CNT)
	INC A										; The first byte in the move pattern contains the size, skip it.
	ADD HL, A

	CALL sr.SetSpriteId							; Set sprite ID in hardware

	; Current register values:
	;  - IX: pointer to #MSS for current sprite
	;  - IY: pointer to #ESS for current sprite
	;  - HL: pointer to current position in #movePattern

	; Increment/Decrement X ?
	LD A, (HL)									; A contains current pattern
	AND MOVE_PAT_X_MASK							; Reset all but X
	LD D, A										; Store A into D

	LD A, (IY + ESS.MOVE_PATTERN_STEP)			; A contains pattern counter	
	AND MOVE_PAT_X_MASK							; Reset all but max X value

	CP D
	JR Z, .afterIncX							; Jump if A == D -> X has already max value
	
	; Increment X
	LD A, (IY + ESS.MOVE_PATTERN_STEP)			; A contains orginal pattern counter
	ADD MOVE_PAT_X_ADD							; Increment X by 1		
	LD (IY + ESS.MOVE_PATTERN_STEP), A

	CALL sr.MoveX								; Move one pixel left/right and check if the sprite is still visible (it could be out of the screen)
	CP sr.MOVE_RET_A_HIDDEN	
	JR NZ,.afterIncX							; Jump is sprite is not hidden

	; Stop moving this spirte, it's hidden
	CALL InitMoveEnemy
	RET
.afterIncX

	; Increment/Decrement Y ?
	LD A, (HL)									; A contains current pattern
	AND MOVE_PAT_Y_MASK							; Reset all but Y
	LD D, A										; Store A into D

	LD A, (IY + ESS.MOVE_PATTERN_STEP)			; A contains pattern counter	
	AND MOVE_PAT_Y_MASK							; Reset all but max Y value

	CP D
	JR Z, .afterChangeY							; Jump if A == D -> Y has already reached max value
	
	LD A, (HL)									; A contains current pattern
	AND MOVE_PAT_Y_INC_MASK						; Reset all except a bit, determining whether Y should be incremented or decremented
	CP MOVE_PAT_Y_INC_MASK
	JR Z, .incY									; Jump if Y should be incremented

	; Decrement Y
	LD A, (IY + ESS.MOVE_PATTERN_STEP)			; A contains orginal pattern counter
	SUB MOVE_PAT_Y_ADD							; Decrement Y by 1
	LD (IY + ESS.MOVE_PATTERN_STEP), A	
	
	LD A, sr.MOVE_Y_IN_A_DOWN
	CALL sr.MoveY
	CP sr.MOVE_RET_A_HIDDEN
	JR NZ,.afterChangeY							; Jump is sprite is not hidden

	; Stop moving this spirte, it's hidden
	CALL InitMoveEnemy
	RET

.incY
	; Increment Y
	LD A, (IY + ESS.MOVE_PATTERN_STEP)			; A contains orginal pattern counter
	ADD MOVE_PAT_Y_ADD							; Increment Y by 1
	LD (IY + ESS.MOVE_PATTERN_STEP), A	

	LD A, sr.MOVE_Y_IN_A_UP
	CALL sr.MoveY
	CP sr.MOVE_RET_A_HIDDEN
	JR NZ,.afterChangeY							; Jump is sprite is not hidden

	; Stop moving this spirte, it's hidden
	CALL InitMoveEnemy
	RET
	
.afterChangeY
	CALL sr.UpdateSpritePosition				; Move sprite to new X,Y coordinates

	; Check if X and Y have reached max values
	LD A, (IY + ESS.MOVE_PATTERN_STEP)			; A contains pattern counter	
	AND MOVE_PAT_XY_MASK						; Reset all but max X,Y values
	LD D, A										; Store A into D

	LD A, (HL)									; A contains current pattern
	AND MOVE_PAT_XY_MASK						; Reset all but X,Y values

	; D contains the wanted X and Y values, and A contains the current ones. If both are the same, that means that the X and Y counters 
	; have reached their maximum value, and we have to start over 
	CP D
	RET NZ										; Jump if A != D -> no need to reset XY counter, keep incrementing X/Y

	; X and Y have reached the max value, so increment the repetition counter for this pattern and restart the X and Y incrementation
	; Reset conter for XY
	LD A, (IY + ESS.MOVE_PATTERN_STEP)			; A contains pattern counter
	AND MOVE_PAT_XY_MASK_RES					; Reset XY bits
	LD (IY + ESS.MOVE_PATTERN_STEP), A

	; The above command has reset XY bits, leaving only counter bits

	; Is counter disabled?
	CP 0
	JR Z, .nextMovePattern

	SUB MOVE_PAT_CNT_ADD						; Decrement counter, it's stored on bits: 5-7	
	CP 0
	JR Z, .nextMovePattern						; Jump if the countdown is done
	
	LD (IY + ESS.MOVE_PATTERN_STEP), A			; Store decreased counter, Y,X are 0
	RET

.nextMovePattern
	LD A, (IY + ESS.MOVE_PATTERN_CNT)			; A contains the current position in the move pattern
	INC A										; Increment move counter and store
	LD (IY + ESS.MOVE_PATTERN_CNT), A

	RET

;----------------------------------------------------------;
;                        #Respown                          ;
;----------------------------------------------------------;
Respown

	; Increment respawn timer and exit function if it's not time to respawn a new enemy
	LD A, (respownDelay)
	LD B, A
	LD A, (respownDelayCnt)
	INC A
	CP B
	JR Z, .startRespown							; Jump if the timer reaches respawn delay
	LD (respownDelayCnt), A
	RET
.startRespown	
	LD A, 0
	LD (respownDelayCnt), A						; Reset delay timer

	; It would be the time to respawn the enemy. However, to archive random respawn time, we will respawn only when the loop counter 
	; is within the Y coordinate, where movement is allowed:  #SCR_Y_MIN_POS < Y < #SCR_Y_MAX_POS
	LD A, (gm.loopCnt)

	CP sc.SCR_Y_MIN_POS
	RET C										; Return if Y is below game screen

	CP sc.SCR_Y_MAX_POS
	RET NC										; Return if Y is above game screen

	LD IX, sprite01								; Iterate over all enemies to find the first hidden, respawn it, and exit function

	LD A, (spritesSize)
	LD B, A 
.loop
	PUSH BC										; Preserve B for loop counter
		
	LD A, (IX + sr.MSS.STATE)
	AND sr.MSS_STATE_VISIBLE					; Reset all bits but visibility
	CP sr.MSS_STATE_VISIBLE
	JR Z, .continue								; Skipp this sprite if it's already visible

	; Sprite is hidden; check the dedicated delay before respawning

	; Load extra sprite data (#ESS) to IY
	LD BC, (IX + sr.MSS.EXT_DATA_POINTER)
	LD IY, BC
	
	; There are two respawn delay timers. The first is global (#respownDelayCnt) and ensures that multiple enemies do not respawn at the same time. 
	; The second timer can be configured for a single enemy, which further delays its comeback. 
	LD A, (IY + ESS.RESPOWN_DELAY)
	CP 0
	
	JR Z, .afterEnemyRespownDelay			; Jump if there is no extra delay for this enemy
		
	LD B, A	
	LD A, (IY + ESS.RESPOWN_DELAY_CNT)
	INC A
	CP B
	JR Z, .afterEnemyRespownDelay				; Jump if the timer reaches respawn delay

	LD (IY + ESS.RESPOWN_DELAY_CNT), A			; The delay timer for the enemy is still ticking
	POP BC
	RET
.afterEnemyRespownDelay

	; Respown enemy, first mark it as visible
	LD A, (IX + sr.MSS.STATE)
	CALL sr.SetVisible

	; Reset counters
	LD A, 0
	LD (IY + ESS.MOVE_DELAY_CNT), A
	LD (IY + ESS.RESPOWN_DELAY_CNT), A
	LD (IY + ESS.MOVE_PATTERN_CNT), A

	; Set Y (horizontal respown) to a random value
	LD A, (gm.loopCnt)
	LD (IX + sr.MSS.Y), A
	
	; Set X to left or right side of the screen
	LD A, (IX + sr.MSS.STATE)
	AND sr.MSS_STATE_RIGHT_MASK
	CP sr.MSS_STATE_RIGHT_MASK
	JR NZ, .left
	LD BC, sc.SCR_X_MAX_POS
	JR .afterLR
.left	
	LD BC, sc.SCR_X_MIN_POS
.afterLR
	LD (IX + sr.MSS.X), BC

	CALL sr.ShowSprite

	; Exit after respawning first enemy
	POP BC
	RET											
.continue
	; Move IX to the beginning of the next #shotMssXX
	LD DE, sr.MSS
	ADD IX, DE
	POP BC
	ret
	DJNZ .loop									; Jump if B > 0 (loop starts with B = #spritesSize)

	RET

;----------------------------------------------------------;
;                  #AnimateEnemies                         ;
;----------------------------------------------------------;
AnimateEnemies
	 
	; Animate shots
	LD IX, sprite01	
	LD A, (spritesSize)
	LD B, A 
	CALL sr.AnimateSprites

	RET	

;----------------------------------------------------------;
;                      #WeaponHit                          ;
;----------------------------------------------------------;
WeaponHit
	LD IX, sprite01
	LD L, SPRITE_HEIGHT_WEAPON
	LD H, SPRITE_WIDTH_WEAPON
	LD A, (spritesSize)
	LD B, A
	CALL jw.WeaponHit
	RET	

;----------------------------------------------------------;
;                       #MoveEnemies                       ;
;----------------------------------------------------------;
; Modifies: ALL
MoveEnemies
	; Loop ever al enemies skipping hidden 
	LD IX, sprite01	
	LD A, (spritesSize)
	LD B, A 

.loop
	PUSH BC										; Preserve B for loop counter

	; Ignore this sprite if it's hidden
	LD A, (IX + sr.MSS.STATE)
	AND sr.MSS_STATE_VISIBLE					; Reset all bits but visibility
	CP 0
	JR Z, .continue								; Jump if visibility is not set (sprite is hidden)

	; Load extra data for this sprite to IY
	LD BC, (IX + sr.MSS.EXT_DATA_POINTER)
	LD IY, BC

	; Slow down movement by incrementing the counter until it reaches the configured value
	LD A, (IY + ESS.MOVE_DELAY)
	CP 0										; No delay? -> move at full speed
	JR Z, .afterDelayMove

	LD B, A										; Load goal for delay counter into B

	; Delaying movement, increment delay counter
	LD A, (IY + ESS.MOVE_DELAY_CNT)
	INC A
	LD (IY + ESS.MOVE_DELAY_CNT), A

	CP B										; B already contains #MOVE_DELAY
	JR NZ, .continue							; Return if the delay counter does not reach the required value.

	LD A, 0										; Reset the movement delay counter because it has reached the configured value
	LD (IY + ESS.MOVE_DELAY_CNT), A

.afterDelayMove

	; Sprite is visible, move it!
	CALL sr.SetSpriteId							; Set the ID of the sprite for the following commands

	CALL sr.MoveX
	CP sr.MOVE_RET_A_HIDDEN
	JR Z, .continue

	CALL sr.UpdateSpritePosition

	; Check the collision with the platform
	PUSH BC
	LD IY, platformBump
	LD L, SPRITE_HEIGHT_PLATFORM
	CALL sr.PlaftormColision
	POP BC

.continue	

	; Jump if B > 0 (loop starts with B = #MSS)
	POP BC
	DEC B
	LD A, B
	CP 0
	RET Z									; Exit if B has reached 0

	; Move IX to the beginning of the next #shotMssXX
	LD DE, sr.MSS
	ADD IX, DE

	JP .loop

	RET	



;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE			