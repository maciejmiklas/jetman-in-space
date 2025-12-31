/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                       Main Loop                          ;
;----------------------------------------------------------;
    MODULE ml 

;----------------------------------------------------------;
;                      #MainLoop                           ;
;----------------------------------------------------------;
MainLoop

    CALL _Loop000
    CALL _Loop002
    CALL _Loop005

    CALL _Loop008
    CALL _Loop010
    CALL _Loop025
    CALL _Loop040
    CALL _Loop050
    CALL _Loop075
    CALL _Loop250
    CALL _LastLoop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                         _Loop000                         ;
;----------------------------------------------------------;
_Loop000

    ; 1 -> 0 and 0 -> 1
    LD A, (mld.counter000FliFLop)
    XOR 1
    LD (mld.counter000FliFLop), A

    ; ##########################################
    ; CALL functions that need to be updated every loop.
    ; First update graphics, logic follows afterwards!

    CALL gb.PrintDebug

    CALL dbs.SetupAyFxsBank
    CALL af.AfxFrame                            ; Keep AYFX sound effect playing.
    
    CALL dbs.SetupMusicBank
    CALL am.MusicLoop

    CALL _Loop000OnRocketPhase2_3
    CALL _Loop000OnPause
    CALL _Loop000OnActiveGame
    CALL _Loop000OnActiveMain
    CALL _Loop000OnNotInGame
    CALL _Loop000OnActiveLevelIntro
    CALL _Loop000OnFlyRocket

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;               _Loop000OnRocketPhase2_3                   ;
;----------------------------------------------------------;
_Loop000OnRocketPhase2_3

    CALL dbs.SetupRocketBank

    LD A, (ro.rocketFlyPhase)
    AND ro.PHASE_2_3
    RET Z

    CALL bg.HideBackgroundBars

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     _Loop000OnPause                      ;
;----------------------------------------------------------;
_Loop000OnPause

    LD A, (ms.mainState)
    CP ms.PAUSE
    RET NZ

    CALL gi.GameOptionsInput

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  _Loop000OnFlyRocket                     ;
;----------------------------------------------------------;
_Loop000OnFlyRocket
    CALL dbs.SetupRocketBank

    ; Return if rocket is not flying. #ms.mainState has also similar state: #FLY_ROCKET, but its not the same!
    ; Rocket is also exploding, in this case #ms.mainState == #Fms.LY_ROCKET but #ro.rocketState == #ro.ROST_EXPLODE and not #ro.ROST_FLY.
    LD A, (ro.rocketState)
    CP ro.ROST_FLY
    RET NZ

    ; ##########################################
    CALL rof.FlyRocket
    CALL rof.FlyRocketSound

    ; ##########################################
    ; Phase 4
    CALL dbs.SetupRocketBank

    LD A, (ro.rocketFlyPhase)
    CP ro.PHASE_4
    RET NZ

    CALL rot.MoveAsteroids

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  _Loop000OnActiveGame                    ;
;----------------------------------------------------------;
_Loop000OnActiveGame

    ; Return if game is inactive
    LD A, (ms.mainState)
    CP ms.GAME_ACTIVE
    RET NZ

    ; ##########################################
    CALL _Loop000OnDisabledJoy
    CALL gi.JetMovementInput
    CALL gi.GameOptionsInput

    CALL jco.JetRip
    CALL jw.MoveShots
    CALL gc.WeaponHitEnemy
    CALL jw.FireDelayCounter
    CALL gc.JetmanEnemiesCollision
    CALL js.UpdateJetSpritePositionRotation
    CALL js.AnimateJetSprite
    CALL jco.JetInvincible

    CALL dbs.SetupRocketBank
    CALL roa.CheckHitTank
    CALL roa.RocketElementFallsForPickup

    CALL dbs.SetupPatternEnemyBank
    CALL enu.MoveFuelThief
    CALL enu.ThiefWeaponHit

    CALL dbs.SetupFollowingEnemyBank
    CALL fe.UpdateFollowingJetman

    ; ##########################################
    ; Move enemies for normal or hard.
    LD A, (jt.difLevel)
    CP jt.DIF_EASY
    JR Z, .onEasy

    CALL gc.MoveEnemies
.onEasy

    ; ##########################################
    ; Faster movement speed for Jetman on hard.
    LD A, (jt.difLevel)
    CP jt.DIF_HARD
    JR NZ, .notHard

    ; Do not speed up animations, like falling from the platform.
    LD A, (gid.joyOffCnt)
    CP 0
    JR NZ, .notHard

    CALL gi.JetMovementInput
.notHard

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   _Loop000OnNotInGame                    ;
;----------------------------------------------------------;
_Loop000OnNotInGame

    ; Return if menu is not active.
    LD A, (ms.mainState)
    CP ms.LEVEL_INTRO
    RET C

    ; ##########################################
    CALL ki.KeyboardInput

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   _Loop000OnActiveMain                   ;
;----------------------------------------------------------;
_Loop000OnActiveMain

    ; Execute if main menu or level select menu is inactive.
    LD A, (ms.mainState)
    
    CP ms.MENU_MAIN
    JR Z, .execute

    CP ms.MENU_LEVEL
    JR Z, .execute

    RET

.execute
    ; ##########################################
    CALL js.UpdateJetSpritePositionRotation
    CALL js.AnimateJetSprite

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                _Loop000OnActiveLevelIntro                ;
;----------------------------------------------------------;
_Loop000OnActiveLevelIntro

    ; Return if intro is inactive.
    LD A, (ms.mainState)
    CP ms.LEVEL_INTRO
    RET NZ

    ; ##########################################
    CALL li.AnimateLevelIntroTextScroll

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  _Loop000OnDisabledJoy                   ;
;----------------------------------------------------------;
_Loop000OnDisabledJoy

    ; Return if game is inactive.
    LD A, (ms.mainState)
    CP ms.GAME_ACTIVE
    RET NZ

    ; Return if the joystick is about to enable.
    LD A, (gid.joyOffCnt)
    CP pl.PL_BUMP_JOY_DEC_D1+1
    RET C                                       ; Return on the last off loop - this one is used to reset status and not to animate

    ; ##########################################
    CALL pl.MoveJetOnPlatformSideHit
    CALL pl.MoveJetOnFallingFromPlatform
    CALL pl.MoveJetOnHitPlatformBelow
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                          _Loop002                        ;
;----------------------------------------------------------;
; Tick rate: 1/25s
_Loop002

    ; Increment the counter.
    LD A, (mld.counter002)
    INC A
    LD (mld.counter002), A
    CP mld.COUNTER002_MAX
    RET NZ

    ; Reset the counter.
    XOR A                                       ; Set A to 0
    LD (mld.counter002), A

    ; ##########################################
    ; 1 -> 0 and 0 -> 1
    LD A, (mld.counter002FliFLop)
    XOR 1
    LD (mld.counter002FliFLop), A

    ; ##########################################
    ; CALL functions that need to be updated every xx-th loop.
    CALL _Loop002OnActiveGame

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  _Loop002OnActiveGame                    ;
;----------------------------------------------------------;
_Loop002OnActiveGame

    ; Return if game is inactive.
    LD A, (ms.mainState)
    CP ms.GAME_ACTIVE
    RET NZ

    ; ##########################################
    LD A, (jt.difLevel)
    CP jt.DIF_EASY
    JR NZ, .notEasy

    CALL gc.MoveEnemies
.notEasy

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        _Loop004                          ;
;----------------------------------------------------------;
; Tick rate: 1/10s
_Loop005

    ; Increment the counter.
    LD A, (mld.counter005)
    INC A
    LD (mld.counter005), A
    CP mld.COUNTER005_MAX
    RET NZ
    
    ; Reset the counter.
    XOR A                                       ; Set A to 0
    LD (mld.counter005), A

    ; ##########################################
    ; 1 -> 0 and 0 -> 1
    LD A, (mld.counter005FliFLop)
    XOR 1
    LD (mld.counter005FliFLop), A

    ; ##########################################
    ; CALL functions that need to be updated every xx-th loop.
    CALL _Loop005OnActiveGame

    RET                                         ; ## END of the function ##


;----------------------------------------------------------;
;                   _Loop005OnActiveGame                   ;
;----------------------------------------------------------;
_Loop005OnActiveGame

    ; Return if game is not active.
    LD A, (ms.mainState)
    CP ms.GAME_ACTIVE
    RET NZ

    ; ##########################################
    CALL dbs.SetupRocketBank
    CALL roa.RocketElementFallsForAssembly

    CALL jo.UpdateJetpackOverheating

    CALL dbs.SetupArrays2Bank
    CALL pi.AnimateFallingPickup

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        _Loop008                          ;
;----------------------------------------------------------;
; Tick rate: ±1/6s
_Loop008

    ; Increment the counter.
    LD A, (mld.counter008)
    INC A
    LD (mld.counter008), A
    CP mld.COUNTER008_MAX
    RET NZ

    ; Reset the counter.
    XOR A                                       ; Set A to 0
    LD (mld.counter008), A

    ; ##########################################
    ; 1 -> 0 and 0 -> 1
    LD A, (mld.counter008FliFLop)
    XOR 1
    LD (mld.counter008FliFLop), A

    ; ##########################################
    ; CALL functions that need to be updated every xx-th loop.
    CALL _Loop008OnActiveGame
    CALL _Loop008OnActiveScoreMenu
    CALL _Loop008OnFlayingRocket
    CALL _Loop008OnRocketExplosion

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                _Loop008OnRocketExplosion                 ;
;----------------------------------------------------------;
_Loop008OnRocketExplosion

    CALL dbs.SetupRocketBank

    ; Is rocket exploding ?
    LD A, (ro.rocketState)
    CP ro.ROST_EXPLODE
    RET NZ

    ; ##########################################
    CALL st.BlinkStarsL1
    CALL st.BlinkStarsL2

    CALL dbs.SetupRocketBank
    CALL rot.AnimateAsteroids
    CALL rof.AnimateRocketExplosion

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;               _Loop008OnActiveScoreMenu                  ;
;----------------------------------------------------------;
_Loop008OnActiveScoreMenu

    LD A, (ms.mainState)
    CP ms.MENU_SCORE
    RET NZ

    ; ##########################################
    CALL mms.AnimateCursor

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 _Loop008OnFlayingRocket                  ;
;----------------------------------------------------------;
_Loop008OnFlayingRocket

    ; Return if rocket is not flying.
    CALL dbs.SetupRocketBank
    LD A, (ro.rocketState)
    CP ro.ROST_FLY
    RET NZ

    ; ##########################################
    CALL st.BlinkStarsL1
    CALL st.BlinkStarsL2

    CALL dbs.SetupRocketBank
    CALL rof.AnimateRocketExhaust
    CALL rof.BlinkFlyingRocket
    CALL gc.AnimateEnemies

    ; ##########################################
    ; Phase 4
    CALL dbs.SetupRocketBank

    LD A, (ro.rocketFlyPhase)
    CP ro.PHASE_4
    RET NZ

    CALL rot.AnimateAsteroids

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   _Loop008OnActiveGame                   ;
;----------------------------------------------------------;
_Loop008OnActiveGame

    ; Return if game is inactive.
    LD A, (ms.mainState)
    CP ms.GAME_ACTIVE
    RET NZ

    ; ##########################################
    CALL jw.AnimateShots

    CALL dbs.SetupRocketBank
    CALL roa.BlinkRocketReady
    CALL roa.AnimateTankExplode

    CALL st.BlinkStarsL1
    CALL jo.AnimateJetpackOverheat

    CALL dbs.SetupTileAnimationBank
    CALL ta.NextTileAnimationFrame 

    CALL dbs.SetupPatternEnemyBank
    CALL enu.AnimateFuelThief

    CALL gc.AnimateEnemies

    ; ##########################################
    ; Hard
    LD A, (jt.difLevel)
    CP jt.DIF_HARD
    JR NZ, .notHard

    CALL gc.MoveEnemies
    CALL gc.RespawnEnemy

.notHard

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        _Loop010                          ;
;----------------------------------------------------------;
; Tick rate: 1/5s
_Loop010

    ; Increment the counter
    LD A, (mld.counter010)
    INC A
    LD (mld.counter010), A
    CP mld.COUNTER010_MAX
    RET NZ

    ; Reset the counter
    XOR A                                       ; Set A to 0
    LD (mld.counter010), A

    ; ##########################################
    ; 1 -> 0 and 0 -> 1
    LD A, (mld.counter010FliFLop)
    XOR 1
    LD (mld.counter010FliFLop), A

    ; ##########################################
    ; CALL functions that need to be updated every xx-th loop.
    CALL _Loop010OnActiveGame

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   _Loop010OnActiveGame                   ;
;----------------------------------------------------------;
_Loop010OnActiveGame

    ; Return if game is inactive.
    LD A, (ms.mainState)
    CP ms.GAME_ACTIVE
    RET NZ

    ; ##########################################
    CALL dbs.SetupPatternEnemyBank
    CALL enf.RespawnFormation

    CALL gc.RespawnEnemy
    CALL st.BlinkStarsL2

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                         _Loop025                         ;
;----------------------------------------------------------;
; Tick rate: 0.5s
_Loop025

    ; Increment the counter.
    LD A, (mld.counter025)
    INC A
    LD (mld.counter025), A
    CP mld.COUNTER025_MAX
    RET NZ

    ; ##########################################
    ; Reset the counter.
    XOR A                                       ; Set A to 0
    LD (mld.counter025), A

    ; ##########################################
    ; CALL functions that need to be updated every xx-th loop.
    CALL _Loop025nFlyingRocket
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  _Loop020nFlyingRocket                   ;
;----------------------------------------------------------;
_Loop025nFlyingRocket

    ; Return if rocket is not flying.
    LD A, (ms.mainState)
    CP ms.FLY_ROCKET
    RET NZ

    ; ##########################################
    CALL gc.KillOneEnemy

    RET                                         ; ## END of the function ##


;----------------------------------------------------------;
;                         _Loop040                         ;
;----------------------------------------------------------;
; Tick rate: 4/5s
_Loop040

    ; Increment the counter.
    LD A, (mld.counter040)
    INC A
    LD (mld.counter040), A
    CP mld.COUNTER040_MAX
    RET NZ

    ; ##########################################
    ; Reset the counter.
    XOR A                                       ; Set A to 0
    LD (mld.counter040), A

    ; ##########################################
    ; CALL functions that need to be updated every xx-th loop.
    CALL _Loop040OnActiveGame

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   _Loop040OnActiveGame                   ;
;----------------------------------------------------------;
_Loop040OnActiveGame

    ; Return if game is inactive.
    LD A, (ms.mainState)
    CP ms.GAME_ACTIVE
    RET NZ

    ; ##########################################
    CALL dbs.SetupRocketBank
    CALL roa.DropNextRocketElement
    
    CALL td.NextTimeOfDayTrigger
    CALL ti.ResetTilemapOffset                  ; When intro ends quickly tilemap is sometimes off, this helps

    CALL dbs.SetupArrays2Bank
    CALL pi.PickupDropCounter

    CALL dbs.SetupPatternEnemyBank
    CALL enu.RespawnFuelThief

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                         _Loop050                         ;
;----------------------------------------------------------;
; Tick rate: 1s
_Loop050

    ; Increment the counter.
    LD A, (mld.counter050)
    INC A
    LD (mld.counter050), A
    CP mld.COUNTER050_MAX
    RET NZ

    ; ##########################################
    ; Reset the counter.
    XOR A                                       ; Set A to 0
    LD (mld.counter050), A

    ; ##########################################
    ; CALL functions that need to be updated every xx-th loop.
    CALL _Loop050OnActiveGame
    CALL _Loop050OnFlayingRocket

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  _Loop050OnActiveGame                    ;
;----------------------------------------------------------;
_Loop050OnActiveGame

    ; Return if game is inactive.
    LD A, (ms.mainState)
    CP ms.GAME_ACTIVE
    RET NZ

    CALL dbs.SetupFollowingEnemyBank
    CALL fe.NextFollowingAngle

    RET                                         ; ## END of the function ##


;----------------------------------------------------------;
;                 _Loop050OnFlayingRocket                  ;
;----------------------------------------------------------;
_Loop050OnFlayingRocket

    ; Return if rocket is not flying.
    CALL dbs.SetupRocketBank
    LD A, (ro.rocketState)
    CP ro.ROST_FLY
    RET NZ

    ; ##########################################
    ; Phase 4
    CALL dbs.SetupRocketBank

    LD A, (ro.rocketFlyPhase)
    CP ro.PHASE_4
    RET NZ

    CALL rot.DeployNextAsteroid

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                         _Loop075                         ;
;----------------------------------------------------------;
; Tick rate: 1,5s
_Loop075

    ; Increment the counter.
    LD A, (mld.counter075)
    INC A
    LD (mld.counter075), A
    CP mld.COUNTER075_MAX
    RET NZ

    ; ##########################################
    ; Reset the counter.
    XOR A                                       ; Set A to 0
    LD (mld.counter075), A

    ; ##########################################
    ; CALL functions that need to be updated every xx-th loop.
    CALL _Loop075OnActiveGame
    CALL _Loop075OnActiveGameOver
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  _Loop075OnActiveGame                    ;
;----------------------------------------------------------;
_Loop075OnActiveGame

    ; Return if game is inactive.
    LD A, (ms.mainState)
    CP ms.GAME_ACTIVE
    RET NZ

    ; ##########################################
    CALL jo.JetpackOverheatFx
    CALL gc.PlayFuelThiefFx

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;              _Loop075OnActiveGameOver                    ;
;----------------------------------------------------------;
_Loop075OnActiveGameOver

    ; Return if game is inactive.
    LD A, (ms.mainState)
    CP ms.GAME_OVER
    RET NZ

    ; ##########################################
    CALL go.GameOverLoop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                         _Loop250                         ;
;----------------------------------------------------------;
; Tick rate: 5s
_Loop250

    ; Increment the counter.
    LD A, (mld.counter250)
    INC A
    LD (mld.counter250), A
    CP mld.COUNTER250_MAX
    RET NZ

    ; ##########################################
    ; Reset the counter.
    XOR A                                       ; Set A to 0
    LD (mld.counter250), A

    ; ##########################################
    ; CALL functions that need to be updated every xx-th loop.
    CALL _Loop250OnRocketPhase4

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;               _Loop250OnRocketPhase4                     ;
;----------------------------------------------------------;
_Loop250OnRocketPhase4

    LD A, (ro.rocketFlyPhase)
    CP ro.PHASE_4
    RET NZ

    ; ##########################################
    CALL dbs.SetupRocketBank
    CALL rot.ChangeAsteroidSpeed

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                         _LastLoop                        ;
;----------------------------------------------------------;
_LastLoop

    CALL ki.KeyboardInputLastLoop
    CALL _LastLoopOnRocketPhase2_3

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;              _LastLoopOnRocketPhase2_3                   ;
;----------------------------------------------------------;
_LastLoopOnRocketPhase2_3

    CALL dbs.SetupRocketBank

    LD A, (ro.rocketFlyPhase)
    AND ro.PHASE_2_3
    RET Z

    CALL bg.HideBackgroundBars

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE