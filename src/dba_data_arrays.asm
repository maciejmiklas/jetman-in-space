;----------------------------------------------------------;
;                    Arrays (Bank 29)                      ;
;----------------------------------------------------------;
    module dba

; Before using it call #dbs.SetupArraysBank
    MMU _RAM_SLOT7, dbs.ARR_BANK_S7_D29
    ORG _RAM_SLOT7_STA_HE000
spritesBankStart

;----------------------------------------------------------;
;                           Menu                           ;
;----------------------------------------------------------;
menuEl
    mma.MENU {mma.TOP_OFS+mma.LOF+5                  /*TILE_OFFSET*/, menuTextSg/*TEXT_POINT*/, 12/*TEXT_SIZE*/, 200/*JET_X*/, 032/*JET_Y*/}  ; START GAME
    mma.MENU {mma.TOP_OFS+(1*mma.EL_DIST)+mma.LOF+4  /*TILE_OFFSET*/, menuTextLs/*TEXT_POINT*/, 14/*TEXT_SIZE*/, 208/*JET_X*/, 055/*JET_Y*/}  ; LEVEL SELECT
    mma.MENU {mma.TOP_OFS+(2*mma.EL_DIST)+mma.LOF+5  /*TILE_OFFSET*/, menuTextHs/*TEXT_POINT*/, 12/*TEXT_SIZE*/, 200/*JET_X*/, 080/*JET_Y*/}  ; HIGH SCORE
    mma.MENU {mma.TOP_OFS+(3*mma.EL_DIST)+mma.LOF+4  /*TILE_OFFSET*/, menuTextIg/*TEXT_POINT*/, 14/*TEXT_SIZE*/, 206/*JET_X*/, 104/*JET_Y*/}  ; IN GAME KEYS
    mma.MENU {mma.TOP_OFS+(4*mma.EL_DIST)+mma.LOF+6  /*TILE_OFFSET*/, menuTextGp/*TEXT_POINT*/, 10/*TEXT_SIZE*/, 192/*JET_X*/, 128/*JET_Y*/}  ; GAMEPLAY
    mma.MENU {mma.TOP_OFS+(5*mma.EL_DIST)+mma.LOF+5  /*TILE_OFFSET*/, menuTextDi/*TEXT_POINT*/, 12/*TEXT_SIZE*/, 200/*JET_X*/, 152/*JET_Y*/}  ; DIFFICULTY
MENU_EL_SIZE            = 6

menuTextSg DB "START GAME ",ti.TX_IDX_ENTER
menuTextLs DB "LEVEL SELECT ",ti.TX_IDX_MINUS
menuTextHs DB "HIGH SCORE ",ti.TX_IDX_ENTER
menuTextIg DB "IN GAME KEYS ",ti.TX_IDX_ENTER
menuTextGp DB "GAMEPLAY ",ti.TX_IDX_ENTER
menuTextDi DB "DIFFICULTY ",ti.TX_IDX_ARROWS

DIF_OFFSET              = mma.TOP_OFS+(5*mma.EL_DIST)+mma.EL_SDIST+mma.LOF+7
menuDifEasy
    mma.MENU {DIF_OFFSET /*TILE_OFFSET*/, menuTextEa/*TEXT_POINT*/, 6/*TEXT_SIZE*/, 200/*JET_X*/, 176/*JET_Y*/}  ; EASY

menuDifNorm
    mma.MENU {DIF_OFFSET /*TILE_OFFSET*/, menuTextNo/*TEXT_POINT*/, 6/*TEXT_SIZE*/, 200/*JET_X*/, 176/*JET_Y*/}  ; NORMAL

menuDifHard
    mma.MENU {DIF_OFFSET /*TILE_OFFSET*/, menuTextHa/*TEXT_POINT*/, 6/*TEXT_SIZE*/, 200/*JET_X*/, 176/*JET_Y*/}  ; HARD

menuTextEa DB " EASY "
menuTextNo DB "NORMAL"
menuTextHa DB " HARD "

; User can enter 10 character, but we display 13: [3xSPACE][10 characters for user name]
menuScore                                       ; This score does not show on screen, it's only there for the sorting ;)
    DW $FFFF
    DW $FFFF
    DB "   FREDUS    "
menuScore1
    DW 00000
    DW 09000
    DB "   MACIEJ    "
menuScore2
    DW 00000
    DW 08000
    DB "   ARTUR     "
menuScore3
    DW 00000
    DW 07000
    DB "   MARCIN    "
menuScore4
    DW 00000
    DW 06000
    DB "   MACIEJ    "
menuScore5
    DW 00000
    DW 05000
    DB "   JUREK     "
menuScore6
    DW 00000
    DW 04000
    DB "   FRANEK    "
menuScore7
    DW 00000
    DW 03000
    DB "   ZUZA      "
menuScore8
    DW 00000
    DW 02000
    DB "   KAROL     "
menuScore9
    DW 00000
    DW 01000
    DB "   FRED      "

menuScoreCursor
    sr.SPR {10/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}

;----------------------------------------------------------;
;                   Movement patterns                      ;
;----------------------------------------------------------;

; Horizontal, max speed.
movePattern01D0
    DB 2, %0'000'1'111,$00

; Horizontal, delay 2.
movePattern01D1
    DB 2, %0'000'1'111,$10  

; Horizontal, delay 2.
movePattern01D2
    DB 2, %0'000'1'111,$20

; Horizontal, delay 3.
movePattern01D3
    DB 2, %0'000'1'111,$30

; 18deg down, delay 0.
movePattern02D0
    DB 2, %1'001'1'111,$00

; 18deg down, delay 1.
movePattern02D1
    DB 2, %1'001'1'111,$10  

; 18deg down, delay 2.
movePattern02D2
    DB 2, %1'001'1'111,$20

; 18deg down, delay 3.
movePattern02D3
    DB 2, %1'001'1'111,$30  

; 18deg up, delay 0.
movePattern03D0
    DB 2, %0'001'1'111,$20

; 5* horizontal, 2x 45deg down,...
movePattern05
    DB 4, %0'000'1'111,$05, %1'111'1'111,$02

; Half sinus.
movePattern06
    DB 32, %0'010'1'001,$22, %0'011'1'010,$22, %0'100'1'011,$31, %0'011'1'011,$31, %0'010'1'011,$33, %0'001'1'011,$32, %0'001'1'100,$32, %0'001'1'101,$31   ; going up
        DB %1'001'1'101,$21, %1'001'1'100,$22, %1'001'1'011,$22, %1'010'1'011,$23, %1'011'1'011,$11, %1'100'1'011,$11, %1'011'1'010,$12, %1'010'1'001,$01   ; going down

; Sinus.
movePattern07
    DB 64, %0'010'1'001,$32, %0'011'1'010,$32, %0'100'1'011,$31, %0'011'1'011,$31, %0'010'1'011,$33, %0'001'1'011,$32, %0'001'1'100,$32, %0'001'1'101,$31   ; going up, above X
        DB %1'001'1'101,$21, %1'001'1'100,$22, %1'001'1'011,$22, %1'010'1'011,$23, %1'011'1'011,$21, %1'100'1'011,$21, %1'011'1'010,$22, %1'010'1'001,$22   ; going down, above X
        DB %1'010'1'001,$11, %1'011'1'010,$11, %1'100'1'011,$11, %1'011'1'011,$01, %1'010'1'011,$03, %1'001'1'011,$02, %1'001'1'100,$02, %1'001'1'101,$01   ; going down, below X
        DB %0'001'1'101,$11, %0'001'1'100,$12, %0'001'1'011,$22, %0'010'1'011,$23, %0'011'1'011,$21, %0'100'1'011,$31, %0'011'1'010,$32, %0'010'1'001,$32   ; going up, below X
        
; Square wave.
movePattern08
    DB 8, %0'000'1'111,$25, %1'111'1'000,$23, %0'000'1'111,$25, %0'111'1'000,$23

; Saw wave.
movePattern09
;         45deg up slow    45deg down slow   45deg up slow   45deg down slow  45deg up fast   45deg down fast
    DB 12, %0'001'1'011,41, %1'001'1'011,41, %0'001'1'011,41, %1'001'1'011,41, %0'001'1'011,31, %1'001'1'011,31

; Square, triangle wave.
movePattern10
    DB 24, %0'000'1'111,$25, %1'111'1'000,$23, %0'000'1'111,$25, %0'111'1'000,$23, %0'000'1'111,$25, %1'111'1'000,$23, %0'000'1'111,$25, %0'111'1'000,$23, %1'111'1'111,$03, %0'111'1'111,$03, %1'111'1'111,$03, %0'111'1'111,$03

movePattern11
;         45deg down         horizontal        horizontal       horizontal         45deg up
    DB 10, %1'111'1'111,$0F, %0'000'1'111,$1F, %0'000'1'111,$2F, %0'000'1'111,$1F, %0'011'1'011,$3F 

; 34deg up, delay 2.
movePattern12D2
    DB 2, %0'011'1'111,$20 

; 34deg up, delay 1.
movePattern12D1
    DB 2, %0'011'1'111,$10 

; 34deg down, delay 0.
movePattern13D0
    DB 2, %1'011'1'111,$00 

; 34deg down, delay 1.
movePattern13D1
    DB 2, %1'011'1'111,$10 

; 34deg down, delay 2.
movePattern13D2
    DB 2, %1'011'1'111,$20 

; 34deg down, delay 3.
movePattern13D3
    DB 2, %1'011'1'111,$30 

; 34deg down, delay 4.
movePattern13D4
    DB 2, %1'011'1'111,$40  

; 45deg down, delay 0.
movePattern14D0
    DB 2, %1'001'1'001,$00 

; 45deg down, delay 1.
movePattern14D1
    DB 2, %1'001'1'001,$10 

; 45deg down, delay 2.
movePattern14D2
    DB 2, %1'001'1'001,$20 

; 45deg up, delay 1.
movePattern15D1
    DB 2, %0'001'1'001,$10 

; 45deg up, delay 2.
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

;----------------------------------------------------------;
;                  Sprite Animations                       ;
;----------------------------------------------------------;

; The animation system is based on a state machine. Each state is represented by a single DB record (#SPR_REC). 
; A single record has an ID that can be used to find it. It has a sequence of sprite patterns that will be played, 
; and once this sequence is done, it contains the offset to the following command (#OFF_NX). It could be an ID for the following DB record 
; containing another animation or a command like #SDB_HIDE that will hide the sprite.
srSpriteDB
    sr.SPR_REC {sr.SDB_EXPLODE, sr.SDB_HIDE - sr.SDB_SUB,   04}
            DB 30, 31, 32, 33
    sr.SPR_REC {sr.SDB_FIRE,    sr.SDB_FIRE - sr.SDB_SUB,   02}
            DB 54, 55
    sr.SPR_REC {sr.SDB_ENEMY1,  sr.SDB_ENEMY1 - sr.SDB_SUB, 24}
            DB 45,46, 45,46,   45,46,47, 45,46,47,   46,47, 46,47,   45,46,47, 45,46,47,   45,47, 45,47
    sr.SPR_REC {sr.SDB_ENEMY2,  sr.SDB_ENEMY2 - sr.SDB_SUB, 03}
            DB 48, 49, 50
    sr.SPR_REC {sr.SDB_ENEMY3,  sr.SDB_ENEMY3 - sr.SDB_SUB, 03}
            DB 34, 35, 36
    sr.SPR_REC {sr.FUEL_THIEF,  sr.FUEL_THIEF - sr.SDB_SUB, 03}
            DB 58, 59, 63

;----------------------------------------------------------;
;                     Single enemies                       ;
;----------------------------------------------------------;

spriteEx01
    enp.ENP {0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, enp.RESPAWN_OFF/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 0/*RESPAWN_Y*/, movePattern01D0/*MOVE_PAT_POINTER*/, enp.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx02
    enp.ENP {0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, enp.RESPAWN_OFF/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 0/*RESPAWN_Y*/, movePattern01D0/*MOVE_PAT_POINTER*/, enp.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx03
    enp.ENP {0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, enp.RESPAWN_OFF/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 0/*RESPAWN_Y*/, movePattern01D0/*MOVE_PAT_POINTER*/, enp.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx04
    enp.ENP {0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, enp.RESPAWN_OFF/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 0/*RESPAWN_Y*/, movePattern01D0/*MOVE_PAT_POINTER*/, enp.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx05
    enp.ENP {0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, enp.RESPAWN_OFF/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 0/*RESPAWN_Y*/, movePattern01D0/*MOVE_PAT_POINTER*/, enp.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx06
    enp.ENP {0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, enp.RESPAWN_OFF/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 0/*RESPAWN_Y*/, movePattern01D0/*MOVE_PAT_POINTER*/, enp.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx07
    enp.ENP {0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, enp.RESPAWN_OFF/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 0/*RESPAWN_Y*/, movePattern01D0/*MOVE_PAT_POINTER*/, enp.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx08
    enp.ENP {0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, enp.RESPAWN_OFF/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 0/*RESPAWN_Y*/, movePattern01D0/*MOVE_PAT_POINTER*/, enp.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx09
    enp.ENP {0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, enp.RESPAWN_OFF/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 0/*RESPAWN_Y*/, movePattern01D0/*MOVE_PAT_POINTER*/, enp.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/} 
spriteEx10
    enp.ENP {0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, enp.RESPAWN_OFF/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 0/*RESPAWN_Y*/, movePattern01D0/*MOVE_PAT_POINTER*/, enp.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx11
    enp.ENP {0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, enp.RESPAWN_OFF/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 0/*RESPAWN_Y*/, movePattern01D0/*MOVE_PAT_POINTER*/, enp.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx12
    enp.ENP {0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, enp.RESPAWN_OFF/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 0/*RESPAWN_Y*/, movePattern01D0/*MOVE_PAT_POINTER*/, enp.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx13
    enp.ENP {0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, enp.RESPAWN_OFF/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 0/*RESPAWN_Y*/, movePattern01D0/*MOVE_PAT_POINTER*/, enp.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx14
    enp.ENP {0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, enp.RESPAWN_OFF/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 0/*RESPAWN_Y*/, movePattern01D0/*MOVE_PAT_POINTER*/, enp.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx15
    enp.ENP {0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, enp.RESPAWN_OFF/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 0/*RESPAWN_Y*/, movePattern01D0/*MOVE_PAT_POINTER*/, enp.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx16
    enp.ENP {0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, enp.RESPAWN_OFF/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 0/*RESPAWN_Y*/, movePattern01D0/*MOVE_PAT_POINTER*/, enp.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx17
    enp.ENP {0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, enp.RESPAWN_OFF/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 0/*RESPAWN_Y*/, movePattern01D0/*MOVE_PAT_POINTER*/, enp.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx18
    enp.ENP {0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, enp.RESPAWN_OFF/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 0/*RESPAWN_Y*/, movePattern01D0/*MOVE_PAT_POINTER*/, enp.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx19
    enp.ENP {0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, enp.RESPAWN_OFF/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 0/*RESPAWN_Y*/, movePattern01D0/*MOVE_PAT_POINTER*/, enp.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx20
    enp.ENP {0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, enp.RESPAWN_OFF/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 0/*RESPAWN_Y*/, movePattern01D0/*MOVE_PAT_POINTER*/, enp.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}

; Enemies reserved for enemyFormation.
spriteExEf01
    enp.ENP {0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, enp.RESPAWN_OFF/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 0/*RESPAWN_Y*/, movePattern07/*MOVE_PAT_POINTER*/, enp.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteExEf02
    enp.ENP {0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, enp.RESPAWN_OFF/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 0/*RESPAWN_Y*/, movePattern07/*MOVE_PAT_POINTER*/, enp.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteExEf03
    enp.ENP {0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, enp.RESPAWN_OFF/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 0/*RESPAWN_Y*/, movePattern07/*MOVE_PAT_POINTER*/, enp.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteExEf04
    enp.ENP {0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, enp.RESPAWN_OFF/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 0/*RESPAWN_Y*/, movePattern07/*MOVE_PAT_POINTER*/, enp.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteExEf05
    enp.ENP {0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, enp.RESPAWN_OFF/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 0/*RESPAWN_Y*/, movePattern07/*MOVE_PAT_POINTER*/, enp.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteExEf06
    enp.ENP {0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, enp.RESPAWN_OFF/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 0/*RESPAWN_Y*/, movePattern07/*MOVE_PAT_POINTER*/, enp.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteExEf07
    enp.ENP {0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, enp.RESPAWN_OFF/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 0/*RESPAWN_Y*/, movePattern07/*MOVE_PAT_POINTER*/, enp.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}

; Single sprites, used by single enemies (#spriteExXX).
singleEnemySprites
    sr.SPR {20/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx01/*EXT_DATA_POINTER*/}
    sr.SPR {21/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx02/*EXT_DATA_POINTER*/}
    sr.SPR {22/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx03/*EXT_DATA_POINTER*/}
    sr.SPR {23/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx04/*EXT_DATA_POINTER*/}
    sr.SPR {24/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx05/*EXT_DATA_POINTER*/}
    sr.SPR {25/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx06/*EXT_DATA_POINTER*/}
    sr.SPR {26/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx07/*EXT_DATA_POINTER*/}
    sr.SPR {27/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx08/*EXT_DATA_POINTER*/}
    sr.SPR {28/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx09/*EXT_DATA_POINTER*/}
    sr.SPR {29/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx10/*EXT_DATA_POINTER*/}
    sr.SPR {30/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx11/*EXT_DATA_POINTER*/}
    sr.SPR {31/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx12/*EXT_DATA_POINTER*/}
    sr.SPR {32/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx13/*EXT_DATA_POINTER*/}
    sr.SPR {33/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx14/*EXT_DATA_POINTER*/}
    sr.SPR {34/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx15/*EXT_DATA_POINTER*/}
    sr.SPR {35/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx16/*EXT_DATA_POINTER*/}
    sr.SPR {36/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx17/*EXT_DATA_POINTER*/}
    sr.SPR {37/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx18/*EXT_DATA_POINTER*/}
    sr.SPR {38/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx19/*EXT_DATA_POINTER*/}
    sr.SPR {39/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx20/*EXT_DATA_POINTER*/}
ENEMY_SINGLE_SIZE       = 20

; Formation sprites used by enemyFormation enemies (#spriteExEfXX).
formationEnemySprites
    sr.SPR {61/*ID*/, sr.SDB_ENEMY3/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteExEf01/*EXT_DATA_POINTER*/}
    sr.SPR {62/*ID*/, sr.SDB_ENEMY3/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteExEf02/*EXT_DATA_POINTER*/}
    sr.SPR {63/*ID*/, sr.SDB_ENEMY3/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteExEf03/*EXT_DATA_POINTER*/}
    sr.SPR {64/*ID*/, sr.SDB_ENEMY3/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteExEf04/*EXT_DATA_POINTER*/}
    sr.SPR {65/*ID*/, sr.SDB_ENEMY3/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteExEf05/*EXT_DATA_POINTER*/}
    sr.SPR {66/*ID*/, sr.SDB_ENEMY3/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteExEf06/*EXT_DATA_POINTER*/}
    sr.SPR {67/*ID*/, sr.SDB_ENEMY3/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteExEf07/*EXT_DATA_POINTER*/}
ENEMY_FORMATION_SIZE    = 7

;----------------------------------------------------------;
;                         Enemies                          ;
;----------------------------------------------------------;

singleEnemiesL1
    enp.ENPS {020/*RESPAWN_Y*/, 025/*RESPAWN_DELAY*/, movePattern01D3/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT  /*SETUP*/}
    enp.ENPS {040/*RESPAWN_Y*/, 025/*RESPAWN_DELAY*/, movePattern01D2/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_RIGHT_HIT /*SETUP*/}
    enp.ENPS {050/*RESPAWN_Y*/, 050/*RESPAWN_DELAY*/, movePattern01D2/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT  /*SETUP*/}
    enp.ENPS {085/*RESPAWN_Y*/, 045/*RESPAWN_DELAY*/, movePattern01D2/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT  /*SETUP*/}
    enp.ENPS {090/*RESPAWN_Y*/, 080/*RESPAWN_DELAY*/, movePattern01D3/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_RIGHT_HIT /*SETUP*/}
    enp.ENPS {105/*RESPAWN_Y*/, 020/*RESPAWN_DELAY*/, movePattern01D2/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT  /*SETUP*/}
    enp.ENPS {125/*RESPAWN_Y*/, 025/*RESPAWN_DELAY*/, movePattern01D2/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_RIGHT_HIT /*SETUP*/}
    enp.ENPS {150/*RESPAWN_Y*/, 074/*RESPAWN_DELAY*/, movePattern01D3/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_RIGHT_HIT /*SETUP*/}
    enp.ENPS {175/*RESPAWN_Y*/, 010/*RESPAWN_DELAY*/, movePattern01D2/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT  /*SETUP*/}
    enp.ENPS {220/*RESPAWN_Y*/, 025/*RESPAWN_DELAY*/, movePattern01D2/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT  /*SETUP*/}
SINGLE_ENEMIES_L1       = 10
enemyFormationL1 enp.ENPS {0/*RESPAWN_Y*/, enp.RESPAWN_OFF/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT/*SETUP*/}

singleEnemiesL2
    enp.ENPS {020/*RESPAWN_Y*/, 010/*RESPAWN_DELAY*/, movePattern01D3/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT   /*SETUP*/}
    enp.ENPS {020/*RESPAWN_Y*/, 010/*RESPAWN_DELAY*/, movePattern01D2/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_RIGHT_HIT   /*SETUP*/}
    enp.ENPS {040/*RESPAWN_Y*/, 015/*RESPAWN_DELAY*/, movePattern01D2/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_RIGHT_HIT  /*SETUP*/}
    enp.ENPS {080/*RESPAWN_Y*/, 015/*RESPAWN_DELAY*/, movePattern02D2/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT   /*SETUP*/}
    enp.ENPS {100/*RESPAWN_Y*/, 010/*RESPAWN_DELAY*/, movePattern02D1/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_ALONG /*SETUP*/}
    enp.ENPS {120/*RESPAWN_Y*/, 005/*RESPAWN_DELAY*/, movePattern02D2/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_RIGHT_ALONG/*SETUP*/}
    enp.ENPS {140/*RESPAWN_Y*/, 024/*RESPAWN_DELAY*/, movePattern02D2/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT   /*SETUP*/}
    enp.ENPS {180/*RESPAWN_Y*/, 022/*RESPAWN_DELAY*/, movePattern01D3/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_RIGHT_ALONG/*SETUP*/}
    enp.ENPS {200/*RESPAWN_Y*/, 025/*RESPAWN_DELAY*/, movePattern16  /*MOVE_PAT_POINTER*/, sr.SDB_ENEMY2/*SDB_INIT*/, enp.ENP_S_RIGHT_ALONG/*SETUP*/}
    enp.ENPS {220/*RESPAWN_Y*/, 022/*RESPAWN_DELAY*/, movePattern01D2/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_ALONG /*SETUP*/}
    enp.ENPS {220/*RESPAWN_Y*/, 020/*RESPAWN_DELAY*/, movePattern01D2/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_RIGHT_ALONG/*SETUP*/}
SINGLE_ENEMIES_L2       = 11
enemyFormationL2 enp.ENPS {0/*RESPAWN_Y*/, enp.RESPAWN_OFF/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT/*SETUP*/}

singleEnemiesL3
    enp.ENPS {010/*RESPAWN_Y*/, 025/*RESPAWN_DELAY*/, movePattern01D3/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_ALONG/*SETUP*/}
    enp.ENPS {020/*RESPAWN_Y*/, 025/*RESPAWN_DELAY*/, movePattern01D2/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_RIGHT_HIT /*SETUP*/}
    enp.ENPS {050/*RESPAWN_Y*/, 015/*RESPAWN_DELAY*/, movePattern02D1/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT  /*SETUP*/}
    enp.ENPS {040/*RESPAWN_Y*/, 015/*RESPAWN_DELAY*/, movePattern02D2/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_RIGHT_HIT /*SETUP*/}
    enp.ENPS {060/*RESPAWN_Y*/, 025/*RESPAWN_DELAY*/, movePattern02D1/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT  /*SETUP*/}
    enp.ENPS {060/*RESPAWN_Y*/, 025/*RESPAWN_DELAY*/, movePattern02D2/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_RIGHT_HIT /*SETUP*/}
    enp.ENPS {080/*RESPAWN_Y*/, 021/*RESPAWN_DELAY*/, movePattern02D3/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY2/*SDB_INIT*/, enp.ENP_S_LEFT_HIT  /*SETUP*/}
    enp.ENPS {080/*RESPAWN_Y*/, 021/*RESPAWN_DELAY*/, movePattern02D2/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY2/*SDB_INIT*/, enp.ENP_S_RIGHT_HIT /*SETUP*/}
    enp.ENPS {100/*RESPAWN_Y*/, 028/*RESPAWN_DELAY*/, movePattern02D3/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY2/*SDB_INIT*/, enp.ENP_S_LEFT_HIT  /*SETUP*/}
    enp.ENPS {100/*RESPAWN_Y*/, 028/*RESPAWN_DELAY*/, movePattern02D2/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY2/*SDB_INIT*/, enp.ENP_S_RIGHT_HIT /*SETUP*/}
    enp.ENPS {120/*RESPAWN_Y*/, 027/*RESPAWN_DELAY*/, movePattern02D1/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY2/*SDB_INIT*/, enp.ENP_S_LEFT_HIT  /*SETUP*/}
    enp.ENPS {120/*RESPAWN_Y*/, 028/*RESPAWN_DELAY*/, movePattern02D3/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY2/*SDB_INIT*/, enp.ENP_S_RIGHT_HIT /*SETUP*/}
    enp.ENPS {140/*RESPAWN_Y*/, 023/*RESPAWN_DELAY*/, movePattern02D2/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY2/*SDB_INIT*/, enp.ENP_S_LEFT_HIT  /*SETUP*/}
    enp.ENPS {140/*RESPAWN_Y*/, 023/*RESPAWN_DELAY*/, movePattern02D1/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY2/*SDB_INIT*/, enp.ENP_S_RIGHT_HIT /*SETUP*/}
    enp.ENPS {160/*RESPAWN_Y*/, 038/*RESPAWN_DELAY*/, movePattern02D2/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT  /*SETUP*/}
    enp.ENPS {160/*RESPAWN_Y*/, 037/*RESPAWN_DELAY*/, movePattern02D2/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_RIGHT_HIT /*SETUP*/}
    enp.ENPS {180/*RESPAWN_Y*/, 035/*RESPAWN_DELAY*/, movePattern02D1/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT  /*SETUP*/}
    enp.ENPS {180/*RESPAWN_Y*/, 025/*RESPAWN_DELAY*/, movePattern02D2/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_RIGHT_HIT /*SETUP*/}
    enp.ENPS {200/*RESPAWN_Y*/, 028/*RESPAWN_DELAY*/, movePattern02D3/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT  /*SETUP*/}
    enp.ENPS {200/*RESPAWN_Y*/, 044/*RESPAWN_DELAY*/, movePattern02D3/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_RIGHT_HIT /*SETUP*/}
SINGLE_ENEMIES_L3       = 20
enemyFormationL3 enp.ENPS {130/*RESPAWN_Y*/, 5/*RESPAWN_DELAY*/, movePattern07/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY3/*SDB_INIT*/, enp.ENP_S_LEFT_ALONG/*SETUP*/}

singleEnemiesL4
    enp.ENPS {010/*RESPAWN_Y*/, 025/*RESPAWN_DELAY*/, movePattern02D3/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_ALONG  /*SETUP*/}
    enp.ENPS {010/*RESPAWN_Y*/, 030/*RESPAWN_DELAY*/, movePattern02D2/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_RIGHT_ALONG /*SETUP*/}
    enp.ENPS {020/*RESPAWN_Y*/, 029/*RESPAWN_DELAY*/, movePattern13D1/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY3/*SDB_INIT*/, enp.ENP_S_LEFT_ALONG  /*SETUP*/}
    enp.ENPS {010/*RESPAWN_Y*/, 025/*RESPAWN_DELAY*/, movePattern13D3/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY2/*SDB_INIT*/, enp.ENP_S_RIGHT_ALONG /*SETUP*/}
    enp.ENPS {010/*RESPAWN_Y*/, 027/*RESPAWN_DELAY*/, movePattern18  /*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_ALONG  /*SETUP*/}
    enp.ENPS {010/*RESPAWN_Y*/, 032/*RESPAWN_DELAY*/, movePattern18  /*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_RIGHT_ALONG /*SETUP*/}

    enp.ENPS {127/*RESPAWN_Y*/, 018/*RESPAWN_DELAY*/, movePattern01D2/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY3/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {127/*RESPAWN_Y*/, 015/*RESPAWN_DELAY*/, movePattern01D3/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY3/*SDB_INIT*/, enp.ENP_S_RIGHT_HIT   /*SETUP*/}
    enp.ENPS {165/*RESPAWN_Y*/, 025/*RESPAWN_DELAY*/, movePattern01D1/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY2/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {165/*RESPAWN_Y*/, 020/*RESPAWN_DELAY*/, movePattern01D1/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY2/*SDB_INIT*/, enp.ENP_S_RIGHT_HIT   /*SETUP*/}

    enp.ENPS {103/*RESPAWN_Y*/, 010/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {144/*RESPAWN_Y*/, 012/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_RIGHT_HIT   /*SETUP*/}
    enp.ENPS {144/*RESPAWN_Y*/, 018/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {185/*RESPAWN_Y*/, 015/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_RIGHT_HIT   /*SETUP*/}  
    enp.ENPS {185/*RESPAWN_Y*/, 009/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    
    enp.ENPS {227/*RESPAWN_Y*/, 020/*RESPAWN_DELAY*/, movePattern09  /*MOVE_PAT_POINTER*/, sr.SDB_ENEMY3/*SDB_INIT*/, enp.ENP_S_RIGHT_ALONG /*SETUP*/}
    enp.ENPS {227/*RESPAWN_Y*/, 040/*RESPAWN_DELAY*/, movePattern09  /*MOVE_PAT_POINTER*/, sr.SDB_ENEMY3/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}

SINGLE_ENEMIES_L4       = 17
enemyFormationL4 enp.ENPS {085/*RESPAWN_Y*/, 8/*RESPAWN_DELAY*/, movePattern17/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY2/*SDB_INIT*/, enp.ENP_S_LEFT_ALONG/*SETUP*/}

singleEnemiesL5
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
SINGLE_ENEMIES_L5       = 1
enemyFormationL5 enp.ENPS {0/*RESPAWN_Y*/, enp.RESPAWN_OFF/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT/*SETUP*/}

singleEnemiesL6
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
SINGLE_ENEMIES_L6       = 1
enemyFormationL6 enp.ENPS {0/*RESPAWN_Y*/, enp.RESPAWN_OFF/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT/*SETUP*/}

singleEnemiesL7
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
SINGLE_ENEMIES_L7       = 1 
enemyFormationL7 enp.ENPS {0/*RESPAWN_Y*/, enp.RESPAWN_OFF/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT/*SETUP*/}

singleEnemiesL8
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
SINGLE_ENEMIES_L8       = 1 
enemyFormationL8 enp.ENPS {0/*RESPAWN_Y*/, enp.RESPAWN_OFF/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT/*SETUP*/}

singleEnemiesL9
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
SINGLE_ENEMIES_L9       = 1 
enemyFormationL9 enp.ENPS {0/*RESPAWN_Y*/, enp.RESPAWN_OFF/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT/*SETUP*/}

singleEnemiesL10
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
    enp.ENPS {009/*RESPAWN_Y*/, 255/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT    /*SETUP*/}
SINGLE_ENEMIES_L10      = 1 
enemyFormationL10 enp.ENPS {0/*RESPAWN_Y*/, enp.RESPAWN_OFF/*RESPAWN_DELAY*/, movePattern01D0/*MOVE_PAT_POINTER*/, sr.SDB_ENEMY1/*SDB_INIT*/, enp.ENP_S_LEFT_HIT/*SETUP*/}

;----------------------------------------------------------;
;                      Fuel Thief                          ;
;----------------------------------------------------------;
fuelThiefEnp
    enp.ENP {0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 0/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 233/*RESPAWN_Y*/, movePattern19/*MOVE_PAT_POINTER*/, enp.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}

fuelThiefSpr
    sr.SPR {96/*ID*/, sr.FUEL_THIEF/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, fuelThiefEnp/*EXT_DATA_POINTER*/}


;----------------------------------------------------------;
;                     Jetman Sprite Data                   ;
;----------------------------------------------------------;

; The animation system is based on a state machine. Its database is divided into records, each containing a list of frames to be played and 
; a reference to the next record that will be played once all frames from the current record have been executed.
; DB Record:
;    [ID], [OFF_NX], [SIZE], [DELAY], [[FRAME_UP,FRAME_LW], [FRAME_UP,FRAME_LW],...,[FRAME_UP,FRAME_LW]]
; where:
;   - ID:           Entry ID for lookup via CPIR
;   - OFF_NX:       ID of the following animation DB record. We subtract from this ID the 100 so that CPIR does not find OFF_NX but ID
;   - SIZE:         Amount of bytes in this record
;   - DELAY:        Amount animation calls to skip (slows down animation)
;   - FRAME_UP:     Offset for the upper part of the Jetman
;   - FRAME_LW:     Offset for the lower part of the Jetman
jetSpriteDB
    ; Jetman is flaying
    DB js.SDB_FLY,      js.SDB_FLY - js.SDB_SUB,        48, 5
                                            DB 00,10, 00,11, 01,12, 01,13, 02,11, 02,12, 03,10, 03,11, 04,12, 04,13
                                            DB 05,12, 05,11, 03,10, 03,11, 04,12, 04,13, 05,10, 05,12, 03,10, 03,11
                                            DB 04,12, 04,13, 05,12, 05,10

    ; Jetman is flaying down
    DB js.SDB_FLYD,     js.SDB_FLYD - js.SDB_SUB,       48, 5
                                            DB 00,12, 00,37, 01,38, 01,37, 02,12, 02,38, 03,12, 03,37, 04,38, 04,12
                                            DB 05,38, 05,37, 03,37, 03,12, 04,38, 04,12, 05,37, 05,38, 03,37, 03,12
                                            DB 04,12, 04,37, 05,38, 05,37

    ; Jetman hovers
    DB js.SDB_HOVER,    js.SDB_HOVER - js.SDB_SUB,      48, 10
                                            DB 00,14, 00,15, 01,16, 01,10, 02,11, 02,12, 03,13, 03,10, 04,11, 04,12 
                                            DB 05,13, 05,14, 03,15, 03,16, 04,10, 04,11, 05,12, 05,13, 03,10, 03,11
                                            DB 04,12, 04,13, 05,10, 05,11

    ; Jetman starts walking with raised feet to avoid moving over the ground and standing still
    DB js.SDB_WALK_ST,  js.SDB_WALK - js.SDB_SUB,       02, 3
                                            DB 03,07

    ; Jetman is walking
    DB js.SDB_WALK,     js.SDB_WALK - js.SDB_SUB,       48, 3
                                            DB 03,06, 03,07, 04,08, 04,09, 05,06, 05,06, 03,08, 03,09, 04,06, 04,07
                                            DB 05,08, 05,09, 00,06, 00,07, 01,08, 01,09, 02,06, 02,07, 03,08, 03,09 
                                            DB 04,06, 04,07, 05,08, 05,09

    ; Jetman stands in place
    DB js.SDB_STAND,    js.SDB_STAND - js.SDB_SUB,      46, 5
                                            DB 03,06, 03,18, 04,19, 04,18, 05,06, 05,19, 03,06, 03,18, 04,19, 04,06
                                            DB 05,19, 05,18, 00,19, 00,18, 01,06, 01,18, 02,06, 02,19, 03,18, 03,18
                                            DB 04,19, 05,06, 05,18

    ; Jetman stands on the ground for a very short time
    DB js.SDB_JSTAND,   js.SDB_STAND - js.SDB_SUB,      02, 3
                                            DB 03,18

    ; Jetman got hit
    DB js.SDB_RIP,      js.SDB_RIP - js.SDB_SUB,        08, 5 
                                            DB 00,27, 01,28, 02,15, 03,29

    ; Transition: walking -> flaying
    DB js.SDB_T_WF,     js.SDB_FLY - js.SDB_SUB,        08, 5
                                            DB 03,26, 04,25, 05,24, 03,23

    ; Transition: flaying -> standing
    DB js.SDB_T_FS,     js.SDB_STAND - js.SDB_SUB,      08, 5
                                            DB 03,23, 04,24, 05,25, 03,26

    ; Transition: flaying -> walking
    DB js.SDB_T_FW,     js.SDB_WALK - js.SDB_SUB,       08, 5
                                            DB 03,23, 04,24, 05,25, 03,26

    ; Transition: kinking -> flying
    DB js.SDB_T_KF,     js.SDB_FLY - js.SDB_SUB,        10, 5
                                            DB 03,15, 04,16, 05,27, 03,28, 04,29

    ; Transition: kinking -> hoovering
    DB js.SDB_T_KO,     js.SDB_HOVER - js.SDB_SUB,        10, 5
                                            DB 03,15, 04,16, 05,27, 03,28, 04,29

;----------------------------------------------------------;
;                     Rocket Sprite Data                   ;
;----------------------------------------------------------;

AGND                    = 30*8
TASM                    = 226
TSID                    = rof.EXHAUST_SPRID_D83
TSRE                    = 17

; Level 1
rocketAssemblyXL1       DB 22*8
rocketElL1
; Rocket element.
    ro.RO {04*8/*DROP_X*/, 14*8/*DROP_LAND_Y*/, 234/*ASSEMBLY_Y*/, 80/*SPRITE_ID*/, 60/*SPRITE_REF*/, 0/*Y*/}  ; bottom element
    ro.RO {13*8/*DROP_X*/, 20*8/*DROP_LAND_Y*/, 218/*ASSEMBLY_Y*/, 81/*SPRITE_ID*/, 56/*SPRITE_REF*/, 0/*Y*/}  ; middle element
    ro.RO {18*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, 202/*ASSEMBLY_Y*/, 82/*SPRITE_ID*/, 52/*SPRITE_REF*/, 0/*Y*/}  ; top of the rocket
    
; Fuel tank.
    ro.RO {03*8/*DROP_X*/, 14*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {29*8/*DROP_X*/, 09*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {31*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {09*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {25*8/*DROP_X*/, 09*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {09*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    
; Level 2
rocketAssemblyXL2       DB 24*8
rocketElL2
; Rocket element.
    ro.RO {07*8/*DROP_X*/, 07*8/*DROP_LAND_Y*/, 234/*ASSEMBLY_Y*/, 80/*SPRITE_ID*/, 60/*SPRITE_REF*/, 0/*Y*/}  ; bottom element
    ro.RO {26*8/*DROP_X*/, 20*8/*DROP_LAND_Y*/, 218/*ASSEMBLY_Y*/, 81/*SPRITE_ID*/, 56/*SPRITE_REF*/, 0/*Y*/}  ; middle element
    ro.RO {01*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, 202/*ASSEMBLY_Y*/, 82/*SPRITE_ID*/, 52/*SPRITE_REF*/, 0/*Y*/}  ; top of the rocket
    
; Fuel tank.
    ro.RO {09*8/*DROP_X*/, 07*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {29*8/*DROP_X*/, 07*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {26*8/*DROP_X*/, 20*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {01*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {01*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {17*8/*DROP_X*/, 07*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}

; Level 3
rocketAssemblyXL3       DB 6*8
rocketElL3
; Rocket element.
    ro.RO {09*8/*DROP_X*/, 05*8/*DROP_LAND_Y*/, 234/*ASSEMBLY_Y*/, 80/*SPRITE_ID*/, 60/*SPRITE_REF*/, 0/*Y*/}  ; bottom element
    ro.RO {24*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, 218/*ASSEMBLY_Y*/, 81/*SPRITE_ID*/, 56/*SPRITE_REF*/, 0/*Y*/}  ; middle element
    ro.RO {13*8/*DROP_X*/, 05*8/*DROP_LAND_Y*/, 202/*ASSEMBLY_Y*/, 82/*SPRITE_ID*/, 52/*SPRITE_REF*/, 0/*Y*/}  ; top of the rocket
    
; Fuel tank.
    ro.RO {05*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {31*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {12*8/*DROP_X*/, 05*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {03*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {23*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {01*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}

; Level 4
rocketAssemblyXL4       DB 18*8
rocketElL4
; Rocket element.
    ro.RO {06*8/*DROP_X*/, 06*8/*DROP_LAND_Y*/, 234/*ASSEMBLY_Y*/, 80/*SPRITE_ID*/, 60/*SPRITE_REF*/, 0/*Y*/}  ; bottom element
    ro.RO {14*8/*DROP_X*/, 12*8/*DROP_LAND_Y*/, 218/*ASSEMBLY_Y*/, 81/*SPRITE_ID*/, 56/*SPRITE_REF*/, 0/*Y*/}  ; middle element
    ro.RO {23*8/*DROP_X*/, 17*8/*DROP_LAND_Y*/, 202/*ASSEMBLY_Y*/, 82/*SPRITE_ID*/, 52/*SPRITE_REF*/, 0/*Y*/}  ; top of the rocket
    
; Fuel tank.
    ro.RO {02*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {30*8/*DROP_X*/, 10*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {21*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {27*8/*DROP_X*/, 10*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {10*8/*DROP_X*/, 06*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {16*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}

; Level 5
rocketAssemblyXL5       DB 18*8
rocketElL5
; Rocket element.
    ro.RO {11*8/*DROP_X*/, 06*8/*DROP_LAND_Y*/, 234/*ASSEMBLY_Y*/, 80/*SPRITE_ID*/, 60/*SPRITE_REF*/, 0/*Y*/}  ; bottom element
    ro.RO {25*8/*DROP_X*/, 11*8/*DROP_LAND_Y*/, 218/*ASSEMBLY_Y*/, 81/*SPRITE_ID*/, 56/*SPRITE_REF*/, 0/*Y*/}  ; middle element
    ro.RO {04*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, 202/*ASSEMBLY_Y*/, 82/*SPRITE_ID*/, 52/*SPRITE_REF*/, 0/*Y*/}  ; top of the rocket
    
; Fuel tank.
    ro.RO {04*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {14*8/*DROP_X*/, 06*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {27*8/*DROP_X*/, 11*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {06*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {02*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {31*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}

; Level 6
rocketAssemblyXL6       DB 02*8
rocketElL6
; Rocket element.
    ro.RO {20*8/*DROP_X*/, 15*8/*DROP_LAND_Y*/, 234/*ASSEMBLY_Y*/, 80/*SPRITE_ID*/, 60/*SPRITE_REF*/, 0/*Y*/}  ; bottom element
    ro.RO {12*8/*DROP_X*/, 06*8/*DROP_LAND_Y*/, 218/*ASSEMBLY_Y*/, 81/*SPRITE_ID*/, 56/*SPRITE_REF*/, 0/*Y*/}  ; middle element
    ro.RO {16*8/*DROP_X*/, 09*8/*DROP_LAND_Y*/, 202/*ASSEMBLY_Y*/, 82/*SPRITE_ID*/, 52/*SPRITE_REF*/, 0/*Y*/}  ; top of the rocket
    
; Fuel tank.
    ro.RO {21*8/*DROP_X*/, 15*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {24*8/*DROP_X*/, 18*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {27*8/*DROP_X*/, 21*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {30*8/*DROP_X*/, 24*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {21*8/*DROP_X*/, 15*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {20*8/*DROP_X*/, 15*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}

; Level 7
rocketAssemblyXL7       DB 18*8
rocketElL7
; Rocket element.
    ro.RO {06*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, 234/*ASSEMBLY_Y*/, 80/*SPRITE_ID*/, 60/*SPRITE_REF*/, 0/*Y*/}  ; bottom element
    ro.RO {16*8/*DROP_X*/, 05*8/*DROP_LAND_Y*/, 218/*ASSEMBLY_Y*/, 81/*SPRITE_ID*/, 56/*SPRITE_REF*/, 0/*Y*/}  ; middle element
    ro.RO {31*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, 202/*ASSEMBLY_Y*/, 82/*SPRITE_ID*/, 52/*SPRITE_REF*/, 0/*Y*/}  ; top of the rocket
    
; Fuel tank.
    ro.RO {02*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {05*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {12*8/*DROP_X*/, 05*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {21*5/*DROP_X*/, 05*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {27*8/*DROP_X*/, 05*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {31*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}

; Level 8
rocketAssemblyXL8       DB 29*8
rocketElL8
; Rocket element.
    ro.RO {08*8/*DROP_X*/, 10*8/*DROP_LAND_Y*/, 234/*ASSEMBLY_Y*/, 80/*SPRITE_ID*/, 60/*SPRITE_REF*/, 0/*Y*/}  ; bottom element
    ro.RO {15*8/*DROP_X*/, 21*8/*DROP_LAND_Y*/, 218/*ASSEMBLY_Y*/, 81/*SPRITE_ID*/, 56/*SPRITE_REF*/, 0/*Y*/}  ; middle element
    ro.RO {17*8/*DROP_X*/, 06*8/*DROP_LAND_Y*/, 202/*ASSEMBLY_Y*/, 82/*SPRITE_ID*/, 52/*SPRITE_REF*/, 0/*Y*/}  ; top of the rocket
    
; Fuel tank.
    ro.RO {27*8/*DROP_X*/, 18*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {31*8/*DROP_X*/, 12*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {17*8/*DROP_X*/, 06*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {12*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {03*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {17*8/*DROP_X*/, 06*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}

; Level 9
rocketAssemblyXL9       DB 15*8
rocketElL9
; Rocket element.
    ro.RO {04*8/*DROP_X*/, 11*8/*DROP_LAND_Y*/, 234/*ASSEMBLY_Y*/, 80/*SPRITE_ID*/, 60/*SPRITE_REF*/, 0/*Y*/}  ; bottom element
    ro.RO {08*8/*DROP_X*/, 11*8/*DROP_LAND_Y*/, 218/*ASSEMBLY_Y*/, 81/*SPRITE_ID*/, 56/*SPRITE_REF*/, 0/*Y*/}  ; middle element
    ro.RO {30*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, 202/*ASSEMBLY_Y*/, 82/*SPRITE_ID*/, 52/*SPRITE_REF*/, 0/*Y*/}  ; top of the rocket
    
; Fuel tank.
    ro.RO {16*8/*DROP_X*/, 16*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {25*8/*DROP_X*/, 05*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {20*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {25*8/*DROP_X*/, 05*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {08*8/*DROP_X*/, 11*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {01*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}

; Level 10
rocketAssemblyXL10      DB 19*8
rocketElL10
; Rocket element.
    ro.RO {05*8/*DROP_X*/, 27*8/*DROP_LAND_Y*/, 234/*ASSEMBLY_Y*/, 80/*SPRITE_ID*/, 60/*SPRITE_REF*/, 0/*Y*/}  ; bottom element
    ro.RO {27*8/*DROP_X*/, 27*8/*DROP_LAND_Y*/, 218/*ASSEMBLY_Y*/, 81/*SPRITE_ID*/, 56/*SPRITE_REF*/, 0/*Y*/}  ; middle element
    ro.RO {15*8/*DROP_X*/, 17*8/*DROP_LAND_Y*/, 202/*ASSEMBLY_Y*/, 82/*SPRITE_ID*/, 52/*SPRITE_REF*/, 0/*Y*/}  ; top of the rocket
    
; Fuel tank.
    ro.RO {27*8/*DROP_X*/, 27*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {05*8/*DROP_X*/, 27*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {05*8/*DROP_X*/, 27*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {27*8/*DROP_X*/, 27*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {23*8/*DROP_X*/, 17*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {27*8/*DROP_X*/, 27*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    
; Three explode DBs for three rocket elements.
rocketExplodeDB1        DB 60,60,60,60, 60,60,60,60, 30,31,32,31, 30,32,31,31, 30,31,32,33  ; bottom element
rocketExplodeDB2        DB 56,56,56,56, 30,31,32,31, 30,31,32,31, 32,30,32,31, 30,31,32,33  ; middle element
rocketExplodeDB3        DB 30,31,32,31, 30,31,32,31, 30,31,32,31, 30,32,31,30, 30,31,32,33  ; top of the rocket

rocketExhaustDB                                 ; Sprite IDs for exhaust
    DB 53,57,62,  57,62,53,  62,53,57,  53,62,57,  62,57,53,  57,53,62
RO_EXHAUST_MAX          = 18

rocketExplodeTankDB     DB 30, 31, 32, 33       ; Sprite IDs for explosion

;----------------------------------------------------------;
;                      Jetman Weapon                       ;
;----------------------------------------------------------;

; Sprites for single shots (#shots), based on #SPR.
shots
    sr.SPR {10/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
    sr.SPR {11/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
    sr.SPR {12/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
    sr.SPR {13/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
    sr.SPR {14/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
    sr.SPR {15/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
    sr.SPR {16/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
    sr.SPR {17/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
    sr.SPR {18/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
    sr.SPR {19/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
    sr.SPR {91/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
    sr.SPR {92/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
    sr.SPR {93/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
    sr.SPR {94/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
    sr.SPR {95/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
SHOTS_SIZE              = 15                   ; Amount of shots that can be simultaneously fired. Max is limited by #shotsXX

;----------------------------------------------------------;
;                       Game Pickups                       ;
;----------------------------------------------------------;

deployOrderPos          DB 0
deployOrder
    DB pi.PI_SPR_DIAMOND, pi.PI_SPR_STRAWBERRY, pi.PI_SPR_GUN, pi.PI_SPR_DIAMOND, pi.PI_SPR_JAR, pi.PI_SPR_GUN, pi.PI_SPR_JAR
    DB pi.PI_SPR_STRAWBERRY, pi.PI_SPR_GUN, pi.PI_SPR_GRENADE, pi.PI_SPR_STRAWBERRY, pi.PI_SPR_GUN, pi.PI_SPR_GRENADE, pi.PI_SPR_GUN
    DB pi.PI_SPR_STRAWBERRY, pi.PI_SPR_GUN, pi.PI_SPR_JAR, pi.PI_SPR_STRAWBERRY, pi.PI_SPR_DIAMOND, pi.PI_SPR_GUN, pi.PI_SPR_STRAWBERRY
DEPLOY_ORDER_SIZE       = 20

;----------------------------------------------------------;
;                          Platforms                       ;
;----------------------------------------------------------;
; [amount of platforms], #PLA,..., #PLA]. Platforms are tiles. Each tile has 8x8 pixels.

; The "close margin" has to be smaller on the left/right than the "hit margin" and larger on the top/bottom than the "hit margin".
; We will first recognize whether an enemy should fly along the platform and, after that, whether it is a hit. If the "close margin" 
; on the left were larger than the hit margin, the enemy would never hit the platform from the left, it would fly through it. The same is 
; true for "top margin". Here, the "close margin" has to be larger so that the enemy first starts flying along the platform and does not 
; hit it first.
closeMargin     pl.PLAM { 14/*X_LEFT*/, 14/*X_RIGHT*/, 18/*Y_TOP*/, 09/*Y_BOTTOM*/}
spriteHitMargin pl.PLAM { 15/*X_LEFT*/, 15/*X_RIGHT*/, 13/*Y_TOP*/, 04/*Y_BOTTOM*/}
shotHitMargin   pl.PLAM { 10/*X_LEFT*/, 10/*X_RIGHT*/, 07/*Y_TOP*/, 00/*Y_BOTTOM*/}
jetHitMargin    pl.PLAM { 15/*X_LEFT*/, 07/*X_RIGHT*/, 23/*Y_TOP*/, 10/*Y_BOTTOM*/}

; Be careful - Jetman bumps into a platform and gets pushed away, which counts as movement. When Jetman gets pushed too far,
; it exceeds the margin defined here, resetting #joyOffBump.
jetAwayMargin   pl.PLAM { 30/*X_LEFT*/, 20/*X_RIGHT*/, 30/*Y_TOP*/, 20/*Y_BOTTOM*/}

; Level 1
platformsL1
    pl.PLA {03*8/*X_LEFT*/, 08*8/*X_RIGHT*/, 15*8/*Y_TOP*/, 15*8/*Y_BOTTOM*/}
    pl.PLA {11*8/*X_LEFT*/, 17*8/*X_RIGHT*/, 21*8/*Y_TOP*/, 21*8/*Y_BOTTOM*/}
    pl.PLA {25*8/*X_LEFT*/, 30*8/*X_RIGHT*/, 10*8/*Y_TOP*/, 10*8/*Y_BOTTOM*/}
platformsSizeL1         DB 3

; Level 2
platformsL2
    pl.PLA {02*8/*X_LEFT*/, 19*8/*X_RIGHT*/, 08*8/*Y_TOP*/, 08*8/*Y_BOTTOM*/}
    pl.PLA {27*8/*X_LEFT*/, 35*8/*X_RIGHT*/, 08*8/*Y_TOP*/, 08*8/*Y_BOTTOM*/}
    pl.PLA {08*8/*X_LEFT*/, 19*8/*X_RIGHT*/, 21*8/*Y_TOP*/, 21*8/*Y_BOTTOM*/}
    pl.PLA {26*8/*X_LEFT*/, 33*8/*X_RIGHT*/, 21*8/*Y_TOP*/, 21*8/*Y_BOTTOM*/}
platformsSizeL2         DB 4

; Level 3
platformsL3
    pl.PLA {09*8/*X_LEFT*/, 18*8/*X_RIGHT*/, 06*8/*Y_TOP*/, 06*8/*Y_BOTTOM*/}
platformsSizeL3         DB 1

; Level 4
platformsL4
    pl.PLA {04*8/*X_LEFT*/, 11*8/*X_RIGHT*/, 07*8/*Y_TOP*/, 07*8/*Y_BOTTOM*/}
    pl.PLA {24*8/*X_LEFT*/, 33*8/*X_RIGHT*/, 11*8/*Y_TOP*/, 11*8/*Y_BOTTOM*/}

    pl.PLA {14*8/*X_LEFT*/, 14*8/*X_RIGHT*/, 13*8/*Y_TOP*/, 15*8/*Y_BOTTOM*/}

    pl.PLA {14*8/*X_LEFT*/, 14*8/*X_RIGHT*/, 18*8/*Y_TOP*/, 20*8/*Y_BOTTOM*/}
    pl.PLA {23*8/*X_LEFT*/, 23*8/*X_RIGHT*/, 18*8/*Y_TOP*/, 20*8/*Y_BOTTOM*/}

    pl.PLA {14*8/*X_LEFT*/, 14*8/*X_RIGHT*/, 23*8/*Y_TOP*/, 25*8/*Y_BOTTOM*/}
    pl.PLA {23*8/*X_LEFT*/, 23*8/*X_RIGHT*/, 23*8/*Y_TOP*/, 25*8/*Y_BOTTOM*/}

platformsSizeL4         DB 7

; Level 5
platformsL5
    pl.PLA {09*8/*X_LEFT*/, 15*8/*X_RIGHT*/, 07*8/*Y_TOP*/, 07*8/*Y_BOTTOM*/}
    pl.PLA {22*8/*X_LEFT*/, 30*8/*X_RIGHT*/, 12*8/*Y_TOP*/, 12*8/*Y_BOTTOM*/}

    pl.PLA {15*8/*X_LEFT*/, 15*8/*X_RIGHT*/, 08*8/*Y_TOP*/, 09*8/*Y_BOTTOM*/}
    pl.PLA {15*8/*X_LEFT*/, 15*8/*X_RIGHT*/, 12*8/*Y_TOP*/, 14*8/*Y_BOTTOM*/}
    pl.PLA {15*8/*X_LEFT*/, 15*8/*X_RIGHT*/, 17*8/*Y_TOP*/, 19*8/*Y_BOTTOM*/}
    pl.PLA {15*8/*X_LEFT*/, 15*8/*X_RIGHT*/, 22*8/*Y_TOP*/, 24*8/*Y_BOTTOM*/}
    pl.PLA {15*8/*X_LEFT*/, 15*8/*X_RIGHT*/, 27*8/*Y_TOP*/, 28*8/*Y_BOTTOM*/}

    pl.PLA {22*8/*X_LEFT*/, 22*8/*X_RIGHT*/, 13*8/*Y_TOP*/, 14*8/*Y_BOTTOM*/}
    pl.PLA {22*8/*X_LEFT*/, 22*8/*X_RIGHT*/, 17*8/*Y_TOP*/, 19*8/*Y_BOTTOM*/}
    pl.PLA {22*8/*X_LEFT*/, 22*8/*X_RIGHT*/, 22*8/*Y_TOP*/, 24*8/*Y_BOTTOM*/}
    pl.PLA {22*8/*X_LEFT*/, 22*8/*X_RIGHT*/, 27*8/*Y_TOP*/, 28*8/*Y_BOTTOM*/}
platformsSizeL5         DB 11

; Level 6
platformsL6
    pl.PLA {08*8/*X_LEFT*/, 10*8/*X_RIGHT*/, 04*8/*Y_TOP*/, 04*8/*Y_BOTTOM*/}
    pl.PLA {11*8/*X_LEFT*/, 13*8/*X_RIGHT*/, 07*8/*Y_TOP*/, 07*8/*Y_BOTTOM*/}
    pl.PLA {14*8/*X_LEFT*/, 19*8/*X_RIGHT*/, 10*8/*Y_TOP*/, 10*8/*Y_BOTTOM*/}
    pl.PLA {19*8/*X_LEFT*/, 19*8/*X_RIGHT*/, 10*8/*Y_TOP*/, 16*8/*Y_BOTTOM*/}
    pl.PLA {22*8/*X_LEFT*/, 22*8/*X_RIGHT*/, 10*8/*Y_TOP*/, 16*8/*Y_BOTTOM*/}
    pl.PLA {22*8/*X_LEFT*/, 25*8/*X_RIGHT*/, 19*8/*Y_TOP*/, 19*8/*Y_BOTTOM*/}
    pl.PLA {26*8/*X_LEFT*/, 28*8/*X_RIGHT*/, 22*8/*Y_TOP*/, 22*8/*Y_BOTTOM*/}
    pl.PLA {29*8/*X_LEFT*/, 31*8/*X_RIGHT*/, 25*8/*Y_TOP*/, 25*8/*Y_BOTTOM*/}
    pl.PLA {32*8/*X_LEFT*/, 34*8/*X_RIGHT*/, 28*8/*Y_TOP*/, 28*8/*Y_BOTTOM*/}
platformsSizeL6         DB 9

; Level 7
platformsL7
    pl.PLA {10*8/*X_LEFT*/, 27*8/*X_RIGHT*/, 06*8/*Y_TOP*/, 06*8/*Y_BOTTOM*/}

    pl.PLA {10*8/*X_LEFT*/, 10*8/*X_RIGHT*/, 07*8/*Y_TOP*/, 08*8/*Y_BOTTOM*/}
    pl.PLA {10*8/*X_LEFT*/, 10*8/*X_RIGHT*/, 11*8/*Y_TOP*/, 13*8/*Y_BOTTOM*/}
    pl.PLA {10*8/*X_LEFT*/, 10*8/*X_RIGHT*/, 16*8/*Y_TOP*/, 20*8/*Y_BOTTOM*/}
    pl.PLA {10*8/*X_LEFT*/, 10*8/*X_RIGHT*/, 23*8/*Y_TOP*/, 28*8/*Y_BOTTOM*/}

    pl.PLA {27*8/*X_LEFT*/, 27*8/*X_RIGHT*/, 07*8/*Y_TOP*/, 08*8/*Y_BOTTOM*/}
    pl.PLA {27*8/*X_LEFT*/, 27*8/*X_RIGHT*/, 11*8/*Y_TOP*/, 13*8/*Y_BOTTOM*/}
    pl.PLA {27*8/*X_LEFT*/, 27*8/*X_RIGHT*/, 16*8/*Y_TOP*/, 20*8/*Y_BOTTOM*/}
    pl.PLA {27*8/*X_LEFT*/, 27*8/*X_RIGHT*/, 23*8/*Y_TOP*/, 28*8/*Y_BOTTOM*/}
platformsSizeL7         DB 9

; Level 8
platformsL8
    pl.PLA {01*8/*X_LEFT*/, 01*8/*X_RIGHT*/, 01*8/*Y_TOP*/, 28*8/*Y_BOTTOM*/}
    pl.PLA {04*8/*X_LEFT*/, 05*8/*X_RIGHT*/, 04*8/*Y_TOP*/, 06*8/*Y_BOTTOM*/}
    pl.PLA {04*8/*X_LEFT*/, 05*8/*X_RIGHT*/, 25*8/*Y_TOP*/, 27*8/*Y_BOTTOM*/}
    pl.PLA {08*8/*X_LEFT*/, 09*8/*X_RIGHT*/, 11*8/*Y_TOP*/, 13*8/*Y_BOTTOM*/}
    pl.PLA {08*8/*X_LEFT*/, 09*8/*X_RIGHT*/, 19*8/*Y_TOP*/, 21*8/*Y_BOTTOM*/}
    pl.PLA {17*8/*X_LEFT*/, 18*8/*X_RIGHT*/, 07*8/*Y_TOP*/, 09*8/*Y_BOTTOM*/}
    pl.PLA {15*8/*X_LEFT*/, 18*8/*X_RIGHT*/, 22*8/*Y_TOP*/, 22*8/*Y_BOTTOM*/}
    pl.PLA {23*8/*X_LEFT*/, 24*8/*X_RIGHT*/, 12*8/*Y_TOP*/, 14*8/*Y_BOTTOM*/}
    pl.PLA {23*8/*X_LEFT*/, 24*8/*X_RIGHT*/, 26*8/*Y_TOP*/, 28*8/*Y_BOTTOM*/}
    pl.PLA {26*8/*X_LEFT*/, 27*8/*X_RIGHT*/, 19*8/*Y_TOP*/, 21*8/*Y_BOTTOM*/}
    pl.PLA {31*8/*X_LEFT*/, 32*8/*X_RIGHT*/, 13*8/*Y_TOP*/, 15*8/*Y_BOTTOM*/}
    pl.PLA {35*8/*X_LEFT*/, 36*8/*X_RIGHT*/, 08*8/*Y_TOP*/, 11*8/*Y_BOTTOM*/}
    pl.PLA {34*8/*X_LEFT*/, 35*8/*X_RIGHT*/, 22*8/*Y_TOP*/, 24*8/*Y_BOTTOM*/}
    pl.PLA {33*8/*X_LEFT*/, 34*8/*X_RIGHT*/, 27*8/*Y_TOP*/, 28*8/*Y_BOTTOM*/}
    pl.PLA {38*8/*X_LEFT*/, 38*8/*X_RIGHT*/, 00*8/*Y_TOP*/, 28*8/*Y_BOTTOM*/}
platformsSizeL8         DB 15

; Level 9
platformsL9
    pl.PLA {03*8/*X_LEFT*/, 08*8/*X_RIGHT*/, 12*8/*Y_TOP*/, 12*8/*Y_BOTTOM*/}
    pl.PLA {12*8/*X_LEFT*/, 17*8/*X_RIGHT*/, 17*8/*Y_TOP*/, 17*8/*Y_BOTTOM*/}
    pl.PLA {23*8/*X_LEFT*/, 27*8/*X_RIGHT*/, 06*8/*Y_TOP*/, 06*8/*Y_BOTTOM*/}
    pl.PLA {23*8/*X_LEFT*/, 27*8/*X_RIGHT*/, 23*8/*Y_TOP*/, 23*8/*Y_BOTTOM*/}
    pl.PLA {32*8/*X_LEFT*/, 37*8/*X_RIGHT*/, 27*8/*Y_TOP*/, 27*8/*Y_BOTTOM*/}
platformsSizeL9         DB 5

; Level 10
platformsL10
    pl.PLA {03*8/*X_LEFT*/, 03*8/*X_RIGHT*/, 07*8/*Y_TOP*/, 08*8/*Y_BOTTOM*/}
    pl.PLA {03*8/*X_LEFT*/, 03*8/*X_RIGHT*/, 11*8/*Y_TOP*/, 12*8/*Y_BOTTOM*/}
    pl.PLA {03*8/*X_LEFT*/, 03*8/*X_RIGHT*/, 15*8/*Y_TOP*/, 16*8/*Y_BOTTOM*/}
    pl.PLA {03*8/*X_LEFT*/, 03*8/*X_RIGHT*/, 19*8/*Y_TOP*/, 20*8/*Y_BOTTOM*/}
    pl.PLA {03*8/*X_LEFT*/, 03*8/*X_RIGHT*/, 23*8/*Y_TOP*/, 24*8/*Y_BOTTOM*/}
    pl.PLA {03*8/*X_LEFT*/, 03*8/*X_RIGHT*/, 27*8/*Y_TOP*/, 28*8/*Y_BOTTOM*/}

    pl.PLA {08*8/*X_LEFT*/, 08*8/*X_RIGHT*/, 07*8/*Y_TOP*/, 08*8/*Y_BOTTOM*/}
    pl.PLA {08*8/*X_LEFT*/, 08*8/*X_RIGHT*/, 11*8/*Y_TOP*/, 12*8/*Y_BOTTOM*/}
    pl.PLA {08*8/*X_LEFT*/, 08*8/*X_RIGHT*/, 15*8/*Y_TOP*/, 16*8/*Y_BOTTOM*/}
    pl.PLA {08*8/*X_LEFT*/, 08*8/*X_RIGHT*/, 19*8/*Y_TOP*/, 20*8/*Y_BOTTOM*/}
    pl.PLA {08*8/*X_LEFT*/, 08*8/*X_RIGHT*/, 23*8/*Y_TOP*/, 24*8/*Y_BOTTOM*/}
    pl.PLA {08*8/*X_LEFT*/, 08*8/*X_RIGHT*/, 27*8/*Y_TOP*/, 28*8/*Y_BOTTOM*/}

    pl.PLA {13*8/*X_LEFT*/, 25*8/*X_RIGHT*/, 18*8/*Y_TOP*/, 18*8/*Y_BOTTOM*/}
    pl.PLA {13*8/*X_LEFT*/, 13*8/*X_RIGHT*/, 18*8/*Y_TOP*/, 20*8/*Y_BOTTOM*/}
    pl.PLA {13*8/*X_LEFT*/, 13*8/*X_RIGHT*/, 23*8/*Y_TOP*/, 24*8/*Y_BOTTOM*/}
    pl.PLA {13*8/*X_LEFT*/, 13*8/*X_RIGHT*/, 26*8/*Y_TOP*/, 28*8/*Y_BOTTOM*/}

    pl.PLA {25*8/*X_LEFT*/, 25*8/*X_RIGHT*/, 07*8/*Y_TOP*/, 08*8/*Y_BOTTOM*/}
    pl.PLA {25*8/*X_LEFT*/, 25*8/*X_RIGHT*/, 11*8/*Y_TOP*/, 12*8/*Y_BOTTOM*/}
    pl.PLA {25*8/*X_LEFT*/, 25*8/*X_RIGHT*/, 15*8/*Y_TOP*/, 16*8/*Y_BOTTOM*/}
    pl.PLA {25*8/*X_LEFT*/, 25*8/*X_RIGHT*/, 19*8/*Y_TOP*/, 20*8/*Y_BOTTOM*/}
    pl.PLA {25*8/*X_LEFT*/, 25*8/*X_RIGHT*/, 23*8/*Y_TOP*/, 24*8/*Y_BOTTOM*/}
    pl.PLA {25*8/*X_LEFT*/, 25*8/*X_RIGHT*/, 27*8/*Y_TOP*/, 28*8/*Y_BOTTOM*/}

    pl.PLA {30*8/*X_LEFT*/, 30*8/*X_RIGHT*/, 07*8/*Y_TOP*/, 08*8/*Y_BOTTOM*/}
    pl.PLA {30*8/*X_LEFT*/, 30*8/*X_RIGHT*/, 11*8/*Y_TOP*/, 12*8/*Y_BOTTOM*/}
    pl.PLA {30*8/*X_LEFT*/, 30*8/*X_RIGHT*/, 15*8/*Y_TOP*/, 16*8/*Y_BOTTOM*/}
    pl.PLA {30*8/*X_LEFT*/, 30*8/*X_RIGHT*/, 19*8/*Y_TOP*/, 20*8/*Y_BOTTOM*/}
    pl.PLA {30*8/*X_LEFT*/, 30*8/*X_RIGHT*/, 23*8/*Y_TOP*/, 24*8/*Y_BOTTOM*/}
    pl.PLA {30*8/*X_LEFT*/, 30*8/*X_RIGHT*/, 27*8/*Y_TOP*/, 28*8/*Y_BOTTOM*/}

    pl.PLA {03*8/*X_LEFT*/, 08*8/*X_RIGHT*/, 28*8/*Y_TOP*/, 28*8/*Y_BOTTOM*/}
    pl.PLA {25*8/*X_LEFT*/, 30*8/*X_RIGHT*/, 28*8/*Y_TOP*/, 28*8/*Y_BOTTOM*/}

platformsSizeL10        DB 30

;----------------------------------------------------------;
;                           Files                          ;
;----------------------------------------------------------;
; Tiles for level intro
introTilesFileName      DB "assets/l00/intro_0.map",0
introSecondFileSize     DW 0                    ; Will be set when loading particular level, now is 0

stTilesFileName         DB "assets/l00/stars_0.map",0
TI16K_FILE_LEVEL_POS    = 8 
TI16K_FILE_NR_POS       = 8

; Tiles for in-game platforms
plTileFileName          DB "assets/l00/tiles.map",0
PL_FILE_LEVEL_POS       = 8                     ; Position of a level number (00-99) in the file name of the background image

; Sprite file.
sprTileFileName         DB "assets/l00/sprites_0.spr",0
SPR_FILE_LEVEL_POS      = 8
SPR_FILE_NR_POS         = 10
SPR_FILE_BYT_D8192      = _BANK_BYTES_D8192

; Level background file
lbFileName              DB "assets/l00/bg_0.nxi",0
LB_FILE_LEVEL_POS       = 8                     ; Position of a level number (00-99) in the file name of the background image
LB_FILE_IMG_POS         = 14                    ; Position of a image part number (0-9) in the file name of the background image

; Level intro file
liBgFileName            DB "assets/l00/intro_0.nxi",0
LI_BG_FILE_LEVEL_POS    = 8                     ; Position of a level number (00-99) in the file name of the background image
LI_BG_FILE_IMG_POS      = 17                    ; Position of a image part number (0-9) in the file name of the background image

menuMainBgFileName      DB "assets/ma/bg_0.nxi",0
MENU_MAIN_BG_POS        = 13                    ; Position of a image part number (0-9) in the file name of the background image

menuEasyBgFileName      DB "assets/ma/easy_0.nxi",0
MENU_EASY_BG_POS        = 15                    ; Position of a image part number (0-9) in the file name of the background image

menuHardBgFileName      DB "assets/ma/hard_0.nxi",0
MENU_HARD_BG_POS        = 15                    ; Position of a image part number (0-9) in the file name of the background image

menuGameplayBgFileName  DB "assets/mg/bg_0.nxi",0
MENU_GAMEPLAY_BG_POS    = 13                    ; Position of a image part number (0-9) in the file name of the background image

menuScoreBgFileName     DB "assets/ms/bg_0.nxi",0
MENU_SCORE_BG_POS       = 13                    ; Position of a image part number (0-9) in the file name of the background image

menuKeysBgFileName      DB "assets/mk/bg_0.nxi",0
MENU_KEYS_BG_POS        = 13                    ; Position of a image part number (0-9) in the file name of the background image

gameOverBgFileName      DB "assets/go/bg_0.nxi",0
GAME_OVER_BG_POS        = 13                    ; Position of a image part number (0-9) in the file name of the background image

mmgTileFileName         DB "assets/mg/gameplay.map",0
mmkTileFileName         DB "assets/mk/keys.map",0

;----------------------------------------------------------;
;                        Final Checks                      ;
;----------------------------------------------------------;

    ASSERT $$ == dbs.ARR_BANK_S7_D29            ; Data should remain in the same bank
    ASSERT $$spritesBankStart == dbs.ARR_BANK_S7_D29 ; Make sure that we have configured the right bank
    ASSERT $ < _RAM_SLOT7_END_HFFFF             ; Data should remain within slot 7 address space

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE