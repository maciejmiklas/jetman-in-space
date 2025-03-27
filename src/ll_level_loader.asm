;----------------------------------------------------------;
;                       Level Data                         ;
;----------------------------------------------------------;
	MODULE ll

;----------------------------------------------------------;
;                    #LoadLevel1Data                       ;
;----------------------------------------------------------;
LoadLevel1Data

	; Load palettes
	CALL bs.SetupPaletteBank
	
	; Load palette size into a global variable.
	LD HL, db.bgrL1PaletteBytes
	LD (btd.palBytes), HL

	; Load the address of the original palette into a global variable.
	LD HL, db.bgrL1PaletteAdr
	LD (btd.palAdr), HL

	CALL btd.CreateTodPalettes

	; ##########################################
	; Load background image.
	LD D, "0"
	LD E, "1"
	CALL bg.LoadBgImage

	; ##########################################
	; Load tile map.
	NEXTREG _MMU_REG_SLOT6_H56, _BN_TI_L1_3_BANK_D150
	LD HL, db.tilesL1
	CALL ti.LoadTiles

	; ##########################################
	; Load platforms map.

	CALL bs.SetupArraysDataBank
	LD HL, db.platformsL1
	LD (pl.platforms), HL

	LD A, (db.platformsSizeL1)
	LD (pl.platformsSize), A
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #LoadLevel2Data                         ;
;----------------------------------------------------------;
LoadLevel2Data

	; Load palettes
	CALL bs.SetupPaletteBank

	; Load palette size into a global variable.
	LD HL, db.bgrL2PaletteBytes
	LD (btd.palBytes), HL

	; Load the address of the original palette into a global variable.
	LD HL, db.bgrL2PaletteAdr
	LD (btd.palAdr), HL

	CALL btd.CreateTodPalettes

	; ##########################################
	; Load background image.
	LD D, "0"
	LD E, "2"
	CALL bg.LoadBgImage

	; ##########################################
	; Load tile map.
	NEXTREG _MMU_REG_SLOT6_H56, _BN_TI_L1_3_BANK_D150
	LD HL, db.tilesL2
	CALL ti.LoadTiles

	; ##########################################
	; Load platforms map.

	CALL bs.SetupArraysDataBank
	LD HL, db.platformsL2
	LD (pl.platforms), HL

	LD A, (db.platformsSizeL2)
	LD (pl.platformsSize), A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #LoadLevel3Data                         ;
;----------------------------------------------------------;
LoadLevel3Data

	; Load palettes
	CALL bs.SetupPaletteBank

	; Load palette size into a global variable.
	LD HL, db.bgrL3PaletteBytes
	LD (btd.palBytes), HL

	; Load the address of the original palette into a global variable.
	LD HL, db.bgrL3PaletteAdr
	LD (btd.palAdr), HL

	CALL btd.CreateTodPalettes

	; ##########################################
	; Load background image.
	LD D, "0"
	LD E, "3"
	CALL bg.LoadBgImage
	
	; ##########################################
	; Load tile map.
	NEXTREG _MMU_REG_SLOT6_H56, _BN_TI_L1_3_BANK_D150
	LD HL, db.tilesL3
	CALL ti.LoadTiles
	
	; ##########################################
	; Load platforms map.

	CALL bs.SetupArraysDataBank
	LD HL, db.platformsL3
	LD (pl.platforms), HL

	LD A, (db.platformsSizeL3)
	LD (pl.platformsSize), A	

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #LoadLevel4Data                         ;
;----------------------------------------------------------;
LoadLevel4Data

	; Load palettes
	CALL bs.SetupPaletteBank

	; Load palette size into a global variable.
	LD HL, db.bgrL4PaletteBytes
	LD (btd.palBytes), HL

	; Load the address of the original palette into a global variable.
	LD HL, db.bgrL4PaletteAdr
	LD (btd.palAdr), HL

	CALL btd.CreateTodPalettes

	; ##########################################
	; Load background image.

	; Load the address of the image into a global variable. LoadImage will be called on #RespawnJet
	LD D, "0"
	LD E, "4"
	CALL bg.LoadBgImage

	; ##########################################
	; Load tile map.
	NEXTREG _MMU_REG_SLOT6_H56, _BN_TI_L4_6_BANK_D151
	LD HL, db.tilesL4
	CALL ti.LoadTiles

	; ##########################################
	; Load platforms map.

	CALL bs.SetupArraysDataBank
	LD HL, db.platformsL4
	LD (pl.platforms), HL

	LD A, (db.platformsSizeL4)
	LD (pl.platformsSize), A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #LoadLevel5Data                         ;
;----------------------------------------------------------;
LoadLevel5Data

	; Load palettes
	CALL bs.SetupPaletteBank

	; Load palette size into a global variable.
	LD HL, db.bgrL5PaletteBytes
	LD (btd.palBytes), HL

	; Load the address of the original palette into a global variable.
	LD HL, db.bgrL5PaletteAdr
	LD (btd.palAdr), HL

	CALL btd.CreateTodPalettes

	; ##########################################
	; Load background image
	LD D, "0"
	LD E, "5"
	CALL bg.LoadBgImage

	; ##########################################
	; Load tile map
	NEXTREG _MMU_REG_SLOT6_H56, _BN_TI_L4_6_BANK_D151
	LD HL, db.tilesL5
	CALL ti.LoadTiles

	; ##########################################
	; Load platforms map.

	CALL bs.SetupArraysDataBank
	LD HL, db.platformsL5
	LD (pl.platforms), HL

	LD A, (db.platformsSizeL5)
	LD (pl.platformsSize), A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #LoadLevel6Data                         ;
;----------------------------------------------------------;
LoadLevel6Data

	; Load palettes
	CALL bs.SetupPaletteBank

	; Load palette size into a global variable.
	LD HL, db.bgrL6PaletteBytes
	LD (btd.palBytes), HL

	; Load the address of the original palette into a global variable.
	LD HL, db.bgrL6PaletteAdr
	LD (btd.palAdr), HL

	CALL btd.CreateTodPalettes

	; ##########################################
	; Load background image
	LD D, "0"
	LD E, "6"
	CALL bg.LoadBgImage

	; ##########################################
	; Load tile map
	NEXTREG _MMU_REG_SLOT6_H56, _BN_TI_L4_6_BANK_D151
	LD HL, db.tilesL6
	CALL ti.LoadTiles

	; ##########################################
	; Load platforms map.

	CALL bs.SetupArraysDataBank
	LD HL, db.platformsL6
	LD (pl.platforms), HL

	LD A, (db.platformsSizeL6)
	LD (pl.platformsSize), A	

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #LoadLevel7Data                         ;
;----------------------------------------------------------;
LoadLevel7Data

	; Load palettes
	CALL bs.SetupPaletteBank

	; Load palette size into a global variable.
	LD HL, db.bgrL7PaletteBytes
	LD (btd.palBytes), HL

	; Load the address of the original palette into a global variable.
	LD HL, db.bgrL7PaletteAdr
	LD (btd.palAdr), HL

	CALL btd.CreateTodPalettes

	; ##########################################
	; Load background image
	LD D, "0"
	LD E, "7"
	CALL bg.LoadBgImage

	; ##########################################
	; Load tile map
	NEXTREG _MMU_REG_SLOT6_H56, _BN_TI_L7_9_BANK_D152
	LD HL, db.tilesL7
	CALL ti.LoadTiles

	; ##########################################
	; Load platforms map.

	CALL bs.SetupArraysDataBank
	LD HL, db.platformsL7
	LD (pl.platforms), HL

	LD A, (db.platformsSizeL7)
	LD (pl.platformsSize), A	

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #LoadLevel8Data                         ;
;----------------------------------------------------------;
LoadLevel8Data

	; Load palettes
	CALL bs.SetupPaletteBank
	
	; Load palette size into a global variable.
	LD HL, db.bgrL8PaletteBytes
	LD (btd.palBytes), HL

	; Load the address of the original palette into a global variable.
	LD HL, db.bgrL8PaletteAdr
	LD (btd.palAdr), HL

	CALL btd.CreateTodPalettes

	; ##########################################
	; Load background image
	LD D, "0"
	LD E, "8"
	CALL bg.LoadBgImage

	; ##########################################
	; Load tile map
	NEXTREG _MMU_REG_SLOT6_H56, _BN_TI_L7_9_BANK_D152
	LD HL, db.tilesL8
	CALL ti.LoadTiles


	; ##########################################
	; Load platforms map.

	CALL bs.SetupArraysDataBank
	LD HL, db.platformsL8
	LD (pl.platforms), HL

	LD A, (db.platformsSizeL8)
	LD (pl.platformsSize), A
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #LoadLevel9Data                         ;
;----------------------------------------------------------;
LoadLevel9Data

	; Load palettes
	CALL bs.SetupPaletteBank

	; Load palette size into a global variable.
	LD HL, db.bgrL9PaletteBytes
	LD (btd.palBytes), HL

	; Load the address of the original palette into a global variable.
	LD HL, db.bgrL9PaletteAdr
	LD (btd.palAdr), HL

	CALL btd.CreateTodPalettes

	; ##########################################
	; Load background image
	LD D, "0"
	LD E, "9"
	CALL bg.LoadBgImage

	; ##########################################
	; Load tile map
	NEXTREG _MMU_REG_SLOT6_H56, _BN_TI_L7_9_BANK_D152
	LD HL, db.tilesL9
	CALL ti.LoadTiles

	; ##########################################
	; Load platforms map.

	CALL bs.SetupArraysDataBank
	LD HL, db.platformsL9
	LD (pl.platforms), HL

	LD A, (db.platformsSizeL9)
	LD (pl.platformsSize), A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #LoadLevel10Data                        ;
;----------------------------------------------------------;
LoadLevel10Data

	; Load palettes
	CALL bs.SetupPaletteBank

	; Load palette size into a global variable.
	LD HL, db.bgrL10PaletteBytes
	LD (btd.palBytes), HL

	; Load the address of the original palette into a global variable.
	LD HL, db.bgrL10PaletteAdr
	LD (btd.palAdr), HL

	CALL btd.CreateTodPalettes

	; ##########################################
	; Load background image
	LD D, "1"
	LD E, "0"
	CALL bg.LoadBgImage

	; ##########################################
	; Load tile map
	NEXTREG _MMU_REG_SLOT6_H56, _BN_TI_L10_BANK_D42
	LD HL, db.tilesL10
	CALL ti.LoadTiles

	; ##########################################
	; Load platforms map.

	CALL bs.SetupArraysDataBank
	LD HL, db.platformsL10
	LD (pl.platforms), HL

	LD A, (db.platformsSizeL10)
	LD (pl.platformsSize), A	

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE
