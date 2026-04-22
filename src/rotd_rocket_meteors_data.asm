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
;            X    Y    MOVE_SPD MOVE_PAT ACTIVE
    rot.MED {300, 020, 1,       rot.MP2,     rot.AS_ACTIVE_NO} ; 0
    rot.MED {010, 000, 1,       rot.MP1,     rot.AS_ACTIVE_NO} ; 1
    rot.MED {050, 000, 1,       rot.MP1,     rot.AS_ACTIVE_NO} ; 2
    rot.MED {300, 060, 1,       rot.MP2,     rot.AS_ACTIVE_NO} ; 3
    rot.MED {150, 000, 1,       rot.MP1,     rot.AS_ACTIVE_NO} ; 4
    rot.MED {200, 000, 1,       rot.MP1,     rot.AS_ACTIVE_NO} ; 5
    rot.MED {300, 150, 1,       rot.MP2,     rot.AS_ACTIVE_NO} ; 6

; See rotd.randMovAddr
randMov1
    DB 00,1|$00, 01,1|$80, 03,1|$00, 03,1|$80, 05,1|$00, 05,1|$80, 02,1|$00, 02,1|$80, 06,1|$00, 01,1|$00, 05,1|$00, 01,1|$80, 00,1|$00
    DB 02,1|$00, 04,1|$00, 06,2|$00, 06,1|$80, 00,1|$00, 01,1|$00, 04,1|$80, 06,1|$00, 05,1|$00, 00,1|$80, 03,3|$00, 03,1|$80, 02,1|$00
    DB 05,1|$80, 06,1|$80, 01,1|$80, 04,1|$80
    ASSERT $ - randMov1 == 2 * rot.RAND_MOVE_SIZE_D30

asDeploy2
;            X    Y    MOVE_SPD MOVE_PAT     ACTIVE
    rot.MED {300, 050, 3,       rot.MP2,     rot.AS_ACTIVE_NO} ; 0
    rot.MED {010, 000, 2,       rot.MP1,     rot.AS_ACTIVE_NO} ; 1
    rot.MED {050, 000, 2,       rot.MP1,     rot.AS_ACTIVE_NO} ; 2
    rot.MED {300, 100, 3,       rot.MP2,     rot.AS_ACTIVE_NO} ; 3
    rot.MED {130, 000, 2,       rot.MP1,     rot.AS_ACTIVE_NO} ; 4
    rot.MED {180, 000, 2,       rot.MP1,     rot.AS_ACTIVE_NO} ; 5
    rot.MED {300, 200, 3,       rot.MP2,     rot.AS_ACTIVE_NO} ; 6

; See rotd.randMovAddr
randMov2
    DB 02,1|$00, 03,1|$80, 01,1|$00, 03,1|$80, 01,1|$00, 06,1|$80, 0,1|$00, 02,1|$80, 06,1|$00, 01,1|$00, 05,1|$00, 04,1|$00, 00,1|$00
    DB 02,1|$00, 04,1|$00, 05,1|$00, 06,1|$80, 00,1|$80, 02,1|$80, 04,1|$80, 00,1|$80, 05,1|$00, 00,1|$80, 03,1|$80, 03,1|$80, 02,1|$00
    DB 05,1|$80, 06,1|$80, 01,1|$80, 04,1|$80
    ASSERT $ - randMov2 == 2 * rot.RAND_MOVE_SIZE_D30

asDeploy3
;            X    Y    MOVE_SPD MOVE_PAT     ACTIVE
    rot.MED {300, 020, 2,       rot.MP2,     rot.AS_ACTIVE_NO} ; 0
    rot.MED {010, 000, 3,       rot.MP1,     rot.AS_ACTIVE_NO} ; 1
    rot.MED {300, 050, 1,       rot.MP2,     rot.AS_ACTIVE_NO} ; 2
    rot.MED {300, 120, 2,       rot.MP2,     rot.AS_ACTIVE_NO} ; 3
    rot.MED {150, 000, 2,       rot.MP1,     rot.AS_ACTIVE_NO} ; 4
    rot.MED {200, 000, 3,       rot.MP1,     rot.AS_ACTIVE_NO} ; 5
    rot.MED {300, 200, 1,       rot.MP2,     rot.AS_ACTIVE_NO} ; 6


; See rotd.randMovAddr
asDeploy4
;            X    Y    MOVE_SPD MOVE_PAT     ACTIVE
    rot.MED {300, 020, 2,       rot.MP2,     rot.AS_ACTIVE_NO} ; 0
    rot.MED {010, 000, 3,       rot.MP1,     rot.AS_ACTIVE_NO} ; 1
    rot.MED {300, 050, 5,       rot.MP2,     rot.AS_ACTIVE_NO} ; 2
    rot.MED {300, 120, 3,       rot.MP2,     rot.AS_ACTIVE_NO} ; 3
    rot.MED {150, 000, 2,       rot.MP1,     rot.AS_ACTIVE_NO} ; 4
    rot.MED {200, 000, 5,       rot.MP1,     rot.AS_ACTIVE_NO} ; 5
    rot.MED {300, 200, 4,       rot.MP2,     rot.AS_ACTIVE_NO} ; 6

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE