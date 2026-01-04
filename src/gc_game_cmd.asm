/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                      Game Command                        ;
;----------------------------------------------------------;
    MODULE gc

; Start times to change animations.
HOVER_START_D250        = 250
STAND_START_D30         = 30
JSTAND_START_D15        = 15

; Respawn location.
JM_RESPAWN_X_D100       = 100
JM_RESPAWN_Y_D217       = _GSC_JET_GND_D217     ; Jetman must respond by standing on the ground. Otherwise, the background will be off.

KILL_FEW                = 7

freezeEnemiesCnt        DW 0
FREEZE_ENEMIES_CNT      = 60 * 10               ; Freeze for 10 Seconds

FUEL_THIEF_ACTIVE_LEV   = 5

;----------------------------------------------------------;
;----------------------------------------------------------;
;                        MACROS                            ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                    _LoadLevel1Intro                      ;
;----------------------------------------------------------;
    MACRO _LoadLevel1Intro

    CALL gc._HideGame

    LD D, "0"
    LD E, "1"
    LD HL, 4048                                 ; Size of intro_1.map.
    LD A, 8192/80 + 4048/80                     ; Total number of lines in intro_0.map and intro_1.map.
    CALL li.LoadLevelIntro

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                     _HideEnemies                         ;
;----------------------------------------------------------;
    MACRO _HideEnemies

    ; Hide single enemies.
    CALL dbs.SetupPatternEnemyBank

    LD A, ena.ENEMY_SINGLE_SIZE
    LD IX, ena.singleEnemySprites
    CALL sr.HideAllSimpleSprites

    ; ##########################################
    ; Hide formation enemies.
    LD A, ena.ENEMY_FORMATION_SIZE
    LD IX, ena.formationEnemySprites
    CALL sr.HideAllSimpleSprites

    ; ##########################################
    ; Hide following enemies.
    CALL dbs.SetupFollowingEnemyBank
    
    LD A, fe.FOLLOWING_FENEMY_SIZE
    LD IX, fe.fEnemySprites
    CALL sr.HideAllSimpleSprites

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                      _StartLevel                         ;
;----------------------------------------------------------;
    MACRO _StartLevel

    LD A, ms.GAME_ACTIVE
    CALL ms.SetMainState

    CALL gb.ShowGameBar
    CALL sc.PrintScore

    CALL dbs.SetupRocketBank
    CALL roa.StartRocketAssembly

    CALL ti.ResetTilemapOffset
    CALL jo.ResetJetpackOverheating
    CALL jl.SetupLives

    LD A, ms.GAME_ACTIVE
    CALL ms.SetMainState

    ; Music on
    CALL dbs.SetupMusicBank
    CALL aml.NextGameSong

    ; Respawn Jetman as the last step, this will set the status to active, all procedures will run afterward and need correct data.
    CALL RespawnJet

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                    _InitLevelLoad                        ;
;----------------------------------------------------------;
    MACRO _InitLevelLoad

    CALL _HideGame
    CALL gi.ResetKeysState
    CALL td.ResetTimeOfDay

    CALL dbs.SetupRocketBank
    CALL ros.ResetRocketStars

    CALL dbs.SetupPatternEnemyBank
    CALL enu.EnableFuelThief

    CALL dbs.SetupTileAnimationBank
    CALL ta.DisableTileAnimation

    XOR A
    LD (freezeEnemiesCnt), A

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PUBLIC FUNCTIONS                       ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                gc.StartGameWithIntro                     ;
;----------------------------------------------------------;
    MACRO gc.StartGameWithIntro

    ; Music off
    CALL dbs.SetupMusicBank
    CALL aml.MusicOff

    ; Show intro only for the first level.
    LD A, (ll.currentLevel)
    CP _LEVEL_MIN
    JR Z, .intro
    CALL gc.LoadCurrentLevel
    JR .end

.intro
    CALL js.HideJetSprite
    CALL jt.SetJetStateInactive
    _LoadLevel1Intro

    ; Music on
    CALL dbs.SetupMusicBank
    LD A, aml.MUSIC_INTRO
    CALL aml.LoadSong
.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                       SetupSystem                        ;
;----------------------------------------------------------;
SetupSystem

    CALL bm.CreateEmptyImageBank
    CALL bm.HideImage
    CALL sc.SetupScreen
    CALL ti.SetupTiles

    ; Load tilemap menu palette.
    CALL dbs.SetupArrays1Bank
    LD HL, db1.tilePalette1Bin
    LD B, db1.TILE_PAL_SIZE_L1
    CALL ti.LoadTilemap9bitPalette

    ; Load sprites from any level for mein menu.
    LD D, "0"
    LD E, "1"
    CALL fi.LoadSpritesFile
    CALL sp.LoadSpritesFPGA

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      LoadMainMenu                        ;
;----------------------------------------------------------;
LoadMainMenu

    LD A, ms.MENU_MAIN
    CALL ms.SetMainState

    CALL _HideGame
    CALL sc.ResetScore
    CALL mma.LoadMainMenu
    CALL jl.ResetLives

    ; Load tilemap menu palette.
    CALL dbs.SetupArrays1Bank
    LD HL, db1.tilePalette1Bin
    LD B, db1.TILE_PAL_SIZE_L1
    CALL ti.LoadTilemap9bitPalette

    CALL sc.ResetClippings

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;               BackgroundPaletteLoaded                    ;
;----------------------------------------------------------;
BackgroundPaletteLoaded

    CALL st.LoadStarsPalette                    ; Call it after the level palette because the stars' colors are right after it.

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      LoadNextLevel                       ;
;----------------------------------------------------------;
LoadNextLevel

    CALL ll.UnlockNextLevel
    CALL LoadCurrentLevel

    CALL dbs.SetupRocketBank                    ; Function was called from this bank and must return there.

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   LoadCurrentLevel                       ;
;----------------------------------------------------------;
LoadCurrentLevel

    _InitLevelLoad
    CALL ll.LoadCurrentLevel
    _StartLevel

    LD A, (ll.currentLevel)
    CP FUEL_THIEF_ACTIVE_LEV
    RET NC

    CALL dbs.SetupPatternEnemyBank
    CALL enu.DisableFuelThief

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     FuelThiefHit                         ;
;----------------------------------------------------------;
FuelThiefHit

    CALL dbs.SetupAyFxsBank
    LD A, af.FX_EXPLODE_ENEMY_3
    CALL af.AfxPlay

    CALL sc.HitEnemy3

    CALL dbs.SetupPatternEnemyBank              ; Stack jumps back to enemy.

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  gc.DifficultyChange                     ;
;----------------------------------------------------------;
; Read curent dificluty from #jt.difLevel
    MACRO gc.DifficultyChange

    CALL ll.ResetLevelPlaying

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                       RocketReady                        ;
;----------------------------------------------------------;
RocketReady

    CALL dbs.SetupAyFxsBank
    LD A, af.FX_ROCKET_READY
    CALL af.AfxPlay

    CALL dbs.SetupRocketBank                    ; Function was called from this bank and must return there.

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  RocketFLyStartPhase1                    ;
;----------------------------------------------------------;
; See #ro.rocketFlyPhase
RocketFLyStartPhase1
    ; The dbs.SetupRocketBank is already set

    CALL rof.RocketFLyStartPhase1

    LD A, ms.FLY_ROCKET
    CALL ms.SetMainState

    CALL sc.BoardRocket
    CALL jt.SetJetStateInactive
    CALL js.HideJetSprite
    CALL gb.HideGameBar
    CALL dbs.SetupArrays2Bank
    CALL pi.ResetPickups
    CALL ki.ResetKeyboard
    CALL dbs.SetupPatternEnemyBank
    CALL enu.DisableFuelThief
    CALL jw.HideShots

    CALL dbs.SetupRocketBank                    ; Function was called from this bank and must return there.

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   RocketFLyStartPhase2                   ;
;----------------------------------------------------------;
; See #ro.rocketFlyPhase
; The dbs.SetupRocketBank is already set
RocketFLyStartPhase2

    CALL sc.SetClipTilesHorizontal
    CALL ti.ClearBottomTileLine

    CALL dbs.SetupRocketBank                    ; Code must return to rof_rocket_fly.asm

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  RocketFLyStartPhase4                    ;
;----------------------------------------------------------;
; See #ro.rocketFlyPhase
; The dbs.SetupRocketBank is already set
RocketFLyStartPhase4

    CALL ros.ResetRocketStars

    CALL ti.CleanAllTiles

    LD DE, (jt.levelNumber)
    PUSH DE
    CALL fi.LoadTileStarsSprFile
    POP DE

    CALL fi.LoadAsteroidsFile
    CALL sp.LoadSpritesFPGA

    ; Load tilemap palette
    CALL dbs.SetupArrays1Bank
    LD HL, (ll.tilePaletteStarsAddr)
    LD B, db1.STARS_PAL_BYTES
    CALL ti.LoadTilemap9bitPalette

    CALL sc.SetClipTop50

    CALL dbs.SetupRocketBank                    ; Function was called from this bank and must return there.

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   RocketFLyPhase2and3                    ;
;----------------------------------------------------------;
; The dbs.SetupRocketBank is already set
RocketFLyPhase2and3

    CALL ros.ScrollStarsOnFlyRocket
    CALL st.MoveFastStarsDown
    bg.UpdateBackgroundOnRocketMove
    CALL bg.HideBackgroundBehindHorizon

    CALL dbs.SetupRocketBank                    ; Function was called from this bank and must return there.

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    RocketFLyPhase4                       ;
;----------------------------------------------------------;
; The dbs.SetupRocketBank is already set
RocketFLyPhase4

    CALL ros.ScrollStarsOnFlyRocket
    CALL rot.CheckRocketCollision

    CALL st.MoveFastStarsDown

    CALL dbs.SetupRocketBank                    ; Function was called from this bank and must return there.

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     RocketTankHit                        ;
;----------------------------------------------------------;
RocketTankHit

    CALL sc.HitRocketTank

    CALL dbs.SetupAyFxsBank
    LD A, af.FX_EXPLODE_TANK
    CALL af.AfxPlay

    CALL dbs.SetupRocketBank                    ; Function was called from this bank and must return there.

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   RocketElementPickup                    ;
;----------------------------------------------------------;
RocketElementPickup

    CALL sc.PickupRocketElement

    ; ##########################################
    ; Play different FX depending on whether Jetman picks up the fuel tank or the rocket element.
    CALL dbs.SetupRocketBank
    CALL roa.IsFuelDeployed
    JR NZ, .notFuelTank

    CALL dbs.SetupAyFxsBank
    LD A, af.FX_PICKUP_FUEL
    CALL af.AfxPlay
    JR .afterFuelFx
.notFuelTank

    CALL dbs.SetupAyFxsBank
    LD A, af.FX_PICKUP_ROCKET_EL
    CALL af.AfxPlay
.afterFuelFx

    CALL dbs.SetupRocketBank                    ; Function was called from this bank and must return there.

    RET                                         ; ## END of the function ## 

;----------------------------------------------------------;
;                RocketElementPickupInAir                  ;
;----------------------------------------------------------;
RocketElementPickupInAir
    
    CALL sc.PickupRocketElementInAir

    CALL dbs.SetupRocketBank                    ; Function was called from this bank and must return there.

    RET                                         ; ## END of the function ## 

;----------------------------------------------------------;
;                    RocketExpolodes                       ;
;----------------------------------------------------------;
RocketExpolodes

    CALL dbs.SetupAyFxsBank
    LD A, af.FX_EXPLODE_ENEMY_2
    CALL af.AfxPlay

    CALL dbs.SetupRocketBank                    ; Function was called from this bank and must return there.


    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    PlayRocketSound                       ;
;----------------------------------------------------------;
PlayRocketSound

    CALL dbs.SetupAyFxsBank
    LD A, af.FX_ROCKET_FLY
    CALL af.AfxPlay

    CALL dbs.SetupRocketBank                    ; Function was called from this bank and must return there.

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   RocketElementDrop                      ;
;----------------------------------------------------------;
RocketElementDrop

    CALL sc.DropRocketElement

    CALL dbs.SetupAyFxsBank
    LD A, af.FX_ROCKET_EL_DROP
    CALL af.AfxPlay

    CALL dbs.SetupRocketBank                    ; Function was called from this bank and must return there.

    RET                                         ; ## END of the function ## 

;----------------------------------------------------------;
;                   gc.JetPlatformTakesOff                 ;
;----------------------------------------------------------;
    MACRO gc.JetPlatformTakesOff

    ; Transition from walking to flaying.
    LD A, (jt.jetGnd)
    CP jt.JT_STATE_INACTIVE                     ; Check if Jetman is on the ground/platform.
    JR Z, .end

    ; Jetman is taking off.
    LD A, jt.AIR_FLY
    CALL jt.SetJetStateAir

    ; Play takeoff animation.
    LD A, js.SDB_T_WF
    CALL js.ChangeJetSpritePattern

    ; Not walking on platform anymore.
    LD A, pl.PLATFORM_WALK_INACTIVE
    LD (pl.platformWalkNumber), A

    CALL js.ChangeJetSpriteOnFlyUp

    ; Play FX
    CALL dbs.SetupAyFxsBank
    LD A, af.FX_JET_TAKE_OFF
    CALL af.AfxPlay

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                 gc.PlatformWeaponHit                     ;
;----------------------------------------------------------;
    MACRO gc.PlatformWeaponHit

    CALL dbs.SetupAyFxsBank
    LD A, af.FX_FIRE_PLATFORM_HIT
    CALL af.AfxPlay

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                 gc.PlayFuelThiefFx                       ;
;----------------------------------------------------------;
    MACRO gc.PlayFuelThiefFx

    CALL dbs.SetupPatternEnemyBank
    LD A, (enu.thiefState)

    CP enu.TS_DEPLOYING
    JR Z, .play
    CP enu.TS_RUNS_EMPTY
    JR NZ, .end
.play

    ; Play FX
    CALL dbs.SetupAyFxsBank
    LD A, af.FX_THIEF
    CALL af.AfxPlay

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                    gc.WeaponHitEnemy                     ;
;----------------------------------------------------------;
    MACRO gc.WeaponHitEnemy

    CALL dbs.SetupArrays2Bank

    ; ##########################################
    CALL dbs.SetupPatternEnemyBank

    LD A, (ens.singleEnemySize)
    LD IX, ena.singleEnemySprites
    CALL jw.CheckHitEnemies

    ; ##########################################
    LD A, ena.ENEMY_FORMATION_SIZE
    LD IX, ena.formationEnemySprites
    CALL jw.CheckHitEnemies

    ; ##########################################
    CALL dbs.SetupFollowingEnemyBank

    LD IX, fe.fEnemySprites
    LD A, (fe.fEnemySize)
    CALL jw.CheckHitEnemies

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                   RocketHitsAsteroid                     ;
;----------------------------------------------------------;
RocketHitsAsteroid

    CALL rof.StartRocketExplosion

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     AnimateEnemies                       ;
;----------------------------------------------------------;
AnimateEnemies

    ; Animate single enemy
    CALL dbs.SetupPatternEnemyBank

    LD A, (ens.singleEnemySize)
    LD IX, ena.singleEnemySprites
    CALL sr.AnimateSprites

    ; ##########################################
    ; Animate formation enemy
    LD A, ena.ENEMY_FORMATION_SIZE
    LD IX, ena.formationEnemySprites
    CALL sr.AnimateSprites

    ; ##########################################
    CALL dbs.SetupFollowingEnemyBank

    LD A, (fe.fEnemySize)
    LD IX, fe.fEnemySprites
    CALL sr.AnimateSprites

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      KillOneEnemy                        ;
;----------------------------------------------------------;
KillOneEnemy

    ; Kill single enemy
    CALL dbs.SetupPatternEnemyBank
    LD A, (ens.singleEnemySize)
    LD IX, ena.singleEnemySprites
    CALL sr.KillOneSprite

    ; ##########################################
    ; Kill formation enemy
    LD A, ena.ENEMY_FORMATION_SIZE
    LD IX, ena.formationEnemySprites
    CALL sr.KillOneSprite

    ; ##########################################
    ; Kill following enemy
    CALL dbs.SetupFollowingEnemyBank

    LD A, (fe.fEnemySize)
    LD IX, fe.fEnemySprites
    CALL sr.KillOneSprite

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;               gc.JetmanEnemiesCollision                  ;
;----------------------------------------------------------;
    MACRO gc.JetmanEnemiesCollision

    CALL dbs.SetupArrays2Bank

    ; ##########################################
    CALL dbs.SetupPatternEnemyBank

    LD A, (ens.singleEnemySize)
    LD IX, ena.singleEnemySprites
    CALL jco.EnemiesCollision

    ; ##########################################
    LD A, ena.ENEMY_FORMATION_SIZE
    LD IX, ena.formationEnemySprites
    CALL jco.EnemiesCollision

    ; ##########################################
    CALL dbs.SetupFollowingEnemyBank

    LD A, (fe.fEnemySize)
    LD IX, fe.fEnemySprites
    CALL jco.EnemiesCollision

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                     KillFewEnemies                       ;
;----------------------------------------------------------;
KillFewEnemies

    LD B, KILL_FEW
.killLoop
    PUSH BC

    CALL KillOneEnemy

    POP BC
    DJNZ .killLoop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    gc.EnemyHit                           ;
;----------------------------------------------------------;
; Input
;    A:  Sprite ID of the enemy.
;  - IX: Pointer to enemy's #SPR.
    MACRO gc.EnemyHit

    CALL dbs.SetupArrays2Bank

    CALL sr.SpriteHit

   
    ; Checkt what enemy has been hit.

    ; ##########################################
    ; Enemy 1?
    LD A, (IX + SPR.SDB_INIT)
    CP sr.SDB_ENEMY1
    JR NZ, .afterHitEnemy1

    ; Yes, enemy 1 hot git.
    CALL dbs.SetupAyFxsBank
    LD A, af.FX_EXPLODE_ENEMY_1
    CALL af.AfxPlay

    CALL sc.HitEnemy1

    JR .end
.afterHitEnemy1

     ; ##########################################
    ; Enemy 2?
    LD A, (IX + SPR.SDB_INIT)
    CP sr.SDB_ENEMY2
    JR NZ, .afterHitEnemy2

    ; Yes, enemy 2 hot git.
    CALL dbs.SetupAyFxsBank
    LD A, af.FX_EXPLODE_ENEMY_2
    CALL af.AfxPlay

    CALL sc.HitEnemy2
    JR .end

.afterHitEnemy2

    ; ##########################################
    ; Enemy 3/1A?
    LD A, (IX + SPR.SDB_INIT)
    CP sr.SDB_ENEMY3
    JR Z, .hit3

    CP sr.SDB_ENEMY1A 
    JR NZ, .end

.hit3
    ; Yes, enemy 3 hot git.
    CALL dbs.SetupAyFxsBank
    LD A, af.FX_EXPLODE_ENEMY_3
    CALL af.AfxPlay

    CALL sc.HitEnemy3

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                   gc.EnemyHitsJet                        ;
;----------------------------------------------------------;
; Input
;  - IX:    Pointer enemy's #SPR
    MACRO gc.EnemyHitsJet

    CALL dbs.SetupArrays2Bank
    
    ; Destroy the enemy.
    CALL sr.SpriteHit

    ; ##########################################
    ; Is Jetman already dying? If so, do not start the RiP sequence again, just kill the enemy.
    LD A, (jt.jetState)
    CP jt.JETST_RIP
    JR Z, .end                                  ; Exit if RIP.

    ; ##########################################
    ; Is Jetman invincible? If so, just kill the enemy.
    CP jt.JETST_INV
    JR Z, .end                                  ; Exit if invincible.

    ; ##########################################
    ; This is the first enemy hit.
    jt.SetJetStateRip
    CALL jw.ResetWeapon
    
    ; Change animation.
    LD A, js.SDB_RIP
    CALL js.ChangeJetSpritePattern

    ; Play FX.
    CALL dbs.SetupAyFxsBank
    LD A, af.FX_JET_KILL
    CALL af.AfxPlay

    ; Remove one life.
    CALL jl.LifeDown

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                       RespawnJet                         ;
;----------------------------------------------------------;
RespawnJet

    CALL js.InitJetSprite

    ; Set respawn coordinates.
    LD BC, JM_RESPAWN_X_D100
    LD (jpo.jetX), BC

    LD A, JM_RESPAWN_Y_D217
    LD (jpo.jetY), A

    ; Reload the image because it has moved with the Jetman, and now he respawns on the ground.
    CALL bm.CopyImageData
    jt.SetJetStateRespawn
    CALL jco.MakeJetInvincible
    CALL bg.UpdateBackgroundOnJetmanMove

    CALL dbs.SetupRocketBank
    CALL roa.ResetCarryingRocketElement

    CALL jw.HideShots
    CALL jo.ResetJetpackOverheating

    ; Show stars after loading the background image.
    CALL st.ShowStars

    ; Switch to flaying animation.
    LD A, js.SDB_STAND
    CALL js.ChangeJetSpritePattern

    CALL js.ShowJetSprite

    RET                                         ; ## END of the function ## 

;----------------------------------------------------------;
;                   gc.JetpackOverheat                     ;
;----------------------------------------------------------;
    MACRO gc.JetpackOverheat

    CALL dbs.SetupAyFxsBank
    LD A, af.FX_JET_OVERHEAT
    CALL af.AfxPlay

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                 gc.JetpackTempNormal                     ;
;----------------------------------------------------------;
    MACRO gc.JetpackTempNormal

    CALL dbs.SetupAyFxsBank
    LD A, af.FX_JET_NORMAL
    CALL af.AfxPlay

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                    gc.JetPicksInAir                      ;
;----------------------------------------------------------;
    MACRO gc.JetPicksInAir

    CALL sc.PickupInAir

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                     gc.JetPicksGun                       ;
;----------------------------------------------------------;
    MACRO gc.JetPicksGun

    CALL sc.PickupRegular
    CALL jw.FireSpeedUp

    CALL dbs.SetupAyFxsBank
    LD A, af.FX_PICKUP_GUN
    CALL af.AfxPlay

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                    gc.JetPicksLife                       ;
;----------------------------------------------------------;
    MACRO gc.JetPicksLife

    CALL sc.PickupRegular

    CALL dbs.SetupAyFxsBank
    LD A, af.FX_PICKUP_LIVE
    CALL af.AfxPlay

    CALL jl.LifeUp

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                   gc.JetPicksGrenade                     ;
;----------------------------------------------------------;
    MACRO gc.JetPicksGrenade

    CALL sc.PickupRegular
    CALL gr.GrenadePickup

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                  gc.JetPicksStrawberry                   ;
;----------------------------------------------------------;
    MACRO gc.JetPicksStrawberry

    CALL sc.PickupRegular

    CALL dbs.SetupAyFxsBank
    LD A, af.FX_PICKUP_STRAWBERRY
    CALL af.AfxPlay

    CALL jco.MakeJetInvincible

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                  gc.JetPicksDiamond                      ;
;----------------------------------------------------------;
    MACRO gc.JetPicksDiamond

    CALL sc.PickupDiamond

    CALL dbs.SetupAyFxsBank
    LD A, af.FX_PICKUP_DIAMOND
    CALL af.AfxPlay

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                       JetPicksJar                        ;
;----------------------------------------------------------;
    MACRO gc.JetPicksJar

    CALL sc.PickupRegular
    CALL jo.ResetJetpackOverheating

    CALL dbs.SetupAyFxsBank
    LD A, af.FX_PICKUP_JAR
    CALL af.AfxPlay

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                 gc.FreezeEnemies                         ;
;----------------------------------------------------------;
    MACRO gc.FreezeEnemies

    CALL dbs.SetupAyFxsBank
    LD A, af.FX_FREEZE_ENEMIES
    CALL af.AfxPlay

    LD DE, gc.FREEZE_ENEMIES_CNT
    LD (gc.freezeEnemiesCnt), DE

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                     RespawnEnemy                         ;
;----------------------------------------------------------;
RespawnEnemy

    ; Enemies frozen and cannot move/respawn?
    LD DE, (freezeEnemiesCnt)

    LD A, D
    CP 0
    RET NZ

    LD A, E
    CP 0
    RET NZ

    ; ##########################################
    CALL dbs.SetupPatternEnemyBank
    CALL ens.RespawnNextSingleEnemy

    CALL dbs.SetupFollowingEnemyBank
    CALL fe.RespawnFollowingEnemy
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      MoveEnemies                         ;
;----------------------------------------------------------;
MoveEnemies

    ; Pattern enemies are immune to freeze
    CALL dbs.SetupPatternEnemyBank
    CALL enf.MoveFormationEnemies

    ; Enemies frozen and cannot move?
    LD DE, (freezeEnemiesCnt)
    
    ; DE == 0 ?
    LD A, D
    CP 0
    JR NZ, .decFreezeCnt

    ; D == 0, now check E
    LD A, E
    CP 0
    JR Z, .afterFreeze

.decFreezeCnt
    DEC DE
    LD (freezeEnemiesCnt), DE
    RET
.afterFreeze

    ; ##########################################
    CALL dbs.SetupPatternEnemyBank
    CALL ens.MoveSingleEnemies
    CALL enf.MoveFormationEnemies

    CALL dbs.SetupFollowingEnemyBank
    CALL fe.MoveFollowingEnemies

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       JetLanding                         ;
;----------------------------------------------------------;
JetLanding

    CALL dbs.SetupAyFxsBank
    LD A, af.FX_JET_LAND
    CALL af.AfxPlay

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                         JetMoves                         ;
;----------------------------------------------------------;
; Called on any Jetman movement, always before the method indicating concrete movement (#JetMovesUp,#JetMovesDown).
JetMoves

    CALL dbs.SetupRocketBank
    CALL roa.UpdateRocketOnJetmanMove

    CALL jl.UpdateLifeFaceOnJetMove

    CALL dbs.SetupArrays2Bank
    CALL pi.UpdatePickupsOnJetmanMove

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      gc.JetMovesUp                       ;
;----------------------------------------------------------;
    MACRO gc.JetMovesUp

    ; The #UpdateBackgroundOnJetmanMove calculates #bgOffset, which is used to hide the background line behind the horizon.
    ; To avoid glitches, like not hidden lines, we always have to first hide the line and then calculate the #bgOffset. This will introduce 
    ; a one pixel delay, but at the same time, it ensures that the previously hidden line will get repainted by direction change.
    CALL bg.HideBackgroundBehindHorizon
    CALL bg.UpdateBackgroundOnJetmanMove
    CALL st.MoveStarsDown

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                    gc.JetMovesDown                       ;
;----------------------------------------------------------;
    MACRO gc.JetMovesDown

    bg.ShowBackgroundAboveHorizon
    CALL bg.UpdateBackgroundOnJetmanMove
    CALL st.MoveStarsUp

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                 gc.JetBumpsIntoPlatform                  ;
;----------------------------------------------------------;
    MACRO gc.JetBumpsIntoPlatform

    CALL dbs.SetupAyFxsBank
    LD A, af.FX_BUMP_PLATFORM
    CALL af.AfxPlay

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                gc.MovementInactivity                     ;
;----------------------------------------------------------;
; TODO move to another file
; It gets executed as a last procedure after the input has been processed, and there was no movement from joystick.
    MACRO gc.MovementInactivity

    ; Increment inactivity counter.
    LD A, (jm.jetInactivityCnt)
    INC A
    LD (jm.jetInactivityCnt), A 

    ; ##########################################
    ; Should Jetman hover?
    LD A, (jt.jetAir)
    CP jt.JT_STATE_INACTIVE                     ; Is Jetman in the air?
    JR Z, .afterHoover                          ; Jump if not flaying.

    LD A, (jt.jetAir)
    CP jt.AIR_HOOVER                            ; Jetman is in the air, but is he hovering already?
    JR Z, .afterHoover                          ; Jump if already hovering.

    ; Jetman is in the air, not hovering, but is he not moving long enough?
    LD A, (jm.jetInactivityCnt)
    CP gc.HOVER_START_D250
    JR NZ, .afterHoover                         ; Jetman is not moving, by sill not long enough to start hovering.

    ; Jetman starts to hover!
    LD A, jt.AIR_HOOVER
    CALL jt.SetJetStateAir

    LD A, js.SDB_HOVER
    CALL js.ChangeJetSpritePattern
    JR .end                                     ; Already hovering, do not check standing.
.afterHoover

    ; ##########################################
    ; Jetman is not hovering, but should he stand?
    LD A, (jt.jetGnd)
    CP jt.JT_STATE_INACTIVE                     ; Is Jetman on the ground already?
    JR Z, .end                                  ; Jump if not on the ground.

    LD A, (jt.jetGnd)
    CP jt.GND_STAND                             ; Jetman is on the ground, but is he standing already?
    JR Z, .end                                  ; Jump if already standing.

    ; ##########################################
    ; Jetman is on the ground and does not move, but is he not moving long enough?
    LD A, (jm.jetInactivityCnt)
    CP gc.STAND_START_D30
    JR NZ, .afterStand                          ; Jump if Jetman stands for too short to trigger standing.

    ; Transition from walking to standing.
    LD A, jt.GND_STAND
    CALL jt.SetJetStateGnd

    LD A, js.SDB_STAND                          ; Change animation.
    CALL js.ChangeJetSpritePattern
    JR .end
.afterStand

    ; We are here because: jetInactivityCnt > 0 and jetInactivityCnt < STAND_START_D30 
    ; Jetman stands still for a short time, not long enough, to play standing animation, but at least we should stop walking animation.
    LD A, (jt.jetGnd)
    CP jt.GND_WALK
    JR NZ, .end                                  ; Jump if not walking.

    CP jt.GND_JSTAND
    JR Z, .end                                   ; Jump already j-standing (just standing - for a short time).

    LD A, (jm.jetInactivityCnt)
    CP gc.JSTAND_START_D15
    JR NC, .end                                  ; Jump if Jetman stands for too short to trigger j-standing.

    ; Stop walking immediately and stand still.
    LD A, jt.GND_JSTAND
    CALL jt.SetJetStateGnd

    LD A, js.SDB_JSTAND                         ; Change animation.
    CALL js.ChangeJetSpritePattern

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                    gc.JoyWillEnable                      ;
;----------------------------------------------------------;
    MACRO gc.JoyWillEnable

    jt.UpdateStateOnJoyWillEnable

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                 gc.ExitGameToMainMenu                    ;
;----------------------------------------------------------;
    MACRO gc.ExitGameToMainMenu

    CALL gc.LoadMainMenu

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                       gc.NightEnds                       ;
;----------------------------------------------------------;
    MACRO gc.NightEnds

    ; #NextTodPalette moves the palette address to the next chunk after loading colors into the hardware. Now, we are after the last 
    ; transition step from day to night (night to day will start), and the palette address points to the memory containing the next step, 
    ; but there is no palette on that address. We have to move the back palette addresses by one palette so that it points to the last 
    ; palette containing colors for the darkest night.
    CALL btd.PrevTodPaletteAddr

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                   gc.NextDayToNight                      ;
;----------------------------------------------------------;
; The function will be called when a night shifts to a day.
; Call sequence:
; A) NextDayToNight -> NextDayToNight -> .... -> NextDayToNight -> GOTO B).
; B) NextNightToDay -> NextNightToDay -> .... -> NextNightToDay -> ChangeToFullDay -> GOTO A).
    MACRO gc.NextDayToNight

    CALL btd.NextTodPalette

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                 gc.NextNightToDay                        ;
;----------------------------------------------------------;
; The function will be called when a day shifts to a night.
    MACRO gc.NextNightToDay

    CALL btd.PrevTodPalette

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                  gc.ChangeToFullDay                      ;
;----------------------------------------------------------;
; Called when the lighting condition has changed to a full day.
    MACRO gc.ChangeToFullDay

    CALL btd.ResetPaletteArrd
    CALL btd.LoadCurrentTodPalette

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                    gc.GameOver                           ;
;----------------------------------------------------------;
    MACRO gc.GameOver

    CALL gc._HideGame

    CALL go.ShowGameOver
    CALL jl.ResetLives

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                        _HideGame                         ;
;----------------------------------------------------------;
_HideGame

    CALL sp.ResetAllSprites

    CALL dbs.SetupMusicBank
    CALL aml.MusicOff

    CALL bm.HideImage
    CALL js.HideJetSprite

    CALL dbs.SetupRocketBank
    CALL roa.ResetAndDisableRocket

    CALL st.HideStars
    CALL jw.HideShots
    CALL jt.SetJetStateInactive
    CALL ti.ResetTilemapOffset
    CALL ti.CleanAllTiles
    CALL ki.ResetKeyboard
    _HideEnemies

    CALL dbs.SetupArrays2Bank
    CALL pi.ResetPickups

    CALL dbs.SetupPatternEnemyBank
    CALL enu.DisableFuelThief

    CALL dbs.SetupFollowingEnemyBank
    CALL fe.DisableFollowingEnemies

    CALL dbs.SetupRocketBank
    CALL rof.ResetAndDisableFlyRocket

    CALL sc.ResetClippings

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE