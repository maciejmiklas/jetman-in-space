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
	CALL _MainLoop002
	CALL _MainLoop004
	CALL _MainLoop006
	CALL _MainLoop008
	CALL _MainLoop010
	CALL _MainLoop020
	CALL _MainLoop040
	CALL _MainLoop080

	RET											; ## END of the function ##

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

	CALL _MainLoop000OnActiveJetman
	CALL _MainLoop000OnActiveLobby
	CALL _MainLoop000OnFlayRocket

	RET											; ## END of the function ##

;----------------------------------------------------------;
;               #_MainLoop000OnFlayRocket                  ;
;----------------------------------------------------------;
_MainLoop000OnFlayRocket
	; Return if rocket is not flying.
	LD A, (ro.rocketState)
	CP ro.ROST_FLY
	RET NZ

	; ##########################################
	CALL ro.FlyRocket
	RET											; ## END of the function ##

;----------------------------------------------------------;
;               #_MainLoop000OnActiveJetman                ;
;----------------------------------------------------------;
_MainLoop000OnActiveJetman

	; Return if Jetman is inactive (game paused/loading).
	LD A, (jt.jetState)
	CP jt.JT_STATE_INACTIVE
	RET Z

	; ##########################################
	CALL _MainLoop000OnDisabledJoy

	CALL gi.GameJoystickInput
	CALL ro.CheckHitTank
	CALL jco.JetRip
	CALL jw.MoveShots
	CALL jw.WeaponHitEnemies
	CALL js.AnimateJetSprite
	CALL js.UpdateJetSpritePositionRotation
	CALL jw.FireDelayCounter
	CALL jco.JetmanEnemiesCollision
	CALL gi.GameKeyboardInput
	CALL ens.MoveSingleEnemies
	CALL enf.MoveFormationEnemies

	RET											; ## END of the function ##

;----------------------------------------------------------;
;               #_MainLoop000OnActiveLobby                 ;
;----------------------------------------------------------;
_MainLoop000OnActiveLobby

	; Return if Lobby is inactive
	LD A, (los.lobbyState)
	CP los.LOBBY_INACTIVE
	RET Z

	; ##########################################
	CALL loi.MainMenuUserInput
	
	RET											; ## END of the function ##	

;----------------------------------------------------------;
;               #_MainLoop000OnDisabledJoy                 ;
;----------------------------------------------------------;
_MainLoop000OnDisabledJoy

	; Return if the joystick is about to enable
	LD A, (gid.joyOffCnt)
	CP pl.PL_BUMP_JOY_DEC_D1+1
	RET C										; Return on the last off loop - this one is used to reset status and not to animate.

	; ##########################################
	CALL pl.MoveJetOnPlatformSideHit
	CALL pl.MoveJetOnFallingFromPlatform
	CALL pl.MoveJetOnHitPlatformBelow

	RET											; ## END of the function ##

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
	XOR A										; Set A to 0.
	LD (mld.counter002), A

	; ##########################################
	; 1 -> 0 and 0 -> 1
	LD A, (mld.counter002FliFLop)
	XOR 1
	LD (mld.counter002FliFLop), A

	; ##########################################
	; CALL functions that need to be updated every xx-th loop.
	CALL _MainLoop002OnActiveJetman
	CALL _MainLoop002OnActiveLobby
	CALL _MainLoop002OnFlayRocket

	RET											; ## END of the function ##

;----------------------------------------------------------;
;               #_MainLoop002OnFlayRocket                  ;
;----------------------------------------------------------;
_MainLoop002OnFlayRocket

	; Return if rocket is not flying.
	LD A, (ro.rocketState)
	CP ro.ROST_FLY
	RET NZ

	; ##########################################
	CALL ros.AnimateStarsOnFlyRocket
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;               #_MainLoop002OnActiveJetman                ;
;----------------------------------------------------------;
_MainLoop002OnActiveJetman

	; Return if Jetman is inactive (game paused/loading).
	LD A, (jt.jetState)
	CP jt.JT_STATE_INACTIVE
	RET Z

	; ##########################################
	CALL jco.JetInvincible
	CALL ro.RocketElementFallsForPickup
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;               #_MainLoop002OnActiveLobby                 ;
;----------------------------------------------------------;
_MainLoop002OnActiveLobby
	
	; Return if Lobby is inactive
	LD A, (los.lobbyState)
	CP los.LOBBY_INACTIVE
	RET Z

	; ##########################################
	CALL li.AnimateLevelIntroTextScroll
	
	RET											; ## END of the function ##

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
	XOR A										; Set A to 0
	LD (mld.counter004), A

	; ##########################################
	; 1 -> 0 and 0 -> 1
	LD A, (mld.counter004FliFLop)
	XOR 1
	LD (mld.counter004FliFLop), A

	; ##########################################
	; CALL functions that need to be updated every xx-th loop.
	CALL _MainLoop004OnRocketExplosion
	CALL _MainLoop004OnActiveJetman

	RET											; ## END of the function ##

