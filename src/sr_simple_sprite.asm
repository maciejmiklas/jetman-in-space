;----------------------------------------------------------;
;                        16x16 Sprites                     ;
;----------------------------------------------------------;

sample
	WORD 300
	DB 50, 1, 3, SR_SDB_EXPLODE, 0, 0
	WORD 0

;----------------------------------------------------------;
;           Memmory Structure for Single Sprite            ;
;----------------------------------------------------------;
; WORD 	[#SR_MS_: X position]
; BYTE 	[#SR_MS_Y: Y position], 
;	   	[#SR_MS_STATE, bit: 0 = Visible flag (1 = displayed), bit: 1-7 used by particular sprite engine], 
;		[#SR_MS_SPRITE_ID: Sprite ID for #_SPR_REG_ATTR_3_H38],
;	   	[#SR_MS_NEXT: ID in #ssSpriteDB for next animation record/state]
;	   	[#SR_MS_REMAINING: Amount of animation frames (bytes) that still need to be processed within current #srSpriteDB record]
; WORD 	[#SR_MS_DB_POINTER: pointer to current #srSpriteDB record]
; Example:
;	 WORD 300
;	 DB 50, 1, 3, SR_SDB_EXPLODE, 0, 0
;	 WORD 0

; Offsets for Memmory Structure
SR_MS_X						= 0		
SR_MS_Y						= 2
SR_MS_STATE					= 3
SR_MS_SPRITE_ID				= 4
SR_MS_NEXT					= 5
SR_MS_REMAINING				= 6
SR_MS_DB_POINTER			= 7

SR_MS_SIZE					= 10					; Size for single memmory structure

; Possible values for #SR_MS_STATE.
; Bits:
;   - 0: 	Visible flag, 1 = displayed, 0 = hiden
;   - 1-7: 	Used by particluar sprite engine
SR_MS_STATE_VISIBLE			= %00000001
SR_MS_STATE_VISIBLE_BIT		= 0

; DB IDs
SR_SDB_EXPLODE				= 201					; Explositon
SR_SDB_FIRE					= 202					; Fire
SR_SDB_HIDE					= 255					; Hides Sprite

SR_SDB_SUB					= 100					; 100 for OFF_NX that CPIR finds ID and not OFF_NX (see record docu below, look for: OFF_NX)

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
	DB SR_SDB_EXPLODE,	SR_SDB_HIDE - SR_SDB_SUB,		03,		38, 39, 40, 41
	DB SR_SDB_FIRE,		SR_SDB_FIRE - SR_SDB_SUB,		03,		42, 43, 44

/*
;----------------------------------------------------------;
;                           #SrTest                        ;
;----------------------------------------------------------;
SrTest
	LD IX, sample
	LD A, SR_SDB_EXPLODE
	CALL SrSetSpritePattern

	CALL SrUpdateSpritePosition
RET*/

;----------------------------------------------------------;
;                #SrUpdateSpritePosition                   ;
;----------------------------------------------------------;
; Input
;  - IX - pointer to "Memmory Structure for Single Sprite"
SrUpdateSpritePosition

	; Return if sprite is hidden
	LD A, (IX + SR_MS_STATE)
	AND SR_MS_STATE_VISIBLE
	CP A, 0
	RET Z										

	LD A, (IX + SR_MS_SPRITE_ID)
	NEXTREG _SPR_REG_NR_H34, A					; Set the ID of the Jetman's sprite for the following commands

	; Move the sprite to the X position, the 9-bit value reqires a few tricks. 
	LD BC, (IX + SR_MS_X)						

	LD A, C										; Set LSB from BC (X)
	NEXTREG _SPR_REG_X_H35, A					

	LD A, B										; Set MSB from BC (X)
	AND %00000001								; Keep only an overflow bit
	NEXTREG _SPR_REG_ATTR_2_H37, A

	; Move the sprite to the Y position
	LD A, (IX + SR_MS_X)
	NEXTREG _SPR_REG_Y_H36, A					; Set Y position

	RET											; END #SrShowSprite 

;----------------------------------------------------------;
;                  #SrSetSpritePattern                       ;
;----------------------------------------------------------;
; Set given pointer IX to animation pattern from #srSpriteDB given by B
; Input
;  - IX - pointer to "Memmory Structure for Single Sprite"
;  - A - ID in #srSpriteDB 
SrSetSpritePattern
	
	; Find DB record
	LD HL, srSpriteDB							; HL points to the beginning of the DB				
	LD BC, 0									; Do not limit CPIR search
	CPIR										; CPIR will keep increasing HL until it finds record ID from A

	;  Now, HL points to the next byte after the ID of the record, which contains data for the new animation pattern. 	
	LD A, (HL)	
	ADD SR_SDB_SUB								; Add 100 because DB value had  -100, to avoid collision with ID
	LD (IX + SR_MS_NEXT), A						; Update #SR_MS_NEXT	

	INC HL										; HL points to [SIZE] in DB
	LD A, (HL)									
	LD (IX + SR_MS_REMAINING), A				; Update #SR_MS_REMAINING

	INC HL										; HL points to [FRAME] in DB
	LD (IX + SR_MS_DB_POINTER), HL				; Update #SR_MS_DB_POINTER

	RET 										; END #SrSetSpritePattern

;----------------------------------------------------------;
;                #SrUpdateSpritePattern                    ;
;----------------------------------------------------------;
; Update sprite pattern for the next animation frame
; Input
;  - IX - pointer to "Memmory Structure for Single Sprite"
SrUpdateSpritePattern

	; Return if sprite is already hidden
	LD A, (IX + SR_MS_STATE)
	AND SR_MS_STATE_VISIBLE
	CP A, 0
	RET Z

	LD A, (IX + SR_MS_SPRITE_ID)
	NEXTREG _SPR_REG_NR_H34, A					; Set the ID of the Jetman's sprite for the following commands

	; Switch to the next DB record if all bytes from the current one have been used
	LD A, (IX + SR_MS_REMAINING)
	CP 0
	JR NZ, .afterRecordChange					; Jump if there are still bytes to be processed	

	; Find new DB record
	LD A, (IX + SR_MS_NEXT)	

	; The next animation record can have value #SR_SDB_HIDE which means: hide it
	CP SR_SDB_HIDE
	JR NZ, .afterHide

	; Hide sprite and exit function
	LD A, _SPR_PATTERN_HIDE						; Hide sprite on display	
	NEXTREG _SPR_REG_ATTR_3_H38, A

	LD A, (IX + SR_MS_STATE)					; Mark sprite as hidden
	RES SR_MS_STATE_VISIBLE_BIT, A
	LD (IX + SR_MS_STATE), A
	RET 										; Exit
.afterHide

	; Load new DB record
	LD A, (IX + SR_MS_NEXT)	
	CALL SrSetSpritePattern			

.afterRecordChange

	; "Memmory Structure for Single Sprite" has been fully updated to current frame from #srSpriteDB
	; Update the remaining animation frames counter.
	LD A, (IX + SR_MS_REMAINING)				
	DEC A
	LD (IX + SR_MS_REMAINING), A

	; Show sprite pattern
	LD HL, (IX + SR_MS_DB_POINTER)				; HL points to a memory location holding a pointer to the current DB position with the next sprite pattern
	LD A, (HL)									; A holds next sprite pattern
	OR _SPR_PATTERN_SHOW						; Store pattern number into Sprite Attribute	
	NEXTREG _SPR_REG_ATTR_3_H38, A

	; Move #SR_MS_DB_POINTER to the next sprite pattern
	LD HL, (IX + SR_MS_DB_POINTER)
	INC HL
	LD (IX + SR_MS_DB_POINTER), HL

	RET											; END #SrUpdateSpritePattern 