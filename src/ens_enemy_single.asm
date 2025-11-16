;----------------------------------------------------------;
;                    Single  Enemy                         ;
;----------------------------------------------------------;
    MODULE ens

    ; ### TO USE THIS MODULE: CALL dbs.SetupPatternEnemyBank ###

; The timer ticks with every game loop. When it reaches #ENP_RESPAWN_DELAY, a single enemy will respawn, and the timer starts from 0,
; counting again.
singleRespDelayCnt      DB 0
singleEnemySize         DB ena.ENEMY_SINGLE_SIZE

NEXT_RESP_DEL           = 3

; Each enemy has a dedicated respawn delay (#ENP.RESPAWN_DELAY_CNT). Enemies are respawned one after another from the enemies list.
; An additional delay is defined here to avoid situations where multiple enemies are respawned simultaneously. It is used to delay
; the respawn of the next enemy from the enemies list. 
nextRespDel             DB NEXT_RESP_DEL

;----------------------------------------------------------;
;                   MoveSingleEnemies                      ;
;----------------------------------------------------------;
MoveSingleEnemies

    ; Single enemies disabled?
    LD A, (singleEnemySize)
    CP 0
    RET Z

    LD B, A
    LD IX, ena.singleEnemySprites
    CALL enp.MovePatternEnemies

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   SetupSingleEnemies                     ;
;----------------------------------------------------------;
; Resets single enemies and loads given #ENPS array into #ENP and #SPR. Expected size for both arrays is given by: _EN_SINGLE_SIZE.
; Input:
;   - A:  number of single enemies (size of #ENPS).
;   - B:  respawn delay for #nextRespDel.
;   - IX: pointer to #ENPS array.
SetupSingleEnemies

    LD (singleEnemySize), A
    CP 0
    RET Z

    LD A, B
    LD (nextRespDel), A

    ; ##########################################
    PUSH IX
    LD B, ena.ENEMY_SINGLE_SIZE
    LD IX, ena.singleEnemySprites
    CALL enp.ResetPatternEnemies
    POP IX

    PUSH IX
    ; ##########################################
    ; Load #ENPS into #ENP.
    LD IY, ena.spriteEx01                       ; Pointer to #ENP array.
    LD A, (singleEnemySize)                     ; Single enemies size (number of #ENPS/#ENP arrays).
    LD B, A
.enpLoop

    CALL enp.CopyEnpsToEnp

    ; ##########################################
    ; Move IX to next array postion.
    LD DE, IX
    ADD DE, ENPS
    LD IX, DE

    ; Move IY to next array postion.
    LD DE, IY
    ADD DE, ENP
    LD IY, DE
    
    DJNZ .enpLoop
    POP IX

    ; ##########################################
    ; Load #ENPS int #SPR.
    LD IY, ena.singleEnemySprites               ; Pointer to #SPR array.
    LD A, (singleEnemySize)                     ; Single enemies size (number of #ENPS/#SPR arrays).
    LD B, A
.sprLoop

    LD A, (IX + ENPS.SDB_INIT)
    LD (IY + SPR.SDB_INIT), A

    ; ##########################################
    ; Move IX to next array postion.
    LD DE, IX
    ADD DE, ENPS
    LD IX, DE

    ; Move IY to next array postion.
    LD DE, IY
    ADD DE, SPR
    LD IY, DE

    DJNZ .sprLoop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 RespawnNextSingleEnemy                   ;
;----------------------------------------------------------;
; Respawns next single enemy. To respawn next from formation use enf.RespawnFormation.
RespawnNextSingleEnemy

    ; Single enemies disabled?
    LD A, (singleEnemySize)
    CP 0
    RET Z

    ; Increment respawn timer and exit function if it's not time to respawn a new enemy.
    LD A, (nextRespDel)
    CP 0
    JR Z, .startRespawn
    LD D, A
    LD A, (singleRespDelayCnt)
    INC A
    CP D
    JR Z, .startRespawn                         ; Jump if the timer reaches respawn delay.
    LD (singleRespDelayCnt), A

    RET
.startRespawn
    XOR A                                       ; Set A to 0.
    LD (singleRespDelayCnt), A                  ; Reset delay timer.

    ; ##########################################
    ; Iterate over all enemies to find the first hidden, respawn it, and exit function.
    LD IX, ena.singleEnemySprites
    LD A, (singleEnemySize)
    LD B, A

.loop
    PUSH BC                                     ; Preserve B for loop counter.
    CALL enp.RespawnPatternEnemy
    POP BC

    CP A, _RET_YES_D1
    RET Z                                       ; Exit after respawning first enemy.

    ; Move IX to the beginning of the next #singleEnemySprites.
    LD DE, SPR
    ADD IX, DE
    DJNZ .loop                                  ; Jump if B > 0 (loop starts with B = _EN_SINGLE_SIZE).

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE