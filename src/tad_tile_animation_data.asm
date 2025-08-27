;----------------------------------------------------------;
;                   Tile Animation Data                    ;
;----------------------------------------------------------;
    ; ### TO USE THIS MODULE: CALL dbs.SetupTileAnimationBank ###

    MODULE tad
EMP                     = 198

; ##############################################
; Level 1
tilemapAnimationRow1L1
    DB 14
    TF{1200*2/*POS*/, 032/*TID*/, $20/*PAL*/}   ; Bat A - frame 1
    TF{1164*2/*POS*/, 033/*TID*/, $00/*PAL*/}   ; Bat B - frame 3
    TF{1131*2/*POS*/, 032/*TID*/, $50/*PAL*/}   ; Bat C - frame 1
    TF{1140*2/*POS*/, 026/*TID*/, $70/*PAL*/}   ; Torch A - frame 1
    TF{1145*2/*POS*/, 043/*TID*/, $70/*PAL*/}   ; Torch B - frame 3
    TF{1126*2/*POS*/, 010/*TID*/, $80/*PAL*/}   ; Bat D - frame 1
    TF{1189*2/*POS*/, 009/*TID*/, $70/*PAL*/}   ; Bat E - frame 3
    TF{1236*2/*POS*/, 010/*TID*/, $80/*PAL*/}   ; Bat F - frame 1
    TF{1158*2/*POS*/, 009/*TID*/, $80/*PAL*/}   ; Bat G - frame 3
    TF{1205*2/*POS*/, 048/*TID*/, $80/*PAL*/}   ; Grass A - frame 1

    TF{1229*2/*POS*/, 050/*TID*/, $80/*PAL*/}   ; Grass B - frame 3
    TF{1211*2/*POS*/, 024/*TID*/, $80/*PAL*/}   ; Grass C - frame 1
    TF{1230*2/*POS*/, 027/*TID*/, $80/*PAL*/}   ; Grass D - frame 3
    TF{1217*2/*POS*/, 032/*TID*/, $30/*PAL*/}   ; Bat H - frame 1

tilemapAnimationRow2L1
    DB 14
    TF{1200*2/*POS*/, 034/*TID*/, $20/*PAL*/}   ; Bat A - frame 2
    TF{1164*2/*POS*/, 032/*TID*/, $00/*PAL*/}   ; Bat B - frame 1
    TF{1131*2/*POS*/, 034/*TID*/, $50/*PAL*/}   ; Bat C - frame 2
    TF{1140*2/*POS*/, 041/*TID*/, $70/*PAL*/}   ; Torch A - frame 2
    TF{1145*2/*POS*/, 026/*TID*/, $70/*PAL*/}   ; Torch B - frame 1
    TF{1126*2/*POS*/, 011/*TID*/, $80/*PAL*/}   ; Bat D - frame 2
    TF{1189*2/*POS*/, 010/*TID*/, $70/*PAL*/}   ; Bat E - frame 1
    TF{1236*2/*POS*/, 011/*TID*/, $80/*PAL*/}   ; Bat F - frame 2
    TF{1158*2/*POS*/, 010/*TID*/, $80/*PAL*/}   ; Bat G - frame 1
    TF{1205*2/*POS*/, 049/*TID*/, $80/*PAL*/}   ; Grass A - frame 2

    TF{1229*2/*POS*/, 048/*TID*/, $80/*PAL*/}   ; Grass B - frame 1
    TF{1211*2/*POS*/, 025/*TID*/, $80/*PAL*/}   ; Grass C - frame 2
    TF{1230*2/*POS*/, 024/*TID*/, $80/*PAL*/}   ; Grass D - frame 1
    TF{1217*2/*POS*/, 034/*TID*/, $30/*PAL*/}   ; Bat H - frame 2

tilemapAnimationRow3L1
    DB 14
    TF{1200*2/*POS*/, 033/*TID*/, $20/*PAL*/}   ; Bat A - frame 3
    TF{1164*2/*POS*/, 034/*TID*/, $00/*PAL*/}   ; Bat B - frame 2
    TF{1131*2/*POS*/, 033/*TID*/, $50/*PAL*/}   ; Bat C - frame 3
    TF{1140*2/*POS*/, 043/*TID*/, $70/*PAL*/}   ; Torch A - frame 3
    TF{1145*2/*POS*/, 041/*TID*/, $70/*PAL*/}   ; Torch B - frame 2
    TF{1126*2/*POS*/, 009/*TID*/, $80/*PAL*/}   ; Bat D - frame 3
    TF{1189*2/*POS*/, 011/*TID*/, $70/*PAL*/}   ; Bat E - frame 2
    TF{1236*2/*POS*/, 009/*TID*/, $80/*PAL*/}   ; Bat F - frame 3
    TF{1158*2/*POS*/, 011/*TID*/, $80/*PAL*/}   ; Bat G - frame 2
    TF{1205*2/*POS*/, 050/*TID*/, $80/*PAL*/}   ; Grass A - frame 3

    TF{1229*2/*POS*/, 049/*TID*/, $80/*PAL*/}   ; Grass B - frame 2
    TF{1211*2/*POS*/, 027/*TID*/, $80/*PAL*/}   ; Grass C - frame 3
    TF{1230*2/*POS*/, 025/*TID*/, $80/*PAL*/}   ; Grass D - frame 2
    TF{1217*2/*POS*/, 033/*TID*/, $30/*PAL*/}   ; Bat H - frame 3

tilemapAnimationRowsL1
    DW tilemapAnimationRow1L1, tilemapAnimationRow2L1, tilemapAnimationRow3L1

TILEMAP_ANIM_ROWS_L1    = 3

; ##############################################
; Level 2
tilemapAnimationRow1L2
    DB 46
    TF{1221*2/*POS*/, 046/*TID*/, $70/*PAL*/}   ; Campfire Left A - frame 1
    TF{1222*2/*POS*/, 047/*TID*/, $70/*PAL*/}   ; Campfire Right A - frame 1
    TF{1227*2/*POS*/, 030/*TID*/, $70/*PAL*/}   ; Campfire Left B - frame 3
    TF{1228*2/*POS*/, 031/*TID*/, $70/*PAL*/}   ; Campfire Right B - frame 3
    TF{0532*2/*POS*/, 032/*TID*/, $80/*PAL*/}   ; Bat A - frame 1
    TF{0457*2/*POS*/, 032/*TID*/, $80/*PAL*/}   ; Bat B - frame 1
    TF{0373*2/*POS*/, 160/*TID*/, $80/*PAL*/}   ; Waterfall A - frame 1
    TF{0413*2/*POS*/, 162/*TID*/, $80/*PAL*/}   ; Waterfall A - frame 1
    TF{0453*2/*POS*/, 160/*TID*/, $80/*PAL*/}   ; Waterfall A - frame 1
    TF{0493*2/*POS*/, 162/*TID*/, $80/*PAL*/}   ; Waterfall A - frame 1

    TF{0533*2/*POS*/, 160/*TID*/, $80/*PAL*/}   ; Waterfall A - frame 1
    TF{0573*2/*POS*/, 162/*TID*/, $80/*PAL*/}   ; Waterfall A - frame 1
    TF{0613*2/*POS*/, 160/*TID*/, $80/*PAL*/}   ; Waterfall A - frame 1
    TF{0613*2/*POS*/, 162/*TID*/, $80/*PAL*/}   ; Waterfall A - frame 1
    TF{0653*2/*POS*/, 160/*TID*/, $80/*PAL*/}   ; Waterfall A - frame 1
    TF{0693*2/*POS*/, 162/*TID*/, $80/*PAL*/}   ; Waterfall A - frame 1
    TF{0733*2/*POS*/, 160/*TID*/, $80/*PAL*/}   ; Waterfall A - frame 1
    TF{0773*2/*POS*/, 162/*TID*/, $80/*PAL*/}   ; Waterfall A - frame 1
    TF{0813*2/*POS*/, 160/*TID*/, $80/*PAL*/}   ; Waterfall A - frame 1
    TF{0376*2/*POS*/, 161/*TID*/, $80/*PAL*/}   ; Waterfall B - frame 2

    TF{0416*2/*POS*/, 163/*TID*/, $80/*PAL*/}   ; Waterfall B - frame 2
    TF{0456*2/*POS*/, 161/*TID*/, $80/*PAL*/}   ; Waterfall B - frame 2
    TF{0496*2/*POS*/, 163/*TID*/, $80/*PAL*/}   ; Waterfall B - frame 2
    TF{0536*2/*POS*/, 161/*TID*/, $80/*PAL*/}   ; Waterfall B - frame 2
    TF{0576*2/*POS*/, 163/*TID*/, $80/*PAL*/}   ; Waterfall B - frame 2
    TF{0616*2/*POS*/, 161/*TID*/, $80/*PAL*/}   ; Waterfall B - frame 2
    TF{0616*2/*POS*/, 163/*TID*/, $80/*PAL*/}   ; Waterfall B - frame 2
    TF{0656*2/*POS*/, 161/*TID*/, $80/*PAL*/}   ; Waterfall B - frame 2
    TF{0696*2/*POS*/, 163/*TID*/, $80/*PAL*/}   ; Waterfall B - frame 2
    TF{0736*2/*POS*/, 161/*TID*/, $80/*PAL*/}   ; Waterfall B - frame 2

    TF{0776*2/*POS*/, 163/*TID*/, $80/*PAL*/}   ; Waterfall B - frame 2
    TF{0816*2/*POS*/, 161/*TID*/, $80/*PAL*/}   ; Waterfall B - frame 2
    TF{0366*2/*POS*/, 164/*TID*/, $80/*PAL*/}   ; Waterfall C - frame 3
    TF{0406*2/*POS*/, 166/*TID*/, $80/*PAL*/}   ; Waterfall C - frame 3
    TF{0446*2/*POS*/, 164/*TID*/, $80/*PAL*/}   ; Waterfall C - frame 3
    TF{0486*2/*POS*/, 166/*TID*/, $80/*PAL*/}   ; Waterfall C - frame 3
    TF{0526*2/*POS*/, 164/*TID*/, $80/*PAL*/}   ; Waterfall C - frame 3
    TF{0566*2/*POS*/, 165/*TID*/, $80/*PAL*/}   ; Waterfall C End - frame 1

    TF{1181*2/*POS*/, 028/*TID*/, $70/*PAL*/}   ; Smoke A - frame 1
    TF{1101*2/*POS*/, EMP/*TID*/, $70/*PAL*/}   ; Smoke A - frame 1

    TF{1182*2/*POS*/, 029/*TID*/, $70/*PAL*/}   ; Smoke B - frame 1
    TF{1102*2/*POS*/, EMP/*TID*/, $70/*PAL*/}   ; Smoke B - frame 1

    TF{1187*2/*POS*/, 028/*TID*/, $70/*PAL*/}   ; Smoke C - frame 1
    TF{1107*2/*POS*/, EMP/*TID*/, $70/*PAL*/}   ; Smoke C - frame 1

    TF{1188*2/*POS*/, EMP/*TID*/, $70/*PAL*/}   ; Smoke D - frame 1
    TF{1108*2/*POS*/, EMP/*TID*/, $70/*PAL*/}   ; Smoke D - frame 1

tilemapAnimationRow2L2
    DB 46
    TF{1221*2/*POS*/, 044/*TID*/, $70/*PAL*/}   ; Campfire Left A - frame 2
    TF{1222*2/*POS*/, 045/*TID*/, $70/*PAL*/}   ; Campfire Right A - frame 2
    TF{1227*2/*POS*/, 046/*TID*/, $70/*PAL*/}   ; Campfire Left B - frame 1
    TF{1228*2/*POS*/, 047/*TID*/, $70/*PAL*/}   ; Campfire Right B - frame 1
    TF{0532*2/*POS*/, 034/*TID*/, $80/*PAL*/}   ; Bat A - frame 2
    TF{0457*2/*POS*/, 033/*TID*/, $80/*PAL*/}   ; Bat B - frame 2
    TF{0373*2/*POS*/, 161/*TID*/, $80/*PAL*/}   ; Waterfall A - frame 2
    TF{0413*2/*POS*/, 163/*TID*/, $80/*PAL*/}   ; Waterfall A - frame 2
    TF{0453*2/*POS*/, 161/*TID*/, $80/*PAL*/}   ; Waterfall A - frame 2
    TF{0493*2/*POS*/, 163/*TID*/, $80/*PAL*/}   ; Waterfall A - frame 2

    TF{0533*2/*POS*/, 161/*TID*/, $80/*PAL*/}   ; Waterfall A - frame 2
    TF{0573*2/*POS*/, 163/*TID*/, $80/*PAL*/}   ; Waterfall A - frame 2
    TF{0613*2/*POS*/, 161/*TID*/, $80/*PAL*/}   ; Waterfall A - frame 2
    TF{0613*2/*POS*/, 163/*TID*/, $80/*PAL*/}   ; Waterfall A - frame 2
    TF{0653*2/*POS*/, 161/*TID*/, $80/*PAL*/}   ; Waterfall A - frame 2
    TF{0693*2/*POS*/, 163/*TID*/, $80/*PAL*/}   ; Waterfall A - frame 2
    TF{0733*2/*POS*/, 161/*TID*/, $80/*PAL*/}   ; Waterfall A - frame 2
    TF{0773*2/*POS*/, 163/*TID*/, $80/*PAL*/}   ; Waterfall A - frame 2
    TF{0813*2/*POS*/, 161/*TID*/, $80/*PAL*/}   ; Waterfall A - frame 2
    TF{0376*2/*POS*/, 164/*TID*/, $80/*PAL*/}   ; Waterfall B - frame 3

    TF{0416*2/*POS*/, 166/*TID*/, $80/*PAL*/}   ; Waterfall B - frame 3
    TF{0456*2/*POS*/, 164/*TID*/, $80/*PAL*/}   ; Waterfall B - frame 3
    TF{0496*2/*POS*/, 166/*TID*/, $80/*PAL*/}   ; Waterfall B - frame 3
    TF{0536*2/*POS*/, 164/*TID*/, $80/*PAL*/}   ; Waterfall B - frame 3
    TF{0576*2/*POS*/, 166/*TID*/, $80/*PAL*/}   ; Waterfall B - frame 3
    TF{0616*2/*POS*/, 164/*TID*/, $80/*PAL*/}   ; Waterfall B - frame 3
    TF{0616*2/*POS*/, 166/*TID*/, $80/*PAL*/}   ; Waterfall B - frame 3
    TF{0656*2/*POS*/, 164/*TID*/, $80/*PAL*/}   ; Waterfall B - frame 3
    TF{0696*2/*POS*/, 166/*TID*/, $80/*PAL*/}   ; Waterfall B - frame 3
    TF{0736*2/*POS*/, 164/*TID*/, $80/*PAL*/}   ; Waterfall B - frame 3

    TF{0776*2/*POS*/, 166/*TID*/, $80/*PAL*/}   ; Waterfall B - frame 3
    TF{0816*2/*POS*/, 164/*TID*/, $80/*PAL*/}   ; Waterfall B - frame 3
    TF{0366*2/*POS*/, 161/*TID*/, $80/*PAL*/}   ; Waterfall C - frame 2
    TF{0406*2/*POS*/, 163/*TID*/, $80/*PAL*/}   ; Waterfall C - frame 2
    TF{0446*2/*POS*/, 161/*TID*/, $80/*PAL*/}   ; Waterfall C - frame 2
    TF{0486*2/*POS*/, 163/*TID*/, $80/*PAL*/}   ; Waterfall C - frame 2
    TF{0526*2/*POS*/, 161/*TID*/, $80/*PAL*/}   ; Waterfall C - frame 2
    TF{0566*2/*POS*/, 167/*TID*/, $80/*PAL*/}   ; Waterfall C End - frame 2
    TF{1181*2/*POS*/, EMP/*TID*/, $70/*PAL*/}   ; Smoke A - frame 1
    TF{1141*2/*POS*/, 029/*TID*/, $70/*PAL*/}   ; Smoke A - frame 1

    TF{1182*2/*POS*/, EMP/*TID*/, $70/*PAL*/}   ; Smoke B - frame 1
    TF{1142*2/*POS*/, 028/*TID*/, $70/*PAL*/}   ; Smoke B - frame 1
    TF{1187*2/*POS*/, EMP/*TID*/, $70/*PAL*/}   ; Smoke C - frame 1
    TF{1147*2/*POS*/, EMP/*TID*/, $70/*PAL*/}   ; Smoke C - frame 1
    TF{1188*2/*POS*/, EMP/*TID*/, $70/*PAL*/}   ; Smoke D - frame 1
    TF{1148*2/*POS*/, 028/*TID*/, $70/*PAL*/}   ; Smoke D - frame 1

tilemapAnimationRow3L2
    DB 46
    TF{1221*2/*POS*/, 030/*TID*/, $70/*PAL*/}   ; Campfire Left A - frame 3
    TF{1222*2/*POS*/, 031/*TID*/, $70/*PAL*/}   ; Campfire Right A - frame 3
    TF{1227*2/*POS*/, 044/*TID*/, $70/*PAL*/}   ; Campfire Left B - frame 2
    TF{1228*2/*POS*/, 045/*TID*/, $70/*PAL*/}   ; Campfire Right B - frame 2
    TF{0532*2/*POS*/, 033/*TID*/, $80/*PAL*/}   ; Bat A - frame 3
    TF{0457*2/*POS*/, 034/*TID*/, $80/*PAL*/}   ; Bat B - frame 
    TF{0373*2/*POS*/, 164/*TID*/, $80/*PAL*/}   ; Waterfall A - frame 3
    TF{0413*2/*POS*/, 166/*TID*/, $80/*PAL*/}   ; Waterfall A - frame 3
    TF{0453*2/*POS*/, 164/*TID*/, $80/*PAL*/}   ; Waterfall A - frame 3
    TF{0493*2/*POS*/, 166/*TID*/, $80/*PAL*/}   ; Waterfall A - frame 3

    TF{0533*2/*POS*/, 164/*TID*/, $80/*PAL*/}   ; Waterfall A - frame 3
    TF{0573*2/*POS*/, 166/*TID*/, $80/*PAL*/}   ; Waterfall A - frame 3
    TF{0613*2/*POS*/, 164/*TID*/, $80/*PAL*/}   ; Waterfall A - frame 3
    TF{0613*2/*POS*/, 166/*TID*/, $80/*PAL*/}   ; Waterfall A - frame 3
    TF{0653*2/*POS*/, 164/*TID*/, $80/*PAL*/}   ; Waterfall A - frame 3
    TF{0693*2/*POS*/, 166/*TID*/, $80/*PAL*/}   ; Waterfall A - frame 3
    TF{0733*2/*POS*/, 164/*TID*/, $80/*PAL*/}   ; Waterfall A - frame 3
    TF{0773*2/*POS*/, 166/*TID*/, $80/*PAL*/}   ; Waterfall A - frame 3
    TF{0813*2/*POS*/, 164/*TID*/, $80/*PAL*/}   ; Waterfall A - frame 3
    TF{0376*2/*POS*/, 160/*TID*/, $80/*PAL*/}   ; Waterfall B - frame 1

    TF{0416*2/*POS*/, 162/*TID*/, $80/*PAL*/}   ; Waterfall B - frame 1
    TF{0456*2/*POS*/, 160/*TID*/, $80/*PAL*/}   ; Waterfall B - frame 1
    TF{0496*2/*POS*/, 162/*TID*/, $80/*PAL*/}   ; Waterfall B - frame 1
    TF{0536*2/*POS*/, 160/*TID*/, $80/*PAL*/}   ; Waterfall B - frame 1
    TF{0576*2/*POS*/, 162/*TID*/, $80/*PAL*/}   ; Waterfall B - frame 1
    TF{0616*2/*POS*/, 160/*TID*/, $80/*PAL*/}   ; Waterfall B - frame 1
    TF{0616*2/*POS*/, 162/*TID*/, $80/*PAL*/}   ; Waterfall B - frame 1
    TF{0656*2/*POS*/, 160/*TID*/, $80/*PAL*/}   ; Waterfall B - frame 1
    TF{0696*2/*POS*/, 162/*TID*/, $80/*PAL*/}   ; Waterfall B - frame 1
    TF{0736*2/*POS*/, 160/*TID*/, $80/*PAL*/}   ; Waterfall B - frame 1

    TF{0776*2/*POS*/, 162/*TID*/, $80/*PAL*/}   ; Waterfall B - frame 1
    TF{0816*2/*POS*/, 160/*TID*/, $80/*PAL*/}   ; Waterfall B - frame 1
    TF{0366*2/*POS*/, 160/*TID*/, $80/*PAL*/}   ; Waterfall C - frame 1
    TF{0406*2/*POS*/, 162/*TID*/, $80/*PAL*/}   ; Waterfall C - frame 1
    TF{0446*2/*POS*/, 160/*TID*/, $80/*PAL*/}   ; Waterfall C - frame 1
    TF{0486*2/*POS*/, 162/*TID*/, $80/*PAL*/}   ; Waterfall C - frame 1
    TF{0526*2/*POS*/, 160/*TID*/, $80/*PAL*/}   ; Waterfall C - frame 1
    TF{0566*2/*POS*/, 168/*TID*/, $80/*PAL*/}   ; Waterfall C End - frame 3
    TF{1101*2/*POS*/, 028/*TID*/, $70/*PAL*/}   ; Smoke A - frame 1
    TF{1141*2/*POS*/, EMP/*TID*/, $70/*PAL*/}   ; Smoke A - frame 1

    TF{1102*2/*POS*/, 029/*TID*/, $70/*PAL*/}   ; Smoke B - frame 1
    TF{1142*2/*POS*/, EMP/*TID*/, $70/*PAL*/}   ; Smoke B - frame 1
    TF{1107*2/*POS*/, 028/*TID*/, $70/*PAL*/}   ; Smoke C - frame 1
    TF{1147*2/*POS*/, EMP/*TID*/, $70/*PAL*/}   ; Smoke C - frame 1
    TF{1108*2/*POS*/, EMP/*TID*/, $70/*PAL*/}   ; Smoke D - frame 1
    TF{1148*2/*POS*/, EMP/*TID*/, $70/*PAL*/}   ; Smoke D - frame 1

tilemapAnimationRowsL2
    DW tilemapAnimationRow1L2, tilemapAnimationRow2L2, tilemapAnimationRow3L2

TILEMAP_ANIM_ROWS_L2    = 3

; ##############################################
; Level 3
tilemapAnimationRow1L3
    DB 22
    TF{1120*2/*POS*/, 032/*TID*/, $80/*PAL*/}   ; Bat A - frame 1
    TF{1161*2/*POS*/, 033/*TID*/, $20/*PAL*/}   ; Bat B - frame 3
    TF{1213*2/*POS*/, 032/*TID*/, $30/*PAL*/}   ; Bat C - frame 1
    TF{1175*2/*POS*/, 034/*TID*/, $60/*PAL*/}   ; Bat D - frame 2
    TF{1187*2/*POS*/, 032/*TID*/, $50/*PAL*/}   ; Bat E - frame 1
    TF{1033*2/*POS*/, 009/*TID*/, $80/*PAL*/}   ; Bat F - frame 1
    TF{1165*2/*POS*/, 026/*TID*/, $70/*PAL*/}   ; Flame A - frame 1
    TF{1168*2/*POS*/, 043/*TID*/, $70/*PAL*/}   ; Flame B - frame 3
    TF{1200*2/*POS*/, 024/*TID*/, $80/*PAL*/}   ; Grass A - frame 1
    TF{1201*2/*POS*/, 048/*TID*/, $80/*PAL*/}   ; Grass B - frame 1

    TF{1214*2/*POS*/, 004/*TID*/, $10/*PAL*/}   ; Grass C - frame 1
    TF{1215*2/*POS*/, 024/*TID*/, $20/*PAL*/}   ; Grass D - frame 1
    TF{1216*2/*POS*/, 004/*TID*/, $30/*PAL*/}   ; Grass E - frame 1
    TF{1219*2/*POS*/, 024/*TID*/, $40/*PAL*/}   ; Grass F - frame 1
    TF{1220*2/*POS*/, 048/*TID*/, $70/*PAL*/}   ; Grass G - frame 1
    TF{1226*2/*POS*/, 025/*TID*/, $80/*PAL*/}   ; Grass H - frame 1
    TF{1227*2/*POS*/, 048/*TID*/, $10/*PAL*/}   ; Grass I - frame 1
    TF{1228*2/*POS*/, 004/*TID*/, $20/*PAL*/}   ; Grass J - frame 1
    TF{1231*2/*POS*/, 024/*TID*/, $30/*PAL*/}   ; Grass K - frame 1
    TF{1232*2/*POS*/, 048/*TID*/, $40/*PAL*/}   ; Grass L - frame 1

    TF{1238*2/*POS*/, 024/*TID*/, $80/*PAL*/}   ; Grass M - frame 1
    TF{1239*2/*POS*/, 048/*TID*/, $70/*PAL*/}   ; Grass N - frame 1

tilemapAnimationRow2L3
    DB 22
    TF{1120*2/*POS*/, 034/*TID*/, $80/*PAL*/}   ; Bat A - frame 2
    TF{1161*2/*POS*/, 032/*TID*/, $20/*PAL*/}   ; Bat B - frame 1
    TF{1213*2/*POS*/, 034/*TID*/, $30/*PAL*/}   ; Bat C - frame 2
    TF{1175*2/*POS*/, 033/*TID*/, $60/*PAL*/}   ; Bat D - frame 3
    TF{1187*2/*POS*/, 034/*TID*/, $50/*PAL*/}   ; Bat E - frame 2
    TF{1033*2/*POS*/, 010/*TID*/, $80/*PAL*/}   ; Bat F - frame 2
    TF{1165*2/*POS*/, 041/*TID*/, $70/*PAL*/}   ; Flame A - frame 2
    TF{1168*2/*POS*/, 026/*TID*/, $70/*PAL*/}   ; Flame B - frame 1
    TF{1200*2/*POS*/, 025/*TID*/, $80/*PAL*/}   ; Grass A - frame 2
    TF{1201*2/*POS*/, 049/*TID*/, $80/*PAL*/}   ; Grass B - frame 2

    TF{1214*2/*POS*/, 005/*TID*/, $10/*PAL*/}   ; Grass C - frame 2
    TF{1215*2/*POS*/, 025/*TID*/, $20/*PAL*/}   ; Grass D - frame 2
    TF{1216*2/*POS*/, 005/*TID*/, $30/*PAL*/}   ; Grass E - frame 2
    TF{1219*2/*POS*/, 025/*TID*/, $40/*PAL*/}   ; Grass F - frame 2
    TF{1220*2/*POS*/, 049/*TID*/, $70/*PAL*/}   ; Grass G - frame 2
    TF{1226*2/*POS*/, 024/*TID*/, $80/*PAL*/}   ; Grass H - frame 2
    TF{1227*2/*POS*/, 049/*TID*/, $10/*PAL*/}   ; Grass I - frame 2
    TF{1228*2/*POS*/, 005/*TID*/, $20/*PAL*/}   ; Grass J - frame 2
    TF{1231*2/*POS*/, 025/*TID*/, $30/*PAL*/}   ; Grass K - frame 2
    TF{1232*2/*POS*/, 049/*TID*/, $40/*PAL*/}   ; Grass L - frame 2

    TF{1238*2/*POS*/, 025/*TID*/, $80/*PAL*/}   ; Grass M - frame 2
    TF{1239*2/*POS*/, 049/*TID*/, $70/*PAL*/}   ; Grass N - frame 2

tilemapAnimationRow3L3
    DB 22
    TF{1120*2/*POS*/, 033/*TID*/, $80/*PAL*/}   ; Bat A - frame 3
    TF{1161*2/*POS*/, 034/*TID*/, $20/*PAL*/}   ; Bat B - frame 2
    TF{1213*2/*POS*/, 033/*TID*/, $30/*PAL*/}   ; Bat C - frame 3
    TF{1175*2/*POS*/, 032/*TID*/, $60/*PAL*/}   ; Bat D - frame 1
    TF{1187*2/*POS*/, 033/*TID*/, $50/*PAL*/}   ; Bat E - frame 3
    TF{1033*2/*POS*/, 011/*TID*/, $80/*PAL*/}   ; Bat F - frame 3
    TF{1165*2/*POS*/, 043/*TID*/, $70/*PAL*/}   ; Flame A - frame 3
    TF{1168*2/*POS*/, 041/*TID*/, $70/*PAL*/}   ; Flame B - frame 2
    TF{1200*2/*POS*/, 027/*TID*/, $80/*PAL*/}   ; Grass A - frame 3
    TF{1201*2/*POS*/, 050/*TID*/, $80/*PAL*/}   ; Grass B - frame 3

    TF{1214*2/*POS*/, 006/*TID*/, $10/*PAL*/}   ; Grass C - frame 3
    TF{1215*2/*POS*/, 027/*TID*/, $20/*PAL*/}   ; Grass D - frame 3
    TF{1216*2/*POS*/, 006/*TID*/, $30/*PAL*/}   ; Grass E - frame 3
    TF{1219*2/*POS*/, 027/*TID*/, $40/*PAL*/}   ; Grass F - frame 3
    TF{1220*2/*POS*/, 050/*TID*/, $70/*PAL*/}   ; Grass G - frame 3
    TF{1226*2/*POS*/, 027/*TID*/, $80/*PAL*/}   ; Grass H - frame 3
    TF{1227*2/*POS*/, 050/*TID*/, $10/*PAL*/}   ; Grass I - frame 3
    TF{1228*2/*POS*/, 006/*TID*/, $20/*PAL*/}   ; Grass J - frame 3
    TF{1231*2/*POS*/, 027/*TID*/, $30/*PAL*/}   ; Grass K - frame 3
    TF{1232*2/*POS*/, 050/*TID*/, $40/*PAL*/}   ; Grass L - frame 3

    TF{1238*2/*POS*/, 027/*TID*/, $80/*PAL*/}   ; Grass M - frame 3
    TF{1239*2/*POS*/, 050/*TID*/, $70/*PAL*/}   ; Grass N - frame 3

tilemapAnimationRowsL3
    DW tilemapAnimationRow1L3, tilemapAnimationRow2L3, tilemapAnimationRow3L3

TILEMAP_ANIM_ROWS_L3    = 3

; ##############################################
; Level 8
tilemapAnimationRow1L8
    DB 35
    TF{1162*2/*POS*/, 135/*TID*/, $70/*PAL*/}   ; Torch A - frame 1
    TF{1132*2/*POS*/, 133/*TID*/, $70/*PAL*/}   ; Torch B - frame 1
    TF{1136*2/*POS*/, 137/*TID*/, $70/*PAL*/}   ; Torch C - frame 3
    TF{1041*2/*POS*/, 084/*TID*/, $00/*PAL*/}   ; Bat A - frame 3
    TF{1186*2/*POS*/, 081/*TID*/, $10/*PAL*/}   ; Bat B - frame 1
    TF{0393*2/*POS*/, 080/*TID*/, $20/*PAL*/}   ; Bat C - frame 2
    TF{1012*2/*POS*/, 084/*TID*/, $30/*PAL*/}   ; Bat D - frame 3
    TF{1056*2/*POS*/, 066/*TID*/, $80/*PAL*/}   ; Bat E - frame 1
    TF{0780*2/*POS*/, 067/*TID*/, $50/*PAL*/}   ; Bat F - frame 2
    TF{0979*2/*POS*/, 070/*TID*/, $60/*PAL*/}   ; Bat G - frame 3

    TF{1063*2/*POS*/, 067/*TID*/, $70/*PAL*/}   ; Bat H - frame 2
    TF{1116*2/*POS*/, 066/*TID*/, $80/*PAL*/}   ; Bat I - frame 1
    TF{0427*2/*POS*/, 066/*TID*/, $80/*PAL*/}   ; Bat J - frame 1
    TF{0963*2/*POS*/, 066/*TID*/, $00/*PAL*/}   ; Bat K - frame 1
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
    TF{0941*2/*POS*/, 104/*TID*/, $80/*PAL*/}   ; Waterfall - frame 1
    TF{0981*2/*POS*/, 106/*TID*/, $80/*PAL*/}   ; Waterfall - frame 1
    TF{1021*2/*POS*/, 104/*TID*/, $80/*PAL*/}   ; Waterfall - frame 1
    TF{1061*2/*POS*/, 106/*TID*/, $80/*PAL*/}   ; Waterfall - frame 1
    TF{1101*2/*POS*/, 104/*TID*/, $80/*PAL*/}   ; Waterfall - frame 1
    TF{1141*2/*POS*/, 106/*TID*/, $80/*PAL*/}   ; Waterfall - frame 1

    TF{1181*2/*POS*/, 104/*TID*/, $80/*PAL*/}   ; Waterfall - frame 1
    TF{1008*2/*POS*/, 152/*TID*/, $70/*PAL*/}   ; Smoke - frame 1
    TF{0928*2/*POS*/, EMP/*TID*/, $70/*PAL*/}   ; Smoke - frame 4
    TF{1165*2/*POS*/, 147/*TID*/, $70/*PAL*/}   ; Windows - frame 1
    TF{1169*2/*POS*/, 147/*TID*/, $70/*PAL*/}   ; Windows - frame 1

tilemapAnimationRow2L8
    DB 35
    TF{1162*2/*POS*/, 138/*TID*/, $70/*PAL*/}   ; Torch A - frame 2
    TF{1132*2/*POS*/, 136/*TID*/, $70/*PAL*/}   ; Torch B - frame 2
    TF{1136*2/*POS*/, 136/*TID*/, $70/*PAL*/}   ; Torch C - frame 2
    TF{1041*2/*POS*/, 081/*TID*/, $00/*PAL*/}   ; Bat A - frame 1
    TF{1186*2/*POS*/, 080/*TID*/, $10/*PAL*/}   ; Bat B - frame 2
    TF{0393*2/*POS*/, 084/*TID*/, $20/*PAL*/}   ; Bat C - frame 3
    TF{1012*2/*POS*/, 081/*TID*/, $30/*PAL*/}   ; Bat D - frame 1
    TF{1056*2/*POS*/, 067/*TID*/, $80/*PAL*/}   ; Bat E - frame 2
    TF{0780*2/*POS*/, 070/*TID*/, $50/*PAL*/}   ; Bat F - frame 3
    TF{0979*2/*POS*/, 066/*TID*/, $60/*PAL*/}   ; Bat G - frame 1

    TF{1063*2/*POS*/, 070/*TID*/, $70/*PAL*/}   ; Bat H - frame 3
    TF{1116*2/*POS*/, 067/*TID*/, $80/*PAL*/}   ; Bat I - frame 2
    TF{0427*2/*POS*/, 067/*TID*/, $80/*PAL*/}   ; Bat J - frame 2
    TF{0963*2/*POS*/, 067/*TID*/, $00/*PAL*/}   ; Bat K - frame 2
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
    TF{0941*2/*POS*/, 105/*TID*/, $80/*PAL*/}   ; Waterfall - frame 2
    TF{0981*2/*POS*/, 107/*TID*/, $80/*PAL*/}   ; Waterfall - frame 2
    TF{1021*2/*POS*/, 105/*TID*/, $80/*PAL*/}   ; Waterfall - frame 2
    TF{1061*2/*POS*/, 107/*TID*/, $80/*PAL*/}   ; Waterfall - frame 2
    TF{1101*2/*POS*/, 105/*TID*/, $80/*PAL*/}   ; Waterfall - frame 2
    TF{1141*2/*POS*/, 107/*TID*/, $80/*PAL*/}   ; Waterfall - frame 2

    TF{1181*2/*POS*/, 105/*TID*/, $80/*PAL*/}   ; Waterfall - frame 2
    TF{1008*2/*POS*/, EMP/*TID*/, $70/*PAL*/}   ; Smoke - frame 2
    TF{0968*2/*POS*/, 153/*TID*/, $70/*PAL*/}   ; Smoke - frame 2
    TF{1165*2/*POS*/, 150/*TID*/, $70/*PAL*/}   ; Windows - frame 2
    TF{1169*2/*POS*/, 150/*TID*/, $70/*PAL*/}   ; Windows - frame 2

tilemapAnimationRow3L8
    DB 34
    TF{1162*2/*POS*/, 139/*TID*/, $70/*PAL*/}   ; Torch A - frame 3
    TF{1132*2/*POS*/, 137/*TID*/, $70/*PAL*/}   ; Torch B - frame 3
    TF{1136*2/*POS*/, 133/*TID*/, $70/*PAL*/}   ; Torch C - frame 1
    TF{1041*2/*POS*/, 080/*TID*/, $00/*PAL*/}   ; Bat A - frame 2
    TF{1186*2/*POS*/, 084/*TID*/, $10/*PAL*/}   ; Bat B - frame 3
    TF{0393*2/*POS*/, 081/*TID*/, $20/*PAL*/}   ; Bat C - frame 1
    TF{1012*2/*POS*/, 080/*TID*/, $30/*PAL*/}   ; Bat D - frame 2
    TF{1056*2/*POS*/, 070/*TID*/, $80/*PAL*/}   ; Bat E - frame 3
    TF{0780*2/*POS*/, 066/*TID*/, $50/*PAL*/}   ; Bat F - frame 1
    TF{0979*2/*POS*/, 067/*TID*/, $60/*PAL*/}   ; Bat G - frame 2

    TF{1063*2/*POS*/, 066/*TID*/, $70/*PAL*/}   ; Bat H - frame 1
    TF{1116*2/*POS*/, 070/*TID*/, $80/*PAL*/}   ; Bat I - frame 3
    TF{0427*2/*POS*/, 070/*TID*/, $80/*PAL*/}   ; Bat J - frame 3
    TF{0963*2/*POS*/, 070/*TID*/, $00/*PAL*/}   ; Bat K - frame 3
    TF{1201*2/*POS*/, 121/*TID*/, $80/*PAL*/}   ; Grass A - frame 3
    TF{1202*2/*POS*/, 118/*TID*/, $80/*PAL*/}   ; Grass B - frame 1
    TF{0864*2/*POS*/, 125/*TID*/, $80/*PAL*/}   ; Grass C - frame 3
    TF{0510*2/*POS*/, 125/*TID*/, $80/*PAL*/}   ; Grass E - frame 3
    TF{0507*2/*POS*/, 121/*TID*/, $80/*PAL*/}   ; Grass F - frame 3
    TF{1151*2/*POS*/, EMP/*TID*/, $70/*PAL*/}   ; Campfire - frame 3

    TF{1231*2/*POS*/, 154/*TID*/, $70/*PAL*/}   ; Campfire - frame 3
    TF{1232*2/*POS*/, 155/*TID*/, $70/*PAL*/}   ; Campfire - frame 3
    TF{1112*2/*POS*/, 153/*TID*/, $70/*PAL*/}   ; Campfire - frame 3
    TF{0941*2/*POS*/, 108/*TID*/, $80/*PAL*/}   ; Waterfall - frame 3
    TF{0981*2/*POS*/, 110/*TID*/, $80/*PAL*/}   ; Waterfall - frame 3
    TF{1021*2/*POS*/, 108/*TID*/, $80/*PAL*/}   ; Waterfall - frame 3
    TF{1061*2/*POS*/, 110/*TID*/, $80/*PAL*/}   ; Waterfall - frame 3
    TF{1101*2/*POS*/, 108/*TID*/, $80/*PAL*/}   ; Waterfall - frame 3
    TF{1141*2/*POS*/, 110/*TID*/, $80/*PAL*/}   ; Waterfall - frame 3
    TF{1181*2/*POS*/, 108/*TID*/, $80/*PAL*/}   ; Waterfall - frame 3

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