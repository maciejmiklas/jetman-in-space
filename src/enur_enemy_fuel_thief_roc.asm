/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;           Fuel Thief and Rocket Integragion              ;
;----------------------------------------------------------;
    MODULE enur

;----------------------------------------------------------;
;                      LoadRocketState                     ;
;----------------------------------------------------------;
LoadRocketState

    dbs.SetupRocketBank                         ; Setup rocket bank to load data.
    LD A, (ro.rocketState)
    LD B, A

    CALL dbs.SetupEnemyDataBank                 ; Setup enemy bank jump back there.

    LD A,B
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  LoadRocketElementCnt                    ;
;----------------------------------------------------------;
LoadRocketElementCnt

    dbs.SetupRocketBank                         ; Setup rocket bank to load data.

    LD A, (roa.rocketElementCnt)
    LD B, A

    CALL dbs.SetupEnemyDataBank                 ; Setup enemy bank jump back there.

    LD A, B

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     LoadDropNextDelay                    ;
;----------------------------------------------------------;
LoadDropNextDelay

    dbs.SetupRocketBank                         ; Setup rocket bank to load data.

    
    LD A, (roa.dropNextDelay)
    LD B, A

    CALL dbs.SetupEnemyDataBank                 ; Setup enemy bank jump back there.

    LD A, B

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     LoadRocAssemblyX                     ;
;----------------------------------------------------------;
LoadRocAssemblyX

    dbs.SetupRocketBank                         ; Setup rocket bank to load data.

    LD A, (roa.rocAssemblyX)
    LD B, A

    CALL dbs.SetupEnemyDataBank                 ; Setup enemy bank jump back there.

    LD A, B

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  RemoveRocketElement                     ;
;----------------------------------------------------------;
RemoveRocketElement

    dbs.SetupRocketBank                         ; Setup rocket bank to load data.

    CALL roa.RemoveRocketElement

    CALL dbs.SetupEnemyDataBank                 ; Setup enemy bank jump back there.

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    ResetDropNextDelay                    ;
;----------------------------------------------------------;
ResetDropNextDelay

    dbs.SetupRocketBank                         ; Setup rocket bank to load data.

    XOR A
    LD (roa.dropNextDelay), A

    CALL dbs.SetupEnemyDataBank                 ; Setup enemy bank jump back there.

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE