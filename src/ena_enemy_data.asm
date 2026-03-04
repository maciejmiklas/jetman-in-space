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

; 34deg down, delay 1
movePattern13D1
    DB 2, %1'011'1'111,$10 

; 34deg down, delay 3
movePattern13D3
    DB 2, %1'011'1'111,$30 

; 45deg up, delay 2
movePattern15D2
    DB 2, %0'001'1'001,$20 

movePattern16
;         horizontal        45deg up
    DB 4, %0'000'1'111,$0C, %0'111'1'111,$19 

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

movePattern22
    DB 16*2 + 2 + 19*2
    ; Phase 1
    DB %1'111'1'101,$22, %1'111'1'111,$21, %1'011'1'110,$21, %0'110'1'111,$21, %0'111'1'100,$21, %0'111'1'011,$23, %0'111'1'100,$22 
    DB %0'100'1'111,$21, %0'000'1'111,$21, %1'110'1'111,$21, %1'111'1'100,$21, %1'111'1'110,$21, %1'101'1'111,$21, %1'011'1'111,$21 
    DB %0'000'1'111,$F1, %0'000'0'111,$F1 
    ; Phase 2
    DB %0'000'1'111,$04 
    ; Phase 3
    DB %0'000'1'111,$21, %1'101'1'111,$21, %1'111'1'101,$24, %1'101'1'111,$21, %1'001'1'111,$21, %0'001'1'101,$21, %1'100'1'111,$21 
    DB %1'101'1'111,$21, %1'011'1'111,$21, %0'011'1'111,$21, %0'111'1'100,$21, %0'111'1'001,$21, %0'111'1'010,$21, %0'111'1'101,$21 
    DB %0'111'1'100,$21, %0'111'1'101,$21, %0'101'1'111,$21, %0'000'1'111,$0F, %0'000'1'101,$2F 
    
movePattern23
    DB 18*2
    DB %1'100'1'111,$21, %1'111'1'110,$21, %1'111'1'100,$21, %1'111'1'111,$21, %1'110'1'111,$21, %1'011'1'111,$21, %1'010'1'110,$21 
    DB %0'011'1'111,$21, %0'111'1'111,$21, %0'111'1'101,$21, %0'111'1'110,$21, %0'111'1'111,$21, %0'110'1'111,$21, %0'010'1'111,$21 
    DB %1'011'1'111,$21, %1'100'1'111,$A1, %1'000'1'011,$A1, %0'000'1'101,$03

movePattern24
    DB 128, %0'000'1'111,$2B, %1'010'1'111,$21, %1'011'1'111,$21, %1'111'1'111,$21, %1'111'1'001,$21, %1'111'0'101,$21, %1'100'0'111,$21 
    DB %1'011'0'111,$21, %1'001'0'111,$23, %1'010'0'111,$21, %1'110'0'111,$21, %1'111'0'011,$21, %1'111'1'100,$21, %1'010'1'111,$22  
    DB %0'000'1'111,$21, %1'011'1'111,$21, %1'111'1'111,$21, %1'111'1'100,$21, %1'111'1'011,$21, %1'111'1'101,$21, %1'111'1'111,$21 
    DB %1'011'1'111,$21, %0'010'1'111,$22, %0'001'1'111,$22, %0'001'1'101,$21, %1'110'1'110,$21, %1'111'0'011,$21, %1'111'0'101,$21  
    DB %1'111'0'001,$21, %1'111'1'011,$21, %1'111'1'111,$21, %1'110'1'111,$21, %1'100'1'111,$21, %1'011'1'111,$21, %1'100'1'111,$21  
    DB %1'001'1'111,$22, %0'000'1'111,$2D, %0'011'1'111,$21, %0'111'1'111,$21, %0'111'1'001,$21, %0'101'1'001,$21, %0'111'0'110,$21  
    DB %0'100'0'111,$22, %0'101'0'010,$21, %0'111'1'111,$21, %0'111'1'110,$22, %0'111'0'010,$21, %0'100'0'111,$21, %0'001'0'111,$21  
    DB %0'000'0'111,$22, %0'001'0'111,$21, %0'000'0'111,$21, %0'011'0'111,$22, %0'101'0'111,$21, %0'110'0'111,$21, %0'111'0'101,$21  
    DB %0'111'0'100,$22, %0'111'0'011,$21, %0'111'0'001,$22, %0'111'0'000,$21, %0'111'1'010,$21, %0'111'1'111,$21, %0'000'1'111,$2F 
    DB %0'000'1'001,$21 

movePattern25
    DB 146, %0'000'1'111,$2F, %0'000'1'111,$21, %0'010'1'111,$22, %0'111'1'111,$21, %0'111'1'100,$21, %0'111'1'010,$23, %0'111'1'011,$21 
    DB %0'111'1'001,$22, %0'111'1'011,$21, %0'111'1'100,$21, %0'101'1'111,$21, %0'001'1'110,$21, %1'111'1'101,$21, %1'111'1'011,$21 
    DB %1'110'1'111,$21, %1'010'1'111,$21, %1'001'1'111,$21, %0'000'1'111,$23, %1'001'1'111,$21, %0'000'1'111,$24, %0'001'1'111,$21 
    DB %0'000'1'111,$21, %1'001'1'111,$21, %1'101'1'111,$21, %1'111'1'001,$21, %1'111'0'001,$21, %1'111'0'010,$22, %1'111'0'011,$21 
    DB %1'111'0'100,$21, %1'110'0'111,$21, %1'011'0'111,$21, %0'000'0'111,$2F, %0'000'0'111,$21, %1'001'0'111,$21, %0'000'0'111,$2F 
    DB %0'101'0'111,$21, %0'111'0'110,$21, %0'111'0'100,$21, %0'111'0'010,$21, %0'111'0'001,$23, %0'111'1'001,$21, %0'111'1'011,$21 
    DB %0'111'1'111,$21, %0'111'0'001,$22, %0'111'0'011,$21, %0'111'1'001,$21, %0'111'1'101,$21, %0'100'1'111,$21, %1'100'1'111,$21 
    DB %1'111'1'100,$21, %1'111'1'011,$23, %1'111'1'111,$21, %1'010'1'101,$21, %0'111'1'111,$21, %0'011'1'111,$21, %1'001'1'111,$21 
    DB %1'111'1'100,$21, %1'111'1'011,$21, %1'100'1'110,$21, %0'100'1'111,$21, %0'000'1'111,$21, %1'001'1'111,$21, %1'010'1'111,$21 
    DB %1'111'1'110,$21, %1'111'1'011,$22, %1'111'1'101,$21, %1'111'1'100,$22, %1'111'1'110,$21, %1'111'1'111,$21, %0'000'1'111,$2B 
    DB %1'001'1'111,$21, %0'000'1'111,$2A, %0'000'1'101,$21 

movePattern26
   DB 86, %0'000'1'111,$26, %1'001'1'111,$21, %1'100'1'111,$21, %1'101'1'111,$21, %1'111'1'001,$21, %1'111'0'000,$25, %1'110'0'111,$21 
   DB %1'011'0'111,$22, %1'100'0'111,$21, %1'011'0'111,$21, %1'111'0'101,$21, %1'111'0'000,$28, %1'111'1'111,$21, %1'010'1'111,$21 
   DB %1'011'1'111,$22, %1'010'1'111,$21, %1'111'1'100,$21, %1'111'0'000,$26, %1'111'0'111,$21, %1'110'0'111,$21, %1'100'0'101,$21 
   DB %0'110'0'111,$21, %0'101'0'111,$21, %0'111'0'110,$21, %0'111'0'000,$26, %0'111'1'111,$21, %0'010'1'111,$21, %0'011'1'111,$22 
   db %0'010'1'111,$21, %0'111'1'100,$21, %0'111'0'000,$28, %0'111'0'111,$21, %0'011'0'111,$22, %0'010'0'111,$21, %0'011'0'111,$21 
   DB %0'111'0'100,$21, %0'111'0'000,$26, %0'100'1'111,$21, %0'010'1'111,$21, %0'011'1'111,$21, %0'001'1'011,$21, %0'000'0'111,$2
   DB %0'000'0'110,$21 

movePattern27
    DB 50, %0'000'1'111,$24, %1'001'1'111,$21, %1'100'1'111,$21, %1'111'1'111,$21, %1'111'1'000,$2D, %1'110'0'111,$21, %1'010'0'111,$23 
    DB %1'111'0'100,$21, %1'111'1'000,$25, %1'111'0'001,$21, %1'111'1'000,$26, %1'111'1'011,$21, %1'101'1'111,$21, %1'101'1'110,$21 
    DB %0'101'1'111,$22, %0'111'1'110,$21, %0'111'1'000,$2C, %0'111'0'110,$21, %0'010'0'111,$23, %0'001'0'111,$21, %0'111'0'010,$21 
    DB %0'111'1'000,$2D, %0'101'0'111,$21, %0'100'0'111,$21, %0'001'0'010,$21

; horizontal right, Saw wave
movePattern28
;          horizontal.        45deg up          45deg up           45deg down        45deg down      45deg down
    DB 12, %0'000'1'111,$21, %0'001'1'011,$2F, %0'001'1'011,$2F, %1'001'1'011,$2F, %1'001'1'011,$2F, %1'001'1'011,$2F 

movePattern29
    DB 44, %0'000'1'111,$2A, %1'110'1'111,$21, %1'111'1'110,$22, %1'111'1'101,$21, %1'011'1'011,$21, %0'111'1'110,$24, %0'111'1'101,$21 
    DB %0'011'1'011,$21, %1'111'1'010,$21, %1'111'1'011,$21, %1'111'1'010,$22, %1'111'1'011,$21, %1'111'1'010,$22, %1'111'1'011,$21 
    DB %1'111'1'010,$22, %1'111'1'011,$21, %1'100'1'001,$21, %0'111'1'110,$21, %0'111'1'101,$21, %0'111'1'110,$22, %0'111'1'101,$21 
    DB %0'010'1'010,$21

movePattern30
    DB 10, %0'111'0'110,$21, %0'001'0'101,$21, %1'111'0'111,$21, %0'101'0'111,$21, %0'010'0'011,$21 

movePattern31
    DB 172, %0'000'1'111,$29, %1'101'1'111,$21, %1'111'1'101,$21, %1'111'1'110,$21, %1'111'1'101,$22, %1'111'1'110,$21, %1'111'1'101,$22 
    DB %1'111'1'100,$21, %1'111'1'011,$21, %1'111'1'010,$21, %1'111'1'001,$21, %1'111'0'001,$21, %1'111'0'010,$21, %1'111'0'001,$21 
    DB %1'111'0'010,$21, %1'111'0'001,$22, %1'111'1'001,$21, %1'111'1'010,$21, %1'111'1'101,$21, %1'110'1'111,$21, %1'100'1'111,$21 
    DB %1'011'1'111,$21, %1'001'1'111,$21, %0'000'1'111,$21, %1'001'1'111,$21, %0'001'1'111,$22, %0'010'1'111,$22, %0'011'1'111,$21 
    DB %0'111'1'100,$22, %0'111'1'010,$21, %0'111'1'001,$21, %0'111'0'000,$21, %0'110'1'001,$21, %0'111'0'010,$22, %0'111'0'101,$21 
    DB %0'110'0'111,$21, %0'011'0'111,$21, %0'001'0'111,$21, %0'010'0'111,$21, %0'001'0'111,$21, %1'001'0'111,$22, %1'010'0'111,$21 
    DB %1'011'0'111,$21, %1'111'0'110,$21, %1'111'0'101,$21, %1'111'0'011,$21, %1'111'0'010,$21, %1'111'0'011,$21, %1'101'0'001,$21 
    DB %1'111'1'011,$21, %1'111'1'010,$21, %1'111'1'011,$21, %1'101'1'111,$21, %1'100'1'111,$22, %1'001'1'111,$21, %0'001'1'111,$24 
    DB %0'010'1'111,$21, %0'011'1'111,$21, %0'111'1'110,$21, %0'111'1'100,$21, %0'111'1'011,$21, %0'110'1'011,$21, %0'111'0'011,$21 
    DB %0'111'0'010,$22, %0'110'0'111,$21, %0'111'0'111,$21, %0'101'0'111,$21, %0'010'0'111,$21, %0'001'0'111,$21, %0'011'0'111,$21 
    DB %0'111'0'110,$21, %0'111'0'100,$21, %0'111'0'000,$22, %0'111'1'111,$21, %0'101'1'111,$21, %0'010'1'111,$21, %0'011'1'111,$21 
    DB %0'010'1'111,$21, %0'011'1'111,$22, %0'111'1'111,$21, %0'111'1'100,$21, %0'110'1'111,$21, %0'010'1'111,$21, %0'001'1'111,$22 
    DB %0'000'1'111,$2B, %0'000'1'100,$21 

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
    SPR {20, sp.SDB_ENEMY1 0,          0, 0, 0,    0,   0,         spriteEx01}
    SPR {21, sp.SDB_ENEMY1 0,          0, 0, 0,    0,   0,         spriteEx02}
    SPR {22, sp.SDB_ENEMY1 0,          0, 0, 0,    0,   0,         spriteEx03}
    SPR {23, sp.SDB_ENEMY1 0,          0, 0, 0,    0,   0,         spriteEx04}
    SPR {24, sp.SDB_ENEMY1 0,          0, 0, 0,    0,   0,         spriteEx05}
    SPR {25, sp.SDB_ENEMY1 0,          0, 0, 0,    0,   0,         spriteEx06}
    SPR {26, sp.SDB_ENEMY1 0,          0, 0, 0,    0,   0,         spriteEx07}
    SPR {27, sp.SDB_ENEMY1 0,          0, 0, 0,    0,   0,         spriteEx08}
    SPR {28, sp.SDB_ENEMY1 0,          0, 0, 0,    0,   0,         spriteEx09}
    SPR {29, sp.SDB_ENEMY1 0,          0, 0, 0,    0,   0,         spriteEx10}
    SPR {30, sp.SDB_ENEMY1 0,          0, 0, 0,    0,   0,         spriteEx11}
    SPR {31, sp.SDB_ENEMY1 0,          0, 0, 0,    0,   0,         spriteEx12}
    SPR {32, sp.SDB_ENEMY1 0,          0, 0, 0,    0,   0,         spriteEx13}
    SPR {33, sp.SDB_ENEMY1 0,          0, 0, 0,    0,   0,         spriteEx14}
    SPR {34, sp.SDB_ENEMY1 0,          0, 0, 0,    0,   0,         spriteEx15}
    SPR {35, sp.SDB_ENEMY1 0,          0, 0, 0,    0,   0,         spriteEx16}
    SPR {36, sp.SDB_ENEMY1 0,          0, 0, 0,    0,   0,         spriteEx17}
    SPR {37, sp.SDB_ENEMY1 0,          0, 0, 0,    0,   0,         spriteEx18}
    SPR {38, sp.SDB_ENEMY1 0,          0, 0, 0,    0,   0,         spriteEx19}
    SPR {39, sp.SDB_ENEMY1 0,          0, 0, 0,    0,   0,         spriteEx20}
ENEMY_SINGLE_SIZE       = 20

; Formation sprites used by enemyFormation enemies (#spriteExEfXX).
formationEnemySprites
    ;    ID  SDB_INIT       SDB_POINTER X  Y  STATE NEXT REMAINING  EXT_DATA_POINTER
    SPR {61, sp.SDB_ENEMY3, 0,          0, 0, 0,    0,   0,         spriteExEf01}
    SPR {62, sp.SDB_ENEMY3, 0,          0, 0, 0,    0,   0,         spriteExEf02}
    SPR {63, sp.SDB_ENEMY3, 0,          0, 0, 0,    0,   0,         spriteExEf03}
    SPR {64, sp.SDB_ENEMY3, 0,          0, 0, 0,    0,   0,         spriteExEf04}
    SPR {65, sp.SDB_ENEMY3, 0,          0, 0, 0,    0,   0,         spriteExEf05}
    SPR {66, sp.SDB_ENEMY3, 0,          0, 0, 0,    0,   0,         spriteExEf06}
    SPR {67, sp.SDB_ENEMY3, 0,          0, 0, 0,    0,   0,         spriteExEf07}
ENEMY_FORMATION_SIZE_D7    = 7

;----------------------------------------------------------;
;                         Enemies                          ;
;----------------------------------------------------------;

singleEnemiesL1
    ;     RESPAWN_Y   RESPAWN_DELAY MOVE_PAT_ADDR      SDB_INIT      SETUP
    ENPS {020,        025,          movePattern01D3,   sp.SDB_ENEMY1 enp.ENP_LEFT_HIT  }
    ENPS {040,        025,          movePattern01D2,   sp.SDB_ENEMY1 enp.ENP_RIGHT_HIT }
    ENPS {050,        050,          movePattern01D2,   sp.SDB_ENEMY1 enp.ENP_LEFT_HIT  }
    ENPS {085,        045,          movePattern01D2,   sp.SDB_ENEMY1 enp.ENP_LEFT_HIT  }
    ENPS {090,        080,          movePattern01D3,   sp.SDB_ENEMY1 enp.ENP_RIGHT_HIT }
    ENPS {105,        020,          movePattern01D2,   sp.SDB_ENEMY1 enp.ENP_LEFT_HIT  }
    ENPS {125,        025,          movePattern01D2,   sp.SDB_ENEMY1 enp.ENP_RIGHT_HIT }
    ENPS {150,        074,          movePattern01D3,   sp.SDB_ENEMY1 enp.ENP_RIGHT_HIT }
    ENPS {175,        010,          movePattern01D2,   sp.SDB_ENEMY1 enp.ENP_LEFT_HIT  }
    ENPS {220,        025,          movePattern01D2,   sp.SDB_ENEMY1 enp.ENP_LEFT_HIT  }
SINGLE_ENEMIES_L1       = 10

; ##############################################
; Level 2
singleEnemiesL2
    ;     RESPAWN_Y   RESPAWN_DELAY MOVE_PAT_ADDR      SDB_INIT      SETUP
    ENPS {020,        010,          movePattern01D3,   sp.SDB_ENEMY1 enp.ENP_LEFT_ALONG    }
    ENPS {020,        010,          movePattern01D2,   sp.SDB_ENEMY1 enp.ENP_RIGHT_HIT     }
    ENPS {040,        015,          movePattern01D2,   sp.SDB_ENEMY1 enp.ENP_RIGHT_ALONG   }
    ENPS {080,        015,          movePattern02D2,   sp.SDB_ENEMY1 enp.ENP_LEFT_HIT      }
    ENPS {100,        010,          movePattern02D1,   sp.SDB_ENEMY3 enp.ENP_LEFT_BOUNCE   }
    ENPS {120,        005,          movePattern02D2,   sp.SDB_ENEMY1 enp.ENP_RIGHT_ALONG   }
    ENPS {140,        024,          movePattern02D2,   sp.SDB_ENEMY1 enp.ENP_LEFT_HIT      }
    ENPS {180,        022,          movePattern01D3,   sp.SDB_ENEMY1 enp.ENP_RIGHT_ALONG   }
    ENPS {200,        025,          movePattern16,     sp.SDB_ENEMY2 enp.ENP_RIGHT_ALONG   }
    ENPS {220,        022,          movePattern01D2,   sp.SDB_ENEMY1 enp.ENP_LEFT_ALONG    }
    ENPS {220,        020,          movePattern01D2,   sp.SDB_ENEMY1 enp.ENP_RIGHT_ALONG   }
SINGLE_ENEMIES_L2       = 11
enemyFormationL2 ENPS {0/*RESPAWN_Y*/, enp.RESPAWN_OFF_D255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sp.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_LEFT_HIT/*SETUP*/}

; ##############################################
; Level 3
singleEnemiesL3
    ;     RESPAWN_Y   RESPAWN_DELAY MOVE_PAT_ADDR      SDB_INIT      SETUP
    ENPS {010,        025,          movePattern01D3,   sp.SDB_ENEMY1 enp.ENP_LEFT_ALONG}
    ENPS {020,        025,          movePattern01D2,   sp.SDB_ENEMY1 enp.ENP_RIGHT_HIT }
    ENPS {050,        015,          movePattern02D1,   sp.SDB_ENEMY1 enp.ENP_LEFT_HIT  }
    ENPS {040,        015,          movePattern02D2,   sp.SDB_ENEMY1 enp.ENP_RIGHT_HIT }
    ENPS {060,        025,          movePattern02D1,   sp.SDB_ENEMY1 enp.ENP_LEFT_HIT  }
    ENPS {060,        025,          movePattern02D2,   sp.SDB_ENEMY1 enp.ENP_RIGHT_HIT }
    ENPS {080,        021,          movePattern02D3,   sp.SDB_ENEMY2 enp.ENP_LEFT_HIT  }
    ENPS {080,        021,          movePattern02D2,   sp.SDB_ENEMY2 enp.ENP_RIGHT_HIT }
    ENPS {100,        028,          movePattern02D3,   sp.SDB_ENEMY2 enp.ENP_LEFT_HIT  }
    ENPS {100,        028,          movePattern02D2,   sp.SDB_ENEMY2 enp.ENP_RIGHT_HIT }
    ENPS {120,        027,          movePattern02D1,   sp.SDB_ENEMY2 enp.ENP_LEFT_HIT  }
    ENPS {120,        028,          movePattern02D3,   sp.SDB_ENEMY2 enp.ENP_RIGHT_HIT }
    ENPS {140,        023,          movePattern02D2,   sp.SDB_ENEMY2 enp.ENP_LEFT_HIT  }
    ENPS {140,        023,          movePattern02D1,   sp.SDB_ENEMY2 enp.ENP_RIGHT_HIT }
    ENPS {160,        038,          movePattern02D2,   sp.SDB_ENEMY1 enp.ENP_LEFT_HIT  }
    ENPS {160,        037,          movePattern02D2,   sp.SDB_ENEMY1 enp.ENP_RIGHT_HIT }
    ENPS {180,        035,          movePattern02D1,   sp.SDB_ENEMY1 enp.ENP_LEFT_HIT  }
    ENPS {180,        025,          movePattern02D2,   sp.SDB_ENEMY1 enp.ENP_RIGHT_HIT }
    ENPS {200,        028,          movePattern02D3,   sp.SDB_ENEMY1 enp.ENP_LEFT_HIT  }
    ENPS {200,        044,          movePattern02D3,   sp.SDB_ENEMY1 enp.ENP_RIGHT_HIT }
SINGLE_ENEMIES_L3       = 20

enemyFormationL3 ENPS {130/*RESPAWN_Y*/, 5/*RESPAWN_DELAY*/, movePattern07/*MOVE_PAT_POINTER*/, sp.SDB_ENEMY3/*SDB_INIT*/, enp.ENP_LEFT_ALONG/*SETUP*/}

; ##############################################
; Level 4
singleEnemiesL4
    ;     RESPAWN_Y   RESPAWN_DELAY MOVE_PAT_ADDR      SDB_INIT      SETUP
    ENPS {010,        020,          movePattern02D3,   sp.SDB_ENEMY1 enp.ENP_LEFT_BOUNCE    }
    ENPS {010,        035,          movePattern02D2,   sp.SDB_ENEMY1 enp.ENP_RIGHT_ALONG    }
    ENPS {020,        015,          movePattern13D1,   sp.SDB_ENEMY3 enp.ENP_LEFT_BOUNCE    }
    ENPS {010,        035,          movePattern13D3,   sp.SDB_ENEMY2 enp.ENP_RIGHT_BOUNCE   }
    ENPS {010,        020,          movePattern18,     sp.SDB_ENEMY1 enp.ENP_LEFT_ALONG     }
    ENPS {010,        020,          movePattern18,     sp.SDB_ENEMY1 enp.ENP_RIGHT_ALONG    }

    ENPS {168,        030,          movePattern22,     sp.SDB_ENEMY1 enp.ENP_LEFT_ALONG_RP  }
    ENPS {128,        025,          movePattern22,     sp.SDB_ENEMY1 enp.ENP_LEFT_ALONG_RP  }
    ENPS {127,        015,          movePattern01D3,   sp.SDB_ENEMY3 enp.ENP_RIGHT_HIT      }
    ENPS {165,        020,          movePattern01D1,   sp.SDB_ENEMY2 enp.ENP_RIGHT_HIT      }

    ;NPS {103,        010,          movePattern01D0,   sp.SDB_ENEMY1 enp.ENP_LEFT_HIT       }
    ENPS {144,        012,          movePattern01D0,   sp.SDB_ENEMY1 enp.ENP_RIGHT_HIT      }
    ENPS {144,        018,          movePattern01D0,   sp.SDB_ENEMY1 enp.ENP_LEFT_HIT       }
    ENPS {185,        015,          movePattern01D0,   sp.SDB_ENEMY1 enp.ENP_RIGHT_HIT      }
    ENPS {185,        009,          movePattern01D0,   sp.SDB_ENEMY1 enp.ENP_LEFT_HIT       }
    
    ENPS {227,        020,          movePattern09  ,   sp.SDB_ENEMY3 enp.ENP_RIGHT_ALONG    }
    ENPS {227,        040,          movePattern09  ,   sp.SDB_ENEMY3 enp.ENP_LEFT_HIT       }

SINGLE_ENEMIES_L4       = 17
enemyFormationL4 ENPS {085/*RESPAWN_Y*/, 8/*RESPAWN_DELAY*/, movePattern23/*MOVE_PAT_POINTER*/, sp.SDB_ENEMY2/*SDB_INIT*/, enp.ENP_LEFT_ALONG_RP/*SETUP*/}

; ##############################################
; Level 5
singleEnemiesL5
    ;     RESPAWN_Y   RESPAWN_DELAY MOVE_PAT_ADDR      SDB_INIT      SETUP

    ENPS {020,        013,          movePattern25,   sp.SDB_ENEMY1   enp.ENP_LEFT_HIT_RP  }
    ENPS {030,        040,          movePattern20,   sp.SDB_ENEMY1   enp.ENP_RIGHT_BOUNCE_AN }
    ENPS {060,        023,          movePattern20,   sp.SDB_ENEMY1   enp.ENP_LEFT_BOUNCE_AN  }
    ENPS {070,        026,          movePattern20,   sp.SDB_ENEMY1   enp.ENP_RIGHT_BOUNCE_AN }
    ENPS {080,        020,          movePattern07,   sp.SDB_ENEMY1   enp.ENP_LEFT_BOUNCE_AN  }
    ENPS {100,        018,          movePattern20,   sp.SDB_ENEMY1   enp.ENP_LEFT_BOUNCE_AN  }
    ENPS {120,        023,          movePattern07,   sp.SDB_ENEMY1   enp.ENP_LEFT_BOUNCE_AN  }
    ENPS {130,        040,          movePattern20,   sp.SDB_ENEMY1   enp.ENP_LEFT_BOUNCE_AN  }
    ENPS {150,        030,          movePattern07,   sp.SDB_ENEMY1   enp.ENP_RIGHT_BOUNCE_AN }
    ENPS {140,        018,          movePattern20,   sp.SDB_ENEMY1   enp.ENP_LEFT_BOUNCE_AN  }
    ENPS {180,        027,          movePattern20,   sp.SDB_ENEMY1   enp.ENP_LEFT_BOUNCE_AN  }
    ENPS {190,        023,          movePattern07,   sp.SDB_ENEMY1   enp.ENP_RIGHT_BOUNCE_AN }
    ENPS {200,        030,          movePattern20,   sp.SDB_ENEMY1   enp.ENP_LEFT_BOUNCE_AN  }
    ENPS {220,        015,          movePattern20,   sp.SDB_ENEMY1   enp.ENP_LEFT_BOUNCE_AN  }
    ENPS {120,        020,          movePattern07,   sp.SDB_ENEMY1   enp.ENP_LEFT_BOUNCE_AN  }
    ENPS {220,        016,          movePattern20,   sp.SDB_ENEMY1   enp.ENP_RIGHT_BOUNCE_AN }
SINGLE_ENEMIES_L5       = 15
enemyFormationL5 ENPS {175/*RESPAWN_Y*/, 3/*RESPAWN_DELAY*/, movePattern25/*MOVE_PAT_POINTER*/, sp.SDB_ENEMY2/*SDB_INIT*/, enp.ENP_LEFT_HIT_RP/*SETUP*/}

; ##############################################
; Level 6
singleEnemiesL6
    ;     RESPAWN_Y   RESPAWN_DELAY MOVE_PAT_ADDR      SDB_INIT      SETUP
    ENPS {005,        010,          movePattern26,    sp.SDB_ENEMY1 enp.ENP_LEFT_HIT_RP     }
    ENPS {005,        010,          movePattern27,    sp.SDB_ENEMY1 enp.ENP_RIGHT_HIT_RP    }
    ENPS {070,        015,          movePattern28,    sp.SDB_ENEMY1 enp.ENP_LEFT_BOUNCE_AN  }
    ENPS {150,        020,          movePattern28,    sp.SDB_ENEMY1 enp.ENP_LEFT_BOUNCE_AN  }
    ENPS {224,        015,          movePattern28,    sp.SDB_ENEMY1 enp.ENP_LEFT_BOUNCE_AN  }
    ENPS {010,        023,          movePattern29,    sp.SDB_ENEMY1 enp.ENP_RIGHT_BOUNCE_AN }
    ENPS {120,        012,          movePattern29,    sp.SDB_ENEMY1 enp.ENP_RIGHT_BOUNCE_AN }
    ENPS {224,        025,          movePattern01D1,  sp.SDB_ENEMY1 enp.ENP_RIGHT_BOUNCE_AN }
SINGLE_ENEMIES_L6       = 8
enemyFormationL6 ENPS {10/*RESPAWN_Y*/, 3/*RESPAWN_DELAY*/, movePattern31/*MOVE_PAT_POINTER*/, sp.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_LEFT_HIT_RP/*SETUP*/}

; ##############################################
; Level 7
singleEnemiesL7
    ;     RESPAWN_Y   RESPAWN_DELAY MOVE_PAT_ADDR      SDB_INIT      SETUP
    ENPS {100,        015,          movePattern08,   sp.SDB_ENEMY1   enp.ENP_LEFT_BOUNCE_AN  }
    ENPS {100,        015,          movePattern08,   sp.SDB_ENEMY1   enp.ENP_RIGHT_BOUNCE_AN }
    ENPS {150,        013,          movePattern08,   sp.SDB_ENEMY1   enp.ENP_LEFT_BOUNCE_AN  }
    ENPS {150,        013,          movePattern08,   sp.SDB_ENEMY1   enp.ENP_RIGHT_BOUNCE_AN }
    ENPS {220,        010,          movePattern08,   sp.SDB_ENEMY1   enp.ENP_LEFT_BOUNCE_AN  }
    ENPS {220,        010,          movePattern08,   sp.SDB_ENEMY1   enp.ENP_RIGHT_BOUNCE_AN }
SINGLE_ENEMIES_L7       = 6
enemyFormationL7 ENPS {20/*RESPAWN_Y*/, 3/*RESPAWN_DELAY*/, movePattern02D2/*MOVE_PAT_POINTER*/, sp.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_LEFT_BOUNCE_AN/*SETUP*/}

; ##############################################
; Level 9
singleEnemiesL9
    ;     RESPAWN_Y   RESPAWN_DELAY MOVE_PAT_ADDR      SDB_INIT      SETUP
    ENPS {232,        015,          movePattern01D3,   sp.SDB_ENEMY1   enp.ENP_LEFT_HIT  }
    ENPS {232,        020,          movePattern01D2,   sp.SDB_ENEMY1   enp.ENP_RIGHT_HIT }
    ENPS {160,        023,          movePattern01D2,   sp.SDB_ENEMY1   enp.ENP_LEFT_HIT  }
    ENPS {160,        020,          movePattern01D0,   sp.SDB_ENEMY1   enp.ENP_RIGHT_HIT }
    ENPS {080,        030,          movePattern01D3,   sp.SDB_ENEMY1   enp.ENP_LEFT_HIT  }
    ENPS {080,        025,          movePattern01D1,   sp.SDB_ENEMY1   enp.ENP_RIGHT_HIT }
    ENPS {032,        023,          movePattern01D2,   sp.SDB_ENEMY1   enp.ENP_LEFT_HIT  }
    ENPS {032,        020,          movePattern01D1,   sp.SDB_ENEMY1   enp.ENP_RIGHT_HIT }
SINGLE_ENEMIES_L9       = 8

; ##############################################
; Level 10
singleEnemiesL10
    ;     RESPAWN_Y   RESPAWN_DELAY MOVE_PAT_ADDR      SDB_INIT      SETUP
    ENPS {224,        015,          movePattern01D2,   sp.SDB_ENEMY1   enp.ENP_LEFT_HIT  }
    ENPS {224,        020,          movePattern01D1,   sp.SDB_ENEMY1   enp.ENP_RIGHT_HIT }
    ENPS {165,        023,          movePattern01D1,   sp.SDB_ENEMY1   enp.ENP_LEFT_HIT  }
    ENPS {165,        020,          movePattern01D2,   sp.SDB_ENEMY1   enp.ENP_RIGHT_HIT }
    ENPS {144,        030,          movePattern01D3,   sp.SDB_ENEMY1   enp.ENP_LEFT_HIT  }
    ENPS {144,        025,          movePattern01D1,   sp.SDB_ENEMY1   enp.ENP_RIGHT_HIT }
SINGLE_ENEMIES_L10       = 6

;----------------------------------------------------------;
;                      Fuel Thief                          ;
;----------------------------------------------------------;
fuelThiefEnp
    ENP {0/*SETUP*/, 0/*MOVE_DELAY*/, 0/*MOVE_DELAY_CNT*/, 0/*MOVE_PX*/, 0/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 233/*RESPAWN_Y*/, movePattern19/*MOVE_PAT_POINTER*/, enp.MOVE_PAT_STEP_OFFSET_D1/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}

fuelThiefSpr
    SPR {96/*ID*/, sp.SDB_FUEL_THIEF/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, fuelThiefEnp/*EXT_DATA_POINTER*/}

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE