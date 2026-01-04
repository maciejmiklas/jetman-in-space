/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                       Main Loop                          ;
;----------------------------------------------------------;
    MODULE ml 


;----------------------------------------------------------;
;----------------------------------------------------------;
;                        MACROS                            ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                         _Loop000                         ;
;----------------------------------------------------------;
    MACRO _Loop000

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

    _Loop000OnRocketPhase2_3
    _Loop000OnPause
    _Loop000OnActiveGame
    _Loop000OnActiveMain
    _Loop000OnNotInGame
    _Loop000OnActiveLevelIntro
    _Loop000OnFlyRocket

    ENDM                                         ; ## END of the macro ##

;----------------------------------------------------------;
;                  _Loop000OnFlyRocket                     ;
;----------------------------------------------------------;
    MACRO _Loop000OnFlyRocket

    CALL dbs.SetupRocketBank

    ; Return if rocket is not flying. #ms.mainState has also similar state: #FLY_ROCKET, but its not the same!
    ; Rocket is also exploding, in this case #ms.mainState == #Fms.LY_ROCKET but #ro.rocketState == #ro.ROST_EXPLODE and not #ro.ROST_FLY.
    LD A, (ro.rocketState)
    CP ro.ROST_FLY
    JR NZ, .end

    ; ##########################################
    CALL rof.FlyRocket
    CALL rof.FlyRocketSound

    ; ##########################################
    ; Phase 4
    CALL dbs.SetupRocketBank

    LD A, (ro.rocketFlyPhase)
    CP ro.PHASE_4
    JR NZ, .end

    CALL rot.MoveAsteroids

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                _Loop000OnActiveLevelIntro                ;
;----------------------------------------------------------;
    MACRO _Loop000OnActiveLevelIntro

    ; Return if intro is inactive.
    LD A, (ms.mainState)
    CP ms.LEVEL_INTRO
    JR NZ, .end

    ; ##########################################
    CALL li.AnimateLevelIntroTextScroll

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                   _Loop000OnNotInGame                    ;
;----------------------------------------------------------;
    MACRO _Loop000OnNotInGame

    ; Return if menu is not active.
    LD A, (ms.mainState)
    CP ms.LEVEL_INTRO
    JR C, .end

    ; ##########################################
    CALL ki.KeyboardInput

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                   _Loop000OnActiveMain                   ;
;----------------------------------------------------------;
    MACRO _Loop000OnActiveMain

    ; Execute if main menu or level select menu is inactive.
    LD A, (ms.mainState)
    
    CP ms.MENU_MAIN
    JR Z, .execute

    CP ms.MENU_LEVEL
    JR Z, .execute

    JR .end

.execute
    ; ##########################################
    CALL js.UpdateJetSpritePositionRotation
    CALL js.AnimateJetSprite

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                  _Loop000OnActiveGame                    ;
;----------------------------------------------------------;
    MACRO _Loop000OnActiveGame

    ; Return if game is inactive
    LD A, (ms.mainState)
    CP ms.GAME_ACTIVE
    JP NZ, .end

    ; ##########################################
    _Loop000OnDisabledJoy
    CALL gi.JetMovementInput
    CALL gi.GameOptionsInput

    CALL jco.JetRip
    CALL jw.MoveShots
    CALL gc.WeaponHitEnemy
    CALL jw.FireDelayCounter
    JetmanEnemiesCollision
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

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                  _Loop000OnDisabledJoy                   ;
;----------------------------------------------------------;
    MACRO _Loop000OnDisabledJoy

    ; Return if game is inactive.
    LD A, (ms.mainState)
    CP ms.GAME_ACTIVE
    JR NZ, .end

    ; Return if the joystick is about to enable.
    LD A, (gid.joyOffCnt)
    CP pl.PL_BUMP_JOY_DEC_D1+1
    JR C, .end                                  ; Return on the last off loop - this one is used to reset status and not to animate

    ; ##########################################
    CALL pl.MoveJetOnPlatformSideHit
    CALL pl.MoveJetOnFallingFromPlatform
    CALL pl.MoveJetOnHitPlatformBelow

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                     _Loop000OnPause                      ;
;----------------------------------------------------------;
    MACRO _Loop000OnPause

    LD A, (ms.mainState)
    CP ms.PAUSE
    JR NZ, .end

    CALL gi.GameOptionsInput

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;               _Loop000OnRocketPhase2_3                   ;
;----------------------------------------------------------;
    MACRO _Loop000OnRocketPhase2_3

    CALL dbs.SetupRocketBank

    LD A, (ro.rocketFlyPhase)
    AND ro.PHASE_2_3
    JR Z, .end

    CALL bg.HideBackgroundBars

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                      _Loop002                            ;
;----------------------------------------------------------;
; Tick rate: 1/25s
    MACRO _Loop002

    ; Increment the counter.
    LD A, (mld.counter002)
    INC A
    LD (mld.counter002), A
    CP mld.COUNTER002_MAX
    JR NZ, .end

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
    _Loop002OnActiveGame

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                  _Loop002OnActiveGame                    ;
;----------------------------------------------------------;
    MACRO _Loop002OnActiveGame

    ; Return if game is inactive.
    LD A, (ms.mainState)
    CP ms.GAME_ACTIVE
    JR NZ, .end

    ; ##########################################
    LD A, (jt.difLevel)
    CP jt.DIF_EASY
    JR NZ, .notEasy

    CALL gc.MoveEnemies
.notEasy

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                        _Loop005                          ;
;----------------------------------------------------------;
; Tick rate: 1/10s
    MACRO _Loop005

    ; Increment the counter.
    LD A, (mld.counter005)
    INC A
    LD (mld.counter005), A
    CP mld.COUNTER005_MAX
    JR NZ, .end

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
    _Loop005OnActiveGame

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                   _Loop005OnActiveGame                   ;
;----------------------------------------------------------;
    MACRO _Loop005OnActiveGame

    ; Return if game is not active.
    LD A, (ms.mainState)
    CP ms.GAME_ACTIVE
    JR NZ, .end

    ; ##########################################
    CALL dbs.SetupRocketBank
    CALL roa.RocketElementFallsForAssembly

    CALL jo.UpdateJetpackOverheating

    CALL dbs.SetupArrays2Bank
    CALL pi.AnimateFallingPickup

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                        _Loop008                          ;
;----------------------------------------------------------;
; Tick rate: ±1/6s
    MACRO _Loop008

    ; Increment the counter.
    LD A, (mld.counter008)
    INC A
    LD (mld.counter008), A
    CP mld.COUNTER008_MAX
    JP NZ, .end

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
    _Loop008OnActiveGame
    _Loop008OnActiveScoreMenu
    _Loop008OnFlayingRocket
    _Loop008OnRocketExplosion

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                _Loop008OnRocketExplosion                 ;
;----------------------------------------------------------;
    MACRO _Loop008OnRocketExplosion

    CALL dbs.SetupRocketBank

    ; Is rocket exploding ?
    LD A, (ro.rocketState)
    CP ro.ROST_EXPLODE
    JR NZ, .end

    ; ##########################################
    CALL st.BlinkStars

    CALL dbs.SetupRocketBank
    CALL rot.AnimateAsteroids
    CALL rof.AnimateRocketExplosion

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;               _Loop008OnActiveScoreMenu                  ;
;----------------------------------------------------------;
    MACRO _Loop008OnActiveScoreMenu

    LD A, (ms.mainState)
    CP ms.MENU_SCORE
    JR NZ, .end

    ; ##########################################
    CALL mms.AnimateCursor

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                 _Loop008OnFlayingRocket                  ;
;----------------------------------------------------------;
    MACRO _Loop008OnFlayingRocket

    ; Return if rocket is not flying.
    CALL dbs.SetupRocketBank
    LD A, (ro.rocketState)
    CP ro.ROST_FLY
    JR NZ, .end

    ; ##########################################
    CALL st.BlinkStars

    CALL dbs.SetupRocketBank
    CALL rof.AnimateRocketExhaust
    CALL rof.BlinkFlyingRocket
    CALL gc.AnimateEnemies

    ; ##########################################
    ; Phase 4
    CALL dbs.SetupRocketBank

    LD A, (ro.rocketFlyPhase)
    CP ro.PHASE_4
    JR NZ, .end

    CALL rot.AnimateAsteroids

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                   _Loop008OnActiveGame                   ;
;----------------------------------------------------------;
    MACRO _Loop008OnActiveGame

    ; Return if game is inactive.
    LD A, (ms.mainState)
    CP ms.GAME_ACTIVE
    JR NZ, .end

    ; ##########################################
    CALL jw.AnimateShots

    CALL dbs.SetupRocketBank
    CALL roa.BlinkRocketReady
    CALL roa.AnimateTankExplode

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

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                        _Loop010                          ;
;----------------------------------------------------------;
; Tick rate: 1/5s
    MACRO _Loop010

    ; Increment the counter
    LD A, (mld.counter010)
    INC A
    LD (mld.counter010), A
    CP mld.COUNTER010_MAX
    JR NZ, .end

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
    _Loop010OnActiveGame

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                   _Loop010OnActiveGame                   ;
;----------------------------------------------------------;
    MACRO _Loop010OnActiveGame

    ; Return if game is inactive.
    LD A, (ms.mainState)
    CP ms.GAME_ACTIVE
    JR NZ, .end

    ; ##########################################
    CALL dbs.SetupPatternEnemyBank
    CALL enf.RespawnFormation
    CALL gc.RespawnEnemy
    CALL st.BlinkStars

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                         _Loop025                         ;
;----------------------------------------------------------;
; Tick rate: 0.5s
    MACRO _Loop025

    ; Increment the counter.
    LD A, (mld.counter025)
    INC A
    LD (mld.counter025), A
    CP mld.COUNTER025_MAX
    JR NZ, .end

    ; ##########################################
    ; Reset the counter.
    XOR A                                       ; Set A to 0
    LD (mld.counter025), A

    ; ##########################################
    ; CALL functions that need to be updated every xx-th loop.
    _Loop025nFlyingRocket

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                  _Loop020nFlyingRocket                   ;
;----------------------------------------------------------;
    MACRO _Loop025nFlyingRocket

    ; Return if rocket is not flying.
    LD A, (ms.mainState)
    CP ms.FLY_ROCKET
    JR NZ, .end

    ; ##########################################
    CALL gc.KillOneEnemy

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                         _Loop040                         ;
;----------------------------------------------------------;
; Tick rate: 4/5s
    MACRO _Loop040

    ; Increment the counter.
    LD A, (mld.counter040)
    INC A
    LD (mld.counter040), A
    CP mld.COUNTER040_MAX
    JR NZ, .end

    ; ##########################################
    ; Reset the counter.
    XOR A                                       ; Set A to 0
    LD (mld.counter040), A

    ; ##########################################
    ; CALL functions that need to be updated every xx-th loop.
    _Loop040OnActiveGame

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                   _Loop040OnActiveGame                   ;
;----------------------------------------------------------;
    MACRO _Loop040OnActiveGame

    ; Return if game is inactive.
    LD A, (ms.mainState)
    CP ms.GAME_ACTIVE
    JR NZ, .end

    ; ##########################################
    CALL dbs.SetupRocketBank
    CALL roa.DropNextRocketElement
    
    CALL td.NextTimeOfDayTrigger
    CALL ti.ResetTilemapOffset                  ; When intro ends quickly tilemap is sometimes off, this helps

    CALL dbs.SetupArrays2Bank
    CALL pi.PickupDropCounter

    CALL dbs.SetupPatternEnemyBank
    CALL enu.RespawnFuelThief

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                         _Loop050                         ;
;----------------------------------------------------------;
; Tick rate: 1s
    MACRO _Loop050

    ; Increment the counter.
    LD A, (mld.counter050)
    INC A
    LD (mld.counter050), A
    CP mld.COUNTER050_MAX
    JR NZ, .end

    ; ##########################################
    ; Reset the counter.
    XOR A                                       ; Set A to 0
    LD (mld.counter050), A

    ; ##########################################
    ; CALL functions that need to be updated every xx-th loop.
    _Loop050OnActiveGame
    _Loop050OnFlayingRocket

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                  _Loop050OnActiveGame                    ;
;----------------------------------------------------------;
    MACRO _Loop050OnActiveGame

    ; Return if game is inactive.
    LD A, (ms.mainState)
    CP ms.GAME_ACTIVE
    JR NZ, .end

    CALL dbs.SetupFollowingEnemyBank
    CALL fe.NextFollowingAngle

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                 _Loop050OnFlayingRocket                  ;
;----------------------------------------------------------;
    MACRO _Loop050OnFlayingRocket

    ; Return if rocket is not flying.
    CALL dbs.SetupRocketBank
    LD A, (ro.rocketState)
    CP ro.ROST_FLY
    JR NZ, .end

    ; ##########################################
    ; Phase 4
    CALL dbs.SetupRocketBank

    LD A, (ro.rocketFlyPhase)
    CP ro.PHASE_4
    JR NZ, .end

    CALL rot.DeployNextAsteroid

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                         _Loop075                         ;
;----------------------------------------------------------;
; Tick rate: 1,5s
    MACRO _Loop075

    ; Increment the counter.
    LD A, (mld.counter075)
    INC A
    LD (mld.counter075), A
    CP mld.COUNTER075_MAX
    JR NZ, .end

    ; ##########################################
    ; Reset the counter.
    XOR A                                       ; Set A to 0
    LD (mld.counter075), A

    ; ##########################################
    ; CALL functions that need to be updated every xx-th loop.
    _Loop075OnActiveGame
    _Loop075OnActiveGameOver

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                  _Loop075OnActiveGame                    ;
;----------------------------------------------------------;
    MACRO _Loop075OnActiveGame

    ; Return if game is inactive.
    LD A, (ms.mainState)
    CP ms.GAME_ACTIVE
    JR NZ, .end

    ; ##########################################
    CALL jo.JetpackOverheatFx
    CALL gc.PlayFuelThiefFx

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;              _Loop075OnActiveGameOver                    ;
;----------------------------------------------------------;
    MACRO _Loop075OnActiveGameOver

    ; Return if game is inactive.
    LD A, (ms.mainState)
    CP ms.GAME_OVER
    JR NZ, .end

    ; ##########################################
    CALL go.GameOverLoop

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                         _Loop150                         ;
;----------------------------------------------------------;
; Tick rate: 5s
    MACRO _Loop150

    ; Increment the counter.
    LD A, (mld.counter150)
    INC A
    LD (mld.counter150), A
    CP mld.counter150_MAX
    JR NZ, .end

    ; ##########################################
    ; Reset the counter.
    XOR A                                       ; Set A to 0
    LD (mld.counter150), A

    ; ##########################################
    ; CALL functions that need to be updated every xx-th loop.
    _Loop150OnRocketPhase4

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;               _Loop150OnRocketPhase4                     ;
;----------------------------------------------------------;
    MACRO _Loop150OnRocketPhase4

    LD A, (ro.rocketFlyPhase)
    CP ro.PHASE_4
    JR NZ, .end

    ; ##########################################
    CALL dbs.SetupRocketBank
    CALL rot.ChangeAsteroidSpeed

    ; When flying a rocket and avoiding asteroids, the score increases with asteroid speed change.
    CALL sc.HitEnemy2

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                         _LastLoop                        ;
;----------------------------------------------------------;
    MACRO _LastLoop

    CALL ki.KeyboardInputLastLoop
    _LastLoopOnRocketPhase2_3

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;              _LastLoopOnRocketPhase2_3                   ;
;----------------------------------------------------------;
    MACRO _LastLoopOnRocketPhase2_3

    CALL dbs.SetupRocketBank

    LD A, (ro.rocketFlyPhase)
    AND ro.PHASE_2_3
    JR Z, .end

    CALL bg.HideBackgroundBars

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PUBLIC FUNCTIONS                       ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                      #MainLoop                           ;
;----------------------------------------------------------;
MainLoop

    _Loop000
    _Loop002
    _Loop005
    _Loop008
    _Loop010
    _Loop025
    _Loop040
    _Loop050
    _Loop075
    _Loop150
    _LastLoop

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