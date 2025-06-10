;----------------------------------------------------------;
;                      Level Loader                        ;
;----------------------------------------------------------;
    MODULE ll

;----------------------------------------------------------;
;                     LoadLevel1Data                       ;
;----------------------------------------------------------;
LoadLevel1Data

    ; Load palettes
    CALL dbs.SetupPaletteBank
    
    ; Load palette size into a global variable
    LD HL, db.bgrL1PaletteBytes
    LD (btd.palBytes), HL

    ; Load the address of the original palette into a global variable
    LD HL, db.bgrL1PaletteAdr
    LD (btd.palAdr), HL

    CALL btd.CreateTodPalettes

    ; ##########################################
    ; Load background image.
    LD D, "0"
    LD E, "1"
    PUSH DE
    CALL fi.LoadBgImageFile
    POP DE

    ; ##########################################
    ; Load tile map. DE is set to level number
    PUSH DE
    CALL fi.LoadPlatformsTilemapFile
    POP DE

    ; ##########################################
    ; Load tile map. DE is set to level number
    PUSH DE
    CALL fi.LoadRocketStarsTilemapFile
    POP DE

    ; ##########################################
    ; Load tile map. DE is set to level number
    CALL fi.LoadSpritesFile
    CALL sp.LoadSpritesFPGA

    ; ##########################################
    ; Setup Platforms
    CALL dbs.SetupArraysBank
    LD HL, dba.platformsL1
    LD A, (dba.platformsSizeL1)
    CALL pl.SetupPlatforms

    ; ##########################################
    ; Load stars
    CALL dbs.SetupArraysBank
    LD DE, dbs.starsData1MaxYL1
    LD HL, dbs.starsData2MaxYL1
    CALL st.SetupStars

    ; ##########################################
    ; Load rocket
    CALL dbs.SetupArraysBank
    LD HL, dba.rocketElL1
    LD A, (dba.rocketAssemblyXL1)
    CALL ro.SetupRocket

    ; ##########################################
    ; Load single enemies
    CALL dbs.SetupEnemyBank
    LD A, ena.SINGLE_ENEMIES_L1
    LD IX, ena.singleEnemiesL1
    LD B, ens.NEXT_RESP_DEL
    CALL ens.SetupSingleEnemies

    ; ##########################################
    ; Load formation
    CALL dbs.SetupEnemyBank
    LD A, 0                                     ; Disable formation
    LD IX, ena.enemyFormationL1
    CALL enf.SetupEnemyFormation

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   LoadLevel2Data                         ;
;----------------------------------------------------------;
LoadLevel2Data

    ; Load palettes
    CALL dbs.SetupPaletteBank

    ; Load palette size into a global variable
    LD HL, db.bgrL2PaletteBytes
    LD (btd.palBytes), HL

    ; Load the address of the original palette into a global variable
    LD HL, db.bgrL2PaletteAdr
    LD (btd.palAdr), HL

    CALL btd.CreateTodPalettes

    ; ##########################################
    ; Load background image
    LD D, "0"
    LD E, "2"
    PUSH DE
    CALL fi.LoadBgImageFile
    POP DE

    ; ##########################################
    ; Load tile map. DE is set to level number
    PUSH DE
    CALL fi.LoadPlatformsTilemapFile 
    POP DE

    ; ##########################################
    ; Load tile map. DE is set to level number
    PUSH DE
    CALL fi.LoadRocketStarsTilemapFile
    POP DE

    ; ##########################################
    ; Load tile map. DE is set to level number
    CALL fi.LoadSpritesFile
    CALL sp.LoadSpritesFPGA

    ; ##########################################
    ; Setup Platforms
    CALL dbs.SetupArraysBank
    LD HL, dba.platformsL2
    LD A, (dba.platformsSizeL2)
    CALL pl.SetupPlatforms

    ; ##########################################
    ; Load stars
    CALL dbs.SetupArraysBank
    LD DE, dbs.starsData1MaxYL2
    LD HL, dbs.starsData2MaxYL2
    CALL st.SetupStars

    ; ##########################################
    ; Load rocket
    CALL dbs.SetupArraysBank
    LD HL, dba.rocketElL2
    LD A, (dba.rocketAssemblyXL2)
    CALL ro.SetupRocket

    ; ##########################################
    ; Load single enemies
    CALL dbs.SetupEnemyBank
    LD A, ena.SINGLE_ENEMIES_L2
    LD IX, ena.singleEnemiesL2
    LD B, ens.NEXT_RESP_DEL
    CALL ens.SetupSingleEnemies

    ; ##########################################
    ; Load formation
    CALL dbs.SetupEnemyBank
    LD A, 0                                     ; Disable formation
    LD IX, ena.enemyFormationL2
    CALL enf.SetupEnemyFormation

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   LoadLevel3Data                         ;
;----------------------------------------------------------;
LoadLevel3Data

    ; Load palettes
    CALL dbs.SetupPaletteBank

    ; Load palette size into a global variable
    LD HL, db.bgrL3PaletteBytes
    LD (btd.palBytes), HL

    ; Load the address of the original palette into a global variable
    LD HL, db.bgrL3PaletteAdr
    LD (btd.palAdr), HL

    CALL btd.CreateTodPalettes

    ; ##########################################
    ; Load background image
    LD D, "0"
    LD E, "3"
    PUSH DE
    CALL fi.LoadBgImageFile
    POP DE

    ; ##########################################
    ; Load tile map. DE is set to level number
    PUSH DE
    CALL fi.LoadPlatformsTilemapFile 
    POP DE

    ; ##########################################
    ; Load tile map. DE is set to level number
    PUSH DE
    CALL fi.LoadRocketStarsTilemapFile
    POP DE

    ; ##########################################
    ; Load tile map. DE is set to level number
    CALL fi.LoadSpritesFile
    CALL sp.LoadSpritesFPGA

    ; ##########################################
    ; Setup Platforms
    CALL dbs.SetupArraysBank
    LD HL, dba.platformsL3
    LD A, (dba.platformsSizeL3)
    CALL pl.SetupPlatforms

    ; ##########################################
    ; Load stars
    CALL dbs.SetupArraysBank
    LD DE, dbs.starsData1MaxYL3
    LD HL, dbs.starsData2MaxYL3
    CALL st.SetupStars

    ; ##########################################
    ; Load rocket
    CALL dbs.SetupArraysBank
    LD HL, dba.rocketElL3
    LD A, (dba.rocketAssemblyXL3)
    CALL ro.SetupRocket

    ; ##########################################
    ; Load single enemies
    CALL dbs.SetupEnemyBank
    LD A, ena.SINGLE_ENEMIES_L3
    LD IX, ena.singleEnemiesL3
    LD B, ens.NEXT_RESP_DEL
    CALL ens.SetupSingleEnemies

    ; ##########################################
    ; Load formation
    CALL dbs.SetupEnemyBank
    LD A, 150
    LD IX, ena.enemyFormationL3
    CALL enf.SetupEnemyFormation

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   LoadLevel4Data                         ;
;----------------------------------------------------------;
LoadLevel4Data

    ; Load palettes
    CALL dbs.SetupPaletteBank

    ; Load palette size into a global variable
    LD HL, db.bgrL4PaletteBytes
    LD (btd.palBytes), HL

    ; Load the address of the original palette into a global variable
    LD HL, db.bgrL4PaletteAdr
    LD (btd.palAdr), HL

    CALL btd.CreateTodPalettes

    ; ##########################################
    ; Load background image.

    ; Load the address of the image into a global variable. LoadImage will be called on #RespawnJet
    LD D, "0"
    LD E, "4"
    PUSH DE
    CALL fi.LoadBgImageFile
    POP DE

    ; ##########################################
    ; Load tile map. DE is set to level number
    PUSH DE
    CALL fi.LoadPlatformsTilemapFile 
    POP DE

    ; ##########################################
    ; Load tile map. DE is set to level number
    PUSH DE
    CALL fi.LoadRocketStarsTilemapFile
    POP DE

    ; ##########################################
    ; Load tile map. DE is set to level number
    CALL fi.LoadSpritesFile
    CALL sp.LoadSpritesFPGA

    ; ##########################################
    ; Setup Platforms
    CALL dbs.SetupArraysBank
    LD HL, dba.platformsL4
    LD A, (dba.platformsSizeL4)
    CALL pl.SetupPlatforms

    ; ##########################################
    ; Load stars
    CALL dbs.SetupArraysBank
    LD DE, dbs.starsData1MaxYL4
    LD HL, dbs.starsData2MaxYL4
    CALL st.SetupStars

    ; ##########################################
    ; Load rocket
    CALL dbs.SetupArraysBank
    LD HL, dba.rocketElL4
    LD A, (dba.rocketAssemblyXL4)
    CALL ro.SetupRocket

    ; ##########################################
    ; Load single enemies
    CALL dbs.SetupEnemyBank
    LD A, ena.SINGLE_ENEMIES_L4
    LD IX, ena.singleEnemiesL4
    LD B, ens.NEXT_RESP_DEL
    CALL ens.SetupSingleEnemies

    ; ##########################################
    ; Load formation
    CALL dbs.SetupEnemyBank
    LD A, 100
    LD IX, ena.enemyFormationL4
    CALL enf.SetupEnemyFormation

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   LoadLevel5Data                         ;
;----------------------------------------------------------;
LoadLevel5Data

    ; Load palettes
    CALL dbs.SetupPaletteBank

    ; Load palette size into a global variable
    LD HL, db.bgrL5PaletteBytes
    LD (btd.palBytes), HL

    ; Load the address of the original palette into a global variable
    LD HL, db.bgrL5PaletteAdr
    LD (btd.palAdr), HL

    CALL btd.CreateTodPalettes

    ; ##########################################
    ; Load background image
    LD D, "0"
    LD E, "5"
    PUSH DE
    CALL fi.LoadBgImageFile
    POP DE

    ; ##########################################
    ; Load tile map. DE is set to level number
    PUSH DE
    CALL fi.LoadPlatformsTilemapFile 
    POP DE

    ; ##########################################
    ; Load tile map. DE is set to level number
    PUSH DE
    CALL fi.LoadRocketStarsTilemapFile
    POP DE

    ; ##########################################
    ; Load tile map. DE is set to level number
    CALL fi.LoadSpritesFile
    CALL sp.LoadSpritesFPGA

    ; ##########################################
    ; Setup Platforms
    CALL dbs.SetupArraysBank
    LD HL, dba.platformsL5
    LD A, (dba.platformsSizeL5)
    CALL pl.SetupPlatforms

    ; ##########################################
    ; Load stars
    CALL dbs.SetupArraysBank
    LD DE, dbs.starsData1MaxYL5
    LD HL, dbs.starsData2MaxYL5
    CALL st.SetupStars

    ; ##########################################
    ; Load rocket
    CALL dbs.SetupArraysBank
    LD HL, dba.rocketElL5
    LD A, (dba.rocketAssemblyXL5)
    CALL ro.SetupRocket

    ; ##########################################
    ; Load single enemies
    CALL dbs.SetupEnemyBank
    LD A, ena.SINGLE_ENEMIES_L5
    LD IX, ena.singleEnemiesL5
    LD B, ens.NEXT_RESP_DEL
    CALL ens.SetupSingleEnemies

    ; ##########################################
    ; Load formation
    CALL dbs.SetupEnemyBank
    LD A, 0
    LD IX, ena.enemyFormationL5
    CALL enf.SetupEnemyFormation

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   LoadLevel6Data                         ;
;----------------------------------------------------------;
LoadLevel6Data

    ; Load palettes
    CALL dbs.SetupPaletteBank

    ; Load palette size into a global variable
    LD HL, db.bgrL6PaletteBytes
    LD (btd.palBytes), HL

    ; Load the address of the original palette into a global variable
    LD HL, db.bgrL6PaletteAdr
    LD (btd.palAdr), HL

    CALL btd.CreateTodPalettes

    ; ##########################################
    ; Load background image
    LD D, "0"
    LD E, "6"
    PUSH DE
    CALL fi.LoadBgImageFile
    POP DE

    ; ##########################################
    ; Load tile map. DE is set to level number
    PUSH DE
    CALL fi.LoadPlatformsTilemapFile 
    POP DE

    ; ##########################################
    ; Load tile map. DE is set to level number
    PUSH DE
    CALL fi.LoadRocketStarsTilemapFile
    POP DE

    ; ##########################################
    ; Load tile map. DE is set to level number
    CALL fi.LoadSpritesFile
    CALL sp.LoadSpritesFPGA

    ; ##########################################
    ; Setup Platforms
    CALL dbs.SetupArraysBank
    LD HL, dba.platformsL6
    LD A, (dba.platformsSizeL6)
    CALL pl.SetupPlatforms

    ; ##########################################
    ; Load stars
    CALL dbs.SetupArraysBank
    LD DE, dbs.starsData1MaxYL6
    LD HL, dbs.starsData2MaxYL6
    CALL st.SetupStars

    ; ##########################################
    ; Load rocket
    CALL dbs.SetupArraysBank
    LD HL, dba.rocketElL6
    LD A, (dba.rocketAssemblyXL6)
    CALL ro.SetupRocket

    ; ##########################################
    ; Load single enemies
    CALL dbs.SetupEnemyBank
    LD A, ena.SINGLE_ENEMIES_L6
    LD IX, ena.singleEnemiesL6
    LD B, ens.NEXT_RESP_DEL
    CALL ens.SetupSingleEnemies

    ; ##########################################
    ; Load formation
    CALL dbs.SetupEnemyBank
    LD A, 0
    LD IX, ena.enemyFormationL6
    CALL enf.SetupEnemyFormation

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   LoadLevel7Data                         ;
;----------------------------------------------------------;
LoadLevel7Data

    ; Load palettes
    CALL dbs.SetupPaletteBank

    ; Load palette size into a global variable
    LD HL, db.bgrL7PaletteBytes
    LD (btd.palBytes), HL

    ; Load the address of the original palette into a global variable
    LD HL, db.bgrL7PaletteAdr
    LD (btd.palAdr), HL

    CALL btd.CreateTodPalettes

    ; ##########################################
    ; Load background image
    LD D, "0"
    LD E, "7"
    PUSH DE
    CALL fi.LoadBgImageFile
    POP DE

    ; ##########################################
    ; Load tile map. DE is set to level number
    PUSH DE
    CALL fi.LoadPlatformsTilemapFile 
    POP DE

    ; ##########################################
    ; Load tile map. DE is set to level number
    PUSH DE
    CALL fi.LoadRocketStarsTilemapFile
    POP DE

    ; ##########################################
    ; Load tile map. DE is set to level number
    CALL fi.LoadSpritesFile
    CALL sp.LoadSpritesFPGA

    ; ##########################################
    ; Setup Platforms
    CALL dbs.SetupArraysBank
    LD HL, dba.platformsL7
    LD A, (dba.platformsSizeL7)
    CALL pl.SetupPlatforms

    ; ##########################################
    ; Load stars
    CALL dbs.SetupArraysBank
    LD DE, dbs.starsData1MaxYL7
    LD HL, dbs.starsData2MaxYL7
    CALL st.SetupStars

    ; ##########################################
    ; Load rocket
    CALL dbs.SetupArraysBank
    LD HL, dba.rocketElL7
    LD A, (dba.rocketAssemblyXL7)
    CALL ro.SetupRocket

    ; ##########################################
    ; Load single enemies
    CALL dbs.SetupEnemyBank
    LD A, ena.SINGLE_ENEMIES_L7
    LD IX, ena.singleEnemiesL7
    LD B, ens.NEXT_RESP_DEL
    CALL ens.SetupSingleEnemies

    ; ##########################################
    ; Load formation
    CALL dbs.SetupEnemyBank
    LD A, 100
    LD IX, ena.enemyFormationL7
    CALL enf.SetupEnemyFormation

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   LoadLevel8Data                         ;
;----------------------------------------------------------;
LoadLevel8Data

    ; Load palettes
    CALL dbs.SetupPaletteBank
    
    ; Load palette size into a global variable
    LD HL, db.bgrL8PaletteBytes
    LD (btd.palBytes), HL

    ; Load the address of the original palette into a global variable
    LD HL, db.bgrL8PaletteAdr
    LD (btd.palAdr), HL

    CALL btd.CreateTodPalettes

    ; ##########################################
    ; Load background image
    LD D, "0"
    LD E, "8"
    PUSH DE
    CALL fi.LoadBgImageFile
    POP DE

    ; ##########################################
    ; Load tile map. DE is set to level number
    PUSH DE
    CALL fi.LoadPlatformsTilemapFile 
    POP DE

    ; ##########################################
    ; Load tile map. DE is set to level number
    PUSH DE
    CALL fi.LoadRocketStarsTilemapFile
    POP DE

    ; ##########################################
    ; Load tile map. DE is set to level number
    CALL fi.LoadSpritesFile
    CALL sp.LoadSpritesFPGA

    ; ##########################################
    ; Setup Platforms
    CALL dbs.SetupArraysBank
    LD HL, dba.platformsL8
    LD A, (dba.platformsSizeL8)
    CALL pl.SetupPlatforms

    ; ##########################################
    ; Load stars
    CALL dbs.SetupArraysBank
    LD DE, dbs.starsData1MaxYL8
    LD HL, dbs.starsData2MaxYL8
    CALL st.SetupStars

    ; ##########################################
    ; Load rocket
    CALL dbs.SetupArraysBank
    LD HL, dba.rocketElL8
    LD A, (dba.rocketAssemblyXL8)
    CALL ro.SetupRocket
    
    ; ##########################################
    ; Load single enemies
    CALL dbs.SetupEnemyBank
    LD A, ena.SINGLE_ENEMIES_L8
    LD IX, ena.singleEnemiesL8
    LD B, ens.NEXT_RESP_DEL
    CALL ens.SetupSingleEnemies

    ; ##########################################
    ; Load formation
    CALL dbs.SetupEnemyBank
    LD A, 0
    LD IX, ena.enemyFormationL8
    CALL enf.SetupEnemyFormation

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   LoadLevel9Data                         ;
;----------------------------------------------------------;
LoadLevel9Data

    ; Load palettes
    CALL dbs.SetupPaletteBank

    ; Load palette size into a global variable
    LD HL, db.bgrL9PaletteBytes
    LD (btd.palBytes), HL

    ; Load the address of the original palette into a global variable
    LD HL, db.bgrL9PaletteAdr
    LD (btd.palAdr), HL

    CALL btd.CreateTodPalettes

    ; ##########################################
    ; Load background image
    LD D, "0"
    LD E, "9"
    PUSH DE
    CALL fi.LoadBgImageFile
    POP DE

    ; ##########################################
    ; Load tile map. DE is set to level number
    PUSH DE
    CALL fi.LoadPlatformsTilemapFile 
    POP DE

    ; ##########################################
    ; Load tile map. DE is set to level number
    PUSH DE
    CALL fi.LoadRocketStarsTilemapFile
    POP DE

    ; ##########################################
    ; Load tile map. DE is set to level number
    CALL fi.LoadSpritesFile
    CALL sp.LoadSpritesFPGA

    ; ##########################################
    ; Setup Platforms
    CALL dbs.SetupArraysBank
    LD HL, dba.platformsL9
    LD A, (dba.platformsSizeL9)
    CALL pl.SetupPlatforms

    ; ##########################################
    ; Load stars
    CALL dbs.SetupArraysBank
    LD DE, dbs.starsData1MaxYL9
    LD HL, dbs.starsData2MaxYL9
    CALL st.SetupStars

    ; ##########################################
    ; Load rocket
    CALL dbs.SetupArraysBank
    LD HL, dba.rocketElL9
    LD A, (dba.rocketAssemblyXL9)
    CALL ro.SetupRocket

    ; ##########################################
    ; Load single enemies
    CALL dbs.SetupEnemyBank
    LD A, ena.SINGLE_ENEMIES_L9
    LD IX, ena.singleEnemiesL9
    LD B, ens.NEXT_RESP_DEL
    CALL ens.SetupSingleEnemies

    ; ##########################################
    ; Load formation
    CALL dbs.SetupEnemyBank
    LD A, 0
    LD IX, ena.enemyFormationL9
    CALL enf.SetupEnemyFormation

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   LoadLevel10Data                        ;
;----------------------------------------------------------;
LoadLevel10Data

    CALL dbs.SetupPaletteBank

    ; Load palette size into a global variable
    LD HL, db.bgrL10PaletteBytes
    LD (btd.palBytes), HL

    ; Load the address of the original palette into a global variable
    LD HL, db.bgrL10PaletteAdr
    LD (btd.palAdr), HL

    CALL btd.CreateTodPalettes

    ; ##########################################
    ; Load background image
    LD D, "1"
    LD E, "0"
    PUSH DE
    CALL fi.LoadBgImageFile
    POP DE

    ; ##########################################
    ; Load tile map. DE is set to level number
    PUSH DE
    CALL fi.LoadPlatformsTilemapFile 
    POP DE

    ; ##########################################
    ; Load tile map. DE is set to level number
    PUSH DE
    CALL fi.LoadRocketStarsTilemapFile
    POP DE

    ; ##########################################
    ; Load tile map. DE is set to level number
    CALL fi.LoadSpritesFile
    CALL sp.LoadSpritesFPGA

    ; ##########################################
    ; Setup Platforms
    CALL dbs.SetupArraysBank
    LD HL, dba.platformsL10
    LD A, (dba.platformsSizeL10)
    CALL pl.SetupPlatforms

    ; ##########################################
    ; Load stars
    CALL dbs.SetupArraysBank
    LD DE, dbs.starsData1MaxYL10
    LD HL, dbs.starsData2MaxYL10
    CALL st.SetupStars

    ; ##########################################
    ; Load rocket
    CALL dbs.SetupArraysBank
    LD HL, dba.rocketElL10
    LD A, (dba.rocketAssemblyXL10)
    CALL ro.SetupRocket

    ; ##########################################
    ; Load single enemies
    CALL dbs.SetupEnemyBank
    LD A, ena.SINGLE_ENEMIES_L10
    LD IX, ena.singleEnemiesL10
    LD B, ens.NEXT_RESP_DEL
    CALL ens.SetupSingleEnemies

    ; ##########################################
    ; Load formation
    CALL dbs.SetupEnemyBank
    LD A, 0
    LD IX, ena.enemyFormationL10
    CALL enf.SetupEnemyFormation

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE
