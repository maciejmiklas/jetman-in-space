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
	LD A, (gld.counter000FliFLop)
	XOR 1
	LD (gld.counter000FliFLop), A

	; ##########################################
	; CALL functions that need to be updated every loop.
	; First update graphics, logic follows afterwards!

	CALL gb.PrintDebug
	CALL ro.FlyRocket
	CALL _MainLoop000OnActiveJetman
	CALL _MainLoop000OnActiveLobby

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
	CALL ep.MovePatternEnemies
	CALL es.RespawnNextSingleEnemy
	;CALL ef.RespawnFormation
	
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

	; ##########################################
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
	LD A, (gld.counter002)
	INC A
	LD (gld.counter002), A
	CP gld.COUNTER002_MAX
	RET NZ

	; Reset the counter.
	XOR A										; Set A to 0.
	LD (gld.counter002), A

	; ##########################################
	; 1 -> 0 and 0 -> 1
	LD A, (gld.counter002FliFLop)
	XOR 1
	LD (gld.counter002FliFLop), A

	; ##########################################
	; CALL functions that need to be updated every xx-th loop.
	CALL _MainLoop002OnActiveJetman
	CALL ros.AnimateStarsOnFlyRocket
	CALL _MainLoop002OnActiveLobby

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
	LD A, (gld.counter004)
	INC A
	LD (gld.counter004), A
	CP gld.COUNTER004_MAX
	RET NZ
	
	; Reset the counter.
	XOR A										; Set A to 0
	LD (gld.counter004), A

	; ##########################################
	; 1 -> 0 and 0 -> 1
	LD A, (gld.counter004FliFLop)
	XOR 1
	LD (gld.counter004FliFLop), A

	; ##########################################
	; CALL functions that need to be updated every xx-th loop.
	CALL ro.AnimateRocketExplosion
	CALL _MainLoop004OnActiveJetman

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
	LD A, (gld.counter006)
	INC A
	LD (gld.counter006), A
	CP gld.COUNTER006_MAX
	RET NZ

	; Reset the counter.
	XOR A										; Set A to 0
	LD (gld.counter006), A

	; ##########################################
	; 1 -> 0 and 0 -> 1
	LD A, (gld.counter006FliFLop)
	XOR 1
	LD (gld.counter006FliFLop), A

	; ##########################################
	; CALL functions that need to be updated every xx-th loop.
	CALL _MainLoop006OnActiveJetman

	RET											; ## END of the function ##

;----------------------------------------------------------;
;               #_MainLoop006OnActiveJetman                ;
;----------------------------------------------------------;
_MainLoop006OnActiveJetman

	; Return if Jetman is inactive (game paused/loading).
	LD A, (jt.jetState)
	CP jt.JT_STATE_INACTIVE
	RET Z

	; ##########################################

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                     #_MainLoop008                        ;
;----------------------------------------------------------;
_MainLoop008

	; Increment the counter.
	LD A, (gld.counter008)
	INC A
	LD (gld.counter008), A
	CP gld.COUNTER008_MAX
	RET NZ

	; Reset the counter.
	XOR A										; Set A to 0
	LD (gld.counter008), A

	; ##########################################
	; 1 -> 0 and 0 -> 1
	LD A, (gld.counter008FliFLop)
	XOR 1
	LD (gld.counter008FliFLop), A

	; ##########################################
	; CALL functions that need to be updated every xx-th loop.
	CALL _MainLoop008OnActiveJetman
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

	; ##########################################
	; Animate enemies
	CALL dbs.SetupArraysBank

	LD IX, db.enemySprites
	LD A, (ep.allEnemiesSize)
	LD B, A	
	CALL sr.AnimateSprites

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                     #_MainLoop010                        ;
;----------------------------------------------------------;
_MainLoop010

	; Increment the counter.
	LD A, (gld.counter010)
	INC A
	LD (gld.counter010), A
	CP gld.COUNTER010_MAX
	RET NZ

	; Reset the counter.
	XOR A										; Set A to 0
	LD (gld.counter010), A

	; ##########################################
	; 1 -> 0 and 0 -> 1
	LD A, (gld.counter010FliFLop)
	XOR 1
	LD (gld.counter010FliFLop), A

	; ##########################################
	; CALL functions that need to be updated every xx-th loop.
	CALL _MainLoop010nFlyingRocket
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

	RET											; ## END of the function ##

;----------------------------------------------------------;
;               #_MainLoop010nFlyingRocket                 ;
;----------------------------------------------------------;
_MainLoop010nFlyingRocket

	; Return if rocket is not flying.
	LD A, (ro.rocketState)
	CP ro.ROST_FLY
	RET NZ

/*
	LD A, (gld.counter008FliFLop)
	CP _GC_FLIP_ON_D1
	JR Z, .flip

	; ##########################################
	CALL dbs.SetupArraysBank
	
	LD IX, (????)
	LD B, ???
	CALL sr.KillOneSprite

	JR .afterFilpFlop
.flip
	; ##########################################
	CALL dbs.SetupArraysBank
	LD IX, (ef.efPointer)
	LD B, _EF_FORM_SIZE
	CALL sr.KillOneSprite
.afterFilpFlop
*/
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                      #_MainLoop040                       ;
;----------------------------------------------------------;
_MainLoop040

	; Increment the counter.
	LD A, (gld.counter040)
	INC A
	LD (gld.counter040), A
	CP gld.COUNTER040_MAX
	RET NZ

	; ##########################################
	; Reset the counter.
	XOR A										; Set A to 0
	LD (gld.counter040), A

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
	LD A, (gld.counter080)
	INC A
	LD (gld.counter080), A
	CP gld.COUNTER080_MAX
	RET NZ

	; ##########################################
	; Reset the counter.
	XOR A										; Set A to 0
	LD (gld.counter080), A

	; ##########################################
	; CALL functions that need to be updated every xx-th loop
	CALL _MainLoop080OnActiveJetman

	RET											; ## END of the function ##

;----------------------------------------------------------;
;               #_MainLoop080OnActiveJetman                ;
;----------------------------------------------------------;
_MainLoop080OnActiveJetman

	; Return if Jetman is inactive (game paused/loading).
	LD A, (jt.jetState)
	CP jt.JT_STATE_INACTIVE
	RET Z

	; ##########################################

	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE