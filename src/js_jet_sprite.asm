;----------------------------------------------------------;
;                      Jetman Sprite                       ;
;----------------------------------------------------------;
	MODULE js

SPR_ID_JET_UP			= 0						; ID of Jetman upper sprite.
SPR_ID_JET_LW			= 1						; ID of Jetman lower sprite.

; IDs for #spriteDB.
SDB_FLY					= 201					; Jetman is flaying.
SDB_FLYD				= 202					; Jetman is flaying down.
SDB_WALK				= 203					; Jetman is walking.
SDB_WALK_ST				= 204					; Jetman starts walking with raised feet to avoid moving over the ground and standing still.
SDB_HOVER				= 205					; Jetman hovers.
SDB_STAND				= 206					; Jetman stands in place.
SDB_JSTAND				= 207					; Jetman quickly stops walking.
SDB_RIP					= 208					; Jetman got hit.

SDB_T_WF				= 220					; Transition: walking -> flaying.
SDB_T_FS				= 221					; Transition: flaying -> standing.
SDB_T_FW				= 222					; Transition: flaying -> walking.
SDB_T_KF				= 223					; Transition: kinking -> flying.

SDB_SUB					= 100					; 100 for OFF_NX that CPIR finds ID and not OFF_NX (see record docu below, look for: OFF_NX).
SDB_FRAME_SIZE			= 2

; The animation system is based on a state machine. Its database is divided into records, each containing a list of frames to be played and 
; a reference to the next record that will be played once all frames from the current record have been executed.
; DB Record:
;    [ID], [OFF_NX], [SIZE], [DELAY], [[FRAME_UP,FRAME_LW], [FRAME_UP,FRAME_LW],...,[FRAME_UP,FRAME_LW]] 
; where:
;	- ID: 			Entry ID for lookup via CPIR.
;	- OFF_NX:		ID of the following animation DB record. We subtract from this ID the 100 so that CPIR does not find OFF_NX but ID.
;	- SIZE:			Amount of bytes in this record.
;	- DELAY:		Amount animation calls to skip (slows down animation).
;	- FRAME_UP:		Offset for the upper part of the Jetman.
;	- FRAME_LW: 	Offset for the lower part of the Jetman.
spriteDB
	; Jetman is flaying.
	DB SDB_FLY,		SDB_FLY - SDB_SUB,		48, 5
											DB 00,10, 00,11, 01,12, 01,13, 02,11, 02,12, 03,10, 03,11, 04,12, 04,13
											DB 05,12, 05,11, 03,10, 03,11, 04,12, 04,13, 05,10, 05,12, 03,10, 03,11
											DB 04,12, 04,13, 05,12, 05,10

	; Jetman is flaying down.
	DB SDB_FLYD, SDB_FLYD - SDB_SUB,		48, 5
											DB 00,12, 00,37, 01,38, 01,37, 02,12, 02,38, 03,12, 03,37, 04,38, 04,12
											DB 05,38, 05,37, 03,37, 03,12, 04,38, 04,12, 05,37, 05,38, 03,37, 03,12
											DB 04,12, 04,37, 05,38, 05,37											

	; Jetman hovers.
	DB SDB_HOVER,	SDB_HOVER - SDB_SUB,	48, 10
											DB 00,14, 00,15, 01,16, 01,10, 02,11, 02,12, 03,13, 03,10, 04,11, 04,12 
											DB 05,13, 05,14, 03,15, 03,16, 04,10, 04,11, 05,12, 05,13, 03,10, 03,11
											DB 04,12, 04,13, 05,10, 05,11

	; Jetman starts walking with raised feet to avoid moving over the ground and standing still.
	DB SDB_WALK_ST,	SDB_WALK	- SDB_SUB,	02, 3
											DB 03,07

	; Jetman is walking.
	DB SDB_WALK, 	SDB_WALK - SDB_SUB,		48, 3
											DB 03,06, 03,07, 04,08, 04,09, 05,06, 05,06, 03,08, 03,09, 04,06, 04,07
											DB 05,08, 05,09, 00,06, 00,07, 01,08, 01,09, 02,06, 02,07, 03,08, 03,09 
											DB 04,06, 04,07, 05,08, 05,09

	; Jetman stands in place.
	DB SDB_STAND,	SDB_STAND - SDB_SUB,	46, 5
											DB 03,17, 03,18, 04,19, 04,18, 05,17, 05,19, 03,17, 03,18, 04,19, 04,17
											DB 05,19, 05,18, 00,19, 00,18, 01,17, 01,18, 02,17, 02,19, 03,18, 03,18
											DB 04,19, 05,17, 05,18

	; Jetman stands on the ground for a very short time.
	DB SDB_JSTAND,	SDB_STAND - SDB_SUB, 	02, 3
											DB 03,11

	; Jetman got hit.
	DB SDB_RIP,		SDB_RIP - SDB_SUB,		08, 5 
											DB 00,27, 01,28, 02,15, 03,29

	; Transition: walking -> flaying.
	DB SDB_T_WF,	SDB_FLY - SDB_SUB, 		08, 5
											DB 03,26, 04,25, 05,24, 03,23

	; Transition: flaying -> standing.
	DB SDB_T_FS, 	SDB_STAND - SDB_SUB,	08, 5
											DB 03,23, 04,24, 05,25, 03,26

	; Transition: flaying -> walking.
	DB SDB_T_FW, 	SDB_WALK - SDB_SUB,		08, 5
											DB 03,23, 04,24, 05,25, 03,26

	; Transition: kinking -> flying.
	DB SDB_T_KF,	SDB_FLY - SDB_SUB, 		10, 5
											DB 03,15, 04,16, 05,27, 03,28, 04,29

sprDBIdx			WORD 0						; Current position in DB.
sprDBRemain			BYTE 0						; Amount of bytes that have to be still processed from the current record.
sprDBCurrentID		BYTE SDB_FLY				; Acrtive animation.
sprDBNextID			BYTE SDB_FLY				; ID in #spriteDB for next animation/DB record.
sprDBDelay			BYTE 0						; Value from #DELAY.
sprDBDelayCnt		BYTE 0						; Counter from #sprDBDelay to 0.

SPR_STATE_HIDE		= 0
SPR_STATE_SHOW		= 1
sprState			BYTE SPR_STATE_SHOW

;----------------------------------------------------------;
;             #UpdateJetSpritePositionRotation             ;
;----------------------------------------------------------;
UpdateJetSpritePositionRotation

	; Move Jetman Sprite to the current X position, the 9-bit value requires two writes (8 bit from C + 1 bit from B).
	LD BC, (jpo.jetX)

	; Set _SPR_REG_NR_H34 with LDB from Jetmans X postion.
	LD A, C			
	NEXTREG _SPR_REG_NR_H34, SPR_ID_JET_UP		; Set the ID of the Jetman's sprite for the following commands.
	NEXTREG _SPR_REG_X_H35, A					; Set LSB from BC (X).

	NEXTREG _SPR_REG_NR_H34, SPR_ID_JET_LW		; Set the ID of the Jetman's sprite for the following commands.
	NEXTREG _SPR_REG_X_H35, A					; Set LSB from BC (X).

	; Set _SPR_REG_ATR2_H37 containing overflow bit from X position, rotation and mirror.
	LD A, (ind.jetDirection)
	LD D, A
	XOR A										; Clear A to set only rotation/mirror bits.
	BIT ind.MOVE_LEFT_BIT, D						; Moving left bit set?
	JR Z, .rotateRight
	SET _SPR_REG_ATR2_MIRX_BIT, A				; Rotate sprite left.
	JR .afterRotate	
.rotateRight	
	RES _SPR_REG_ATR2_MIRX_BIT, A				; Rotate sprite right.
.afterRotate
	LD E, A										; Backup A.

	LD A, B										; Load MSB from X into A.
	AND %00000001								; Keep only an overflow bit.
	OR E										; Apply rotation from A (E now).

	NEXTREG _SPR_REG_NR_H34, SPR_ID_JET_UP		; Set the ID of the Jetman's sprite for the following commands.
	NEXTREG _SPR_REG_ATR2_H37, A

	NEXTREG _SPR_REG_NR_H34, SPR_ID_JET_LW		; Set the ID of the Jetman's sprite for the following commands.
	NEXTREG _SPR_REG_ATR2_H37, A

	; Move Jetman sprite to current Y postion, 8-bit value is easy.
	LD A, (jpo.jetY)		
	
	NEXTREG _SPR_REG_NR_H34, SPR_ID_JET_UP		; Set the ID of the Jetman's sprite for the following commands.
	NEXTREG _SPR_REG_Y_H36, A					; Set Y position.

	NEXTREG _SPR_REG_NR_H34, SPR_ID_JET_LW		; Set the ID of the Jetman's sprite for the following commands.
	ADD 16										; Lower part is 16px below upper.
	NEXTREG _SPR_REG_Y_H36, A					; Set Y position.

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                #ChangeJetSpritePattern                   ;
;----------------------------------------------------------;
; Switches immediately to the given animation, breaking the currently running one.
; Input:
;   - A: ID for #jesSprites, to siwtch to the next animation record.
ChangeJetSpritePattern

	; Do not change the animation if the same animation is already playing, it will restart it.
	LD B, A
	LD A, (sprDBCurrentID)
	CP B
	RET Z

	LD A, B										; Restore method param.

	LD (sprDBNextID), A							; Next animation record.
	LD (sprDBCurrentID), A

	XOR A										; Set A to 0.
	LD (sprDBRemain), A							; No more bytes to process within the current DB record will cause the fast switch to the next.

	CALL AnimateJetSprite						; Update the next animation frame immediately.

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #AnimateJetSprite                       ;
;----------------------------------------------------------;
; Update sprite pattern for the next animation frame.
AnimateJetSprite

	; Delay animation.
	LD A, (sprDBDelay)
	CP 0
	JR Z, .afterAnimationDelay					; Jump if delay is off
	
	; Animation delay is on. Check if counter has reached 0 and needs to be reset.
	LD A, (sprDBDelayCnt)
	CP 0
	JR NZ, .decResetDelay
	
	; Delay counter is 0, reset it.
	LD A, (sprDBDelay)
	LD (sprDBDelayCnt), A
	JR .afterAnimationDelay
.decResetDelay
	DEC A
	LD (sprDBDelayCnt), A

	RET 
.afterAnimationDelay	
	; ##########################################
	; Switch to the next DB record if all bytes from the current one have been used.
	LD A, (sprDBRemain)
	CP 0
	JR NZ, .afterRecordChange					; Jump if there are still bytes to be processed.
	
	; Load new record.
	LD HL, spriteDB								; HL points to the beginning of the DB.
	LD A, (sprDBNextID)							; CPIR will keep increasing HL until it finds the record ID from A.
	LD (sprDBCurrentID), A						; Store current animation.
	LD BC, 0									; Do not limit CPIR search.
	CPIR

	; Now we are at the correct DB position containing the following sprite pattern and will load it into the registry.
	LD A, (HL)									; Update next pointer to next animation record.
	ADD SDB_SUB									; Add 100 because DB value had  -100, to avoid collision with ID.
	LD (sprDBNextID), A	

	INC HL										; HL points to [SIZE].
	LD A, (HL)									; Update SIZE.
	LD (sprDBRemain), A

	INC HL										; HL points to [DELAY].
	LD A, (HL)
	LD (sprDBDelay), A
	LD (sprDBDelayCnt), A

	INC HL										; HL points to first sprite data (upper/lower parts).
	LD (sprDBIdx), HL							; Database offset points to be bytes containing sprite offsets from sprite file.
.afterRecordChange

	; 2 bytes will be consumed from current DB record -> upper and lower sprite for Jetman.
	LD A, (sprDBRemain)
	ADD -SDB_FRAME_SIZE
	LD (sprDBRemain), A

	; Now we are at correct DB position containing next sprite pattern and will load it into registry.
	LD HL, (sprDBIdx)

	; Store in B _SPR_PATTERN_SHOW/_HIDE depending on the #sprState.
	LD A, (sprState)
	CP SPR_STATE_HIDE
	JR Z, .hide
	LD B, _SPR_PATTERN_SHOW						; Sprite is visible.
	JR .afterShow
.hide
	LD B, _SPR_PATTERN_HIDE						; Sprite is hidden.
.afterShow	

	; Update upper sprite.
	NEXTREG _SPR_REG_NR_H34, SPR_ID_JET_UP		; Set the ID of the Jetman's sprite for the following commands.
	LD A, (HL)									; Store pattern number into sprite attribute.
	OR B										; Store visibility sprite attribute.
	NEXTREG _SPR_REG_ATR3_H38, A	

	; Update lower sprite.
	NEXTREG _SPR_REG_NR_H34, SPR_ID_JET_LW		; Set the ID of the Jetman's sprite for the following commands.
	INC HL
	LD A, (HL)									; Store pattern number into sprite attribute.
	OR B										; Store visibility sprite attribute.
	NEXTREG _SPR_REG_ATR3_H38, A	

	; Update pointer to DB.
	INC HL
	LD (sprDBIdx), HL

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                    #BlinkJetSprite                       ;
;----------------------------------------------------------;
; Input:
; - A:	Flip Flop counter, ie: #counter002FliFLop.
BlinkJetSprite

	CP _GC_FLIP_ON_D1
	JR NZ, .flipOff
	
	; Show sprite
	CALL HideJetSprite
	RET
.flipOff
	; Hide sprite
	CALL ShowJetSprite

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                     #ShowJetSprite                       ;
;----------------------------------------------------------;
ShowJetSprite

	; Return if Jetman is inactive.
	LD A, (jt.jetState)
	CP jt.STATE_INACTIVE
	RET Z

	LD A, SPR_STATE_SHOW
	LD (sprState), A

	LD B, _SPR_PATTERN_SHOW
	CALL _ShowOrHideJetSprite

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                     #HideJetSprite                       ;
;----------------------------------------------------------;
HideJetSprite

	LD A, SPR_STATE_HIDE
	LD (sprState), A

	LD B, _SPR_PATTERN_HIDE
	CALL _ShowOrHideJetSprite

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                #ChangeJetSpriteOnFlyDown                 ;
;----------------------------------------------------------;
ChangeJetSpriteOnFlyDown

	; Change animation only if Jetman is flying.
	LD A, (jt.jetAir)
	CP jt.AIR_FLY
	RET NZ

	; Switch to flaying down animation.
	LD A, SDB_FLYD
	CALL ChangeJetSpritePattern

	RET											; ## END of the function ##


;----------------------------------------------------------;
;               #ChangeJetSpriteOnFlyUp                    ;
;----------------------------------------------------------;
ChangeJetSpriteOnFlyUp

	; Change animation only if Jetman is flying.
	LD A, (jt.jetAir)
	CP jt.AIR_FLY
	RET NZ

	; Switch to flaying animation.
	LD A, SDB_FLY
	CALL ChangeJetSpritePattern
	RET											; ## END of the function ##	

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                 #_ShowOrHideJetSprite                    ;
;----------------------------------------------------------;
; Input:
;  - B: _SPR_PATTERN_SHOW or _SPR_PATTERN_HIDE.
_ShowOrHideJetSprite

	LD HL, (sprDBIdx)							; Load current sprite pattern.
	ADD HL, -SDB_FRAME_SIZE						; Every update sprite pattern moves db pointer to the next record, but blinking has to show current record.

	; Update upper sprite
	NEXTREG _SPR_REG_NR_H34, SPR_ID_JET_UP		; Set the ID of the Jetman's sprite for the following commands.
	LD A, (HL)
	OR B										; Store pattern number into Sprite Attribute.
	NEXTREG _SPR_REG_ATR3_H38, A	

	; Update lower sprite
	NEXTREG _SPR_REG_NR_H34, SPR_ID_JET_LW		; Set the ID of the Jetman's sprite for the following commands.
	INC HL
	LD A, (HL)
	OR B										; Store pattern number into Sprite Attribute.
	NEXTREG _SPR_REG_ATR3_H38, A	

	RET											; ## END of the function ##
;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE
