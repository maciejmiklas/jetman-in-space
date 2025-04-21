;----------------------------------------------------------;
;                      Bank Setup                          ;
;----------------------------------------------------------;
	MODULE dbs


BM_BANKS_D10			= 10

BGST_BANK_D18			= 18					; Background image occupies 10 8K banks from 18 to 27 (starts on 16K bank 9, uses 5 16K banks).
BG_END_BANK_D27			= 27					; Last background bank (inclusive).
ST_BANK_D28				= 28					; Bank for stars, slot 6
ARR_BANK_D29			= 29					; Bank for arrays, slot 6
TI_SPR_BANK_D30			= 30
PAL2_BANK_D31			= 31					; Layer 2 pallettes
PAL2_BR_BANK_D32		= 32					; Layer 2 brightness change for pallettes from dbs.PAL2_BANK_D31.
SPR_BANK1_D33			= 33
SPR_BANK2_D34			= 34

; Background image (all values inclusive). Background image has 80KiB (320x256), taking 10 banks.
BGST_BANK_D35			= 35
BG_EN_BANK_D44 	= dbs.BGST_BANK_D35+dbs.BM_BANKS_D10-1; -1 because inclusive.
	ASSERT dbs.BG_EN_BANK_D44 == 44

RO_STAR_BANK1_D45		= 46
RO_STAR_BANK2_D46		= 47

;----------------------------------------------------------;
;                    #SetupTilesBank                       ;
;----------------------------------------------------------;
SetupTilesBank

	NEXTREG _MMU_REG_SLOT7_H57, dbs.TI_SPR_BANK_D30	; Assign bank 30 to slot 7.

	RET											; ## END of the function ##	

;----------------------------------------------------------;
;               #SetupRocketStarsBank                      ;
;----------------------------------------------------------;
SetupRocketStarsBank

	NEXTREG _MMU_REG_SLOT6_H56, dbs.RO_STAR_BANK1_D45 ; Assign bank 31 to slot 6 (see di_data_bin.asm).
	NEXTREG _MMU_REG_SLOT7_H57, dbs.RO_STAR_BANK2_D46 ; Assign bank 32 to slot 7.

	RET											; ## END of the function ##
	
;----------------------------------------------------------;
;                  #SetupSpritesBank                       ;
;----------------------------------------------------------;
SetupSpritesBank

	NEXTREG _MMU_REG_SLOT6_H56, dbs.SPR_BANK1_D33	; Assign bank 28 to slot 6 (see di_data_bin.asm).
	NEXTREG _MMU_REG_SLOT7_H57, dbs.SPR_BANK2_D34	; Assign bank 29 to slot 7.

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                    #SetupStarsBank                       ;
;----------------------------------------------------------;
SetupStarsBank

	NEXTREG _MMU_REG_SLOT7_H57, dbs.ST_BANK_D28

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                   #SetupArraysBank                       ;
;----------------------------------------------------------;
SetupArraysBank

	NEXTREG _MMU_REG_SLOT7_H57, dbs.ARR_BANK_D29

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                   #SetupPaletteBank                      ;
;----------------------------------------------------------;
SetupPaletteBank

	; Memory bank (8KiB) containing layer 2 palette data.
	NEXTREG _MMU_REG_SLOT6_H56, dbs.PAL2_BANK_D31

	; Memory bank (8KiB) containing layer 2 palette with brightness.
	NEXTREG _MMU_REG_SLOT7_H57, dbs.PAL2_BR_BANK_D32	
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE
