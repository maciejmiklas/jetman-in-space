;----------------------------------------------------------;
;                         Enemies                          ;
;----------------------------------------------------------;
	MODULE ed

; Single enemies
spriteEx01
	ep.ENEMY {%000000'1'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 005/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 050/*RESPOWN_Y*/, ep.movePattern01/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx02
	ep.ENEMY {%000000'0'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 050/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 130/*RESPOWN_Y*/, ep.movePattern01/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx03
	ep.ENEMY {%000000'1'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 060/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 180/*RESPOWN_Y*/, ep.movePattern01/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx04
	ep.ENEMY {%000000'0'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 010/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 020/*RESPOWN_Y*/, ep.movePattern01/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx05
	ep.ENEMY {%000000'1'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 010/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 040/*RESPOWN_Y*/, ep.movePattern01/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx06
	ep.ENEMY {%000000'0'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 020/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 080/*RESPOWN_Y*/, ep.movePattern01/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx07
	ep.ENEMY {%000000'1'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 020/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 110/*RESPOWN_Y*/, ep.movePattern01/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx08
	ep.ENEMY {%000000'0'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 010/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 130/*RESPOWN_Y*/, ep.movePattern01/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx09
	ep.ENEMY {%000000'1'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 020/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 150/*RESPOWN_Y*/, ep.movePattern01/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx10
	ep.ENEMY {%000000'0'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 010/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 220/*RESPOWN_Y*/, ep.movePattern01/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}

; Enemies reserved for formation
spriteExEf01
	ep.ENEMY {%000000'1'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 000/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 180/*RESPOWN_Y*/, ep.movePattern07/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteExEf02
	ep.ENEMY {%000000'1'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 100/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 180/*RESPOWN_Y*/, ep.movePattern07/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteExEf03
	ep.ENEMY {%000000'1'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 100/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 180/*RESPOWN_Y*/, ep.movePattern07/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteExEf04
	ep.ENEMY {%000000'1'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 100/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 180/*RESPOWN_Y*/, ep.movePattern07/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteExEf05
	ep.ENEMY {%000000'1'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 100/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 180/*RESPOWN_Y*/, ep.movePattern07/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}

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
	sr.SPRITE {30/*ID*/, sr.SDB_ENEMY2/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteExEf01/*EXT_DATA_POINTER*/}
spriteEf02
	sr.SPRITE {31/*ID*/, sr.SDB_ENEMY2/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteExEf02/*EXT_DATA_POINTER*/}
spriteEf03
	sr.SPRITE {32/*ID*/, sr.SDB_ENEMY2/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteExEf03/*EXT_DATA_POINTER*/}
spriteEf04
	sr.SPRITE {33/*ID*/, sr.SDB_ENEMY2/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteExEf04/*EXT_DATA_POINTER*/}
spriteEf05
	sr.SPRITE {34/*ID*/, sr.SDB_ENEMY2/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteExEf05/*EXT_DATA_POINTER*/}

spritesSize					BYTE 15				; The total amount of visible sprites - including single enemies and formations
singleSpritesSize			BYTE 10				; Amount of sprites that can respawn as a single enemy

formation ef.EF{spriteEf01/*SPRITE_POINTER*/, 62000/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 5/*SPRITES*/, 0/*SPRITES_CNT*/}

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE