;----------------------------------------------------------;
;                Binary Data Loader - Part 2               ;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                 Load sprites into PFGA                   ;
;----------------------------------------------------------;
; Sprites for Level 1 are stored in Bank 40, 41 (DI_BANK40_SPR1/2_41)
	NEXTREG _MMU_REG_SLOT6_H56, DI_BANK40_SPR1	; Assign bank 40 to slot 6
	NEXTREG _MMU_REG_SLOT7_H57, DI_BANK41_SPR2	; Assign bank 41 to slot 7

	LD HL, diSpritesBin							; Sprites binary data							
	LD BC, diSpritesBinLength					; Copy 63 sprites, each 16x16 pixels
	CALL SpLoadSpritesFPGA

;----------------------------------------------------------;
;                  Load tiles into PFGA                    ;
;----------------------------------------------------------;
	NEXTREG _MMU_REG_SLOT6_H56, DI_BANK42_PALETTE	; Assign bank 42 to slot 6
	CALL TiLoadTiles	