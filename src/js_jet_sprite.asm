;----------------------------------------------------------;
;                      Jetman Sprite                       ;
;----------------------------------------------------------;
	MODULE js

SPR_ID_JET_UP			= 0						; ID of Jetman upper sprite
SPR_ID_JET_LW			= 1						; ID of Jetman lower sprite

; IDs for #spriteDB
SDB_FLY					= 201					; Jetman is flaying
SDB_WALK				= 202					; Jetman is walking
SDB_WALK_ST				= 203					; Jetman starts walking with raised feet to avoid moving over the ground and standing still.
SDB_HOVER				= 204					; Jetman hovers
SDB_STAND				= 205					; Jetman stands in place
SDB_JSTAND				= 206					; Jetman quickly stops walking
SDB_RIP					= 207					; Jetman got hit

SDB_T_WF				= 220					; Transition: walking -> flaying
SDB_T_FS				= 221					; Transition: flaying -> standing
SDB_T_FW				= 222					; Transition: flaying -> walking
SDB_T_WL				= 223					; Transition: walking -> falling

SDB_SUB				= 100						; 100 for OFF_NX that CPIR finds ID and not OFF_NX (see record docu below, look for: OFF_NX)
SDB_FRAME_SIZE		= 2

; The animation system is based on a state machine. Its database is divided into records, each containing a list of frames to be played and 
; a reference to the next record that will be played once all frames from the current record have been executed.
; DB Record:
;    [ID], [OFF_NX], [SIZE], [[FRAME_UP,FRAME_LW], [FRAME_UP,FRAME_LW],...,[FRAME_UP,FRAME_LW]] 
; where:
;	- ID: 			Entry ID for lookup via CPIR
;	- SIZE:			Amount of bytes in this record
;	- FRAME_UP:		Offset for the upper part of the Jetman
;	- FRAME_LW: 	Offset for the lower part of the Jetman
;	- OFF_NX:		ID of the following animation DB record. We subtract from this ID the 100 so that CPIR does not find OFF_NX but ID

spriteDB
	; Jetman is flaying
	DB SDB_FLY,		SDB_FLY - SDB_SUB,		48
											DB 00,12, 00,13, 01,14, 01,15, 02,16, 02,17, 03,12, 03,13, 04,14, 04,15
											DB 05,16, 05,17, 03,12, 03,13, 04,14, 04,15, 05,16, 05,17, 03,12, 03,13
											DB 04,14, 04,15, 05,16, 05,17

	; Jetman hovers
	DB SDB_HOVER,	SDB_HOVER - SDB_SUB,	48 
											DB 00,18, 00,19, 01,20, 01,21, 02,16, 02,17, 03,12, 03,13, 04,14, 04,15 
											DB 05,16, 05,17, 03,12, 03,13, 04,14, 04,15, 05,16, 05,17, 03,12, 03,13
											DB 04,14, 04,15, 05,16, 05,17

	; Jetman starts walking with raised feet to avoid moving over the ground and standing still.
	DB SDB_WALK_ST,	SDB_WALK	- SDB_SUB,	02, 03,07

	; Jetman is walking
	DB SDB_WALK, 	SDB_WALK - SDB_SUB,		48
											DB 03,06, 03,07, 04,08, 04,09, 05,06, 05,06, 03,08, 03,09, 04,06, 04,07
											DB 05,08, 05,09, 00,06, 00,07, 01,08, 01,09, 02,06, 02,07, 03,08, 03,09 
											DB 04,06, 04,07, 05,08, 05,09

	; Jetman stands in place
	DB SDB_STAND,	SDB_STAND - SDB_SUB,	46 
											DB 03,34, 03,35, 04,36, 04,37, 05,34, 05,35, 03,36, 03,37, 04,34, 04,35
											DB 05,36, 05,37, 00,34, 00,35, 01,36, 01,37, 02,34, 02,35, 03,36, 03,37
											DB 04,34, 05,35, 05,36

	; Jetman stands on the ground for a very short time
	DB SDB_JSTAND,	SDB_STAND - SDB_SUB, 	02, 03,36

	; Jetman got hit
	DB SDB_RIP,		SDB_RIP - SDB_SUB,		16, 00,08, 01,09, 02,10, 03,11, 00,22, 01,23, 02,24, 03,25

	; Transition: walking -> flaying
	DB SDB_T_WF,	SDB_FLY - SDB_SUB, 		08, 03,22, 04,23, 05,24, 03,25

	; Transition: flaying -> standing
	DB SDB_T_FS, 	SDB_STAND - SDB_SUB,	4, 03,26, 04,27, 05,28, 03,29

	; Transition: flaying -> walking
	DB SDB_T_FW, 	SDB_WALK - SDB_SUB,		4, 03,26, 04,27, 05,28, 03,29

	; Transition: walking -> falling
	DB SDB_T_WL,	SDB_FLY - SDB_SUB, 		08, 03,30, 04,31, 05,32, 03,33

sprDBIdx			WORD 0						; Current position in DB
sprDBRemain			BYTE 0						; Amount of bytes that have to be still processed from the current record
sprDBNextID			BYTE SDB_FLY				; ID in #spriteDB for next animation/DB record

SPR_STATE_HIDE		= 0
SPR_STATE_SHOW		= 1
sprState			BYTE SPR_STATE_SHOW

;----------------------------------------------------------;
;          #UpdateJetSpritePositionRotation                ;
;----------------------------------------------------------;
UpdateJetSpritePositionRotation	
	; Move Jetman Sprite to the current X position, the 9-bit value requires two writes (8 bit from C + 1 bit from B)
	LD BC, (jo.jetX)

	; Set _SPR_REG_NR_H34 with LDB from Jetmans X postion
	LD A, C			
	NEXTREG _SPR_REG_NR_H34, SPR_ID_JET_UP		; Set the ID of the Jetman's sprite for the following commands
	NEXTREG _SPR_REG_X_H35, A					; Set LSB from BC (X)

	NEXTREG _SPR_REG_NR_H34, SPR_ID_JET_LW		; Set the ID of the Jetman's sprite for the following commands
	NEXTREG _SPR_REG_X_H35, A					; Set LSB from BC (X)

	; Set _SPR_REG_ATR2_H37 containing overflow bit from X position, rotation and mirror
	LD A, (id.jetDirection)
	LD D, A
	LD A, 0										; Clear A to set only rotation/mirror bits
	BIT id.MOVE_LEFT_BIT, D						; Moving left bit set?
	JR Z, .rotateRight
	SET _SPR_REG_ATR2_MIRX_BIT, A				; Rotate sprite left
	JR .afterRotate	
.rotateRight	
	RES _SPR_REG_ATR2_MIRX_BIT, A				; Rotate sprite right
.afterRotate
	LD E, A										; Backup A

	LD A, B										; Load MSB from X into A
	AND %00000001								; Keep only an overflow bit
	OR E										; Apply rotation from A (E now)

	NEXTREG _SPR_REG_NR_H34, SPR_ID_JET_UP		; Set the ID of the Jetman's sprite for the following commands
	NEXTREG _SPR_REG_ATR2_H37, A

	NEXTREG _SPR_REG_NR_H34, SPR_ID_JET_LW		; Set the ID of the Jetman's sprite for the following commands
	NEXTREG _SPR_REG_ATR2_H37, A

	; Move Jetman sprite to current Y postion, 8-bit value is easy 
	LD A, (jo.jetY)		
	
	NEXTREG _SPR_REG_NR_H34, SPR_ID_JET_UP		; Set the ID of the Jetman's sprite for the following commands
	NEXTREG _SPR_REG_Y_H36, A					; Set Y position

	NEXTREG _SPR_REG_NR_H34, SPR_ID_JET_LW		; Set the ID of the Jetman's sprite for the following commands
	ADD 16										; Lower part is 16px below upper
	NEXTREG _SPR_REG_Y_H36, A					; Set Y position

	RET
	
;----------------------------------------------------------;
;                 #ChangeJetSpritePattern                  ;
;----------------------------------------------------------;
; Input:
;   - A: ID for #jesSprites, to siwtch to the next animation record
ChangeJetSpritePattern

	LD (sprDBNextID), A							; Next animation record

	LD A, 0
	LD (sprDBRemain), A						; No more bytes to process within the current DB record will cause the fast switch to the next.

	CALL UpdateJetSpritePattern				    ; Update the next animation frame immediately
	
	RET

;----------------------------------------------------------;
;               #UpdateJetSpritePattern                    ;
;----------------------------------------------------------;
; Update sprite pattern for the next animation frame
UpdateJetSpritePattern	
	
	; Switch to the next DB record if all bytes from the current one have been used
	LD A, (sprDBRemain)
	CP 0
	JR NZ, .afterRecordChange					; Jump if there are still bytes to be processed
	
	; Load new record
	LD HL, spriteDB								; HL points to the beginning of the DB
	LD A, (sprDBNextID)							; CPIR will keep increasing HL until it finds the record ID from A
	LD BC, 0									; Do not limit CPIR search
	CPIR

	; Now we are at the correct DB position containing the following sprite pattern and will load it into the registry
	LD A, (HL)									; Update next pointer to next animation record
	ADD SDB_SUB									; Add 100 because DB value had  -100, to avoid collision with ID
	LD (sprDBNextID), A

	INC HL										; HL points to [SIZE]
	LD A, (HL)									; Update SIZE
	LD (sprDBRemain), A

	INC HL										; HL points to first sprite data (upper/lower parts)
	LD (sprDBIdx), HL							; Database offset points to be bytes containing sprite offsets from sprite file

.afterRecordChange

	; 2 bytes will be consumed from current DB record -> upper and lower sprite for Jetman
	LD A, (sprDBRemain)
	ADD -SDB_FRAME_SIZE
	LD (sprDBRemain), A

	; Now we are at correct DB position containing next sprite pattern and will load it into registry
	LD HL, (sprDBIdx)

	; Store in B _SPR_PATTERN_SHOW/_HIDE depending on the #sprState 
	LD A, (sprState)
	CP SPR_STATE_HIDE
	JR Z, .hide
	LD B, _SPR_PATTERN_SHOW						; Sprite is visible
	JR .afterShow
.hide
	LD B, _SPR_PATTERN_HIDE						; Sprite is hidden
.afterShow	

	; Update upper sprite
	NEXTREG _SPR_REG_NR_H34, SPR_ID_JET_UP		; Set the ID of the Jetman's sprite for the following commands
	LD A, (HL)									; Store pattern number into sprite attribute	
	OR B										; Store visibility sprite attribute
	NEXTREG _SPR_REG_ATR3_H38, A	

	; Update lower sprite
	NEXTREG _SPR_REG_NR_H34, SPR_ID_JET_LW		; Set the ID of the Jetman's sprite for the following commands
	INC HL
	LD A, (HL)									; Store pattern number into sprite attribute	
	OR B										; Store visibility sprite attribute
	NEXTREG _SPR_REG_ATR3_H38, A	

	; Update pointer to DB
	INC HL
	LD (sprDBIdx), HL

	RET

;----------------------------------------------------------;
;                    #BlinkJetSprite                       ;
;----------------------------------------------------------;
; Input:
; - A:	Flip Flop counter, ie: #counter2FliFLop
BlinkJetSprite	
	CP cd.FLIP_ON
	JR NZ, .flipOff
	
	; Show sprite
	CALL HideJetSprite
	RET
.flipOff
	; Hide sprite
	CALL ShowJetSprite
	RET

;----------------------------------------------------------;
;                     #ShowJetSprite                       ;
;----------------------------------------------------------;
ShowJetSprite
	LD A, SPR_STATE_SHOW
	LD (sprState), A

	LD B, _SPR_PATTERN_SHOW
	CALL ShowOrHideJetSprite

	RET

;----------------------------------------------------------;
;                     #HideJetSprite                       ;
;----------------------------------------------------------;
HideJetSprite
	LD A, SPR_STATE_HIDE
	LD (sprState), A

	LD B, _SPR_PATTERN_HIDE
	CALL ShowOrHideJetSprite

	RET	

;----------------------------------------------------------;
;                 #ShowOrHideJetSprite                     ;
;----------------------------------------------------------;
; Input:
;  - B: _SPR_PATTERN_SHOW or _SPR_PATTERN_HIDE
ShowOrHideJetSprite
	LD HL, (sprDBIdx)							; Load current sprite pattern
	ADD HL, -SDB_FRAME_SIZE						; Every update sprite pattern moves db pointer to the next record, but blinking has to show current record

	; Update upper sprite
	NEXTREG _SPR_REG_NR_H34, SPR_ID_JET_UP		; Set the ID of the Jetman's sprite for the following commands
	LD A, (HL)
	OR B										; Store pattern number into Sprite Attribute	
	NEXTREG _SPR_REG_ATR3_H38, A	

	; Update lower sprite
	NEXTREG _SPR_REG_NR_H34, SPR_ID_JET_LW		; Set the ID of the Jetman's sprite for the following commands
	INC HL
	LD A, (HL)
	OR B										; Store pattern number into Sprite Attribute
	NEXTREG _SPR_REG_ATR3_H38, A	

	RET

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE
