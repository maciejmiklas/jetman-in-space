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
    CALL _MainLoop004
    CALL _MainLoop006
    CALL _MainLoop008
    CALL _MainLoop010
    CALL _MainLoop015
    CALL _MainLoop020
    CALL _MainLoop040
    CALL _MainLoop080
    CALL _LastLoop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                     #_MainLoop000                        ;
;----------------------------------------------------------;
_MainLoop000

    ; 1 -> 0 and 0 -> 1
    LD A, (mld.counter000FliFLop)
    XOR 1
    LD (mld.counter000FliFLop), A

    ; ##########################################
    ; CALL functions that need to be updated every loop.
    ; First update graphics, logic follows afterwards!

    CALL gb.PrintDebug
    CALL af.AfxFrame                            ; Keep AYFX sound effect playing

    CALL _MainLoop000OnActiveGame
    CALL _MainLoop000OnActiveMenuMain
    CALL _MainLoop000OnActiveMenuManual
    CALL _MainLoop000OnActiveMenuScore
    CALL _MainLoop000OnFlayRocket
    CALL _MainLoop000OnActiveLevelIntro

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;               #_MainLoop000OnFlayRocket                  ;
;----------------------------------------------------------;
_MainLoop000OnFlayRocket

    ; Return if rocket is not flying. #ms.mainState has also similar state: #FLY_ROCKET, but its not the same!
    ; Rocket is also exploding, in this case #ms.mainState == #Fms.LY_ROCKET but #ro.rocketState == #ro.ROST_EXPLODE and not #ro.ROST_FLY!
    LD A, (ro.rocketState)
    CP ro.ROST_FLY
    RET NZ

    ; ##########################################
    CALL rof.FlyRocket
    CALL ros.AnimateStarsOnFlyRocket

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;               #_MainLoop000OnActiveGame                  ;
;----------------------------------------------------------;
_MainLoop000OnActiveGame

    ; Return if game is inactive.
    LD A, (ms.mainState)
    CP ms.GAME_ACTIVE
    RET NZ

    ; ##########################################
    CALL _MainLoop000OnDisabledJoy
    CALL gi.GameJoystickInput
    CALL ro.CheckHitTank
    CALL jco.JetRip
    CALL jw.MoveShots
    CALL jw.WeaponHitEnemies
    CALL jw.FireDelayCounter
    CALL gi.GameKeyboardInput
    CALL jco.JetmanEnemiesCollision
    CALL js.UpdateJetSpritePositionRotation
    CALL js.AnimateJetSprite
    CALL jco.JetInvincible
    CALL ro.RocketElementFallsForPickup

    ; ##########################################
    ; Move enemies for normal or hard.
    LD A, (jt.difLevel)
    CP jt.DIF_EASY
    JR Z, .onEasy
    CALL ens.MoveSingleEnemies
    CALL enf.MoveFormationEnemies
.onEasy

    ; ##########################################
    ; Extra speed on hard!
    LD A, (jt.difLevel)
    CP jt.DIF_HARD
    JR NZ, .notHard
    CALL ens.MoveSingleEnemies
    CALL enf.MoveFormationEnemies
    CALL gi.GameJoystickInput
.notHard

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;              #_MainLoop000OnActiveMenuMain               ;
;----------------------------------------------------------;
_MainLoop000OnActiveMenuMain

    ; Return if main menu is inactive.
    LD A, (ms.mainState)
    CP ms.MENU_MAIN
    RET NZ

    ; ##########################################
    CALL mma.MenuMainUserInput
    CALL js.UpdateJetSpritePositionRotation
    CALL js.AnimateJetSprite

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;            #_MainLoop000OnActiveMenuManual               ;
;----------------------------------------------------------;
_MainLoop000OnActiveMenuManual

    ; Return if manual menu is inactive.
    LD A, (ms.mainState)
    CP ms.MENU_MANUAL
    RET NZ

    ; ##########################################
    CALL mmn.MenuManualUserInput
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;            #_MainLoop000OnActiveMenuScore                ;
;----------------------------------------------------------;
_MainLoop000OnActiveMenuScore

    ; Return if manual menu is inactive.
    LD A, (ms.mainState)
    CP ms.MENU_SCORE
    RET NZ

    ; ##########################################
    CALL mms.MenuScoreUserInput
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;             #_MainLoop000OnActiveLevelIntro              ;
;----------------------------------------------------------;
_MainLoop000OnActiveLevelIntro

    ; Return if intro is inactive.
    LD A, (ms.mainState)
    CP ms.LEVEL_INTRO
    RET NZ

    ; ##########################################
    CALL li.LevelIntroUserInput
    CALL li.AnimateLevelIntroTextScroll

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;               #_MainLoop000OnDisabledJoy                 ;
;----------------------------------------------------------;
_MainLoop000OnDisabledJoy

    ; Return if game is inactive.
    LD A, (ms.mainState)
    CP ms.GAME_ACTIVE
    RET NZ

    ; Return if the joystick is about to enable
    LD A, (gid.joyOffCnt)
    CP pl.PL_BUMP_JOY_DEC_D1+1
    RET C                                       ; Return on the last off loop - this one is used to reset status and not to animate.

    ; ##########################################
    CALL pl.MoveJetOnPlatformSideHit
    CALL pl.MoveJetOnFallingFromPlatform
    CALL pl.MoveJetOnHitPlatformBelow
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       #_MainLoop002                      ;
;----------------------------------------------------------;
_MainLoop002

    ; Increment the counter.
    LD A, (mld.counter002)
    INC A
    LD (mld.counter002), A
    CP mld.COUNTER002_MAX
    RET NZ

    ; Reset the counter.
    XOR A                                       ; Set A to 0.
    LD (mld.counter002), A

    ; ##########################################
    ; 1 -> 0 and 0 -> 1
    LD A, (mld.counter002FliFLop)
    XOR 1
    LD (mld.counter002FliFLop), A

    ; ##########################################
    ; CALL functions that need to be updated every xx-th loop.
    CALL _MainLoop002OnActiveGame

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;               #_MainLoop002OnActiveGame                  ;
;----------------------------------------------------------;
_MainLoop002OnActiveGame

    ; Return if game is inactive.
    LD A, (ms.mainState)
    CP ms.GAME_ACTIVE
    RET NZ

    ; ##########################################
    LD A, (jt.difLevel)
    CP jt.DIF_EASY
    JR NZ, .notEasy
    CALL Z, ens.MoveSingleEnemies
    CALL Z, enf.MoveFormationEnemies
.notEasy

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     #_MainLoop004                        ;
;----------------------------------------------------------;
_MainLoop004

    ; Increment the counter.
    LD A, (mld.counter004)
    INC A
    LD (mld.counter004), A
    CP mld.COUNTER004_MAX
    RET NZ
    
    ; Reset the counter.
    XOR A                                       ; Set A to 0
    LD (mld.counter004), A

    ; ##########################################
    ; 1 -> 0 and 0 -> 1
    LD A, (mld.counter004FliFLop)
    XOR 1
    LD (mld.counter004FliFLop), A

    ; ##########################################
    ; CALL functions that need to be updated every xx-th loop.
    CALL _MainLoop004OnRocketExplosion
    CALL _MainLoop004OnActiveGame

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;             #_MainLoop004OnRocketExplosion               ;
;----------------------------------------------------------;
_MainLoop004OnRocketExplosion
    ; Is rocket exploding ?
    LD A, (ro.rocketState)
    CP ro.ROST_EXPLODE
    RET NZ

    ; ##########################################
    CALL rof.AnimateRocketExplosion
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                #_MainLoop004OnActiveGame                 ;
;----------------------------------------------------------;
_MainLoop004OnActiveGame

    ; Return if game is not active.
    LD A, (ms.mainState)
    CP ms.GAME_ACTIVE
    RET NZ

    ; ##########################################
    CALL ro.RocketElementFallsForAssembly
    CALL jo.UpdateJetpackOverheating
    CALL pi.AnimateFallingPickup

    ; ##########################################
    LD A, (jt.difLevel)
    CP jt.DIF_HARD
    CALL Z, ens.RespawnNextSingleEnemy

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      #_MainLoop006                       ;
;----------------------------------------------------------;
_MainLoop006

    ; Increment the counter.
    LD A, (mld.counter006)
    INC A
    LD (mld.counter006), A
    CP mld.COUNTER006_MAX
    RET NZ

    ; Reset the counter.
    XOR A                                       ; Set A to 0
    LD (mld.counter006), A

    ; ##########################################
    ; 1 -> 0 and 0 -> 1
    LD A, (mld.counter006FliFLop)
    XOR 1
    LD (mld.counter006FliFLop), A

    ; ##########################################
    ; CALL functions that need to be updated every xx-th loop.

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     #_MainLoop008                        ;
;----------------------------------------------------------;
_MainLoop008

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
    CALL _MainLoop008OnActiveGame
    CALL _MainLoop008OnActiveGameOrFlyingRocket
    CALL _MainLoop008OnFlayingRocket

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;              #_MainLoop008OnFlayingRocket                ;
;----------------------------------------------------------;
_MainLoop008OnFlayingRocket
    ; Return if rocket is not flying.
    LD A, (ro.rocketState)
    CP ro.ROST_FLY
    RET NZ

    ; ##########################################
    CALL rof.AnimateRocketExhaust
    CALL rof.BlinkFlyingRocket
    CALL st.BlinkStarsL1

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                #_MainLoop008OnActiveGame                 ;
;----------------------------------------------------------;
_MainLoop008OnActiveGame

    ; Return if game is inactive.
    LD A, (ms.mainState)
    CP ms.GAME_ACTIVE
    RET NZ

    ; ##########################################
    CALL jw.AnimateShots
    CALL ro.BlinkRocketReady
    CALL ro.AnimateTankExplode
    CALL st.BlinkStarsL1
    CALL jo.AnimateJetpackOverheat
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;         #_MainLoop008OnActiveGameOrFlyingRocket          ;
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
    RET NZ                                          ; Return if rocket is not flying.

.execute
    ; ##########################################
    CALL enp.AnimatePatternEnemies

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     #_MainLoop010                        ;
;----------------------------------------------------------;
_MainLoop010

    ; Increment the counter.
    LD A, (mld.counter010)
    INC A
    LD (mld.counter010), A
    CP mld.COUNTER010_MAX
    RET NZ

    ; Reset the counter.
    XOR A                                       ; Set A to 0
    LD (mld.counter010), A

    ; ##########################################
    ; 1 -> 0 and 0 -> 1
    LD A, (mld.counter010FliFLop)
    XOR 1
    LD (mld.counter010FliFLop), A

    ; ##########################################
    ; CALL functions that need to be updated every xx-th loop.
    CALL _MainLoop010OnActiveGame
    CALL _MainLoop010OnActiveFlyingRocket

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;            #_MainLoop010OnActiveFlyingRocket             ;
;----------------------------------------------------------;
_MainLoop010OnActiveFlyingRocket

    ; Return if rocket is not flying.
    LD A, (ms.mainState)
    CP ms.FLY_ROCKET
    RET NZ

    ; ##########################################
    CALL st.BlinkStarsL2

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                #_MainLoop010OnActiveGame                 ;
;----------------------------------------------------------;
_MainLoop010OnActiveGame

    ; Return if game is inactive.
    LD A, (ms.mainState)
    CP ms.GAME_ACTIVE
    RET NZ

    ; ##########################################
    CALL st.BlinkStarsL2
    CALL enf.RespawnFormation

    ; ##########################################
    LD A, (jt.difLevel)
    CP jt.DIF_HARD
    CALL NZ, ens.RespawnNextSingleEnemy

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     #_MainLoop015                        ;
;----------------------------------------------------------;
_MainLoop015

    ; Increment the counter.
    LD A, (mld.counter015)
    INC A
    LD (mld.counter015), A
    CP mld.COUNTER015_MAX
    RET NZ

    ; Reset the counter.
    XOR A                                       ; Set A to 0
    LD (mld.counter015), A

    ; ##########################################
    ; CALL functions that need to be updated every xx-th loop.

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      #_MainLoop020                       ;
;----------------------------------------------------------;
_MainLoop020

    ; Increment the counter.
    LD A, (mld.counter020)
    INC A
    LD (mld.counter020), A
    CP mld.COUNTER020_MAX
    RET NZ

    ; ##########################################
    ; Reset the counter.
    XOR A                                       ; Set A to 0
    LD (mld.counter020), A

    ; ##########################################
    ; CALL functions that need to be updated every xx-th loop
    CALL _MainLoop020nFlyingRocket
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;               #_MainLoop020nFlyingRocket                 ;
;----------------------------------------------------------;
_MainLoop020nFlyingRocket

    ; Return if rocket is not flying.
    LD A, (ms.mainState)
    CP ms.FLY_ROCKET
    RET NZ

    ; ##########################################
    CALL enp.KillOnePatternEnemy

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      #_MainLoop040                       ;
;----------------------------------------------------------;
_MainLoop040

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
    ; CALL functions that need to be updated every xx-th loop
    CALL _MainLoop040OnActiveGame

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                #_MainLoop040OnActiveGame                 ;
;----------------------------------------------------------;
_MainLoop040OnActiveGame

    ; Return if game is inactive.
    LD A, (ms.mainState)
    CP ms.GAME_ACTIVE
    RET NZ

    ; ##########################################
    CALL ro.DropNextRocketElement
    CALL td.NextTimeOfDayTrigger
    CALL pi.PickupDropCounter
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      #_MainLoop080                       ;
;----------------------------------------------------------;
_MainLoop080

    ; Increment the counter.
    LD A, (mld.counter080)
    INC A
    LD (mld.counter080), A
    CP mld.COUNTER080_MAX
    RET NZ

    ; ##########################################
    ; Reset the counter.
    XOR A                                       ; Set A to 0
    LD (mld.counter080), A

    ; ##########################################
    ; CALL functions that need to be updated every xx-th loop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        #_LastLoop                        ;
;----------------------------------------------------------;
_LastLoop

    CALL ui.UserInputLastLoop
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE