;----------------------------------------------------------;
;                   Global Counters                        ;
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

	CALL jw.MoveShots
	CALL jw.WeaponHitEnemies

	CALL jco.JetRip
	CALL gb.PrintDebug

	CALL ro.CheckHitTank
	CALL ro.FlyRocket

	CALL _GameLoop000OnDisabledJoy
	CALL _GameLoop000OnRocketTakingOff
	CALL _GameLoop000OnActiveJetman
	
	; ##########################################
	LD IX, ed.sprite01
	LD A, (ed.spritesSize)
	LD B, A 	
	CALL ep.MoveEnemies

	; ##########################################
	CALL gi.JoystickInput
	CALL gi.KeyboardInput

	RET											; ## END of the function ##

;----------------------------------------------------------;
;               #_GameLoop000OnActiveJetman                ;
;----------------------------------------------------------;
_GameLoop000OnActiveJetman

	; Return if inactive
	LD A, (jt.jetState)
	CP jt.STATE_INACTIVE
	RET Z

	; ##########################################
	CALL js.AnimateJetSprite
	CALL js.UpdateJetSpritePositionRotation
	CALL jw.FireDelayCounter
	CALL jco.JetmanEnemiesCollision

	; ##########################################
	LD IX, ed.sprite01
	LD A, (ed.singleSpritesSize)
	LD B, A	
	;CALL ep.RespawnNextEnemy
	
	; ##########################################
	LD IY, ed.formation
	;CALL ef.RespawnFormation	

	RET											; ## END of the function ##

;----------------------------------------------------------;
;               #_GameLoop000OnDisabledJoy                 ;
;----------------------------------------------------------;
_GameLoop000OnDisabledJoy

	; ##########################################
	; Return if the joystick is about to enable
	LD A, (gid.joyOffCnt)
	CP _C_PL_BUMP_JOY_DEC_D1+1
	RET C										; Return on the last off loop - this one is used to reset status and not to animate.

	; ##########################################
	CALL pl.MoveJetOnPlatformSideHit
	CALL pl.MoveJetOnFallingFromPlatform
	CALL pl.MoveJetOnHitPlatformBelow

	RET											; ## END of the function ##

;----------------------------------------------------------;
;           #_GameLoop000OnRocketTakingOff                 ;
;----------------------------------------------------------;
_GameLoop000OnRocketTakingOff

	; Return if rocket is not flying
	LD A, (ro.rocketState)
	CP ro.RO_ST_FLY
	RET NZ

	; ##########################################
	; Execute function until the rocket has reached its destination, where it stops and only stars are moving.
	LD HL, (ro.rocketDistance)
	LD A, H										; H is always 0, because distance < 255.
	CP 0
	RET NZ

	LD A, L
	CP _RO_MOVE_STOP_D120
	RET NC

	; ##########################################
	CALL ti.ShakeTilemap

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
	CALL jco.JetInvincible
	CALL ros.AnimateStarsOnFlyRocket
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
	CALL ro.RocketElementFallsForAssembly
	CALL ro.AnimateRocketExplosion
	CALL st.BlinkStarsL2

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
	CALL st.BlinkStarsL1

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
	CALL jw.AnimateShots
	
	; Animate enemies
	LD IX, ed.sprite01	
	LD A, (ed.spritesSize)
	LD B, A	
	CALL sr.AnimateSprites

	CALL ro.AnimateRocketReady
	CALL ro.AnimateTankExplode
	CALL ro.AnimateRocketExhaust
	CALL ro.BlinkRocketReady
	
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
	RET											; ## END of the function ##

;----------------------------------------------------------;
;               #_GameLoop010nFlyingRocket                 ;
;----------------------------------------------------------;
_GameLoop010nFlyingRocket

	; Return if rocket is not flying.
	LD A, (ro.rocketState)
	CP ro.RO_ST_FLY
	RET NZ

	LD A, (gld.counter008FliFLop)
	CP _GC_FLIP_ON_D1
	JR Z, .flip

	; ##########################################
	LD IX, ed.sprite01
	LD A, (ed.singleSpritesSize)
	LD B, A
	CALL sr.KillOneSprite

	JR .afterFilpFlop
.flip
	; ##########################################
	LD IX, ed.spriteEf01
	LD A, (ed.formation.SPRITES)
	LD B, A
	CALL sr.KillOneSprite

.afterFilpFlop
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


	RET											; ## END of the function ##


;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE