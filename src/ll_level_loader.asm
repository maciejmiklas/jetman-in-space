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
    CALL _LoadDataByLevelNumber

    ; ##########################################
    ; Setup Platforms
    CALL dbs.SetupArrays2Bank
    LD HL, db2.platformsL1
    LD A, (db2.platformsSizeL1)
    CALL pl.SetupPlatforms

    ; ##########################################
    ; Load stars
    CALL dbs.SetupArrays2Bank
    LD DE, db1.starsData1MaxYL1
    LD HL, db1.starsData2MaxYL1
    CALL st.SetupStars

    ; ##########################################
    ; Load rocket
    CALL dbs.SetupArrays2Bank
    LD HL, db2.rocketElL1
    LD A, (db2.rocketAssemblyXL1)
    CALL ro.SetupRocket

    ; ##########################################
    ; Load single enemies
    CALL dbs.SetupPatternEnemyBank
    LD A, ena.SINGLE_ENEMIES_L1
    LD IX, ena.singleEnemiesL1
    LD B, ens.NEXT_RESP_DEL
    CALL ens.SetupSingleEnemies

    ; ##########################################
    ; Load formation
    CALL dbs.SetupPatternEnemyBank
    XOR A                                       ; Disable formation
    CALL enf.SetupEnemyFormation

    ; ##########################################
    ; Load following enemies
    CALL dbs.SetupFollowingEnemyBank
    CALL fe.DisableFollowingEnemies

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
    CALL _LoadDataByLevelNumber

    ; ##########################################
    ; Setup Platforms
    CALL dbs.SetupArrays2Bank
    LD HL, db2.platformsL2
    LD A, (db2.platformsSizeL2)
    CALL pl.SetupPlatforms

    ; ##########################################
    ; Load stars
    CALL dbs.SetupArrays2Bank
    LD DE, db1.starsData1MaxYL2
    LD HL, db1.starsData2MaxYL2
    CALL st.SetupStars

    ; ##########################################
    ; Load rocket
    CALL dbs.SetupArrays2Bank
    LD HL, db2.rocketElL2
    LD A, (db2.rocketAssemblyXL2)
    CALL ro.SetupRocket

    ; ##########################################
    ; Load single enemies
    CALL dbs.SetupPatternEnemyBank
    LD A, ena.SINGLE_ENEMIES_L2
    LD IX, ena.singleEnemiesL2
    LD B, ens.NEXT_RESP_DEL
    CALL ens.SetupSingleEnemies

    ; ##########################################
    ; Load formation
    CALL dbs.SetupPatternEnemyBank
    XOR A                                       ; Disable formation
    CALL enf.SetupEnemyFormation

    ; ##########################################
    ; Load following enemies
    CALL dbs.SetupFollowingEnemyBank
    CALL fe.DisableFollowingEnemies

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
    CALL _LoadDataByLevelNumber

    ; ##########################################
    ; Setup Platforms
    CALL dbs.SetupArrays2Bank
    LD HL, db2.platformsL3
    LD A, (db2.platformsSizeL3)
    CALL pl.SetupPlatforms

    ; ##########################################
    ; Load stars
    CALL dbs.SetupArrays2Bank
    LD DE, db1.starsData1MaxYL3
    LD HL, db1.starsData2MaxYL3
    CALL st.SetupStars

    ; ##########################################
    ; Load rocket
    CALL dbs.SetupArrays2Bank
    LD HL, db2.rocketElL3
    LD A, (db2.rocketAssemblyXL3)
    CALL ro.SetupRocket

    ; ##########################################
    ; Load single enemies
    CALL dbs.SetupPatternEnemyBank
    LD A, ena.SINGLE_ENEMIES_L3
    LD B, ens.NEXT_RESP_DEL
    LD IX, ena.singleEnemiesL3
    CALL ens.SetupSingleEnemies

    ; ##########################################
    ; Load formation
    CALL dbs.SetupPatternEnemyBank
    LD A, ena.ENEMY_FORMATION_SIZE
    LD B, 150
    LD IX, ena.enemyFormationL3
    CALL enf.SetupEnemyFormation

    ; ##########################################
    ; Load following enemies
    CALL dbs.SetupFollowingEnemyBank
    CALL fe.DisableFollowingEnemies

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
    CALL _LoadDataByLevelNumber

    ; ##########################################
    ; Setup Platforms
    CALL dbs.SetupArrays2Bank
    LD HL, db2.platformsL4
    LD A, (db2.platformsSizeL4)
    CALL pl.SetupPlatforms

    ; ##########################################
    ; Load stars
    CALL dbs.SetupArrays2Bank
    LD DE, db1.starsData1MaxYL4
    LD HL, db1.starsData2MaxYL4
    CALL st.SetupStars

    ; ##########################################
    ; Load rocket
    CALL dbs.SetupArrays2Bank
    LD HL, db2.rocketElL4
    LD A, (db2.rocketAssemblyXL4)
    CALL ro.SetupRocket

    ; ##########################################
    ; Load single enemies
    CALL dbs.SetupPatternEnemyBank
    LD A, ena.SINGLE_ENEMIES_L4
    LD IX, ena.singleEnemiesL4
    LD B, ens.NEXT_RESP_DEL
    CALL ens.SetupSingleEnemies

    ; ##########################################
    ; Load formation
    CALL dbs.SetupPatternEnemyBank
    LD A, ena.ENEMY_FORMATION_SIZE
    LD B, 100
    LD IX, ena.enemyFormationL4
    CALL enf.SetupEnemyFormation

    ; ##########################################
    ; Load following enemies
    CALL dbs.SetupFollowingEnemyBank
    CALL fe.DisableFollowingEnemies

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
    CALL _LoadDataByLevelNumber

    ; ##########################################
    ; Setup Platforms
    CALL dbs.SetupArrays2Bank
    LD HL, db2.platformsL5
    LD A, (db2.platformsSizeL5)
    CALL pl.SetupPlatforms

    ; ##########################################
    ; Load stars
    CALL dbs.SetupArrays2Bank
    LD DE, db1.starsData1MaxYL5
    LD HL, db1.starsData2MaxYL5
    CALL st.SetupStars

    ; ##########################################
    ; Load rocket
    CALL dbs.SetupArrays2Bank
    LD HL, db2.rocketElL5
    LD A, (db2.rocketAssemblyXL5)
    CALL ro.SetupRocket

    ; ##########################################
    ; Load single enemies
    CALL dbs.SetupPatternEnemyBank
    LD A, ena.SINGLE_ENEMIES_L5
    LD IX, ena.singleEnemiesL5
    LD B, ens.NEXT_RESP_DEL
    CALL ens.SetupSingleEnemies

    ; ##########################################
    ; Load formation
    CALL dbs.SetupPatternEnemyBank
    XOR A
    CALL enf.SetupEnemyFormation

    ; ##########################################
    ; Load following enemies
    CALL dbs.SetupFollowingEnemyBank
    CALL fe.DisableFollowingEnemies

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
    CALL _LoadDataByLevelNumber

    ; ##########################################
    ; Setup Platforms
    CALL dbs.SetupArrays2Bank
    LD HL, db2.platformsL6
    LD A, (db2.platformsSizeL6)
    CALL pl.SetupPlatforms

    ; ##########################################
    ; Load stars
    CALL dbs.SetupArrays2Bank
    LD DE, db1.starsData1MaxYL6
    LD HL, db1.starsData2MaxYL6
    CALL st.SetupStars

    ; ##########################################
    ; Load rocket
    CALL dbs.SetupArrays2Bank
    LD HL, db2.rocketElL6
    LD A, (db2.rocketAssemblyXL6)
    CALL ro.SetupRocket

    ; ##########################################
    ; Load single enemies
    CALL dbs.SetupPatternEnemyBank
    LD A, ena.SINGLE_ENEMIES_L6
    LD IX, ena.singleEnemiesL6
    LD B, ens.NEXT_RESP_DEL
    CALL ens.SetupSingleEnemies

    ; ##########################################
    ; Load formation
    CALL dbs.SetupPatternEnemyBank
    XOR A
    CALL enf.SetupEnemyFormation

    ; ##########################################
    ; Load following enemies
    CALL dbs.SetupFollowingEnemyBank
    CALL fe.DisableFollowingEnemies

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
    CALL _LoadDataByLevelNumber

    ; ##########################################
    ; Setup Platforms
    CALL dbs.SetupArrays2Bank
    LD HL, db2.platformsL7
    LD A, (db2.platformsSizeL7)
    CALL pl.SetupPlatforms

    ; ##########################################
    ; Load stars
    CALL dbs.SetupArrays2Bank
    LD DE, db1.starsData1MaxYL7
    LD HL, db1.starsData2MaxYL7
    CALL st.SetupStars

    ; ##########################################
    ; Load rocket
    CALL dbs.SetupArrays2Bank
    LD HL, db2.rocketElL7
    LD A, (db2.rocketAssemblyXL7)
    CALL ro.SetupRocket

    ; ##########################################
    ; Load single enemies
    CALL dbs.SetupPatternEnemyBank
    LD A, ena.SINGLE_ENEMIES_L7
    LD IX, ena.singleEnemiesL7
    LD B, ens.NEXT_RESP_DEL
    CALL ens.SetupSingleEnemies

    ; ##########################################
    ; Load formation
    CALL dbs.SetupPatternEnemyBank
    LD A, ena.ENEMY_FORMATION_SIZE
    LD B, 100
    LD IX, ena.enemyFormationL7
    CALL enf.SetupEnemyFormation

    ; ##########################################
    ; Load following enemies
    CALL dbs.SetupFollowingEnemyBank
    CALL fe.DisableFollowingEnemies

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
    CALL _LoadDataByLevelNumber

    ; ##########################################
    ; Setup Platforms
    CALL dbs.SetupArrays2Bank
    LD HL, db2.platformsL8
    LD A, (db2.platformsSizeL8)
    CALL pl.SetupPlatforms

    ; ##########################################
    ; Load stars
    CALL dbs.SetupArrays2Bank
    LD DE, db1.starsData1MaxYL8
    LD HL, db1.starsData2MaxYL8
    CALL st.SetupStars

    ; ##########################################
    ; Load rocket
    CALL dbs.SetupArrays2Bank
    LD HL, db2.rocketElL8
    LD A, (db2.rocketAssemblyXL8)
    CALL ro.SetupRocket
    
    ; ##########################################
    ; Load single enemies
    CALL dbs.SetupPatternEnemyBank
    LD A, 0
    CALL ens.SetupSingleEnemies

    ; ##########################################
    ; Load formation
    CALL dbs.SetupPatternEnemyBank
    XOR A
    CALL enf.SetupEnemyFormation

    ; ##########################################
    ; Load following enemies
    CALL dbs.SetupFollowingEnemyBank

    LD IX, fed.fEnemyL08
    LD A, fed.FENEMY_SIZE_L8
    CALL fe.SetupFollowingEnemies

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
    CALL _LoadDataByLevelNumber

    ; ##########################################
    ; Setup Platforms
    CALL dbs.SetupArrays2Bank
    LD HL, db2.platformsL9
    LD A, (db2.platformsSizeL9)
    CALL pl.SetupPlatforms

    ; ##########################################
    ; Load stars
    CALL dbs.SetupArrays2Bank
    LD DE, db1.starsData1MaxYL9
    LD HL, db1.starsData2MaxYL9
    CALL st.SetupStars

    ; ##########################################
    ; Load rocket
    CALL dbs.SetupArrays2Bank
    LD HL, db2.rocketElL9
    LD A, (db2.rocketAssemblyXL9)
    CALL ro.SetupRocket

    ; ##########################################
    ; Load single enemies
    CALL dbs.SetupPatternEnemyBank
    LD A, ena.SINGLE_ENEMIES_L9
    LD IX, ena.singleEnemiesL9
    LD B, ens.NEXT_RESP_DEL
    CALL ens.SetupSingleEnemies

    ; ##########################################
    ; Load formation
    CALL dbs.SetupPatternEnemyBank
    LD A, 0
    LD IX, ena.enemyFormationL9
    CALL enf.SetupEnemyFormation

    ; ##########################################
    ; Load following enemies
    CALL dbs.SetupFollowingEnemyBank
    CALL fe.DisableFollowingEnemies

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
    CALL _LoadDataByLevelNumber

    ; ##########################################
    ; Setup Platforms
    CALL dbs.SetupArrays2Bank
    LD HL, db2.platformsL10
    LD A, (db2.platformsSizeL10)
    CALL pl.SetupPlatforms

    ; ##########################################
    ; Load stars
    CALL dbs.SetupArrays2Bank
    LD DE, db1.starsData1MaxYL10
    LD HL, db1.starsData2MaxYL10
    CALL st.SetupStars

    ; ##########################################
    ; Load rocket
    CALL dbs.SetupArrays2Bank
    LD HL, db2.rocketElL10
    LD A, (db2.rocketAssemblyXL10)
    CALL ro.SetupRocket

    ; ##########################################
    ; Load single enemies
    CALL dbs.SetupPatternEnemyBank
    LD A, ena.SINGLE_ENEMIES_L10
    LD IX, ena.singleEnemiesL10
    LD B, ens.NEXT_RESP_DEL
    CALL ens.SetupSingleEnemies

    ; ##########################################
    ; Load formation
    CALL dbs.SetupPatternEnemyBank
    LD A, 0
    LD IX, ena.enemyFormationL10
    CALL enf.SetupEnemyFormation

    ; ##########################################
    ; Load following enemies
    CALL dbs.SetupFollowingEnemyBank
    CALL fe.DisableFollowingEnemies

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                _LoadDataByLevelNumber                    ;
;----------------------------------------------------------;
; Input:
;  - DE: Level number as ASCII, for example for level 4: D="0", E="4"
_LoadDataByLevelNumber

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
    ; Copy tile definitions (sprite file) to expected memory
    PUSH DE
    CALL fi.LoadTileSprFile
    POP DE

    ; ##########################################
    ; Load tile map. DE is set to level number
    CALL fi.LoadSpritesFile
    CALL sp.LoadSpritesFPGA

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE
