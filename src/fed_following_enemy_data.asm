;----------------------------------------------------------;
;                   Following Enemy                        ;
;----------------------------------------------------------;
    MODULE fed
    ; ### TO USE THIS MODULE: CALL dbs.SetupFollowingEnemyBank ###


; ##############################################
; Level 8
fEnemyL08
    FES {STATE_DEPLOY_RIGHT /*STATE*/, 040/*RESPAWN_Y*/, 05/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_LEFT  /*STATE*/, 040/*RESPAWN_Y*/, 05/*RESPAWN_DELAY*/, 01/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_RIGHT /*STATE*/, 080/*RESPAWN_Y*/, 05/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_LEFT  /*STATE*/, 080/*RESPAWN_Y*/, 05/*RESPAWN_DELAY*/, 02/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_RIGHT /*STATE*/, 120/*RESPAWN_Y*/, 05/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_LEFT  /*STATE*/, 120/*RESPAWN_Y*/, 05/*RESPAWN_DELAY*/, 02/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_LEFT  /*STATE*/, 180/*RESPAWN_Y*/, 05/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_RIGHT /*STATE*/, 180/*RESPAWN_Y*/, 05/*RESPAWN_DELAY*/, 01/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_LEFT  /*STATE*/, 200/*RESPAWN_Y*/, 05/*RESPAWN_DELAY*/, 02/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_RIGHT /*STATE*/, 200/*RESPAWN_Y*/, 05/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/}
FENEMY_SIZE_L8          = 10

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE