;----------------------------------------------------------;
;                        16x16 Sprites                     ;
;----------------------------------------------------------;
	MODULE sr

;----------------------------------------------------------;
;           Memory Structure for Single Sprite             ;
;----------------------------------------------------------;
	STRUCT MSS
ID						BYTE					; Sprite ID for #_SPR_REG_ATR3_H38
DB_POINTER				WORD					; Pointer to #srSpriteDB record
X						WORD					; X position of the sprite
Y						BYTE					; Y position of the sprite

; Bits:
;	- 0: 	Visible flag, 1 = displayed, 0 = hidden
;	- 1:	Alive flag, 1 - sprite is alive, 2 - sprite is dying, disabled for colistion detection, but visible.
;	- 2:	1 = sprite moving down, 0 = sprite = moving up. This bit corresponds to _SPR_REG_ATR2_H37.
;	- 3: 	1 = sprite moving left, 0 = sprite = moving right. This bit corresponds to _SPR_REG_ATR2_H37.
;	- 4-7: 	not used
STATE					BYTE
NEXT					BYTE					; ID in #ssSpriteDB for next animation record/state
REMAINING				BYTE					; Amount of animation frames (bytes) that still need to be processed within current #srSpriteDB record


MOVE_DELAY_LOOPS		BYTE					; Number of game loops to skip before moving enemy (delays movement speed)
MOVE_DELAY_CNT			BYTE					; Move delay counter
MOVE_PATTERN_POINTER	WORD					; Pointer to the movement pattern
MOVE_PATTERN_CNT 		BYTE					; Counter for current position in the movement pattern
RESPOWN_DELAY_LOOPS		BYTE					; Number of game loops delaying respawn
RESPOWN_DELAY_CNT		BYTE					; Respawn delay counter
	ENDS


; Possible values for #MSS.STATE
MSS_STATE_VISIBLE		= %00000001
MSS_STATE_VISIBLE_BIT	= 0

MSS_STATE_ALIVE			= %00000010
MSS_STATE_ALIVE_BIT		= 1

MSS_STATE_DIRECTION_BIT	= 3
MSS_STATE_RIGHT_MASK	= %00001000				; See _SPR_REG_ATR2_H37 -> Bit 3
MSS_STATE_LEFT_MASK		= %00000000				
MSS_STATE_RES_FREE		= _SPR_REG_ATR2_RES_PAL	; Mask to reset free bits.

; DB IDs
SDB_EXPLODE				= 201					; Explosion
SDB_FIRE				= 202					; Fire
SDB_COMET1				= 203					; Comet 1
SDB_COMET2				= 204					; Comet 2
SDB_HIDE				= 255					; Hides Sprite

SDB_SUB					= 100					; 100 for OFF_NX that CPIR finds ID and not OFF_NX (see record docu below, look for: OFF_NX)

;----------------------------------------------------------;
;          Memory Structure for Sprite Move Patern         ;
;----------------------------------------------------------;
; Move pattern (given by #MSS.MOVE_PATTERN_CNT) consists of a byte array. The first byte determines the number of elements in this array, 
; and the remaining move pattern, where each byte carries the same information:
; bit 0-4: amount of iterations, each iteration will change X and Y based following bits
; bit 5-6: number of pixels to change X in a single iteration, from 0 to 3. 
;          The X will increase or decrease depending on the movement direction given by bit 3 in #MSS.STATE.
; bit 7-8: number of pixels to change Y in a single iteration, from 0 to 3. 
;          The Y will increase or decrease depending on the movement direction given by bit 2 in #MSS.STATE.

;----------------------------------------------------------;
;                         Sprite DB                        ;
;----------------------------------------------------------;
	STRUCT SPR_REC
ID		BYTE									; Entry ID for lookup via CPIR
OFF_NX	BYTE									; ID of the following animation DB record. We subtract from this ID the 100 so that CPIR does not find OFF_NX but ID
SIZE	BYTE									; Amount of frames/sprite patterns in this record
	ENDS

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
	RES MSS_STATE_ALIVE_BIT, A
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

	LD A, (IX + MSS.STATE)
	AND MSS_STATE_VISIBLE						; Reset all bits but visibility
	CP 0
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
	AND MSS_STATE_RES_FREE						; Reset bits reserved for pallete

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
	RES MSS_STATE_VISIBLE_BIT, A
	LD (IX + MSS.STATE), A
	
	RET

;----------------------------------------------------------;
;                       #ShowSprite                        ;
;----------------------------------------------------------;
; Input:
;  - IX: 	Pointer to #MSS
;  - A:		Prepared state
; Modifies: A
ShowSprite
	SET MSS_STATE_VISIBLE_BIT, A
	SET MSS_STATE_ALIVE_BIT, A
	LD (IX + MSS.STATE), A

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
	LD A, (IX + MSS.REMAINING)				
	DEC A
	LD (IX + MSS.REMAINING), A

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
; A sprite can hit platform from left or right. 
; Input:
;  - IX: 	pointer to #MSS, single sprite to check colsion for
;  - IY:	Structure like #platformBump
;  - L:		Half of the height of the sprite
; Modifies: ALL
PlaftormColision

	; Exit if sprite is not alive
	LD A, (IX + MSS.STATE)
	AND MSS_STATE_ALIVE							; Reset all bits but alive
	CP MSS_STATE_ALIVE
	RET NZ										; Exit if sprite is not alive

	LD B, (IY)									; Load into B the number of platforms to check
.platformsLoop	

	LD A, (IX + MSS.X)							; A holds current X position of the sprite for colision check (only LSB, platrofrm are limited to X <= 255)
	INC IY										; HL points to [X platform start]
	LD C, (IY)									; C holds [X platform start]
	CP C
	JR NC, .afterXLeftCheck						; Jump if [X sprite] < [X platform start]

	; There is no collision with the current platform. Move the IY pointer to the next one and continue looping
	INC IY										; HL points to [X platform end]
	INC IY										; HL points to [Y platform start]
	INC IY										; HL points to [Y platform end]
	JR .platformsLoopEnd
.afterXLeftCheck
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
	PUSH BC
	CALL SetSpriteId
	CALL SpriteHit
	POP BC

.platformsLoopEnd
	DJNZ .platformsLoop							; Decrease B until all platforms have been evaluated
	RET

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE									