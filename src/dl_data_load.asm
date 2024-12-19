;----------------------------------------------------------;
;                Binary Data Loader - Part 2               ;
;----------------------------------------------------------;
	MODULE dl

; ############################
; Load sprites into PFGA

	NEXTREG _MMU_REG_SLOT6_H56, _CF_BIN_SPRITE_BANK1	; Assign bank 40 to slot 6 (see di_data_bin.asm)
	NEXTREG _MMU_REG_SLOT7_H57, _CF_BIN_SPRITE_BANK2	; Assign bank 41 to slot 7

	LD HL, db.spritesBin						; Sprites binary data
	LD BC, db.spritesBinLength					; Copy 63 sprites, each 16x16 pixels
	CALL sp.LoadSpritesFPGA

; ############################
; Load tiles into PFGA

	NEXTREG _MMU_REG_SLOT6_H56, _CF_BIN_TILES_BANK1	; Assign bank 42 to slot 6 (see di_data_bin.asm)
	NEXTREG _MMU_REG_SLOT7_H57, _CF_BIN_TILES_BANK2	; Assign bank 42 to slot 6 (see di_data_bin.asm)
	CALL ti.LoadTiles

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE