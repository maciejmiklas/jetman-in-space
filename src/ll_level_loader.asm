/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                      Level Loader                        ;
;----------------------------------------------------------;
    MODULE ll

currentLevel            DB _LEVEL_MIN_D1           ; Int value 1-10.
currentLevelStr         DW 0                    ; string value  01-10.

    STRUCT LL
LNUM                    DW                      ; Level number as a 2-char string.

; Stars
STARS_PAL               DB                      ; palette number, values from 0-3.
STARS_D1                DW                      ; Array containing max horizontal star position for each column (#SC) for Layer 1.
STARS_D2                DW                      ; Same as STARS_D1, but for Layer 2.

; Platforms
PLAT_SIZE               DB                      ; Platforms size.
PLAT_DATA               DW                      ; Pointer to #PLA array containing PLAT_SIZE elements.

; Rocket
ROC_X                   DB                      ; X coordinate for rocket assembly.
ROC_DATA                DW                      ; Array containing 9 #ro.RO elements.
ROC_ST_PAL              DW                      ; Pallete for rocket stars.

; Single enemies
SE_SIZE                 DB                      ; Number of single enemies (size of #ENPS).
SE_DEL                  DB                      ; Respawn delay for #nextRespDel.
SE_DATA                 DW                      ; Pointer to #ENPS array.

; Following enemies
FE_SIZE                 DB                      ; Number of following enemies.
FE_DATA                 DW

; Formation
FORM_SIZE               DB                      ; Size of the formation.
FORM_DEL                DB                      ; Delay to respawn the whole formation.
FORM_DATA               DW                      ; Pointer to setup (#ENPS).

; Tilemap animation
TIA_SIZE                DB                      ; Number of animation rows.
TIA_DATA                DW                      ; Pointer to a list containing pointers to concrete rows.

; Tilemap palette
TIP_SIZE                DB                      ; Number bytes to copy (each color takes two bytes).
TIP_DATA                DW                      ; Address of layer 2 palette data.

; Pickups
PIC_SIZE                DB                      ; Number of pickups.
PIC_DATA                DW                      ; Pointer to pickups array, each entry of #PI_SPR_XXX.

; Meteors
AD_DEP_DATA             DW                      ; Pointer to #asDeploy.
AS_MOV_DATA             DW                      ; Pointer to #randMov.
    ENDS

levels
;       LNUM  STARS_PAL STARS_D1               STARS_D2               PLAT_SIZE              PLAT_DATA         ROC_X             ROC_DATA         ROC_ST_PAL                 SE_NUM                  SE_DEL             SE_DATA               FE_SIZE             FE_DATA        FORM_SIZE                 FORM_DEL FORM_DATA              TIA_SIZE                  TIA_DATA                    TIP_SIZE             TIP_DATA             PIC_SIZE             PIC_DATA        AD_DEP_DATA    AS_MOV_DATA
    LL {"01", 0,        db1.starsData1MaxYL1,  db1.starsData2MaxYL1,  db2.PLATFORM_SIZE_L1,  db2.platformsL1,  rod.ROCKET_X_L1,  rod.rocketElL1,  db1.tilePaletteStars1Bin,  ena.SINGLE_ENEMIES_L1,  ens.NEXT_RESP_DEL, ena.singleEnemiesL1,  0,                  0,             0,                        0,       0,                     tad.TILEMAP_ANIM_ROWS_L1, tad.tilemapAnimationRowsL1, db1.TILE_PAL_SIZE_L1, db1.tilePalette1Bin, db2.PICKUPS_L1_SIZE, db2.pickupsL1, rotd.asDeploy1, rotd.randMov1}
    LL {"02", 1,        db1.starsData1MaxYL2,  db1.starsData2MaxYL2,  db2.PLATFORM_SIZE_L2,  db2.platformsL2,  rod.ROCKET_X_L2,  rod.rocketElL2,  db1.tilePaletteStars2Bin,  ena.SINGLE_ENEMIES_L2,  ens.NEXT_RESP_DEL, ena.singleEnemiesL2,  0,                  0,             0,                        0,       0,                     tad.TILEMAP_ANIM_ROWS_L2, tad.tilemapAnimationRowsL2, db1.TILE_PAL_SIZE_L1, db1.tilePalette1Bin, db2.PICKUPS_L2_SIZE, db2.pickupsL2, rotd.asDeploy2, rotd.randMov2}
    LL {"03", 2,        db1.starsData1MaxYL3,  db1.starsData2MaxYL3,  db2.PLATFORM_SIZE_L3,  db2.platformsL3,  rod.ROCKET_X_L3,  rod.rocketElL3,  db1.tilePaletteStars3Bin,  ena.SINGLE_ENEMIES_L3,  ens.NEXT_RESP_DEL, ena.singleEnemiesL3,  0,                  0,             ena.ENEMY_FORMATION_SIZE, 150,     ena.enemyFormationL3,  tad.TILEMAP_ANIM_ROWS_L3, tad.tilemapAnimationRowsL3, db1.TILE_PAL_SIZE_L1, db1.tilePalette1Bin, db2.PICKUPS_L3_SIZE, db2.pickupsL3, rotd.asDeploy3, rotd.randMov3}
    LL {"04", 3,        db1.starsData1MaxYL4,  db1.starsData2MaxYL4,  db2.PLATFORM_SIZE_L4,  db2.platformsL4,  rod.ROCKET_X_L4,  rod.rocketElL4,  db1.tilePaletteStars4Bin,  ena.SINGLE_ENEMIES_L4,  ens.NEXT_RESP_DEL, ena.singleEnemiesL4,  0,                  0,             ena.ENEMY_FORMATION_SIZE, 100,     ena.enemyFormationL4,  0,                        0,                          db1.TILE_PAL_SIZE_L1, db1.tilePalette1Bin, db2.PICKUPS_L4_SIZE, db2.pickupsL4, rotd.asDeploy4, rotd.randMov4}
    LL {"05", 0,        db1.starsData1MaxYL5,  db1.starsData2MaxYL5,  db2.PLATFORM_SIZE_L5,  db2.platformsL5,  rod.ROCKET_X_L5,  rod.rocketElL5,  db1.tilePaletteStars5Bin,  ena.SINGLE_ENEMIES_L5,  ens.NEXT_RESP_DEL, ena.singleEnemiesL5,  0,                  0,             0,                        0,       0,                     tad.TILEMAP_ANIM_ROWS_L5, tad.tilemapAnimationRowsL5, db1.TILE_PAL_SIZE_L2, db1.tilePalette2Bin, db2.PICKUPS_L5_SIZE, db2.pickupsL5, rotd.asDeploy1, rotd.randMov1}
    LL {"06", 1,        db1.starsData1MaxYL6,  db1.starsData2MaxYL6,  db2.PLATFORM_SIZE_L6,  db2.platformsL6,  rod.ROCKET_X_L6,  rod.rocketElL6,  db1.tilePaletteStars6Bin,  ena.SINGLE_ENEMIES_L6,  ens.NEXT_RESP_DEL, ena.singleEnemiesL6,  0,                  0,             0,                        0,       0,                     tad.TILEMAP_ANIM_ROWS_L6, tad.tilemapAnimationRowsL6, db1.TILE_PAL_SIZE_L2, db1.tilePalette2Bin, db2.PICKUPS_L6_SIZE, db2.pickupsL6, rotd.asDeploy2, rotd.randMov2}
    LL {"07", 2,        db1.starsData1MaxYL7,  db1.starsData2MaxYL7,  db2.PLATFORM_SIZE_L7,  db2.platformsL7,  rod.ROCKET_X_L7,  rod.rocketElL7,  db1.tilePaletteStars7Bin,  ena.SINGLE_ENEMIES_L7,  ens.NEXT_RESP_DEL, ena.singleEnemiesL7,  0,                  0,             ena.ENEMY_FORMATION_SIZE, 100,     ena.enemyFormationL7,  0,                        0,                          db1.TILE_PAL_SIZE_L1, db1.tilePalette1Bin, db2.PICKUPS_L6_SIZE, db2.pickupsL6, rotd.asDeploy3, rotd.randMov3}
    LL {"08", 3,        db1.starsData1MaxYL8,  db1.starsData2MaxYL8,  db2.PLATFORM_SIZE_L8,  db2.platformsL8,  rod.ROCKET_X_L8,  rod.rocketElL8,  db1.tilePaletteStars8Bin,  0,                      0,                 0,                    fed.FENEMY_SIZE_L8, fed.fEnemyL08, 0,                        0,       0,                     tad.TILEMAP_ANIM_ROWS_L8, tad.tilemapAnimationRowsL8, db1.TILE_PAL_SIZE_L3, db1.tilePalette3Bin, db2.PICKUPS_L6_SIZE, db2.pickupsL6, rotd.asDeploy4, rotd.randMov4}
    LL {"09", 0,        db1.starsData1MaxYL9,  db1.starsData2MaxYL9,  db2.PLATFORM_SIZE_L9,  db2.platformsL9,  rod.ROCKET_X_L9,  rod.rocketElL9,  db1.tilePaletteStars9Bin,  ena.SINGLE_ENEMIES_L9,  ens.NEXT_RESP_DEL, ena.singleEnemiesL9,  fed.FENEMY_SIZE_L8, fed.fEnemyL08, ena.ENEMY_FORMATION_SIZE, 0,       ena.enemyFormationL9,  tad.TILEMAP_ANIM_ROWS_L8, tad.tilemapAnimationRowsL8, db1.TILE_PAL_SIZE_L1, db1.tilePalette1Bin, db2.PICKUPS_L6_SIZE, db2.pickupsL6, rotd.asDeploy3, rotd.randMov3}
    LL {"10", 1,        db1.starsData1MaxYL10, db1.starsData2MaxYL10, db2.PLATFORM_SIZE_L10, db2.platformsL10, rod.ROCKET_X_L10, rod.rocketElL10, db1.tilePaletteStars10Bin, ena.SINGLE_ENEMIES_L10, ens.NEXT_RESP_DEL, ena.singleEnemiesL10, fed.FENEMY_SIZE_L8, fed.fEnemyL08, ena.ENEMY_FORMATION_SIZE, 0,       ena.enemyFormationL10, tad.TILEMAP_ANIM_ROWS_L8, tad.tilemapAnimationRowsL8, db1.TILE_PAL_SIZE_L1, db1.tilePalette1Bin, db2.PICKUPS_L6_SIZE, db2.pickupsL6, rotd.asDeploy1, rotd.randMov1}

tilePaletteStarsAddr    DW 0


;----------------------------------------------------------;
;----------------------------------------------------------;
;                     PRIVATE MACROS                       ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                _LoadDataByLevelNumber                    ;
;----------------------------------------------------------;
; Input:
;  - DE: Level number as ASCII, for example for level 4: D="0", E="4"
    MACRO _LoadDataByLevelNumber

    LD (jt.levelNumber), DE

    PUSH DE
    CALL fi.LoadBgImageFile
    POP DE

    ; ##########################################
    ; Load platform tile map. DE is set to level number
    PUSH DE
    CALL fi.LoadPlatformsTilemapFile
    POP DE

    ; ##########################################
    ; Load stars tile map. DE is set to level number
    PUSH DE
    CALL fi.LoadRocketStarsTilemapFile
    POP DE

    ; ##########################################
    ; Copy tile definitions (sprite file) to expected memory
    PUSH DE
    CALL fi.LoadTilePlatformsSprFile
    POP DE

    ; ##########################################
    ; Load sprites. DE is set to level number
    PUSH DE
    CALL fi.LoadSpritesFile
    CALL sp.LoadSpritesFPGA
    POP DE

    ; ##########################################
    ; Load palettes
    CALL fi.LoadBgPaletteFile
    CALL btd.CreateTodPalettes

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PUBLIC FUNCTIONS                       ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                  LoadCurrentLevel                        ;
;----------------------------------------------------------;
LoadCurrentLevel

    ; Load the pointer to the current level data (LL) into IX.
    LD A, (currentLevel)
    DEC A
    LD D, A
    LD E, LL
    MUL D, E

    LD HL, levels
    ADD HL, DE
    LD IX, HL

    ; ##########################################
    ; Load stars
    PUSH IX
    CALL dbs.SetupArrays1Bank
    LD A, (IX + LL.STARS_PAL)
    LD DE, (IX + LL.STARS_D1)
    LD HL, (IX + LL.STARS_D2)
    CALL st.SetupStars
    POP IX

    ; ##########################################
    ; Load data for level
    PUSH IX
    LD DE, (IX + LL.LNUM)
    LD (currentLevelStr), DE
    _LoadDataByLevelNumber
    POP IX

    ; ##########################################
    ; Setup Platforms
    PUSH IX
    CALL dbs.SetupArrays2Bank
    LD HL, (IX + LL.PLAT_DATA)
    LD A, (IX + LL.PLAT_SIZE)
    CALL pl.SetupPlatforms
    POP IX

    ; ##########################################
    ; Load rocket
    PUSH IX
    CALL dbs.SetupRocketBank
    LD HL, (IX + LL.ROC_DATA)
    LD A, (IX + LL.ROC_X)
    CALL roa.SetupRocket
    POP IX

    ; ##########################################
    ; Meteors
    PUSH IX
    LD DE, (IX + LL.AD_DEP_DATA)
    LD HL, (IX + LL.AS_MOV_DATA)
    CALL rot.SetupMeteors
    POP IX
    
    ; ##########################################
    ; Load single enemies
    PUSH IX
    CALL dbs.SetupPatternEnemyBank
    LD A, (IX + LL.SE_SIZE)
    LD B,(IX + LL.SE_DEL)
    LD HL, (IX + LL.SE_DATA)
    LD IX, HL
    CALL ens.SetupSingleEnemies
    POP IX

    ; ##########################################
    ; Load formation
    PUSH IX
    CALL dbs.SetupPatternEnemyBank

    LD A, (IX + LL.FORM_SIZE)
    LD B, (IX + LL.FORM_DEL)
    LD HL, (IX + LL.FORM_DATA)
    LD IX, HL

    CALL enf.SetupEnemyFormation
    POP IX

    ; ##########################################
    ; Load following enemies
    PUSH IX
    CALL dbs.SetupFollowingEnemyBank

    LD A, (IX + LL.FE_SIZE)
    OR A                                        ; Same as CP 0, but faster.
    JR Z, .followingDisabled

    LD DE, (IX + LL.FE_DATA)
    LD IX, DE
    CALL fe.SetupFollowingEnemies
    JR .afterFollwing

.followingDisabled
    CALL fe.DisableFollowingEnemies

.afterFollwing
    POP IX

    ; ##########################################
    ; Load tile animation
    PUSH IX
    CALL dbs.SetupTileAnimationBank
    LD A, (IX + LL.TIA_SIZE)
    LD HL, (IX + LL.TIA_DATA)
    CALL ta.SetupTileAnimation
    POP IX

    ; ##########################################
    ; Load tilemap palette
    PUSH IX
    CALL dbs.SetupArrays1Bank
    LD HL, (IX + LL.TIP_DATA)
    LD B, (IX + LL.TIP_SIZE)
    CALL ti.LoadTilemap9bitPalette
    POP IX

    ; ##########################################
    ; Setup Pickups
    PUSH IX
    CALL dbs.SetupArrays2Bank
    LD A, (IX + LL.PIC_SIZE)
    LD DE, (IX + LL.PIC_DATA)
    CALL pi.SetupPickups
    POP IX

    ; ##########################################
    ; Rocket stars
    PUSH IX
    LD DE, (IX + LL.ROC_ST_PAL)
    LD (tilePaletteStarsAddr), DE
    POP IX

    RET                                         ; ## END of the function ##
    
;----------------------------------------------------------;
;                   LoadUnlockLevel                        ;
;----------------------------------------------------------;
; Return:
;  -A: Level number for current difficulty, 1-10.
LoadUnlockLevel

    ; The unlock level is stored for each difficulty, as 3 bytes in #unlockedLevel. #difLevel counts from 1 to 3, and we will use it to 
    ; calculate the offset to read the unlock level for the current difficulty.
    LD A, (jt.difLevel)
    DEC A                                       ; Diff level counts 1-3, for offset we need 0-2

    CALL dbs.SetupStorageBank
    LD DE, so.unlockedLevel
    ADD DE, A
    LD A, (DE)

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  ResetLevelPlaying                       ;
;----------------------------------------------------------;
ResetLevelPlaying

    LD A, _LEVEL_MIN_D1
    LD (currentLevel), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   SetLevelPlaying                        ;
;----------------------------------------------------------;
; Input:
;  -A: Level number, 1-10
SetLevelPlaying

    LD (currentLevel), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   UnlockNextLevel                        ;
;----------------------------------------------------------;
UnlockNextLevel

    ; Increment current level, or eventually reset it (10 -> 1).
    LD A, (currentLevel)
    INC A
    LD (currentLevel), A

    ; Player has finished the last level, restart at  1, but do not store the unlock level.
    CP _LEVEL_MAX_D10 + 1
    JR Z, .resetCurrentLevel

    ; ##########################################
    ; Update the unlock level
    PUSH AF
    CALL dbs.SetupStorageBank

    ; Move DE to the #unlockedLevel for the current difficulty level.
    LD DE, so.unlockedLevel

    LD A, (jt.difLevel)
    DEC A
    ADD DE, A                                   ; DE points to the current value with unlocked level

    ; Update unlocked level only if the new value is > than the current one.
    LD A, (DE)
    LD B, A
    POP AF
    ; Now, A contains the current level that the player has just finished, and B holds the unlocked level. 
    ; We have to make sure that we do not overwrite the unlocked level with a lower value.
    CP B
    RET C
    LD (DE), A
    RET

.resetCurrentLevel
    LD A, _LEVEL_MIN_D1
    LD (currentLevel), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE
