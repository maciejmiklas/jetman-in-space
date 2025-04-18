;----------------------------------------------------------;
;                        16x16 Sprites                     ;
;----------------------------------------------------------;
	MODULE sr

;----------------------------------------------------------;
;           Memory Structure for Single Sprite             ;
;----------------------------------------------------------;
	STRUCT SPR
ID						BYTE					; Sprite ID for #_SPR_REG_ATR3_H38.
SDB_INIT				BYTE					; Initial ID of Sprite from #srSpriteDB.
SDB_POINTER				WORD					; Pointer to #srSpriteDB record.
X						WORD					; X position of the sprite.
Y						BYTE					; Y position of the sprite.

; Bits:
;	- 0: 	#SPRITEST_VISIBLE_BIT,
;	- 1:	#SPRITEST_ACTIVE_BIT,
;   - 2: 	Not used, but reserved for simple sprite (sr),
;   - 3:	#SPRITEST_MIRROR_X_BIT,
;	- 4:	Not used, but reserved for simple sprite (sr),
;	- 5-8: 	Not used by simple sprite (sr), can be used by others, for example: jw.STATE_SHOT_TOD_DIR_BIT.
STATE					BYTE
NEXT					BYTE					; ID in #ssSpriteDB for next animation record/state.
REMAINING				BYTE					; Amount of animation frames (bytes) that still need to be processed within current #srSpriteDB record.
EXT_DATA_POINTER		WORD					; Pointer to additional data structure for this sprite.
	ENDS

; When a weapon hits something, the sprite first gets status #SPRITEST_ACTIVE_BIT. After it stops exploding, it becomes status #SPRITEST_VISIBLE_BIT.

; Active flag, 1 - sprite is alive/active, 0 - sprite is dying (not active), disabled for collision detection, but visible (exploding/dying).
SPRITEST_ACTIVE_BIT		= 1
SPRITEST_ACTIVE			= %00000010

; Visible flag, 1 = visible (enabled for collision detection only if active bit is set), 0 = hidden (can be reused).
SPRITEST_VISIBLE_BIT		= 0
SPRITEST_VISIBLE		= %00000001

SPRITEST_ALIVE			= %00000011			; Alive and visible.

; 1 - X mirror sprite, 0 - do not mirror sprite. This bit corresponds to _SPR_REG_ATR2_H37.
SPRITEST_MIRROR_X_BIT	= 3

;----------------------------------------------------------;
;                         Sprite DB                        ;
;----------------------------------------------------------;
	STRUCT SPR_REC
ID						BYTE					; Entry ID for lookup via CPIR.
OFF_NX					BYTE					; ID of the following animation DB record. We subtract from this ID the 100 so that CPIR does not find OFF_NX but ID.
SIZE					BYTE					; Amount of frames/sprite patterns in this record.
	ENDS

; DB IDs
SDB_EXPLODE				= 201					; Explosion
SDB_FIRE				= 202					; Fire
SDB_ENEMY1				= 203					; Enemy 1
SDB_ENEMY2				= 204					; Enemy 2
SDB_ENEMY3				= 205					; Enemy 3
SDB_HIDE				= 255					; Hides Sprite

SDB_SUB					= 100					; 100 for OFF_NX that CPIR finds ID and not OFF_NX (see record doc below, look for: OFF_NX).

; The animation system is based on a state machine. Each state is represented by a single DB record (#SPR_REC). 
; A single record has an ID that can be used to find it. It has a sequence of sprite patterns that will be played, 
; and once this sequence is done, it contains the offset to the following command (#OFF_NX). It could be an ID for the following DB record 
; containing another animation or a command like #SDB_HIDE that will hide the sprite.
srSpriteDB
	SPR_REC {SDB_EXPLODE, SDB_HIDE - SDB_SUB, 04} 
			DB 30, 31, 32, 33
	SPR_REC {SDB_FIRE, SDB_FIRE - SDB_SUB, 02}
			DB 54, 55
	SPR_REC {SDB_ENEMY1, SDB_ENEMY1 - SDB_SUB, 24}
			DB 45,46, 45,46,   45,46,47, 45,46,47,   46,47, 46,47,   45,46,47, 45,46,47,   45,47, 45,47
	SPR_REC {SDB_ENEMY2, SDB_ENEMY2 - SDB_SUB, 03}
			DB 48, 49, 50
	SPR_REC {SDB_ENEMY3, SDB_ENEMY3 - SDB_SUB, 03}
			DB 34, 35, 36			

;----------------------------------------------------------;
;                     #KillOneSprite                       ;
;----------------------------------------------------------;
; Input:
;  - IX:	Pointer to #SPR.
;  - B:		Sprites size.
KillOneSprite

	; Loop ever all sprites skipping hidden.
.loop

	; ##########################################
	; Ignore this enemy if it's hidden/exploding.
	LD A, (IX + sr.SPR.STATE)
	AND sr.SPRITEST_ALIVE						; Reset all bits but hidden/exploding.
	CP sr.SPRITEST_ALIVE
	JR NZ, .continue							; Jump if this enemy is already dead or exploding.

	; ##########################################
	CALL gc.EnemyHit
	RET

.continue
	; ##########################################
	; Move IX to the beginning of the next #SPR.
	LD DE, sr.SPR
	ADD IX, DE

	; ##########################################
	DJNZ .loop

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                         #SpriteHit                       ;
;----------------------------------------------------------;
; Input
;  - IX:	Pointer to #SPR.
SpriteHit

	LD A, (IX + SPR.STATE)						; Sprite is dying; turn off collision detection.
	RES SPRITEST_ACTIVE_BIT, A
	LD (IX + SPR.STATE), A

	LD A, SDB_EXPLODE
	CALL _LoadSpritePattern						; Enemy explodes.
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                     #AnimateSprites                      ;
;----------------------------------------------------------;
; Input
;  - IX:	Pointer to #SPR.
;  - B:		Number of sprites.
; Modifies: A, BC, HL
AnimateSprites

.loop
	PUSH BC										; Preserve B for loop counter.

	BIT SPRITEST_VISIBLE_BIT, (IX + SPR.STATE)
	JR Z, .continue								; Jump if visibility is not set -> hidden, can be reused.

	; Sprite is visible.
	CALL SetSpriteId							; Set the ID of the sprite for the following commands.
	CALL UpdateSpritePattern

.continue
	; Move HL to the beginning of the next #shotsX.
	LD DE, SPR
	ADD IX, DE
	POP BC
	DJNZ .loop									; Jump if B > 0.

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                     #SetSpriteId                         ;
;----------------------------------------------------------;
; Input:
;  - IX:	Pointer to #SPR.
; Modifies: A
SetSpriteId

	LD A, (IX + SPR.ID)
	NEXTREG _SPR_REG_NR_H34, A					; Set the ID of the sprite for the following commands.

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                 #UpdateSpritePosition                    ;
;----------------------------------------------------------;
; Input:
;  - IX:	pointer to #SPR
; Modifies: A, BC
UpdateSpritePosition

	; Move the sprite to the X position, the 9-bit value requires a few tricks. 
	LD BC, (IX + SPR.X)						

	LD A, C										; Set LSB from BC (X).
	NEXTREG _SPR_REG_X_H35, A					

	; Update the H37
	LD A, B										; Set MSB from BC (X).
	AND _SPR_REG_ATR2_OVERFLOW					; Keep only an overflow bit.
	LD B, A										; Backup A to B, as we need A.

	LD A, (IX + SPR.STATE)
	RES _SPR_REG_ATR2_OVER_BIT, A				; Reset overflow and set it in next command.
	OR B										; Apply B to set MSB from X.
	AND _SPR_REG_ATR2_RES_PAL					; Reset bits reserved for palette.

	RES _SPR_REG_ATR2_MIRY_BIT, A				; Reset rotation bits, as we use those for different things and might be set.
	RES _SPR_REG_ATR2_ROT_BIT, A

	NEXTREG _SPR_REG_ATR2_H37, A

	; Move the sprite to the Y position.
	LD A, (IX + SPR.Y)
	NEXTREG _SPR_REG_Y_H36, A					; Set Y position.

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                   #HideSimpleSprite                      ;
;----------------------------------------------------------;
; Hide Sprite given by IX
; Input
;  - IX:	Pointer to #SPR.
; Modifies: A
HideSimpleSprite

	CALL sr.SetSpriteId

	LD A, (IX + SPR.STATE)
	RES SPRITEST_ACTIVE, A
	RES SPRITEST_VISIBLE_BIT, A
	LD (IX + SPR.STATE), A

	CALL sp.HideSprite

	RET											; ## END of the function ##
	
;----------------------------------------------------------;
;                       #ShowSprite                        ;
;----------------------------------------------------------;
; Input:
;  - IX: 	Pointer to #SPR.
ShowSprite

	LD A, (IX + SPR.SDB_INIT)
	CALL _LoadSpritePattern						; Reset pattern

	CALL UpdateSpritePosition					; Set X, Y position for sprite
	CALL UpdateSpritePattern					; Render sprite

	RET											; ## END of the function ##
	
;----------------------------------------------------------;
;                    #SetStateVisible                      ;
;----------------------------------------------------------;
; Input:
;  - IX: 	Pointer to #SPR.
;  - A:		Prepared state.
; Modifies: A
SetStateVisible

	SET SPRITEST_VISIBLE_BIT, A
	SET SPRITEST_ACTIVE_BIT, A
	LD (IX + SPR.STATE), A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                 #UpdateSpritePattern                     ;
;----------------------------------------------------------;
; Show the current sprite pattern and switch the pointer to the next one so the following method CALL will display it.
; Input:
;  - IX:	Pointer to #SPR.
; Modifies: A, BC, HL
UpdateSpritePattern

	; Switch to the next DB record if all bytes from the current one have been used.
	LD A, (IX + SPR.REMAINING)
	CP 0
	JR NZ, .afterRecordChange					; Jump if there are still bytes to be processed.

	; Find new DB record.
	LD A, (IX + SPR.NEXT)

	; The next animation record can have value #SDB_HIDE which means: hide it.
	CP SDB_HIDE
	JR NZ, .afterHide
	CALL HideSimpleSprite
	RET
.afterHide

	; Load new DB record.
	LD A, (IX + SPR.NEXT)
	CALL _LoadSpritePattern

.afterRecordChange

	; #SPR has been fully updated to a current frame from #srSpriteDB.
	; Update the remaining animation frames counter.
	DEC (IX + SPR.REMAINING)

	; Set sprite pattern
	LD HL, (IX + SPR.SDB_POINTER)				; HL points to a memory location holding a pointer to the current DB position with the next sprite pattern.
	LD A, (HL)									; A holds the next sprite pattern.
	OR _SPR_PATTERN_SHOW						; Store pattern number into Sprite Attribute.
	NEXTREG _SPR_REG_ATR3_H38, A

	; Move #SPR.SDB_POINTER to the next sprite pattern.
	LD HL, (IX + SPR.SDB_POINTER)
	INC HL
	LD (IX + SPR.SDB_POINTER), HL

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                          #MoveX                          ;
;----------------------------------------------------------;
; Move the sprite by 1-7 pixels to the right or left along the X-axis, depending on the #SPR.STATE.
; Input
;  - IX:	Pointer to #SPR
;  - D: 	Configuration, bits:
;			- 0-2: Number of pixels to move sprite,
;			- 3:  #MVX_IN_D_HIDE_BIT,
;			- 4:  #MVX_IN_D_TOD_DIR_BIT.
MVX_IN_D_HIDE_BIT 			= 3					; 1 - hide sprite when off-screen, 0 - roll over sprite when off-screen.
MVX_IN_D_TOD_DIR_BIT			= 4					; 1 - to move right, 0 - to move left.
MVX_IN_D_6PX_HIDE			= %0000'1'110		; Move the sprite by 6 pixels and hide on the screen end.
MVX_IN_D_1PX_ROL			= %0000'0'001		; Move the sprite by 1 pixel and roll over sprite when off-screen.
MVX_IN_D_2PX_ROL			= %0000'0'010		; Move the sprite by 2 pixels and roll over sprite when off-screen.
MVX_IN_D_MASK_CNT			= %00000'111
; Modifies; A, B, HL
MoveX

	; Load counter for .moveLeftLoop into B.
	LD A, D
	AND MVX_IN_D_MASK_CNT
	LD B, A

	LD HL, (IX + SPR.X)							; Pointer to X

	BIT MVX_IN_D_TOD_DIR_BIT, D
	JR NZ, .moveRight

	; ##########################################
	; Move left.
.moveLeftLoop
	DEC HL

	; Check whether a sprite is outside the screen.
	LD A, H
	CP 0										; H holds MSB from X, if H > 0 than X > 256.
	JR NZ, .continueLeftLoop

	; H is 0, check whether L has reached #_GSC_X_MIN_D0.
	LD A, L
	CP _GSC_X_MIN_D0+1
	JR NC, .continueLeftLoop					; Jump if A >= 1

	; HL == #_GSC_X_MIN_D0
	BIT MVX_IN_D_HIDE_BIT, D					; Hide sprite or roll over?
	JR NZ, .hideSpriteL
	
	LD HL, _GSC_X_MAX_D315						; Roll over.
	JR .afterMoving

.continueLeftLoop
	DJNZ .moveLeftLoop							; Jump if B > 0.
	JR .afterMoving

.hideSpriteL

 	CALL HideSimpleSprite						; Hide sprite.
	JR .afterMoving

	; ##########################################
	; Move right.
.moveRight
	; Moving right - increment X coordinate.
	LD HL, (IX + SPR.X)	

.moveRightLoop	
	INC HL

	; If X >= 315 then hide sprite .
	; X is 9-bit value: 315 = 256 + 59 = %00000001 + %00111011 -> MSB: 1, LSB: 59.
	LD A, H										; Load MSB from X into A.
	CP 1										; 9-th bit set means X > 256.
	JR NZ, .continueRightLoop
	LD A, L										; Load MSB from X into A.
	CP 59										; MSB > 59.
	JR C, .continueRightLoop
	
	; Sprite is after 315.
	BIT MVX_IN_D_HIDE_BIT, D					; Hide sprite or roll over?
	JR NZ, .hideSpriteR
	
	; Roll over.
	LD H, 0
	LD L, _GSC_X_MIN_D0
	JR .afterMoving

.continueRightLoop
	DJNZ .moveRightLoop							; Jump if B > 0.
	JR .afterMoving

.hideSpriteR
 	CALL HideSimpleSprite						; Hide sprite.

.afterMoving
	LD (IX + SPR.X), HL							; Update new X position.
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                          #MoveY                          ;
;----------------------------------------------------------;
; Move the sprite one pixel to the right or left along the Y-axis, depending on the A.
; Input
;  - IX:	Pointer to #SPR.
;  - A:    	MOVE_Y_IN_XXX
MOVE_Y_IN_UP 				= 1					; Move up.
MOVE_Y_IN_DOWN 				= 0					; Move down.
; Output:
;  - A: 	MOVE_RET_XXX
MOVE_RET_VISIBLE 			= 1					; Sprite is still visible.
MOVE_RET_HIDDEN 			= 0					; Sprite outside screen, or hits ground.
; Modifies: A
MoveY

	CP MOVE_Y_IN_UP
	JR Z, .afterMovingUp						; Jump if moving up.

	; Moving down - increment Y coordinate.
	LD A, (IX + SPR.Y)	
	INC A

	; Check whether a sprite hits ground.
	CP _GSC_Y_MAX_D232
	JR C, .afterMoving							; Jump if the sprite is above ground (A < _GSC_Y_MAX_D232).

	; Sprite hits the ground.
	LD A, MOVE_RET_HIDDEN
	CALL SpriteHit
	RET
.afterMovingUp

	; Moving up - decrement X coordinate.
	LD A, (IX + SPR.Y)	
	DEC A

	; Check if sprite is above screen.
	CP _GSC_Y_MIN_D15
	JR NC, .afterMoving							; Jump if the enemy is below max screen postion (A >= _GSC_Y_MIN_D15).

	; Sprite is above screen -> hide it.
	CALL HideSimpleSprite
	LD A, MOVE_RET_HIDDEN
		
	RET
.afterMoving

	LD (IX + SPR.Y), A							; Update new X position.
	LD A, MOVE_RET_VISIBLE

	RET											; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                 #_LoadSpritePattern                      ;
;----------------------------------------------------------;
; Set given pointer IX to animation pattern from #srSpriteDB given by B.
; Input:
;  - IX: 	Pointer to #SPR.
;  - A:		ID in #srSpriteDB.
; Modifies: A, BC, HL
_LoadSpritePattern

	; Find DB record.
	LD HL, srSpriteDB							; HL points to the beginning of the DB.
	LD BC, 0									; Do not limit CPIR search.
	CPIR										; CPIR will keep increasing HL until it finds a record ID from A.

	;  Now, HL points to the next byte after the ID of the record, which contains data for the new animation pattern.
	LD A, (HL)	
	ADD SDB_SUB									; Add 100 because DB value had  -100, to avoid collision with ID.
	LD (IX + SPR.NEXT), A						; Update #SPR.NEXT.

	INC HL										; HL points to [SIZE] in DB.
	LD A, (HL)									
	LD (IX + SPR.REMAINING), A					; Update #SPR.REMAINING.

	INC HL										; HL points to [FRAME] in DB.
	LD (IX + SPR.SDB_POINTER), HL				; Update #SPR.SDB_POINTER.

	RET											; ## END of the function ##
;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE