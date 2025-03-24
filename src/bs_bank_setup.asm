;----------------------------------------------------------;
;                     Bitmap Palette                       ;
;----------------------------------------------------------;
	MODULE bs

;----------------------------------------------------------;
;           =      #SetupStarsDataBank                      ;
;----------------------------------------------------------;
SetupStarsDataBank

	NEXTREG _MMU_REG_SLOT7_H57, _ST_BANK_D148	; Assign bank to slot 7

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                 #SetupArraysDataBank                     ;
;----------------------------------------------------------;
SetupArraysDataBank

	NEXTREG _MMU_REG_SLOT7_H57, _BN_SPR_BANK_D149	; Assign bank to slot 7

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                   #SetupPaletteBank                      ;
;----------------------------------------------------------;
SetupPaletteBank

	; Memory bank (8KiB) containing layer 2 palette data.
	NEXTREG _MMU_REG_SLOT6_H56, _BN_PAL2_BANK_D46

	; Memory bank (8KiB) containing layer 2 palette with brightness.
	NEXTREG _MMU_REG_SLOT7_H57, _BN_PAL2_BR_BANK_D47	
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE
