/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                        Enemy Data                        ;
;----------------------------------------------------------;
    MODULE ena
    ; ### TO USE THIS MODULE: CALL dbs.SetupPatternEnemyBank ###

;----------------------------------------------------------;
;                   Movement patterns                      ;
;----------------------------------------------------------;

; Move delay is not directly a delay, but also not a speed. Here is a mapping from delay to speed in pixels:
;  - delay 0 moves by 3 pixels
;  - delay 1 moves by 2 pixels
;  - delay 2 moves by 1 pixel (normal speed)
;  - delay 3 skips 1 pixel
; We could say that delay 0 and 1 speed up, 2 does nothing, and first delay 3 slows down.

; Horizontal, max speed
movePattern01D0
    DB 2, %0'000'1'111,$00

; Horizontal, delay 1
movePattern01D1
    DB 2, %0'000'1'111,$10

; Horizontal, delay 2
movePattern01D2
    DB 2, %0'000'1'111,$20

; Horizontal, delay 3
movePattern01D3
    DB 2, %0'000'1'111,$3A

; 18deg down, delay 0
movePattern02D0
    DB 2, %1'001'1'111,$00

; 18deg down, delay 1
movePattern02D1
    DB 2, %1'001'1'111,$10

; 18deg down, delay 2
movePattern02D2
    DB 2, %1'001'1'111,$20

; 18deg down, delay 3
movePattern02D3
    DB 2, %1'001'1'111,$30

; 18deg up, delay 0
movePattern03D0
    DB 2, %0'001'1'111,$20

; 5* horizontal, 2x 45deg down
movePattern05
    DB 4, %0'000'1'111,$05, %1'111'1'111,$02

; Half sinus
movePattern06
    DB 32, %0'010'1'001,$22, %0'011'1'010,$22, %0'100'1'011,$31, %0'011'1'011,$31, %0'010'1'011,$33, %0'001'1'011,$32, %0'001'1'100,$32, %0'001'1'101,$31   ; going up
        DB %1'001'1'101,$21, %1'001'1'100,$22, %1'001'1'011,$22, %1'010'1'011,$23, %1'011'1'011,$11, %1'100'1'011,$11, %1'011'1'010,$12, %1'010'1'001,$01   ; going down

; Sinus
movePattern07
    DB 64, %0'010'1'001,$32, %0'011'1'010,$32, %0'100'1'011,$31, %0'011'1'011,$31, %0'010'1'011,$33, %0'001'1'011,$32, %0'001'1'100,$32, %0'001'1'101,$31   ; going up, above X
        DB %1'001'1'101,$21, %1'001'1'100,$22, %1'001'1'011,$22, %1'010'1'011,$23, %1'011'1'011,$21, %1'100'1'011,$21, %1'011'1'010,$22, %1'010'1'001,$22   ; going down, above X
        DB %1'010'1'001,$21, %1'011'1'010,$21, %1'100'1'011,$21, %1'011'1'011,$21, %1'010'1'011,$13, %1'001'1'011,$12, %1'001'1'100,$12, %1'001'1'101,$11   ; going down, below X
        DB %0'001'1'101,$21, %0'001'1'100,$22, %0'001'1'011,$22, %0'010'1'011,$23, %0'011'1'011,$21, %0'100'1'011,$31, %0'011'1'010,$32, %0'010'1'001,$32   ; going up, below X

; Saw wave
movePattern08
;          45deg up          45deg up           45deg down        45deg down      45deg down
    DB 10, %0'001'1'011,$2F, %0'001'1'011,$2F, %1'001'1'011,$2F, %1'001'1'011,$2F, %1'001'1'011,$2F 

; Saw wave
movePattern09
;         45deg up slow    45deg down slow   45deg up slow   45deg down slow  45deg up fast   45deg down fast
    DB 12, %0'001'1'011,$41, %1'001'1'011,$41, %0'001'1'011,$41, %1'001'1'011,$41, %0'001'1'011,$31, %1'001'1'011,$31

movePattern11
;         45deg down         horizontal        horizontal       horizontal         45deg up
    DB 10, %1'111'1'111,$0F, %0'000'1'111,$1F, %0'000'1'111,$2F, %0'000'1'111,$1F, %0'011'1'011,$3F 

; 34deg up, delay 2
movePattern12D2
    DB 2, %0'011'1'111,$20 

; 34deg up, delay 1
movePattern12D1
    DB 2, %0'011'1'111,$10 

; 34deg down, delay 0
movePattern13D0
    DB 2, %1'011'1'111,$00 

; 34deg down, delay 1
movePattern13D1
    DB 2, %1'011'1'111,$10 

; 34deg down, delay 2
movePattern13D2
    DB 2, %1'011'1'111,$20 

; 34deg down, delay 3
movePattern13D3
    DB 2, %1'011'1'111,$30 

; 34deg down, delay 4
movePattern13D4
    DB 2, %1'011'1'111,$40 

; 45deg down, delay 0
movePattern14D0
    DB 2, %1'001'1'001,$00 

; 45deg down, delay 1
movePattern14D1
    DB 2, %1'001'1'001,$10 

; 45deg down, delay 2
movePattern14D2
    DB 2, %1'001'1'001,$20 

; 45deg up, delay 1
movePattern15D1
    DB 2, %0'001'1'001,$10 

; 45deg up, delay 2
movePattern15D2
    DB 2, %0'001'1'001,$20 

movePattern16
;         horizontal        45deg up
    DB 4, %0'000'1'111,$0C, %0'111'1'111,$19 

movePattern17
;           horizontal fast  horizontal slow    34deg down        horizontal        34deg up
    DB 10, %0'000'1'111,$1A, %0'000'1'111,$45, %1'011'1'111,$05, %0'000'1'111,$29, %0'011'1'111,37

movePattern18
;         horizontal        45deg down
    DB 4, %0'000'1'111,$2C, %1'111'1'111,$39 

; Horizontal, variable speed
movePattern19
    DB 6, %0'000'1'111,$2F, %0'000'1'111,$1F, %0'000'1'111,$35 

; sinus, up
movePattern20
    DB 65, %0'010'1'001,$32, %0'011'1'010,$32, %0'100'1'011,$31, %0'011'1'011,$31, %0'010'1'011,$33, %0'001'1'011,$32, %0'001'1'100,$32, %0'001'1'101,$31   ; going up, above X
        DB %1'001'1'101,$21, %1'001'1'100,$22, %1'001'1'011,$22, %1'010'1'011,$23, %1'011'1'011,$21, %1'100'1'011,$21, %1'011'1'010,$22, %1'010'1'001,$22   ; going down, above X
        DB %1'010'1'001,$21, %1'011'1'010,$21, %1'100'1'011,$21, %1'011'1'011,$21, %1'010'1'011,$13, %1'001'1'011,$12, %1'001'1'100,$12, %1'001'1'101,$11   ; going down, below X
        DB %0'001'1'101,$21, %0'001'1'100,$22, %0'001'1'011,$22, %0'010'1'011,$23, %0'011'1'011,$21, %0'100'1'011,$31, %0'011'1'010,$32, %0'010'1'001,$32   ; going up, below X
        DB %1'111'1'111,$2F 

movePattern21
;         horizontal         45deg up
    DB 4, %0'000'1'111,$2F,  %0'111'1'111,$3F 

;----------------------------------------------------------;
;                     Single enemies                       ;
;----------------------------------------------------------;
spriteEx01
    ;    SETUP MOVE_DELAY MOVE_DELAY_CNT MOVE_PX RESPAWN_DELAY         RESPAWN_DELAY_CNT RESPAWN_Y MOVE_PAT_ADDR      MOVE_PAT_POS                 MOVE_PAT_STEP MOVE_PAT_STEP_RCNT
    ENP {0,    0,         0,             0,      enp.RESPAWN_OFF_D255, 0,                0,        movePattern01D0,   enp.MOVE_PAT_STEP_OFFSET_D1/, 0,           0}
spriteEx02
    ENP {0,    0,         0,             0,      enp.RESPAWN_OFF_D255, 0,                0,        movePattern01D0,   enp.MOVE_PAT_STEP_OFFSET_D1,  0,           0}
spriteEx03
    ENP {0,    0,         0,             0,      enp.RESPAWN_OFF_D255, 0,                0,        movePattern01D0,   enp.MOVE_PAT_STEP_OFFSET_D1,  0,           0}
spriteEx04
    ENP {0,    0,         0,             0,      enp.RESPAWN_OFF_D255, 0,                0,        movePattern01D0,   enp.MOVE_PAT_STEP_OFFSET_D1,  0,           0}
spriteEx05
    ENP {0,    0,         0,             0,      enp.RESPAWN_OFF_D255, 0,                0,        movePattern01D0,   enp.MOVE_PAT_STEP_OFFSET_D1,  0,           0}
spriteEx06
    ENP {0,    0,         0,             0,      enp.RESPAWN_OFF_D255, 0,                0,        movePattern01D0,   enp.MOVE_PAT_STEP_OFFSET_D1,  0,           0}
spriteEx07
    ENP {0,    0,         0,             0,      enp.RESPAWN_OFF_D255, 0,                0,        movePattern01D0,   enp.MOVE_PAT_STEP_OFFSET_D1,  0,           0}
spriteEx08
    ENP {0,    0,         0,             0,      enp.RESPAWN_OFF_D255, 0,                0,        movePattern01D0,   enp.MOVE_PAT_STEP_OFFSET_D1,  0,           0}
spriteEx09
    ENP {0,    0,         0,             0,      enp.RESPAWN_OFF_D255, 0,                0,        movePattern01D0,   enp.MOVE_PAT_STEP_OFFSET_D1,  0,           0} 
spriteEx10
    ENP {0,    0,         0,             0,      enp.RESPAWN_OFF_D255, 0,                0,        movePattern01D0,   enp.MOVE_PAT_STEP_OFFSET_D1,  0,           0}
spriteEx11
    ENP {0,    0,         0,             0,      enp.RESPAWN_OFF_D255, 0,                0,        movePattern01D0,   enp.MOVE_PAT_STEP_OFFSET_D1,  0,           0}
spriteEx12
    ENP {0,    0,         0,             0,      enp.RESPAWN_OFF_D255, 0,                0,        movePattern01D0,   enp.MOVE_PAT_STEP_OFFSET_D1,  0,           0}
spriteEx13
    ENP {0,    0,         0,             0,      enp.RESPAWN_OFF_D255, 0,                0,        movePattern01D0,   enp.MOVE_PAT_STEP_OFFSET_D1,  0,           0}
spriteEx14
    ENP {0,    0,         0,             0,      enp.RESPAWN_OFF_D255, 0,                0,        movePattern01D0,   enp.MOVE_PAT_STEP_OFFSET_D1,  0,           0}
spriteEx15
    ENP {0,    0,         0,             0,      enp.RESPAWN_OFF_D255, 0,                0,        movePattern01D0,   enp.MOVE_PAT_STEP_OFFSET_D1,  0,           0}
spriteEx16
    ENP {0,    0,         0,             0,      enp.RESPAWN_OFF_D255, 0,                0,        movePattern01D0,   enp.MOVE_PAT_STEP_OFFSET_D1,  0,           0}
spriteEx17
    ENP {0,    0,         0,             0,      enp.RESPAWN_OFF_D255, 0,                0,        movePattern01D0,   enp.MOVE_PAT_STEP_OFFSET_D1,  0,           0}
spriteEx18
    ENP {0,    0,         0,             0,      enp.RESPAWN_OFF_D255, 0,                0,        movePattern01D0,   enp.MOVE_PAT_STEP_OFFSET_D1,  0,           0}
spriteEx19
    ENP {0,    0,         0,             0,      enp.RESPAWN_OFF_D255, 0,                0,        movePattern01D0,   enp.MOVE_PAT_STEP_OFFSET_D1,  0,           0}
spriteEx20
    ENP {0,    0,         0,             0,      enp.RESPAWN_OFF_D255, 0,                0,        movePattern01D0,   enp.MOVE_PAT_STEP_OFFSET_D1,  0,           0}

; Enemies reserved for enemyFormation.
   ;    SETUP  MOVE_DELAY MOVE_DELAY_CNT MOVE_PX RESPAWN_DELAY         RESPAWN_DELAY_CNT RESPAWN_Y MOVE_PAT_ADDR     MOVE_PAT_POS                 MOVE_PAT_STEP MOVE_PAT_STEP_RCNT
spriteExEf01
    ENP {0,    0,         0,             0,      enp.RESPAWN_OFF_D255, 0,                0,        movePattern07,   enp.MOVE_PAT_STEP_OFFSET_D1,  0,           0}
spriteExEf02
    ENP {0,    0,         0,             0,      enp.RESPAWN_OFF_D255, 0,                0,        movePattern07,   enp.MOVE_PAT_STEP_OFFSET_D1,  0,           0}
spriteExEf03
    ENP {0,    0,         0,             0,      enp.RESPAWN_OFF_D255, 0,                0,        movePattern07,   enp.MOVE_PAT_STEP_OFFSET_D1,  0,           0}
spriteExEf04
    ENP {0,    0,         0,             0,      enp.RESPAWN_OFF_D255, 0,                0,        movePattern07,   enp.MOVE_PAT_STEP_OFFSET_D1,  0,           0}
spriteExEf05
    ENP {0,    0,         0,             0,      enp.RESPAWN_OFF_D255, 0,                0,        movePattern07,   enp.MOVE_PAT_STEP_OFFSET_D1,  0,           0}
spriteExEf06
    ENP {0,    0,         0,             0,      enp.RESPAWN_OFF_D255, 0,                0,        movePattern07,   enp.MOVE_PAT_STEP_OFFSET_D1,  0,           0}
spriteExEf07
    ENP {0,    0,         0,             0,      enp.RESPAWN_OFF_D255, 0,                0,        movePattern07,   enp.MOVE_PAT_STEP_OFFSET_D1,  0,           0}

/*SDB_POINTER*/

; Single sprites, used by single enemies (#spriteExXX).
singleEnemySprites
    ;    ID  SDB_POINTER.  SDB_POINTER X  Y  STATE NEXT REMAINING  EXT_DATA_POINTER
    SPR {20, sr.SDB_ENEMY1 0,          0, 0, 0,    0,   0,         spriteEx01}
    SPR {21, sr.SDB_ENEMY1 0,          0, 0, 0,    0,   0,         spriteEx02}
    SPR {22, sr.SDB_ENEMY1 0,          0, 0, 0,    0,   0,         spriteEx03}
    SPR {23, sr.SDB_ENEMY1 0,          0, 0, 0,    0,   0,         spriteEx04}
    SPR {24, sr.SDB_ENEMY1 0,          0, 0, 0,    0,   0,         spriteEx05}
    SPR {25, sr.SDB_ENEMY1 0,          0, 0, 0,    0,   0,         spriteEx06}
    SPR {26, sr.SDB_ENEMY1 0,          0, 0, 0,    0,   0,         spriteEx07}
    SPR {27, sr.SDB_ENEMY1 0,          0, 0, 0,    0,   0,         spriteEx08}
    SPR {28, sr.SDB_ENEMY1 0,          0, 0, 0,    0,   0,         spriteEx09}
    SPR {29, sr.SDB_ENEMY1 0,          0, 0, 0,    0,   0,         spriteEx10}
    SPR {30, sr.SDB_ENEMY1 0,          0, 0, 0,    0,   0,         spriteEx11}
    SPR {31, sr.SDB_ENEMY1 0,          0, 0, 0,    0,   0,         spriteEx12}
    SPR {32, sr.SDB_ENEMY1 0,          0, 0, 0,    0,   0,         spriteEx13}
    SPR {33, sr.SDB_ENEMY1 0,          0, 0, 0,    0,   0,         spriteEx14}
    SPR {34, sr.SDB_ENEMY1 0,          0, 0, 0,    0,   0,         spriteEx15}
    SPR {35, sr.SDB_ENEMY1 0,          0, 0, 0,    0,   0,         spriteEx16}
    SPR {36, sr.SDB_ENEMY1 0,          0, 0, 0,    0,   0,         spriteEx17}
    SPR {37, sr.SDB_ENEMY1 0,          0, 0, 0,    0,   0,         spriteEx18}
    SPR {38, sr.SDB_ENEMY1 0,          0, 0, 0,    0,   0,         spriteEx19}
    SPR {39, sr.SDB_ENEMY1 0,          0, 0, 0,    0,   0,         spriteEx20}
ENEMY_SINGLE_SIZE       = 20

; Formation sprites used by enemyFormation enemies (#spriteExEfXX).
formationEnemySprites
    ;    ID  SDB_INIT       SDB_POINTER X  Y  STATE NEXT REMAINING  EXT_DATA_POINTER
    SPR {61, sr.SDB_ENEMY3, 0,          0, 0, 0,    0,   0,         spriteExEf01}
    SPR {62, sr.SDB_ENEMY3, 0,          0, 0, 0,    0,   0,         spriteExEf02}
    SPR {63, sr.SDB_ENEMY3, 0,          0, 0, 0,    0,   0,         spriteExEf03}
    SPR {64, sr.SDB_ENEMY3, 0,          0, 0, 0,    0,   0,         spriteExEf04}
    SPR {65, sr.SDB_ENEMY3, 0,          0, 0, 0,    0,   0,         spriteExEf05}
    SPR {66, sr.SDB_ENEMY3, 0,          0, 0, 0,    0,   0,         spriteExEf06}
    SPR {67, sr.SDB_ENEMY3, 0,          0, 0, 0,    0,   0,         spriteExEf07}
ENEMY_FORMATION_SIZE    = 7

;----------------------------------------------------------;
;                         Enemies                          ;
;----------------------------------------------------------;

singleEnemiesL1
    ;     RESPAWN_Y   RESPAWN_DELAY MOVE_PAT_ADDR      SDB_INIT      SETUP
    ENPS {020,        025,          movePattern01D3,   sr.SDB_ENEMY1 enp.ENP_LEFT_HIT  }
    ENPS {040,        025,          movePattern01D2,   sr.SDB_ENEMY1 enp.ENP_RIGHT_HIT }
    ENPS {050,        050,          movePattern01D2,   sr.SDB_ENEMY1 enp.ENP_LEFT_HIT  }
    ENPS {085,        045,          movePattern01D2,   sr.SDB_ENEMY1 enp.ENP_LEFT_HIT  }
    ENPS {090,        080,          movePattern01D3,   sr.SDB_ENEMY1 enp.ENP_RIGHT_HIT }
    ENPS {105,        020,          movePattern01D2,   sr.SDB_ENEMY1 enp.ENP_LEFT_HIT  }
    ENPS {125,        025,          movePattern01D2,   sr.SDB_ENEMY1 enp.ENP_RIGHT_HIT }
    ENPS {150,        074,          movePattern01D3,   sr.SDB_ENEMY1 enp.ENP_RIGHT_HIT }
    ENPS {175,        010,          movePattern01D2,   sr.SDB_ENEMY1 enp.ENP_LEFT_HIT  }
    ENPS {220,        025,          movePattern01D2,   sr.SDB_ENEMY1 enp.ENP_LEFT_HIT  }
SINGLE_ENEMIES_L1       = 10


singleEnemiesL2
    ;     RESPAWN_Y   RESPAWN_DELAY MOVE_PAT_ADDR      SDB_INIT      SETUP
    ENPS {020,        010,          movePattern01D3,   sr.SDB_ENEMY1 enp.ENP_LEFT_ALONG    }
    ENPS {020,        010,          movePattern01D2,   sr.SDB_ENEMY1 enp.ENP_RIGHT_HIT     }
    ENPS {040,        015,          movePattern01D2,   sr.SDB_ENEMY1 enp.ENP_RIGHT_ALONG   }
    ENPS {080,        015,          movePattern02D2,   sr.SDB_ENEMY1 enp.ENP_LEFT_HIT      }
    ENPS {100,        010,          movePattern02D1,   sr.SDB_ENEMY3 enp.ENP_LEFT_BOUNCE   }
    ENPS {120,        005,          movePattern02D2,   sr.SDB_ENEMY1 enp.ENP_RIGHT_ALONG   }
    ENPS {140,        024,          movePattern02D2,   sr.SDB_ENEMY1 enp.ENP_LEFT_HIT      }
    ENPS {180,        022,          movePattern01D3,   sr.SDB_ENEMY1 enp.ENP_RIGHT_ALONG   }
    ENPS {200,        025,          movePattern16,     sr.SDB_ENEMY2 enp.ENP_RIGHT_ALONG   }
    ENPS {220,        022,          movePattern01D2,   sr.SDB_ENEMY1 enp.ENP_LEFT_ALONG    }
    ENPS {220,        020,          movePattern01D2,   sr.SDB_ENEMY1 enp.ENP_RIGHT_ALONG   }
SINGLE_ENEMIES_L2       = 11
enemyFormationL2 ENPS {0/*RESPAWN_Y*/, enp.RESPAWN_OFF_D255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_LEFT_HIT/*SETUP*/}



singleEnemiesL3
    ;     RESPAWN_Y   RESPAWN_DELAY MOVE_PAT_ADDR      SDB_INIT      SETUP
    ENPS {150,        1,            movePattern07,   sr.SDB_ENEMY1 enp.ENP_LEFT_HIT  }
    ENPS {040,        025,          movePattern01D2,   sr.SDB_ENEMY1 enp.ENP_RIGHT_HIT }
    ENPS {050,        050,          movePattern01D2,   sr.SDB_ENEMY1 enp.ENP_LEFT_HIT  }
    ENPS {085,        045,          movePattern01D2,   sr.SDB_ENEMY1 enp.ENP_LEFT_HIT  }
    ENPS {090,        080,          movePattern01D3,   sr.SDB_ENEMY1 enp.ENP_RIGHT_HIT }
    ENPS {105,        020,          movePattern01D2,   sr.SDB_ENEMY1 enp.ENP_LEFT_HIT  }
    ENPS {125,        025,          movePattern01D2,   sr.SDB_ENEMY1 enp.ENP_RIGHT_HIT }
    ENPS {150,        074,          movePattern01D3,   sr.SDB_ENEMY1 enp.ENP_RIGHT_HIT }
    ENPS {175,        010,          movePattern01D2,   sr.SDB_ENEMY1 enp.ENP_LEFT_HIT  }
    ENPS {220,        025,          movePattern01D2,   sr.SDB_ENEMY1 enp.ENP_LEFT_HIT  }
SINGLE_ENEMIES_L3       = 1

singleEnemiesL3_
    ;     RESPAWN_Y   RESPAWN_DELAY MOVE_PAT_ADDR      SDB_INIT      SETUP
    ENPS {010,        025,          movePattern01D3,   sr.SDB_ENEMY1 enp.ENP_LEFT_ALONG}
    ENPS {020,        025,          movePattern01D2,   sr.SDB_ENEMY1 enp.ENP_RIGHT_HIT }
    ENPS {050,        015,          movePattern02D1,   sr.SDB_ENEMY1 enp.ENP_LEFT_HIT  }
    ENPS {040,        015,          movePattern02D2,   sr.SDB_ENEMY1 enp.ENP_RIGHT_HIT }
    ENPS {060,        025,          movePattern02D1,   sr.SDB_ENEMY1 enp.ENP_LEFT_HIT  }
    ENPS {060,        025,          movePattern02D2,   sr.SDB_ENEMY1 enp.ENP_RIGHT_HIT }
    ENPS {080,        021,          movePattern02D3,   sr.SDB_ENEMY2 enp.ENP_LEFT_HIT  }
    ENPS {080,        021,          movePattern02D2,   sr.SDB_ENEMY2 enp.ENP_RIGHT_HIT }
    ENPS {100,        028,          movePattern02D3,   sr.SDB_ENEMY2 enp.ENP_LEFT_HIT  }
    ENPS {100,        028,          movePattern02D2,   sr.SDB_ENEMY2 enp.ENP_RIGHT_HIT }
    ENPS {120,        027,          movePattern02D1,   sr.SDB_ENEMY2 enp.ENP_LEFT_HIT  }
    ENPS {120,        028,          movePattern02D3,   sr.SDB_ENEMY2 enp.ENP_RIGHT_HIT }
    ENPS {140,        023,          movePattern02D2,   sr.SDB_ENEMY2 enp.ENP_LEFT_HIT  }
    ENPS {140,        023,          movePattern02D1,   sr.SDB_ENEMY2 enp.ENP_RIGHT_HIT }
    ENPS {160,        038,          movePattern02D2,   sr.SDB_ENEMY1 enp.ENP_LEFT_HIT  }
    ENPS {160,        037,          movePattern02D2,   sr.SDB_ENEMY1 enp.ENP_RIGHT_HIT }
    ENPS {180,        035,          movePattern02D1,   sr.SDB_ENEMY1 enp.ENP_LEFT_HIT  }
    ENPS {180,        025,          movePattern02D2,   sr.SDB_ENEMY1 enp.ENP_RIGHT_HIT }
    ENPS {200,        028,          movePattern02D3,   sr.SDB_ENEMY1 enp.ENP_LEFT_HIT  }
    ENPS {200,        044,          movePattern02D3,   sr.SDB_ENEMY1 enp.ENP_RIGHT_HIT }
SINGLE_ENEMIES_L3_       = 20
enemyFormationL3_ ENPS {130/*RESPAWN_Y*/, 5/*RESPAWN_DELAY*/, movePattern07/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY3/*SDB_INIT*/, enp.ENP_LEFT_ALONG/*SETUP*/}
enemyFormationL3 ENPS {130/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern07/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY3/*SDB_INIT*/, enp.ENP_LEFT_ALONG/*SETUP*/}

singleEnemiesL4
    ;     RESPAWN_Y   RESPAWN_DELAY MOVE_PAT_ADDR      SDB_INIT      SETUP
    ENPS {010,        025,          movePattern02D3,   sr.SDB_ENEMY1 enp.ENP_LEFT_ALONG  }
    ENPS {010,        030,          movePattern02D2,   sr.SDB_ENEMY1 enp.ENP_RIGHT_ALONG }
    ENPS {020,        029,          movePattern13D1,   sr.SDB_ENEMY3 enp.ENP_LEFT_ALONG  }
    ENPS {010,        025,          movePattern13D3,   sr.SDB_ENEMY2 enp.ENP_RIGHT_ALONG }
    ENPS {010,        027,          movePattern18,     sr.SDB_ENEMY1 enp.ENP_LEFT_ALONG  }
    ENPS {010,        032,          movePattern18,     sr.SDB_ENEMY1 enp.ENP_RIGHT_ALONG }

    ENPS {127,        018,          movePattern01D2,   sr.SDB_ENEMY3 enp.ENP_LEFT_HIT    }
    ENPS {127,        015,          movePattern01D3,   sr.SDB_ENEMY3 enp.ENP_RIGHT_HIT   }
    ENPS {165,        025,          movePattern01D1,   sr.SDB_ENEMY2 enp.ENP_LEFT_HIT    }
    ENPS {165,        020,          movePattern01D1,   sr.SDB_ENEMY2 enp.ENP_RIGHT_HIT   }

    ENPS {103,        010,          movePattern01D0,   sr.SDB_ENEMY1 enp.ENP_LEFT_HIT    }
    ENPS {144,        012,          movePattern01D0,   sr.SDB_ENEMY1 enp.ENP_RIGHT_HIT   }
    ENPS {144,        018,          movePattern01D0,   sr.SDB_ENEMY1 enp.ENP_LEFT_HIT    }
    ENPS {185,        015,          movePattern01D0,   sr.SDB_ENEMY1 enp.ENP_RIGHT_HIT   }
    ENPS {185,        009,          movePattern01D0,   sr.SDB_ENEMY1 enp.ENP_LEFT_HIT    }
    
    ENPS {227,        020,          movePattern09  ,   sr.SDB_ENEMY3 enp.ENP_RIGHT_ALONG }
    ENPS {227,        040,          movePattern09  ,   sr.SDB_ENEMY3 enp.ENP_LEFT_HIT    }

SINGLE_ENEMIES_L4       = 17
enemyFormationL4 ENPS {085/*RESPAWN_Y*/, 8/*RESPAWN_DELAY*/, movePattern17/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY2/*SDB_INIT*/, enp.ENP_LEFT_ALONG/*SETUP*/}

singleEnemiesL5
    ;     RESPAWN_Y   RESPAWN_DELAY MOVE_PAT_ADDR      SDB_INIT      SETUP
    ENPS {020,        010,          movePattern20,   sr.SDB_ENEMY1   enp.ENP_LEFT_BOUNCE_AN  }
    ENPS {030,        040,          movePattern20,   sr.SDB_ENEMY1   enp.ENP_RIGHT_BOUNCE_AN }
    ENPS {060,        020,          movePattern20,   sr.SDB_ENEMY1   enp.ENP_LEFT_BOUNCE_AN  }
    ENPS {070,        023,          movePattern20,   sr.SDB_ENEMY1   enp.ENP_RIGHT_BOUNCE_AN }
    ENPS {080,        020,          movePattern20,   sr.SDB_ENEMY1   enp.ENP_LEFT_BOUNCE_AN  }
    ENPS {100,        015,          movePattern20,   sr.SDB_ENEMY1   enp.ENP_LEFT_BOUNCE_AN  }
    ENPS {120,        020,          movePattern20,   sr.SDB_ENEMY1   enp.ENP_LEFT_BOUNCE_AN  }
    ENPS {130,        040,          movePattern20,   sr.SDB_ENEMY1   enp.ENP_LEFT_BOUNCE_AN  }
    ENPS {150,        027,          movePattern20,   sr.SDB_ENEMY1   enp.ENP_RIGHT_BOUNCE_AN }
    ENPS {140,        013,          movePattern20,   sr.SDB_ENEMY1   enp.ENP_LEFT_BOUNCE_AN  }
    ENPS {180,        027,          movePattern20,   sr.SDB_ENEMY1   enp.ENP_LEFT_BOUNCE_AN  }
    ENPS {190,        020,          movePattern20,   sr.SDB_ENEMY1   enp.ENP_RIGHT_BOUNCE_AN }
    ENPS {200,        030,          movePattern20,   sr.SDB_ENEMY1   enp.ENP_LEFT_BOUNCE_AN  }
    ENPS {220,        012,          movePattern20,   sr.SDB_ENEMY1   enp.ENP_LEFT_BOUNCE_AN  }
    ENPS {120,        020,          movePattern20,   sr.SDB_ENEMY1   enp.ENP_LEFT_BOUNCE_AN  }
    ENPS {220,        010,          movePattern20,   sr.SDB_ENEMY1   enp.ENP_RIGHT_BOUNCE_AN }
SINGLE_ENEMIES_L5       = 15

singleEnemiesL6
    ;     RESPAWN_Y   RESPAWN_DELAY MOVE_PAT_ADDR      SDB_INIT      SETUP
    ENPS {020,        040,          movePattern02D0,   sr.SDB_ENEMY1 enp.ENP_LEFT_BOUNCE_AN }
    ENPS {070,        014,          movePattern02D2,   sr.SDB_ENEMY1 enp.ENP_LEFT_BOUNCE_AN }
    ENPS {150,        010,          movePattern02D1,   sr.SDB_ENEMY1 enp.ENP_LEFT_BOUNCE_AN }
    ENPS {224,        010,          movePattern15D2,   sr.SDB_ENEMY1 enp.ENP_LEFT_BOUNCE_AN }

    ENPS {020,        010,          movePattern02D2,   sr.SDB_ENEMY1 enp.ENP_RIGHT_BOUNCE_AN }
    ENPS {120,        002,          movePattern01D3,   sr.SDB_ENEMY1 enp.ENP_RIGHT_BOUNCE_AN }
    ENPS {224,        010,          movePattern15D2,   sr.SDB_ENEMY1 enp.ENP_RIGHT_BOUNCE_AN }
SINGLE_ENEMIES_L6       = 6

singleEnemiesL7
    ;     RESPAWN_Y   RESPAWN_DELAY MOVE_PAT_ADDR      SDB_INIT      SETUP
    ENPS {100,        015,          movePattern08,   sr.SDB_ENEMY1   enp.ENP_LEFT_BOUNCE_AN  }
    ENPS {100,        015,          movePattern08,   sr.SDB_ENEMY1   enp.ENP_RIGHT_BOUNCE_AN }
    ENPS {150,        013,          movePattern08,   sr.SDB_ENEMY1   enp.ENP_LEFT_BOUNCE_AN  }
    ENPS {150,        013,          movePattern08,   sr.SDB_ENEMY1   enp.ENP_RIGHT_BOUNCE_AN }
    ENPS {220,        010,          movePattern08,   sr.SDB_ENEMY1   enp.ENP_LEFT_BOUNCE_AN  }
    ENPS {220,        010,          movePattern08,   sr.SDB_ENEMY1   enp.ENP_RIGHT_BOUNCE_AN }

SINGLE_ENEMIES_L7       = 6 
enemyFormationL7 ENPS {20/*RESPAWN_Y*/, 3/*RESPAWN_DELAY*/, movePattern02D2/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_LEFT_BOUNCE_AN/*SETUP*/}

singleEnemiesL9
    ;     RESPAWN_Y   RESPAWN_DELAY MOVE_PAT_ADDR      SDB_INIT      SETUP
    ENPS {009,        255,          movePattern01D0,   sr.SDB_ENEMY1 enp.ENP_LEFT_HIT    }
    ENPS {009,        255,          movePattern01D0,   sr.SDB_ENEMY1 enp.ENP_LEFT_HIT    }
    ENPS {009,        255,          movePattern01D0,   sr.SDB_ENEMY1 enp.ENP_LEFT_HIT    }
    ENPS {009,        255,          movePattern01D0,   sr.SDB_ENEMY1 enp.ENP_LEFT_HIT    }
    ENPS {009,        255,          movePattern01D0,   sr.SDB_ENEMY1 enp.ENP_LEFT_HIT    }
    ENPS {009,        255,          movePattern01D0,   sr.SDB_ENEMY1 enp.ENP_LEFT_HIT    }
    ENPS {009,        255,          movePattern01D0,   sr.SDB_ENEMY1 enp.ENP_LEFT_HIT    }
    ENPS {009,        255,          movePattern01D0,   sr.SDB_ENEMY1 enp.ENP_LEFT_HIT    }
    ENPS {009,        255,          movePattern01D0,   sr.SDB_ENEMY1 enp.ENP_LEFT_HIT    }
    ENPS {009,        255,          movePattern01D0,   sr.SDB_ENEMY1 enp.ENP_LEFT_HIT    }
SINGLE_ENEMIES_L9       = 1 
enemyFormationL9 ENPS {0/*RESPAWN_Y*/, enp.RESPAWN_OFF_D255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_LEFT_HIT/*SETUP*/}

singleEnemiesL10
    ;     RESPAWN_Y   RESPAWN_DELAY MOVE_PAT_ADDR      SDB_INIT      SETUP
    ENPS {009,        255,          movePattern01D0,   sr.SDB_ENEMY1 enp.ENP_LEFT_HIT    }
    ENPS {009,        255,          movePattern01D0,   sr.SDB_ENEMY1 enp.ENP_LEFT_HIT    }
    ENPS {009,        255,          movePattern01D0,   sr.SDB_ENEMY1 enp.ENP_LEFT_HIT    }
    ENPS {009,        255,          movePattern01D0,   sr.SDB_ENEMY1 enp.ENP_LEFT_HIT    }
    ENPS {009,        255,          movePattern01D0,   sr.SDB_ENEMY1 enp.ENP_LEFT_HIT    }
    ENPS {009,        255,          movePattern01D0,   sr.SDB_ENEMY1 enp.ENP_LEFT_HIT    }
    ENPS {009,        255,          movePattern01D0,   sr.SDB_ENEMY1 enp.ENP_LEFT_HIT    }
    ENPS {009,        255,          movePattern01D0,   sr.SDB_ENEMY1 enp.ENP_LEFT_HIT    }
    ENPS {009,        255,          movePattern01D0,   sr.SDB_ENEMY1 enp.ENP_LEFT_HIT    }
    ENPS {009,        255,          movePattern01D0,   sr.SDB_ENEMY1 enp.ENP_LEFT_HIT    }
SINGLE_ENEMIES_L10      = 1 
enemyFormationL10 ENPS {0/*RESPAWN_Y*/, enp.RESPAWN_OFF_D255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_LEFT_HIT/*SETUP*/}

;----------------------------------------------------------;
;                      Fuel Thief                          ;
;----------------------------------------------------------;
fuelThiefEnp
    ENP {0/*SETUP*/, 0/*MOVE_DELAY*/, 0/*MOVE_DELAY_CNT*/, 0/*MOVE_PX*/, 0/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 233/*RESPAWN_Y*/, movePattern19/*MOVE_PAT_POINTER*/, enp.MOVE_PAT_STEP_OFFSET_D1/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}

fuelThiefSpr
    SPR {96/*ID*/, sr.SDB_FUEL_THIEF/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, fuelThiefEnp/*EXT_DATA_POINTER*/}

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE