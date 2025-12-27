/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                     Asteroids Shower                     ;
;----------------------------------------------------------;
    MODULE rot
    ; TO USE THIS MODULE: CALL dbs.SetupRocketBank


asDeploy2
;        X    Y    MOVE_SPD MOVE_PAT ACTIVE
    ASD {300, 050, 1,       MP2,     AS_ACTIVE_NO} ; 0
    ASD {010, 000, 1,       MP1,     AS_ACTIVE_NO} ; 1
    ASD {050, 000, 2,       MP1,     AS_ACTIVE_NO} ; 2
    ASD {300, 100, 3,       MP2,     AS_ACTIVE_NO} ; 3
    ASD {130, 000, 2,       MP1,     AS_ACTIVE_NO} ; 4
    ASD {180, 000, 1,       MP1,     AS_ACTIVE_NO} ; 5
    ASD {300, 200, 2,       MP2,     AS_ACTIVE_NO} ; 6

randMov2                DB 0,1,  3,1|$80, 5,2,  3,1|$80,  2,1,  5,1,  3,1|$80,  5,1|$80,  2,1|$80,  3,1, 5,3|$80,  1,2|$80,  3,3|$80
                        DB 0,1|$80,  2,1|$80,  4,1|$80,  6,1|$80,  1,2,  3,2,  5,2,  6,3,  1,1,  3,1,  6,1,  0,1,  2,1,  5,1,  4,1
                        DB 1,1,  0,1


;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE