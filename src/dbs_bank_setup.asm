;----------------------------------------------------------;
;                     Bitmap Palette                       ;
;----------------------------------------------------------;
	MODULE dbs

;----------------------------------------------------------;
;                 #SetupStarsDataBank                      ;
;----------------------------------------------------------;
SetupStarsDataBank

	NEXTREG _MMU_REG_SLOT7_H57, _DB_ST_BANK_D57

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                 #SetupArraysDataBank                     ;
;----------------------------------------------------------;
SetupArraysDataBank

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
