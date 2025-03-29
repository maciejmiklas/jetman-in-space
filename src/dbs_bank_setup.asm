;----------------------------------------------------------;
;                      Bank Setup                          ;
;----------------------------------------------------------;
	MODULE dbs

;----------------------------------------------------------;
;                    #SetupTilesBank                       ;
;----------------------------------------------------------;
SetupTilesBank

	NEXTREG _MMU_REG_SLOT7_H57, _DB_TI_SPR_BANK_D42	; Assign bank 43 to slot 7.

	RET											; ## END of the function ##	

;----------------------------------------------------------;
;               #SetupRocketStarsBank                      ;
;----------------------------------------------------------;
SetupRocketStarsBank

	NEXTREG _MMU_REG_SLOT6_H56, _DB_RO_STAR_BANK1_D43 ; Assign bank 44 to slot 6 (see di_data_bin.asm).
	NEXTREG _MMU_REG_SLOT7_H57, _DB_RO_STAR_BANK2_D44 ; Assign bank 45 to slot 7.

	RET											; ## END of the function ##
	
;----------------------------------------------------------;
;                  #SetupSpritesBank                       ;
;----------------------------------------------------------;
SetupSpritesBank

	NEXTREG _MMU_REG_SLOT6_H56, _DB_SPRITE_BANK1_D40	; Assign bank 40 to slot 6 (see di_data_bin.asm).
	NEXTREG _MMU_REG_SLOT7_H57, _DB_SPRITE_BANK2_D41	; Assign bank 41 to slot 7.

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                    #SetupStarsBank                       ;
;----------------------------------------------------------;
SetupStarsBank

	NEXTREG _MMU_REG_SLOT7_H57, _DB_ST_BANK_D57

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                   #SetupArraysBank                       ;
;----------------------------------------------------------;
SetupArraysBank

	NEXTREG _MMU_REG_SLOT7_H57, _DB_ARR_BANK_D58

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                   #SetupPaletteBank                      ;
;----------------------------------------------------------;
SetupPaletteBank

	; Memory bank (8KiB) containing layer 2 palette data.
	NEXTREG _MMU_REG_SLOT6_H56, _DB_PAL2_BANK_D45

	; Memory bank (8KiB) containing layer 2 palette with brightness.
	NEXTREG _MMU_REG_SLOT7_H57, _DB_PAL2_BR_BANK_D46	
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE
