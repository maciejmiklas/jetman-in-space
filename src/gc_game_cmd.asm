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

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #RocketExplosionOver                    ;
;----------------------------------------------------------;
RocketExplosionOver

	CALL ro.HideRocket
	CALL ro.ResetAndDisableRocket

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
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE