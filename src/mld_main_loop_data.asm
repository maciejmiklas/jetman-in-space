/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                    Game Counters                         ;
;----------------------------------------------------------;
    MODULE mld 

counter000FliFLop   DB 0                        ; Changes with every counter run from _GC_FLIP_ON_D1 to _GC_FLIP_OFF_D0 and so on.

COUNTER002_MAX      = 2                         ; Tick rate: 1/25s
counter002          DB COUNTER002_MAX

COUNTER005_MAX      = 5                         ; Tick rate: 1/10s
counter005          DB COUNTER005_MAX
counter005FliFLop   DB 0                        ; Changes with every counter run from _GC_FLIP_ON_D1 to _GC_FLIP_OFF_D0 and so on.

COUNTER008_MAX      = 8                         ; Tick rate: ±1/6s
counter008          DB COUNTER008_MAX
counter008FliFLop   DB 0                        ; Changes with every counter run from _GC_FLIP_ON_D1 to _GC_FLIP_OFF_D0 and so on.

COUNTER010_MAX      = 10                        ; Tick rate: 1/5s
counter010          DB COUNTER010_MAX

COUNTER025_MAX      = 25                        ; Tick rate: 0.5s
counter025          DB COUNTER025_MAX

COUNTER040_MAX      = 40                        ; Tick rate: 4/5s
counter040          DB COUNTER040_MAX

COUNTER050_MAX      = 50                        ; Tick rate: 1s
counter050          DB COUNTER050_MAX

COUNTER075_MAX      = 75                        ; Tick rate: 1.5s
counter075          DB COUNTER075_MAX

COUNTER150_MAX      = 150                       ; Tick rate: 3s
counter150          DB COUNTER150_MAX

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE