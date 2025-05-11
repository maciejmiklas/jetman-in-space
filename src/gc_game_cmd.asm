;----------------------------------------------------------;
;                      Game Command                        ;
;----------------------------------------------------------;
    MODULE gc

; Start times to change animations.
HOVER_START_D250        = 250
STAND_START_D30         = 30
JSTAND_START_D15        = 15

; Invincibility
JM_INV_D400             = 400                   ; Number of loops to keep Jetman invincible.

LEVEL_MIN               = 1
LEVEL_MAX               = 10
level                   BYTE LEVEL_MIN

; Respawn location.
JM_RESPAWN_X_D100       = 100
JM_RESPAWN_Y_D217       = _GSC_JET_GND_D217     ; Jetman must respond by standing on the ground. Otherwise, the background will be off.

;----------------------------------------------------------;
;                   #MainLoopCmd                           ;
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
;                      #SetupGame                          ;
;----------------------------------------------------------;
SetupGame

    CALL bm.HideImage
    CALL sc.SetupScreen
    CALL ti.SetupTiles
    CALL fi.LoadEffects

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       #LoadLobby                         ;
;----------------------------------------------------------;
LoadLobby

    CALL _HaltGame
    CALL sc.ResetScore
    CALL lom.LoadMainMenu

    ; TODO remove it when menu is ready, also remove assets/l00
    XOR A
    LD (fi.introSecondFileSize), A
    LD D, "0"
    LD E, "0"
    LD A, 4800/80                               ; Total number of lines in intro_0.map and intro_1.map
    CALL fi.LoadLevelIntroTilemap
    CALL li._ResetLevelIntro
    CALL ti.SetTilesClipVertical
    CALL jw.ResetWeapon
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    #LoadLevel1Intro                      ;
;----------------------------------------------------------;
LoadLevel1Intro

    CALL _HaltGame
    CALL los.SetLobbyStateLevelIntro

    LD D, "0"
    LD E, "1"
    LD HL, 5248                                 ; Size of intro_1.map
    LD A, 8192/80 + 5248/80                     ; Total number of lines in intro_0.map and intro_1.map
    CALL li.LoadLevelIntro

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      #LoadLevel1                         ;
;----------------------------------------------------------;
LoadLevel1

    CALL _InitLevelLoad
    CALL ll.LoadLevel1Data
    CALL _StartLevel
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      #LoadLevel2                         ;
;----------------------------------------------------------;
LoadLevel2

    CALL _InitLevelLoad
    CALL ll.LoadLevel2Data
    CALL _StartLevel
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      #LoadLevel3                         ;
;----------------------------------------------------------;
LoadLevel3

    CALL _InitLevelLoad
    CALL ll.LoadLevel3Data
    CALL _StartLevel

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      #LoadLevel4                         ;
;----------------------------------------------------------;
LoadLevel4

    CALL _InitLevelLoad
    CALL ll.LoadLevel4Data
    CALL _StartLevel

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      #LoadLevel5                         ;
;----------------------------------------------------------;
LoadLevel5

    CALL _InitLevelLoad
    CALL ll.LoadLevel5Data
    CALL _StartLevel

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      #LoadLevel6                         ;
;----------------------------------------------------------;
LoadLevel6

    CALL _InitLevelLoad
    CALL ll.LoadLevel6Data
    CALL _StartLevel

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      #LoadLevel7                         ;
;----------------------------------------------------------;
LoadLevel7

    CALL _InitLevelLoad
    CALL ll.LoadLevel7Data
    CALL _StartLevel

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      #LoadLevel8                         ;
;----------------------------------------------------------;
LoadLevel8

    CALL _InitLevelLoad
    CALL ll.LoadLevel8Data
    CALL _StartLevel

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      #LoadLevel9                         ;
;----------------------------------------------------------;
LoadLevel9

    CALL _InitLevelLoad
    CALL ll.LoadLevel9Data
    CALL _StartLevel

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     #LoadLevel10                         ;
;----------------------------------------------------------;
LoadLevel10

    CALL _InitLevelLoad
    CALL ll.LoadLevel10Data
    CALL _StartLevel
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;              #BackgroundPaletteLoaded                    ;
;----------------------------------------------------------;
BackgroundPaletteLoaded

    CALL st.LoadStarsPalette                    ; Call it after the level palette because the stars' colors are right after it.

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    #RocketTakesOff                       ;
;----------------------------------------------------------;
RocketTakesOff

    CALL sc.BoardRocket
    CALL jt.SetJetStateInactive
    CALL js.HideJetSprite
    CALL gb.HideGameBar
    CALL ti.SetTilesClipVertical

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     #LoadNextLevel                       ;
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
;                  #LoadCurrentLevel                       ;
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
;                     #RocketFlying                        ;
;----------------------------------------------------------;
RocketFlying
    
    CALL bg.UpdateBackgroundOnRocketMove
    CALL bg.HideBackgroundBehindHorizon

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    #RocketTankHit                        ;
;----------------------------------------------------------;
RocketTankHit

    CALL sc.HitRocketTank

    LD A, af.FX_EXPLODE_TANK
    CALL af.AfxPlay

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  #RocketElementPickup                    ;
;----------------------------------------------------------;
RocketElementPickup

    CALL sc.PickupRocketElement

    ; ##########################################
    ; Play different FX depending on whether Jetman picks up the fuel tank or the rocket element.
    CALL ro.IsFuelTankDeployed
    JR C, .notFuelTank

    LD A, af.FX_PICKUP_FUEL
    CALL af.AfxPlay
    JR .afterFuelFx
.notFuelTank

    LD A, af.FX_PICKUP_ROCKET_EL
    CALL af.AfxPlay
.afterFuelFx

    RET                                         ; ## END of the function ## 

;----------------------------------------------------------;
;               #RocketElementPickupInAir                  ;
;----------------------------------------------------------;
RocketElementPickupInAir
    
    CALL sc.PickupRocketElementInAir

    RET                                         ; ## END of the function ## 

;----------------------------------------------------------;
;                  #RocketElementDrop                      ;
;----------------------------------------------------------;
RocketElementDrop
    
    CALL sc.DropRocketElement

    LD A, af.FX_ROCKET_EL_DROP
    CALL af.AfxPlay

    RET                                         ; ## END of the function ## 

;----------------------------------------------------------;
;                  #PlatformWeaponHit                      ;
;----------------------------------------------------------;
PlatformWeaponHit

    LD A, af.FX_FIRE_PLATFORM_HIT
    CALL af.AfxPlay

    RET                                         ; ## END of the function ## 

;----------------------------------------------------------;
;                     #EnemyHit                            ;
;----------------------------------------------------------;
; Input
;    A:  Sprite ID of the enemy.
;  - IX: Pointer to enemy's #sr.SPR.
EnemyHit

    CALL sr.SetSpriteId
    CALL sr.SpriteHit

    ; ##########################################
    ; Checkt what enemy has been hit.

    ; Enemy 1?
    LD A, (IX + sr.SPR.SDB_INIT)
    CP sr.SDB_ENEMY1
    JR NZ, .afterHitEnemy1

    ; Yes, enemy 1 hot git.
    LD A, af.FX_EXPLODE_ENEMY_1
    CALL af.AfxPlay

    CALL sc.HitEnemy1

    JR .afterHitEnemy
.afterHitEnemy1

    ; Enemy 2?
    LD A, (IX + sr.SPR.SDB_INIT)
    CP sr.SDB_ENEMY2
    JR NZ, .afterHitEnemy2

    ; Yes, enemy 2 hot git.
    LD A, af.FX_EXPLODE_ENEMY_2
    CALL af.AfxPlay

    CALL sc.HitEnemy2
    
    JR .afterHitEnemy
.afterHitEnemy2

    ; Enemy 3?
    LD A, (IX + sr.SPR.SDB_INIT)
    CP sr.SDB_ENEMY3
    JR NZ, .afterHitEnemy3

    ; Yes, enemy 3 hot git.
    LD A, af.FX_EXPLODE_ENEMY_3
    CALL af.AfxPlay

    CALL sc.HitEnemy3
    
    JR .afterHitEnemy
.afterHitEnemy3

.afterHitEnemy

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      #EnemyHitsJet                       ;
;----------------------------------------------------------;
; Input
;  - IX:    Pointer enemy's #SPR
EnemyHitsJet

    ; Destroy the enemy.
    CALL sr.SetSpriteId
    CALL sr.SpriteHit

    ; ##########################################
    ; Is Jetman already dying? If so, do not start the RiP sequence again, just kill the enemy.
    LD A, (jt.jetState)                         
    CP jt.JETST_RIP
    RET Z                                       ; Exit if RIP.

    ; ##########################################
    ; Is Jetman invincible? If so, just kill the enemy.
    CP jt.JETST_INV
    RET Z                                       ; Exit if invincible.

    ; ##########################################
    ; This is the first enemy hit.
    CALL jt.SetJetStateRip
    CALL jw.ResetWeapon
    
    ; Change animation.
    LD A, js.SDB_RIP
    CALL js.ChangeJetSpritePattern

    ; Play FX.
    LD A, af.FX_JET_KILL
    CALL af.AfxPlay

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      #RespawnJet                         ;
;----------------------------------------------------------;
RespawnJet

    ; Set respawn coordinates.
    LD BC, JM_RESPAWN_X_D100
    LD (jpo.jetX), BC

    LD A, JM_RESPAWN_Y_D217
    LD (jpo.jetY), A

    ; Reload the image because it has moved with the Jetman, and now he respawns on the ground.
    CALL bm.CopyImageData

    CALL jt.SetJetStateRespawn

    LD HL, JM_INV_D400
    CALL jco.MakeJetInvincible

    CALL bg.UpdateBackgroundOnJetmanMove
    CALL ro.ResetCarryingRocketElement
    CALL jw.HideShots
    CALL jo.ResetJetpackOverheating

    ; Show stars after loading the background image.
    CALL st.ShowStars

    ; Switch to flaying animation.
    LD A, js.SDB_STAND
    CALL js.ChangeJetSpritePattern

    RET                                         ; ## END of the function ## 


;----------------------------------------------------------;
;                   #JetpackOverheat                       ;
;----------------------------------------------------------;
JetpackOverheat

    LD A, af.FX_JET_OVERHEAT
    CALL af.AfxPlay

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    #JetpackNormal                        ;
;----------------------------------------------------------;
JetpackNormal

    LD A, af.FX_JET_NORMAL
    CALL af.AfxPlay

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     #JetPicksInAir                       ;
;----------------------------------------------------------;
JetPicksInAir

    CALL sc.PickupInAir

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      #JetPicksGun                        ;
;----------------------------------------------------------;
JetPicksGun

    CALL sc.PickupRegular
    CALL jw.FireSpeedUp

    LD A, af.FX_PICKUP_GUN
    CALL af.AfxPlay

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     #JetPicksLife                        ;
;----------------------------------------------------------;
JetPicksLife

    CALL sc.PickupRegular

    LD A, af.FX_PICKUP_LIVE
    CALL af.AfxPlay

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    #JetPicksGrenade                      ;
;----------------------------------------------------------;
JetPicksGrenade

    CALL sc.PickupRegular
    CALL enp.KillFewPatternEnemies

    LD A, af.FX_PICKUP_GRENADE
    CALL af.AfxPlay

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  #JetPicksStrawberry                     ;
;----------------------------------------------------------;
JetPicksStrawberry

    CALL sc.PickupRegular

    LD A, af.FX_PICKUP_STRAWBERRY
    CALL af.AfxPlay

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   #JetPicksDiamond                       ;
;----------------------------------------------------------;
JetPicksDiamond

    CALL sc.PickupDiamond

    LD A, af.FX_PICKUP_DIAMOND
    CALL af.AfxPlay

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      #JetPicksJar                        ;
;----------------------------------------------------------;
JetPicksJar

    CALL sc.PickupRegular
    CALL jo.ResetJetpackOverheating

    LD A, af.FX_PICKUP_JAR
    CALL af.AfxPlay

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      #JetLanding                         ;
;----------------------------------------------------------;
JetLanding

    LD A, af.FX_JET_LAND
    CALL af.AfxPlay

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        #JetMoves                        ;
;----------------------------------------------------------;
; Called on any Jetman movement, always before the method indicating concrete movement (#JetMovesUp,#JetMovesDown).
JetMoves

    CALL ro.UpdateRocketOnJetmanMove
    CALL pi.UpdatePickupsOnJetmanMove

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       #JetMovesUp                        ;
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
;                     #JetMovesDown                        ;
;----------------------------------------------------------;
JetMovesDown

    CALL bg.ShowBackgroundAboveHorizon
    CALL bg.UpdateBackgroundOnJetmanMove
    CALL st.MoveStarsUp

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      #RocketReady                        ;
;----------------------------------------------------------;
RocketReady

    LD A, af.FX_ROCKET_READY
    CALL af.AfxPlay

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  #JetBumpsIntoPlatform                   ;
;----------------------------------------------------------;
JetBumpsIntoPlatform

    LD A, af.FX_BUMP_PLATFORM
    CALL af.AfxPlay

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 #MovementInactivity                      ;
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
    JR NZ, .afterHoover                         ; Jetman is not moving, by sill not long enough to start hovering.

    ; Jetman starts to hover!
    LD A, jt.AIR_HOOVER
    CALL jt.SetJetStateAir

    LD A, js.SDB_HOVER
    CALL js.ChangeJetSpritePattern
    RET                     ; Already hovering, do not check standing.
.afterHoover

    ; ##########################################
    ; Jetman is not hovering, but should he stand?
    LD A, (jt.jetGnd)
    CP jt.JT_STATE_INACTIVE                     ; Is Jetman on the ground already?
    RET Z                                       ; Jump if not on the ground.

    LD A, (jt.jetGnd)
    CP jt.GND_STAND                             ; Jetman is on the ground, but is he standing already?
    RET Z                                       ; Jump if already standing.

    ; ##########################################
    ; Jetman is on the ground and does not move, but is he not moving long enough?
    LD A, (jm.jetInactivityCnt)
    CP STAND_START_D30
    JR NZ, .afterStand                          ; Jump if Jetman stands for too short to trigger standing.
    
    ; Transition from walking to standing.
    LD A, jt.GND_STAND
    CALL jt.SetJetStateGnd

    LD A, js.SDB_STAND                          ; Change animation.
    CALL js.ChangeJetSpritePattern
    RET
.afterStand

    ; We are here because: jetInactivityCnt > 0 and jetInactivityCnt < STAND_START_D30 
    ; Jetman stands still for a short time, not long enough, to play standing animation, but at least we should stop walking animation.
    LD A, (jt.jetGnd)
    CP jt.GND_WALK
    RET NZ                                      ; Jump if not walking.
    
    CP jt.GND_JSTAND
    RET Z                                       ; Jump already j-standing (just standing - for a short time).

    LD A, (jm.jetInactivityCnt)
    CP JSTAND_START_D15
    RET NC                                      ; Jump if Jetman stands for too short to trigger j-standing.

    ; Stop walking immediately and stand still.
    LD A, jt.GND_JSTAND
    CALL jt.SetJetStateGnd

    LD A, js.SDB_JSTAND                         ; Change animation.
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
;                    #NextDayToNight                       ;
;----------------------------------------------------------;
; The function will be called when a night shifts to a day.
; Call sequence:
; A) NextDayToNight -> NextDayToNight -> .... -> NextDayToNight -> GOTO B)
; B) NextNightToDay -> NextNightToDay -> .... -> NextNightToDay -> ChangeToFullDay -> GOTO A)
NextDayToNight

    CALL btd.NextTodPalette

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  #NextNightToDay                         ;
;----------------------------------------------------------;
; The function will be called when a day shifts to a night.
NextNightToDay

    CALL btd.PrevTodPalette

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   #ChangeToFullDay                       ;
;----------------------------------------------------------;
; Called when the lighting condition has changed to a full day.
ChangeToFullDay

    CALL btd.ResetPaletteArrd
    CALL btd.LoadCurrentTodPalette

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                       #_HaltGame                         ;
;----------------------------------------------------------;
_HaltGame

    CALL bm.HideImage
    CALL js.HideJetSprite
    CALL ro.ResetAndDisableRocket
    CALL rof.ResetAndDisableFlyRocket
    CALL st.HideStars
    CALL jw.HideShots
    CALL enp.HidePatternEnemies
    CALL jt.SetJetStateInactive
    CALL ti.ResetTilemapOffset
    CALL ti.CleanAllTiles

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   #_InitLevelLoad                        ;
;----------------------------------------------------------;
_InitLevelLoad

    CALL _HaltGame
    
    CALL gi.ResetKeysState
    CALL los.SetLobbyStateInactive
    CALL ti.ResetTilemapOffset
    CALL td.ResetTimeOfDay
    CALL ros.ResetRocketStars
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     #_StartLevel                         ;
;----------------------------------------------------------;
_StartLevel
    
    CALL sp.LoadSpritesFPGA
    CALL gb.ShowGameBar
    CALL sc.PrintScore
    CALL ro.StartRocketAssembly
    CALL ti.SetTilesClipFull
    CALL jo.ResetJetpackOverheating
    CALL pi.ResetPickups
    CALL jw.ResetWeapon
    
    ; Respawn Jetman as the last step, this will set the status to active, all procedures will run afterward and need correct data.
    CALL RespawnJet

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE