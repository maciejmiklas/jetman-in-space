;----------------------------------------------------------;
;               Formation of 16x16 enemies                 ;
;----------------------------------------------------------;
	MODULE ef

; The move enemyFormation consists of multiple sprites. #formationEnemySprites gives the first sprite, and #EF.SPRITES determines the amount. 
; The #ENP.RESPAWN_DELAY for the remaining sprites determines the deploy delay for the following sprite in the enemy formation. 
	STRUCT EF
RESPAWN_DELAY			BYTE					; Number of game loops delaying respawn.
RESPAWN_DELAY_CNT		BYTE					; Respawn delay counter.
SPRITES					BYTE					; Number of sprites used in this enemyFormation, starting from #SPRITE_POINTER inclusive.
	ENDS

efPointer				WORD db.enemyFormationL1; Value is a pointer to #ef.EF
spritesCnt				BYTE 0					; Counter for #EF.SPRITES

;----------------------------------------------------------;
;                #GetEnemyFormationSize                    ;
;----------------------------------------------------------;
; Output:
;  A - Size of sprites in formation.
GetEnemyFormationSize

	LD IX, (efPointer)
	LD A, (IX + EF.SPRITES)

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                #MoveFormationEnemies                     ;
;----------------------------------------------------------;
MoveFormationEnemies
	CALL dbs.SetupArraysBank
	
	CALL GetEnemyFormationSize
	LD IX, db.formationEnemySprites
	LD B, A
	;CALL ep.MovePatternEnemies

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                   #SetupEnemyFormation                   ;
;----------------------------------------------------------;
;Input:
;  -DE: Pointer to formation enemies (#ef.EF)
SetupEnemyFormation

	LD (efPointer), DE

	LD B, db.ENEMY_FORMATION_SIZE
	LD IX, db.formationEnemySprites
	CALL ep.ResetPatternEnemies

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                   #RespawnFormation                      ;
;----------------------------------------------------------;
RespawnFormation
	RET
	CALL dbs.SetupArraysBank
	LD IY, (efPointer)

	; ##########################################
	; Check whether it's time to start a new enemyFormation deployment.
	LD B, (IY + EF.RESPAWN_DELAY)
	LD A, (IY + EF.RESPAWN_DELAY_CNT)

	; Compare timer
	CP B
	JR Z, .startRespawn							; Jump if #RESPAWN_DELAY == #RESPAWN_DELAY_CNT.
	INC A										; Increment delay timer and return.
	LD (IY + EF.RESPAWN_DELAY_CNT), A
	RET
.startRespawn									; #RESPAWN_DELAY == #RESPAWN_DELAY_CNT -> deployment is active.
	
	; ##########################################
	; Formation deployment in progress.....

	; Check if deployment is over -> the last sprite has been deployed.
	LD A, (spritesCnt)
	CP (IY + EF.SPRITES)
	JR C, .deployNextEnemy						; Jump if  #spritesCnt < #EF.SPRITES -> There are still enemies that need to be deployed.
	
	; Deployment is over, reset enemyFormation counters.
	XOR A
	LD (spritesCnt), A
	LD (IY + EF.RESPAWN_DELAY_CNT), A

	RET
.deployNextEnemy	

	; ##########################################
	; Deploy next enemy!
	LD HL, db.formationEnemySprites
	LD IX, HL									; IX points for ENP for the first sprite in the enemyFormation.

	; Move IX to the current sprite in the enemyFormation.
	LD A, (spritesCnt)
	LD D, A										; IX = IX + spritesCnt * EF.
	LD E, sr.SPR
	MUL D, E
	ADD IX, DE

	PUSH IY
	CALL ep.RespawnEnemy
	POP IY

	CP ep.RES_SE_OUT_YES						; Has the enemy respawned?
	RET NZ
	LD A, (spritesCnt)

	; Move to the next enemy if this has respawned.
	INC A
	LD (spritesCnt), A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE