;----------------------------------------------------------;
;                      Game Command                        ;
;----------------------------------------------------------;
	MODULE gc

;----------------------------------------------------------;
;                       #TakeOff                           ;
;----------------------------------------------------------;
TakeOff

	CALL js.HideJetSprite
	CALL jt.ChangeJetStateFlyRocket
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
;                      #JetHitsEnemy                       ;
;----------------------------------------------------------;
; Input
;  - IX:	Pointer enemy's #SPR
JetHitsEnemy

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
	BIT jt.JET_STATE_RIP_BIT, A
	RET NZ										; Exit if RIP

	; ##########################################
	; Is Jetman invincible? If so, just kill the enemy
	BIT jt.JET_STATE_INV_BIT, A
	RET NZ										; Exit if invincible

	; ##########################################
	; This is the first enemy hit
	CALL jt.ChangeJetStateRip
	
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

	CALL jt.ChangeJetStateRespown

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