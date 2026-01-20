/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                   Following Enemy                        ;
;----------------------------------------------------------;
    MODULE fed
    ; ### TO USE THIS MODULE: CALL dbs.SetupFollowingEnemyBank ###

; ##############################################
; Level 8
fEnemyL08
    FES {STATE_DEPLOY_RIGHT /*STATE*/, 040/*RESPAWN_Y*/, 15/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_LEFT  /*STATE*/, 040/*RESPAWN_Y*/, 25/*RESPAWN_DELAY*/, 01/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_RIGHT /*STATE*/, 080/*RESPAWN_Y*/, 15/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_LEFT  /*STATE*/, 080/*RESPAWN_Y*/, 13/*RESPAWN_DELAY*/, 02/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_RIGHT /*STATE*/, 120/*RESPAWN_Y*/, 11/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_LEFT  /*STATE*/, 120/*RESPAWN_Y*/, 20/*RESPAWN_DELAY*/, 02/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_LEFT  /*STATE*/, 180/*RESPAWN_Y*/, 13/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_RIGHT /*STATE*/, 180/*RESPAWN_Y*/, 18/*RESPAWN_DELAY*/, 01/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_LEFT  /*STATE*/, 200/*RESPAWN_Y*/, 25/*RESPAWN_DELAY*/, 02/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_RIGHT /*STATE*/, 200/*RESPAWN_Y*/, 10/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/}
FENEMY_SIZE_L8          = 10

; Level 9
fEnemyL09
    FES {STATE_DEPLOY_RIGHT /*STATE*/, 040/*RESPAWN_Y*/, 15/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_LEFT  /*STATE*/, 060/*RESPAWN_Y*/, 25/*RESPAWN_DELAY*/, 01/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_RIGHT /*STATE*/, 080/*RESPAWN_Y*/, 15/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_LEFT  /*STATE*/, 080/*RESPAWN_Y*/, 13/*RESPAWN_DELAY*/, 02/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_RIGHT /*STATE*/, 100/*RESPAWN_Y*/, 11/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_LEFT  /*STATE*/, 120/*RESPAWN_Y*/, 20/*RESPAWN_DELAY*/, 02/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_LEFT  /*STATE*/, 150/*RESPAWN_Y*/, 13/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_RIGHT /*STATE*/, 180/*RESPAWN_Y*/, 18/*RESPAWN_DELAY*/, 01/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_LEFT  /*STATE*/, 100/*RESPAWN_Y*/, 25/*RESPAWN_DELAY*/, 03/*MOVE_DELAY*/}
    FES {STATE_DEPLOY_RIGHT /*STATE*/, 200/*RESPAWN_Y*/, 10/*RESPAWN_DELAY*/, 00/*MOVE_DELAY*/}
FENEMY_SIZE_L9          = 10


;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE