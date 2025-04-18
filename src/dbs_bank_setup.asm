;----------------------------------------------------------;
;                      Bank Setup                          ;
;----------------------------------------------------------;
	MODULE dbs

_DBS_BM_BANKS_D10		= 10

_DBS_BGST_BANK_D18		= 18					; Background image occupies 10 8K banks from 18 to 27 (starts on 16K bank 9, uses 5 16K banks).
_DBS_BG_END_BANK_D27	= 27					; Last background bank (inclusive).
_DBS_ST_BANK_D28		= 28					; Bank for stars, slot 6
_DBS_ARR_BANK_D29		= 29					; Bank for arrays, slot 6
_DBS_TI_SPR_BANK_D30	= 30
_DBS_PAL2_BANK_D31		= 31					; Layer 2 pallettes
_DBS_PAL2_BR_BANK_D32	= 32					; Layer 2 brightness change for pallettes from _DBS_PAL2_BANK_D31.
_DBS_SPR_BANK1_D33		= 33
_DBS_SPR_BANK2_D34		= 34

; Background image (all values inclusive). Each background image has 80KiB (320x256), taking 10 banks.
_DBS_BGST_BANK_D35		= 35
_DBS_BG_EN_BANK_D44 	= _DBS_BGST_BANK_D35+_DBS_BM_BANKS_D10-1; -1 because inclusive.
	ASSERT _DBS_BG_EN_BANK_D44 == 44

_DBS_RO_STAR_BANK1_D45	= 46
_DBS_RO_STAR_BANK2_D46	= 47

;----------------------------------------------------------;
;                    #SetupTilesBank                       ;
;----------------------------------------------------------;
SetupTilesBank

	NEXTREG _MMU_REG_SLOT7_H57, _DBS_TI_SPR_BANK_D30	; Assign bank 30 to slot 7.

	RET											; ## END of the function ##	

;----------------------------------------------------------;
;               #SetupRocketStarsBank                      ;
;----------------------------------------------------------;
SetupRocketStarsBank

	NEXTREG _MMU_REG_SLOT6_H56, _DBS_RO_STAR_BANK1_D45 ; Assign bank 31 to slot 6 (see di_data_bin.asm).
	NEXTREG _MMU_REG_SLOT7_H57, _DBS_RO_STAR_BANK2_D46 ; Assign bank 32 to slot 7.

	RET											; ## END of the function ##
	
;----------------------------------------------------------;
;                  #SetupSpritesBank                       ;
;----------------------------------------------------------;
SetupSpritesBank

	NEXTREG _MMU_REG_SLOT6_H56, _DBS_SPR_BANK1_D33	; Assign bank 28 to slot 6 (see di_data_bin.asm).
	NEXTREG _MMU_REG_SLOT7_H57, _DBS_SPR_BANK2_D34	; Assign bank 29 to slot 7.

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                    #SetupStarsBank                       ;
;----------------------------------------------------------;
SetupStarsBank

	NEXTREG _MMU_REG_SLOT7_H57, _DBS_ST_BANK_D28

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                   #SetupArraysBank                       ;
;----------------------------------------------------------;
SetupArraysBank

	NEXTREG _MMU_REG_SLOT7_H57, _DBS_ARR_BANK_D29

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                   #SetupPaletteBank                      ;
;----------------------------------------------------------;
SetupPaletteBank

	; Memory bank (8KiB) containing layer 2 palette data.
	NEXTREG _MMU_REG_SLOT6_H56, _DBS_PAL2_BANK_D31

	; Memory bank (8KiB) containing layer 2 palette with brightness.
	NEXTREG _MMU_REG_SLOT7_H57, _DBS_PAL2_BR_BANK_D32	
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE
