;----------------------------------------------------------;
;                      Game Command                        ;
;----------------------------------------------------------;
	MODULE gc

;----------------------------------------------------------;
;                    #RocketTakesOff                       ;
;----------------------------------------------------------;
RocketTakesOff
	CALL jt.SetJetStateInactive
	CALL js.HideJetSprite
	CALL gb.HideGameBar
	CALL bg.SetupBackgroundOnRocketTakeoff
	CALL ti.SetTilesClipRocket

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #RocketExplosionOver                    ;
;----------------------------------------------------------;
RocketExplosionOver

	CALL ti.ResetTilemapOffset
	CALL ro.HideRocket
	CALL ro.ResetAndDisableRocket
	CALL ti.SetTilesClipFull
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                   #RocketMovingEnd                       ;
;----------------------------------------------------------;
RocketMovingEnd

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                        #EnemyHit                         ;
;----------------------------------------------------------;
; Input
;  - IX:	Pointer enemy's #SPR
EnemyHit

	CALL sr.SetSpriteId
	CALL sr.SpriteHit

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                      #EnemyHitsJet                       ;
;----------------------------------------------------------;
; Input
;  - IX:	Pointer enemy's #SPR
EnemyHitsJet

	; Destroy the enemy
	CALL sr.SetSpriteId
	CALL sr.SpriteHit

	; ##########################################
	; Is Jetman already dying? If so, do not start the RiP sequence again, just kill the enemy
	LD A, (jt.jetState)							
	CP jt.JET_ST_RIP
	RET Z										; Exit if RIP

	; ##########################################
	; Is Jetman invincible? If so, just kill the enemy
	CP jt.JET_ST_INV
	RET Z										; Exit if invincible

	; ##########################################
	; This is the first enemy hit
	CALL jt.SetJetStateRip
	
	LD A, js.SDB_RIP							; Change animation
	CALL js.ChangeJetSpritePattern

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                      #RespawnJet                         ;
;----------------------------------------------------------;
RespawnJet

	; Set respawn coordinates
	LD BC, _CF_JET_RESPOWN_X
	LD (jpo.jetX), BC

	LD A, _CF_JET_RESPOWN_Y
	LD (jpo.jetY), A

	CALL jt.SetJetStateRespown

	LD HL, _CF_INVINCIBLE
	CALL jco.MakeJetInvincible

	CALL bg.UpdateBackgroundOnJetmanMove
	CALL ro.ResetCarryingRocketElement

	LD A, js.SDB_FLY							; Switch to flaying animation
	CALL js.ChangeJetSpritePattern

	RET											; ## END of the function ##	

;----------------------------------------------------------;
;                      #JetmanMoves                        ;
;----------------------------------------------------------;
JetmanMoves

	CALL bg.UpdateBackgroundOnJetmanMove
	CALL ro.UpdateRocketOnJetmanMove

	RET											; ## END of the function ##

;----------------------------------------------------------;
;               #MovementInactivity                        ;
;----------------------------------------------------------;
; It gets executed as a last procedure after the input has been processed, and there was no movemet from joystick
MovementInactivity

	; Increment inactivity counter
	LD A, (jm.jetInactivityCnt)
	INC A
	LD (jm.jetInactivityCnt), A	

	; ##########################################
	; Should Jetman hover?
	LD A, (jt.jetAir)
	CP jt.STATE_INACTIVE						; Is Jemtan in the air?
	JR Z, .afterHoover							; Jump if not flaying

	LD A, (jt.jetAir)
	CP jt.AIR_HOOVER							; Jetman is in the air, but is he hovering already?
	JR Z, .afterHoover							; Jump if already hovering

	; Jetman is in the air, not hovering, but is he not moving long enough?
	LD A, (jm.jetInactivityCnt)
	CP _CF_HOVER_START
	JR NZ, .afterHoover							; Jetman is not moving, by sill not long enough to start hovering

	; Jetamn starts to hover!
	LD A, jt.AIR_HOOVER
	CALL jt.SetJetStateAir

	LD A, js.SDB_HOVER
	CALL js.ChangeJetSpritePattern
	RET						; Alerady hovering, do not check standing	
.afterHoover

	; ##########################################
	; Jetman is not hovering, but should he stand?
	LD A, (jt.jetGnd)
	CP jt.STATE_INACTIVE						; Is Jemtan on the ground already?
	RET Z										; Jump if not on the ground

	LD A, (jt.jetGnd)
	CP jt.GND_STAND								; Jetman is on the ground, but is he stainding already?
	RET Z										; Jump if already standing

	; ##########################################
	; Jetman is on the ground and does not move, but is he not moving long enough?
	LD A, (jm.jetInactivityCnt)
	CP _CF_STAND_START
	JR NZ, .afterStand							; Jump if Jetman stands for too short to trigger standing
	
	; Transtion from walking to standing
	LD A, jt.GND_STAND
	CALL jt.SetJetStateGnd

	LD A, js.SDB_STAND							; Change animation
	CALL js.ChangeJetSpritePattern
	RET
.afterStand

	; We are here because: jetInactivityCnt > 0 and jetInactivityCnt < _CF_STAND_START 
	; Jetman stands still for a short time, not long enough, to play standing animation, but at least we should stop walking animation.	
	LD A, (jt.jetGnd)
	CP jt.GND_WALK
	RET NZ										; Jump is if not walking
	
	CP jt.GND_JSTAND
	RET Z										; Jump already j-standing (just standing - for a short time)

	LD A, (jm.jetInactivityCnt)
	CP _CF_JSTAND_START
	RET NZ										; Jump if Jetman stands for too short to trigger j-standing

	LD A, jt.GND_JSTAND
	CALL jt.SetJetStateGnd

	LD A, js.SDB_JSTAND							; Change animation
	CALL js.ChangeJetSpritePattern


	RET											; ## END of the function ##

;----------------------------------------------------------;
;                      JoyWillEnable                       ;
;----------------------------------------------------------;
JoyWillEnable
	CALL jt.UpdateStateOnJoyWillEnable

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE