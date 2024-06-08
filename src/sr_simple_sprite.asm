;----------------------------------------------------------;
;                        16x16 Sprites                     ;
;----------------------------------------------------------;
	MODULE sr

;----------------------------------------------------------;
;           Memory Structure for Single Sprite             ;
;----------------------------------------------------------;
	STRUCT MSS
ID						BYTE					; Sprite ID for #_SPR_REG_ATR3_H38
SDB_INIT				BYTE					; Initial ID of Sprite from #srSpriteDB
DB_POINTER				WORD					; Pointer to #srSpriteDB record
X						WORD					; X position of the sprite
Y						BYTE					; Y position of the sprite

; Bits:
;	- 0: 	#MSS_ST_VISIBLE_BIT
;	- 1:	#MSS_ST_ALIVE_BIT
;   - 2: 	Not used, but reserverd for simple sprite (sr)
;   - 3:	#MSS_ST_MIRROR_X_BIT
;	- 4:	Not used, but reserverd for simple sprite (sr)
;	- 5-8: 	Not used by simple sprite (sr), can be used by others, for example: jw.STATE_SHOT_DIR_BIT
STATE					BYTE
NEXT					BYTE					; ID in #ssSpriteDB for next animation record/state
REMAINING				BYTE					; Amount of animation frames (bytes) that still need to be processed within current #srSpriteDB record
EXT_DATA_POINTER		WORD					; Pointer to additional data structure for this sprite
	ENDS

; Visible flag, 1 = displayed, 0 = hidden
MSS_ST_VISIBLE_BIT		= 0
MSS_ST_VISIBLE			= %00000001

; Alive flag, 1 - sprite is alive, 0 - sprite is dying, disabled for colistion detection, but visible.
MSS_ST_ALIVE_BIT		= 1
MSS_ST_ALIVE			= %00000010

; 1 - X mirror sprite, 0 - do not mirror sprite. This bit corresponds to _SPR_REG_ATR2_H37
MSS_ST_MIRROR_X_BIT		= 3

;----------------------------------------------------------;
;                         Sprite DB                        ;
;----------------------------------------------------------;
	STRUCT SPR_REC
ID						BYTE					; Entry ID for lookup via CPIR
OFF_NX					BYTE					; ID of the following animation DB record. We subtract from this ID the 100 so that CPIR does not find OFF_NX but ID
SIZE					BYTE					; Amount of frames/sprite patterns in this record
	ENDS

; DB IDs
SDB_EXPLODE				= 201					; Explosion
SDB_FIRE				= 202					; Fire
SDB_COMET1				= 203					; Comet 1
SDB_COMET2				= 204					; Comet 2
SDB_HIDE				= 255					; Hides Sprite

SDB_SUB					= 100					; 100 for OFF_NX that CPIR finds ID and not OFF_NX (see record docu below, look for: OFF_NX)

; The animation system is based on a state machine. Each state is represented by a single DB record (#SPR_REC). 
; A single record has an ID that can be used to find it. It has a sequence of sprite patterns that will be played, 
; and once this sequence is done, it contains the offset to the following command (#OFF_NX). It could be an ID for the following DB record 
; containing another animation or a command like #SDB_HIDE that will hide the sprite.
srSpriteDB
	SPR_REC {SDB_EXPLODE, SDB_HIDE - SDB_SUB, 04} 
			DB 38, 39, 40, 41
	SPR_REC {SDB_FIRE, SDB_FIRE - SDB_SUB, 03}
			DB 42, 43, 44
	SPR_REC {SDB_COMET1, SDB_COMET1 - SDB_SUB, 03}
			DB 45, 46, 47
	SPR_REC {SDB_COMET2, SDB_COMET2 - SDB_SUB, 03}
			DB 48, 49, 50

; We are using platform coordinates for bumping, which are too thick for the thin sprite
PLATFROM_MARGIN_UP		= 12
PLATFROM_MARGIN_DOWN	= 5

;----------------------------------------------------------;
;                         #SpriteHit                       ;
;----------------------------------------------------------;
; Input
;  - IX:	pointer to #MSS
SpriteHit	
	LD A, (IX + MSS.STATE)						; Sprite is dying; turn off collision detection
	RES MSS_ST_ALIVE_BIT, A
	LD (IX + MSS.STATE), A

	LD A, SDB_EXPLODE
	CALL SetSpritePattern						; Enemy expoldes
	RET
;----------------------------------------------------------;
;                     #AnimateSprites                      ;
;----------------------------------------------------------;
; Input
;  - IX:	pointer to #MSS
;  - B:		number of sprites
; Modifies: A, BC, HL
AnimateSprites
	
.loop
	PUSH BC										; Preserve B for loop counter

	BIT MSS_ST_VISIBLE_BIT, (IX + MSS.STATE)
	JR Z, .continue								; Jump if visibility is not set -> hidden, can be reused

	; Sprite is visible
	CALL SetSpriteId							; Set the ID of the sprite for the following commands
	CALL UpdateSpritePattern

.continue
	; Move HL to the beginning of the next #shotMssX
	LD DE, MSS
	ADD IX, DE
	POP BC
	DJNZ .loop									; Jump if B > 0

	RET

;----------------------------------------------------------;
;                     #SetSpriteId                         ;
;----------------------------------------------------------;
; Input:
;  - IX:	pointer to #MSS
; Modifies: A
SetSpriteId

	LD A, (IX + MSS.ID)
	NEXTREG _SPR_REG_NR_H34, A					; Set the ID of the sprite for the following commands

	RET
;----------------------------------------------------------;
;                 #UpdateSpritePosition                    ;
;----------------------------------------------------------;
; Input:
;  - IX:	pointer to #MSS
; Modifies: A, BC
UpdateSpritePosition
	; Move the sprite to the X position, the 9-bit value requires a few tricks. 
	LD BC, (IX + MSS.X)						

	LD A, C										; Set LSB from BC (X)
	NEXTREG _SPR_REG_X_H35, A					

	; Update the H37
	LD A, B										; Set MSB from BC (X)
	AND _SPR_REG_ATR2_OVEFLOW					; Keep only an overflow bit
	LD B, A										; Backup A to B, as we need A

	LD A, (IX + MSS.STATE)
	RES _SPR_REG_ATR2_OVER_BIT, A				; Reset overflow and set it in next command
	OR B										; Apply B to set MSB from X
	AND _SPR_REG_ATR2_RES_PAL					; Reset bits reserved for pallete

	RES _SPR_REG_ATR2_MIRY_BIT, A				; Reset rotation bits, as we use those for different things and might be set
	RES _SPR_REG_ATR2_ROT_BIT, A

	NEXTREG _SPR_REG_ATR2_H37, A

	; Move the sprite to the Y position
	LD A, (IX + MSS.Y)
	NEXTREG _SPR_REG_Y_H36, A					; Set Y position

	RET

;----------------------------------------------------------;
;                      #HideSprite                         ;
;----------------------------------------------------------;
; Hide Sprite given by IX
; Input
;  - IX - pointer to #MSS
; Modifies: A
HideSprite

	; Hide sprite
	LD A, _SPR_PATTERN_HIDE						; Hide sprite on display	
	NEXTREG _SPR_REG_ATR3_H38, A

	LD A, (IX + MSS.STATE)						; Mark sprite as hidden
	RES MSS_ST_VISIBLE_BIT, A
	LD (IX + MSS.STATE), A
	
	RET

;----------------------------------------------------------;
;                       #SetVisible                        ;
;----------------------------------------------------------;
; Input:
;  - IX: 	Pointer to #MSS
;  - A:		Prepared state
; Modifies: A
SetVisible
	SET MSS_ST_VISIBLE_BIT, A
	SET MSS_ST_ALIVE_BIT, A
	LD (IX + MSS.STATE), A

	RET	

;----------------------------------------------------------;
;                       #ShowSprite                        ;
;----------------------------------------------------------;
; Input:
;  - IX: 	Pointer to #MSS
ShowSprite	
	CALL SetSpriteId							; Set the ID of the sprite for the following commands

	LD A, (IX + MSS.SDB_INIT)
	CALL SetSpritePattern						; Reset pattern

	CALL UpdateSpritePosition					; Set X, Y position for sprite
	CALL UpdateSpritePattern					; Render sprite
	RET

;----------------------------------------------------------;
;                 #UpdateSpritePattern                     ;
;----------------------------------------------------------;
; Show the current sprite pattern and switch the pointer to the next one so the following method call will display it
; Input:
;  - IX:	pointer to #MSS
; Modifies: A, BC, HL
UpdateSpritePattern

	; Switch to the next DB record if all bytes from the current one have been used
	LD A, (IX + MSS.REMAINING)
	CP 0
	JR NZ, .afterRecordChange					; Jump if there are still bytes to be processed	

	; Find new DB record
	LD A, (IX + MSS.NEXT)	

	; The next animation record can have value #SDB_HIDE which means: hide it
	CP SDB_HIDE
	JR NZ, .afterHide
	CALL HideSprite
	RET
.afterHide

	; Load new DB record
	LD A, (IX + MSS.NEXT)	
	CALL SetSpritePattern			

.afterRecordChange

	; #MSS has been fully updated to a current frame from #srSpriteDB
	; Update the remaining animation frames counter.
	DEC (IX + MSS.REMAINING)

	; Show sprite pattern
	LD HL, (IX + MSS.DB_POINTER)				; HL points to a memory location holding a pointer to the current DB position with the next sprite pattern
	LD A, (HL)									; A holds the next sprite pattern
	OR _SPR_PATTERN_SHOW						; Store pattern number into Sprite Attribute	
	NEXTREG _SPR_REG_ATR3_H38, A

	; Move #MSS.DB_POINTER to the next sprite pattern
	LD HL, (IX + MSS.DB_POINTER)
	INC HL
	LD (IX + MSS.DB_POINTER), HL

	RET

;----------------------------------------------------------;
;                   #SetSpritePattern                      ;
;----------------------------------------------------------;
; Set given pointer IX to animation pattern from #srSpriteDB given by B
; Input:
;  - IX: 	Pointer to #MSS
;  - A:		ID in #srSpriteDB
; Modifies: A, BC, HL
SetSpritePattern
	
	; Find DB record
	LD HL, srSpriteDB							; HL points to the beginning of the DB
	LD BC, 0									; Do not limit CPIR search
	CPIR										; CPIR will keep increasing HL until it finds a record ID from A

	;  Now, HL points to the next byte after the ID of the record, which contains data for the new animation pattern.
	LD A, (HL)	
	ADD SDB_SUB									; Add 100 because DB value had  -100, to avoid collision with ID
	LD (IX + MSS.NEXT), A						; Update #MSS.NEXT	

	INC HL										; HL points to [SIZE] in DB
	LD A, (HL)									
	LD (IX + MSS.REMAINING), A					; Update #MSS.REMAINING

	INC HL										; HL points to [FRAME] in DB
	LD (IX + MSS.DB_POINTER), HL				; Update #MSS.DB_POINTER

	RET

;----------------------------------------------------------;
;                 #PlaftormColision                        ;
;----------------------------------------------------------;
; Input:
;  - IX: 	pointer to #MSS, single sprite to check colsion for
;  - IY:	Structure for #platformBump
;  - L:		Half of the height of the sprite
; Output:
;  - A: 	MOVE_RET_XXX
PL_COL_RET_A_NO 			= 0					; No colision
PL_COL_RET_A_YES 			= 1					; Sprite hits the platform
; Modifies: ALL

PlaftormColision
	; Exit if sprite is not alive
	BIT MSS_ST_ALIVE_BIT, (IX + MSS.STATE)
	LD A, PL_COL_RET_A_NO
	RET Z										; Exit if sprite is not alive

	LD B, (IY)									; Load into B the number of platforms to check
.platformsLoop	
	; Return if X > 256 -> such position takes two bytes and MSB is > 0 (D is 1). Platforms end at 256.
	LD DE, (IX + MSS.X)
	LD A, 0 
	CP D
	RET NZ

	; Is Sprite after the beginning of the platform?
	LD A, E										; A holds current X position of the sprite for colision check (only LSB, platrofrm are limited to X <= 255)
	INC IY										; HL points to [X platform start]
	LD C, (IY)									; C holds [X platform start]
	CP C
	JR NC, .afterXLeftCheck						; Jump if [X sprite] < [X platform start] -> 

	; There is no collision with the current platform. Move the IY pointer to the next one and continue looping
	INC IY										; HL points to [X platform end]
	INC IY										; HL points to [Y platform start]
	INC IY										; HL points to [Y platform end]
	JR .platformsLoopEnd
.afterXLeftCheck

	; Is Sprite before the end of the platform?

	; A still holds [X sprite]
	INC IY										; HL points to [X platform end]
	LD C, (IY)									; C holds [X platform end]
	CP C
	JR C, .afterXRightCheck						; Jump if [X sprite] >= [X platform end]

	; There is no collision with the current platform. Move the IY pointer to the next one and continue looping
	INC IY										; HL points to [Y platform start]
	INC IY										; HL points to [Y platform end]
	JR .platformsLoopEnd
.afterXRightCheck	

	; Sprite is within the platform's horizontal position; now check whether it's within vertical bounds
	INC IY										; HL points to [Y platform start]
	LD A, (IY)	
	ADD PLATFROM_MARGIN_UP						; Increase start Y to make platform thinner
	SUB L										; Thickness to the sprite
	LD D, A										; D contains [Y platform start]

	INC IY										; HL points to [Y platform end]
	LD A, (IY)
	SUB PLATFROM_MARGIN_DOWN					; Decrease end Y to make the platform thinner
	ADD L										; Thickness to the sprite
	LD E, A										; E contains [Y platform end]

	; Now D contains [Y platform start + margin],  E contains [Y platform end + margin]
	LD A, (IX + MSS.Y)							; A holds current shot Y position
	
	CP D										; Compare [Y sprite] position to [Y start]
	JR C, .platformsLoopEnd						; Jump if shot < [Y platform start]

	CP E
	JR NC, .platformsLoopEnd					; Jump if shot > [Y end]

	; Sprite hits the platform!
	LD A, PL_COL_RET_A_YES

	RET

.platformsLoopEnd
	DJNZ .platformsLoop							; Decrease B until all platforms have been evaluated

	LD A, PL_COL_RET_A_NO
	RET

;----------------------------------------------------------;
;                          #MoveX                          ;
;----------------------------------------------------------;
; Move the sprite one pixel to the right or left along the X-axis, depending on the #MSS.STATE
; Input
;  - IX:	pointer to #MSS
;  - D: 	configuration, bits:
;			- 0: 0 - move sprite by 1 pixel, 1 - move sprite by 2 pixels
;			- 4: #MVX_IN_D_HIDE_BIT
;			- 5: #MVX_IN_D_DIR_BIT
MVX_IN_D_MOVE_STEP_BIT 		= 0
MVX_IN_D_HIDE_BIT 			= 4					; 1 - hide sprite when off-screen, 0 - roll over sprite when off-screen
MVX_IN_D_DIR_BIT			= 5					; 1 - to move right, 0 - to move left
; Modifies: A, BC

MoveX
	BIT MVX_IN_D_DIR_BIT, D
	JR NZ, .moveRight
	
	; Moving left - decrease X coordinate
	LD BC, (IX + MSS.X)
	DEC BC

	; Move again?
	LD A, D
	BIT MVX_IN_D_MOVE_STEP_BIT, A
	JR Z, .afterExtraMoveL
	DEC BC
.afterExtraMoveL

	; Check whether a enemy is outside the screen 
	LD A, B
	CP sc.SCR_X_MIN_POS							; B holds MSB from X, if B > 0 than X > 256
	JR NZ, .afterMoving
	LD A, C
	CP sc.SCR_X_MIN_POS + 5						; C holds LSB from X, ff C != 5 then X is> 5
	JR NC, .afterMoving

	; X == 0 (both A and B are 0) -> enemy out of screen
	BIT MVX_IN_D_HIDE_BIT, D					; Hide sprite or roll over?
	JR NZ, .hideSpriteL
	
	LD BC, sc.SCR_X_MAX_POS						; Roll over 
	JR .afterMoving

.hideSpriteL
 	CALL HideSprite								; Hide sprite
	JR .afterMoving

.moveRight
	; Moving right - increase X coordinate
	LD BC, (IX + MSS.X)	
	INC BC

	; Move again?
	LD A, D
	BIT MVX_IN_D_MOVE_STEP_BIT, A
	JR Z, .afterExtraMoveR
	INC BC
.afterExtraMoveR

	; If X >= 315 then hide sprite 
	; X is 9-bit value: 315 = 256 + 59 = %00000001 + %00111011 -> MSB: 1, LSB: 59
	LD A, B										; Load MSB from X into A
	CP 1										; 9-th bit set means X > 256
	JR NZ, .afterMoving
	LD A, C										; Load MSB from X into A
	CP 59										; MSB > 59 
	JR C, .afterMoving
	
	; Sprite is after 315
	BIT MVX_IN_D_HIDE_BIT, D					; Hide sprite or roll over?
	JR NZ, .hideSpriteR
	
	; Roll over 
	LD B, 0
	LD C, sc.SCR_X_MIN_POS
	JR .afterMoving

.hideSpriteR
 	CALL sr.HideSprite							; Hide sprite
	JR .afterMoving

.afterMoving

	LD (IX + sr.MSS.X), BC						; Update new X position
	RET

;----------------------------------------------------------;
;                          #MoveY                          ;
;----------------------------------------------------------;
; Move the sprite one pixel to the right or left along the Y-axis, depending on the A
; Input
;  - IX:	pointer to #MSS
;  - A:    	MOVE_Y_IN_XXX
MOVE_Y_IN_UP 				= 1					; Move up
MOVE_Y_IN_DOWN 				= 0					; Move down
; Output:
;  - A: 	MOVE_RET_XXX
MOVE_RET_VISIBLE 			= 1					; Sprite is still visible
MOVE_RET_HIDDEN 			= 0					; Sprite outside screen, or hits ground
; Modifies: A
MoveY
	CP MOVE_Y_IN_UP
	JR Z, .afterMovingUp						; Jump if moving up

	; Moving down - increment Y coordinate
	LD A, (IX + MSS.Y)	
	INC A

	; Check whether a enemy hits ground
	CP sc.SCR_Y_MAX_POS
	JR C, .afterMoving							; Jump if the enemy is above ground (A < SCR_Y_MAX_POS)

	; Enemy hits the ground
	LD A, MOVE_RET_HIDDEN
	CALL SpriteHit
	RET
.afterMovingUp

	; Moving up - decrease X coordinate
	LD A, (IX + MSS.Y)	
	DEC A

	; check if sprite is above screen
	CP sc.SCR_Y_MIN_POS
	JR NC, .afterMoving							; Jump if the enemy is below max screen postion (A >= SCR_Y_MIN_POS)

	; Sprite is above screen -> hide it
	CALL HideSprite
	LD A, MOVE_RET_HIDDEN
		
	RET
.afterMoving

	LD (IX + MSS.Y), A							; Update new X position
	LD A, MOVE_RET_VISIBLE
	RET	
;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE