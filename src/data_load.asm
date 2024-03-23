;----------------------------------------------------------;
;                 Load Sprites into PFGA                   ;
;----------------------------------------------------------;
; Sprites for Level 1 are stored in Bank 40, 41 (SPR_BANK1_40/2_41)
	NEXTREG MMU_REG_SLOT_6_H56, SPR_BANK1_40		; Assign bank 40 to slot 6
	NEXTREG MMU_REG_SLOT_7_H57, SPR_BANK2_41		; Assign bank 41 to slot 7

	LD HL, spritesBin								; Sprites binary data							
	LD BC, spritesBinLength							; Copy 63 sprites, each 16x16 pixels
	CALL LoadSpritesFPGA

		