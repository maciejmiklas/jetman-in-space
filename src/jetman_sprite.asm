; IDs for #jetSpriteDB
JET_SDB_FLY				= 201					; Jetman is flaying
JET_SDB_WALK			= 202					; Jetman is walking
JET_SDB_WALK_ST			= 203					; Jetman starts walking with raised feet to avoid moving over the ground and standing still.
JET_SDB_HOVER			= 204					; Jetman hovers
JET_SDB_STAND			= 205					; Jetman stands in place
JET_SDB_JSTAND			= 206					; Jetman quickly stops walking

JET_SDB_T_WF			= 220					; Transition: walking -> flaying
JET_SDB_T_FS			= 221					; Transition: flaying -> standing
JET_SDB_T_FW			= 222					; Transition: flaying -> walking
JET_SDB_T_WL			= 223					; Transition: walking -> falling

JET_SDB_SUB				= 100					; 100 for OFF_NX that CPIR finds ID and not OFF_NX (see record docu below, look for: OFF_NX)
JET_SDB_FRAME_SIZE		= 2

; The animation system is based on a state machine. It's a DB where each record contains a start and end offset to the animation pattern and 
; finally offset to a new DB record containing animation that will be played next.
; DB Record:
;	- ID: 			Entry ID for lookup via CPIR
;	- SIZE:			Amount of bytes in this record
;	- FRAME_UP:		Start offset for the upper part of the Jetman
;	- FRAME_LW: 	Start offset for the lower part of the Jetman
;	- OFF_NX:		ID of the following animation DB record. We subtract from this ID the 100 so that CPIR does not find OFF_NX but ID
; 	
;	DB [ID], [SIZE], [OFF_NX], [[FRAME_UP],[FRAME_LW] ,...], 
;
; Jetman sprite frames:
;   - 00-02: top, breathe 
;   - 03-05: top, no breathe
;   - 06-11: low, walk
;   - 12-17: low, fly
;   - 18-21: low, hover
;   - 22-25: low, walk -> fly
;   - 26-29: low, fly -> walk
;   - 30-33: low, walk -> fall
;   - 34-37: low, stand
jetSpriteDB
	; Jetman is flaying
	DB JET_SDB_FLY,		JET_SDB_FLY 	- JET_SDB_SUB,	48, 00,12, 00,13, 01,14, 01,15, 02,16, 02,17, 03,12, 03,13, 04,14, 04,15
														 DB 05,16, 05,17, 03,12, 03,13, 04,14, 04,15, 05,16, 05,17, 03,12, 03,13
														 DB 04,14, 04,15, 05,16, 05,17

	; Jetman hovers
	DB JET_SDB_HOVER,	JET_SDB_HOVER 	- JET_SDB_SUB, 	48, 00,18, 00,19, 01,20, 01,21, 02,16, 02,17, 03,12, 03,13, 04,14, 04,15 
														 DB 05,16, 05,17, 03,12, 03,13, 04,14, 04,15, 05,16, 05,17, 03,12, 03,13
														 DB 04,14, 04,15, 05,16, 05,17

	; Jetman starts walking with raised feet to avoid moving over the ground and standing still.
	DB JET_SDB_WALK_ST,	JET_SDB_WALK 	- JET_SDB_SUB, 	02, 03,07

	; Jetman is walking
	DB JET_SDB_WALK, 	JET_SDB_WALK 	- JET_SDB_SUB,	48, 03,06, 03,07, 04,08, 04,09, 05,10, 05,11, 03,06, 03,07, 04,08, 04,09
														 DB 05,10, 05,11, 00,06, 00,07, 01,08, 01,09, 02,10, 02,11, 03,06, 03,07 
														 DB 04,08, 04,09, 05,10, 05,11

	; Jetman stands in place
	DB JET_SDB_STAND,	JET_SDB_STAND	- JET_SDB_SUB, 	46, 03,34, 03,35, 04,36, 04,37, 05,34, 05,35, 03,36, 03,37, 04,34, 04,35
														 DB 05,36, 05,37, 00,34, 00,35, 01,36, 01,37, 02,34, 02,35, 03,36, 03,37
														 DB 04,34, 05,35, 05,36

	; Jetman stands on the ground for a very short time
	DB JET_SDB_JSTAND,	JET_SDB_STAND	- JET_SDB_SUB, 	02, 03,36

	; Transition: walking -> flaying
	DB JET_SDB_T_WF,	JET_SDB_FLY 	- JET_SDB_SUB, 	08, 03,22, 04,23, 05,24, 03,25

	; Transition: flaying -> standing
	DB JET_SDB_T_FS, 	JET_SDB_STAND	- JET_SDB_SUB,	4, 03,26, 04,27, 05,28, 03,29

	; Transition: flaying -> walking
	DB JET_SDB_T_FW, 	JET_SDB_WALK	- JET_SDB_SUB,	4, 03,26, 04,27, 05,28, 03,29

	; Transition: walking -> falling
	DB JET_SDB_T_WL,	JET_SDB_FLY		- JET_SDB_SUB, 	08, 03,30, 04,31, 05,32, 03,33

jetSpriteDBIdx			WORD 0					; Current position in DB
jetSpriteDBRemain		BYTE 0					; Amount of bytes that have to be still processed from the current record
jetSprDBNextID			BYTE JET_SDB_FLY		; ID in #jetSpriteDB for next animation/DB record						

JET_SPRITE_UP_ID		= 0						; ID of Jetman upper sprite

; bit 7 = Visible flag (1 = displayed)
; bits 5-0 = Pattern used by sprite (0-63), we will use pattern 0
JET_SPRITE_PAT			= %10000000

JET_SPRITE_LW_ID		= 1						; ID of Jetman lower sprite

;----------------------------------------------------------;
;                  #IntiJetmanSprite                       ;
;----------------------------------------------------------;
IntiJetmanSprite
	CALL UpdateJetmanSpritePosition							
	CALL UpdateJetmanSpritePattern

	NEXTREG SPR_REG_ATTR_3_H38, JET_SPRITE_PAT

	RET											; END IntiJetmanSprite

;----------------------------------------------------------;
;               #UpdateJetmanSpritePosition                ;
;----------------------------------------------------------;
UpdateJetmanSpritePosition	

	; Move Jetman Sprite to the current X position, the 9-bit value r=ires a few tricks. 
	LD BC, (jetX)								
	LD A, C			

	NEXTREG SPR_REG_NR_H34, JET_SPRITE_UP_ID	; Set the ID of the Jetman's sprite for the following commands								
	NEXTREG SPR_REG_X_H35, A					; Set LSB from BC into X, below in next lines we handle overflow bit

	NEXTREG SPR_REG_NR_H34, JET_SPRITE_LW_ID	; Set the ID of the Jetman's sprite for the following commands								
	NEXTREG SPR_REG_X_H35, A					; Set LSB from BC into X, below in next lines we handle overflow bit

	LD A, B										; Load MSB from X into A
	AND %00000001								; Keep only an overflow bit
	
	; Rotate sprite for Left/Right movement	
	LD E, A										; Store A in E to use A for loading data from RAM.
	LD A, (jetDirection)			
	LD D, A
	LD A, E										; Now, A has it's original value, and D contains a value from #jetState
	BIT JET_MOVE_LEFT_BIT, D					; Moving left bit set?
	JR Z, .rotateRight
	SET 3, A									; Rotate sprite left	
	JR .afterRotate	
.rotateRight	
	RES 3, A									; Rotate sprite right
.afterRotate

	NEXTREG SPR_REG_NR_H34, JET_SPRITE_UP_ID	; Set the ID of the Jetman's sprite for the following commands	
	NEXTREG SPR_REG_ATTR_2_H37, A

	NEXTREG SPR_REG_NR_H34, JET_SPRITE_LW_ID	; Set the ID of the Jetman's sprite for the following commands	
	NEXTREG SPR_REG_ATTR_2_H37, A

	; Move Jetman sprite to current Y postion, 8-bit value is easy 
	LD A, (jetY)		
	
	NEXTREG SPR_REG_NR_H34, JET_SPRITE_UP_ID	; Set the ID of the Jetman's sprite for the following commands							
	NEXTREG SPR_REG_Y_H36, A					; Set Y position

	NEXTREG SPR_REG_NR_H34, JET_SPRITE_LW_ID	; Set the ID of the Jetman's sprite for the following commands		
	ADD 16										; Lower part is 16px below upper					
	NEXTREG SPR_REG_Y_H36, A					; Set Y position

	; PRINT START
	LD B, 0
	LD H, 0
	LD HL, (jetX)
	CALL PrintNumHL

	LD B, 10
	LD H, 0
	LD A,  (jetY)
	LD L, A
	CALL PrintNumHL		

	LD B, 20
	LD H, 0
	LD A, (jetGnd)
	LD L, A
	CALL PrintNumHL	

	LD B, 30
	LD H, 0
	LD A, (jetMove)
	LD L, A
	CALL PrintNumHL		
	; PRINT END

	RET											; END UpdateJetmanSpritePosition

;----------------------------------------------------------;
;              #ChangeJetmanSpritePattern                  ;
;----------------------------------------------------------;
; Input:
;   - A: ID for #jesSprites, to siwtch to the next animation record
ChangeJetmanSpritePattern
	LD (jetSprDBNextID), A						; Next animation record

	LD A, 0
	LD (jetSpriteDBRemain), A					; No more bytes to process within the current DB record will cause the fast switch to the next.

	CALL UpdateJetmanSpritePattern				; Update next animation frame imedatelly
	
	RET											; END #ChangeJetmanSpritePattern 

;----------------------------------------------------------;
;            #UpdateJetmanSpritePattern                    ;
;----------------------------------------------------------;
; Update sprite pattern for the next animation frame
UpdateJetmanSpritePattern	

	; Switch to the next DB record if all bytes from the current one have been used
	LD A, (jetSpriteDBRemain)
	CP 0
	JR NZ, .afterRecordChange					; Jump if there are still bytes to be processed
	
	; Load new record
	LD HL, jetSpriteDB							; HL points to the beginning of the DB
	LD A, (jetSprDBNextID)						; CPIR will keep increasing HL until it finds record ID from A
	LD BC, 0									; Do not limit CPIR search
	CPIR

	;  Now, HL points to the next byte after the ID of the record, which contains data for the new animation pattern. 	
	LD A, (HL)									; Update next pointer to next animiation record
	ADD JET_SDB_SUB								; Add 100 because DB value had  -100, to avoid collision with ID
	LD (jetSprDBNextID), A

	INC HL										; HL points to [SIZE]
	LD A, (HL)									; Update SIZE
	LD (jetSpriteDBRemain), A

	INC HL										; HL points to first sprite data (uper/lower parts)
	LD (jetSpriteDBIdx), HL						; Database offset points to be bytes containing sprite offsets from sprite file

.afterRecordChange

	; 2 bytes will be consumed from current DB record -> upper and lower sprite for Jetman
	LD A, (jetSpriteDBRemain)
	ADD -JET_SDB_FRAME_SIZE
	LD (jetSpriteDBRemain), A

	LD HL, (jetSpriteDBIdx)

	; Update upper sprite
	NEXTREG SPR_REG_NR_H34, JET_SPRITE_UP_ID	; Set the ID of the Jetman's sprite for the following commands
	LD A, (HL)
	OR JET_SPRITE_PAT							; Store pattern number into Sprite Attribute	
	NEXTREG SPR_REG_ATTR_3_H38, A	

	; Update lower sprite
	NEXTREG SPR_REG_NR_H34, JET_SPRITE_LW_ID	; Set the ID of the Jetman's sprite for the following commands
	INC HL
	LD A, (HL)
	OR JET_SPRITE_PAT							; Store pattern number into Sprite Attribute	
	NEXTREG SPR_REG_ATTR_3_H38, A	

	; Update pointer to DB
	INC HL
	LD (jetSpriteDBIdx), HL

	RET											; END #UpdateJetmanSpritePattern	
