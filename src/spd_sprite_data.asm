;----------------------------------------------------------;
;                       Sprite Data                        ;
;----------------------------------------------------------;
	MODULE spd

;----------------------------------------------------------;
;                       Enemy Data                         ;
;----------------------------------------------------------;
; Before using it call #SetupSpriteDataBank
	MMU _RAM_SLOT7, _EN_BANK_D69
	ORG _RAM_SLOT7_START_HE000
enemiesBankStart

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
	ep.ENP {%000000'1'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 020/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 060/*RESPAWN_Y*/, movePattern05/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx02
	ep.ENP {%000000'1'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 020/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 105/*RESPAWN_Y*/, movePattern06/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx03
	ep.ENP {%000000'0'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 020/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 200/*RESPAWN_Y*/, movePattern07/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx04
	ep.ENP {%000000'1'0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 020/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 010/*RESPAWN_Y*/, movePattern01/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx05
	ep.ENP {%000000'1'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 020/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 030/*RESPAWN_Y*/, movePattern04/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx06
	ep.ENP {%000000'1'0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 020/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 060/*RESPAWN_Y*/, movePattern02/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx07
	ep.ENP {%000000'1'0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 020/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 090/*RESPAWN_Y*/, movePattern01/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx08
	ep.ENP {%000000'1'0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 020/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 140/*RESPAWN_Y*/, movePattern02/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx09
	ep.ENP {%000000'1'0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 020/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 230/*RESPAWN_Y*/, movePattern01/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}	
spriteEx10
	ep.ENP {%000000'0'0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 020/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 030/*RESPAWN_Y*/, movePattern01/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx11
	ep.ENP {%000000'0'0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 020/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 005/*RESPAWN_Y*/, movePattern02/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx12
	ep.ENP {%000000'0'0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 020/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 070/*RESPAWN_Y*/, movePattern02/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx13
	ep.ENP {%000000'0'0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 020/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 120/*RESPAWN_Y*/, movePattern04/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx14
	ep.ENP {%000000'0'0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 020/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 160/*RESPAWN_Y*/, movePattern02/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx15
	ep.ENP {%000000'0'0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 020/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 220/*RESPAWN_Y*/, movePattern02/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}

; Enemies reserved for formation
spriteExEf01
	ep.ENP {%000000'1'0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 000/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 200/*RESPAWN_Y*/, movePattern07/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteExEf02
	ep.ENP {%000000'1'0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 100/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 200/*RESPAWN_Y*/, movePattern07/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteExEf03
	ep.ENP {%000000'1'0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 100/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 200/*RESPAWN_Y*/, movePattern07/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteExEf04
	ep.ENP {%000000'1'0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 080/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 200/*RESPAWN_Y*/, movePattern07/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteExEf05
	ep.ENP {%000000'1'0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 080/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 200/*RESPAWN_Y*/, movePattern07/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteExEf06
	ep.ENP {%000000'1'0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 080/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 200/*RESPAWN_Y*/, movePattern07/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteExEf07
	ep.ENP {%000000'1'0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 080/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 200/*RESPAWN_Y*/, movePattern07/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}

; Single sprites, used by single enemies (#spriteExXX)
sprite01
	sr.SPR {20/*ID*/, sr.SDB_ENEMY2/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx01/*EXT_DATA_POINTER*/}
sprite02
	sr.SPR {21/*ID*/, sr.SDB_ENEMY2/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx02/*EXT_DATA_POINTER*/}
sprite03
	sr.SPR {22/*ID*/, sr.SDB_ENEMY2/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx03/*EXT_DATA_POINTER*/}
sprite04
	sr.SPR {23/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx04/*EXT_DATA_POINTER*/}
sprite05
	sr.SPR {24/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx05/*EXT_DATA_POINTER*/}
sprite06
	sr.SPR {25/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx06/*EXT_DATA_POINTER*/}
sprite07
	sr.SPR {26/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx07/*EXT_DATA_POINTER*/}
sprite08
	sr.SPR {27/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx08/*EXT_DATA_POINTER*/}
sprite09
	sr.SPR {28/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx09/*EXT_DATA_POINTER*/}
sprite10
	sr.SPR {29/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx10/*EXT_DATA_POINTER*/}
sprite11
	sr.SPR {30/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx11/*EXT_DATA_POINTER*/}
sprite12
	sr.SPR {31/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx12/*EXT_DATA_POINTER*/}
sprite13
	sr.SPR {32/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx13/*EXT_DATA_POINTER*/}
sprite14
	sr.SPR {33/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx14/*EXT_DATA_POINTER*/}
sprite15
	sr.SPR {34/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx15/*EXT_DATA_POINTER*/}

; Formation sprites used by formation enemies (#spriteExEfXX)
spriteEf01
	sr.SPR {35/*ID*/, sr.SDB_ENEMY3/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteExEf01/*EXT_DATA_POINTER*/}
spriteEf02
	sr.SPR {36/*ID*/, sr.SDB_ENEMY3/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteExEf02/*EXT_DATA_POINTER*/}
spriteEf03
	sr.SPR {37/*ID*/, sr.SDB_ENEMY3/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteExEf03/*EXT_DATA_POINTER*/}
spriteEf04
	sr.SPR {38/*ID*/, sr.SDB_ENEMY3/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteExEf04/*EXT_DATA_POINTER*/}
spriteEf05
	sr.SPR {39/*ID*/, sr.SDB_ENEMY3/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteExEf05/*EXT_DATA_POINTER*/}
spriteEf06
	sr.SPR {40/*ID*/, sr.SDB_ENEMY3/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteExEf06/*EXT_DATA_POINTER*/}
spriteEf07
	sr.SPR {41/*ID*/, sr.SDB_ENEMY3/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteExEf07/*EXT_DATA_POINTER*/}

spritesSize					BYTE 15+7			; The total amount of visible sprites - including single enemies (15) and formation (7)
singleSpritesSize			BYTE 15				; Amount of sprites that can respawn as a single enemy

formation ef.EF{spriteEf01/*SPRITE_POINTER*/, 200/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 7/*SPRITES*/, 0/*SPRITES_CNT*/}

;----------------------------------------------------------;
;                 Jetman Sprite Data                       ;
;----------------------------------------------------------;

; The animation system is based on a state machine. Its database is divided into records, each containing a list of frames to be played and 
; a reference to the next record that will be played once all frames from the current record have been executed.
; DB Record:
;    [ID], [OFF_NX], [SIZE], [DELAY], [[FRAME_UP,FRAME_LW], [FRAME_UP,FRAME_LW],...,[FRAME_UP,FRAME_LW]] 
; where:
;	- ID: 			Entry ID for lookup via CPIR.
;	- OFF_NX:		ID of the following animation DB record. We subtract from this ID the 100 so that CPIR does not find OFF_NX but ID.
;	- SIZE:			Amount of bytes in this record.
;	- DELAY:		Amount animation calls to skip (slows down animation).
;	- FRAME_UP:		Offset for the upper part of the Jetman.
;	- FRAME_LW: 	Offset for the lower part of the Jetman.
jetSpriteDB
	; Jetman is flaying.
	DB js.SDB_FLY,		js.SDB_FLY - js.SDB_SUB,		48, 5
											DB 00,10, 00,11, 01,12, 01,13, 02,11, 02,12, 03,10, 03,11, 04,12, 04,13
											DB 05,12, 05,11, 03,10, 03,11, 04,12, 04,13, 05,10, 05,12, 03,10, 03,11
											DB 04,12, 04,13, 05,12, 05,10

	; Jetman is flaying down.
	DB js.SDB_FLYD, 	js.SDB_FLYD - js.SDB_SUB,		48, 5
											DB 00,12, 00,37, 01,38, 01,37, 02,12, 02,38, 03,12, 03,37, 04,38, 04,12
											DB 05,38, 05,37, 03,37, 03,12, 04,38, 04,12, 05,37, 05,38, 03,37, 03,12
											DB 04,12, 04,37, 05,38, 05,37

	; Jetman hovers.
	DB js.SDB_HOVER, 	js.SDB_HOVER - js.SDB_SUB,		48, 10
											DB 00,14, 00,15, 01,16, 01,10, 02,11, 02,12, 03,13, 03,10, 04,11, 04,12 
											DB 05,13, 05,14, 03,15, 03,16, 04,10, 04,11, 05,12, 05,13, 03,10, 03,11
											DB 04,12, 04,13, 05,10, 05,11

	; Jetman starts walking with raised feet to avoid moving over the ground and standing still.
	DB js.SDB_WALK_ST,	js.SDB_WALK	- js.SDB_SUB,		02, 3
											DB 03,07

	; Jetman is walking.
	DB js.SDB_WALK, 	js.SDB_WALK - js.SDB_SUB,		48, 3
											DB 03,06, 03,07, 04,08, 04,09, 05,06, 05,06, 03,08, 03,09, 04,06, 04,07
											DB 05,08, 05,09, 00,06, 00,07, 01,08, 01,09, 02,06, 02,07, 03,08, 03,09 
											DB 04,06, 04,07, 05,08, 05,09

	; Jetman stands in place.
	DB js.SDB_STAND,	js.SDB_STAND - js.SDB_SUB,		46, 5
											DB 03,17, 03,18, 04,19, 04,18, 05,17, 05,19, 03,17, 03,18, 04,19, 04,17
											DB 05,19, 05,18, 00,19, 00,18, 01,17, 01,18, 02,17, 02,19, 03,18, 03,18
											DB 04,19, 05,17, 05,18

	; Jetman stands on the ground for a very short time.
	DB js.SDB_JSTAND,	js.SDB_STAND - js.SDB_SUB, 		02, 3
											DB 03,11

	; Jetman got hit.
	DB js.SDB_RIP,		js.SDB_RIP - js.SDB_SUB,		08, 5 
											DB 00,27, 01,28, 02,15, 03,29

	; Transition: walking -> flaying.
	DB js.SDB_T_WF,		js.SDB_FLY - js.SDB_SUB, 		08, 5
											DB 03,26, 04,25, 05,24, 03,23

	; Transition: flaying -> standing.
	DB js.SDB_T_FS, 	js.SDB_STAND - js.SDB_SUB,		08, 5
											DB 03,23, 04,24, 05,25, 03,26

	; Transition: flaying -> walking.
	DB js.SDB_T_FW, 	js.SDB_WALK - js.SDB_SUB,		08, 5
											DB 03,23, 04,24, 05,25, 03,26

	; Transition: kinking -> flying.
	DB js.SDB_T_KF,		js.SDB_FLY - js.SDB_SUB, 		10, 5
											DB 03,15, 04,16, 05,27, 03,28, 04,29

;----------------------------------------------------------;
;                 Rocket Sprite Data                       ;
;----------------------------------------------------------;

rocketEl
; rocket element
	ro.RO {050/*DROP_X*/, 100/*DROP_LAND_Y*/, 227/*ASSEMBLY_Y*/, _RO_DOWN_SPR_ID_D50/*SPRITE_ID*/, 60/*SPRITE_REF*/, 0/*Y*/}	; bottom element
	ro.RO {072/*DROP_X*/, 227/*DROP_LAND_Y*/, 211/*ASSEMBLY_Y*/,                 51/*SPRITE_ID*/,  56/*SPRITE_REF*/, 0/*Y*/}	; middle element
	ro.RO {140/*DROP_X*/, 227/*DROP_LAND_Y*/, 195/*ASSEMBLY_Y*/,                 52/*SPRITE_ID*/,  52/*SPRITE_REF*/, 0/*Y*/}	; top of the rocket
; fuel tank
	ro.RO {030/*DROP_X*/, 099/*DROP_LAND_Y*/, 226/*ASSEMBLY_Y*/, 43/*SPRITE_ID*/, 51/*SPRITE_REF*/, 0/*Y*/}
	ro.RO {070/*DROP_X*/, 227/*DROP_LAND_Y*/, 226/*ASSEMBLY_Y*/, 43/*SPRITE_ID*/, 51/*SPRITE_REF*/, 0/*Y*/}
	ro.RO {250/*DROP_X*/, 227/*DROP_LAND_Y*/, 226/*ASSEMBLY_Y*/, 43/*SPRITE_ID*/, 51/*SPRITE_REF*/, 0/*Y*/}
	
; Three explode DBs for three rocket elements.
rocketExplodeDB1		DB 60,60,60,60, 60,60,60,60, 30,31,32,31, 30,32,31,31, 30,31,32,33	; bottom element
rocketExplodeDB2		DB 56,56,56,56, 30,31,32,31, 30,31,32,31, 32,30,32,31, 30,31,32,33	; middle element
rocketExplodeDB3		DB 30,31,32,31, 30,31,32,31, 30,31,32,31, 30,32,31,30, 30,31,32,33	; top of the rocket

rocketExhaustDB									; Sprite IDs for exhaust
	DB 53,57,62,  57,62,53,  62,53,57,  53,62,57,  62,57,53,  57,53,62

rocketExplodeTankDB		DB 30, 31, 32, 33		; Sprite IDs for explosion.

;----------------------------------------------------------;
;                     Final Checks                         ;
;----------------------------------------------------------;
	ASSERT $$ == _EN_BANK_D69					; Data shold remain in the same bank
	ASSERT $$enemiesBankStart == _EN_BANK_D69 	; Make sure that we have configured the right bank.

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE