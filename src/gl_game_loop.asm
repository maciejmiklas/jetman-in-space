;----------------------------------------------------------;
;                   Global Counters                        ;
;----------------------------------------------------------;
	MODULE gl 

;----------------------------------------------------------;
;                      #GameLoop                           ;
;----------------------------------------------------------;
GameLoop

	CALL GameLoop000
	CALL GameLoop002
	CALL GameLoop002
	CALL GameLoop004	
	CALL GameLoop006
	CALL GameLoop008
	CALL GameLoop010
	CALL GameLoop040
	CALL GameLoop080

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                      #GameLoop000                        ;
;----------------------------------------------------------;
GameLoop000

	; 1 -> 0 and 0 -> 1
	LD A, (gld.counter000FliFLop)
	XOR 1
	LD (gld.counter000FliFLop), A

	; ##########################################
	; CALL functions that need to be updated every loop
	; First update graphics, logic follows afterwards!

	CALL jw.MoveShots
	CALL jw.WeaponHitEnemies

	CALL jco.JetRip
	CALL gb.PrintDebug

	CALL ro.CheckHitTank
	CALL ro.FlyRocket

	CALL GameLoop000OnDisabledJoy
	CALL GameLoop000OnRocketTakingOff
	CALL GameLoop000OnActiveJetman
	
	; ##########################################
	LD IX, ed.sprite01
	LD A, (ed.spritesSize)
	LD B, A 	
	CALL ep.MoveEnemies

	CALL in.JoyInput

	RET											; ## END of the function ##

tmp byte 0
;----------------------------------------------------------;
;               #GameLoop000OnActiveJetman                 ;
;----------------------------------------------------------;
GameLoop000OnActiveJetman

	; Return if inactive
	LD A, (jt.jetState)
	CP jt.STATE_INACTIVE
	RET Z

	ld a, (tmp)
	inc a 
	ld (tmp),a
	; ##########################################
	CALL js.AnimateJetSprite
	CALL js.UpdateJetSpritePositionRotation
	CALL jw.FireDelayCounter
	CALL jco.JetmanEnemiesColision

	; ##########################################
	LD IX, ed.sprite01
	LD A, (ed.singleSpritesSize)
	LD B, A	
	//CALL ep.RespownNextEnemy
	
	; ##########################################
	LD IY, ed.formation
	//CALL ef.RespownFormation	

	RET											; ## END of the function ##	

;----------------------------------------------------------;
;               #GameLoop000OnDisabledJoy                  ;
;----------------------------------------------------------;
GameLoop000OnDisabledJoy

	; Return if the joystick is about to enable
	LD A, (ind.joyOffCnt)
	CP _CF_PL_BUMP_JOY_OFF_DEC+1
	RET C										; Return on the last off loop - this one is used to reset status and not to animate

	; ##########################################
	CALL pl.MoveJetOnPlatfromSideHit
	CALL pl.MoveJetOnFallingFromPlatform
	CALL pl.MoveJetOnHitPlatfromBelow

	RET											; ## END of the function ##

;----------------------------------------------------------;
;           #GameLoop000OnRocketTakingOff                  ;
;----------------------------------------------------------;
GameLoop000OnRocketTakingOff

	; Return if rocket is not flying
	LD A, (ro.rocketState)
	CP ro.RO_ST_FLY
	RET NZ

	; ##########################################
	; Execute function until the rocket has reached its destination, where it stops and only stars are moving
	LD HL, (ro.rocketDistance)
	LD A, H										; H is always 0, because distance < 255
	CP 0
	RET NZ

	LD A, L
	CP _CF_RO_MOVE_STOP
	RET NC

	; ##########################################
	CALL ti.ShakeTilemap

	RET											; ## END of the function ##
	
;----------------------------------------------------------;
;                       #GameLoop002                       ;
;----------------------------------------------------------;
GameLoop002

	; Increment the counter
	LD A, (gld.counter002)
	INC A
	LD (gld.counter002), A
	CP gld.COUNTER002_MAX
	RET NZ

	; Reset the counter
	XOR A										; Set A to 0
	LD (gld.counter002), A

	; ##########################################
	; 1 -> 0 and 0 -> 1
	LD A, (gld.counter002FliFLop)
	XOR 1
	LD (gld.counter002FliFLop), A

	; ##########################################
	; CALL functions that need to be updated every xx-th loop
	CALL jco.JetInvincible
	CALL st.AnimateStarsOnFlyRocket

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                      #GameLoop004                        ;
;----------------------------------------------------------;
GameLoop004

	; Increment the counter
	LD A, (gld.counter004)
	INC A
	LD (gld.counter004), A
	CP gld.COUNTER004_MAX
	RET NZ
	
	; Reset the counter
	XOR A										; Set A to 0
	LD (gld.counter004), A

	; ##########################################
	; 1 -> 0 and 0 -> 1
	LD A, (gld.counter004FliFLop)
	XOR 1
	LD (gld.counter004FliFLop), A

	; ##########################################
	; CALL functions that need to be updated every xx-th loop
	CALL ro.RocketElementFallsForPickup
	CALL ro.RocketElementFallsForAssembly
	CALL ro.AdminateRocketExplosion
	CALL bg.AnimateBackgroundOnFlyRocket
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                      #GameLoop006                        ;
;----------------------------------------------------------;
GameLoop006

	; Increment the counter
	LD A, (gld.counter006)
	INC A
	LD (gld.counter006), A
	CP gld.COUNTER006_MAX
	RET NZ

	; Reset the counter
	XOR A										; Set A to 0
	LD (gld.counter006), A

	; ##########################################
	; 1 -> 0 and 0 -> 1
	LD A, (gld.counter006FliFLop)
	XOR 1
	LD (gld.counter006FliFLop), A

	; ##########################################
	; CALL functions that need to be updated every xx-th loop
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                      #GameLoop008                        ;
;----------------------------------------------------------;
GameLoop008

	; Increment the counter
	LD A, (gld.counter008)
	INC A
	LD (gld.counter008), A
	CP gld.COUNTER008_MAX
	RET NZ

	; Reset the counter
	XOR A										; Set A to 0
	LD (gld.counter008), A

	; ##########################################
	; 1 -> 0 and 0 -> 1
	LD A, (gld.counter008FliFLop)
	XOR 1
	LD (gld.counter008FliFLop), A

	; ##########################################
	; CALL functions that need to be updated every xx-th loop
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
;                      #GameLoop010                        ;
;----------------------------------------------------------;
GameLoop010

	; Increment the counter
	LD A, (gld.counter010)
	INC A
	LD (gld.counter010), A
	CP gld.COUNTER010_MAX
	RET NZ

	; Reset the counter
	XOR A										; Set A to 0
	LD (gld.counter010), A

	; ##########################################
	; 1 -> 0 and 0 -> 1
	LD A, (gld.counter010FliFLop)
	XOR 1
	LD (gld.counter010FliFLop), A

	; ##########################################
	; CALL functions that need to be updated every xx-th loop

	CALL GameLoop010nFlyingRocket
	RET											; ## END of the function ##

;----------------------------------------------------------;
;               #GameLoop010nFlyingRocket                  ;
;----------------------------------------------------------;
GameLoop010nFlyingRocket

	; Return if rocket is not flying
	LD A, (ro.rocketState)
	CP ro.RO_ST_FLY
	RET NZ

	LD A, (gld.counter008FliFLop)
	CP gld.FLIP_ON
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
;                       #GameLoop040                       ;
;----------------------------------------------------------;
GameLoop040

	; Increment the counter
	LD A, (gld.counter040)
	INC A
	LD (gld.counter040), A
	CP gld.COUNTER040_MAX
	RET NZ

	; ##########################################
	; Reset the counter
	XOR A										; Set A to 0
	LD (gld.counter040), A

	; ##########################################
	; CALL functions that need to be updated every xx-th loop
	CALL ro.DropNextRocketElement
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       #GameLoop080                       ;
;----------------------------------------------------------;
GameLoop080

	; Increment the counter
	LD A, (gld.counter080)
	INC A
	LD (gld.counter080), A
	CP gld.COUNTER080_MAX
	RET NZ

	; ##########################################
	; Reset the counter
	XOR A										; Set A to 0
	LD (gld.counter080), A

	; ##########################################
	; CALL functions that need to be updated every xx-th loop

	RET											; ## END of the function ##


;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE