;----------------------------------------------------------;
;                      Jetman Sprite                       ;
;----------------------------------------------------------;

JS_SPR_ID_JET_UP		= 0						; ID of Jetman upper sprite
JS_SPR_ID_JET_LW		= 1						; ID of Jetman lower sprite

; IDs for #jsSpriteDB
JS_SDB_FLY				= 201					; Jetman is flaying
JS_SDB_WALK				= 202					; Jetman is walking
JS_SDB_WALK_ST			= 203					; Jetman starts walking with raised feet to avoid moving over the ground and standing still.
JS_SDB_HOVER			= 204					; Jetman hovers
JS_SDB_STAND			= 205					; Jetman stands in place
JS_SDB_JSTAND			= 206					; Jetman quickly stops walking

JS_SDB_T_WF				= 220					; Transition: walking -> flaying
JS_SDB_T_FS				= 221					; Transition: flaying -> standing
JS_SDB_T_FW				= 222					; Transition: flaying -> walking
JS_SDB_T_WL				= 223					; Transition: walking -> falling

JS_SDB_SUB				= 100					; 100 for OFF_NX that CPIR finds ID and not OFF_NX (see record docu below, look for: OFF_NX)
JS_SDB_FRAME_SIZE		= 2

; The animation system is based on a state machine. It's a DB where each record contains a start and end offset to the animation pattern and 
; finally offset to a new DB record containing animation that will be played next.
; DB Record:
;	- ID: 			Entry ID for lookup via CPIR
;	- SIZE:			Amount of bytes in this record
;	- FRAME_UP:		Start offset for the upper part of the Jetman
;	- FRAME_LW: 	Start offset for the lower part of the Jetman
;	- OFF_NX:		ID of the following animation DB record. We subtract from this ID the 100 so that CPIR does not find OFF_NX but ID
; 	
;	DB [ID], [OFF_NX], [SIZE], [[FRAME_UP],[FRAME_LW] ,...], 
;
jsSpriteDB
	; Jetman is flaying
	DB JS_SDB_FLY,		JS_SDB_FLY - JS_SDB_SUB,		48
														DB 00,12, 00,13, 01,14, 01,15, 02,16, 02,17, 03,12, 03,13, 04,14, 04,15
														DB 05,16, 05,17, 03,12, 03,13, 04,14, 04,15, 05,16, 05,17, 03,12, 03,13
														DB 04,14, 04,15, 05,16, 05,17

	; Jetman hovers
	DB JS_SDB_HOVER,	JS_SDB_HOVER - JS_SDB_SUB,		48 
														DB 00,18, 00,19, 01,20, 01,21, 02,16, 02,17, 03,12, 03,13, 04,14, 04,15 
														DB 05,16, 05,17, 03,12, 03,13, 04,14, 04,15, 05,16, 05,17, 03,12, 03,13
														DB 04,14, 04,15, 05,16, 05,17

	; Jetman starts walking with raised feet to avoid moving over the ground and standing still.
	DB JS_SDB_WALK_ST,	JS_SDB_WALK	- JS_SDB_SUB,		02, 03,07

	; Jetman is walking
	DB JS_SDB_WALK, 	JS_SDB_WALK - JS_SDB_SUB,		48
														DB 03,06, 03,07, 04,08, 04,09, 05,10, 05,11, 03,06, 03,07, 04,08, 04,09
														DB 05,10, 05,11, 00,06, 00,07, 01,08, 01,09, 02,10, 02,11, 03,06, 03,07 
														DB 04,08, 04,09, 05,10, 05,11

	; Jetman stands in place
	DB JS_SDB_STAND,	JS_SDB_STAND - JS_SDB_SUB,		46 
														DB 03,34, 03,35, 04,36, 04,37, 05,34, 05,35, 03,36, 03,37, 04,34, 04,35
														DB 05,36, 05,37, 00,34, 00,35, 01,36, 01,37, 02,34, 02,35, 03,36, 03,37
														DB 04,34, 05,35, 05,36

	; Jetman stands on the ground for a very short time
	DB JS_SDB_JSTAND,	JS_SDB_STAND - JS_SDB_SUB, 		02, 03,36

	; Transition: walking -> flaying
	DB JS_SDB_T_WF,		JS_SDB_FLY - JS_SDB_SUB, 		08, 03,22, 04,23, 05,24, 03,25

	; Transition: flaying -> standing
	DB JS_SDB_T_FS, 	JS_SDB_STAND - JS_SDB_SUB,		4, 03,26, 04,27, 05,28, 03,29

	; Transition: flaying -> walking
	DB JS_SDB_T_FW, 	JS_SDB_WALK	- JS_SDB_SUB,		4, 03,26, 04,27, 05,28, 03,29

	; Transition: walking -> falling
	DB JS_SDB_T_WL,		JS_SDB_FLY - JS_SDB_SUB, 		08, 03,30, 04,31, 05,32, 03,33

jsSpriteDBIdx			WORD 0					; Current position in DB
jsSpriteDBRemain		BYTE 0					; Amount of bytes that have to be still processed from the current record
jsSprDBNextID			BYTE JS_SDB_FLY			; ID in #jsSpriteDB for next animation/DB record						

;----------------------------------------------------------;
;                 #JsIntiJetmanSprite                      ;
;----------------------------------------------------------;
JsIntiJetmanSprite
	CALL JsUpdateJetmanSpritePosition							
	CALL JsUpdateJetmanSpritePattern
	RET											; END JsIntiJetmanSprite

;----------------------------------------------------------;
;              #JsUpdateJetmanSpritePosition               ;
;----------------------------------------------------------;
JsUpdateJetmanSpritePosition	

	; Move Jetman Sprite to the current X position, the 9-bit value r=ires a few tricks. 
	LD BC, (jtX)								
	LD A, C			

	NEXTREG _SPR_REG_NR_H34, JS_SPR_ID_JET_UP	; Set the ID of the Jetman's sprite for the following commands								
	NEXTREG _SPR_REG_X_H35, A					; Set LSB from BC (X)

	NEXTREG _SPR_REG_NR_H34, JS_SPR_ID_JET_LW	; Set the ID of the Jetman's sprite for the following commands								
	NEXTREG _SPR_REG_X_H35, A					; Set LSB from BC (X)

	LD A, B										; Load MSB from X into A
	AND %00000001								; Keep only an overflow bit
	
	; Rotate sprite for Left/Right movement	
	LD E, A										; Store A in E to use A for loading data from RAM.
	LD A, (joJetmanDirection)			
	LD D, A
	LD A, E										; Now, A has its original value, and D contains a value from #jetState
	BIT JO_MOVE_LEFT_BIT, D						; Moving left bit set?
	JR Z, .rotateRight
	SET 3, A									; Rotate sprite left	
	JR .afterRotate	
.rotateRight	
	RES 3, A									; Rotate sprite right
.afterRotate

	NEXTREG _SPR_REG_NR_H34, JS_SPR_ID_JET_UP	; Set the ID of the Jetman's sprite for the following commands	
	NEXTREG _SPR_REG_ATTR_2_H37, A

	NEXTREG _SPR_REG_NR_H34, JS_SPR_ID_JET_LW	; Set the ID of the Jetman's sprite for the following commands	
	NEXTREG _SPR_REG_ATTR_2_H37, A

	; Move Jetman sprite to current Y postion, 8-bit value is easy 
	LD A, (jtY)		
	
	NEXTREG _SPR_REG_NR_H34, JS_SPR_ID_JET_UP	; Set the ID of the Jetman's sprite for the following commands							
	NEXTREG _SPR_REG_Y_H36, A					; Set Y position

	NEXTREG _SPR_REG_NR_H34, JS_SPR_ID_JET_LW	; Set the ID of the Jetman's sprite for the following commands		
	ADD 16										; Lower part is 16px below upper					
	NEXTREG _SPR_REG_Y_H36, A					; Set Y position

	; PRINT START
	LD B, 0
	LD H, 0
	LD HL, (jtX)
	CALL TxPrintNumHL

	LD B, 10
	LD H, 0
	LD A,  (jtY)
	LD L, A
	CALL TxPrintNumHL		
/*
	LD B, 20
	LD H, 0
	LD A, (jtGnd)
	LD L, A
	CALL TxPrintNumHL	

	LD B, 30
	LD H, 0
	LD A, (joJoyDirection)
	LD L, A
	CALL TxPrintNumHL		
	*/
	; PRINT END

	RET											; END JsUpdateJetmanSpritePosition

;----------------------------------------------------------;
;              #JsChangeJetmanSpritePattern                ;
;----------------------------------------------------------;
; Input:
;   - A: ID for #jesSprites, to siwtch to the next animation record
JsChangeJetmanSpritePattern
	LD (jsSprDBNextID), A						; Next animation record

	LD A, 0
	LD (jsSpriteDBRemain), A					; No more bytes to process within the current DB record will cause the fast switch to the next.

	CALL JsUpdateJetmanSpritePattern			; Update the next animation frame immediately
	
	RET											; END #JsChangeJetmanSpritePattern 

;----------------------------------------------------------;
;            #JsUpdateJetmanSpritePattern                  ;
;----------------------------------------------------------;
; Update sprite pattern for the next animation frame
JsUpdateJetmanSpritePattern	

	; Switch to the next DB record if all bytes from the current one have been used
	LD A, (jsSpriteDBRemain)
	CP 0
	JR NZ, .afterRecordChange					; Jump if there are still bytes to be processed
	
	; Load new record
	LD HL, jsSpriteDB							; HL points to the beginning of the DB
	LD A, (jsSprDBNextID)						; CPIR will keep increasing HL until it finds the record ID from A
	LD BC, 0									; Do not limit CPIR search
	CPIR

	;  Now, HL points to the next byte after the ID of the record, which contains data for the new animation pattern. 	
	LD A, (HL)									; Update next pointer to next animation record
	ADD JS_SDB_SUB								; Add 100 because DB value had  -100, to avoid collision with ID
	LD (jsSprDBNextID), A

	INC HL										; HL points to [SIZE]
	LD A, (HL)									; Update SIZE
	LD (jsSpriteDBRemain), A

	INC HL										; HL points to first sprite data (upper/lower parts)
	LD (jsSpriteDBIdx), HL						; Database offset points to be bytes containing sprite offsets from sprite file

.afterRecordChange

	; 2 bytes will be consumed from current DB record -> upper and lower sprite for Jetman
	LD A, (jsSpriteDBRemain)
	ADD -JS_SDB_FRAME_SIZE
	LD (jsSpriteDBRemain), A

	LD HL, (jsSpriteDBIdx)

	; Update upper sprite
	NEXTREG _SPR_REG_NR_H34, JS_SPR_ID_JET_UP	; Set the ID of the Jetman's sprite for the following commands
	LD A, (HL)
	OR _SPR_PATTERN_SHOW						; Store pattern number into Sprite Attribute	
	NEXTREG _SPR_REG_ATTR_3_H38, A	

	; Update lower sprite
	NEXTREG _SPR_REG_NR_H34, JS_SPR_ID_JET_LW	; Set the ID of the Jetman's sprite for the following commands
	INC HL
	LD A, (HL)
	OR _SPR_PATTERN_SHOW						; Store pattern number into Sprite Attribute
	NEXTREG _SPR_REG_ATTR_3_H38, A	

	; Update pointer to DB
	INC HL
	LD (jsSpriteDBIdx), HL

	RET											; END #JsUpdateJetmanSpritePattern