;----------------------------------------------------------;
;             #_MainLoop004OnRocketExplosion               ;
;----------------------------------------------------------;
_MainLoop004OnRocketExplosion
	; Is rocket exploding ?
	LD A, (ro.rocketState)
	CP ro.ROST_EXPLODE
	RET NZ

	; ##########################################
	CALL ro.AnimateRocketExplosion
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;               #_MainLoop004OnActiveJetman                ;
;----------------------------------------------------------;
_MainLoop004OnActiveJetman

	; Return if Jetman is inactive (game paused/loading).
	LD A, (jt.jetState)
	CP jt.JT_STATE_INACTIVE
	RET Z

	; ##########################################
	CALL ro.RocketElementFallsForAssembly
	CALL jo.UpdateJetpackOverheating

	RET											; ## END of the function ##

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
	XOR A										; Set A to 0
	LD (mld.counter006), A

	; ##########################################
	; 1 -> 0 and 0 -> 1
	LD A, (mld.counter006FliFLop)
	XOR 1
	LD (mld.counter006FliFLop), A

	; ##########################################
	; CALL functions that need to be updated every xx-th loop.

	RET											; ## END of the function ##

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
	XOR A										; Set A to 0
	LD (mld.counter008), A

	; ##########################################
	; 1 -> 0 and 0 -> 1
	LD A, (mld.counter008FliFLop)
	XOR 1
	LD (mld.counter008FliFLop), A

	; ##########################################
	; CALL functions that need to be updated every xx-th loop.
	CALL _MainLoop008OnActiveJetman
	CALL _MainLoop008OnActiveJetmanOrFlyingRocket
	CALL _MainLoop008OnFlayingRocket

	RET											; ## END of the function ##

;----------------------------------------------------------;
;              #_MainLoop008OnFlayingRocket                ;
;----------------------------------------------------------;
_MainLoop008OnFlayingRocket
	; Return if rocket is not flying.
	LD A, (ro.rocketState)
	CP ro.ROST_FLY
	RET NZ

	; ##########################################
	CALL ro.AnimateRocketExhaust
	CALL ro.BlinkFlyingRocket

	RET											; ## END of the function ##
;----------------------------------------------------------;
;               #_MainLoop008OnActiveJetman                ;
;----------------------------------------------------------;
_MainLoop008OnActiveJetman

	; Return if Jetman is inactive (game paused/loading).
	LD A, (jt.jetState)
	CP jt.JT_STATE_INACTIVE
	RET Z

	; ##########################################
	CALL jw.AnimateShots
	CALL ro.BlinkRocketReady
	CALL ro.AnimateTankExplode
	CALL st.BlinkStarsL1

	RET											; ## END of the function ##

;----------------------------------------------------------;
;         #_MainLoop008OnActiveJetmanOrFlyingRocket        ;
;----------------------------------------------------------;
_MainLoop008OnActiveJetmanOrFlyingRocket

	; Is Jetman active?
	LD A, (jt.jetState)
	CP jt.JT_STATE_INACTIVE
	JR Z, .jetInactive
	JR .execute
.jetInactive
	; Jetman ist inactive, what about rocket?
	LD A, (ro.rocketState)
	CP ro.ROST_FLY
	RET NZ											; Return if rocket is not flying.

.execute
	; ##########################################
	CALL enp.AnimatePatternEnemies

	RET											; ## END of the function ##

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
	XOR A										; Set A to 0
	LD (mld.counter010), A

	; ##########################################
	; 1 -> 0 and 0 -> 1
	LD A, (mld.counter010FliFLop)
	XOR 1
	LD (mld.counter010FliFLop), A

	; ##########################################
	; CALL functions that need to be updated every xx-th loop.
	CALL _MainLoop010OnActiveJetman

	RET											; ## END of the function ##

;----------------------------------------------------------;
;               #_MainLoop010OnActiveJetman                ;
;----------------------------------------------------------;
_MainLoop010OnActiveJetman

	; Return if Jetman is inactive (game paused/loading).
	LD A, (jt.jetState)
	CP jt.JT_STATE_INACTIVE
	RET Z

	; ##########################################
	CALL st.BlinkStarsL2
	CALL ens.RespawnNextSingleEnemy
	CALL enf.RespawnFormation
	
	RET											; ## END of the function ##

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
	XOR A										; Set A to 0
	LD (mld.counter020), A

	; ##########################################
	; CALL functions that need to be updated every xx-th loop
	CALL _MainLoop020nFlyingRocket
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;               #_MainLoop020nFlyingRocket                 ;
;----------------------------------------------------------;
_MainLoop020nFlyingRocket

	; Return if rocket is not flying.
	LD A, (ro.rocketState)
	CP ro.ROST_FLY
	RET NZ

	; ##########################################
	CALL enp.KillOnePatternEnemy

	RET											; ## END of the function ##

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
	XOR A										; Set A to 0
	LD (mld.counter040), A

	; ##########################################
	; CALL functions that need to be updated every xx-th loop
	CALL _MainLoop040OnActiveJetman

	RET											; ## END of the function ##

;----------------------------------------------------------;
;               #_MainLoop040OnActiveJetman                ;
;----------------------------------------------------------;
_MainLoop040OnActiveJetman

	; Return if Jetman is inactive (game paused/loading).
	LD A, (jt.jetState)
	CP jt.JT_STATE_INACTIVE
	RET Z

	; ##########################################
	CALL ro.DropNextRocketElement
	CALL td.NextTimeOfDayTrigger
	
	RET											; ## END of the function ##

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
	XOR A										; Set A to 0
	LD (mld.counter080), A

	; ##########################################
	; CALL functions that need to be updated every xx-th loop

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE