/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;               Formation of 16x16 enemies                 ;
;----------------------------------------------------------;
    MODULE enf

    ; ### TO USE THIS MODULE: CALL dbs.SetupPatternEnemyBank ###

; The enemy formation consists of multiple sprites. #formationEnemySprites gives the first sprite, and #ENEMY_FORMATION_SIZE
; determines the amount. The deployment starts when #respawnDelayCnt will reach #respawnDelay. 
; There is also a delay in respawning each enemy in the formation (#ENPS.RESPAWN_DELAY_D22). It will define the distance between single
; enemies in the formation.

spritesCnt              DB 0                    ; Counter for #ENEMY_FORMATION_SIZE.
respawnDelay            DB 0                    ; Delay to respawn the whole formation.
respawnDelayCnt         DB 0                    ; Counter for #respawnDelay.
formationSize           DB 0

;----------------------------------------------------------;
;                 MoveFormationEnemies                     ;
;----------------------------------------------------------;
MoveFormationEnemies

    ; Check whether formation is disabled.
    LD A, (formationSize)
    OR A                                        ; Same as CP 0, but faster.
    RET Z

    LD B, A
    LD IX, ena.formationEnemySprites
    CALL enp.MovePatternEnemies

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    SetupEnemyFormation                   ;
;----------------------------------------------------------;
;Input:
;  - A:  size of the formation.
;  - B:  delay to respawn the whole formation.
;  - IX: pointer to setup (#ENPS).
SetupEnemyFormation

    LD (formationSize), A
    OR A                                        ; Same as CP 0, but faster.
    RET Z

    LD A, B
    LD (respawnDelay), A

    ; ##########################################
    PUSH IX                                     ; Keep method param.
    LD B, ena.ENEMY_FORMATION_SIZE
    LD IX, ena.formationEnemySprites
    CALL enp.ResetPatternEnemies
    POP IX

    ; ##########################################
    XOR A
    LD (respawnDelayCnt), A
    LD (spritesCnt), A

    ; ##########################################
    ; Copy one given #ENPS to all #ENP.
    LD IY, ena.spriteExEf01                      ; Points to first #ENP.
    LD B, ena.ENEMY_FORMATION_SIZE               ; Enemies size (number of #ENP structs).
.enpLoop
    CALL enp.ResetEnp
    CALL enp.CopyEnpsToEnp

    ; Move IY to next array position.
    LD DE, IY
    ADD DE, ENP
    LD IY, DE
    DJNZ .enpLoop

    ; ##########################################
    ; Copy one given #ENPS to all #SPR.
    LD IY, ena.formationEnemySprites             ; Pointer to #SPR array.
    LD B, ena.ENEMY_FORMATION_SIZE               ; Enemies size (number of #SPR structs).
.sprLoop
    LD A, (IX + ENPS.SDB_INIT)
    LD (IY + SPR.SDB_INIT), A

    ; Move IY to next array position.
    LD DE, IY
    ADD DE, SPR
    LD IY, DE
    DJNZ .sprLoop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    RespawnFormation                      ;
;----------------------------------------------------------;
RespawnFormation

    ; Check whether formation is disabled
    LD A, (formationSize)
    OR A                                        ; Same as CP 0, but faster.
    RET Z

    ; ##########################################
    ; Check whether the respawn delay timer is 0, indicating that deployment is over.
    LD A, (respawnDelayCnt)
    OR A                                        ; Same as CP 0, but faster.
    JR NZ, .afterStillAliveCheck

    ; The respawn delay timer is 0. We could start a new deployment, but first, we must check whether some enemies from the previous.
    ; deployment are still visible.
    LD IX, ena.formationEnemySprites
    LD B, ena.ENEMY_FORMATION_SIZE
    CALL sr.CheckAnySpriteVisible
    RET Z                                       ; Return if at least one sprite is visible.

.afterStillAliveCheck

    ; ##########################################
    ; Check whether the timer is up and whether it's time to start a new formation deployment.
    LD A, (respawnDelay)
    LD B, A
    LD A, (respawnDelayCnt)

    ; Compare timer
    CP B
    JR Z, .startRespawn                         ; Jump if #RESPAWN_DELAY_D22 == #respawnDelayCnt.
    INC A                                       ; Increment delay timer and return.
    LD (respawnDelayCnt), A
    RET
.startRespawn                                   ; #RESPAWN_DELAY_D22 == #respawnDelayCnt -> deployment is active.

    ; ##########################################
    ; Formation deployment in progress.....

    ; Check if deployment is over -> the last sprite has been deployed.
    LD A, (spritesCnt)
    LD B, ena.ENEMY_FORMATION_SIZE
    CP B
    JR C, .deployNextEnemy                      ; Jump if #spritesCnt < #ENEMY_FORMATION_SIZE -> There are still enemies that need to be deployed.
    
    ; Deployment is over, reset formation counters.
    XOR A
    LD (spritesCnt), A
    LD (respawnDelayCnt), A
    RET

.deployNextEnemy
    ; ##########################################
    ; Deploy next enemy!
    LD HL, ena.formationEnemySprites
    LD IX, HL                                   ; IX points to the #SPR with the first sprite in the enemy formation.

    ; Move IX to the current sprite in the enemy formation.
    LD A, (spritesCnt)
    LD D, A                                     ; IX = IX + spritesCnt * SPR.
    LD E, SPR
    MUL D, E
    ADD IX, DE                                  ; Now IX points to the current #SPR that should be deployed.

    CALL enp.RespawnPatternEnemy                ; Has the enemy respawned?
    RET NZ                                      ; Enemy did not respawn, probably still waiting for #ENP.RESPAWN_DELAY_CNT.

    ; ##########################################
    ; Move to the next enemy if this has respawned.
    LD A, (spritesCnt)
    INC A
    LD (spritesCnt), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE