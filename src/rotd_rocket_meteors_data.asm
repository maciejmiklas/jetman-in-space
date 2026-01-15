/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                     Meteor Shower                        ;
;----------------------------------------------------------;
    MODULE rotd
    ; TO USE THIS MODULE: CALL dbs.SetupRocketBank


asDeploy1
;        X    Y    MOVE_SPD MOVE_PAT ACTIVE
    rot.ASD {300, 020, 1,       rot.MP2,     rot.AS_ACTIVE_NO} ; 0
    rot.ASD {010, 000, 1,       rot.MP1,     rot.AS_ACTIVE_NO} ; 1
    rot.ASD {050, 000, 1,       rot.MP1,     rot.AS_ACTIVE_NO} ; 2
    rot.ASD {300, 060, 1,       rot.MP2,     rot.AS_ACTIVE_NO} ; 3
    rot.ASD {150, 000, 1,       rot.MP1,     rot.AS_ACTIVE_NO} ; 4
    rot.ASD {200, 000, 1,       rot.MP1,     rot.AS_ACTIVE_NO} ; 5
    rot.ASD {300, 150, 1,       rot.MP2,     rot.AS_ACTIVE_NO} ; 6

; See rotd.randMovAddr
randMov1                DB 0,1,  0,1|$80, 3,1,  3,1|$80,  5,1,  5,1|$80,  2,1,  2,1|$80,  6,1,  1,1, 5,1,  5,1|$80,  0,1
                        DB 2,1,  4,1,  6,2,  6,1|$80,  0,1,  1,1,  4,1,  6,1,  5,1,  0,1|$80,  3,3,  3,1|$80,  2,1,  5,2,  6,1|$80
                        DB 3,1|$80,  4,1|$80

asDeploy2
;        X    Y    MOVE_SPD MOVE_PAT ACTIVE
    rot.ASD {300, 050, 1,       rot.MP2,     rot.AS_ACTIVE_NO} ; 0
    rot.ASD {010, 000, 1,       rot.MP1,     rot.AS_ACTIVE_NO} ; 1
    rot.ASD {050, 000, 2,       rot.MP1,     rot.AS_ACTIVE_NO} ; 2
    rot.ASD {300, 100, 3,       rot.MP2,     rot.AS_ACTIVE_NO} ; 3
    rot.ASD {130, 000, 2,       rot.MP1,     rot.AS_ACTIVE_NO} ; 4
    rot.ASD {180, 000, 1,       rot.MP1,     rot.AS_ACTIVE_NO} ; 5
    rot.ASD {300, 200, 2,       rot.MP2,     rot.AS_ACTIVE_NO} ; 6

; See rotd.randMovAddr
randMov2                DB 0,1,  3,1|$80, 5,2,  3,1|$80,  2,1,  5,1,  3,1|$80,  5,1|$80,  2,1|$80,  3,1, 5,3|$80,  1,2|$80,  3,3|$80
                        DB 0,1|$80,  2,1|$80,  4,1|$80,  6,1,  1,2,  3,2,  5,2,  6,3,  1,2,  3,1,  6,1|$80,  0,1,  2,2,  5,1|$80,  4,2
                        DB 1,1,  0,2

asDeploy3
;        X    Y    MOVE_SPD MOVE_PAT ACTIVE
    rot.ASD {300, 020, 1,       rot.MP2,     rot.AS_ACTIVE_NO} ; 0
    rot.ASD {010, 000, 2,       rot.MP1,     rot.AS_ACTIVE_NO} ; 1
    rot.ASD {300, 050, 1,       rot.MP2,     rot.AS_ACTIVE_NO} ; 2
    rot.ASD {300, 120, 2,       rot.MP2,     rot.AS_ACTIVE_NO} ; 3
    rot.ASD {150, 000, 1,       rot.MP1,     rot.AS_ACTIVE_NO} ; 4
    rot.ASD {200, 000, 2,       rot.MP1,     rot.AS_ACTIVE_NO} ; 5
    rot.ASD {300, 200, 1,       rot.MP2,     rot.AS_ACTIVE_NO} ; 6

randMov3                 DB 0,2,  3,2,  5,2,  0,1|$80,  3,2|$80,  5,2|$80,  1,1,  2,1,  6,1,  1,1|$80,  2,1|$80,  4,1|$80 
                        DB 0,5|$80,  1,5|$80,  2,5|$80,  3,5|$80,  4,5|$80,  5,5|$80,  6,5|$80
                        DB 0,2, 2,2, 1,1, 3,2, 4,1, 5,2, 6,1, 0,1, 3,1, 5,1

; See rotd.randMovAddr
asDeploy4
;        X    Y    MOVE_SPD MOVE_PAT ACTIVE
    rot.ASD {300, 020, 2,       rot.MP2,     rot.AS_ACTIVE_NO} ; 0
    rot.ASD {010, 000, 3,       rot.MP1,     rot.AS_ACTIVE_NO} ; 1
    rot.ASD {300, 050, 1,       rot.MP2,     rot.AS_ACTIVE_NO} ; 2
    rot.ASD {300, 120, 3,       rot.MP2,     rot.AS_ACTIVE_NO} ; 3
    rot.ASD {150, 000, 2,       rot.MP1,     rot.AS_ACTIVE_NO} ; 4
    rot.ASD {200, 000, 1,       rot.MP1,     rot.AS_ACTIVE_NO} ; 5
    rot.ASD {300, 200, 4,       rot.MP2,     rot.AS_ACTIVE_NO} ; 6

randMov4                DB 0,2,  3,2,  5,2,  0,2|$80,  3,2|$80,  5,2|$80,  1,1,  2,1,  4,1,  6,1|$80,  2,1|$80,  4,1|$80 
                        DB 1,1|$80,  0,1,  2,1|$80,  5,1, 5,1,  5,1|$80,  6,1|$80
                        DB 0,2, 1,2, 2,3, 3,2, 4,1, 5,3, 6,2, 0,1, 3,2, 5,3

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE