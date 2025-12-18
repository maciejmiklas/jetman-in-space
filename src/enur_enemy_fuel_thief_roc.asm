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

    CALL dbs.SetupRocketBank                    ; Setup rocket bank to load data.

    LD A, (ro.rocketState)

    CALL dbs.SetupPatternEnemyBank              ; Setup enemy bank jump back there.

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  LoadRocketElementCnt                    ;
;----------------------------------------------------------;
LoadRocketElementCnt

    CALL dbs.SetupRocketBank                    ; Setup rocket bank to load data.

    LD A, (roa.rocketElementCnt)

    CALL dbs.SetupPatternEnemyBank              ; Setup enemy bank jump back there.

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     LoadDropNextDelay                    ;
;----------------------------------------------------------;
LoadDropNextDelay

    CALL dbs.SetupRocketBank                    ; Setup rocket bank to load data.

    LD A, (roa.dropNextDelay)

    CALL dbs.SetupPatternEnemyBank              ; Setup enemy bank jump back there.

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     LoadRocAssemblyX                     ;
;----------------------------------------------------------;
LoadRocAssemblyX

    CALL dbs.SetupRocketBank                    ; Setup rocket bank to load data.

    LD A, (roa.rocAssemblyX)

    CALL dbs.SetupPatternEnemyBank              ; Setup enemy bank jump back there.

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  RemoveRocketElement                     ;
;----------------------------------------------------------;
RemoveRocketElement

    CALL dbs.SetupRocketBank                    ; Setup rocket bank to load data.

    CALL roa.RemoveRocketElement

    CALL dbs.SetupPatternEnemyBank              ; Setup enemy bank jump back there.

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    ResetDropNextDelay                    ;
;----------------------------------------------------------;
ResetDropNextDelay

    CALL dbs.SetupRocketBank                    ; Setup rocket bank to load data.

    XOR A
    LD (roa.dropNextDelay), A

    CALL dbs.SetupPatternEnemyBank              ; Setup enemy bank jump back there.

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE