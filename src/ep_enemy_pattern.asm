;----------------------------------------------------------;
;             Single 16x16 Flying Enemy                    ;
;----------------------------------------------------------;
	MODULE ep

; The timer ticks with every game loop. When it reaches #EN_RESPOWN_DELAY, a single enemy will respawn, and the timer starts from 0, counting again.
respownDelayCnt 			DB 0
respownDelay 				DB 20				; Amount of game loops to respawn single enemy

; Extends #MSS by additional params.
	STRUCT ESS
MOVE_DELAY_CNT			BYTE					; Move delay counter, counting down. Move delay is specified in the move pattern, byte 2, bits 8-5. Bit 0-4 is the repetition counter.
RESPOWN_DELAY			BYTE					; Number of game loops delaying respawn
RESPOWN_DELAY_CNT		BYTE					; Respawn delay counter
RESPOWN_Y				BYTE					; Repown Y position
MOVE_PATTERN_POINTER	WORD					; Pointer to the movement pattern (#movePatternXX)
MOVE_PATTERN_CNT		BYTE					; Counter for repetition of single move pattern. Counts towards 0
MOVE_PATTERN_POS		BYTE					; Position in #MOVE_PATTERN_POINTER. Counts from #MOVE_PAT_STEP_OFFSET to #movePatternXX.size
MOVE_PATTERN_STEP 		BYTE					; Counters X,Y from current move pattern
	ENDS
; Bits 4-7 on sr.STATE will be used here:

MOVE_DELAY_CNT_INC		= %0001'0000

; Avoid platforms by flying along them. When set, bits 1 and 2 will be ignored. The platform cannot destroy the enemy
MSS_STATE_ALONG_BIT		= 4

; Sprites for single enemy (#sprite), based on #MSS
; Each sprite has hardcoded respawn coordinates and the direction in which it moves
spriteEx01
	ESS {0/*MOVE_DELAY_CNT*/, 5/*RESPOWN_DELAY*/ ,0/*RESPOWN_DELAY_CNT*/, 40/*RESPOWN_Y*/, movePattern01/*MOVE_PATTERN_POINTER*/, /*MOVE_PATTERN_CNT*/0, /*MOVE_PATTERN_POS*/MOVE_PAT_STEP_OFFSET, 0/*MOVE_PATTERN_STEP*/}
spriteEx02
	ESS {0/*MOVE_DELAY_CNT*/, 0/*RESPOWN_DELAY*/ ,0/*RESPOWN_DELAY_CNT*/, 50/*RESPOWN_Y*/, movePattern01/*MOVE_PATTERN_POINTER*/, /*MOVE_PATTERN_CNT*/0, /*MOVE_PATTERN_POS*/MOVE_PAT_STEP_OFFSET, 0/*MOVE_PATTERN_STEP*/}
spriteEx03
	ESS {0/*MOVE_DELAY_CNT*/, 0/*RESPOWN_DELAY*/ ,0/*RESPOWN_DELAY_CNT*/, 60/*RESPOWN_Y*/, movePattern01/*MOVE_PATTERN_POINTER*/, /*MOVE_PATTERN_CNT*/0, /*MOVE_PATTERN_POS*/MOVE_PAT_STEP_OFFSET, 0/*MOVE_PATTERN_STEP*/}
spriteEx04
	ESS {0/*MOVE_DELAY_CNT*/, 0/*RESPOWN_DELAY*/ ,0/*RESPOWN_DELAY_CNT*/, 80/*RESPOWN_Y*/, movePattern01/*MOVE_PATTERN_POINTER*/, /*MOVE_PATTERN_CNT*/0, /*MOVE_PATTERN_POS*/MOVE_PAT_STEP_OFFSET, 0/*MOVE_PATTERN_STEP*/}
spriteEx05
	ESS {0/*MOVE_DELAY_CNT*/, 5/*RESPOWN_DELAY*/ ,0/*RESPOWN_DELAY_CNT*/, 100/*RESPOWN_Y*/, movePattern01/*MOVE_PATTERN_POINTER*/, /*MOVE_PATTERN_CNT*/0, /*MOVE_PATTERN_POS*/MOVE_PAT_STEP_OFFSET, 0/*MOVE_PATTERN_STEP*/}
spriteEx06
	ESS {0/*MOVE_DELAY_CNT*/, 5/*RESPOWN_DELAY*/ ,0/*RESPOWN_DELAY_CNT*/, 120/*RESPOWN_Y*/, movePattern01/*MOVE_PATTERN_POINTER*/, /*MOVE_PATTERN_CNT*/0, /*MOVE_PATTERN_POS*/MOVE_PAT_STEP_OFFSET, 0/*MOVE_PATTERN_STEP*/}
spriteEx07
	ESS {0/*MOVE_DELAY_CNT*/, 5/*RESPOWN_DELAY*/ ,0/*RESPOWN_DELAY_CNT*/, 140/*RESPOWN_Y*/, movePattern01/*MOVE_PATTERN_POINTER*/, /*MOVE_PATTERN_CNT*/0, /*MOVE_PATTERN_POS*/MOVE_PAT_STEP_OFFSET, 0/*MOVE_PATTERN_STEP*/}
spriteEx08
	ESS {0/*MOVE_DELAY_CNT*/, 0/*RESPOWN_DELAY*/ ,0/*RESPOWN_DELAY_CNT*/, 160/*RESPOWN_Y*/, movePattern01/*MOVE_PATTERN_POINTER*/, /*MOVE_PATTERN_CNT*/0, /*MOVE_PATTERN_POS*/MOVE_PAT_STEP_OFFSET, 0/*MOVE_PATTERN_STEP*/}
spriteEx09
	ESS {0/*MOVE_DELAY_CNT*/, 0/*RESPOWN_DELAY*/ ,0/*RESPOWN_DELAY_CNT*/, 180/*RESPOWN_Y*/, movePattern01/*MOVE_PATTERN_POINTER*/, /*MOVE_PATTERN_CNT*/0, /*MOVE_PATTERN_POS*/MOVE_PAT_STEP_OFFSET, 0/*MOVE_PATTERN_STEP*/}
spriteEx10
	ESS {0/*MOVE_DELAY_CNT*/, 2/*RESPOWN_DELAY*/ ,0/*RESPOWN_DELAY_CNT*/, 200/*RESPOWN_Y*/, movePattern01/*MOVE_PATTERN_POINTER*/, /*MOVE_PATTERN_CNT*/0, /*MOVE_PATTERN_POS*/MOVE_PAT_STEP_OFFSET, 0/*MOVE_PATTERN_STEP*/}

; Formation Sprites
spriteExEf01
	ESS {0/*MOVE_DELAY_CNT*/, 0/*RESPOWN_DELAY*/ ,0/*RESPOWN_DELAY_CNT*/, 170/*RESPOWN_Y*/, movePattern01/*MOVE_PATTERN_POINTER*/, /*MOVE_PATTERN_CNT*/0, /*MOVE_PATTERN_POS*/MOVE_PAT_STEP_OFFSET, 0/*MOVE_PATTERN_STEP*/}
spriteExEf02
	ESS {0/*MOVE_DELAY_CNT*/, 100/*RESPOWN_DELAY*/ ,0/*RESPOWN_DELAY_CNT*/, 170/*RESPOWN_Y*/, movePattern01/*MOVE_PATTERN_POINTER*/, /*MOVE_PATTERN_CNT*/0, /*MOVE_PATTERN_POS*/MOVE_PAT_STEP_OFFSET, 0/*MOVE_PATTERN_STEP*/}
spriteExEf03
	ESS {0/*MOVE_DELAY_CNT*/, 100/*RESPOWN_DELAY*/ ,0/*RESPOWN_DELAY_CNT*/, 170/*RESPOWN_Y*/, movePattern01/*MOVE_PATTERN_POINTER*/, /*MOVE_PATTERN_CNT*/0, /*MOVE_PATTERN_POS*/MOVE_PAT_STEP_OFFSET, 0/*MOVE_PATTERN_STEP*/}
spriteExEf04
	ESS {0/*MOVE_DELAY_CNT*/, 100/*RESPOWN_DELAY*/ ,0/*RESPOWN_DELAY_CNT*/, 170/*RESPOWN_Y*/, movePattern01/*MOVE_PATTERN_POINTER*/, /*MOVE_PATTERN_CNT*/0, /*MOVE_PATTERN_POS*/MOVE_PAT_STEP_OFFSET, 0/*MOVE_PATTERN_STEP*/}
spriteExEf05
	ESS {0/*MOVE_DELAY_CNT*/, 100/*RESPOWN_DELAY*/ ,0/*RESPOWN_DELAY_CNT*/, 170/*RESPOWN_Y*/, movePattern01/*MOVE_PATTERN_POINTER*/, /*MOVE_PATTERN_CNT*/0, /*MOVE_PATTERN_POS*/MOVE_PAT_STEP_OFFSET, 0/*MOVE_PATTERN_STEP*/}

sprite01
	sr.MSS {20/*ID*/, sr.SDB_COMET1/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, %00'0'1'0'000/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx01/*EXT_DATA_POINTER*/}
sprite02
	sr.MSS {21/*ID*/, sr.SDB_COMET1/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, %00'0'1'0'000/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx02/*EXT_DATA_POINTER*/}
sprite03
	sr.MSS {22/*ID*/, sr.SDB_COMET1/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, %00'0'1'1'000/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx03/*EXT_DATA_POINTER*/}
sprite04
	sr.MSS {23/*ID*/, sr.SDB_COMET1/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, %00'0'1'0'000/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx04/*EXT_DATA_POINTER*/}
sprite05
	sr.MSS {24/*ID*/, sr.SDB_COMET2/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, %00'0'1'1'000/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx05/*EXT_DATA_POINTER*/}
sprite06
	sr.MSS {25/*ID*/, sr.SDB_COMET2/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, %00'0'1'0'000/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx06/*EXT_DATA_POINTER*/}
sprite07
	sr.MSS {26/*ID*/, sr.SDB_COMET2/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, %00'0'1'1'000/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx07/*EXT_DATA_POINTER*/}
sprite08
	sr.MSS {27/*ID*/, sr.SDB_COMET1/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, %00'0'1'0'000/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx08/*EXT_DATA_POINTER*/}
sprite09
	sr.MSS {28/*ID*/, sr.SDB_COMET1/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, %00'0'1'1'000/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx09/*EXT_DATA_POINTER*/}
sprite10
	sr.MSS {29/*ID*/, sr.SDB_COMET1/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, %00'0'1'0'000/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx10/*EXT_DATA_POINTER*/}

; Formation Sprites
spriteEf01
	sr.MSS {30/*ID*/, sr.SDB_COMET1/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, %00'0'1'0'000/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteExEf01/*EXT_DATA_POINTER*/}
spriteEf02
	sr.MSS {31/*ID*/, sr.SDB_COMET1/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, %00'0'1'0'000/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteExEf02/*EXT_DATA_POINTER*/}
spriteEf03
	sr.MSS {32/*ID*/, sr.SDB_COMET1/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, %00'0'1'0'000/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteExEf03/*EXT_DATA_POINTER*/}
spriteEf04
	sr.MSS {33/*ID*/, sr.SDB_COMET1/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, %00'0'1'0'000/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteExEf04/*EXT_DATA_POINTER*/}
spriteEf05
	sr.MSS {34/*ID*/, sr.SDB_COMET1/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, %00'0'1'0'000/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteExEf05/*EXT_DATA_POINTER*/}

spritesSize					DB 15				; The total amount of visible sprites - including single enemies and formations
singleSpritesSize			DB 1				; Amount of sprites that can respawn as a single enemy

SPRITE_HEIGHT_PLATFORM		= 3
SPRITE_HEIGHT_COLISION		= 10

SPRITE_HEIGHT_WEAPON		= 8
SPRITE_WIDTH_WEAPON			= 8

; The move pattern is stored as a byte array. The first byte in this array holds the byte, indicating the number of patterns it contains. 
; This single byte is followed by move patterns, where each pattern consists of two bytes: first for the pattern itself and the second 
; holding the movement delay (bits 8-5) and the number of times it should be repeated (bits 4-0).
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
; 4:   determines whether X should be decremented (0 - move left) or incremented (1 - move right) in each iteration. 
;      This flag is reversed if an enemy moves from right to left (#MSS.STATE -> bit 3 == 1)
; 4-6: number of pixels to move on Y axis
; 7:   determines whether Y should be decremented (0 - move up) or incremented (1 - move down) in each iteration
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
MOVE_PAT_Y_INC_BIT		= 7

MOVE_PAT_XY_MASK		= %0'111'0'111
MOVE_PAT_XY_MASK_RES	= %1'000'1'000

MOVE_STEP_SIZE			= 2						; Each move step in the pattern takes two bytes: pattern and delay/number of repeats
MOVE_STEP_CNT_OFF		= 1
MOVE_PAT_STEP_OFFSET	= 1						; Data for move pattern starts at byte 1, byte 0 provides size
MOVE_PAT_REPEAT_MASK	= %0000'1111
MOVE_PAT_DELAY_MASK		= %1111'0000

; Horizontal movemment
movePattern01_
	DB 2, %0'000'1'111,$0F

; 10deg move down
movePattern02
	DB 2, %1'001'1'111,$0F

; 10deg move up
movePattern03
	DB 2, %0'001'1'111,$0F

; 45deg move down
movePattern01
	DB 2, %1'001'1'001,$52

; 5x horizontal, 2x 45deg down,...
movePattern05
	DB 4, %0'000'1'111,5, %1'111'1'111,2

; Half sinus
movePattern06
	DB 32, %0'010'1'001,$02, %0'011'1'010,$02, %0'100'1'011,$01, %0'011'1'011,$01, %0'010'1'011,$03, %0'001'1'011,$02, %0'001'1'100,$02, %0'001'1'101,$01 	; going up
		DB %1'001'1'101,$01, %1'001'1'100,$02, %1'001'1'011,$02, %1'010'1'011,$03, %1'011'1'011,$01, %1'100'1'011,$01, %1'011'1'010,$02, %1'010'1'001,$02	; going down		

; sinus
movePattern07
	DB 64, %0'010'1'001,$52, %0'011'1'010,$52, %0'100'1'011,$51, %0'011'1'011,$51, %0'010'1'011,$53, %0'001'1'011,$52, %0'001'1'100,$52, %0'001'1'101,$51 	; going up, above X
		DB %1'001'1'101,$51, %1'001'1'100,$52, %1'001'1'011,$52, %1'010'1'011,$53, %1'011'1'011,$51, %1'100'1'011,$51, %1'011'1'010,$52, %1'010'1'001,$52	; going down, above X
		DB %1'010'1'001,$52, %1'011'1'010,$52, %1'100'1'011,$51, %1'011'1'011,$51, %1'010'1'011,$53, %1'001'1'011,$52, %1'001'1'100,$52, %1'001'1'101,$51 	; going down, below X
		DB %0'001'1'101,$51, %0'001'1'100,$52, %0'001'1'011,$52, %0'010'1'011,$53, %0'011'1'011,$51, %0'100'1'011,$51, %0'011'1'010,$52, %0'010'1'001,$52	; going up, below X	
		
; Square wave
movePattern08
	DB 8, %0'000'1'111,5, %1'111'1'000,3, %0'000'1'111,5, %0'111'1'000,3

; Triangle wave
movePattern09
	DB 4, %0'111'1'111,5, %1'111'1'111,5

; Square,triangle wave
movePattern10
	DB 24, %0'000'1'111,5, %1'111'1'000,3, %0'000'1'111,5, %0'111'1'000,3, %0'000'1'111,5, %1'111'1'000,3, %0'000'1'111,5, %0'111'1'000,3, %1'111'1'111,3, %0'111'1'111,3, %1'111'1'111,3, %0'111'1'111,3

;----------------------------------------------------------;
;                  #RestartMovePattern                     ;
;----------------------------------------------------------;
; This method resets the move pattern (#ESS) so animation can start from the first move pattern. It does not modify #MSS.
; Input
;  - IX:	pointer to #MSS holding data for single spreite that will be moved
; Modifies: A, IY, BC, HL
RestartMovePattern

	LD BC, (IX + sr.MSS.EXT_DATA_POINTER)		; Load #ESS for this sprite to IY
	LD IY, BC
	LD HL, (IY + ESS.MOVE_PATTERN_POINTER)		; HL points to start of the #movePattern, that is the amount of elements in this pattern.
	INC HL										; HL points to the first move pattern element	
	
	; X, Y counters will be set to max value as we count down towards 0
	LD A, (HL)
	LD (IY + ESS.MOVE_PATTERN_STEP), A	

	; Set position at the first pattern, this is one byte after the start of #movePatternXX
	LD A, MOVE_PAT_STEP_OFFSET
	LD (IY + ESS.MOVE_PATTERN_POS), A

	; Set pattern counters to the first pattern
	INC HL										; HL points to delay/repeat counter byte
	LD A, (HL)
	LD B, A

	; Set repeat counter
	AND MOVE_PAT_REPEAT_MASK					; Leave only repeat counter bits
	LD (IY + ESS.MOVE_PATTERN_CNT), A

	; Set delay counter 
	LD A, B
	AND MOVE_PAT_DELAY_MASK						; Leave only delay counter bits	
	LD (IY + ESS.MOVE_DELAY_CNT), A

	RET	

;----------------------------------------------------------;
;                      #MoveEnemy                          ;
;----------------------------------------------------------;
; Input
;  - IX:	pointer to #MSS holding data for single spreite that will be moved
; Output:
;  - A: 	sr.MOVE_RET_XXX
; Modifies: all
MoveEnemy

	; Move the Sprite horizontally if it has been hit and it's dying
	LD A, (IX + sr.MSS.STATE)
	CALL sr.SetSpriteId							; Set sprite ID in hardware

	LD A, (IX + sr.MSS.STATE)
	BIT sr.MSS_STATE_ALIVE_BIT, A
	JR NZ, .afterAliveCheck						; Jump if sprite is alive

	LD A, (IX + sr.MSS.STATE)

	; Move the sprite horizontally while it's exploding
	CALL sr.MoveX
	CALL sr.UpdateSpritePosition				; Move sprite to new X,Y coordinates

	LD A, sr.MOVE_RET_VISIBLE
	RET
.afterAliveCheck

	; Load #ESS for this sprite to IY
	LD BC, (IX + sr.MSS.EXT_DATA_POINTER)
	LD IY, BC

	; Should the enemy move along the platform to avoid collision?
	LD A, (IX + sr.MSS.STATE)
	BIT MSS_STATE_ALONG_BIT, A
	JR Z, .afterMoveAlong						; Jump if move along is not set

	; Check the collision with the platform
	PUSH IY
	LD IY, jp.platformBump
	LD L, SPRITE_HEIGHT_COLISION
	CALL sr.PlaftormColision
	POP IY

	CP A, sr.PL_COL_RET_A_NO
	JR Z, .afterMoveAlong						; Jump if there is no collision

	; Avoid collision with the platform by moving along it 
	CALL sr.MoveX
	CALL sr.UpdateSpritePosition				; Move sprite to new X,Y coordinates
	RET
.afterMoveAlong
	LD HL, (IY + ESS.MOVE_PATTERN_POINTER)		; HL points to start of the #movePattern

	; Check if we should restart the move pattern, as it might have reached the last element
	LD A, (IY + ESS.MOVE_PATTERN_POS)			; A contains the current position in the move pattern array
	DEC A										; Pattern starts after offset

	LD B, (HL)									; B contains the amount of bytes in the move pattern array
	CP B
	JR NC, .restartMovePattern					; Jump A >= B -> (current postion >= size)
	JR .afterRestartMovePattern
.restartMovePattern
	CALL RestartMovePattern						; Restart move pattern, it has reached max value
	RET
.afterRestartMovePattern
		
	; Move HL from the beginning of the move pattern to current element
	LD A, (IY + ESS.MOVE_PATTERN_POS)
	ADD HL, A

	; Current register values:
	;  - IX: pointer to #MSS for current sprite
	;  - IY: pointer to #ESS for current sprite
	;  - HL: pointer to current position in #movePattern

	; Check if counter for X has already reached 0, or is set to 0
	LD A, (IY + ESS.MOVE_PATTERN_STEP)			; A contains orginal pattern counter
	AND MOVE_PAT_X_MASK							; Reset all but X
	CP 0
	JR Z, .afterIncX							; Jump if the counter for X has reached 0
	
	; Decrement X counter
	LD A, (IY + ESS.MOVE_PATTERN_STEP)			; A contains orginal pattern counter
	SUB MOVE_PAT_X_ADD							; Decrement X counter by 1
	LD (IY + ESS.MOVE_PATTERN_STEP), A

	CALL sr.MoveX								; Move one pixel left/right and check if the sprite is still visible (it could be out of the screen)
	CP sr.MOVE_RET_HIDDEN	
	JR NZ,.afterIncX							; Jump is sprite is not hidden

	LD A, sr.MOVE_RET_HIDDEN
	RET											; Stop moving this spirte, it's hidden
.afterIncX

	; Check if counter for Y has already reached 0, or is set to 0
	LD A, (IY + ESS.MOVE_PATTERN_STEP)			; A contains orginal pattern counter
	AND MOVE_PAT_Y_MASK							; Reset all but Y
	CP 0
	JR Z, .afterChangeY							; Jump if the counter for Y has reached 0
	
	LD A, (IY + ESS.MOVE_PATTERN_STEP)			; A contains orginal pattern counter
	SUB MOVE_PAT_Y_ADD							; Decrement Y counter by 1
	LD (IY + ESS.MOVE_PATTERN_STEP), A	

	; Move on Y-axis one pixel up or down?
	LD A, (HL)									; A contains current pattern
	BIT MOVE_PAT_Y_INC_BIT, A
	JR Z, .incY									; Jump if Y should be incremented

	; Move on pixel down	
	LD A, sr.MOVE_Y_IN_DOWN
	CALL sr.MoveY
	CP sr.MOVE_RET_HIDDEN
	JR NZ,.afterChangeY							; Jump is sprite is not hidden

	LD A, sr.MOVE_RET_HIDDEN
	RET											; Stop moving this spirte, it's hidden

.incY
	; Move on pixel up
	LD A, sr.MOVE_Y_IN_UP
	CALL sr.MoveY
	CP sr.MOVE_RET_HIDDEN
	JR NZ,.afterChangeY							; Jump is sprite is not hidden

	LD A, sr.MOVE_RET_HIDDEN	
	RET											; Stop moving this spirte, it's hidden

.afterChangeY
	CALL sr.UpdateSpritePosition				; Move sprite to new X,Y coordinates

	; Check if X and Y have reached 0
	LD A, (IY + ESS.MOVE_PATTERN_STEP)			; A contains pattern counter	
	AND MOVE_PAT_XY_MASK						; Reset all but max X,Y values
	CP 0
	JR Z, .resetXYCounters						; Jump if X and Y counters has reached 0

	LD A, sr.MOVE_RET_VISIBLE
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

	LD A, sr.MOVE_RET_VISIBLE
	RET

.nextMovePattern
	; Setup next move pattern
	LD A, (IY + ESS.MOVE_PATTERN_POS)			; A contains the current position in the move pattern
	ADD MOVE_STEP_SIZE							; Increment the position to the next patern and store it
	LD (IY + ESS.MOVE_PATTERN_POS), A

	LD BC, HL									; BC points to current position in #movePatternXX
	INC BC										; Move BC to the counter for current pattern
	INC BC										; Move BC to the next pattern
	
	LD A, (BC)									; X, Y counters will be set to max value as we count down towards 0
	LD (IY + ESS.MOVE_PATTERN_STEP), A	

	INC BC										; Move BC to the counter for the next pattern
	LD A, (BC)									; Load delay/repeat counter into A
	LD D, A

	; Set pattern counter for next pattern
	AND MOVE_PAT_REPEAT_MASK					; Leave only repeat counter bits
	LD (IY + ESS.MOVE_PATTERN_CNT), A

	; Set delay counter for next pattern
	LD A, D
	AND MOVE_PAT_DELAY_MASK						; Leave only delay counter bits	
	LD (IY + ESS.MOVE_DELAY_CNT), A

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

	; Slow down movement by decrementing the counter until it reaches 0
	LD A, (IY + ESS.MOVE_DELAY_CNT)
	CP 0										; No delay? -> move at full speed
	JR Z, .afterDelayMove

	; Delaying movement, decrement delay counter
	SUB MOVE_DELAY_CNT_INC
	LD (IY + ESS.MOVE_DELAY_CNT), A

	CP 0										
	JR NZ, .continue							; Skipp enemy if the delay counter > 0

	CALL LoadMoveDelayCounter		
	LD (IY + ESS.MOVE_DELAY_CNT), A				; Reset counter, A has the max value of delay counter

.afterDelayMove

	; Sprite is visible, move it!
	CALL MoveEnemy
	CP sr.MOVE_RET_HIDDEN
	JR Z, .continue

	; Check the collision with the platform
	LD IY, jp.platformBump
	LD L, SPRITE_HEIGHT_PLATFORM
	CALL sr.PlaftormColision
	CP A, sr.PL_COL_RET_A_NO
	JR Z, .continue   
	CALL sr.SpriteHit

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
;                 #LoadMoveDelayCounter                    ;
;----------------------------------------------------------;
; Input
;  - IY:	pointer to #ESS holding data for single spreite 
; Output:
;  - A;		value of move delay counter for this pattern (bits 8-5)
; Modifies: A, HL
LoadMoveDelayCounter

	; Set ESS.MOVE_DELAY to value from current move pattern
	LD HL, (IY + ESS.MOVE_PATTERN_POINTER)		; HL points to start of the #movePattern, that is the amount of elements in this pattern.

	; Move HL to the current pattern, not first byte, but the second, because this one contains a delay and repetition counter
	LD A, (IY + ESS.MOVE_PATTERN_POS)
	INC A
	ADD HL, A									; Now HL points to movement delay in current pattern	
	LD A, (HL)									; Load the delay/repetition counter into A, reset all bits but delay, and shift to the proper number
	AND MOVE_PAT_DELAY_MASK
	RET
	
;----------------------------------------------------------;
;                  #RespownNextEnemy                       ;
;----------------------------------------------------------;
RespownNextEnemy

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

	; Respawn the enemy
	LD IX, sprite01								; Iterate over all enemies to find the first hidden, respawn it, and exit function
	LD A, (singleSpritesSize)
	LD B, A 
.loop
	PUSH BC										; Preserve B for loop counter
	CALL RespownEnemy
	POP BC

	CP A, RES_SE_OUT_YES
	RET Z										; Exit after respawning first enemy
										
.continue
	; Move IX to the beginning of the next #shotMssXX
	LD DE, sr.MSS
	ADD IX, DE
	DJNZ .loop									; Jump if B > 0 (loop starts with B = #singleSpritesSize)

	RET

;----------------------------------------------------------;
;                    #RespownEnemy                         ;
;----------------------------------------------------------;
; Input
;  - IX:	pointer to #MSS holding data for single enemy
; Output:
; - A: 		RES_SE_OUT_XXX
RES_SE_OUT_YES					= 1				; Enemy did respawn
RES_SE_OUT_NO					= 0				; Enemy did not respawn
; Modifies: all
RespownEnemy
	
	LD A, (IX + sr.MSS.STATE)
	BIT sr.MSS_STATE_VISIBLE_BIT, A
	JR Z, .afterVisibilityCheck					; Skipp this sprite if it's already visible
	
	LD A, RES_SE_OUT_NO
	RET
.afterVisibilityCheck
	; Sprite is hidden; check the dedicated delay before respawning

	; Load extra sprite data (#ESS) to IY
	LD BC, (IX + sr.MSS.EXT_DATA_POINTER)
	LD IY, BC
	
	; There are two respawn delay timers. The first is global (#respownDelayCnt) and ensures that multiple enemies do not respawn at the same time.
	; The second timer can be configured for a single enemy, which further delays its comeback. 
	LD A, (IY + ESS.RESPOWN_DELAY)
	CP 0
	
	JR Z, .afterEnemyRespownDelay				; Jump if there is no extra delay for this enemy
		
	LD B, A	
	LD A, (IY + ESS.RESPOWN_DELAY_CNT)
	INC A
	CP B
	JR Z, .afterEnemyRespownDelay				; Jump if the timer reaches respawn delay

	LD (IY + ESS.RESPOWN_DELAY_CNT), A			; The delay timer for the enemy is still ticking

	LD A, RES_SE_OUT_NO	
	RET
.afterEnemyRespownDelay

	; Respown enemy, first mark it as visible
	LD A, (IX + sr.MSS.STATE)
	CALL sr.SetVisible

	; Reset counters and move pattern
	LD A, 0
	LD (IY + ESS.RESPOWN_DELAY_CNT), A

	CALL LoadMoveDelayCounter	
	LD (IY + ESS.MOVE_DELAY_CNT), A

	CALL RestartMovePattern

	; Set Y (horizontal respown)
	LD A,  (IY + ESS.RESPOWN_Y)
	LD (IX + sr.MSS.Y), A
	
	; Set X to left or right side of the screen
	LD A, (IX + sr.MSS.STATE)
	BIT sr.MSS_STATE_DIRECTION_BIT, A
	JR Z, .left
	LD BC, sc.SCR_X_MAX_POS
	JR .afterLR
.left	
	LD BC, sc.SCR_X_MIN_POS
.afterLR
	LD (IX + sr.MSS.X), BC

	CALL sr.ShowSprite

	LD A, RES_SE_OUT_YES
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