;----------------------------------------------------------;
;                      Jetman Weapon                       ;
;----------------------------------------------------------;

; Sprites for single shots, based on "Memmory Structure for Single Sprite" from sr_simple_sprite.asm
;
; Possible values for #SR_MS_STATE
; Bits:
;   - 0: 	Visible flag, 1 = displayed, 0 = hiden  (reserved in sr_simple_sprite.asm)
;   - 1: 	1 = shot moving left, 0 = shot moving left
;   - 2-7: 	Not used

JW_MS_STATE_DIRECTION_BIT		= 1

jwShot
	WORD 0
	DB 0, 0, 10, SR_SDB_FIRE, 0, 0
	WORD 0
jwShot1
	WORD 0
	DB 0, 0, 11, SR_SDB_FIRE, 0, 0
	WORD 0
jwShot2
	WORD 0
	DB 0, 0, 12, SR_SDB_FIRE, 0, 0
	WORD 0
jwShot3
	WORD 0
	DB 0, 0, 13, SR_SDB_FIRE, 0, 0
	WORD 0
jwShot4
	WORD 0
	DB 0, 0, 14, SR_SDB_FIRE, 0, 0
	WORD 0
jwShot5
	WORD 0
	DB 0, 0, 15, SR_SDB_FIRE, 0, 0
	WORD 0				

JW_SHOT_SIZE					= 6				; Amount of shots that can be simultaneously fired

;----------------------------------------------------------;
;                 #JwAnimateSprites                        ;
;----------------------------------------------------------;
JwAnimateSprites
	; Loop ever all jwShot# skipping hidden sprites

	RET											; END #JwAnimateSprites

;----------------------------------------------------------;
;                        #JwFire                           ;
;----------------------------------------------------------;
JwFire
	; Find the first inactive (sprite hidden) shot
	LD IX, jwShot
	LD DE, SR_MS_SIZE
	LD B, JW_SHOT_SIZE 
.findLoop

	; Check whether the current #jwShotX is not visible and can be reused
	LD A, (IX + SR_MS_STATE)
	AND SR_MS_STATE_VISIBLE						; Reset all bits but visiblity
	CP 0
	JR Z, .afterFound							; Jump if visibility is not set -> hidden, can be reused

	; Move HL to the beginning of the next #jwShotX (see "LD DE, SR_MS_SIZE" above)
	ADD IX, DE
	DJNZ .findLoop								; Jump if B > 0 (starts with #SR_MS_SIZE - 1)
	RET											; Loop has ended without finding free #jwShotX

.afterFound										
	; We are here because free #jwShotX has been found, and IX points to it


	; Setup laser beam pattern, IX already points to the right memmory address
	LD A, SR_SDB_FIRE
	CALL SrSetSpritePattern
	
	; Set X coordinate for laser beam
	LD BC, (jtX)
	LD (IX + SR_MS_X), BC

	; Set Y coordinate for laser beam
	LD A, (jtY)
	LD (IX + SR_MS_Y), A

	; Set sprite flag
	LD A, SR_MS_STATE_VISIBLE
	SET JW_MS_STATE_DIRECTION_BIT, A
	LD (IX + SR_MS_STATE), A

	LD B, 30
	//LD H, 0
//	LD A, (IX + SR_MS_STATE)
//	LD L, A
	LD HL, IX
	CALL TxPrintNumHL	

	RET											; END #JoPressFire