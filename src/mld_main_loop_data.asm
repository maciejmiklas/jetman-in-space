;----------------------------------------------------------;
;                    Game Counters                         ;
;----------------------------------------------------------;
    MODULE mld 

counter000FliFLop   DB 0                        ; Changes with every counter run from _GC_FLIP_ON_D1 to _GC_FLIP_OFF_D0 and so on.

COUNTER002_MAX      = 2                         ; Tick rate: 1/25s
counter002          DB 0
counter002FliFLop   DB 0                        ; Changes with every counter run from _GC_FLIP_ON_D1 to _GC_FLIP_OFF_D0 and so on.

COUNTER005_MAX      = 5                         ; Tick rate: 1/10s
counter005          DB 0
counter005FliFLop   DB 0                        ; Changes with every counter run from _GC_FLIP_ON_D1 to _GC_FLIP_OFF_D0 and so on.

COUNTER008_MAX      = 8                         ; Tick rate: ±1/6s
counter008          DB 0
counter008FliFLop   DB 0                        ; Changes with every counter run from _GC_FLIP_ON_D1 to _GC_FLIP_OFF_D0 and so on.

COUNTER010_MAX      = 10                        ; Tick rate: 1/5s
counter010          DB 0
counter010FliFLop   DB 0                        ; Changes with every counter run from _GC_FLIP_ON_D1 to _GC_FLIP_OFF_D0 and so on.

COUNTER025_MAX      = 25                        ; Tick rate: 0.5s
counter025          DB 0

COUNTER040_MAX      = 40                        ; Tick rate: 4/5s
counter040          DB 0

COUNTER050_MAX      = 50                        ; Tick rate: 1s
counter050          DB 0

COUNTER075_MAX      = 80                        ; Tick rate: 1.5s
counter075          DB 0

COUNTER150_MAX      = 150                       ; Tick rate: 3s
counter150          DB 0

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE