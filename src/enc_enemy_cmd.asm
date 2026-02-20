/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                    Enemy Command                         ;
;----------------------------------------------------------;
    MODULE enc
KILL_FEW                = 7

freezeEnemiesCnt        DW 0
FREEZE_ENEMIES_CNT      = 60 * 10               ; Freeze for 10 Seconds

;----------------------------------------------------------;
;                      InitEnemies                         ;
;----------------------------------------------------------;
InitEnemies

    XOR A
    LD (freezeEnemiesCnt), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 CheckEnemyWeaponHit                      ;
;----------------------------------------------------------;
CheckEnemyWeaponHit

    CALL dbs.SetupArrays2Bank

    ; ##########################################
    CALL dbs.SetupPatternEnemyBank

    LD A, (ens.singleEnemySize)
    LD IX, ena.singleEnemySprites
    CALL jw.CheckHitEnemies

    ; ##########################################
    LD A, (enf.formationSize)
    LD IX, ena.formationEnemySprites
    CALL jw.CheckHitEnemies

    ; ##########################################
    CALL dbs.SetupFollowingEnemyBank

    LD IX, fed.fEnemySprites
    LD A, (fed.fEnemySize)
    CALL jw.CheckHitEnemies

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      HideEnemies                         ;
;----------------------------------------------------------;
HideEnemies

    ; Hide single enemies.
    CALL dbs.SetupPatternEnemyBank

    LD A, ena.ENEMY_SINGLE_SIZE
    LD IX, ena.singleEnemySprites
    CALL sp.HideAllSprites

    ; ##########################################
    ; Hide formation enemies.
    LD A, (enf.formationSize)
    LD IX, ena.formationEnemySprites
    CALL sp.HideAllSprites

    ; ##########################################
    ; Hide following enemies.
    CALL dbs.SetupFollowingEnemyBank
    
    LD A, fed.FOLLOWING_FENEMY_SIZE
    LD IX, fed.fEnemySprites
    CALL sp.HideAllSprites

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     AnimateEnemies                       ;
;----------------------------------------------------------;
AnimateEnemies

    ; Animate single enemy
    CALL dbs.SetupPatternEnemyBank

    LD A, (ens.singleEnemySize)
    LD IX, ena.singleEnemySprites
    CALL sp.AnimateSprites

    ; ##########################################
    ; Animate formation enemy
    LD A, (enf.formationSize)
    LD IX, ena.formationEnemySprites
    CALL sp.AnimateSprites

    ; ##########################################
    CALL dbs.SetupFollowingEnemyBank

    LD A, (fed.fEnemySize)
    LD IX, fed.fEnemySprites
    CALL sp.AnimateSprites

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     KillFewEnemies                       ;
;----------------------------------------------------------;
KillFewEnemies

    LD B, KILL_FEW
.killLoop
    PUSH BC

    CALL KillOneEnemy

    POP BC
    DJNZ .killLoop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      KillOneEnemy                        ;
;----------------------------------------------------------;
KillOneEnemy

    ; Kill single enemy
    CALL dbs.SetupPatternEnemyBank
    LD A, (ens.singleEnemySize)
    LD IX, ena.singleEnemySprites
    CALL sp.KillOneSprite

    ; ##########################################
    ; Kill formation enemy
    LD A, (enf.formationSize)
    LD IX, ena.formationEnemySprites
    CALL sp.KillOneSprite

    ; ##########################################
    ; Kill following enemy
    CALL dbs.SetupFollowingEnemyBank

    LD A, (fed.fEnemySize)
    LD IX, fed.fEnemySprites
    CALL sp.KillOneSprite

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   FreezeEnemies                          ;
;----------------------------------------------------------;
FreezeEnemies

    CALL dbs.SetupAyFxsBank
    LD A, af.FX_FREEZE_ENEMIES
    CALL af.AfxPlay

    LD DE, FREEZE_ENEMIES_CNT
    LD (freezeEnemiesCnt), DE

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     RespawnEnemy                         ;
;----------------------------------------------------------;
RespawnEnemy

    ; Enemies frozen and cannot move/respawn?
    LD DE, (freezeEnemiesCnt)

    LD A, D
    OR A                                        ; Same as CP 0, but faster.
    RET NZ

    LD A, E
    OR A                                        ; Same as CP 0, but faster.
    RET NZ

    ; ##########################################
    CALL dbs.SetupPatternEnemyBank
    CALL ens.RespawnNextSingleEnemy

    CALL dbs.SetupFollowingEnemyBank
    CALL fe.RespawnFollowingEnemy

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      MoveEnemies                         ;
;----------------------------------------------------------;
MoveEnemies

    ; Enemies frozen and cannot move?
    LD DE, (freezeEnemiesCnt)
    
    ; DE == 0 ?
    LD A, D
    OR A                                        ; Same as CP 0, but faster.
    JR NZ, .decFreezeCnt

    ; D == 0, now check E
    LD A, E
    OR A                                        ; Same as CP 0, but faster.
    JR Z, .afterFreeze

.decFreezeCnt
    DEC DE
    LD (freezeEnemiesCnt), DE
    RET
.afterFreeze

    ; ##########################################
    CALL dbs.SetupPatternEnemyBank
    CALL ens.MoveSingleEnemies
    CALL enf.MoveFormationEnemies

    CALL dbs.SetupFollowingEnemyBank
    CALL fe.MoveFollowingEnemies

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE