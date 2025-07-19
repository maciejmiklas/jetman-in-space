;----------------------------------------------------------;
;                      Game Command                        ;
;----------------------------------------------------------;
    MODULE gc

; Start times to change animations.
HOVER_START_D250        = 250
STAND_START_D30         = 30
JSTAND_START_D15        = 15

LEVEL_MIN               = 1
LEVEL_MAX               = 10
level                   DB LEVEL_MIN

; Respawn location.
JM_RESPAWN_X_D100       = 100
JM_RESPAWN_Y_D217       = _GSC_JET_GND_D217     ; Jetman must respond by standing on the ground. Otherwise, the background will be off

;----------------------------------------------------------;
;                    MainLoopCmd                           ;
;----------------------------------------------------------;
    //DEFINE  PERFORMANCE_BORDER 
MainLoopCmd

    IFDEF PERFORMANCE_BORDER
        LD  A, _COL_GREEN_D4
        OUT (_BORDER_IO_HFE), A
    ENDIF

    CALL sc.WaitForScanline

    IFDEF PERFORMANCE_BORDER
        LD  A, _COL_RED_D2
        OUT (_BORDER_IO_HFE), A
    ENDIF   

    CALL ml.MainLoop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  StartGameWithIntro                      ;
;----------------------------------------------------------;
StartGameWithIntro

    ; Music off
    CALL dbs.SetupMusicBank
    CALL aml.MusicOff

    CALL js.HideJetSprite
    CALL jt.SetJetStateInactive
    CALL LoadLevel1Intro

    ; Music on
    CALL dbs.SetupMusicBank
    LD A, aml.MUSIC_INTRO
    CALL aml.LoadSong

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       SetupSystem                        ;
;----------------------------------------------------------;
SetupSystem

    CALL bm.CreateEmptyImageBank
    CALL bm.HideImage
    CALL sc.SetupScreen
    CALL ti.SetupTiles

    ; Load sprites from any level for mein menu
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
    CALL ti.SetTilesClipFull
    CALL mma.LoadMainMenu
    CALL jl.ResetLives

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     LoadLevel1Intro                      ;
;----------------------------------------------------------;
LoadLevel1Intro

    CALL _HideGame

    LD D, "0"
    LD E, "1"
    LD HL, 4048                                 ; Size of intro_1.map
    LD A, 8192/80 + 4048/80                     ; Total number of lines in intro_0.map and intro_1.map
    CALL li.LoadLevelIntro

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       LoadLevel1                         ;
;----------------------------------------------------------;
LoadLevel1

    CALL _InitLevelLoad

    CALL ll.LoadLevel1Data
    CALL _StartLevel

    CALL dbs.SetupPatternEnemyBank: CALL enu.DisableFuelThief

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       LoadLevel2                         ;
;----------------------------------------------------------;
LoadLevel2

    CALL _InitLevelLoad
    CALL ll.LoadLevel2Data
    CALL _StartLevel
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       LoadLevel3                         ;
;----------------------------------------------------------;
LoadLevel3

    CALL _InitLevelLoad
    CALL ll.LoadLevel3Data
    CALL _StartLevel

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       LoadLevel4                         ;
;----------------------------------------------------------;
LoadLevel4

    CALL _InitLevelLoad
    CALL ll.LoadLevel4Data
    CALL _StartLevel

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       LoadLevel5                         ;
;----------------------------------------------------------;
LoadLevel5

    CALL _InitLevelLoad
    CALL ll.LoadLevel5Data
    CALL _StartLevel

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       LoadLevel6                         ;
;----------------------------------------------------------;
LoadLevel6

    CALL _InitLevelLoad
    CALL ll.LoadLevel6Data
    CALL _StartLevel

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       LoadLevel7                         ;
;----------------------------------------------------------;
LoadLevel7

    CALL _InitLevelLoad
    CALL ll.LoadLevel7Data
    CALL _StartLevel

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       LoadLevel8                         ;
;----------------------------------------------------------;
LoadLevel8

    CALL _InitLevelLoad
    CALL ll.LoadLevel8Data
    CALL _StartLevel

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       LoadLevel9                         ;
;----------------------------------------------------------;
LoadLevel9

    CALL _InitLevelLoad
    CALL ll.LoadLevel9Data
    CALL _StartLevel

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      LoadLevel10                         ;
;----------------------------------------------------------;
LoadLevel10

    CALL _InitLevelLoad
    CALL ll.LoadLevel10Data
    CALL _StartLevel
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;               BackgroundPaletteLoaded                    ;
;----------------------------------------------------------;
BackgroundPaletteLoaded

    CALL st.LoadStarsPalette                    ; Call it after the level palette because the stars' colors are right after it

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     RocketTakesOff                       ;
;----------------------------------------------------------;
RocketTakesOff

    LD A, ms.FLY_ROCKET
    CALL ms.SetMainState

    CALL sc.BoardRocket
    CALL jt.SetJetStateInactive
    CALL js.HideJetSprite
    CALL gb.HideGameBar
    CALL ti.SetTilesClipHorizontal
    CALL pi.ResetPickups
    CALL ki.ResetKeyboard
    CALL dbs.SetupPatternEnemyBank: CALL enu.DisableFuelThief
    CALL jw.HideShots

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      LoadNextLevel                       ;
;----------------------------------------------------------;
LoadNextLevel

    ; Load level into A and eventually reset it (10 -> 1).
    LD A, (level)
    INC A
    LD (level),A

    ; Restart level.
    CP LEVEL_MAX+1
    JR NZ, .afterResetLevel
    LD A, (LEVEL_MIN)
    LD (level),A
.afterResetLevel

    CALL LoadCurrentLevel

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   LoadCurrentLevel                       ;
;----------------------------------------------------------;
LoadCurrentLevel

    ; Load level into A
    LD A, (level)

    ; Load level 1
    CP 1
    JR NZ, .afterLevel1
    CALL LoadLevel1
    RET
.afterLevel1

    ; Load level 2
    CP 2
    JR NZ, .afterLevel2
    CALL LoadLevel2
    RET
.afterLevel2

    ; Load level 3
    CP 3
    JR NZ, .afterLevel3
    CALL LoadLevel3
    RET
.afterLevel3

    ; Load level 4
    CP 4
    JR NZ, .afterLevel4
    CALL LoadLevel4
    RET
.afterLevel4

    ; Load level 5
    CP 5
    JR NZ, .afterLevel5
    CALL LoadLevel5
    RET
.afterLevel5

    ; Load level 6
    CP 6
    JR NZ, .afterLevel6
    CALL LoadLevel6
    RET
.afterLevel6

    ; Load level 7
    CP 7
    JR NZ, .afterLevel7
    CALL LoadLevel7
    RET
.afterLevel7

    ; Load level 8
    CP 8
    JR NZ, .afterLevel8
    CALL LoadLevel8
    RET
.afterLevel8

    ; Load level 9
    CP 9
    JR NZ, .afterLevel9
    CALL LoadLevel9
    RET
.afterLevel9

    ; Load level 10
    CP 10
    JR NZ, .afterLevel10
    CALL LoadLevel10
    RET
.afterLevel10

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      RocketFlying                        ;
;----------------------------------------------------------;
RocketFlying

    CALL st.MoveStarsDown
    CALL bg.UpdateBackgroundOnRocketMove
    CALL bg.HideBackgroundBehindHorizon

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     FuelThiefHit                         ;
;----------------------------------------------------------;
FuelThiefHit

    LD A, af.FX_EXPLODE_ENEMY_3
    CALL dbs.SetupAyFxsBank
    CALL af.AfxPlay

    CALL sc.HitEnemy3

    CALL dbs.SetupPatternEnemyBank                     ; Stack jumps back to enemy 

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     RocketTankHit                        ;
;----------------------------------------------------------;
RocketTankHit

    CALL sc.HitRocketTank

    LD A, af.FX_EXPLODE_TANK
    CALL dbs.SetupAyFxsBank
    CALL af.AfxPlay

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   RocketElementPickup                    ;
;----------------------------------------------------------;
RocketElementPickup

    CALL sc.PickupRocketElement

    ; ##########################################
    ; Play different FX depending on whether Jetman picks up the fuel tank or the rocket element
    CALL ro.IsFuelDeployed
    CP _RET_NO_D0
    JR Z, .notFuelTank

    LD A, af.FX_PICKUP_FUEL
    CALL dbs.SetupAyFxsBank
    CALL af.AfxPlay
    JR .afterFuelFx
.notFuelTank

    LD A, af.FX_PICKUP_ROCKET_EL
    CALL dbs.SetupAyFxsBank
    CALL af.AfxPlay
.afterFuelFx

    RET                                         ; ## END of the function ## 

;----------------------------------------------------------;
;                RocketElementPickupInAir                  ;
;----------------------------------------------------------;
RocketElementPickupInAir
    
    CALL sc.PickupRocketElementInAir

    RET                                         ; ## END of the function ## 

;----------------------------------------------------------;
;                   RocketElementDrop                      ;
;----------------------------------------------------------;
RocketElementDrop
    
    CALL sc.DropRocketElement

    LD A, af.FX_ROCKET_EL_DROP
    CALL dbs.SetupAyFxsBank
    CALL af.AfxPlay

    RET                                         ; ## END of the function ## 

;----------------------------------------------------------;
;                     JetPlatformTakesOff                  ;
;----------------------------------------------------------;
JetPlatformTakesOff

    ; Transition from walking to flaying.
    LD A, (jt.jetGnd)
    CP jt.JT_STATE_INACTIVE                     ; Check if Jetman is on the ground/platform
    RET Z

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
    LD A, af.FX_JET_TAKE_OFF
    CALL dbs.SetupAyFxsBank
    CALL af.AfxPlay

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   PlatformWeaponHit                      ;
;----------------------------------------------------------;
PlatformWeaponHit

    LD A, af.FX_FIRE_PLATFORM_HIT
    CALL dbs.SetupAyFxsBank
    CALL af.AfxPlay

    RET                                         ; ## END of the function ## 

;----------------------------------------------------------;
;                   PlayFuelThiefFx                        ;
;----------------------------------------------------------;
PlayFuelThiefFx

    CALL dbs.SetupPatternEnemyBank
    LD A, (enu.thiefState)

    CP enu.TS_DEPLOYING
    JR Z, .play
    CP enu.TS_RUNS_EMPTY
    RET NZ
.play

    ; Play FX
    CALL dbs.SetupAyFxsBank
    LD A, af.FX_THIEF
    CALL af.AfxPlay

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    WeaponHitEnemies                      ;
;----------------------------------------------------------;
WeaponHitEnemies

    CALL dbs.SetupArraysBank

    ; ##########################################
    CALL dbs.SetupPatternEnemyBank
    LD IX, ena.singleEnemySprites
    LD B, (ens.singleEnemySize)
    CALL jw.CheckHitEnemies

    ; ##########################################
    CALL dbs.SetupPatternEnemyBank
    LD IX, ena.formationEnemySprites
    LD B, ena.ENEMY_FORMATION_SIZE
    CALL jw.CheckHitEnemies

    ; ##########################################
    CALL dbs.SetupFollowingEnemyBank
    LD IX, fe.fEnemySprites
    LD B, (fe.fEnemySize)
    CALL jw.CheckHitEnemies

    RET                                         ; ## END of the function ##
    
;----------------------------------------------------------;
;                      EnemyHit                            ;
;----------------------------------------------------------;
; Input
;    A:  Sprite ID of the enemy.
;  - IX: Pointer to enemy's #SPR.
EnemyHit

    CALL dbs.SetupArraysBank

    CALL sr.SpriteHit

    ; ##########################################
    ; Checkt what enemy has been hit.

    ; Enemy 1?
    LD A, (IX + SPR.SDB_INIT)
    CP sr.SDB_ENEMY1
    JR NZ, .afterHitEnemy1

    ; Yes, enemy 1 hot git.
    LD A, af.FX_EXPLODE_ENEMY_1
    CALL dbs.SetupAyFxsBank
    CALL af.AfxPlay

    CALL sc.HitEnemy1

    JR .afterHitEnemy
.afterHitEnemy1

    ; Enemy 2?
    LD A, (IX + SPR.SDB_INIT)
    CP sr.SDB_ENEMY2
    JR NZ, .afterHitEnemy2

    ; Yes, enemy 2 hot git.
    LD A, af.FX_EXPLODE_ENEMY_2
    CALL dbs.SetupAyFxsBank
    CALL af.AfxPlay

    CALL sc.HitEnemy2
    
    JR .afterHitEnemy
.afterHitEnemy2

    ; Enemy 3?
    LD A, (IX + SPR.SDB_INIT)
    CP sr.SDB_ENEMY3
    JR NZ, .afterHitEnemy3

    ; Yes, enemy 3 hot git.
    LD A, af.FX_EXPLODE_ENEMY_3
    CALL dbs.SetupAyFxsBank
    CALL af.AfxPlay

    CALL sc.HitEnemy3

    JR .afterHitEnemy
.afterHitEnemy3

.afterHitEnemy

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       EnemyHitsJet                       ;
;----------------------------------------------------------;
; Input
;  - IX:    Pointer enemy's #SPR
EnemyHitsJet

    CALL dbs.SetupArraysBank
    
    ; Destroy the enemy.
    CALL sr.SpriteHit

    ; ##########################################
    ; Is Jetman already dying? If so, do not start the RiP sequence again, just kill the enemy
    LD A, (jt.jetState)                         
    CP jt.JETST_RIP
    RET Z                                       ; Exit if RIP

    ; ##########################################
    ; Is Jetman invincible? If so, just kill the enemy.
    CP jt.JETST_INV
    RET Z                                       ; Exit if invincible

    ; ##########################################
    ; This is the first enemy hit.
    CALL jt.SetJetStateRip
    CALL jw.ResetWeapon
    
    ; Change animation.
    LD A, js.SDB_RIP
    CALL js.ChangeJetSpritePattern

    ; Play FX.
    LD A, af.FX_JET_KILL
    CALL dbs.SetupAyFxsBank
    CALL af.AfxPlay

    ; Remove one life
    CALL jl.LifeDown

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       RespawnJet                         ;
;----------------------------------------------------------;
RespawnJet

    ; Set respawn coordinates.
    LD BC, JM_RESPAWN_X_D100
    LD (jpo.jetX), BC

    LD A, JM_RESPAWN_Y_D217
    LD (jpo.jetY), A

    ; Reload the image because it has moved with the Jetman, and now he respawns on the ground
    CALL bm.CopyImageData

    CALL jt.SetJetStateRespawn

    CALL jco.MakeJetInvincible

    CALL bg.UpdateBackgroundOnJetmanMove
    CALL ro.ResetCarryingRocketElement
    CALL jw.HideShots
    CALL jo.ResetJetpackOverheating

    ; Show stars after loading the background image
    CALL st.ShowStars

    ; Switch to flaying animation
    LD A, js.SDB_STAND
    CALL js.ChangeJetSpritePattern

    CALL js.ShowJetSprite

    RET                                         ; ## END of the function ## 

;----------------------------------------------------------;
;                    JetpackOverHard                       ;
;----------------------------------------------------------;
JetpackOverHard

    LD A, af.FX_JET_OVERHEAT
    CALL dbs.SetupAyFxsBank
    CALL af.AfxPlay

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     JetpackNormal                        ;
;----------------------------------------------------------;
JetpackNormal

    LD A, af.FX_JET_NORMAL
    CALL dbs.SetupAyFxsBank
    CALL af.AfxPlay

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      JetPicksInAir                       ;
;----------------------------------------------------------;
JetPicksInAir

    CALL sc.PickupInAir

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       JetPicksGun                        ;
;----------------------------------------------------------;
JetPicksGun

    CALL sc.PickupRegular
    CALL jw.FireSpeedUp

    LD A, af.FX_PICKUP_GUN
    CALL dbs.SetupAyFxsBank
    CALL af.AfxPlay

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      JetPicksLife                        ;
;----------------------------------------------------------;
JetPicksLife

    CALL sc.PickupRegular

    LD A, af.FX_PICKUP_LIVE
    CALL dbs.SetupAyFxsBank
    CALL af.AfxPlay

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     JetPicksGrenade                      ;
;----------------------------------------------------------;
JetPicksGrenade

    CALL sc.PickupRegular
    CALL gr.GrenadePickup

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     FreezeEnemies                        ;
;----------------------------------------------------------;
FreezeEnemies

    LD A, af.FX_FREEZE_ENEMIES
    CALL dbs.SetupAyFxsBank
    CALL af.AfxPlay

    CALL dbs.SetupPatternEnemyBank
    CALL enp.FreezePatternEnemies

    CALL dbs.SetupFollowingEnemyBank
    CALL fe.FreezeFollowingEnemies

    RET                                         ; ## END of the function ##


;----------------------------------------------------------;
;                   JetPicksStrawberry                     ;
;----------------------------------------------------------;
JetPicksStrawberry

    CALL sc.PickupRegular

    LD A, af.FX_PICKUP_STRAWBERRY
    CALL dbs.SetupAyFxsBank
    CALL af.AfxPlay

    CALL jco.MakeJetInvincible

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    JetPicksDiamond                       ;
;----------------------------------------------------------;
JetPicksDiamond

    CALL sc.PickupDiamond

    LD A, af.FX_PICKUP_DIAMOND
    CALL dbs.SetupAyFxsBank
    CALL af.AfxPlay

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       JetPicksJar                        ;
;----------------------------------------------------------;
JetPicksJar

    CALL sc.PickupRegular
    CALL jo.ResetJetpackOverheating

    LD A, af.FX_PICKUP_JAR
    CALL dbs.SetupAyFxsBank
    CALL af.AfxPlay

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       JetLanding                         ;
;----------------------------------------------------------;
JetLanding

    LD A, af.FX_JET_LAND
    CALL dbs.SetupAyFxsBank
    CALL af.AfxPlay

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                         JetMoves                         ;
;----------------------------------------------------------;
; Called on any Jetman movement, always before the method indicating concrete movement (#JetMovesUp,#JetMovesDown).
JetMoves

    CALL ro.UpdateRocketOnJetmanMove
    CALL pi.UpdatePickupsOnJetmanMove
    CALL jl.UpdateLifeFaceOnJetMove

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        JetMovesUp                        ;
;----------------------------------------------------------;
JetMovesUp

    ; The #UpdateBackgroundOnJetmanMove calculates #bgOffset, which is used to hide the background line behind the horizon.
    ; To avoid glitches, like not hidden lines, we always have to first hide the line and then calculate the #bgOffset. This will introduce 
    ; a one pixel delay, but at the same time, it ensures that the previously hidden line will get repainted by direction change.
    CALL bg.HideBackgroundBehindHorizon
    CALL bg.UpdateBackgroundOnJetmanMove
    CALL st.MoveStarsDown

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      JetMovesDown                        ;
;----------------------------------------------------------;
JetMovesDown

    CALL bg.ShowBackgroundAboveHorizon
    CALL bg.UpdateBackgroundOnJetmanMove
    CALL st.MoveStarsUp

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       RocketReady                        ;
;----------------------------------------------------------;
RocketReady

    LD A, af.FX_ROCKET_READY
    CALL dbs.SetupAyFxsBank
    CALL af.AfxPlay

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   JetBumpsIntoPlatform                   ;
;----------------------------------------------------------;
JetBumpsIntoPlatform

    LD A, af.FX_BUMP_PLATFORM
    CALL dbs.SetupAyFxsBank
    CALL af.AfxPlay

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  MovementInactivity                      ;
;----------------------------------------------------------;
; It gets executed as a last procedure after the input has been processed, and there was no movement from joystick.
MovementInactivity

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
    CP HOVER_START_D250
    JR NZ, .afterHoover                         ; Jetman is not moving, by sill not long enough to start hovering

    ; Jetman starts to hover!
    LD A, jt.AIR_HOOVER
    CALL jt.SetJetStateAir

    LD A, js.SDB_HOVER
    CALL js.ChangeJetSpritePattern
    RET                     ; Already hovering, do not check standing
.afterHoover

    ; ##########################################
    ; Jetman is not hovering, but should he stand?
    LD A, (jt.jetGnd)
    CP jt.JT_STATE_INACTIVE                     ; Is Jetman on the ground already?
    RET Z                                       ; Jump if not on the ground

    LD A, (jt.jetGnd)
    CP jt.GND_STAND                             ; Jetman is on the ground, but is he standing already?
    RET Z                                       ; Jump if already standing

    ; ##########################################
    ; Jetman is on the ground and does not move, but is he not moving long enough?
    LD A, (jm.jetInactivityCnt)
    CP STAND_START_D30
    JR NZ, .afterStand                          ; Jump if Jetman stands for too short to trigger standing
    
    ; Transition from walking to standing.
    LD A, jt.GND_STAND
    CALL jt.SetJetStateGnd

    LD A, js.SDB_STAND                          ; Change animation
    CALL js.ChangeJetSpritePattern
    RET
.afterStand

    ; We are here because: jetInactivityCnt > 0 and jetInactivityCnt < STAND_START_D30 
    ; Jetman stands still for a short time, not long enough, to play standing animation, but at least we should stop walking animation
    LD A, (jt.jetGnd)
    CP jt.GND_WALK
    RET NZ                                      ; Jump if not walking
    
    CP jt.GND_JSTAND
    RET Z                                       ; Jump already j-standing (just standing - for a short time)

    LD A, (jm.jetInactivityCnt)
    CP JSTAND_START_D15
    RET NC                                      ; Jump if Jetman stands for too short to trigger j-standing

    ; Stop walking immediately and stand still
    LD A, jt.GND_JSTAND
    CALL jt.SetJetStateGnd

    LD A, js.SDB_JSTAND                         ; Change animation
    CALL js.ChangeJetSpritePattern

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      JoyWillEnable                       ;
;----------------------------------------------------------;
JoyWillEnable

    CALL jt.UpdateStateOnJoyWillEnable

    RET                                         ; ## END of the function ##


;----------------------------------------------------------;
;                         NightEnds                        ;
;----------------------------------------------------------;
NightEnds

    ; #NextTodPalette moves the palette address to the next chunk after loading colors into the hardware. Now, we are after the last 
    ; transition step from day to night (night to day will start), and the palette address points to the memory containing the next step, 
    ; but there is no palette on that address. We have to move the back palette addresses by one palette so that it points to the last 
    ; palette containing colors for the darkest night.
    CALL btd.PrevTodPaletteAddr

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     NextDayToNight                       ;
;----------------------------------------------------------;
; The function will be called when a night shifts to a day.
; Call sequence:
; A) NextDayToNight -> NextDayToNight -> .... -> NextDayToNight -> GOTO B)
; B) NextNightToDay -> NextNightToDay -> .... -> NextNightToDay -> ChangeToFullDay -> GOTO A)
NextDayToNight

    CALL btd.NextTodPalette

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   NextNightToDay                         ;
;----------------------------------------------------------;
; The function will be called when a day shifts to a night.
NextNightToDay

    CALL btd.PrevTodPalette

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    ChangeToFullDay                       ;
;----------------------------------------------------------;
; Called when the lighting condition has changed to a full day.
ChangeToFullDay

    CALL btd.ResetPaletteArrd
    CALL btd.LoadCurrentTodPalette

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      GameOver                            ;
;----------------------------------------------------------;
GameOver
    CALL _HideGame

    CALL go.ShowGameOver
    CALL jl.ResetLives

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                        _HideGame                         ;
;----------------------------------------------------------;
_HideGame

    ; Music off
    CALL dbs.SetupMusicBank
    CALL aml.MusicOff

    CALL bm.HideImage
    CALL js.HideJetSprite
    CALL ro.ResetAndDisableRocket
    CALL rof.ResetAndDisableFlyRocket
    CALL st.HideStars
    CALL jw.HideShots
    CALL jt.SetJetStateInactive
    CALL ti.ResetTilemapOffset
    CALL ti.CleanAllTiles
    CALL pi.ResetPickups
    CALL ki.ResetKeyboard

    CALL dbs.SetupPatternEnemyBank
    CALL enp.HidePatternEnemies
    CALL enu.DisableFuelThief

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    _InitLevelLoad                        ;
;----------------------------------------------------------;
_InitLevelLoad

    CALL _HideGame
    CALL gi.ResetKeysState
    CALL td.ResetTimeOfDay
    CALL ros.ResetRocketStars
    CALL dbs.SetupPatternEnemyBank: CALL enu.EnableFuelThief

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      _StartLevel                         ;
;----------------------------------------------------------;
_StartLevel

    LD A, ms.GAME_ACTIVE
    CALL ms.SetMainState
    
    CALL gb.ShowGameBar
    CALL sc.PrintScore
    CALL ro.StartRocketAssembly
    CALL ti.SetTilesClipFull
    CALL ti.ResetTilemapOffset
    CALL jo.ResetJetpackOverheating
    CALL jl.SetupLives
    CALL jw.ResetWeapon
    
    LD A, ms.GAME_ACTIVE
    CALL ms.SetMainState

    ; Music on
    CALL dbs.SetupMusicBank
    CALL aml.NextGameSong

    ; Respawn Jetman as the last step, this will set the status to active, all procedures will run afterward and need correct data
    CALL RespawnJet

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE