;----------------------------------------------------------;
;                Binary Data Loader - Part 2               ;
;----------------------------------------------------------;
	MODULE dl

;----------------------------------------------------------;
;                 Load sprites into PFGA                   ;
;----------------------------------------------------------;
; Sprites for Level 1 are stored in Bank 40, 41 (SPRITE_B40)
	NEXTREG _MMU_REG_SLOT6_H56, $$di.spritesBin	; Assign bank 40 to slot 6
	NEXTREG _MMU_REG_SLOT7_H57, $$di.spritesBin+1; Assign bank 41 to slot 7

	LD HL, di.spritesBin						; Sprites binary data
	LD BC, di.spritesBinLength					; Copy 63 sprites, each 16x16 pixels
	CALL sp.LoadSpritesFPGA

;----------------------------------------------------------;
;                  Load tiles into PFGA                    ;
;----------------------------------------------------------;
	NEXTREG _MMU_REG_SLOT6_H56, $$di.tilemapBin	; Assign bank 42 to slot 6
	CALL ti.LoadTiles

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE