/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                      Rocket Data                         ;
;----------------------------------------------------------;
    MODULE rod
    ; TO USE THIS MODULE: CALL dbs.SetupRocketBank

AGND                    = 30*8
TASM                    = 200
TSID                    = _EXHAUST_SPRID_D83
TSRE                    = 17

; Level 1
ROCKET_X_L1             = 22*8
rocketElL1
; Rocket element.
    ro.RO {04*8/*DROP_X*/, 14*8/*DROP_LAND_Y*/, 234/*ASSEMBLY_Y*/, 80/*SPRITE_ID*/, 60/*SPRITE_REF*/}  ; bottom element
    ro.RO {13*8/*DROP_X*/, 20*8/*DROP_LAND_Y*/, 218/*ASSEMBLY_Y*/, 81/*SPRITE_ID*/, 56/*SPRITE_REF*/}  ; middle element
    ro.RO {18*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, 202/*ASSEMBLY_Y*/, 82/*SPRITE_ID*/, 52/*SPRITE_REF*/}  ; top of the rocket
    
; Fuel tank.
    ro.RO {03*8/*DROP_X*/, 14*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {29*8/*DROP_X*/, 09*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {31*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {09*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {25*8/*DROP_X*/, 09*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {09*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    
; Level 2
ROCKET_X_L2             = 24*8
rocketElL2
; Rocket element.
    ro.RO {07*8/*DROP_X*/, 07*8/*DROP_LAND_Y*/, 234/*ASSEMBLY_Y*/, 80/*SPRITE_ID*/, 60/*SPRITE_REF*/}  ; bottom element
    ro.RO {26*8/*DROP_X*/, 20*8/*DROP_LAND_Y*/, 218/*ASSEMBLY_Y*/, 81/*SPRITE_ID*/, 56/*SPRITE_REF*/}  ; middle element
    ro.RO {01*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, 202/*ASSEMBLY_Y*/, 82/*SPRITE_ID*/, 52/*SPRITE_REF*/}  ; top of the rocket
    
; Fuel tank.
    ro.RO {09*8/*DROP_X*/, 07*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {29*8/*DROP_X*/, 07*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {26*8/*DROP_X*/, 20*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {01*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {01*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {17*8/*DROP_X*/, 07*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}

; Level 3
ROCKET_X_L3             = 6*8
rocketElL3
; Rocket element.
    ro.RO {09*8/*DROP_X*/, 05*8/*DROP_LAND_Y*/, 234/*ASSEMBLY_Y*/, 80/*SPRITE_ID*/, 60/*SPRITE_REF*/}  ; bottom element
    ro.RO {24*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, 218/*ASSEMBLY_Y*/, 81/*SPRITE_ID*/, 56/*SPRITE_REF*/}  ; middle element
    ro.RO {13*8/*DROP_X*/, 05*8/*DROP_LAND_Y*/, 202/*ASSEMBLY_Y*/, 82/*SPRITE_ID*/, 52/*SPRITE_REF*/}  ; top of the rocket
    
; Fuel tank.
    ro.RO {05*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {31*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {12*8/*DROP_X*/, 05*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {03*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {23*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {01*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}

; Level 4
ROCKET_X_L4             = 18*8
rocketElL4
; Rocket element.
    ro.RO {06*8/*DROP_X*/, 06*8/*DROP_LAND_Y*/, 234/*ASSEMBLY_Y*/, 80/*SPRITE_ID*/, 60/*SPRITE_REF*/}  ; bottom element
    ro.RO {14*8/*DROP_X*/, 12*8/*DROP_LAND_Y*/, 218/*ASSEMBLY_Y*/, 81/*SPRITE_ID*/, 56/*SPRITE_REF*/}  ; middle element
    ro.RO {23*8/*DROP_X*/, 17*8/*DROP_LAND_Y*/, 202/*ASSEMBLY_Y*/, 82/*SPRITE_ID*/, 52/*SPRITE_REF*/}  ; top of the rocket
    
; Fuel tank.
    ro.RO {02*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {30*8/*DROP_X*/, 10*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {21*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {27*8/*DROP_X*/, 10*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {10*8/*DROP_X*/, 06*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {16*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}

; Level 5
ROCKET_X_L5             = 18*8
rocketElL5
; Rocket element.
    ro.RO {04*8/*DROP_X*/, 13*8/*DROP_LAND_Y*/, 234/*ASSEMBLY_Y*/, 80/*SPRITE_ID*/, 60/*SPRITE_REF*/}  ; bottom element
    ro.RO {12*8/*DROP_X*/, 16*8/*DROP_LAND_Y*/, 218/*ASSEMBLY_Y*/, 81/*SPRITE_ID*/, 56/*SPRITE_REF*/}  ; middle element
    ro.RO {01*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, 202/*ASSEMBLY_Y*/, 82/*SPRITE_ID*/, 52/*SPRITE_REF*/}  ; top of the rocket
    
; Fuel tank.
    ro.RO {20*8/*DROP_X*/, 23*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {31*8/*DROP_X*/, 16*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {16*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {25*8/*DROP_X*/, 16*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {09*8/*DROP_X*/, 23*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {27*8/*DROP_X*/, 23*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}

; Level 6
ROCKET_X_L6             = 8*8
rocketElL6
; Rocket element.
    ro.RO {17*8/*DROP_X*/, 16*8/*DROP_LAND_Y*/, 234/*ASSEMBLY_Y*/, 80/*SPRITE_ID*/, 60/*SPRITE_REF*/}  ; bottom element
    ro.RO {25*8/*DROP_X*/, 23*8/*DROP_LAND_Y*/, 218/*ASSEMBLY_Y*/, 81/*SPRITE_ID*/, 56/*SPRITE_REF*/}  ; middle element
    ro.RO {29*8/*DROP_X*/, 08*8/*DROP_LAND_Y*/, 202/*ASSEMBLY_Y*/, 82/*SPRITE_ID*/, 52/*SPRITE_REF*/}  ; top of the rocket
    
; Fuel tank.
    ro.RO {02*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {31*8/*DROP_X*/, 08*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {25*8/*DROP_X*/, 23*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {14*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {29*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {31*8/*DROP_X*/, 08*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}

; Level 7
ROCKET_X_L7             = 18*8
rocketElL7
; Rocket element.
    ro.RO {06*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, 234/*ASSEMBLY_Y*/, 80/*SPRITE_ID*/, 60/*SPRITE_REF*/}  ; bottom element
    ro.RO {16*8/*DROP_X*/, 05*8/*DROP_LAND_Y*/, 218/*ASSEMBLY_Y*/, 81/*SPRITE_ID*/, 56/*SPRITE_REF*/}  ; middle element
    ro.RO {31*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, 202/*ASSEMBLY_Y*/, 82/*SPRITE_ID*/, 52/*SPRITE_REF*/}  ; top of the rocket
    
; Fuel tank.
    ro.RO {02*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {05*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {12*8/*DROP_X*/, 05*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {21*5/*DROP_X*/, 05*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {27*8/*DROP_X*/, 05*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {31*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}

; Level 8
ROCKET_X_L8             =  14*8
rocketElL8
; Rocket element.
    ro.RO {22*8/*DROP_X*/, 21*8/*DROP_LAND_Y*/, 234/*ASSEMBLY_Y*/, 80/*SPRITE_ID*/, 60/*SPRITE_REF*/}  ; bottom element
    ro.RO {30*8/*DROP_X*/, 12*8/*DROP_LAND_Y*/, 218/*ASSEMBLY_Y*/, 81/*SPRITE_ID*/, 56/*SPRITE_REF*/}  ; middle element
    ro.RO {02*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, 202/*ASSEMBLY_Y*/, 82/*SPRITE_ID*/, 52/*SPRITE_REF*/}  ; top of the rocket
    
; Fuel tank.
    ro.RO {23*8/*DROP_X*/, 21*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {31*8/*DROP_X*/, 12*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {10*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {01*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {17*8/*DROP_X*/, 21*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {27*8/*DROP_X*/, 12*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}

; Level 9
ROCKET_X_L9             = 17*8
rocketElL9
; Rocket element.
    ro.RO {05*8/*DROP_X*/, 27*8/*DROP_LAND_Y*/, 234/*ASSEMBLY_Y*/, 80/*SPRITE_ID*/, 60/*SPRITE_REF*/}  ; bottom element
    ro.RO {16*8/*DROP_X*/, 14*8/*DROP_LAND_Y*/, 218/*ASSEMBLY_Y*/, 81/*SPRITE_ID*/, 56/*SPRITE_REF*/}  ; middle element
    ro.RO {34*8/*DROP_X*/, 26*8/*DROP_LAND_Y*/, 202/*ASSEMBLY_Y*/, 82/*SPRITE_ID*/, 52/*SPRITE_REF*/}  ; top of the rocket
    
; Fuel tank.
    ro.RO {02*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {06*8/*DROP_X*/, 26*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {20*8/*DROP_X*/, 14*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {30*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {24*8/*DROP_X*/, 14*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {19*8/*DROP_X*/, 14*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}

; Level 10
ROCKET_X_L10             = 19*8
rocketElL10
; Rocket element.
    ro.RO {05*8/*DROP_X*/, 24*8/*DROP_LAND_Y*/, 234/*ASSEMBLY_Y*/, 80/*SPRITE_ID*/, 60/*SPRITE_REF*/}  ; bottom element
    ro.RO {27*8/*DROP_X*/, 24*8/*DROP_LAND_Y*/, 218/*ASSEMBLY_Y*/, 81/*SPRITE_ID*/, 56/*SPRITE_REF*/}  ; middle element
    ro.RO {15*8/*DROP_X*/, 17*8/*DROP_LAND_Y*/, 202/*ASSEMBLY_Y*/, 82/*SPRITE_ID*/, 52/*SPRITE_REF*/}  ; top of the rocket
    
; Fuel tank.
    ro.RO {27*8/*DROP_X*/, 24*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {33*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {05*8/*DROP_X*/, 24*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {27*8/*DROP_X*/, 24*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {23*8/*DROP_X*/, 17*8/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    ro.RO {02*8/*DROP_X*/, AGND/*DROP_LAND_Y*/, TASM/*ASSEMBLY_Y*/, TSID/*SPRITE_ID*/, TSRE/*SPRITE_REF*/}
    
; Three explode DBs for three rocket elements.
rocketExplodeDB1        DB 60,60,60,60, 60,60,60,60, 48,50,49,50, 48,49,50,50, 48,50,49,51, 51,51,51,51, 51,51,51,51 ; bottom element
rocketExplodeDB2        DB 56,56,56,56, 48,50,49,50, 48,50,49,50, 49,48,49,50, 48,51,51,51, 51,51,51,51, 51,51,51,51 ; middle element
rocketExplodeDB3        DB 48,50,49,50, 48,50,49,50, 48,50,49,50, 51,51,51,51, 51,51,51,51, 51,51,51,51, 51,51,51,51 ; top of the rocket

rocketExplodeTankDB     DB 30, 31, 32, 33       ; Sprite IDs for explosion

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE