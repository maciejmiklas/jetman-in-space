/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                   Following Enemy                        ;
;----------------------------------------------------------;
    MODULE fed
    ; ### TO USE THIS MODULE: CALL dbs.SetupFollowingEnemyBank ###

; Sprites, used by single enemies (#spriteExXX).
fEnemySprites
    ;    ID   SDB_INIT        SDB_POINTER  X   Y   STATE  NEXT REMAINING COLLISION_CNT EXT_DATA_POINTER
    SPR {089, sp.SDB_ENEMY1A, 0,           0,  0,  0,     0,   0,        0,            fEnemy01}
    SPR {099, sp.SDB_ENEMY1A, 0,           0,  0,  0,     0,   0,        0,            fEnemy02}
    SPR {100, sp.SDB_ENEMY1A, 0,           0,  0,  0,     0,   0,        0,            fEnemy03}
    SPR {101, sp.SDB_ENEMY1A, 0,           0,  0,  0,     0,   0,        0,            fEnemy04}
    SPR {102, sp.SDB_ENEMY1A, 0,           0,  0,  0,     0,   0,        0,            fEnemy05}
    SPR {103, sp.SDB_ENEMY1A, 0,           0,  0,  0,     0,   0,        0,            fEnemy06}
    SPR {104, sp.SDB_ENEMY1A, 0,           0,  0,  0,     0,   0,        0,            fEnemy07}
    SPR {105, sp.SDB_ENEMY1A, 0,           0,  0,  0,     0,   0,        0,            fEnemy08}
    SPR {106, sp.SDB_ENEMY1A, 0,           0,  0,  0,     0,   0,        0,            fEnemy09}
    SPR {107, sp.SDB_ENEMY1A, 0,           0,  0,  0,     0,   0,        0,            fEnemy10}
    SPR {108, sp.SDB_ENEMY1A, 0,           0,  0,  0,     0,   0,        0,            fEnemy11}
    SPR {109, sp.SDB_ENEMY1A, 0,           0,  0,  0,     0,   0,        0,            fEnemy12}
    SPR {110, sp.SDB_ENEMY1A, 0,           0,  0,  0,     0,   0,        0,            fEnemy13}
    SPR {111, sp.SDB_ENEMY1A, 0,           0,  0,  0,     0,   0,        0,            fEnemy14}
    SPR {112, sp.SDB_ENEMY1A, 0,           0,  0,  0,     0,   0,        0,            fEnemy15}
fEnemySize              BYTE 1
FOLLOWING_FENEMY_SIZE   = 15                    ; Max size

fEnemy01
    FE {STATE_DEPLOY_RIGHT ,     080/*RESPAWN_Y*/, 01/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/, 0,0,0,0,0,0}

fEnemy02
    FE {STATE_DEPLOY_LEFT ,     080/*RESPAWN_Y*/, 01/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/, 0,0,0,0,0,0}

fEnemy03
    FE {STATE_DEPLOY_RIGHT ,     080/*RESPAWN_Y*/, 01/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/, 0,0,0,0,0,0}

fEnemy04
    FE {STATE_DEPLOY_RIGHT ,     080/*RESPAWN_Y*/, 01/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/, 0,0,0,0,0,0}

fEnemy05
    FE {STATE_DEPLOY_RIGHT ,     080/*RESPAWN_Y*/, 01/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/, 0,0,0,0,0,0}

fEnemy06
    FE {STATE_DEPLOY_RIGHT ,     080/*RESPAWN_Y*/, 01/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/, 0,0,0,0,0,0}

fEnemy07
    FE {STATE_DEPLOY_RIGHT ,     080/*RESPAWN_Y*/, 01/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/, 0,0,0,0,0,0}

fEnemy08
    FE {STATE_DEPLOY_RIGHT ,     080/*RESPAWN_Y*/, 01/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/, 0,0,0,0,0,0}

fEnemy09
    FE {STATE_DEPLOY_RIGHT ,     080/*RESPAWN_Y*/, 01/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/, 0,0,0,0,0,0}

fEnemy10
    FE {STATE_DEPLOY_RIGHT ,     080/*RESPAWN_Y*/, 01/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/, 0,0,0,0,0,0}

fEnemy11
    FE {STATE_DEPLOY_RIGHT ,     080/*RESPAWN_Y*/, 01/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/, 0,0,0,0,0,0}

fEnemy12
    FE {STATE_DEPLOY_RIGHT ,     080/*RESPAWN_Y*/, 01/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/, 0,0,0,0,0,0}

fEnemy13
    FE {STATE_DEPLOY_RIGHT ,     080/*RESPAWN_Y*/, 01/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/, 0,0,0,0,0,0}

fEnemy14
    FE {STATE_DEPLOY_RIGHT ,     080/*RESPAWN_Y*/, 01/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/, 0,0,0,0,0,0}

fEnemy15
    FE {STATE_DEPLOY_RIGHT ,     080/*RESPAWN_Y*/, 01/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/, 0,0,0,0,0,0}

; ##############################################
; Level 5
fEnemyL05
    FES {STATE_DEPLOY_RIGHT ,     015/*RESPAWN_Y*/, 15/*RESPAWN_DELAY*/, 02/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_LEFT  ,     005/*RESPAWN_Y*/, 25/*RESPAWN_DELAY*/, 01/*MOVE_DELAY*/}
FENEMY_SIZE_L5          = 2

; ##############################################
; Level 8
fEnemyL08
    FES {STATE_DEPLOY_RIGHT ,     040/*RESPAWN_Y*/, 11/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_LEFT  ,     040/*RESPAWN_Y*/, 15/*RESPAWN_DELAY*/, 01/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_RIGHT ,     060/*RESPAWN_Y*/, 11/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_LEFT  ,     060/*RESPAWN_Y*/, 15/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_RIGHT ,     080/*RESPAWN_Y*/, 15/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_LEFT  ,     080/*RESPAWN_Y*/, 05/*RESPAWN_DELAY*/, 01/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_RIGHT ,     120/*RESPAWN_Y*/, 11/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_LEFT  ,     120/*RESPAWN_Y*/, 10/*RESPAWN_DELAY*/, 02/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_RIGHT ,     140/*RESPAWN_Y*/, 11/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_LEFT  ,     140/*RESPAWN_Y*/, 10/*RESPAWN_DELAY*/, 01/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_LEFT  ,     180/*RESPAWN_Y*/, 13/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_RIGHT ,     180/*RESPAWN_Y*/, 18/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_LEFT  ,     200/*RESPAWN_Y*/, 15/*RESPAWN_DELAY*/, 02/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_RIGHT ,     200/*RESPAWN_Y*/, 10/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_RIGHT ,     220/*RESPAWN_Y*/, 10/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/}
FENEMY_SIZE_L8          = 15

; Level 9
fEnemyL09
    FES {STATE_DEPLOY_RIGHT ,     024/*RESPAWN_Y*/, 15/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_LEFT  ,     024/*RESPAWN_Y*/, 25/*RESPAWN_DELAY*/, 01/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_RIGHT ,     040/*RESPAWN_Y*/, 15/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_LEFT  ,     040/*RESPAWN_Y*/, 13/*RESPAWN_DELAY*/, 01/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_RIGHT ,     100/*RESPAWN_Y*/, 21/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_LEFT  ,     080/*RESPAWN_Y*/, 20/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_LEFT  ,     160/*RESPAWN_Y*/, 23/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_RIGHT ,     180/*RESPAWN_Y*/, 18/*RESPAWN_DELAY*/, 01/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_LEFT  ,     200/*RESPAWN_Y*/, 25/*RESPAWN_DELAY*/, 03/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_RIGHT ,     200/*RESPAWN_Y*/, 15/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_LEFT  ,     010/*RESPAWN_Y*/, 25/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_RIGHT ,     010/*RESPAWN_Y*/, 15/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/}
FENEMY_SIZE_L9          = 12

; Level 10
fEnemyL10
    FES {STATE_DEPLOY_RIGHT ,     040/*RESPAWN_Y*/, 15/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_LEFT  ,     040/*RESPAWN_Y*/, 15/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_RIGHT ,     080/*RESPAWN_Y*/, 11/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_LEFT  ,     080/*RESPAWN_Y*/, 13/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_RIGHT ,     128/*RESPAWN_Y*/, 21/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_LEFT  ,     128/*RESPAWN_Y*/, 10/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_LEFT  ,     216/*RESPAWN_Y*/, 13/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_RIGHT ,     216/*RESPAWN_Y*/, 18/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_LEFT  ,     232/*RESPAWN_Y*/, 15/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_RIGHT ,     232/*RESPAWN_Y*/, 15/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/}
FENEMY_SIZE_L10          = 10

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE