;----------------------------------------------------------;
;                    Single  Enemy                         ;
;----------------------------------------------------------;
	MODULE ens

; The timer ticks with every game loop. When it reaches #ENP_RESPAWN_DELAY, a single enemy will respawn, and the timer starts from 0, counting again.
singleRespDelayCnt 		BYTE 0
singleEnemySize			BYTE db.ENEMY_SINGLE_SIZE

NEXT_RESP_DEL			= 3
; Each enemy has a dedicated respawn delay (enf.RESPAWN_DELAY_CNT). Enemies are renowned one after another from the enemies list. 
; An additional delay is defined here to avoid situations where multiple enemies are respawned simultaneously. It is used to delay 
; the respawn of the next enemy from the enemies list. 
nextRespDel				BYTE NEXT_RESP_DEL


;----------------------------------------------------------;
;                  #MoveSingleEnemies                      ;
;----------------------------------------------------------;
MoveSingleEnemies

	LD IX, db.singleEnemySprites
	LD A, (singleEnemySize)
	LD B, A

	CALL enp.MovePatternEnemies

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #SetupSingleEnemies                     ;
;----------------------------------------------------------;
; Resets single enemies and loads given #enp.ENPS array into #enp.ENP and #sr.SPR. Expected size for both arrays is given by: _EN_SINGLE_SIZE.
; Input:
;   - A:  Number of single enemies (size of #ENPS)
;   - B:  Respawn delay for #nextRespDel
;   - IX: Pointer to #ENPS array.
SetupSingleEnemies
	CALL dbs.SetupArraysBank

	LD (singleEnemySize), A
	LD A, B
	LD (nextRespDel), A

	; ##########################################
	PUSH IX
	LD B, db.ENEMY_SINGLE_SIZE
	LD IX, db.singleEnemySprites
	CALL enp.ResetPatternEnemies
	POP IX

	PUSH IX
	; ##########################################
	; Load #enp.ENPS int #enp.ENP
	LD IY, db.spriteEx01						; Pointer to #ENP array.
	LD A, (singleEnemySize)						; Single enemies size (number of #ENPS/#ENP arrays).
	LD B, A
.enpLoop

	CALL enp.CopyEnpsToEnp

	; ##########################################
	; Move IX to next array postion.
	LD DE, IX
	ADD DE, enp.ENPS
	LD IX, DE

	; Move IY to next array postion.
	LD DE, IY
	ADD DE, enp.ENP
	LD IY, DE
	
	DJNZ .enpLoop
	POP IX

	; ##########################################
	; Load #enp.ENPS int #sr.SPR
	LD IY, db.singleEnemySprites				; Pointer to #SPR array.
	LD A, (singleEnemySize)						; Single enemies size (number of #ENPS/#SPR arrays).
	LD B, A
.sprLoop

	LD A, (IX + enp.ENPS.SDB_INIT)
	LD (IY + sr.SPR.SDB_INIT), A

	; ##########################################
	; Move IX to next array postion.
	LD DE, IX
	ADD DE, enp.ENPS
	LD IX, DE

	; Move IY to next array postion.
	LD DE, IY
	ADD DE, sr.SPR
	LD IY, DE

	DJNZ .sprLoop

	RET											; ## END of the function ##

tmp byte 0
;----------------------------------------------------------;
;                #RespawnNextSingleEnemy                   ;
;----------------------------------------------------------;
; Respawns next single enemy. To respawn next from formation use enf.RespawnFormation
RespawnNextSingleEnemy

	CALL dbs.SetupArraysBank

	; ##########################################	
	; Increment respawn timer and exit function if it's not time to respawn a new enemy.
	LD A, (nextRespDel)
	CP 0
	JR Z, .startRespawn
	LD D, A
	LD A, (singleRespDelayCnt)
	INC A
	CP D
	JR Z, .startRespawn							; Jump if the timer reaches respawn delay.
	LD (singleRespDelayCnt), A

	RET
.startRespawn	
	ld a, (tmp)
	inc a
	ld (tmp),a
	XOR A										; Set A to 0.
	LD (singleRespDelayCnt), A					; Reset delay timer.

	; ##########################################
	; Iterate over all enemies to find the first hidden, respawn it, and exit function.
	LD IX, db.singleEnemySprites
	LD A, (singleEnemySize)
	LD B, A

.loop
	PUSH BC										; Preserve B for loop counter.
	CALL enp.RespawnPatternEnemy
	POP BC

	CP A, enp.RES_SE_OUT_YES
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
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE