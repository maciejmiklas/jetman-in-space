;----------------------------------------------------------;
;             Single 16x16 Flying Enemy                    ;
;----------------------------------------------------------;
	MODULE ep

; The timer ticks with every game loop. When it reaches #EN_RESPOWN_DELAY, a single enemy will respawn, and the timer starts from 0, counting again.
respownDelayCnt 			DB 0
respownDelay 				DB 20				; Amount of game loops to respawn single enemy

; Extends #MSS by additional params
	STRUCT ESS
; Bits:
;	- 0:	#ESS_SETUP_ALONG_BIT
;	- 1:	#ESS_SETUP_DEPLOY_BIT
SETUP					BYTE	
MOVE_DELAY_CNT			BYTE					; Move delay counter, counting down. Move delay is specified in the move pattern, byte 2, bits 8-5. Bit 0-4 is the repetition counter.
RESPOWN_DELAY			BYTE					; Number of game loops delaying respawn
RESPOWN_DELAY_CNT		BYTE					; Respawn delay counter
RESPOWN_Y				BYTE					; Repown Y position
MOVE_PAT_POINTER		WORD					; Pointer to the movement pattern (#movePatternXX)
MOVE_PAT_POS			BYTE					; Position in #MOVE_PAT_POINTER. Counts from #MOVE_PAT_STEP_OFFSET to #movePatternXX.size
MOVE_PAT_STEP 			BYTE					; Counters X,Y from current move pattern
MOVE_PAT_STEP_RCNT		BYTE					; Counter for repetition of single move pattern step. Counts towards 0
	ENDS
; Bits 4-7 on sr.STATE will be used here:

ESS_SETUP_ALONG_BIT		= 0						; 1 - avoid platforms by flying along them, 0 - hit platform
ESS_SETUP_DEPLOY_BIT	= 1						; 1 - deply enemy on the left, 0 - on the right

MOVE_DELAY_CNT_INC		= %0001'0000

SPRITE_HEIGHT_PLATFORM		= 3
SPRITE_HEIGHT_COLISION		= 10

; The move pattern is stored as a byte array. The first byte in this array holds the byte, indicating the number of patterns it contains. 
; This single byte is followed by move patterns, where each pattern consists of two bytes: first for the pattern itself (pattern step) and 
; the second holding the movement delay (bits 8-5) and the number of times it should be repeated (bits 4-0).
; To illustrate, if the first byte is set to 5,  the move pattern will span a total of 11 bytes: 11 = 1 + 5 * 2, or:
; [numer of patterns],[[step],[delay/repetition],[[step],[delay/repetition],...,[[step],[delay/repetition]]
;
; Each pattern step contains the number of pixels to move along the X axis (left or right) and the number of pixels to move along Y axis (up or down).
;
; The sprite travels only one pixel in each direction during each animation loop. If possible, it travels in both directions 
; (increasing X and Y by one). If the number of pixels in a particular direction has been reached, it will continue vertically or horizontally. 
;
; Bits of the sigle step:
; 0-2:	Number of pixels to move along X axis
; 3:	#MOVE_PAT_X_DIR_BIT
; 4-6:	Number of pixels to move on Y axis
; 7:	#MOVE_PAT_Y_DIR_BIT
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

; 1 = sprite moves right, 0 = sprite moves left. However, this is the case if deployment occurs on the left side. For deployment on 
; the right side of the screen, all directions in the movement pattern get inverted. Just write all move patterns, assuming deployments 
; occur on the screen's left side. If it's being deployed right, the direction bits will be inverted.
MOVE_PAT_X_DIR_BIT		= 3
MOVE_PAT_X_DIR_MASK		= %0'000'1'000

MOVE_PAT_Y_MASK			= %0'111'0'000
MOVE_PAT_Y_ADD			= %0'001'0'000

MOVE_PAT_Y_DIR_MASK		= %1'000'0'000

; Determines whether Y should be decremented (0 - move up) or incremented (1 - move down) in each iteration
MOVE_PAT_Y_DIR_BIT		= 7

MOVE_PAT_XY_MASK		= %0'111'0'111
MOVE_PAT_XY_MASK_RES	= %1'000'1'000

MOVE_STEP_SIZE			= 2						; Each move step in the pattern takes two bytes: pattern and delay/number of repeats
MOVE_STEP_CNT_OFF		= 1
MOVE_PAT_STEP_OFFSET	= 1						; Data for move pattern starts at byte 1, byte 0 provides size
MOVE_PAT_REPEAT_MASK	= %0000'1111
MOVE_PAT_DELAY_MASK		= %1111'0000

MOVE_X_IN_D				= %000'0'0000			; Input mask for MoveX. Move the sprite by one pixel and roll over on the screen end

; Horizontal movemment
movePattern01_
	DB 2, %0'000'1'111,$AF

; 10deg move down
movePattern02
	DB 2, %1'001'1'111,$0F

; 10deg move up
movePattern03
	DB 2, %0'001'1'111,$0F

; 45deg move down
movePattern04
	DB 2, %1'001'1'001,$52

; 5x horizontal, 2x 45deg down,...
movePattern05
	DB 4, %0'000'1'111,5, %1'111'1'111,2

; Half sinus
movePattern06
	DB 32, %0'010'1'001,$02, %0'011'1'010,$02, %0'100'1'011,$01, %0'011'1'011,$01, %0'010'1'011,$03, %0'001'1'011,$02, %0'001'1'100,$02, %0'001'1'101,$01 	; going up
		DB %1'001'1'101,$01, %1'001'1'100,$02, %1'001'1'011,$02, %1'010'1'011,$03, %1'011'1'011,$01, %1'100'1'011,$01, %1'011'1'010,$02, %1'010'1'001,$02	; going down		

; sinus
movePattern01
	DB 64, %0'010'1'001,$52, %0'011'1'010,$52, %0'100'1'011,$51, %0'011'1'011,$51, %0'010'1'011,$53, %0'001'1'011,$52, %0'001'1'100,$52, %0'001'1'101,$51 	; going up, above X
		DB %1'001'1'101,$51, %1'001'1'100,$42, %1'001'1'011,$42, %1'010'1'011,$33, %1'011'1'011,$31, %1'100'1'011,$21, %1'011'1'010,$22, %1'010'1'001,$12	; going down, above X
		DB %1'010'1'001,$12, %1'011'1'010,$02, %1'100'1'011,$01, %1'011'1'011,$21, %1'010'1'011,$23, %1'001'1'011,$32, %1'001'1'100,$32, %1'001'1'101,$41 	; going down, below X
		DB %0'001'1'101,$51, %0'001'1'100,$52, %0'001'1'011,$52, %0'010'1'011,$53, %0'011'1'011,$51, %0'100'1'011,$51, %0'011'1'010,$52, %0'010'1'001,$52	; going up, below X	
		
; Square wave
movePattern08
	DB 8, %0'000'1'111,$25, %1'111'1'000,$23, %0'000'1'111,$25, %0'111'1'000,$23

; Triangle wave
movePattern09
	DB 4, %0'111'1'111,5, %1'111'1'111,5

; Square,triangle wave
movePattern10
	DB 24, %0'000'1'111,$25, %1'111'1'000,$23, %0'000'1'111,$25, %0'111'1'000,$23, %0'000'1'111,$25, %1'111'1'000,$23, %0'000'1'111,$25, %0'111'1'000,$23, %1'111'1'111,$03, %0'111'1'111,$03, %1'111'1'111,$03, %0'111'1'111,$03

;----------------------------------------------------------;
;                  #RestartMovePattern                     ;
;----------------------------------------------------------;
; This method resets the move pattern (#ESS) so animation can start from the first move pattern. It does not modify #MSS.
; Input
;  - IX:	Pointer to #MSS holding data for single spreite that will be moved
;  - IY: 	Pointer to #ESS for current sprite
; Modifies: A, IY, BC, HL
RestartMovePattern

	LD BC, (IX + sr.MSS.EXT_DATA_POINTER)		; Load #ESS for this sprite to IY
	LD IY, BC
	LD HL, (IY + ESS.MOVE_PAT_POINTER)			; HL points to start of the #movePattern, that is the amount of elements in this pattern.
	INC HL										; HL points to the first move pattern element	
	
	; X, Y counters will be set to max value as we count down towards 0
	LD A, (HL)
	LD (IY + ESS.MOVE_PAT_STEP), A	

	; Set position at the first pattern, this is one byte after the start of #movePatternXX
	LD A, MOVE_PAT_STEP_OFFSET
	LD (IY + ESS.MOVE_PAT_POS), A

	; Set pattern counters to the first pattern
	INC HL										; HL points to delay/repeat counter byte
	LD A, (HL)
	LD B, A

	; Set repeat counter
	AND MOVE_PAT_REPEAT_MASK					; Leave only repeat counter bits
	LD (IY + ESS.MOVE_PAT_STEP_RCNT), A

	; Set delay counter 
	LD A, B
	AND MOVE_PAT_DELAY_MASK						; Leave only delay counter bits	
	LD (IY + ESS.MOVE_DELAY_CNT), A

	RET	

;----------------------------------------------------------;
;                  #LoadCurrentMoveStep                    ;
;----------------------------------------------------------;
; Load HL that points to the current move pattern's step.
; Input
;  - IY: 	Pointer to #ESS for current sprite
; Output:
;  - HL: 	Points to the current move pattern's step.
; Modifies: A
LoadCurrentMoveStep
	LD HL, (IY + ESS.MOVE_PAT_POINTER)			; HL points to start of the #movePattern
	LD A, (IY + ESS.MOVE_PAT_POS)
	ADD HL, A									; Move HL from the beginning of the move pattern to current element

	RET

;----------------------------------------------------------;
;                      #MoveEnemy                          ;
;----------------------------------------------------------;
; Input
;  - IX:	Pointer to #MSS holding data for single spreite that will be moved
; Output:
;  - A: 	sr.MOVE_RET_XXX
; Modifies: all
MoveEnemy

	; Move the Sprite horizontally if it has been hit and it's dying
	LD A, (IX + sr.MSS.STATE)
	CALL sr.SetSpriteId							; Set sprite ID in hardware
	
	; Load #ESS for this sprite to IY
	LD BC, (IX + sr.MSS.EXT_DATA_POINTER)
	LD IY, BC
	CALL LoadCurrentMoveStep

	; Current register values:
	;  - IX: pointer to #MSS for current sprite
	;  - IY: pointer to #ESS for current sprite
	;  - HL: pointer to current position in #movePattern

	BIT sr.MSS_ST_ALIVE_BIT, (IX + sr.MSS.STATE)
	JR NZ, .afterAliveCheck						; Jump if sprite is alive

	; Move the sprite horizontally while it's exploding
	CALL MoveEnemyX
	CALL sr.UpdateSpritePosition				; Move sprite to new X,Y coordinates

	LD A, sr.MOVE_RET_VISIBLE
	RET
.afterAliveCheck

	; Should the enemy move along the platform to avoid collision?
	BIT ESS_SETUP_ALONG_BIT, (IY + ESS.SETUP)
	JR Z, .afterMoveAlong						; Jump if move along is not set

	; Check the collision with the platform
	PUSH IY, HL
	LD IY, jp.platformBump
	LD L, SPRITE_HEIGHT_COLISION
	CALL sr.PlaftormColision
	POP HL, IY

	CP A, sr.PL_COL_RET_A_NO
	JR Z, .afterMoveAlong						; Jump if there is no collision

	; Avoid collision with the platform by moving along it 
	CALL MoveEnemyX
	CALL sr.UpdateSpritePosition				; Move sprite to new X,Y coordinates
	RET
.afterMoveAlong

	; Check if counter for X has already reached 0, or is set to 0
	LD A, (IY + ESS.MOVE_PAT_STEP)				; A contains current X,Y counters
	AND MOVE_PAT_X_MASK							; Reset all but X
	CP 0
	JR Z, .aftetrMoveLR							; Jump if the counter for X has reached 0
	
	; Decrement X counter
	LD A, (IY + ESS.MOVE_PAT_STEP)				; A contains current X,Y counters
	SUB MOVE_PAT_X_ADD							; Decrement X counter by 1
	LD (IY + ESS.MOVE_PAT_STEP), A

	CALL MoveEnemyX	
.aftetrMoveLR

	; Check if counter for Y has already reached 0, or is set to 0
	LD A, (IY + ESS.MOVE_PAT_STEP)				; A contains current X,Y counters
	AND MOVE_PAT_Y_MASK							; Reset all but Y
	CP 0
	JR Z, .afterChangeY							; Jump if the counter for Y has reached 0

	; Enemy should move on Y
	LD A, (IY + ESS.MOVE_PAT_STEP)				; A contains current X,Y counters
	SUB MOVE_PAT_Y_ADD							; Decrement Y counter by 1
	LD (IY + ESS.MOVE_PAT_STEP), A	

	; Move on Y-axis one pixel up or down?
	LD A, (HL)									; A contains current pattern
	BIT MOVE_PAT_Y_DIR_BIT, A
	JR Z, .moveUp								; Jump if sprite should move up

	; Move on pixel down	
	LD A, sr.MOVE_Y_IN_DOWN
	CALL sr.MoveY
	CP sr.MOVE_RET_HIDDEN
	JR NZ, .afterChangeY							; Jump is sprite is not hidden

	LD A, sr.MOVE_RET_HIDDEN
	RET											; Stop moving this spirte, it's hidden

.moveUp
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
	LD A, (IY + ESS.MOVE_PAT_STEP)				; A contains pattern counter	
	AND MOVE_PAT_XY_MASK						; Reset all but max X,Y values
	CP 0
	JR Z, .resetXYCounters						; Jump if X and Y counters has reached 0

	LD A, sr.MOVE_RET_VISIBLE
	RET

.resetXYCounters
	; X and Y have reached the max value. First, reset the X and Y counters, and afterward, decrease the repetition counter
	LD A, (HL)									; X, Y counters will be set to max value as we count down towards 0
	LD (IY + ESS.MOVE_PAT_STEP), A	

	LD A, (IY + ESS.MOVE_PAT_STEP_RCNT)			; Decrease the repetition counter
	DEC A
	CP 0
	JR Z, .nextMovePattern						; Jump if repetition counter for single step has reached 0
	
	; Decrease repetition counter for move step and return
	LD (IY + ESS.MOVE_PAT_STEP_RCNT), A			; Store decreased counter
	
	LD A, sr.MOVE_RET_VISIBLE
	RET

.nextMovePattern
	; Setup next move pattern
	LD A, (IY + ESS.MOVE_PAT_POS)				; A contains the current position in the move pattern
	ADD MOVE_STEP_SIZE							; Increment the position to the next patern and store it
	LD (IY + ESS.MOVE_PAT_POS), A

	; Check if we should restart the move pattern, as it might have reached the last element
	DEC A										; Pattern starts after offset
	PUSH HL
	LD HL, (IY + ESS.MOVE_PAT_POINTER)			; DE points to start of the #movePattern
	LD B, (HL)									; B contains the amount of bytes in the move pattern array
	POP HL
	CP B
	JR NC, .restartMovePattern					; Jump A >= B -> (current postion >= size)

	; There is no need to restart the move pattern, load the next one
	LD BC, HL									; BC points to current position in #movePatternXX
	INC BC										; Move BC to the counter for current pattern
	INC BC										; Move BC to the next pattern
	
	LD A, (BC)									; X, Y counters will be set to max value as we count down towards 0
	LD (IY + ESS.MOVE_PAT_STEP), A	

	INC BC										; Move BC to the counter for the next pattern
	LD A, (BC)									; Load delay/repeat counter into A
	LD D, A

	; Set pattern counter for next pattern
	AND MOVE_PAT_REPEAT_MASK					; Leave only repeat counter bits
	LD (IY + ESS.MOVE_PAT_STEP_RCNT), A

	; Set delay counter for next pattern
	LD A, D
	AND MOVE_PAT_DELAY_MASK						; Leave only delay counter bits	
	LD (IY + ESS.MOVE_DELAY_CNT), A
	RET

.restartMovePattern
	; Restart move pattern, it has reached max value
	CALL RestartMovePattern
	RET

;----------------------------------------------------------;
;                     #MoveEnemyX                          ;
;----------------------------------------------------------;
; Input
;  - IX:	Pointer to #MSS
;  - IY:	Pointer to #ESS
;  - HL: 	Points to the current move pattern's step.
; Modifies: A, BC
MoveEnemyX
	LD D, MOVE_X_IN_D							; D contains configuration for MoveX
	BIT ESS_SETUP_DEPLOY_BIT, (IY + ESS.SETUP)
	JR NZ, .deployedLeft						; Jump if bit is 0 -> deploy left

	; Enemy was deployed on the right, invert #MOVE_PAT_X_DIR_BIT
	BIT MOVE_PAT_X_DIR_BIT, (HL)
	JR NZ, .moveLeft							; Jump if bit is set to 1 (right), invert right -> left
	JR .moveRight								; Bit is 0 -> move left

.deployedLeft
	; Enemy was deployed on the left, do not invert #MOVE_PAT_X_DIR_BIT
	BIT MOVE_PAT_X_DIR_BIT, (HL)
	JR NZ, .moveRight							; Jump if bit is set to 1 (right)
	JR .moveLeft								; Bit is 0 -> move left

.moveRight										; Move right
	SET sr.MVX_IN_D_DIR_BIT, D
	CALL sr.MoveX	
	RET

.moveLeft										; Move left
	RES sr.MVX_IN_D_DIR_BIT, D
	CALL sr.MoveX	
	RET

;----------------------------------------------------------;
;                       #MoveEnemies                       ;
;----------------------------------------------------------;
;  - IX:	Pointer to #MSS
;  - B:		Sprites size
; Modifies: ALL
MoveEnemies
	; Loop ever all enemies skipping hidden 
.loop
	PUSH BC										; Preserve B for loop counter

	; Ignore this sprite if it's hidden
	LD A, (IX + sr.MSS.STATE)
	AND sr.MSS_ST_VISIBLE						; Reset all bits but visibility
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
	RET Z										; Exit if B has reached 0

	; Move IX to the beginning of the next #MSS
	LD DE, sr.MSS
	ADD IX, DE
	JP .loop

	RET		

;----------------------------------------------------------;
;                 #LoadMoveDelayCounter                    ;
;----------------------------------------------------------;
; Input
;  - IY:	Pointer to #ESS holding data for single spreite 
; Output:
;  - A;		Value of move delay counter for this pattern (bits 8-5)
; Modifies: A, HL
LoadMoveDelayCounter

	CALL LoadCurrentMoveStep
	INC HL
	LD A, (HL)									; Load the delay/repetition counter into A, reset all bits but delay, and shift to the proper number
	AND MOVE_PAT_DELAY_MASK
	RET
	
;----------------------------------------------------------;
;                  #RespownNextEnemy                       ;
;----------------------------------------------------------;
; Input:
;  - IX:	Pointer to #MSS
;  - B:		Sprites size
RespownNextEnemy

	; Increment respawn timer and exit function if it's not time to respawn a new enemy
	LD A, (respownDelay)
	LD D, A
	LD A, (respownDelayCnt)
	INC A
	CP D
	JR Z, .startRespown							; Jump if the timer reaches respawn delay
	LD (respownDelayCnt), A

	RET
.startRespown	
	LD A, 0
	LD (respownDelayCnt), A						; Reset delay timer

	; Iterate over all enemies to find the first hidden, respawn it, and exit function
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
;  - IX:	Pointer to #MSS holding data for single enemy
; Output:
; - A: 		RES_SE_OUT_XXX
RES_SE_OUT_YES					= 1				; Enemy did respawn
RES_SE_OUT_NO					= 0				; Enemy did not respawn
; Modifies: all
RespownEnemy
	
	LD A, (IX + sr.MSS.STATE)
	BIT sr.MSS_ST_VISIBLE_BIT, A
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
	BIT ESS_SETUP_DEPLOY_BIT, (IY + ESS.SETUP)
	JR NZ, .deployLeft								; Jump if bit is 0 -> deploy left

	; Deploy right
	LD BC, sc.SCR_X_MAX_POS
	SET sr.MSS_ST_MIRROR_X_BIT, (IX + sr.MSS.STATE)	; Mirror sprite, because it deploys on the right and moves to the left side 
	JR .afterLR
.deployLeft	
	; Deploy left
	LD BC, sc.SCR_X_MIN_POS

.afterLR
	LD (IX + sr.MSS.X), BC
	CALL sr.ShowSprite

	LD A, RES_SE_OUT_YES
	RET

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE