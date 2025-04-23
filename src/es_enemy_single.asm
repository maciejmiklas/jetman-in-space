;----------------------------------------------------------;
;                    Single  Enemy                         ;
;----------------------------------------------------------;
	MODULE es

; The timer ticks with every game loop. When it reaches #ENP_RESPAWN_DELAY, a single enemy will respawn, and the timer starts from 0, counting again.
singleRespDelayCnt 		BYTE 0
singleCount				BYTE 10

; Each enemy has a dedicated respawn delay (EF.RESPAWN_DELAY_CNT). Enemies are renowned one after another from the enemies list. 
; An additional delay is defined here to avoid situations where multiple enemies are respawned simultaneously. It is used to delay 
; the respawn of the next enemy from the enemies list. 
NEXT_RESP_DEL			= 10

;----------------------------------------------------------;
;                  #SetupSingleEnemies                     ;
;----------------------------------------------------------;
; Resets single enemies and loads given #ep.ENPS array into #ep.ENP and #sr.SPR. Expected size for both arrays is given by: _EN_SINGLE_SIZE.
; Input:
;   - A:  Number of single enemies (size of #ENPS)
;   - IX: Pointer to #ENPS array.
SetupSingleEnemies
	CALL dbs.SetupArraysBank

	LD (singleCount), A

	PUSH IX
	CALL _ResetSingleEnemies
	POP IX

	PUSH IX
	; ##########################################
	; Load #ep.ENPS int #ep.ENP
	LD IY, db.spriteEx01						; Pointer to #ENP array.
	LD A, (singleCount)							; Single enemies size (number of #ENPS/#ENP arrays).
	LD B, A
.enpLoop
	LD A, (IY +  ep.ENP.MOVE_DELAY_CNT)

	LD A, (IX + ep.ENPS.RESPAWN_Y)
	LD (IY + ep.ENP.RESPAWN_Y), A

	LD A, (IX + ep.ENPS.SETUP)
	LD (IY + ep.ENP.SETUP), A

	LD A, (IX + ep.ENPS.RESPAWN_DELAY)
	LD (IY + ep.ENP.RESPAWN_DELAY), A

	LD DE, (IX + ep.ENPS.MOVE_PAT_POINTER)
	LD (IY + ep.ENP.MOVE_PAT_POINTER), DE

	; ##########################################
	; Move IX to next array postion.
	LD DE, IX
	ADD DE, ep.ENPS
	LD IX, DE

	; Move IY to next array postion.
	LD DE, IY
	ADD DE, ep.ENP
	LD IY, DE
	
	DJNZ .enpLoop
	POP IX

	; ##########################################
	; Load #ep.ENPS int #sr.SPR
	LD IY, db.singleEnemySprites						; Pointer to #SPR array.
	LD A, (singleCount)							; Single enemies size (number of #ENPS/#ENP arrays).
	LD B, A
.sprLoop

	LD A, (IX + ep.ENPS.SDB_INIT)
	LD (IY + sr.SPR.SDB_INIT), A

	; ##########################################
	; Move IX to next array postion.
	LD DE, IX
	ADD DE, ep.ENPS
	LD IX, DE

	; Move IY to next array postion.
	LD DE, IY
	ADD DE, sr.SPR
	LD IY, DE

	DJNZ .sprLoop
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                #RespawnNextSingleEnemy                   ;
;----------------------------------------------------------;
; Respawns next single enemy. To respawn next from formation use ef.RespawnFormation
RespawnNextSingleEnemy

	CALL dbs.SetupArraysBank

	; ##########################################	
	; Increment respawn timer and exit function if it's not time to respawn a new enemy.
	LD A, NEXT_RESP_DEL
	LD D, A
	LD A, (singleRespDelayCnt)
	INC A
	CP D
	JR Z, .startRespawn							; Jump if the timer reaches respawn delay.
	LD (singleRespDelayCnt), A

	RET
.startRespawn	
	XOR A										; Set A to 0.
	LD (singleRespDelayCnt), A						; Reset delay timer.

	; ##########################################
	; Iterate over all enemies to find the first hidden, respawn it, and exit function.
	LD IX, db.singleEnemySprites
	LD A, (singleCount)
	LD B, A

.loop
	PUSH BC										; Preserve B for loop counter.
	CALL ep.RespawnEnemy
	POP BC

	CP A, ep.RES_SE_OUT_YES
	RET Z										; Exit after respawning first enemy.
										
	; Move IX to the beginning of the next #shotsXX.
	LD DE, sr.SPR
	ADD IX, DE
	DJNZ .loop									; Jump if B > 0 (loop starts with B = _EN_SINGLE_SIZE).

	RET											; ## END of the function ##.

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                  #_ResetSingleEnemies                    ;
;----------------------------------------------------------;
; Input:
;   - A:  Number of single enemies (size of #ENPS)
; Modifies: A, DE, IX, IY
_ResetSingleEnemies

	LD B, A
.enemyLoop
	LD IX, db.singleEnemySprites

	XOR A
	LD (IX + sr.SPR.SDB_POINTER), A
	LD (IX + sr.SPR.X), A
	LD (IX + sr.SPR.Y), A
	LD (IX + sr.SPR.STATE), A
	LD (IX + sr.SPR.NEXT), A
	LD (IX + sr.SPR.REMAINING), A

	; Load extra data for this sprite to IY.
	LD DE, (IX + sr.SPR.EXT_DATA_POINTER)
	LD IY, DE

	LD (IY + ep.ENP.MOVE_DELAY_CNT), A
	LD (IY + ep.ENP.RESPAWN_DELAY_CNT), A
	LD (IY + ep.ENP.MOVE_PAT_STEP), A
	LD (IY + ep.ENP.MOVE_PAT_STEP_RCNT), A

	LD A, ep.MOVE_PAT_STEP_OFFSET
	LD (IY + ep.ENP.MOVE_PAT_POS), A

	DJNZ .enemyLoop

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE