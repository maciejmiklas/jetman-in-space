;----------------------------------------------------------;
;                       Game Loop                          ;
;----------------------------------------------------------;
	MODULE gl 

;----------------------------------------------------------;
;                      #GameLoop                           ;
;----------------------------------------------------------;
GameLoop

	CALL _GameLoop000
	CALL _GameLoop002
	CALL _GameLoop002
	CALL _GameLoop004
	CALL _GameLoop006
	CALL _GameLoop008
	CALL _GameLoop010
	CALL _GameLoop040
	CALL _GameLoop080

	RET											; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                     #_GameLoop000                        ;
;----------------------------------------------------------;
_GameLoop000

	; 1 -> 0 and 0 -> 1
	LD A, (gld.counter000FliFLop)
	XOR 1
	LD (gld.counter000FliFLop), A

	; ##########################################
	; CALL functions that need to be updated every loop.
	; First update graphics, logic follows afterwards!

	CALL gb.PrintDebug
	CALL ro.FlyRocket
	CALL _GameLoop000OnActiveJetman

	RET											; ## END of the function ##

;----------------------------------------------------------;
;               #_GameLoop000OnActiveJetman                ;
;----------------------------------------------------------;
_GameLoop000OnActiveJetman

	; Return if Jetman is inactive (game paused/loading).
	LD A, (jt.jetState)
	CP jt.STATE_INACTIVE
	RET Z

	; ##########################################
	CALL _GameLoop000OnDisabledJoy

	CALL ro.CheckHitTank
	CALL jco.JetRip
	CALL jw.MoveShots
	CALL jw.WeaponHitEnemies
	CALL js.AnimateJetSprite
	CALL js.UpdateJetSpritePositionRotation
	CALL jw.FireDelayCounter
	CALL jco.JetmanEnemiesCollision
	CALL gi.JoystickInput
	CALL gi.KeyboardInput
	CALL ep.MoveEnemies
	CALL es.RespawnNextSingleEnemy
;CALL ef.RespawnFormation
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;               #_GameLoop000OnDisabledJoy                 ;
;----------------------------------------------------------;
_GameLoop000OnDisabledJoy

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
;                       #_GameLoop002                      ;
;----------------------------------------------------------;
_GameLoop002

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
	CALL _GameLoop002OnActiveJetman
	CALL ros.AnimateStarsOnFlyRocket
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;               #_GameLoop002OnActiveJetman                ;
;----------------------------------------------------------;
_GameLoop002OnActiveJetman

	; Return if Jetman is inactive (game paused/loading).
	LD A, (jt.jetState)
	CP jt.STATE_INACTIVE
	RET Z

	; ##########################################
	CALL jco.JetInvincible
	CALL ro.RocketElementFallsForPickup

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                     #_GameLoop004                        ;
;----------------------------------------------------------;
_GameLoop004

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
	CALL _GameLoop004OnActiveJetman

	RET											; ## END of the function ##

;----------------------------------------------------------;
;               #_GameLoop004OnActiveJetman                ;
;----------------------------------------------------------;
_GameLoop004OnActiveJetman

	; Return if Jetman is inactive (game paused/loading).
	LD A, (jt.jetState)
	CP jt.STATE_INACTIVE
	RET Z

	; ##########################################
	CALL ro.RocketElementFallsForAssembly
	CALL jo.UpdateJetpackOverheating
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                      #_GameLoop006                       ;
;----------------------------------------------------------;
_GameLoop006

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
	CALL _GameLoop006OnActiveJetman

	RET											; ## END of the function ##

;----------------------------------------------------------;
;               #_GameLoop006OnActiveJetman                ;
;----------------------------------------------------------;
_GameLoop006OnActiveJetman

	; Return if Jetman is inactive (game paused/loading).
	LD A, (jt.jetState)
	CP jt.STATE_INACTIVE
	RET Z

	; ##########################################

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                     #_GameLoop008                        ;
;----------------------------------------------------------;
_GameLoop008

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
	CALL _GameLoop008OnActiveJetman
	CALL ro.AnimateRocketExhaust
	CALL ro.BlinkFlyingRocket

	RET											; ## END of the function ##

;----------------------------------------------------------;
;               #_GameLoop008OnActiveJetman                ;
;----------------------------------------------------------;
_GameLoop008OnActiveJetman

	; Return if Jetman is inactive (game paused/loading).
	LD A, (jt.jetState)
	CP jt.STATE_INACTIVE
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
	LD A, (ep.enemiesSize)
	LD B, A	
	CALL sr.AnimateSprites

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                     #_GameLoop010                        ;
;----------------------------------------------------------;
_GameLoop010

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
	CALL _GameLoop010nFlyingRocket
	CALL _GameLoop010OnActiveJetman

	RET											; ## END of the function ##

;----------------------------------------------------------;
;               #_GameLoop010OnActiveJetman                ;
;----------------------------------------------------------;
_GameLoop010OnActiveJetman

	; Return if Jetman is inactive (game paused/loading).
	LD A, (jt.jetState)
	CP jt.STATE_INACTIVE
	RET Z

	; ##########################################
	CALL st.BlinkStarsL2

	RET											; ## END of the function ##

;----------------------------------------------------------;
;               #_GameLoop010nFlyingRocket                 ;
;----------------------------------------------------------;
_GameLoop010nFlyingRocket

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
;                      #_GameLoop040                       ;
;----------------------------------------------------------;
_GameLoop040

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
	CALL _GameLoop040OnActiveJetman

	RET											; ## END of the function ##

;----------------------------------------------------------;
;               #_GameLoop040OnActiveJetman                ;
;----------------------------------------------------------;
_GameLoop040OnActiveJetman

	; Return if Jetman is inactive (game paused/loading).
	LD A, (jt.jetState)
	CP jt.STATE_INACTIVE
	RET Z

	; ##########################################
	CALL ro.DropNextRocketElement
	CALL td.NextTimeOfDayTrigger
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                      #_GameLoop080                       ;
;----------------------------------------------------------;
_GameLoop080

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
	CALL _GameLoop080OnActiveJetman

	RET											; ## END of the function ##

;----------------------------------------------------------;
;               #_GameLoop080OnActiveJetman                ;
;----------------------------------------------------------;
_GameLoop080OnActiveJetman

	; Return if Jetman is inactive (game paused/loading).
	LD A, (jt.jetState)
	CP jt.STATE_INACTIVE
	RET Z

	; ##########################################

	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE