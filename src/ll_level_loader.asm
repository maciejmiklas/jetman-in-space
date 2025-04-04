;----------------------------------------------------------;
;                       Level Data                         ;
;----------------------------------------------------------;
	MODULE ll

;----------------------------------------------------------;
;                    #LoadLevel1Data                       ;
;----------------------------------------------------------;
LoadLevel1Data

	; Load palettes
	CALL dbs.SetupPaletteBank
	
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
	PUSH DE
	CALL bg.LoadBgImage
	POP DE

	; ##########################################
	; Load tile map.
	; DE is set to level number above
	CALL ti.LoadGameTilemap

	; ##########################################
	; Load platforms map.

	CALL dbs.SetupArraysBank
	LD HL, db.platformsL1
	LD (pl.platforms), HL

	LD A, (db.platformsSizeL1)
	LD (pl.platformsSize), A

	; ##########################################
	; Load stars.
	LD HL, db.starsData1MaxYL1
	LD (st.starsData1MaxY), HL

	LD HL, db.starsData2MaxYL1
	LD (st.starsData2MaxY), HL
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #LoadLevel2Data                         ;
;----------------------------------------------------------;
LoadLevel2Data

	; Load palettes
	CALL dbs.SetupPaletteBank

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
	PUSH DE
	CALL bg.LoadBgImage
	POP DE

	; ##########################################
	; Load tile map.
	; DE is set to level number above
	CALL ti.LoadGameTilemap

	; ##########################################
	; Load platforms map.

	CALL dbs.SetupArraysBank
	LD HL, db.platformsL2
	LD (pl.platforms), HL

	LD A, (db.platformsSizeL2)
	LD (pl.platformsSize), A

	; ##########################################
	; Load stars.
	LD HL, db.starsData1MaxYL2
	LD (st.starsData1MaxY), HL

	LD HL, db.starsData2MaxYL2
	LD (st.starsData2MaxY), HL

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #LoadLevel3Data                         ;
;----------------------------------------------------------;
LoadLevel3Data

	; Load palettes
	CALL dbs.SetupPaletteBank

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
	PUSH DE
	CALL bg.LoadBgImage
	POP DE

	; ##########################################
	; Load tile map.
	; DE is set to level number above
	CALL ti.LoadGameTilemap
	
	; ##########################################
	; Load platforms map.

	CALL dbs.SetupArraysBank
	LD HL, db.platformsL3
	LD (pl.platforms), HL

	LD A, (db.platformsSizeL3)
	LD (pl.platformsSize), A

	; ##########################################
	; Load stars.
	LD HL, db.starsData1MaxYL3
	LD (st.starsData1MaxY), HL

	LD HL, db.starsData2MaxYL3
	LD (st.starsData2MaxY), HL

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #LoadLevel4Data                         ;
;----------------------------------------------------------;
LoadLevel4Data

	; Load palettes
	CALL dbs.SetupPaletteBank

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
	PUSH DE
	CALL bg.LoadBgImage
	POP DE

	; ##########################################
	; Load tile map.
	; DE is set to level number above
	CALL ti.LoadGameTilemap

	; ##########################################
	; Load platforms map.

	CALL dbs.SetupArraysBank
	LD HL, db.platformsL4
	LD (pl.platforms), HL

	LD A, (db.platformsSizeL4)
	LD (pl.platformsSize), A

	; ##########################################
	; Load stars.
	LD HL, db.starsData1MaxYL4
	LD (st.starsData1MaxY), HL

	LD HL, db.starsData2MaxYL4
	LD (st.starsData2MaxY), HL

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #LoadLevel5Data                         ;
;----------------------------------------------------------;
LoadLevel5Data

	; Load palettes
	CALL dbs.SetupPaletteBank

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
	PUSH DE
	CALL bg.LoadBgImage
	POP DE

	; ##########################################
	; Load tile map.
	; DE is set to level number above
	CALL ti.LoadGameTilemap

	; ##########################################
	; Load platforms map.

	CALL dbs.SetupArraysBank
	LD HL, db.platformsL5
	LD (pl.platforms), HL

	LD A, (db.platformsSizeL5)
	LD (pl.platformsSize), A

	; ##########################################
	; Load stars.
	LD HL, db.starsData1MaxYL5
	LD (st.starsData1MaxY), HL

	LD HL, db.starsData2MaxYL5
	LD (st.starsData2MaxY), HL

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #LoadLevel6Data                         ;
;----------------------------------------------------------;
LoadLevel6Data

	; Load palettes
	CALL dbs.SetupPaletteBank

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
	PUSH DE
	CALL bg.LoadBgImage
	POP DE

	; ##########################################
	; Load tile map.
	; DE is set to level number above
	CALL ti.LoadGameTilemap

	; ##########################################
	; Load platforms map.

	CALL dbs.SetupArraysBank
	LD HL, db.platformsL6
	LD (pl.platforms), HL

	LD A, (db.platformsSizeL6)
	LD (pl.platformsSize), A

	; ##########################################
	; Load stars.
	LD HL, db.starsData1MaxYL6
	LD (st.starsData1MaxY), HL

	LD HL, db.starsData2MaxYL6
	LD (st.starsData2MaxY), HL

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #LoadLevel7Data                         ;
;----------------------------------------------------------;
LoadLevel7Data

	; Load palettes
	CALL dbs.SetupPaletteBank

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
	PUSH DE
	CALL bg.LoadBgImage
	POP DE

	; ##########################################
	; Load tile map.
	; DE is set to level number above
	CALL ti.LoadGameTilemap

	; ##########################################
	; Load platforms map.

	CALL dbs.SetupArraysBank
	LD HL, db.platformsL7
	LD (pl.platforms), HL

	LD A, (db.platformsSizeL7)
	LD (pl.platformsSize), A

	; ##########################################
	; Load stars.
	LD HL, db.starsData1MaxYL7
	LD (st.starsData1MaxY), HL

	LD HL, db.starsData2MaxYL7
	LD (st.starsData2MaxY), HL

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #LoadLevel8Data                         ;
;----------------------------------------------------------;
LoadLevel8Data

	; Load palettes
	CALL dbs.SetupPaletteBank
	
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
	PUSH DE
	CALL bg.LoadBgImage
	POP DE

	; ##########################################
	; Load tile map.
	; DE is set to level number above
	CALL ti.LoadGameTilemap

	; ##########################################
	; Load platforms map.

	CALL dbs.SetupArraysBank
	LD HL, db.platformsL8
	LD (pl.platforms), HL

	LD A, (db.platformsSizeL8)
	LD (pl.platformsSize), A

	; ##########################################
	; Load stars.
	LD HL, db.starsData1MaxYL8
	LD (st.starsData1MaxY), HL

	LD HL, db.starsData2MaxYL8
	LD (st.starsData2MaxY), HL

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #LoadLevel9Data                         ;
;----------------------------------------------------------;
LoadLevel9Data

	; Load palettes
	CALL dbs.SetupPaletteBank

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
	PUSH DE
	CALL bg.LoadBgImage
	POP DE

	; ##########################################
	; Load tile map.
	; DE is set to level number above
	CALL ti.LoadGameTilemap

	; ##########################################
	; Load platforms map.

	CALL dbs.SetupArraysBank
	LD HL, db.platformsL9
	LD (pl.platforms), HL

	LD A, (db.platformsSizeL9)
	LD (pl.platformsSize), A

	; ##########################################
	; Load stars.
	LD HL, db.starsData1MaxYL9
	LD (st.starsData1MaxY), HL

	LD HL, db.starsData2MaxYL9
	LD (st.starsData2MaxY), HL

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #LoadLevel10Data                        ;
;----------------------------------------------------------;
LoadLevel10Data

	CALL dbs.SetupPaletteBank

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
	PUSH DE
	CALL bg.LoadBgImage
	POP DE

	; ##########################################
	; Load tile map.
	; DE is set to level number above
	CALL ti.LoadGameTilemap

	; ##########################################
	; Load platforms map.

	CALL dbs.SetupArraysBank
	LD HL, db.platformsL10
	LD (pl.platforms), HL

	LD A, (db.platformsSizeL10)
	LD (pl.platformsSize), A	

	; ##########################################
	; Load stars.
	LD HL, db.starsData1MaxYL10
	LD (st.starsData1MaxY), HL

	LD HL, db.starsData2MaxYL10
	LD (st.starsData2MaxY), HL

	RET											; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE
