;----------------------------------------------------------;
;                         Enemies                          ;
;----------------------------------------------------------;
	MODULE ed

; Horizontal movemment
movePattern01
	DB 2, %0'000'1'111,$10

; 10deg move down
movePattern02
	DB 2, %1'001'1'111,$20

; 10deg move up
movePattern03
	DB 2, %0'001'1'111,$00

; 45deg move down
movePattern04
	DB 2, %1'001'1'001,$20

; 5x horizontal, 2x 45deg down,...
movePattern05
	DB 4, %0'000'1'111,$05, %1'111'1'111,$02

; Half sinus
movePattern06
	DB 32, %0'010'1'001,$02, %0'011'1'010,$02, %0'100'1'011,$01, %0'011'1'011,$01, %0'010'1'011,$03, %0'001'1'011,$02, %0'001'1'100,$02, %0'001'1'101,$01 	; going up
		DB %1'001'1'101,$01, %1'001'1'100,$02, %1'001'1'011,$02, %1'010'1'011,$03, %1'011'1'011,$01, %1'100'1'011,$01, %1'011'1'010,$02, %1'010'1'001,$02	; going down	

; sinus
movePattern07
	DB 64, %0'010'1'001,$32, %0'011'1'010,$32, %0'100'1'011,$31, %0'011'1'011,$31, %0'010'1'011,$33, %0'001'1'011,$32, %0'001'1'100,$32, %0'001'1'101,$31 	; going up, above X
		DB %1'001'1'101,$21, %1'001'1'100,$22, %1'001'1'011,$22, %1'010'1'011,$23, %1'011'1'011,$21, %1'100'1'011,$21, %1'011'1'010,$22, %1'010'1'001,$22	; going down, above X
		DB %1'010'1'001,$11, %1'011'1'010,$11, %1'100'1'011,$11, %1'011'1'011,$01, %1'010'1'011,$03, %1'001'1'011,$02, %1'001'1'100,$02, %1'001'1'101,$01 	; going down, below X
		DB %0'001'1'101,$11, %0'001'1'100,$12, %0'001'1'011,$22, %0'010'1'011,$23, %0'011'1'011,$21, %0'100'1'011,$31, %0'011'1'010,$32, %0'010'1'001,$32	; going up, below X	
		
; Square wave
movePattern08
	DB 8, %0'000'1'111,$25, %1'111'1'000,$23, %0'000'1'111,$25, %0'111'1'000,$23

; Triangle wave
movePattern09
	DB 4, %0'111'1'111,5, %1'111'1'111,5

; Square,triangle wave
movePattern10
	DB 24, %0'000'1'111,$25, %1'111'1'000,$23, %0'000'1'111,$25, %0'111'1'000,$23, %0'000'1'111,$25, %1'111'1'000,$23, %0'000'1'111,$25, %0'111'1'000,$23, %1'111'1'111,$03, %0'111'1'111,$03, %1'111'1'111,$03, %0'111'1'111,$03

; Single enemies
spriteEx01
	ep.EN {%000000'1'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 010/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 100/*RESPOWN_Y*/, movePattern06/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx02
	ep.EN {%000000'0'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 030/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 130/*RESPOWN_Y*/, movePattern06/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx03
	ep.EN {%000000'1'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 030/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 180/*RESPOWN_Y*/, movePattern06/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx04
	ep.EN {%000000'0'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 010/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 020/*RESPOWN_Y*/, movePattern04/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx05
	ep.EN {%000000'1'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 010/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 040/*RESPOWN_Y*/, movePattern04/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx06
	ep.EN {%000000'0'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 020/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 080/*RESPOWN_Y*/, movePattern04/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx07
	ep.EN {%000000'1'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 020/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 110/*RESPOWN_Y*/, movePattern03/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx08
	ep.EN {%000000'0'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 010/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 130/*RESPOWN_Y*/, movePattern03/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx09
	ep.EN {%000000'1'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 020/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 150/*RESPOWN_Y*/, movePattern03/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx10
	ep.EN {%000000'0'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 010/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 220/*RESPOWN_Y*/, movePattern04/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}

; Enemies reserved for formation
spriteExEf01
	ep.EN {%000000'1'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 000/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 200/*RESPOWN_Y*/, movePattern07/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteExEf02
	ep.EN {%000000'1'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 100/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 200/*RESPOWN_Y*/, movePattern07/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteExEf03
	ep.EN {%000000'1'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 100/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 200/*RESPOWN_Y*/, movePattern07/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteExEf04
	ep.EN {%000000'1'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 080/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 200/*RESPOWN_Y*/, movePattern07/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteExEf05
	ep.EN {%000000'1'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 080/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 200/*RESPOWN_Y*/, movePattern07/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteExEf06
	ep.EN {%000000'1'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 080/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 200/*RESPOWN_Y*/, movePattern07/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteExEf07
	ep.EN {%000000'1'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 080/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 200/*RESPOWN_Y*/, movePattern07/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}

; Single sprites, used by single enemies (#spriteExXX)
sprite01
	sr.SPRITE {20/*ID*/, sr.SDB_ENEMY2/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx01/*EXT_DATA_POINTER*/}
sprite02
	sr.SPRITE {21/*ID*/, sr.SDB_ENEMY2/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx02/*EXT_DATA_POINTER*/}
sprite03
	sr.SPRITE {22/*ID*/, sr.SDB_ENEMY2/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx03/*EXT_DATA_POINTER*/}
sprite04
	sr.SPRITE {23/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx04/*EXT_DATA_POINTER*/}
sprite05
	sr.SPRITE {24/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx05/*EXT_DATA_POINTER*/}
sprite06
	sr.SPRITE {25/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx06/*EXT_DATA_POINTER*/}
sprite07
	sr.SPRITE {26/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx07/*EXT_DATA_POINTER*/}
sprite08
	sr.SPRITE {27/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx08/*EXT_DATA_POINTER*/}
sprite09
	sr.SPRITE {28/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx09/*EXT_DATA_POINTER*/}
sprite10
	sr.SPRITE {29/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx10/*EXT_DATA_POINTER*/}

; Formation sprites used by formation enemies (#spriteExEfXX)
spriteEf01
	sr.SPRITE {30/*ID*/, sr.SDB_ENEMY3/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteExEf01/*EXT_DATA_POINTER*/}
spriteEf02
	sr.SPRITE {31/*ID*/, sr.SDB_ENEMY3/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteExEf02/*EXT_DATA_POINTER*/}
spriteEf03
	sr.SPRITE {32/*ID*/, sr.SDB_ENEMY3/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteExEf03/*EXT_DATA_POINTER*/}
spriteEf04
	sr.SPRITE {33/*ID*/, sr.SDB_ENEMY3/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteExEf04/*EXT_DATA_POINTER*/}
spriteEf05
	sr.SPRITE {34/*ID*/, sr.SDB_ENEMY3/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteExEf05/*EXT_DATA_POINTER*/}
spriteEf06
	sr.SPRITE {35/*ID*/, sr.SDB_ENEMY3/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteExEf06/*EXT_DATA_POINTER*/}
spriteEf07
	sr.SPRITE {36/*ID*/, sr.SDB_ENEMY3/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteExEf07/*EXT_DATA_POINTER*/}	

spritesSize					BYTE 17				; The total amount of visible sprites - including single enemies and formations
singleSpritesSize			BYTE 10				; Amount of sprites that can respawn as a single enemy

formation ef.EF{spriteEf01/*SPRITE_POINTER*/, 200/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 7/*SPRITES*/, 0/*SPRITES_CNT*/}

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE