;----------------------------------------------------------;
;                      Level Loader                        ;
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
	CALL bg.LoadLevelBgImage
	POP DE

	; ##########################################
	; Load tile map. DE is set to level number.
	PUSH DE
	CALL fi.LoadPlatformsTilemap 
	POP DE

	; ##########################################
	; Load tile map. DE is set to level number.
	PUSH DE
	CALL fi.LoadRocketStarsTilemap
	POP DE

	; ##########################################
	; Load tile map. DE is set to level number.
	CALL fi.LoadSprites
	
	; ##########################################
	; Setup Platforms.
	CALL dbs.SetupArraysBank
	LD HL, db.platformsL1
	LD A, (db.platformsSizeL1)
	CALL pl.SetupPlatforms

	; ##########################################
	; Load stars.
	CALL dbs.SetupArraysBank
	LD DE, db.starsData1MaxYL1
	LD HL, db.starsData2MaxYL1
	CALL st.SetupStars

	; ##########################################
	; Load rocket.
	CALL dbs.SetupArraysBank
	LD HL, db.rocketElL1
	LD A, (db.rocketAssemblyXL1)
	CALL ro.SetupRocket

	; ##########################################
	; Load single enemies.
	LD A, 10									; Number of single enemies (size of #ENPS)
	LD IX, db.singleEnemiesL1
	CALL es.SetupSingleEnemies

	; ##########################################
	; Load formation.
	;LD IX, db.enemyFormationL1
	;CALL ef.SetupEnemyFormation

	; ##########################################
	; Setup total enemies.
	LD A, 10									; The total amount of visible sprites - including single enemies and formations.
	CALL ep.SetupPatterEnemies

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
	CALL bg.LoadLevelBgImage
	POP DE

	; ##########################################
	; Load tile map. DE is set to level number.
	PUSH DE
	CALL fi.LoadPlatformsTilemap 
	POP DE

	; ##########################################
	; Load tile map. DE is set to level number.
	PUSH DE
	CALL fi.LoadRocketStarsTilemap
	POP DE

	; ##########################################
	; Load tile map. DE is set to level number.
	CALL fi.LoadSprites
	
	; ##########################################
	; Setup Platforms.
	CALL dbs.SetupArraysBank
	LD HL, db.platformsL2
	LD A, (db.platformsSizeL2)
	CALL pl.SetupPlatforms

	; ##########################################
	; Load stars.
	CALL dbs.SetupArraysBank
	LD DE, db.starsData1MaxYL2
	LD HL, db.starsData2MaxYL2
	CALL st.SetupStars

	; ##########################################
	; Load rocket.
	CALL dbs.SetupArraysBank
	LD HL, db.rocketElL2
	LD A, (db.rocketAssemblyXL2)
	CALL ro.SetupRocket

	; ##########################################
	; Load single enemies.
	LD A, 10									; Number of single enemies (size of #ENPS)
	LD IX, db.singleEnemiesL2
	CALL es.SetupSingleEnemies

	; ##########################################
	; Load formation.
	;LD IX, db.enemyFormationL1
	;CALL ef.SetupEnemyFormation

	; ##########################################
	; Setup total enemies.
	LD A, 10									; The total amount of visible sprites - including single enemies and formations.
	CALL ep.SetupPatterEnemies

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
	CALL bg.LoadLevelBgImage
	POP DE

	; ##########################################
	; Load tile map. DE is set to level number.
	PUSH DE
	CALL fi.LoadPlatformsTilemap 
	POP DE

	; ##########################################
	; Load tile map. DE is set to level number.
	PUSH DE
	CALL fi.LoadRocketStarsTilemap
	POP DE

	; ##########################################
	; Load tile map. DE is set to level number.
	CALL fi.LoadSprites
	
	; ##########################################
	; Setup Platforms.
	CALL dbs.SetupArraysBank
	LD HL, db.platformsL3
	LD A, (db.platformsSizeL3)
	CALL pl.SetupPlatforms

	; ##########################################
	; Load stars.
	CALL dbs.SetupArraysBank
	LD DE, db.starsData1MaxYL3
	LD HL, db.starsData2MaxYL3
	CALL st.SetupStars

	; ##########################################
	; Load rocket.
	CALL dbs.SetupArraysBank
	LD HL, db.rocketElL2
	LD A, (db.rocketAssemblyXL2)
	CALL ro.SetupRocket

	; ##########################################
	; Load single enemies.
	LD A, 10									; Number of single enemies (size of #ENPS)
	LD IX, db.singleEnemiesL3
	CALL es.SetupSingleEnemies

	; ##########################################
	; Load formation.
	;LD IX, db.enemyFormationL1
	;CALL ef.SetupEnemyFormation

	; ##########################################
	; Setup total enemies.
	LD A, 10									; The total amount of visible sprites - including single enemies and formations.
	CALL ep.SetupPatterEnemies

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
	CALL bg.LoadLevelBgImage
	POP DE

	; ##########################################
	; Load tile map. DE is set to level number.
	PUSH DE
	CALL fi.LoadPlatformsTilemap 
	POP DE

	; ##########################################
	; Load tile map. DE is set to level number.
	PUSH DE
	CALL fi.LoadRocketStarsTilemap
	POP DE

	; ##########################################
	; Load tile map. DE is set to level number.
	CALL fi.LoadSprites
	
	; ##########################################
	; Setup Platforms.
	CALL dbs.SetupArraysBank
	LD HL, db.platformsL4
	LD A, (db.platformsSizeL4)
	CALL pl.SetupPlatforms

	; ##########################################
	; Load stars.
	CALL dbs.SetupArraysBank
	LD DE, db.starsData1MaxYL4
	LD HL, db.starsData2MaxYL4
	CALL st.SetupStars

	; ##########################################
	; Load rocket.
	CALL dbs.SetupArraysBank
	LD HL, db.rocketElL4
	LD A, (db.rocketAssemblyXL4)
	CALL ro.SetupRocket

	; ##########################################
	; Load single enemies.
	LD A, 10									; Number of single enemies (size of #ENPS)
	LD IX, db.singleEnemiesL4
	CALL es.SetupSingleEnemies

	; ##########################################
	; Load formation.
	;LD IX, db.enemyFormationL1
	;CALL ef.SetupEnemyFormation

	; ##########################################
	; Setup total enemies.
	LD A, 10									; The total amount of visible sprites - including single enemies and formations.
	CALL ep.SetupPatterEnemies
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
	CALL bg.LoadLevelBgImage
	POP DE

	; ##########################################
	; Load tile map. DE is set to level number.
	PUSH DE
	CALL fi.LoadPlatformsTilemap 
	POP DE

	; ##########################################
	; Load tile map. DE is set to level number.
	PUSH DE
	CALL fi.LoadRocketStarsTilemap
	POP DE

	; ##########################################
	; Load tile map. DE is set to level number.
	CALL fi.LoadSprites
	
	; ##########################################
	; Setup Platforms.
	CALL dbs.SetupArraysBank
	LD HL, db.platformsL5
	LD A, (db.platformsSizeL5)
	CALL pl.SetupPlatforms

	; ##########################################
	; Load stars.
	CALL dbs.SetupArraysBank
	LD DE, db.starsData1MaxYL5
	LD HL, db.starsData2MaxYL5
	CALL st.SetupStars

	; ##########################################
	; Load rocket.
	CALL dbs.SetupArraysBank
	LD HL, db.rocketElL5
	LD A, (db.rocketAssemblyXL5)
	CALL ro.SetupRocket

	; ##########################################
	; Load single enemies.
	LD A, 10									; Number of single enemies (size of #ENPS)
	LD IX, db.singleEnemiesL5
	CALL es.SetupSingleEnemies

	; ##########################################
	; Load formation.
	;LD IX, db.enemyFormationL1
	;CALL ef.SetupEnemyFormation

	; ##########################################
	; Setup total enemies.
	LD A, 10									; The total amount of visible sprites - including single enemies and formations.
	CALL ep.SetupPatterEnemies

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
	CALL bg.LoadLevelBgImage
	POP DE

	; ##########################################
	; Load tile map. DE is set to level number.
	PUSH DE
	CALL fi.LoadPlatformsTilemap 
	POP DE

	; ##########################################
	; Load tile map. DE is set to level number.
	PUSH DE
	CALL fi.LoadRocketStarsTilemap
	POP DE

	; ##########################################
	; Load tile map. DE is set to level number.
	CALL fi.LoadSprites
	
	; ##########################################
	; Setup Platforms.
	CALL dbs.SetupArraysBank
	LD HL, db.platformsL6
	LD A, (db.platformsSizeL6)
	CALL pl.SetupPlatforms

	; ##########################################
	; Load stars.
	CALL dbs.SetupArraysBank
	LD DE, db.starsData1MaxYL6
	LD HL, db.starsData2MaxYL6
	CALL st.SetupStars

	; ##########################################
	; Load rocket.
	CALL dbs.SetupArraysBank
	LD HL, db.rocketElL6
	LD A, (db.rocketAssemblyXL6)
	CALL ro.SetupRocket

	; ##########################################
	; Load single enemies.
	LD A, 10									; Number of single enemies (size of #ENPS)
	LD IX, db.singleEnemiesL6
	CALL es.SetupSingleEnemies

	; ##########################################
	; Load formation.
	;LD IX, db.enemyFormationL1
	;CALL ef.SetupEnemyFormation

	; ##########################################
	; Setup total enemies.
	LD A, 10									; The total amount of visible sprites - including single enemies and formations.
	CALL ep.SetupPatterEnemies

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
	CALL bg.LoadLevelBgImage
	POP DE

	; ##########################################
	; Load tile map. DE is set to level number.
	PUSH DE
	CALL fi.LoadPlatformsTilemap 
	POP DE

	; ##########################################
	; Load tile map. DE is set to level number.
	PUSH DE
	CALL fi.LoadRocketStarsTilemap
	POP DE

	; ##########################################
	; Load tile map. DE is set to level number.
	CALL fi.LoadSprites
	
	; ##########################################
	; Setup Platforms.
	CALL dbs.SetupArraysBank
	LD HL, db.platformsL7
	LD A, (db.platformsSizeL7)
	CALL pl.SetupPlatforms

	; ##########################################
	; Load stars.
	CALL dbs.SetupArraysBank
	LD DE, db.starsData1MaxYL7
	LD HL, db.starsData2MaxYL7
	CALL st.SetupStars

	; ##########################################
	; Load rocket.
	CALL dbs.SetupArraysBank
	LD HL, db.rocketElL7
	LD A, (db.rocketAssemblyXL7)
	CALL ro.SetupRocket

	; ##########################################
	; Load single enemies.
	LD A, 10									; Number of single enemies (size of #ENPS)
	LD IX, db.singleEnemiesL7
	CALL es.SetupSingleEnemies

	; ##########################################
	; Load formation.
	;LD IX, db.enemyFormationL1
	;CALL ef.SetupEnemyFormation

	; ##########################################
	; Setup total enemies.
	LD A, 10									; The total amount of visible sprites - including single enemies and formations.
	CALL ep.SetupPatterEnemies

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
	CALL bg.LoadLevelBgImage
	POP DE

	; ##########################################
	; Load tile map. DE is set to level number.
	PUSH DE
	CALL fi.LoadPlatformsTilemap 
	POP DE

	; ##########################################
	; Load tile map. DE is set to level number.
	PUSH DE
	CALL fi.LoadRocketStarsTilemap
	POP DE

	; ##########################################
	; Load tile map. DE is set to level number.
	CALL fi.LoadSprites
	
	; ##########################################
	; Setup Platforms.
	CALL dbs.SetupArraysBank
	LD HL, db.platformsL8
	LD A, (db.platformsSizeL8)
	CALL pl.SetupPlatforms

	; ##########################################
	; Load stars.
	CALL dbs.SetupArraysBank
	LD DE, db.starsData1MaxYL8
	LD HL, db.starsData2MaxYL8
	CALL st.SetupStars

	; ##########################################
	; Load rocket.
	CALL dbs.SetupArraysBank
	LD HL, db.rocketElL8
	LD A, (db.rocketAssemblyXL8)
	CALL ro.SetupRocket
	
	; ##########################################
	; Load single enemies.
	LD A, 10									; Number of single enemies (size of #ENPS)
	LD IX, db.singleEnemiesL8
	CALL es.SetupSingleEnemies

	; ##########################################
	; Load formation.
	;LD IX, db.enemyFormationL1
	;CALL ef.SetupEnemyFormation

	; ##########################################
	; Setup total enemies.
	LD A, 10									; The total amount of visible sprites - including single enemies and formations.
	CALL ep.SetupPatterEnemies

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
	CALL bg.LoadLevelBgImage
	POP DE

	; ##########################################
	; Load tile map. DE is set to level number.
	PUSH DE
	CALL fi.LoadPlatformsTilemap 
	POP DE

	; ##########################################
	; Load tile map. DE is set to level number.
	PUSH DE
	CALL fi.LoadRocketStarsTilemap
	POP DE

	; ##########################################
	; Load tile map. DE is set to level number.
	CALL fi.LoadSprites
	
	; ##########################################
	; Setup Platforms.
	CALL dbs.SetupArraysBank
	LD HL, db.platformsL9
	LD A, (db.platformsSizeL9)
	CALL pl.SetupPlatforms

	; ##########################################
	; Load stars.
	CALL dbs.SetupArraysBank
	LD DE, db.starsData1MaxYL9
	LD HL, db.starsData2MaxYL9
	CALL st.SetupStars

	; ##########################################
	; Load rocket.
	CALL dbs.SetupArraysBank
	LD HL, db.rocketElL9
	LD A, (db.rocketAssemblyXL9)
	CALL ro.SetupRocket

	; ##########################################
	; Load single enemies.
	LD A, 10									; Number of single enemies (size of #ENPS)
	LD IX, db.singleEnemiesL9
	CALL es.SetupSingleEnemies

	; ##########################################
	; Load formation.
	;LD IX, db.enemyFormationL1
	;CALL ef.SetupEnemyFormation

	; ##########################################
	; Setup total enemies.
	LD A, 10									; The total amount of visible sprites - including single enemies and formations.
	CALL ep.SetupPatterEnemies

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
	CALL bg.LoadLevelBgImage
	POP DE

	; ##########################################
	; Load tile map. DE is set to level number.
	PUSH DE
	CALL fi.LoadPlatformsTilemap 
	POP DE

	; ##########################################
	; Load tile map. DE is set to level number.
	PUSH DE
	CALL fi.LoadRocketStarsTilemap
	POP DE

	; ##########################################
	; Load tile map. DE is set to level number.
	CALL fi.LoadSprites
	
	; ##########################################
	; Setup Platforms.
	CALL dbs.SetupArraysBank
	LD HL, db.platformsL10
	LD A, (db.platformsSizeL10)
	CALL pl.SetupPlatforms

	; ##########################################
	; Load stars.
	CALL dbs.SetupArraysBank
	LD DE, db.starsData1MaxYL10
	LD HL, db.starsData2MaxYL10
	CALL st.SetupStars

	; ##########################################
	; Load rocket.
	CALL dbs.SetupArraysBank
	LD HL, db.rocketElL10
	LD A, (db.rocketAssemblyXL10)
	CALL ro.SetupRocket

	; ##########################################
	; Load single enemies.
	LD A, 10									; Number of single enemies (size of #ENPS)
	LD IX, db.singleEnemiesL10
	CALL es.SetupSingleEnemies

	; ##########################################
	; Load formation.
	;LD IX, db.enemyFormationL1
	;CALL ef.SetupEnemyFormation

	; ##########################################
	; Setup total enemies.
	LD A, 10									; The total amount of visible sprites - including single enemies and formations.
	CALL ep.SetupPatterEnemies
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
