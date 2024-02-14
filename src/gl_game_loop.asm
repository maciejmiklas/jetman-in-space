;----------------------------------------------------------;
;                   Global Counters                        ;
;----------------------------------------------------------;
	MODULE gl 

;----------------------------------------------------------;
;                     #GameLoop                         ;
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

	; CALL functions that need to be updated every loop
	; First update graphics, logic follows afterwards!
	CALL js.AnimateJetSprite
	CALL js.UpdateJetSpritePositionRotation
	
	CALL jw.FireDelayCounter
	CALL jco.JetRip
	CALL in.JoyInput

	CALL AnimateOnDisabledJoy

	LD IX, ed.sprite01
	LD A, (ed.spritesSize)
	LD B, A 	
	CALL ep.MoveEnemies

	LD IX, ed.sprite01
	LD A, (ed.singleSpritesSize)
	LD B, A	
	;CALL ep.RespownNextEnemy	

	;CALL jco.JetmanEnemiesColision
	CALL ro.CheckHitTank
	
	LD IY, ed.formation
	;CALL ef.RespownFormation

	CALL jw.MoveShots
	CALL jw.WeaponHitEnemies
	
	CALL gb.PrintDebug

	CALL ro.FlyRocket
	
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

	; 1 -> 0 and 0 -> 1
	LD A, (gld.counter002FliFLop)
	XOR 1
	LD (gld.counter002FliFLop), A

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

	; 1 -> 0 and 0 -> 1
	LD A, (gld.counter004FliFLop)
	XOR 1
	LD (gld.counter004FliFLop), A

	; CALL functions that need to be updated every xx-th loop
	CALL ro.RocketElementFallsForPickup
	CALL ro.RocketElementFallsForAssembly
	CALL ro.AdminateRocketExplosion

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

	; 1 -> 0 and 0 -> 1
	LD A, (gld.counter006FliFLop)
	XOR 1
	LD (gld.counter006FliFLop), A

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

	; 1 -> 0 and 0 -> 1
	LD A, (gld.counter008FliFLop)
	XOR 1
	LD (gld.counter008FliFLop), A

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
	CALL ro.SwitchRocketSpriteForBlink

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

	; 1 -> 0 and 0 -> 1
	LD A, (gld.counter010FliFLop)
	XOR 1
	LD (gld.counter010FliFLop), A

	; CALL functions that need to be updated every xx-th loop

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

	; Reset the counter
	XOR A										; Set A to 0
	LD (gld.counter040), A

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

	; Reset the counter
	XOR A										; Set A to 0
	LD (gld.counter080), A

	; CALL functions that need to be updated every xx-th loop

	RET											; ## END of the function ##
	
;----------------------------------------------------------;
;               #AnimateOnDisabledJoy                      ;
;----------------------------------------------------------;
AnimateOnDisabledJoy
	
	; Return if the joystick is about to enable
	LD A, (ind.joyOffCnt)
	CP 2
	RET C										; Return on the last off loop (#joyOffCnt < 2) - this one is used to reset status and not to animate

	; ##########################################
	CALL pl.AnimateJetSideHitPlatfrom
	CALL pl.AnimateJetFallingFromPlatform
	CALL pl.AnimateJetHitPlatfromBelow
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE