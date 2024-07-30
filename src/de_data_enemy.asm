;----------------------------------------------------------;
;                         Enemies                          ;
;----------------------------------------------------------;
	MODULE de

; Single enemies
spriteEx01
	ep.ESS {%000000'1'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 005/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 170/*RESPOWN_Y*/, ep.movePattern01/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx02
	ep.ESS {%000000'0'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 000/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 050/*RESPOWN_Y*/, ep.movePattern01/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx03
	ep.ESS {%000000'1'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 000/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 060/*RESPOWN_Y*/, ep.movePattern01/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx04
	ep.ESS {%000000'0'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 000/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 080/*RESPOWN_Y*/, ep.movePattern01/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx05
	ep.ESS {%000000'1'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 005/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 100/*RESPOWN_Y*/, ep.movePattern02/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx06
	ep.ESS {%000000'0'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 005/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 120/*RESPOWN_Y*/, ep.movePattern06/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx07
	ep.ESS {%000000'1'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 005/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 140/*RESPOWN_Y*/, ep.movePattern09/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx08
	ep.ESS {%000000'0'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 000/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 160/*RESPOWN_Y*/, ep.movePattern01/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx09
	ep.ESS {%000000'1'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 000/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 180/*RESPOWN_Y*/, ep.movePattern01/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx10
	ep.ESS {%000000'0'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 002/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 200/*RESPOWN_Y*/, ep.movePattern01/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}

; Enemies reserved for formation
spriteExEf01
	ep.ESS {%000000'1'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 000/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 160/*RESPOWN_Y*/, ep.movePattern01/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteExEf02
	ep.ESS {%000000'1'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 100/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 160/*RESPOWN_Y*/, ep.movePattern01/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteExEf03
	ep.ESS {%000000'1'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 100/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 160/*RESPOWN_Y*/, ep.movePattern01/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteExEf04
	ep.ESS {%000000'1'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 100/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 160/*RESPOWN_Y*/, ep.movePattern01/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteExEf05
	ep.ESS {%000000'1'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 100/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 160/*RESPOWN_Y*/, ep.movePattern01/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}

; Single sprites, used by single enemies (#spriteExXX)
sprite01
	sr.MSS {20/*ID*/, sr.SDB_COMET1/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx01/*EXT_DATA_POINTER*/}
sprite02
	sr.MSS {21/*ID*/, sr.SDB_COMET1/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx02/*EXT_DATA_POINTER*/}
sprite03
	sr.MSS {22/*ID*/, sr.SDB_COMET1/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx03/*EXT_DATA_POINTER*/}
sprite04
	sr.MSS {23/*ID*/, sr.SDB_COMET1/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx04/*EXT_DATA_POINTER*/}
sprite05
	sr.MSS {24/*ID*/, sr.SDB_COMET2/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx05/*EXT_DATA_POINTER*/}
sprite06
	sr.MSS {25/*ID*/, sr.SDB_COMET2/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx06/*EXT_DATA_POINTER*/}
sprite07
	sr.MSS {26/*ID*/, sr.SDB_COMET2/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx07/*EXT_DATA_POINTER*/}
sprite08
	sr.MSS {27/*ID*/, sr.SDB_COMET1/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx08/*EXT_DATA_POINTER*/}
sprite09
	sr.MSS {28/*ID*/, sr.SDB_COMET1/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx09/*EXT_DATA_POINTER*/}
sprite10
	sr.MSS {29/*ID*/, sr.SDB_COMET1/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx10/*EXT_DATA_POINTER*/}

; Formation sprites used by formation enemies (#spriteExEfXX)
spriteEf01
	sr.MSS {30/*ID*/, sr.SDB_COMET1/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteExEf01/*EXT_DATA_POINTER*/}
spriteEf02
	sr.MSS {31/*ID*/, sr.SDB_COMET1/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteExEf02/*EXT_DATA_POINTER*/}
spriteEf03
	sr.MSS {32/*ID*/, sr.SDB_COMET1/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteExEf03/*EXT_DATA_POINTER*/}
spriteEf04
	sr.MSS {33/*ID*/, sr.SDB_COMET1/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteExEf04/*EXT_DATA_POINTER*/}
spriteEf05
	sr.MSS {34/*ID*/, sr.SDB_COMET1/*SDB_INIT*/, 0/*DB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteExEf05/*EXT_DATA_POINTER*/}

spritesSize					DB 15				; The total amount of visible sprites - including single enemies and formations
singleSpritesSize			DB 10				; Amount of sprites that can respawn as a single enemy

formation ef.MF{de.spriteEf01/*MSS_POINTER*/, 2000/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 5/*SPRITES*/, 0/*SPRITES_CNT*/}

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE