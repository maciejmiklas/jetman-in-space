;----------------------------------------------------------;
;                 Load Sprites into PFGA                   ;
;----------------------------------------------------------;
SPR_FILE_BYTES			EQU 16*16*63	

; Sprites for Level 1 are stored in Bank 40, 41 (SPR_SLOT1/2)
	NEXTREG MMU_REG_SLOT_6_H56, SPR_SLOT1		; Assign bank 40 to slot 6
	NEXTREG MMU_REG_SLOT_7_H57, SPR_SLOT2		; Assign bank 41 to slot 7

	LD HL, spritesFile							; Sprites binary data							
	LD BC, SPR_FILE_BYTES						; Copy 63 sprites, each 16x16 pixels
	CALL LoadSpritesFPGA	