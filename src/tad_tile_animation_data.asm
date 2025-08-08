;----------------------------------------------------------;
;                   Tile Animation Data                    ;
;----------------------------------------------------------;
    ; ### TO USE THIS MODULE: CALL dbs.SetupTileAnimationBank ###

    MODULE tad

; ##############################################
; Level 8
EMP                     = 198
tilemapAnimationRow1L8
    DB 35
    TF{1162*2/*POS*/, 135/*TID*/, $70/*PAL*/}   ; Torch A - frame 1
    TF{1132*2/*POS*/, 133/*TID*/, $70/*PAL*/}   ; Torch B - frame 1
    TF{1136*2/*POS*/, 137/*TID*/, $70/*PAL*/}   ; Torch C - frame 3
    TF{1041*2/*POS*/, 084/*TID*/, $80/*PAL*/}   ; Bat A - frame 3
    TF{1186*2/*POS*/, 081/*TID*/, $80/*PAL*/}   ; Bat B - frame 1
    TF{0393*2/*POS*/, 080/*TID*/, $80/*PAL*/}   ; Bat C - frame 2
    TF{1012*2/*POS*/, 084/*TID*/, $80/*PAL*/}   ; Bat D - frame 3
    TF{1056*2/*POS*/, 066/*TID*/, $80/*PAL*/}   ; Bat E - frame 1
    TF{0780*2/*POS*/, 067/*TID*/, $80/*PAL*/}   ; Bat F - frame 2
    TF{0979*2/*POS*/, 070/*TID*/, $80/*PAL*/}   ; Bat G - frame 3

    TF{1063*2/*POS*/, 067/*TID*/, $80/*PAL*/}   ; Bat H - frame 2
    TF{1116*2/*POS*/, 066/*TID*/, $80/*PAL*/}   ; Bat I - frame 1
    TF{0427*2/*POS*/, 066/*TID*/, $80/*PAL*/}   ; Bat J - frame 1
    TF{0963*2/*POS*/, 066/*TID*/, $80/*PAL*/}   ; Bat K - frame 1
    TF{1201*2/*POS*/, 117/*TID*/, $80/*PAL*/}   ; Grass A - frame 1
    TF{1202*2/*POS*/, 124/*TID*/, $80/*PAL*/}   ; Grass B - frame 2
    TF{0864*2/*POS*/, 118/*TID*/, $80/*PAL*/}   ; Grass C - frame 1
    TF{0510*2/*POS*/, 118/*TID*/, $80/*PAL*/}   ; Grass E - frame 1
    TF{0507*2/*POS*/, 117/*TID*/, $80/*PAL*/}   ; Grass F - frame 1
    TF{1231*2/*POS*/, 170/*TID*/, $70/*PAL*/}   ; Campfire - frame 1

    TF{1232*2/*POS*/, 171/*TID*/, $70/*PAL*/}   ; Campfire - frame 1
    TF{1191*2/*POS*/, 152/*TID*/, $70/*PAL*/}   ; Campfire - frame 1
    TF{1192*2/*POS*/, 153/*TID*/, $70/*PAL*/}   ; Campfire - frame 1
    TF{1112*2/*POS*/, EMP/*TID*/, $70/*PAL*/}   ; Campfire - frame 1
    TF{0941*2/*POS*/, 104/*TID*/, $80/*PAL*/}   ; Water - frame 1
    TF{0981*2/*POS*/, 106/*TID*/, $80/*PAL*/}   ; Water - frame 1
    TF{1021*2/*POS*/, 104/*TID*/, $80/*PAL*/}   ; Water - frame 1
    TF{1061*2/*POS*/, 106/*TID*/, $80/*PAL*/}   ; Water - frame 1
    TF{1101*2/*POS*/, 104/*TID*/, $80/*PAL*/}   ; Water - frame 1
    TF{1141*2/*POS*/, 106/*TID*/, $80/*PAL*/}   ; Water - frame 1

    TF{1181*2/*POS*/, 104/*TID*/, $80/*PAL*/}   ; Water - frame 1
    TF{1008*2/*POS*/, 152/*TID*/, $70/*PAL*/}   ; Smoke - frame 1
    TF{0928*2/*POS*/, EMP/*TID*/, $70/*PAL*/}   ; Smoke - frame 4
    TF{1165*2/*POS*/, 147/*TID*/, $70/*PAL*/}   ; Windows - frame 1
    TF{1169*2/*POS*/, 147/*TID*/, $70/*PAL*/}   ; Windows - frame 1

tilemapAnimationRow2L8
    DB 35
    TF{1162*2/*POS*/, 138/*TID*/, $70/*PAL*/}   ; Torch A - frame 2
    TF{1132*2/*POS*/, 136/*TID*/, $70/*PAL*/}   ; Torch B - frame 2
    TF{1136*2/*POS*/, 136/*TID*/, $70/*PAL*/}   ; Torch C - frame 2
    TF{1041*2/*POS*/, 081/*TID*/, $80/*PAL*/}   ; Bat A - frame 1
    TF{1186*2/*POS*/, 080/*TID*/, $80/*PAL*/}   ; Bat B - frame 2
    TF{0393*2/*POS*/, 084/*TID*/, $80/*PAL*/}   ; Bat C - frame 3
    TF{1012*2/*POS*/, 081/*TID*/, $80/*PAL*/}   ; Bat D - frame 1
    TF{1056*2/*POS*/, 067/*TID*/, $80/*PAL*/}   ; Bat E - frame 2
    TF{0780*2/*POS*/, 070/*TID*/, $80/*PAL*/}   ; Bat F - frame 3
    TF{0979*2/*POS*/, 066/*TID*/, $80/*PAL*/}   ; Bat G - frame 1

    TF{1063*2/*POS*/, 070/*TID*/, $80/*PAL*/}   ; Bat H - frame 3
    TF{1116*2/*POS*/, 067/*TID*/, $80/*PAL*/}   ; Bat I - frame 2
    TF{0427*2/*POS*/, 067/*TID*/, $80/*PAL*/}   ; Bat J - frame 2
    TF{0963*2/*POS*/, 067/*TID*/, $80/*PAL*/}   ; Bat K - frame 2
    TF{1201*2/*POS*/, 120/*TID*/, $80/*PAL*/}   ; Grass A - frame 2
    TF{1202*2/*POS*/, 125/*TID*/, $80/*PAL*/}   ; Grass B - frame 3
    TF{0864*2/*POS*/, 124/*TID*/, $80/*PAL*/}   ; Grass C - frame 2
    TF{0510*2/*POS*/, 124/*TID*/, $80/*PAL*/}   ; Grass E - frame 2
    TF{0507*2/*POS*/, 120/*TID*/, $80/*PAL*/}   ; Grass F - frame 2
    TF{1191*2/*POS*/, EMP/*TID*/, $70/*PAL*/}   ; Campfire - frame 2

    TF{1192*2/*POS*/, EMP/*TID*/, $70/*PAL*/}   ; Campfire - frame 2
    TF{1231*2/*POS*/, 168/*TID*/, $70/*PAL*/}   ; Campfire - frame 2
    TF{1232*2/*POS*/, 169/*TID*/, $70/*PAL*/}   ; Campfire - frame 2
    TF{1151*2/*POS*/, 152/*TID*/, $70/*PAL*/}   ; Campfire - frame 2
    TF{0941*2/*POS*/, 105/*TID*/, $80/*PAL*/}   ; Water - frame 2
    TF{0981*2/*POS*/, 107/*TID*/, $80/*PAL*/}   ; Water - frame 2
    TF{1021*2/*POS*/, 105/*TID*/, $80/*PAL*/}   ; Water - frame 2
    TF{1061*2/*POS*/, 107/*TID*/, $80/*PAL*/}   ; Water - frame 2
    TF{1101*2/*POS*/, 105/*TID*/, $80/*PAL*/}   ; Water - frame 2
    TF{1141*2/*POS*/, 107/*TID*/, $80/*PAL*/}   ; Water - frame 2

    TF{1181*2/*POS*/, 105/*TID*/, $80/*PAL*/}   ; Water - frame 2
    TF{1008*2/*POS*/, EMP/*TID*/, $70/*PAL*/}   ; Smoke - frame 2
    TF{0968*2/*POS*/, 153/*TID*/, $70/*PAL*/}   ; Smoke - frame 2
    TF{1165*2/*POS*/, 150/*TID*/, $70/*PAL*/}   ; Windows - frame 2
    TF{1169*2/*POS*/, 150/*TID*/, $70/*PAL*/}   ; Windows - frame 2

tilemapAnimationRow3L8
    DB 34
    TF{1162*2/*POS*/, 139/*TID*/, $70/*PAL*/}   ; Torch A - frame 3
    TF{1132*2/*POS*/, 137/*TID*/, $70/*PAL*/}   ; Torch B - frame 3
    TF{1136*2/*POS*/, 133/*TID*/, $70/*PAL*/}   ; Torch C - frame 1
    TF{1041*2/*POS*/, 080/*TID*/, $80/*PAL*/}   ; Bat A - frame 2
    TF{1186*2/*POS*/, 084/*TID*/, $80/*PAL*/}   ; Bat B - frame 3
    TF{0393*2/*POS*/, 081/*TID*/, $80/*PAL*/}   ; Bat C - frame 1
    TF{1012*2/*POS*/, 080/*TID*/, $80/*PAL*/}   ; Bat D - frame 2
    TF{1056*2/*POS*/, 070/*TID*/, $80/*PAL*/}   ; Bat E - frame 3
    TF{0780*2/*POS*/, 066/*TID*/, $80/*PAL*/}   ; Bat F - frame 1
    TF{0979*2/*POS*/, 067/*TID*/, $80/*PAL*/}   ; Bat G - frame 2

    TF{1063*2/*POS*/, 066/*TID*/, $80/*PAL*/}   ; Bat H - frame 1
    TF{1116*2/*POS*/, 070/*TID*/, $80/*PAL*/}   ; Bat I - frame 3
    TF{0427*2/*POS*/, 070/*TID*/, $80/*PAL*/}   ; Bat J - frame 3
    TF{0963*2/*POS*/, 070/*TID*/, $80/*PAL*/}   ; Bat K - frame 3
    TF{1201*2/*POS*/, 121/*TID*/, $80/*PAL*/}   ; Grass A - frame 3
    TF{1202*2/*POS*/, 118/*TID*/, $80/*PAL*/}   ; Grass B - frame 1
    TF{0864*2/*POS*/, 125/*TID*/, $80/*PAL*/}   ; Grass C - frame 3
    TF{0510*2/*POS*/, 125/*TID*/, $80/*PAL*/}   ; Grass E - frame 3
    TF{0507*2/*POS*/, 121/*TID*/, $80/*PAL*/}   ; Grass F - frame 3
    TF{1151*2/*POS*/, EMP/*TID*/, $70/*PAL*/}   ; Campfire - frame 3

    TF{1231*2/*POS*/, 154/*TID*/, $70/*PAL*/}   ; Campfire - frame 3
    TF{1232*2/*POS*/, 155/*TID*/, $70/*PAL*/}   ; Campfire - frame 3
    TF{1112*2/*POS*/, 153/*TID*/, $70/*PAL*/}   ; Campfire - frame 3
    TF{0941*2/*POS*/, 108/*TID*/, $80/*PAL*/}   ; Water - frame 3
    TF{0981*2/*POS*/, 110/*TID*/, $80/*PAL*/}   ; Water - frame 3
    TF{1021*2/*POS*/, 108/*TID*/, $80/*PAL*/}   ; Water - frame 3
    TF{1061*2/*POS*/, 110/*TID*/, $80/*PAL*/}   ; Water - frame 3
    TF{1101*2/*POS*/, 108/*TID*/, $80/*PAL*/}   ; Water - frame 3
    TF{1141*2/*POS*/, 110/*TID*/, $80/*PAL*/}   ; Water - frame 3
    TF{1181*2/*POS*/, 108/*TID*/, $80/*PAL*/}   ; Water - frame 3

    TF{0968*2/*POS*/, EMP/*TID*/, $70/*PAL*/}   ; Smoke - frame 3
    TF{0928*2/*POS*/, 152/*TID*/, $70/*PAL*/}   ; Smoke - frame 3
    TF{1165*2/*POS*/, 151/*TID*/, $70/*PAL*/}   ; Windows - frame 3
    TF{1169*2/*POS*/, 151/*TID*/, $70/*PAL*/}   ; Windows - frame 3

tilemapAnimationRowsL8
    DW tilemapAnimationRow1L8, tilemapAnimationRow2L8, tilemapAnimationRow3L8

TILEMAP_ANIM_ROWS_L8    = 3

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE