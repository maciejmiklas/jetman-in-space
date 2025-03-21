;----------------------------------------------------------;
;                Binary Data Loader - Part 2               ;
;----------------------------------------------------------;
	MODULE dl

; ############################
; Load sprites into PFGA

	NEXTREG _MMU_REG_SLOT6_H56, _BN_SPRITE_BANK1_D40	; Assign bank 40 to slot 6 (see di_data_bin.asm).
	NEXTREG _MMU_REG_SLOT7_H57, _BN_SPRITE_BANK2_D41	; Assign bank 41 to slot 7.

	LD HL, db.spritesBin						; Sprites binary data.
	LD BC, db.spritesBinLength					; Copy 63 sprites, each 16x16 pixels.
	CALL sp.LoadSpritesFPGA

; ############################
; Load tiles into PFGA

	NEXTREG _MMU_REG_SLOT6_H56, _BN_TILES_BANK1_D42	; Assign bank 42 to slot 6 (see di_data_bin.asm).
	NEXTREG _MMU_REG_SLOT7_H57, _BN_TILES_BANK2_D43	; Assign bank 43 to slot 7 (see di_data_bin.asm).
	CALL ti.LoadTiles

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE