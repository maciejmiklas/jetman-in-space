;----------------------------------------------------------;
;                    Game Counters                         ;
;----------------------------------------------------------;
    MODULE mld 

counter000FliFLop   DB 0                        ;  Changes with every counter run from _GC_FLIP_ON_D1 to _GC_FLIP_OFF_D0 and so on

COUNTER002_MAX      = 2
counter002          DB 0
counter002FliFLop   DB 0                        ;  Changes with every counter run from _GC_FLIP_ON_D1 to _GC_FLIP_OFF_D0 and so on

COUNTER004_MAX      = 4
counter004          DB 0
counter004FliFLop   DB 0                        ;  Changes with every counter run from _GC_FLIP_ON_D1 to _GC_FLIP_OFF_D0 and so on

COUNTER006_MAX      = 6
counter006          DB 0
counter006FliFLop   DB 0                        ;  Changes with every counter run from _GC_FLIP_ON_D1 to _GC_FLIP_OFF_D0 and so on

COUNTER008_MAX      = 8
counter008          DB 0
counter008FliFLop   DB 0                        ; Changes with every counter run from _GC_FLIP_ON_D1 to _GC_FLIP_OFF_D0 and so on

COUNTER010_MAX      = 10
counter010          DB 0
counter010FliFLop   DB 0                        ;  Changes with every counter run from _GC_FLIP_ON_D1 to _GC_FLIP_OFF_D0 and so on

COUNTER015_MAX      = 15
counter015          DB 0

COUNTER020_MAX      = 20
counter020          DB 0

COUNTER040_MAX      = 40
counter040          DB 0

COUNTER080_MAX      = 80
counter080          DB 0

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE