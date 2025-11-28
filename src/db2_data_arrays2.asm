/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                    Arrays 2 (Bank 29)                    ;
;----------------------------------------------------------;
    module db2

    ; Before using it CALL dbs.SetupArrays2Bank
spritesBankStart

;----------------------------------------------------------;
;                      Main Menu                           ;
;----------------------------------------------------------;
mainMenuEl
    mma.MENU {mma.TOP_OFS+mma.LOF+5                  /*TILE_OFFSET*/, menuTextSg/*TEXT_POINT*/, 12/*TEXT_SIZE*/, 200/*JET_X*/, 032/*JET_Y*/}  ; START GAME
    mma.MENU {mma.TOP_OFS+(1*mma.EL_DIST)+mma.LOF+4  /*TILE_OFFSET*/, menuTextLs/*TEXT_POINT*/, 14/*TEXT_SIZE*/, 208/*JET_X*/, 055/*JET_Y*/}  ; LEVEL SELECT
    mma.MENU {mma.TOP_OFS+(2*mma.EL_DIST)+mma.LOF+5  /*TILE_OFFSET*/, menuTextHs/*TEXT_POINT*/, 12/*TEXT_SIZE*/, 200/*JET_X*/, 080/*JET_Y*/}  ; HIGH SCORE
    mma.MENU {mma.TOP_OFS+(3*mma.EL_DIST)+mma.LOF+4  /*TILE_OFFSET*/, menuTextIg/*TEXT_POINT*/, 14/*TEXT_SIZE*/, 206/*JET_X*/, 104/*JET_Y*/}  ; IN GAME KEYS
    mma.MENU {mma.TOP_OFS+(4*mma.EL_DIST)+mma.LOF+6  /*TILE_OFFSET*/, menuTextGp/*TEXT_POINT*/, 10/*TEXT_SIZE*/, 192/*JET_X*/, 128/*JET_Y*/}  ; GAMEPLAY
    mma.MENU {mma.TOP_OFS+(5*mma.EL_DIST)+mma.LOF+5  /*TILE_OFFSET*/, menuTextDi/*TEXT_POINT*/, 12/*TEXT_SIZE*/, 200/*JET_X*/, 152/*JET_Y*/}  ; DIFFICULTY
MAIN_MENU_EL_SIZE       = 6

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
    SPR {10/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}

;----------------------------------------------------------;
;                      Main Menu                           ;
;----------------------------------------------------------;
menuLevelEl
    mml.MLS  {/*TILE_OFFSET*/, 045/*JET_X*/, 020/*JET_Y*/}  ; Level 1
    mml.MLS  {/*TILE_OFFSET*/, 155/*JET_X*/, 020/*JET_Y*/}  ; Level 2
    mml.MLS  {/*TILE_OFFSET*/, 095/*JET_X*/, 075/*JET_Y*/}  ; Level 3
    mml.MLS  {/*TILE_OFFSET*/, 040/*JET_X*/, 120/*JET_Y*/}  ; Level 4
    mml.MLS  {/*TILE_OFFSET*/, 155/*JET_X*/, 125/*JET_Y*/}  ; Level 5
    mml.MLS  {/*TILE_OFFSET*/, 090/*JET_X*/, 210/*JET_Y*/}  ; Level 6
    mml.MLS  {/*TILE_OFFSET*/, 255/*JET_X*/, 160/*JET_Y*/}  ; Level 7
    mml.MLS  {/*TILE_OFFSET*/, 255/*JET_X*/, 020/*JET_Y*/}  ; Level 8
    mml.MLS  {/*TILE_OFFSET*/, 205/*JET_X*/, 075/*JET_Y*/}  ; Level 9
    mml.MLS  {/*TILE_OFFSET*/, 180/*JET_X*/, 215/*JET_Y*/}  ; Level 10

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
TASM                    = 200
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
    ro.RO {04*8/*DROP_X*/, 13*8/*DROP_LAND_Y*/, 234/*ASSEMBLY_Y*/, 80/*SPRITE_ID*/, 60/*SPRITE_REF*/, 0/*Y*/}  ; bottom element
    ro.RO {12*8/*DROP_X*/, 16*8/*DROP_LAND_Y*/, 218/*ASSEMBLY_Y*/, 81/*SPRITE_ID*/, 56/*SPRITE_REF*/, 0/*Y*/}  ; middle element
    ro.RO {01*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, 202/*ASSEMBLY_Y*/, 82/*SPRITE_ID*/, 52/*SPRITE_REF*/, 0/*Y*/}  ; top of the rocket
    
; Fuel tank.
    ro.RO {20*8/*DROP_X*/, 23*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {31*8/*DROP_X*/, 16*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {16*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {25*8/*DROP_X*/, 16*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {09*8/*DROP_X*/, 23*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {27*8/*DROP_X*/, 23*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}

; Level 6
rocketAssemblyXL6       DB 08*8
rocketElL6
; Rocket element.
    ro.RO {17*8/*DROP_X*/, 16*8/*DROP_LAND_Y*/, 234/*ASSEMBLY_Y*/, 80/*SPRITE_ID*/, 60/*SPRITE_REF*/, 0/*Y*/}  ; bottom element
    ro.RO {25*8/*DROP_X*/, 23*8/*DROP_LAND_Y*/, 218/*ASSEMBLY_Y*/, 81/*SPRITE_ID*/, 56/*SPRITE_REF*/, 0/*Y*/}  ; middle element
    ro.RO {29*8/*DROP_X*/, 08*8/*DROP_LAND_Y*/, 202/*ASSEMBLY_Y*/, 82/*SPRITE_ID*/, 52/*SPRITE_REF*/, 0/*Y*/}  ; top of the rocket
    
; Fuel tank.
    ro.RO {02*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {31*8/*DROP_X*/, 08*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {25*8/*DROP_X*/, 23*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {14*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {29*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {31*8/*DROP_X*/, 08*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}

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
rocketAssemblyXL8       DB 14*8
rocketElL8
; Rocket element.
    ro.RO {22*8/*DROP_X*/, 21*8/*DROP_LAND_Y*/, 234/*ASSEMBLY_Y*/, 80/*SPRITE_ID*/, 60/*SPRITE_REF*/, 0/*Y*/}  ; bottom element
    ro.RO {30*8/*DROP_X*/, 12*8/*DROP_LAND_Y*/, 218/*ASSEMBLY_Y*/, 81/*SPRITE_ID*/, 56/*SPRITE_REF*/, 0/*Y*/}  ; middle element
    ro.RO {02*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, 202/*ASSEMBLY_Y*/, 82/*SPRITE_ID*/, 52/*SPRITE_REF*/, 0/*Y*/}  ; top of the rocket
    
; Fuel tank.
    ro.RO {23*8/*DROP_X*/, 21*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {31*8/*DROP_X*/, 12*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {10*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {01*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {17*8/*DROP_X*/, 21*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {27*8/*DROP_X*/, 12*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}

; Level 9
rocketAssemblyXL9       DB 17*8
rocketElL9
; Rocket element.
    ro.RO {03*8/*DROP_X*/, 20*8/*DROP_LAND_Y*/, 234/*ASSEMBLY_Y*/, 80/*SPRITE_ID*/, 60/*SPRITE_REF*/, 0/*Y*/}  ; bottom element
    ro.RO {25*8/*DROP_X*/, 11*8/*DROP_LAND_Y*/, 218/*ASSEMBLY_Y*/, 81/*SPRITE_ID*/, 56/*SPRITE_REF*/, 0/*Y*/}  ; middle element
    ro.RO {27*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, 202/*ASSEMBLY_Y*/, 82/*SPRITE_ID*/, 52/*SPRITE_REF*/, 0/*Y*/}  ; top of the rocket
    
; Fuel tank.
    ro.RO {06*8/*DROP_X*/, 20*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {08*8/*DROP_X*/, 20*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {27*8/*DROP_X*/, 11*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {02*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {23*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}
    ro.RO {30*8/*DROP_X*/, 11*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/, 0/*Y*/}

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
    SPR {10/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
    SPR {11/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
    SPR {12/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
    SPR {13/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
    SPR {14/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
    SPR {15/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
    SPR {16/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
    SPR {17/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
    SPR {18/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
    SPR {19/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
    SPR {91/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
    SPR {92/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
    SPR {93/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
    SPR {94/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
    SPR {95/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}
SHOTS_SIZE              = 15                   ; Amount of shots that can be simultaneously fired. Max is limited by #shotsXX

;----------------------------------------------------------;
;                       Game Pickups                       ;
;----------------------------------------------------------;

; Pickups for Level 1
pickupsL1
    DB pi.PI_SPR_DIAMOND
PICKUPS_L1_SIZE             = 1

; Pickups for Level 2
pickupsL2
    DB pi.PI_SPR_DIAMOND, pi.PI_SPR_GUN, pi.PI_SPR_DIAMOND, pi.PI_SPR_GUN, pi.PI_SPR_DIAMOND, pi.PI_SPR_GUN, pi.PI_SPR_DIAMOND
PICKUPS_L2_SIZE             = 7

; Pickups for Level 3
pickupsL3
    DB pi.PI_SPR_LIFE, pi.PI_SPR_GUN, pi.PI_SPR_DIAMOND, pi.PI_SPR_GUN, pi.PI_SPR_GRENADE, pi.PI_SPR_GUN, pi.PI_SPR_GRENADE, pi.PI_SPR_GUN
    DB pi.PI_SPR_DIAMOND, pi.PI_SPR_GUN
PICKUPS_L3_SIZE             = 10

; Pickups for Level 4
pickupsL4
    DB  pi.PI_SPR_LIFE, pi.PI_SPR_DIAMOND, pi.PI_SPR_GUN, pi.PI_SPR_GRENADE, pi.PI_SPR_GUN, pi.PI_SPR_STRAWBERRY, pi.PI_SPR_GUN
    DB pi.PI_SPR_DIAMOND,  pi.PI_SPR_GUN, pi.PI_SPR_STRAWBERRY, pi.PI_SPR_GUN, pi.PI_SPR_DIAMOND
PICKUPS_L4_SIZE             = 12

; Pickups for Level 5
pickupsL5
    DB pi.PI_SPR_GUN, pi.PI_SPR_STRAWBERRY, pi.PI_SPR_GUN, pi.PI_SPR_GRENADE, pi.PI_SPR_GUN, pi.PI_SPR_DIAMOND, pi.PI_SPR_GUN
    DB pi.PI_SPR_GRENADE,  pi.PI_SPR_GUN, pi.PI_SPR_JAR
PICKUPS_L5_SIZE             = 10

; Pickups for Level 6-10
pickupsL6
    DB pi.PI_SPR_GUN, pi.PI_FREEZE_ENEMIES, pi.PI_SPR_GUN, pi.PI_SPR_DIAMOND, pi.PI_SPR_GUN, pi.PI_SPR_GRENADE, pi.PI_SPR_GUN
    DB pi.PI_SPR_STRAWBERRY, pi.PI_SPR_GUN, pi.PI_SPR_DIAMOND, pi.PI_SPR_GUN, pi.PI_SPR_GUN, pi.PI_SPR_GRENADE, pi.PI_SPR_GUN, pi.PI_SPR_JAR
    DB pi.PI_SPR_GUN, pi.PI_FREEZE_ENEMIES, pi.PI_SPR_GUN, pi.PI_SPR_GRENADE,  pi.PI_SPR_GUN, pi.PI_SPR_LIFE
PICKUPS_L6_SIZE             = 21

;----------------------------------------------------------;
;                          Platforms                       ;
;----------------------------------------------------------;
; [amount of platforms], #PLA,..., #PLA]. Platforms are tiles. Each tile has 8x8 pixels.

; The "close margin" has to be smaller on the left/right than the "hit margin" and larger on the top/bottom than the "hit margin".
; We will first recognize whether an enemy should fly along the platform and, after that, whether it is a hit. If the "close margin" 
; on the left were larger than the hit margin, the enemy would never hit the platform from the left, it would fly through it. The same is 
; true for "top margin". Here, the "close margin" has to be larger so that the enemy first starts flying along the platform and does not 
; hit it first.
closeMargin     pl.PLAM { 12/*X_LEFT*/, 06/*X_RIGHT*/, 15/*Y_TOP*/, 06/*Y_BOTTOM*/}
spriteHitMargin pl.PLAM { 13/*X_LEFT*/, 08/*X_RIGHT*/, 13/*Y_TOP*/, 04/*Y_BOTTOM*/}
shotHitMargin   pl.PLAM { 10/*X_LEFT*/, 10/*X_RIGHT*/, 07/*Y_TOP*/, 00/*Y_BOTTOM*/}
jetHitMargin    pl.PLAM { 15/*X_LEFT*/, 07/*X_RIGHT*/, 23/*Y_TOP*/, 10/*Y_BOTTOM*/}
bounceMargin    pl.PLAM { 15/*X_LEFT*/, 10/*X_RIGHT*/, 15/*Y_TOP*/, 06/*Y_BOTTOM*/}

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
    pl.PLA {04*8/*X_LEFT*/, 14*8/*X_RIGHT*/, 17*8/*Y_TOP*/, 17*8/*Y_BOTTOM*/}
    pl.PLA {03*8/*X_LEFT*/, 16*8/*X_RIGHT*/, 24*8/*Y_TOP*/, 24*8/*Y_BOTTOM*/}
    pl.PLA {21*8/*X_LEFT*/, 32*8/*X_RIGHT*/, 17*8/*Y_TOP*/, 17*8/*Y_BOTTOM*/}
    pl.PLA {20*8/*X_LEFT*/, 35*8/*X_RIGHT*/, 24*8/*Y_TOP*/, 24*8/*Y_BOTTOM*/}
platformsSizeL5         DB 4

; Level 6
platformsL6
    pl.PLA {05*8/*X_LEFT*/, 06*8/*X_RIGHT*/, 04*8/*Y_TOP*/, 07*8/*Y_BOTTOM*/}
    pl.PLA {05*8/*X_LEFT*/, 06*8/*X_RIGHT*/, 12*8/*Y_TOP*/, 17*8/*Y_BOTTOM*/}
    pl.PLA {05*8/*X_LEFT*/, 06*8/*X_RIGHT*/, 22*8/*Y_TOP*/, 25*8/*Y_BOTTOM*/}

    pl.PLA {16*8/*X_LEFT*/, 23*8/*X_RIGHT*/, 17*8/*Y_TOP*/, 17*8/*Y_BOTTOM*/}
    pl.PLA {27*8/*X_LEFT*/, 32*8/*X_RIGHT*/, 09*8/*Y_TOP*/, 09*8/*Y_BOTTOM*/}
    pl.PLA {24*8/*X_LEFT*/, 28*8/*X_RIGHT*/, 24*8/*Y_TOP*/, 24*8/*Y_BOTTOM*/}

    pl.PLA {35*8/*X_LEFT*/, 36*8/*X_RIGHT*/, 04*8/*Y_TOP*/, 12*8/*Y_BOTTOM*/}
    pl.PLA {35*8/*X_LEFT*/, 36*8/*X_RIGHT*/, 17*8/*Y_TOP*/, 25*8/*Y_BOTTOM*/}
platformsSizeL6         DB 8

; Level 7
platformsL7
    pl.PLA {10*8/*X_LEFT*/, 27*8/*X_RIGHT*/, 06*8/*Y_TOP*/, 06*8/*Y_BOTTOM*/}
    
    pl.PLA {14*8/*X_LEFT*/, 15*8/*X_RIGHT*/, 12*8/*Y_TOP*/, 12*8/*Y_BOTTOM*/}
    pl.PLA {21*8/*X_LEFT*/, 22*8/*X_RIGHT*/, 17*8/*Y_TOP*/, 17*8/*Y_BOTTOM*/}

    pl.PLA {10*8/*X_LEFT*/, 10*8/*X_RIGHT*/, 06*8/*Y_TOP*/, 08*8/*Y_BOTTOM*/}
    pl.PLA {10*8/*X_LEFT*/, 10*8/*X_RIGHT*/, 11*8/*Y_TOP*/, 13*8/*Y_BOTTOM*/}
    pl.PLA {10*8/*X_LEFT*/, 10*8/*X_RIGHT*/, 16*8/*Y_TOP*/, 20*8/*Y_BOTTOM*/}
    pl.PLA {10*8/*X_LEFT*/, 10*8/*X_RIGHT*/, 23*8/*Y_TOP*/, 26*8/*Y_BOTTOM*/}

    pl.PLA {27*8/*X_LEFT*/, 27*8/*X_RIGHT*/, 06*8/*Y_TOP*/, 08*8/*Y_BOTTOM*/}
    pl.PLA {27*8/*X_LEFT*/, 27*8/*X_RIGHT*/, 11*8/*Y_TOP*/, 13*8/*Y_BOTTOM*/}
    pl.PLA {27*8/*X_LEFT*/, 27*8/*X_RIGHT*/, 16*8/*Y_TOP*/, 20*8/*Y_BOTTOM*/}
    pl.PLA {27*8/*X_LEFT*/, 27*8/*X_RIGHT*/, 23*8/*Y_TOP*/, 26*8/*Y_BOTTOM*/}
platformsSizeL7         DB 11

; Level 8
platformsL8
    pl.PLA {17*8/*X_LEFT*/, 26*8/*X_RIGHT*/, 22*8/*Y_TOP*/, 22*8/*Y_BOTTOM*/}
    pl.PLA {26*8/*X_LEFT*/, 32*8/*X_RIGHT*/, 13*8/*Y_TOP*/, 13*8/*Y_BOTTOM*/}
platformsSizeL8         DB 2

; Level 9
platformsL9
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
platformsSizeL9         DB 11

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

LEVEL_FILE_POS          = 7                     ; Position of a level number (00-99) in the file name

; Tiles for level intro
introTilesFileName      DB "assets/00/intro_0.map",0
introSecondFileSize     DW 0                    ; Will be set when loading particular level, now is 0

stTilesFileName         DB "assets/00/stars_0.map",0
TI16K_FILE_NR_POS       = 8

; Tiles for in-game platforms
plTileFileName          DB "assets/00/tiles.map",0

; Sprite file
sprFileName             DB "assets/00/sprites_0.spr",0
SPR_FILE_NR_POS         = 10
SPR_FILE_BYT_D8192      = _BANK_BYTES_D8192

; Tile sprite file
sprTileFileName         DB "assets/00/tiles.spr",0
SPR_TILE_BYT_D6400      = 6400
    assert SPR_TILE_BYT_D6400 < ti.TI_DEF_MAX_D6910

; Level background file
lbFileName              DB "assets/00/bg_0.nxi",0
LB_FILE_IMG_POS         = 13                    ; Position of a image part number (0-9) in the file name

introPalFileName        DB "assets/01/intro.nxp",0
easyPalFileName         DB "assets/ma/easy.nxp",0
hardPalFileName         DB "assets/ma/hard.nxp",0

; Level background palette file
lbpFileName             DB "assets/00/bg.nxp",0

; Level music file
sndFileName             DB "assets/snd/00.pt3",0
SND_NR_POS              = 11                    ; Position of song number (01-99) in the file name

; Level intro file
liBgFileName            DB "assets/00/intro_0.nxi",0
LI_BG_FILE_IMG_POS      = 16                    ; Position of a image part number (0-9) in the file name

menuEasyBgFileName      DB "assets/ma/easy_0.nxi",0
MENU_EASY_BG_POS        = 15                    ; Position of a image part number (0-9) in the file name

menuHardBgFileName      DB "assets/ma/hard_0.nxi",0
MENU_HARD_BG_POS        = 15                    ; Position of a image part number (0-9) in the file name

mmgTileFileName         DB "assets/mg/gameplay.map",0
mmkTileFileName         DB "assets/mk/keys.map",0

; Level select background
levelSelectBgFileName   DB "assets/ml/ls_00_0.nxi",0
levelSelectPalFileName  DB "assets/ml/ls_00.nxp",0
LS_BG_LEVEL_POS         = 13
LS_BG_IMG_POS           = 16

;----------------------------------------------------------;
;                        Final Checks                      ;
;----------------------------------------------------------;

    ASSERT $$ == dbs.ARR2_BANK_S7_D29            ; Data should remain in the same bank
    ASSERT $$spritesBankStart == dbs.ARR2_BANK_S7_D29 ; Make sure that we have configured the right bank
    ASSERT $ < _RAM_SLOT7_END_HFFFF             ; Data should remain within slot 7 address space

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE