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
MOVE_PATTERN			WORD					; Pointer to the movement pattern (#movePatternXX)
MOVE_PATTERN_CNT		BYTE					; Counter for repetition of single move pattern. Counts towards 0
MOVE_PATTERN_POS		BYTE					; Position in #MOVE_PATTERN. Counts from 0 to #movePatternXX.size-1
MOVE_PATTERN_STEP 		BYTE					; Counters X,Y from current move pattern

; Confugures move Pattern. Bits:
;  - 0 - avoid platforms by flying along them. When set, bits 1 and 2 will be ignored. The platform cannot destroy the enemy
;  - 1 - bounce from the platform horizontally
;  - 2 - bounce from the platform vertically
;  - 3-7 - not used yet
MOVE_CONFIG				BYTE
	ENDS

; Sprites for single enemy (#sprite), based on #MSS
; Each sprite has hardcoded respawn coordinates and the direction in which it moves
spriteEx01
	ESS {0/*MOVE_DELAY*/, 0/*MOVE_DELAY_CNT*/, 0/*RESPOWN_DELAY*/ ,0/*RESPOWN_DELAY_CNT*/, movePattern01/*MOVE_PATTERN*/, /*MOVE_PATTERN_CNT*/0, /*MOVE_PATTERN_POS*/0, 0/*MOVE_PATTERN_STEP*/, /*MOVE_CONFIG*/%00000000}
spriteEx02
	ESS {2/*MOVE_DELAY*/, 0/*MOVE_DELAY_CNT*/, 0/*RESPOWN_DELAY*/ ,0/*RESPOWN_DELAY_CNT*/, movePattern01/*MOVE_PATTERN*/, /*MOVE_PATTERN_CNT*/0, /*MOVE_PATTERN_POS*/0, 0/*MOVE_PATTERN_STEP*/, /*MOVE_CONFIG*/%00000000}
spriteEx03
	ESS {3/*MOVE_DELAY*/, 0/*MOVE_DELAY_CNT*/, 0/*RESPOWN_DELAY*/ ,0/*RESPOWN_DELAY_CNT*/, movePattern01/*MOVE_PATTERN*/, /*MOVE_PATTERN_CNT*/0, /*MOVE_PATTERN_POS*/0, 0/*MOVE_PATTERN_STEP*/, /*MOVE_CONFIG*/%00000000}
spriteEx04
	ESS {4/*MOVE_DELAY*/, 0/*MOVE_DELAY_CNT*/, 0/*RESPOWN_DELAY*/ ,0/*RESPOWN_DELAY_CNT*/, movePattern01/*MOVE_PATTERN*/, /*MOVE_PATTERN_CNT*/0, /*MOVE_PATTERN_POS*/0, 0/*MOVE_PATTERN_STEP*/, /*MOVE_CONFIG*/%00000000}
spriteEx05
	ESS {0/*MOVE_DELAY*/, 0/*MOVE_DELAY_CNT*/, 5/*RESPOWN_DELAY*/ ,0/*RESPOWN_DELAY_CNT*/, movePattern01/*MOVE_PATTERN*/, /*MOVE_PATTERN_CNT*/0, /*MOVE_PATTERN_POS*/0, 0/*MOVE_PATTERN_STEP*/, /*MOVE_CONFIG*/%00000000}
spriteEx06
	ESS {0/*MOVE_DELAY*/, 0/*MOVE_DELAY_CNT*/, 5/*RESPOWN_DELAY*/ ,0/*RESPOWN_DELAY_CNT*/, movePattern01/*MOVE_PATTERN*/, /*MOVE_PATTERN_CNT*/0, /*MOVE_PATTERN_POS*/0, 0/*MOVE_PATTERN_STEP*/, /*MOVE_CONFIG*/%00000000}
spriteEx07
	ESS {0/*MOVE_DELAY*/, 0/*MOVE_DELAY_CNT*/, 5/*RESPOWN_DELAY*/ ,0/*RESPOWN_DELAY_CNT*/, movePattern01/*MOVE_PATTERN*/, /*MOVE_PATTERN_CNT*/0, /*MOVE_PATTERN_POS*/0, 0/*MOVE_PATTERN_STEP*/, /*MOVE_CONFIG*/%00000000}
spriteEx08
	ESS {1/*MOVE_DELAY*/, 0/*MOVE_DELAY_CNT*/, 0/*RESPOWN_DELAY*/ ,0/*RESPOWN_DELAY_CNT*/, movePattern01/*MOVE_PATTERN*/, /*MOVE_PATTERN_CNT*/0, /*MOVE_PATTERN_POS*/0, 0/*MOVE_PATTERN_STEP*/, /*MOVE_CONFIG*/%00000000}
spriteEx09
	ESS {2/*MOVE_DELAY*/, 0/*MOVE_DELAY_CNT*/, 0/*RESPOWN_DELAY*/ ,0/*RESPOWN_DELAY_CNT*/, movePattern01/*MOVE_PATTERN*/, /*MOVE_PATTERN_CNT*/0, /*MOVE_PATTERN_POS*/0, 0/*MOVE_PATTERN_STEP*/, /*MOVE_CONFIG*/%00000000}
spriteEx10
	ESS {2/*MOVE_fDELAY*/, 0/*MOVE_DELAY_CNT*/, 0/*RESPOWN_DELAY*/ ,0/*RESPOWN_DELAY_CNT*/, movePattern01/*MOVE_PATTERN*/, /*MOVE_PATTERN_CNT*/0, /*MOVE_PATTERN_POS*/0, 0/*MOVE_PATTERN_STEP*/, /*MOVE_CONFIG*/%00000000}

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


; The move pattern is stored as a byte array. The first byte in this array holds the byte, indicating the number of patterns it contains. 
; Each pattern is then represented by 2 bytes: one for the pattern itself and the other for the number of times it should be repeated. 
; To illustrate, if the first byte is set to 5,  the move pattern will span a total of 11 bytes: 11 = 1 + 5 * 2.
;
; Each pattern determines a single step in this movement pattern: the number of pixels to move along the X axis (left or right),  
; the number of pixels to move along Y axis (up or down).
;
; The sprite travels only one pixel in each direction during each animation loop. If possible, it travels in both directions 
; (increasing X and Y by one). If the number of pixels in a particular direction has been reached, it will continue vertically or horizontally. 
;
; Bits:
; 0-3: number of pixels to move along X axis
; 4  : determines whether X should be decremented (0 - move left) or incremented (1 - move right) in each iteration. 
;      This flag is reversed if an enemy moves from right to left (#MSS.STATE -> bit 3 == 1)
; 4-6: number of pixels to move on Y axis
; 7 : determines whether Y should be decremented (0 - move up) or incremented (Y - move down) in each iteration
; 
; Example: for a move pattern: "%0'011'1'101, 10" the sprite will move 5 pixels on the X axis, 3 pixel on the Y axis, 
; and it will be repeated 10 times. In total sprite will travel: 5*10 pixels on X and 3*10 pixels on Y. 
; Below we have single step that will be repeated 10x.
; 1) INC X, DEC Y:	%0'000'1'000
; 2) INC X, DEC Y:	%0'001'1'001
; 3) INC X, DEC Y:	%0'010'1'010
; 4) _    , DEC Y:	%0'011'1'011
; 5) _,     DEC Y:	%0'011'1'100
; 6) _,     DEC Y:	%0'011'1'101
; In this example, both counters count up, and hoverer X position is increased (move right), and Y is decreased (move up).

MOVE_PAT_X_MASK			= %0'000'0'111
MOVE_PAT_X_ADD			= %0'000'0'001

MOVE_PAT_Y_MASK			= %0'111'0'000
MOVE_PAT_Y_ADD			= %0'001'0'000

MOVE_PAT_Y_INC_MASK		= %1'000'0'000

MOVE_PAT_XY_MASK		= %0'111'0'111
MOVE_PAT_XY_MASK_RES	= %1'000'1'000

MOVE_STEP_SIZE			= 2						; Each move pattern takes two bytes: pattern and number of repeats
MOVE_PAT_STEP_OFFSET	= 1						; Data for move pattern starts at byte 1, byte 0 provides size

; Horizontal movemment
movePattern01_
	DB 2, %0'000'1'111,$FF

; 20deg move down
movePattern01
	DB 2, %1'001'1'111,$FF

; 20deg move up
movePattern03
	DB 2, %0'001'1'111,$FF

; 45deg move down
movePattern04
	DB 2, %1'111'1'111,$FF

; 5x horizontal, 2x 45deg down,...
movePattern05
	DB 4, %0'000'1'111,5, %1'111'1'111,2

;----------------------------------------------------------;
;                   #ResetMovePattern                      ;
;----------------------------------------------------------;
; This method resets the move pattern (#ESS) so animation can start from the first move pattern. It does not modify #MSS.
; Input
;  - IX:	pointer to #MSS holding data for single spreite that will be moved
; Modifies: A, IY, BC, HL
RestartMovePattern

	LD BC, (IX + sr.MSS.EXT_DATA_POINTER)		; Load #ESS for this sprite to IY
	LD IY, BC
	LD HL, (IY + ESS.MOVE_PATTERN)				; HL points to start of the #movePattern, that is the amount of elements in this pattern.
	INC HL										; HL points to the first move pattern element	
	
	; X, Y counters will be set to max value as we count down towards 0
	LD A, (HL)
	LD (IY + ESS.MOVE_PATTERN_STEP), A	

	; Set position at the first pattern, this is one byte after the start of #movePatternXX
	LD A, MOVE_PAT_STEP_OFFSET
	LD (IY + ESS.MOVE_PATTERN_POS), A

	; Set MOVE_PATTERN_CNT to the counter from first pattern
	LD A, MOVE_PAT_STEP_OFFSET
	ADD HL, A									; Move HL to the counter for the first pattern
	LD A, (HL)
	LD (IY + ESS.MOVE_PATTERN_CNT), A

	RET	

;----------------------------------------------------------;
;                      #MoveEnemy                          ;
;----------------------------------------------------------;
; Input
;  - IX:	pointer to #MSS holding data for single spreite that will be moved
; Output:
;  - A: 	sr.MOVE_RET_A_XXX
; Modifies: all
MoveEnemy

	; Move the Sprite horizontally if it has been hit and it's dying
	LD A, (IX + sr.MSS.STATE)
	CALL sr.SetSpriteId							; Set sprite ID in hardware

	LD A, (IX + sr.MSS.STATE)
	AND sr.MSS_STATE_ALIVE						; Reset all bits but alive
	CP sr.MSS_STATE_ALIVE
	JR Z, .afterAliveCheck						; Jump if sprite is alive

	LD A, (IX + sr.MSS.STATE)

	; Move the sprite horizontally while it's exploding
	CALL sr.MoveX
	CALL sr.UpdateSpritePosition				; Move sprite to new X,Y coordinates

	LD A, sr.MOVE_RET_A_VISIBLE
	RET
.afterAliveCheck

	; Load #ESS for this sprite to IY
	LD BC, (IX + sr.MSS.EXT_DATA_POINTER)
	LD IY, BC

	LD HL, (IY + ESS.MOVE_PATTERN)				; HL points to start of the #movePattern
	LD B, (HL)									; B contains  the amount of bytes in the move pattern

	; Check if we should restart the move pattern, as it might have reached the last element
	LD A, (IY + ESS.MOVE_PATTERN_POS)
	SUB MOVE_PAT_STEP_OFFSET					; pattern starts after offset
	CP B
	JR C, .afterRestartMovePattern				; Jump if move counter can be increased
	
	CALL RestartMovePattern						; Restart move pattern, it has reached max value
.afterRestartMovePattern

	; Move HL from the beginning of the move pattern to current position
	LD A, (IY + ESS.MOVE_PATTERN_POS)
	ADD HL, A

	; Current register values:
	;  - IX: pointer to #MSS for current sprite
	;  - IY: pointer to #ESS for current sprite
	;  - HL: pointer to current position in #movePattern

	; Check if counter for X has already reached 0
	LD A, (IY + ESS.MOVE_PATTERN_STEP)			; A contains orginal pattern counter
	AND MOVE_PAT_X_MASK							; Reset all but X
	CP 0
	JR Z, .afterIncX							; Jump if the counter for X has reached 0
	
	; Decrement X counter
	LD A, (IY + ESS.MOVE_PATTERN_STEP)			; A contains orginal pattern counter
	SUB MOVE_PAT_X_ADD							; Decrement X counter by 1		
	LD (IY + ESS.MOVE_PATTERN_STEP), A

	CALL sr.MoveX								; Move one pixel left/right and check if the sprite is still visible (it could be out of the screen)
	CP sr.MOVE_RET_A_HIDDEN	
	JR NZ,.afterIncX							; Jump is sprite is not hidden

	LD A, sr.MOVE_RET_A_HIDDEN
	RET											; Stop moving this spirte, it's hidden
.afterIncX

	; Check if counter for Y has already reached 0
	LD A, (IY + ESS.MOVE_PATTERN_STEP)			; A contains orginal pattern counter
	AND MOVE_PAT_Y_MASK							; Reset all but Y
	CP 0
	JR Z, .afterChangeY							; Jump if the counter for Y has reached 0
	
	LD A, (IY + ESS.MOVE_PATTERN_STEP)			; A contains orginal pattern counter
	SUB MOVE_PAT_Y_ADD							; Decrement Y counter by 1
	LD (IY + ESS.MOVE_PATTERN_STEP), A	

	; Move on Y-axis one pixel up or down?
	LD A, (HL)									; A contains current pattern
	AND MOVE_PAT_Y_INC_MASK						; Reset all except a bit, determining whether Y should be incremented or decremented
	CP MOVE_PAT_Y_INC_MASK
	JR NZ, .incY								; Jump if Y should be incremented

	; Move on pixel down	
	LD A, sr.MOVE_Y_IN_A_DOWN
	CALL sr.MoveY
	CP sr.MOVE_RET_A_HIDDEN
	JR NZ,.afterChangeY							; Jump is sprite is not hidden

	LD A, sr.MOVE_RET_A_HIDDEN
	RET											; Stop moving this spirte, it's hidden

.incY
	; Move on pixel up
	LD A, sr.MOVE_Y_IN_A_UP
	CALL sr.MoveY
	CP sr.MOVE_RET_A_HIDDEN
	JR NZ,.afterChangeY							; Jump is sprite is not hidden

	LD A, sr.MOVE_RET_A_HIDDEN	
	RET											; Stop moving this spirte, it's hidden

.afterChangeY
	CALL sr.UpdateSpritePosition				; Move sprite to new X,Y coordinates

	; Check if X and Y have reached 0
	LD A, (IY + ESS.MOVE_PATTERN_STEP)			; A contains pattern counter	
	AND MOVE_PAT_XY_MASK						; Reset all but max X,Y values
	CP 0
	JR Z, .resetXYCounters						; Jump if X and Y counters has reached 0

	LD A, sr.MOVE_RET_A_VISIBLE
	RET
.resetXYCounters

	; X and Y have reached the max value. First, reset the X and Y counters, and afterward, decrease the repetition counter
	LD A, (HL)									; X, Y counters will be set to max value as we count down towards 0
	LD (IY + ESS.MOVE_PATTERN_STEP), A	

	LD A, (IY + ESS.MOVE_PATTERN_CNT)			; Decrease the repetition counter
	DEC A
	CP 0
	JR Z, .nextMovePattern						; Jump if the countdown is done
	
	LD (IY + ESS.MOVE_PATTERN_CNT), A			; Store decreased counter, Y,X are 0

	LD A, sr.MOVE_RET_A_VISIBLE
	RET

.nextMovePattern

	; Move MOVE_PATTERN_POS to next pattern
	LD A, (IY + ESS.MOVE_PATTERN_POS)			; A contains the current position in the move pattern
	ADD MOVE_STEP_SIZE							; Increment the position to the next patern and store it
	LD (IY + ESS.MOVE_PATTERN_POS), A

	; Set MOVE_PATTERN_CNT to the value from next pattern 
	LD BC, HL									; BC points to current position in #movePatternXX
	INC BC										; Move BC to the counter for current pattern
	INC BC										; Move BC to the next pattern
	INC BC										; Move BC to the counter for the next pattern
	LD A, (BC)
	LD (IY + ESS.MOVE_PATTERN_CNT), A

	RET	

;----------------------------------------------------------;
;                       #MoveEnemies                       ;
;----------------------------------------------------------;
; Modifies: ALL
MoveEnemies

	; Loop ever all enemies skipping hidden 
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
	JR NZ, .continue							; Return if the delay counter does not reach the required value

	LD A, 0										; Reset the movement delay counter because it has reached the configured value
	LD (IY + ESS.MOVE_DELAY_CNT), A

.afterDelayMove

	; Sprite is visible, move it!
	CALL MoveEnemy
	CP sr.MOVE_RET_A_HIDDEN
	JR Z, .continue

	; Check the collision with the platform
	LD IY, jp.platformBump
	LD L, SPRITE_HEIGHT_PLATFORM
	CALL sr.PlaftormColision

.continue	

	; Jump if B > 0 (loop starts with B = #MSS)
	POP BC
	DEC B
	LD A, B
	CP 0
	RET Z									; Exit if B has reached 0

	; Move IX to the beginning of the next #MSS
	LD DE, sr.MSS
	ADD IX, DE
	JP .loop

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
	CALL RestartMovePattern

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
	DJNZ .loop									; Jump if B > 0 (loop starts with B = #spritesSize)

	RET

;----------------------------------------------------------;
;                  #AnimateEnemies                         ;
;----------------------------------------------------------;
AnimateEnemies
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
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE