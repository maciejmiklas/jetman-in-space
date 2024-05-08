;----------------------------------------------------------;
;                        16x16 Sprites                     ;
;----------------------------------------------------------;

sample
	WORD 300
	DB 50, 1, 3, SR_SDB_EXPLODE, 0, 0
	WORD 0

;----------------------------------------------------------;
;           Memory Structure for Single Sprite             ;
;----------------------------------------------------------;
; BYTE [SR_MS_SPRITE_ID]
; WORD [SR_MS_DB_POINTER], [SR_MS_X]
; BYTE [SR_MS_Y], [SR_MS_STATE], [SR_MS_NEXT], [SR_MS_REMAINING], [SR_MS_MOVE_DELAY], [SR_MS_MOVE_DELAY_CNT], [SR_MS_MOVE_PATTERN_CNT]
; WORD [SR_MS_MOVE_PATTERN_POINTER]

SR_MS_SPRITE_ID				= 0						; Sprite ID for #_SPR_REG_ATR3_H38
SR_MS_DB_POINTER			= 1						; 16 bit pointer to current #srSpriteDB record
SR_MS_X						= 3						; 16 bit X position
SR_MS_Y						= 5						; Y position

; State
; Bits:
;	- 0: 	Visible flag, 1 = displayed, 0 = hidden
;	- 1:	Alive flag, 1 - sprite is alive, 2 - sprite is dying, disabled for colistion detection, but visible.
;	- 2:	1 = sprite moving down, 0 = sprite = moving up. This bit corresponds to _SPR_REG_ATR2_H37.
;	- 3: 	1 = sprite moving left, 0 = sprite = moving right. This bit corresponds to _SPR_REG_ATR2_H37.
;	- 4-7: 	not used
SR_MS_STATE					= 6
SR_MS_NEXT					= 7						; ID in #ssSpriteDB for next animation record/state
SR_MS_REMAINING				= 8						; Amount of animation frames (bytes) that still need to be processed within current #srSpriteDB record
SR_MS_MOVE_DELAY			= 9						; Number of game loops to skip before moving enemy
SR_MS_MOVE_DELAY_CNT		= 10					; Move delay counter
SR_MS_MOVE_PATTERN_CNT		= 11					; Counter for current position from move pattern
SR_MS_MOVE_PATTERN_POINTER	= 12					; 16 bit memory pointer to the movement pattern
SR_MS_END					= 13

SR_MS_SIZE					= SR_MS_END + 1 		; Size for single memory structure

; Possible values for #SR_MS_STATE.
SR_MS_STATE_VISIBLE			= %00000001
SR_MS_STATE_VISIBLE_BIT		= 0

SR_MS_STATE_ALIVE			= %00000010
SR_MS_STATE_ALIVE_BIT		= 1

SR_MS_STATE_DIRECTION_BIT	= 3
SR_MS_STATE_RIGHT_MASK		= %00001000				; See _SPR_REG_ATR2_H37 -> Bit 3
SR_MS_STATE_LEFT_MASK		= %00000000				
SR_MS_STATE_RES_FREE		= _SPR_REG_ATR2_RES_PAL	; Mask to reset free bits.

; DB IDs
SR_SDB_EXPLODE				= 201					; Explosion
SR_SDB_FIRE					= 202					; Fire
SR_SDB_COMET1				= 203					; Comet 1
SR_SDB_COMET2				= 204					; Comet 2
SR_SDB_HIDE					= 255					; Hides Sprite

SR_SDB_SUB					= 100					; 100 for OFF_NX that CPIR finds ID and not OFF_NX (see record docu below, look for: OFF_NX)

;----------------------------------------------------------;
;          Memory Structure for Sprite Move Patern         ;
;----------------------------------------------------------;
; Move pattern (given by #SR_MS_MOVE_PATTERN_CNT) consists of a byte array. The first byte determines the number of elements in this array, 
; and the remaining move pattern, where each byte carries the same information:
; bit 0-4: amount of iterations, each iteration will change X and Y based following bits
; bit 5-6: number of pixels to change X in a single iteration, from 0 to 3. 
;          The X will increase or decrease depending on the movement direction given by bit 3 in #SR_MS_STATE.
; bit 7-8: number of pixels to change Y in a single iteration, from 0 to 3. 
;          The Y will increase or decrease depending on the movement direction given by bit 2 in #SR_MS_STATE.

;----------------------------------------------------------;
;                         Sprite DB                        ;
;----------------------------------------------------------;
; The animation system is based on a state machine. It's a DB where each record contains a start and end offset to the animation pattern and 
; finally offset to a new DB record containing animation that will be played next.
; DB Record:
;	- ID: 			Entry ID for lookup via CPIR
;	- SIZE:			Amount of bytes in this record
;	- FRAME:		Sprite offset in spr file
;	- OFF_NX:		ID of the following animation DB record. We subtract from this ID the 100 so that CPIR does not find OFF_NX but ID
; 	
;	DB [ID], [OFF_NX], [SIZE], [[FRAME] ,...]
srSpriteDB
	; Explosion, and afterward, the sprite disappears
	DB SR_SDB_EXPLODE,	SR_SDB_HIDE - SR_SDB_SUB,		04,		38, 39, 40, 41
	DB SR_SDB_FIRE,		SR_SDB_FIRE - SR_SDB_SUB,		03,		42, 43, 44
	DB SR_SDB_COMET1,	SR_SDB_COMET1 - SR_SDB_SUB,		03,		45, 46, 47
	DB SR_SDB_COMET2,	SR_SDB_COMET2 - SR_SDB_SUB,		03,		48, 49, 50

; We are using platform coordinates for bumping, which are too thick for the thin sprite
SR_PLATFROM_MARGIN_UP			= 12
SR_PLATFROM_MARGIN_DOWN			= 5

;----------------------------------------------------------;
;                     #SrWeaponHit                         ;
;----------------------------------------------------------;
; Checks all active enemies given by IX for collision with leaser beam
; Input
;  - IX:	Pointer to "Memory Structure for Single Sprite", the enemies
;  - B:		Number of enemies
;  - H:     Half of the width of the enemy
;  - L:		Half of the height of the enemy
; Modifies: ALL
SrWeaponHit
.loop
	PUSH BC										; Preserve B for loop counter

	LD A, (IX + SR_MS_STATE)
	AND SR_MS_STATE_VISIBLE						; Reset all bits but visibility
	CP 0
	JR Z, .continue								; Jump if enemy is hidden

	; Sprite is visible
	CALL JwHitEnemy

.continue
	; Move HL to the beginning of the next #jwSpriteX
	LD DE, SR_MS_SIZE
	ADD IX, DE
	POP BC
	DJNZ .loop									; Jump if B > 0

	RET

;----------------------------------------------------------;
;                        #SrSpriteHit                      ;
;----------------------------------------------------------;
; Input
;  - IX:	pointer to "Memory Structure for Single Sprite"
SrSpriteHit	
	LD A, (IX + SR_MS_STATE)					; Sprite is dying; turn off collision detection
	RES SR_MS_STATE_ALIVE_BIT, A
	LD (IX + SR_MS_STATE), A

	LD A, SR_SDB_EXPLODE
	CALL SrSetSpritePattern						; Enemy expoldes
	RET
;----------------------------------------------------------;
;                  #SrAnimateSprites                       ;
;----------------------------------------------------------;
; Input
;  - IX:	pointer to "Memory Structure for Single Sprite"
;  - B:		number of sprites
; Modifies: A, BC, HL
SrAnimateSprites

.loop
	PUSH BC										; Preserve B for loop counter

	LD A, (IX + SR_MS_STATE)
	AND SR_MS_STATE_VISIBLE						; Reset all bits but visibility
	CP 0
	JR Z, .continue								; Jump if visibility is not set -> hidden, can be reused

	; Sprite is visible
	CALL SrSetSpriteId							; Set the ID of the sprite for the following commands
	CALL SrUpdateSpritePattern

.continue
	; Move HL to the beginning of the next #jwSpriteX
	LD DE, SR_MS_SIZE
	ADD IX, DE
	POP BC
	DJNZ .loop									; Jump if B > 0

	RET

;----------------------------------------------------------;
;                    #SrSetSpriteId                        ;
;----------------------------------------------------------;
; Input:
;  - IX:	pointer to "Memory Structure for Single Sprite"
; Modifies: A
SrSetSpriteId

	LD A, (IX + SR_MS_SPRITE_ID)
	NEXTREG _SPR_REG_NR_H34, A					; Set the ID of the sprite for the following commands

	RET
;----------------------------------------------------------;
;                #SrUpdateSpritePosition                   ;
;----------------------------------------------------------;
; Input:
;  - IX:	pointer to "Memory Structure for Single Sprite"
; Modifies: A, BC
SrUpdateSpritePosition

	; Move the sprite to the X position, the 9-bit value requires a few tricks. 
	LD BC, (IX + SR_MS_X)						

	LD A, C										; Set LSB from BC (X)
	NEXTREG _SPR_REG_X_H35, A					

	; Update the H37
	LD A, B										; Set MSB from BC (X)
	AND _SPR_REG_ATR2_OVEFLOW					; Keep only an overflow bit
	LD B, A										; Backup A to B, as we need A

	LD A, (IX + SR_MS_STATE)
	RES _SPR_REG_ATR2_OVER_BIT, A				; Reset overflow and set it in next command
	OR B										; Apply B to set MSB from X
	AND SR_MS_STATE_RES_FREE					; Reset bits reserved for pallete

	RES _SPR_REG_ATR2_MIRY_BIT, A				; Reset rotation bits, as we use those for different things and might be set
	RES _SPR_REG_ATR2_ROT_BIT, A

	NEXTREG _SPR_REG_ATR2_H37, A

	; Move the sprite to the Y position
	LD A, (IX + SR_MS_Y)
	NEXTREG _SPR_REG_Y_H36, A					; Set Y position

	RET

;----------------------------------------------------------;
;                     #SrHideSprite                        ;
;----------------------------------------------------------;
; Hide Sprite given by IX
; Input
;  - IX - pointer to "Memory Structure for Single Sprite"
; Modifies: A
SrHideSprite

	; Hide sprite
	LD A, _SPR_PATTERN_HIDE						; Hide sprite on display	
	NEXTREG _SPR_REG_ATR3_H38, A

	LD A, (IX + SR_MS_STATE)					; Mark sprite as hidden
	RES SR_MS_STATE_VISIBLE_BIT, A
	LD (IX + SR_MS_STATE), A
	
	RET

;----------------------------------------------------------;
;                      #SrShowSprite                       ;
;----------------------------------------------------------;
; Input:
;  - IX: 	Pointer to "Memory Structure for Single Sprite"
;  - A:		Prepared state
; Modifies: A
SrShowSprite
	SET SR_MS_STATE_VISIBLE_BIT, A
	SET SR_MS_STATE_ALIVE_BIT, A
	LD (IX + SR_MS_STATE), A

	RET	
;----------------------------------------------------------;
;                #SrUpdateSpritePattern                    ;
;----------------------------------------------------------;
; Show the current sprite pattern and switch the pointer to the next one so the following method call will display it
; Input:
;  - IX:	pointer to "Memory Structure for Single Sprite"
; Modifies: A, BC, HL
SrUpdateSpritePattern

	; Switch to the next DB record if all bytes from the current one have been used
	LD A, (IX + SR_MS_REMAINING)
	CP 0
	JR NZ, .afterRecordChange					; Jump if there are still bytes to be processed	

	; Find new DB record
	LD A, (IX + SR_MS_NEXT)	

	; The next animation record can have value #SR_SDB_HIDE which means: hide it
	CP SR_SDB_HIDE
	JR NZ, .afterHide
	CALL SrHideSprite
	RET
.afterHide

	; Load new DB record
	LD A, (IX + SR_MS_NEXT)	
	CALL SrSetSpritePattern			

.afterRecordChange

	; "Memory Structure for Single Sprite" has been fully updated to a current frame from #srSpriteDB
	; Update the remaining animation frames counter.
	LD A, (IX + SR_MS_REMAINING)				
	DEC A
	LD (IX + SR_MS_REMAINING), A

	; Show sprite pattern
	LD HL, (IX + SR_MS_DB_POINTER)				; HL points to a memory location holding a pointer to the current DB position with the next sprite pattern
	LD A, (HL)									; A holds the next sprite pattern
	OR _SPR_PATTERN_SHOW						; Store pattern number into Sprite Attribute	
	NEXTREG _SPR_REG_ATR3_H38, A

	; Move #SR_MS_DB_POINTER to the next sprite pattern
	LD HL, (IX + SR_MS_DB_POINTER)
	INC HL
	LD (IX + SR_MS_DB_POINTER), HL

	RET

;----------------------------------------------------------;
;                  #SrSetSpritePattern                     ;
;----------------------------------------------------------;
; Set given pointer IX to animation pattern from #srSpriteDB given by B
; Input:
;  - IX: 	Pointer to "Memory Structure for Single Sprite"
;  - A:		ID in #srSpriteDB
; Modifies: A, BC, HL
SrSetSpritePattern
	
	; Find DB record
	LD HL, srSpriteDB							; HL points to the beginning of the DB				
	LD BC, 0									; Do not limit CPIR search
	CPIR										; CPIR will keep increasing HL until it finds a record ID from A

	;  Now, HL points to the next byte after the ID of the record, which contains data for the new animation pattern. 	
	LD A, (HL)	
	ADD SR_SDB_SUB								; Add 100 because DB value had  -100, to avoid collision with ID
	LD (IX + SR_MS_NEXT), A						; Update #SR_MS_NEXT	

	INC HL										; HL points to [SIZE] in DB
	LD A, (HL)									
	LD (IX + SR_MS_REMAINING), A				; Update #SR_MS_REMAINING

	INC HL										; HL points to [FRAME] in DB
	LD (IX + SR_MS_DB_POINTER), HL				; Update #SR_MS_DB_POINTER

	RET

;----------------------------------------------------------;
;                #SrPlaftormColision                       ;
;----------------------------------------------------------;
; A sprite can hit platform from left or right. 
; Input:
;  - IX: 	pointer to "Memory Structure for Single Sprite", single sprite to check colsion for.
;  - IY:	Structure like #jpPlatformBump
;  - L:		Half of the height of the sprite
; Modifies: ALL
SrPlaftormColision

	; Exit if sprite is not alive
	LD A, (IX + SR_MS_STATE)
	AND SR_MS_STATE_ALIVE						; Reset all bits but alive
	CP SR_MS_STATE_ALIVE
	RET NZ										; Exit if sprite is not alive

	LD B, (IY)									; Load into B the number of platforms to check
.platformsLoop	

	LD A, (IX + SR_MS_X)						; A holds current X position of the sprite for colision check (only LSB, platrofrm are limited to X <= 255)
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
	ADD SR_PLATFROM_MARGIN_UP					; Increase start Y to make platform thinner
	SUB L										; Thickness to the sprite
	LD D, A										; D contains [Y platform start]								

	INC IY										; HL points to [Y platform end]
	LD A, (IY)
	SUB SR_PLATFROM_MARGIN_DOWN					; Decrease end Y to make the platform thinner
	ADD L										; Thickness to the sprite
	LD E, A										; E contains [Y platform end]

	; Now D contains [Y platform start + margin],  E contains [Y platform end + margin]
	LD A, (IX + SR_MS_Y)						; A holds current shot Y position
	
	CP D										; Compare [Y sprite] position to [Y start]
	JR C, .platformsLoopEnd						; Jump if shot < [Y platform start]

	CP E
	JR NC, .platformsLoopEnd					; Jump if shot > [Y end]

	; Sprite hits the platform!
	PUSH BC
	CALL SrSetSpriteId
	CALL SrSpriteHit
	POP BC

.platformsLoopEnd
	DJNZ .platformsLoop							; Decrease B until all platforms have been evaluated
	RET
