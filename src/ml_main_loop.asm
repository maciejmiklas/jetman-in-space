;----------------------------------------------------------;
;                       Main Loop                          ;
;----------------------------------------------------------;
    MODULE ml 

;----------------------------------------------------------;
;                      #MainLoop                           ;
;----------------------------------------------------------;
MainLoop

    CALL _MainLoop000
    CALL _MainLoop002
    CALL _MainLoop005

    CALL _MainLoop008
    CALL _MainLoop010
    CALL _MainLoop025
    CALL _MainLoop040
    CALL _MainLoop050
    CALL _MainLoop080
    CALL _LastLoop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                      _MainLoop000                        ;
;----------------------------------------------------------;
_MainLoop000

    ; 1 -> 0 and 0 -> 1
    LD A, (mld.counter000FliFLop)
    XOR 1
    LD (mld.counter000FliFLop), A

    ; ##########################################
    ; CALL functions that need to be updated every loop
    ; First update graphics, logic follows afterwards!

    CALL gb.PrintDebug

    CALL dbs.SetupAyFxsBank
    CALL af.AfxFrame                            ; Keep AYFX sound effect playing
    
    CALL dbs.SetupMusicBank
    CALL am.MusicLoop

    CALL _MainLoop000OnPause
    CALL _MainLoop000OnActiveGame
    CALL _MainLoop000OnActiveMenuMain
    CALL _MainLoop000OnNotInGame
    CALL _MainLoop000OnFlayRocket
    CALL _MainLoop000OnActiveLevelIntro

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   _MainLoop000OnPause                    ;
;----------------------------------------------------------;
_MainLoop000OnPause

    LD A, (ms.mainState)
    CP ms.PAUSE
    RET NZ

    CALL gi.GameKeyboardInput

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                _MainLoop000OnFlayRocket                  ;
;----------------------------------------------------------;
_MainLoop000OnFlayRocket

    ; Return if rocket is not flying. #ms.mainState has also similar state: #FLY_ROCKET, but its not the same!
    ; Rocket is also exploding, in this case #ms.mainState == #Fms.LY_ROCKET but #ro.rocketState == #ro.ROST_EXPLODE and not #ro.ROST_FLY
    LD A, (ro.rocketState)
    CP ro.ROST_FLY
    RET NZ

    ; ##########################################
    CALL rof.FlyRocket
    CALL rof.FlyRocketSound
    CALL ros.AnimateStarsOnFlyRocket

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                _MainLoop000OnActiveGame                  ;
;----------------------------------------------------------;
_MainLoop000OnActiveGame

    ; Return if game is inactive
    LD A, (ms.mainState)
    CP ms.GAME_ACTIVE
    RET NZ

    ; ##########################################
    CALL _MainLoop000OnDisabledJoy
    CALL gi.GameJoystickInput
    CALL ro.CheckHitTank
    CALL jco.JetRip
    CALL jw.MoveShots
    CALL gc.WeaponHitEnemies
    CALL jw.FireDelayCounter
    CALL gi.GameKeyboardInput
    CALL jco.JetmanEnemiesCollision
    CALL js.UpdateJetSpritePositionRotation
    CALL js.AnimateJetSprite
    CALL jco.JetInvincible
    CALL ro.RocketElementFallsForPickup

    CALL dbs.SetupPatternEnemyBank
    CALL enu.MoveFuelThief
    CALL enu.ThiefWeaponHit

    ; ##########################################
    ; Move enemies for normal or hard
    LD A, (jt.difLevel)
    CP jt.DIF_EASY
    JR Z, .onEasy
    CALL dbs.SetupPatternEnemyBank
    CALL ens.MoveSingleEnemies
    CALL enf.MoveFormationEnemies

    CALL dbs.SetupFollowingEnemyBank
    CALL fe.MoveFollowingEnemies
.onEasy

    ; ##########################################
    ; Faster movement speed for Jetman on hard
    LD A, (jt.difLevel)
    CP jt.DIF_HARD
    JR NZ, .notHard

    ; Do not speed up animations, like falling from the platform
    LD A, (gid.joyOffCnt)
    CP 0
    JR NZ, .notHard

    CALL gi.GameJoystickInput
.notHard

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 _MainLoop000OnNotInGame                  ;
;----------------------------------------------------------;
_MainLoop000OnNotInGame

    ; Return if main menu is inactive
    LD A, (ms.mainState)
    CP ms.GAME_ACTIVE
    RET Z

    ; ##########################################
    CALL ki.KeyboardInput

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;               _MainLoop000OnActiveMenuMain               ;
;----------------------------------------------------------;
_MainLoop000OnActiveMenuMain

    ; Return if main menu is inactive
    LD A, (ms.mainState)
    CP ms.MENU_MAIN
    RET NZ

    ; ##########################################
    CALL js.UpdateJetSpritePositionRotation
    CALL js.AnimateJetSprite

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;              _MainLoop000OnActiveLevelIntro              ;
;----------------------------------------------------------;
_MainLoop000OnActiveLevelIntro

    ; Return if intro is inactive
    LD A, (ms.mainState)
    CP ms.LEVEL_INTRO
    RET NZ

    ; ##########################################
    CALL li.AnimateLevelIntroTextScroll

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                _MainLoop000OnDisabledJoy                 ;
;----------------------------------------------------------;
_MainLoop000OnDisabledJoy

    ; Return if game is inactive
    LD A, (ms.mainState)
    CP ms.GAME_ACTIVE
    RET NZ

    ; Return if the joystick is about to enable
    LD A, (gid.joyOffCnt)
    CP pl.PL_BUMP_JOY_DEC_D1+1
    RET C                                       ; Return on the last off loop - this one is used to reset status and not to animate

    ; ##########################################
    CALL pl.MoveJetOnPlatformSideHit
    CALL pl.MoveJetOnFallingFromPlatform
    CALL pl.MoveJetOnHitPlatformBelow
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        _MainLoop002                      ;
;----------------------------------------------------------;
; Tick rate: 1/25s
_MainLoop002

    ; Increment the counter
    LD A, (mld.counter002)
    INC A
    LD (mld.counter002), A
    CP mld.COUNTER002_MAX
    RET NZ

    ; Reset the counter
    XOR A                                       ; Set A to 0
    LD (mld.counter002), A

    ; ##########################################
    ; 1 -> 0 and 0 -> 1
    LD A, (mld.counter002FliFLop)
    XOR 1
    LD (mld.counter002FliFLop), A

    ; ##########################################
    ; CALL functions that need to be updated every xx-th loop
    CALL _MainLoop002OnActiveGame

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                _MainLoop002OnActiveGame                  ;
;----------------------------------------------------------;
_MainLoop002OnActiveGame

    ; Return if game is inactive
    LD A, (ms.mainState)
    CP ms.GAME_ACTIVE
    RET NZ

    ; ##########################################
    LD A, (jt.difLevel)
    CP jt.DIF_EASY
    JR NZ, .notEasy
    
    CALL dbs.SetupPatternEnemyBank
    CALL ens.MoveSingleEnemies
    CALL enf.MoveFormationEnemies

    CALL dbs.SetupFollowingEnemyBank
    CALL fe.MoveFollowingEnemies
.notEasy

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      _MainLoop004                        ;
;----------------------------------------------------------;
; Tick rate: 1/10s
_MainLoop005

    ; Increment the counter
    LD A, (mld.counter005)
    INC A
    LD (mld.counter005), A
    CP mld.COUNTER005_MAX
    RET NZ
    
    ; Reset the counter
    XOR A                                       ; Set A to 0
    LD (mld.counter005), A

    ; ##########################################
    ; 1 -> 0 and 0 -> 1
    LD A, (mld.counter005FliFLop)
    XOR 1
    LD (mld.counter005FliFLop), A

    ; ##########################################
    ; CALL functions that need to be updated every xx-th loop
    CALL _MainLoop005OnRocketExplosion
    CALL _MainLoop005OnActiveGame

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;              _MainLoop005OnRocketExplosion               ;
;----------------------------------------------------------;
_MainLoop005OnRocketExplosion
    ; Is rocket exploding ?
    LD A, (ro.rocketState)
    CP ro.ROST_EXPLODE
    RET NZ

    ; ##########################################
    CALL rof.AnimateRocketExplosion
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 _MainLoop005OnActiveGame                 ;
;----------------------------------------------------------;
_MainLoop005OnActiveGame

    ; Return if game is not active
    LD A, (ms.mainState)
    CP ms.GAME_ACTIVE
    RET NZ

    ; ##########################################
    CALL ro.RocketElementFallsForAssembly
    CALL jo.UpdateJetpackOverheating
    CALL pi.AnimateFallingPickup

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      _MainLoop008                        ;
;----------------------------------------------------------;
; Tick rate: ±1/6s
_MainLoop008

    ; Increment the counter
    LD A, (mld.counter008)
    INC A
    LD (mld.counter008), A
    CP mld.COUNTER008_MAX
    RET NZ

    ; Reset the counter
    XOR A                                       ; Set A to 0
    LD (mld.counter008), A

    ; ##########################################
    ; 1 -> 0 and 0 -> 1
    LD A, (mld.counter008FliFLop)
    XOR 1
    LD (mld.counter008FliFLop), A

    ; ##########################################
    ; CALL functions that need to be updated every xx-th loop
    CALL _MainLoop008OnActiveGame

    CALL _MainLoop008OnActiveGameOrFlyingRocket
    CALL _MainLoop008OnFlayingRocket
    CALL _MainLoop008OnActiveScoreMenu

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;             _MainLoop008OnActiveScoreMenu                ;
;----------------------------------------------------------;
_MainLoop008OnActiveScoreMenu

    LD A, (ms.mainState)
    CP ms.MENU_SCORE
    RET NZ

    ; ##########################################
    CALL mms.AnimateCursor

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;               _MainLoop008OnFlayingRocket                ;
;----------------------------------------------------------;
_MainLoop008OnFlayingRocket
    ; Return if rocket is not flying
    LD A, (ro.rocketState)
    CP ro.ROST_FLY
    RET NZ

    ; ##########################################
    CALL rof.AnimateRocketExhaust
    CALL rof.BlinkFlyingRocket
    CALL st.BlinkStarsL1

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 _MainLoop008OnActiveGame                 ;
;----------------------------------------------------------;
_MainLoop008OnActiveGame

    ; Return if game is inactive
    LD A, (ms.mainState)
    CP ms.GAME_ACTIVE
    RET NZ

    ; ##########################################
    CALL jw.AnimateShots
    CALL ro.BlinkRocketReady
    CALL ro.AnimateTankExplode
    CALL st.BlinkStarsL1
    CALL jo.AnimateJetpackOverheat

    CALL dbs.SetupPatternEnemyBank
    CALL enu.AnimateFuelThief

    ; ##########################################
    ; Hard
    LD A, (jt.difLevel)
    CP jt.DIF_HARD
    JR NZ, .notHard

    CALL dbs.SetupPatternEnemyBank
    CALL ens.MoveSingleEnemies
    CALL ens.RespawnNextSingleEnemy

    CALL dbs.SetupFollowingEnemyBank
    CALL fe.MoveFollowingEnemies
    CALL fe.RespawnFollowingEnemy
.notHard

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;          _MainLoop008OnActiveGameOrFlyingRocket          ;
;----------------------------------------------------------;
_MainLoop008OnActiveGameOrFlyingRocket

    ; Is Game active?
    LD A, (ms.mainState)
    CP ms.GAME_ACTIVE
    JR NZ, .gameInactive
    JR .execute
.gameInactive
    ; Game ist inactive, what about rocket?
    LD A, (ro.rocketState)
    CP ro.ROST_FLY
    RET NZ                                          ; Return if rocket is not flying

.execute
    ; ##########################################
    CALL dbs.SetupPatternEnemyBank
    CALL enp.AnimatePatternEnemies

    CALL dbs.SetupFollowingEnemyBank
    CALL fe.AnimateFollowingEnemies

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      _MainLoop010                        ;
;----------------------------------------------------------;
; Tick rate: 1/5s
_MainLoop010

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
    ; CALL functions that need to be updated every xx-th loop
    CALL _MainLoop010OnActiveGame

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 _MainLoop010OnActiveGame                 ;
;----------------------------------------------------------;
_MainLoop010OnActiveGame

    ; Return if game is inactive
    LD A, (ms.mainState)
    CP ms.GAME_ACTIVE
    RET NZ

    ; ##########################################
    CALL dbs.SetupPatternEnemyBank
    CALL enf.RespawnFormation
    CALL ens.RespawnNextSingleEnemy

    CALL dbs.SetupFollowingEnemyBank
    CALL fe.RespawnFollowingEnemy

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       _MainLoop025                       ;
;----------------------------------------------------------;
; Tick rate: 0.5s
_MainLoop025

    ; Increment the counter
    LD A, (mld.counter025)
    INC A
    LD (mld.counter025), A
    CP mld.COUNTER025_MAX
    RET NZ

    ; ##########################################
    ; Reset the counter
    XOR A                                       ; Set A to 0
    LD (mld.counter025), A

    ; ##########################################
    ; CALL functions that need to be updated every xx-th loop
    CALL _MainLoop025nFlyingRocket
    CALL _MainLoop025OnActiveGame

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 _MainLoop025OnActiveGame                 ;
;----------------------------------------------------------;
_MainLoop025OnActiveGame

    ; Return if game is inactive
    LD A, (ms.mainState)
    CP ms.GAME_ACTIVE
    RET NZ

    ; ##########################################
    CALL dbs.SetupFollowingEnemyBank
    CALL fe.UpdateFollowingJetman

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                _MainLoop020nFlyingRocket                 ;
;----------------------------------------------------------;
_MainLoop025nFlyingRocket

    ; Return if rocket is not flying
    LD A, (ms.mainState)
    CP ms.FLY_ROCKET
    RET NZ

    ; ##########################################
    CALL dbs.SetupPatternEnemyBank
    CALL enp.KillOnePatternEnemy

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       _MainLoop040                       ;
;----------------------------------------------------------;
; Tick rate: 4/5s
_MainLoop040

    ; Increment the counter
    LD A, (mld.counter040)
    INC A
    LD (mld.counter040), A
    CP mld.COUNTER040_MAX
    RET NZ

    ; ##########################################
    ; Reset the counter
    XOR A                                       ; Set A to 0
    LD (mld.counter040), A

    ; ##########################################
    ; CALL functions that need to be updated every xx-th loop
    CALL _MainLoop040OnActiveGame

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 _MainLoop040OnActiveGame                 ;
;----------------------------------------------------------;
_MainLoop040OnActiveGame

    ; Return if game is inactive
    LD A, (ms.mainState)
    CP ms.GAME_ACTIVE
    RET NZ

    ; ##########################################
    CALL ro.DropNextRocketElement
    CALL td.NextTimeOfDayTrigger
    CALL pi.PickupDropCounter
    CALL ti.ResetTilemapOffset                  ; When intro ends quickly tilemap is sometimes off, this helps
    CALL dbs.SetupPatternEnemyBank: CALL enu.RespawnFuelThief

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       _MainLoop050                       ;
;----------------------------------------------------------;
; Tick rate: 1s
_MainLoop050

    ; Increment the counter
    LD A, (mld.counter050)
    INC A
    LD (mld.counter050), A
    CP mld.COUNTER050_MAX
    RET NZ

    ; ##########################################
    ; Reset the counter
    XOR A                                       ; Set A to 0
    LD (mld.counter050), A

    ; ##########################################
    ; CALL functions that need to be updated every xx-th loop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       _MainLoop080                       ;
;----------------------------------------------------------;
; Tick rate: 1,6s
_MainLoop080

    ; Increment the counter
    LD A, (mld.counter080)
    INC A
    LD (mld.counter080), A
    CP mld.COUNTER080_MAX
    RET NZ

    ; ##########################################
    ; Reset the counter
    XOR A                                       ; Set A to 0
    LD (mld.counter080), A

    ; ##########################################
    ; CALL functions that need to be updated every xx-th loop
    CALL _MainLoop080OnActiveGame
    CALL _MainLoop080OnActiveGameOver
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                _MainLoop080OnActiveGame                  ;
;----------------------------------------------------------;
_MainLoop080OnActiveGame

    ; Return if game is inactive
    LD A, (ms.mainState)
    CP ms.GAME_ACTIVE
    RET NZ

    ; ##########################################
    CALL jo.JetpackOverheatFx
    CALL gc.PlayFuelThiefFx
    CALL fe.RandomizeFollowingAngle

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;            _MainLoop080OnActiveGameOver                  ;
;----------------------------------------------------------;
_MainLoop080OnActiveGameOver

    ; Return if game is inactive
    LD A, (ms.mainState)
    CP ms.GAME_OVER
    RET NZ

    ; ##########################################
    CALL go.GameOverLoop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                         _LastLoop                        ;
;----------------------------------------------------------;
_LastLoop

    CALL ki.KeyboardInputLastLoop
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE