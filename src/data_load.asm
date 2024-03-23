;----------------------------------------------------------;
;                 Load sprites into PFGA                   ;
;----------------------------------------------------------;
; Sprites for Level 1 are stored in Bank 40, 41 (BANK40_SPR1/2_41)
	NEXTREG MMU_REG_SLOT_6_H56, BANK40_SPR1		; Assign bank 40 to slot 6
	NEXTREG MMU_REG_SLOT_7_H57, BANK41_SPR2		; Assign bank 41 to slot 7

	LD HL, spritesBin							; Sprites binary data							
	LD BC, spritesBinLength						; Copy 63 sprites, each 16x16 pixels
	CALL LoadSpritesFPGA

;----------------------------------------------------------;
;                  Load tiles into PFGA                    ;
;----------------------------------------------------------;
	NEXTREG MMU_REG_SLOT_6_H56, BANK42_PALETTE	; Assign bank 42 to slot 6
	CALL LoadTiles	