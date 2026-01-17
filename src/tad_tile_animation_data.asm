/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
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
    TF{1140*2/*POS*/, 026/*TID*/, $40/*PAL*/}   ; Torch A - frame 1
    TF{1145*2/*POS*/, 043/*TID*/, $40/*PAL*/}   ; Torch B - frame 3
    TF{1126*2/*POS*/, 010/*TID*/, $00/*PAL*/}   ; Bat D - frame 1
    TF{1189*2/*POS*/, 009/*TID*/, $70/*PAL*/}   ; Bat E - frame 3
    TF{1236*2/*POS*/, 010/*TID*/, $20/*PAL*/}   ; Bat F - frame 1
    TF{1158*2/*POS*/, 009/*TID*/, $20/*PAL*/}   ; Bat G - frame 3
    TF{1205*2/*POS*/, 048/*TID*/, $20/*PAL*/}   ; Grass A - frame 1

    TF{1229*2/*POS*/, 050/*TID*/, $20/*PAL*/}   ; Grass B - frame 3
    TF{1211*2/*POS*/, 024/*TID*/, $20/*PAL*/}   ; Grass C - frame 1
    TF{1230*2/*POS*/, 027/*TID*/, $20/*PAL*/}   ; Grass D - frame 3
    TF{1217*2/*POS*/, 032/*TID*/, $30/*PAL*/}   ; Bat H - frame 1

tilemapAnimationRow2L1
    DB 14
    TF{1200*2/*POS*/, 034/*TID*/, $20/*PAL*/}   ; Bat A - frame 2
    TF{1164*2/*POS*/, 032/*TID*/, $00/*PAL*/}   ; Bat B - frame 1
    TF{1131*2/*POS*/, 034/*TID*/, $50/*PAL*/}   ; Bat C - frame 2
    TF{1140*2/*POS*/, 041/*TID*/, $40/*PAL*/}   ; Torch A - frame 2
    TF{1145*2/*POS*/, 026/*TID*/, $40/*PAL*/}   ; Torch B - frame 1
    TF{1126*2/*POS*/, 011/*TID*/, $10/*PAL*/}   ; Bat D - frame 2
    TF{1189*2/*POS*/, 010/*TID*/, $70/*PAL*/}   ; Bat E - frame 1
    TF{1236*2/*POS*/, 011/*TID*/, $20/*PAL*/}   ; Bat F - frame 2
    TF{1158*2/*POS*/, 010/*TID*/, $20/*PAL*/}   ; Bat G - frame 1
    TF{1205*2/*POS*/, 049/*TID*/, $20/*PAL*/}   ; Grass A - frame 2

    TF{1229*2/*POS*/, 048/*TID*/, $20/*PAL*/}   ; Grass B - frame 1
    TF{1211*2/*POS*/, 025/*TID*/, $20/*PAL*/}   ; Grass C - frame 2
    TF{1230*2/*POS*/, 024/*TID*/, $20/*PAL*/}   ; Grass D - frame 1
    TF{1217*2/*POS*/, 034/*TID*/, $30/*PAL*/}   ; Bat H - frame 2

tilemapAnimationRow3L1
    DB 14
    TF{1200*2/*POS*/, 033/*TID*/, $20/*PAL*/}   ; Bat A - frame 3
    TF{1164*2/*POS*/, 034/*TID*/, $00/*PAL*/}   ; Bat B - frame 2
    TF{1131*2/*POS*/, 033/*TID*/, $50/*PAL*/}   ; Bat C - frame 3
    TF{1140*2/*POS*/, 043/*TID*/, $40/*PAL*/}   ; Torch A - frame 3
    TF{1145*2/*POS*/, 041/*TID*/, $40/*PAL*/}   ; Torch B - frame 2
    TF{1126*2/*POS*/, 009/*TID*/, $20/*PAL*/}   ; Bat D - frame 3
    TF{1189*2/*POS*/, 011/*TID*/, $70/*PAL*/}   ; Bat E - frame 2
    TF{1236*2/*POS*/, 009/*TID*/, $20/*PAL*/}   ; Bat F - frame 3
    TF{1158*2/*POS*/, 011/*TID*/, $20/*PAL*/}   ; Bat G - frame 2
    TF{1205*2/*POS*/, 050/*TID*/, $20/*PAL*/}   ; Grass A - frame 3

    TF{1229*2/*POS*/, 049/*TID*/, $20/*PAL*/}   ; Grass B - frame 2
    TF{1211*2/*POS*/, 027/*TID*/, $20/*PAL*/}   ; Grass C - frame 3
    TF{1230*2/*POS*/, 025/*TID*/, $20/*PAL*/}   ; Grass D - frame 2
    TF{1217*2/*POS*/, 033/*TID*/, $30/*PAL*/}   ; Bat H - frame 3

tilemapAnimationRowsL1
    DW tilemapAnimationRow1L1, tilemapAnimationRow2L1, tilemapAnimationRow3L1

TILEMAP_ANIM_ROWS_L1    = 3

; ##############################################
; Level 2
tilemapAnimationRow1L2
    DB 46
    TF{1221*2/*POS*/, 046/*TID*/, $40/*PAL*/}   ; Campfire Left A - frame 1
    TF{1222*2/*POS*/, 047/*TID*/, $40/*PAL*/}   ; Campfire Right A - frame 1
    TF{1227*2/*POS*/, 030/*TID*/, $40/*PAL*/}   ; Campfire Left B - frame 3
    TF{1228*2/*POS*/, 031/*TID*/, $40/*PAL*/}   ; Campfire Right B - frame 3
    TF{0532*2/*POS*/, 032/*TID*/, $20/*PAL*/}   ; Bat A - frame 1
    TF{0457*2/*POS*/, 032/*TID*/, $20/*PAL*/}   ; Bat B - frame 1
    TF{0373*2/*POS*/, 160/*TID*/, $00/*PAL*/}   ; Waterfall A - frame 1
    TF{0413*2/*POS*/, 162/*TID*/, $00/*PAL*/}   ; Waterfall A - frame 1
    TF{0453*2/*POS*/, 160/*TID*/, $00/*PAL*/}   ; Waterfall A - frame 1
    TF{0493*2/*POS*/, 162/*TID*/, $00/*PAL*/}   ; Waterfall A - frame 1

    TF{0533*2/*POS*/, 160/*TID*/, $00/*PAL*/}   ; Waterfall A - frame 1
    TF{0573*2/*POS*/, 162/*TID*/, $00/*PAL*/}   ; Waterfall A - frame 1
    TF{0613*2/*POS*/, 160/*TID*/, $00/*PAL*/}   ; Waterfall A - frame 1
    TF{0613*2/*POS*/, 162/*TID*/, $00/*PAL*/}   ; Waterfall A - frame 1
    TF{0653*2/*POS*/, 160/*TID*/, $00/*PAL*/}   ; Waterfall A - frame 1
    TF{0693*2/*POS*/, 162/*TID*/, $00/*PAL*/}   ; Waterfall A - frame 1
    TF{0733*2/*POS*/, 160/*TID*/, $00/*PAL*/}   ; Waterfall A - frame 1
    TF{0773*2/*POS*/, 162/*TID*/, $00/*PAL*/}   ; Waterfall A - frame 1
    TF{0813*2/*POS*/, 160/*TID*/, $00/*PAL*/}   ; Waterfall A - frame 1
    TF{0376*2/*POS*/, 161/*TID*/, $00/*PAL*/}   ; Waterfall B - frame 2

    TF{0416*2/*POS*/, 163/*TID*/, $00/*PAL*/}   ; Waterfall B - frame 2
    TF{0456*2/*POS*/, 161/*TID*/, $00/*PAL*/}   ; Waterfall B - frame 2
    TF{0496*2/*POS*/, 163/*TID*/, $00/*PAL*/}   ; Waterfall B - frame 2
    TF{0536*2/*POS*/, 161/*TID*/, $00/*PAL*/}   ; Waterfall B - frame 2
    TF{0576*2/*POS*/, 163/*TID*/, $00/*PAL*/}   ; Waterfall B - frame 2
    TF{0616*2/*POS*/, 161/*TID*/, $00/*PAL*/}   ; Waterfall B - frame 2
    TF{0616*2/*POS*/, 163/*TID*/, $00/*PAL*/}   ; Waterfall B - frame 2
    TF{0656*2/*POS*/, 161/*TID*/, $00/*PAL*/}   ; Waterfall B - frame 2
    TF{0696*2/*POS*/, 163/*TID*/, $00/*PAL*/}   ; Waterfall B - frame 2
    TF{0736*2/*POS*/, 161/*TID*/, $00/*PAL*/}   ; Waterfall B - frame 2

    TF{0776*2/*POS*/, 163/*TID*/, $00/*PAL*/}   ; Waterfall B - frame 2
    TF{0816*2/*POS*/, 161/*TID*/, $00/*PAL*/}   ; Waterfall B - frame 2
    TF{0366*2/*POS*/, 164/*TID*/, $00/*PAL*/}   ; Waterfall C - frame 3
    TF{0406*2/*POS*/, 166/*TID*/, $00/*PAL*/}   ; Waterfall C - frame 3
    TF{0446*2/*POS*/, 164/*TID*/, $00/*PAL*/}   ; Waterfall C - frame 3
    TF{0486*2/*POS*/, 166/*TID*/, $00/*PAL*/}   ; Waterfall C - frame 3
    TF{0526*2/*POS*/, 164/*TID*/, $00/*PAL*/}   ; Waterfall C - frame 3
    TF{0566*2/*POS*/, 165/*TID*/, $00/*PAL*/}   ; Waterfall C End - frame 1

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
    TF{1221*2/*POS*/, 044/*TID*/, $40/*PAL*/}   ; Campfire Left A - frame 2
    TF{1222*2/*POS*/, 045/*TID*/, $40/*PAL*/}   ; Campfire Right A - frame 2
    TF{1227*2/*POS*/, 046/*TID*/, $40/*PAL*/}   ; Campfire Left B - frame 1
    TF{1228*2/*POS*/, 047/*TID*/, $40/*PAL*/}   ; Campfire Right B - frame 1
    TF{0532*2/*POS*/, 034/*TID*/, $20/*PAL*/}   ; Bat A - frame 2
    TF{0457*2/*POS*/, 033/*TID*/, $20/*PAL*/}   ; Bat B - frame 2
    TF{0373*2/*POS*/, 161/*TID*/, $00/*PAL*/}   ; Waterfall A - frame 2
    TF{0413*2/*POS*/, 163/*TID*/, $00/*PAL*/}   ; Waterfall A - frame 2
    TF{0453*2/*POS*/, 161/*TID*/, $00/*PAL*/}   ; Waterfall A - frame 2
    TF{0493*2/*POS*/, 163/*TID*/, $00/*PAL*/}   ; Waterfall A - frame 2

    TF{0533*2/*POS*/, 161/*TID*/, $00/*PAL*/}   ; Waterfall A - frame 2
    TF{0573*2/*POS*/, 163/*TID*/, $00/*PAL*/}   ; Waterfall A - frame 2
    TF{0613*2/*POS*/, 161/*TID*/, $00/*PAL*/}   ; Waterfall A - frame 2
    TF{0613*2/*POS*/, 163/*TID*/, $00/*PAL*/}   ; Waterfall A - frame 2
    TF{0653*2/*POS*/, 161/*TID*/, $00/*PAL*/}   ; Waterfall A - frame 2
    TF{0693*2/*POS*/, 163/*TID*/, $00/*PAL*/}   ; Waterfall A - frame 2
    TF{0733*2/*POS*/, 161/*TID*/, $00/*PAL*/}   ; Waterfall A - frame 2
    TF{0773*2/*POS*/, 163/*TID*/, $00/*PAL*/}   ; Waterfall A - frame 2
    TF{0813*2/*POS*/, 161/*TID*/, $00/*PAL*/}   ; Waterfall A - frame 2
    TF{0376*2/*POS*/, 164/*TID*/, $00/*PAL*/}   ; Waterfall B - frame 3

    TF{0416*2/*POS*/, 166/*TID*/, $00/*PAL*/}   ; Waterfall B - frame 3
    TF{0456*2/*POS*/, 164/*TID*/, $00/*PAL*/}   ; Waterfall B - frame 3
    TF{0496*2/*POS*/, 166/*TID*/, $00/*PAL*/}   ; Waterfall B - frame 3
    TF{0536*2/*POS*/, 164/*TID*/, $00/*PAL*/}   ; Waterfall B - frame 3
    TF{0576*2/*POS*/, 166/*TID*/, $00/*PAL*/}   ; Waterfall B - frame 3
    TF{0616*2/*POS*/, 164/*TID*/, $00/*PAL*/}   ; Waterfall B - frame 3
    TF{0616*2/*POS*/, 166/*TID*/, $00/*PAL*/}   ; Waterfall B - frame 3
    TF{0656*2/*POS*/, 164/*TID*/, $00/*PAL*/}   ; Waterfall B - frame 3
    TF{0696*2/*POS*/, 166/*TID*/, $00/*PAL*/}   ; Waterfall B - frame 3
    TF{0736*2/*POS*/, 164/*TID*/, $00/*PAL*/}   ; Waterfall B - frame 3

    TF{0776*2/*POS*/, 166/*TID*/, $00/*PAL*/}   ; Waterfall B - frame 3
    TF{0816*2/*POS*/, 164/*TID*/, $00/*PAL*/}   ; Waterfall B - frame 3
    TF{0366*2/*POS*/, 161/*TID*/, $00/*PAL*/}   ; Waterfall C - frame 2
    TF{0406*2/*POS*/, 163/*TID*/, $00/*PAL*/}   ; Waterfall C - frame 2
    TF{0446*2/*POS*/, 161/*TID*/, $00/*PAL*/}   ; Waterfall C - frame 2
    TF{0486*2/*POS*/, 163/*TID*/, $00/*PAL*/}   ; Waterfall C - frame 2
    TF{0526*2/*POS*/, 161/*TID*/, $00/*PAL*/}   ; Waterfall C - frame 2
    TF{0566*2/*POS*/, 167/*TID*/, $00/*PAL*/}   ; Waterfall C End - frame 2
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
    TF{1221*2/*POS*/, 030/*TID*/, $40/*PAL*/}   ; Campfire Left A - frame 3
    TF{1222*2/*POS*/, 031/*TID*/, $40/*PAL*/}   ; Campfire Right A - frame 3
    TF{1227*2/*POS*/, 044/*TID*/, $40/*PAL*/}   ; Campfire Left B - frame 2
    TF{1228*2/*POS*/, 045/*TID*/, $40/*PAL*/}   ; Campfire Right B - frame 2
    TF{0532*2/*POS*/, 033/*TID*/, $20/*PAL*/}   ; Bat A - frame 3
    TF{0457*2/*POS*/, 034/*TID*/, $20/*PAL*/}   ; Bat B - frame 
    TF{0373*2/*POS*/, 164/*TID*/, $00/*PAL*/}   ; Waterfall A - frame 3
    TF{0413*2/*POS*/, 166/*TID*/, $00/*PAL*/}   ; Waterfall A - frame 3
    TF{0453*2/*POS*/, 164/*TID*/, $00/*PAL*/}   ; Waterfall A - frame 3
    TF{0493*2/*POS*/, 166/*TID*/, $00/*PAL*/}   ; Waterfall A - frame 3

    TF{0533*2/*POS*/, 164/*TID*/, $00/*PAL*/}   ; Waterfall A - frame 3
    TF{0573*2/*POS*/, 166/*TID*/, $00/*PAL*/}   ; Waterfall A - frame 3
    TF{0613*2/*POS*/, 164/*TID*/, $00/*PAL*/}   ; Waterfall A - frame 3
    TF{0613*2/*POS*/, 166/*TID*/, $00/*PAL*/}   ; Waterfall A - frame 3
    TF{0653*2/*POS*/, 164/*TID*/, $00/*PAL*/}   ; Waterfall A - frame 3
    TF{0693*2/*POS*/, 166/*TID*/, $00/*PAL*/}   ; Waterfall A - frame 3
    TF{0733*2/*POS*/, 164/*TID*/, $00/*PAL*/}   ; Waterfall A - frame 3
    TF{0773*2/*POS*/, 166/*TID*/, $00/*PAL*/}   ; Waterfall A - frame 3
    TF{0813*2/*POS*/, 164/*TID*/, $00/*PAL*/}   ; Waterfall A - frame 3
    TF{0376*2/*POS*/, 160/*TID*/, $00/*PAL*/}   ; Waterfall B - frame 1

    TF{0416*2/*POS*/, 162/*TID*/, $00/*PAL*/}   ; Waterfall B - frame 1
    TF{0456*2/*POS*/, 160/*TID*/, $00/*PAL*/}   ; Waterfall B - frame 1
    TF{0496*2/*POS*/, 162/*TID*/, $00/*PAL*/}   ; Waterfall B - frame 1
    TF{0536*2/*POS*/, 160/*TID*/, $00/*PAL*/}   ; Waterfall B - frame 1
    TF{0576*2/*POS*/, 162/*TID*/, $00/*PAL*/}   ; Waterfall B - frame 1
    TF{0616*2/*POS*/, 160/*TID*/, $00/*PAL*/}   ; Waterfall B - frame 1
    TF{0616*2/*POS*/, 162/*TID*/, $00/*PAL*/}   ; Waterfall B - frame 1
    TF{0656*2/*POS*/, 160/*TID*/, $00/*PAL*/}   ; Waterfall B - frame 1
    TF{0696*2/*POS*/, 162/*TID*/, $00/*PAL*/}   ; Waterfall B - frame 1
    TF{0736*2/*POS*/, 160/*TID*/, $00/*PAL*/}   ; Waterfall B - frame 1

    TF{0776*2/*POS*/, 162/*TID*/, $00/*PAL*/}   ; Waterfall B - frame 1
    TF{0816*2/*POS*/, 160/*TID*/, $00/*PAL*/}   ; Waterfall B - frame 1
    TF{0366*2/*POS*/, 160/*TID*/, $00/*PAL*/}   ; Waterfall C - frame 1
    TF{0406*2/*POS*/, 162/*TID*/, $00/*PAL*/}   ; Waterfall C - frame 1
    TF{0446*2/*POS*/, 160/*TID*/, $00/*PAL*/}   ; Waterfall C - frame 1
    TF{0486*2/*POS*/, 162/*TID*/, $00/*PAL*/}   ; Waterfall C - frame 1
    TF{0526*2/*POS*/, 160/*TID*/, $00/*PAL*/}   ; Waterfall C - frame 1
    TF{0566*2/*POS*/, 168/*TID*/, $00/*PAL*/}   ; Waterfall C End - frame 3
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
    TF{1120*2/*POS*/, 032/*TID*/, $20/*PAL*/}   ; Bat A - frame 1
    TF{1161*2/*POS*/, 033/*TID*/, $20/*PAL*/}   ; Bat B - frame 3
    TF{1213*2/*POS*/, 032/*TID*/, $30/*PAL*/}   ; Bat C - frame 1
    TF{1175*2/*POS*/, 034/*TID*/, $60/*PAL*/}   ; Bat D - frame 2
    TF{1187*2/*POS*/, 032/*TID*/, $50/*PAL*/}   ; Bat E - frame 1
    TF{1033*2/*POS*/, 009/*TID*/, $20/*PAL*/}   ; Bat F - frame 1
    TF{1165*2/*POS*/, 026/*TID*/, $40/*PAL*/}   ; Flame A - frame 1
    TF{1168*2/*POS*/, 043/*TID*/, $40/*PAL*/}   ; Flame B - frame 3
    TF{1200*2/*POS*/, 024/*TID*/, $20/*PAL*/}   ; Grass A - frame 1
    TF{1201*2/*POS*/, 048/*TID*/, $20/*PAL*/}   ; Grass B - frame 1

    TF{1214*2/*POS*/, 004/*TID*/, $10/*PAL*/}   ; Grass C - frame 1
    TF{1215*2/*POS*/, 024/*TID*/, $20/*PAL*/}   ; Grass D - frame 1
    TF{1216*2/*POS*/, 004/*TID*/, $30/*PAL*/}   ; Grass E - frame 1
    TF{1219*2/*POS*/, 024/*TID*/, $40/*PAL*/}   ; Grass F - frame 1
    TF{1220*2/*POS*/, 048/*TID*/, $70/*PAL*/}   ; Grass G - frame 1
    TF{1226*2/*POS*/, 025/*TID*/, $20/*PAL*/}   ; Grass H - frame 1
    TF{1227*2/*POS*/, 048/*TID*/, $10/*PAL*/}   ; Grass I - frame 1
    TF{1228*2/*POS*/, 004/*TID*/, $20/*PAL*/}   ; Grass J - frame 1
    TF{1231*2/*POS*/, 024/*TID*/, $30/*PAL*/}   ; Grass K - frame 1
    TF{1232*2/*POS*/, 048/*TID*/, $40/*PAL*/}   ; Grass L - frame 1

    TF{1238*2/*POS*/, 024/*TID*/, $20/*PAL*/}   ; Grass M - frame 1
    TF{1239*2/*POS*/, 048/*TID*/, $70/*PAL*/}   ; Grass N - frame 1

tilemapAnimationRow2L3
    DB 22
    TF{1120*2/*POS*/, 034/*TID*/, $20/*PAL*/}   ; Bat A - frame 2
    TF{1161*2/*POS*/, 032/*TID*/, $20/*PAL*/}   ; Bat B - frame 1
    TF{1213*2/*POS*/, 034/*TID*/, $30/*PAL*/}   ; Bat C - frame 2
    TF{1175*2/*POS*/, 033/*TID*/, $60/*PAL*/}   ; Bat D - frame 3
    TF{1187*2/*POS*/, 034/*TID*/, $50/*PAL*/}   ; Bat E - frame 2
    TF{1033*2/*POS*/, 010/*TID*/, $20/*PAL*/}   ; Bat F - frame 2
    TF{1165*2/*POS*/, 041/*TID*/, $40/*PAL*/}   ; Flame A - frame 2
    TF{1168*2/*POS*/, 026/*TID*/, $40/*PAL*/}   ; Flame B - frame 1
    TF{1200*2/*POS*/, 025/*TID*/, $20/*PAL*/}   ; Grass A - frame 2
    TF{1201*2/*POS*/, 049/*TID*/, $20/*PAL*/}   ; Grass B - frame 2

    TF{1214*2/*POS*/, 005/*TID*/, $10/*PAL*/}   ; Grass C - frame 2
    TF{1215*2/*POS*/, 025/*TID*/, $20/*PAL*/}   ; Grass D - frame 2
    TF{1216*2/*POS*/, 005/*TID*/, $30/*PAL*/}   ; Grass E - frame 2
    TF{1219*2/*POS*/, 025/*TID*/, $40/*PAL*/}   ; Grass F - frame 2
    TF{1220*2/*POS*/, 049/*TID*/, $70/*PAL*/}   ; Grass G - frame 2
    TF{1226*2/*POS*/, 024/*TID*/, $20/*PAL*/}   ; Grass H - frame 2
    TF{1227*2/*POS*/, 049/*TID*/, $10/*PAL*/}   ; Grass I - frame 2
    TF{1228*2/*POS*/, 005/*TID*/, $20/*PAL*/}   ; Grass J - frame 2
    TF{1231*2/*POS*/, 025/*TID*/, $30/*PAL*/}   ; Grass K - frame 2
    TF{1232*2/*POS*/, 049/*TID*/, $40/*PAL*/}   ; Grass L - frame 2

    TF{1238*2/*POS*/, 025/*TID*/, $20/*PAL*/}   ; Grass M - frame 2
    TF{1239*2/*POS*/, 049/*TID*/, $70/*PAL*/}   ; Grass N - frame 2

tilemapAnimationRow3L3
    DB 22
    TF{1120*2/*POS*/, 033/*TID*/, $20/*PAL*/}   ; Bat A - frame 3
    TF{1161*2/*POS*/, 034/*TID*/, $20/*PAL*/}   ; Bat B - frame 2
    TF{1213*2/*POS*/, 033/*TID*/, $30/*PAL*/}   ; Bat C - frame 3
    TF{1175*2/*POS*/, 032/*TID*/, $60/*PAL*/}   ; Bat D - frame 1
    TF{1187*2/*POS*/, 033/*TID*/, $50/*PAL*/}   ; Bat E - frame 3
    TF{1033*2/*POS*/, 011/*TID*/, $20/*PAL*/}   ; Bat F - frame 3
    TF{1165*2/*POS*/, 043/*TID*/, $40/*PAL*/}   ; Flame A - frame 3
    TF{1168*2/*POS*/, 041/*TID*/, $40/*PAL*/}   ; Flame B - frame 2
    TF{1200*2/*POS*/, 027/*TID*/, $20/*PAL*/}   ; Grass A - frame 3
    TF{1201*2/*POS*/, 050/*TID*/, $20/*PAL*/}   ; Grass B - frame 3

    TF{1214*2/*POS*/, 006/*TID*/, $10/*PAL*/}   ; Grass C - frame 3
    TF{1215*2/*POS*/, 027/*TID*/, $20/*PAL*/}   ; Grass D - frame 3
    TF{1216*2/*POS*/, 006/*TID*/, $30/*PAL*/}   ; Grass E - frame 3
    TF{1219*2/*POS*/, 027/*TID*/, $40/*PAL*/}   ; Grass F - frame 3
    TF{1220*2/*POS*/, 050/*TID*/, $70/*PAL*/}   ; Grass G - frame 3
    TF{1226*2/*POS*/, 027/*TID*/, $20/*PAL*/}   ; Grass H - frame 3
    TF{1227*2/*POS*/, 050/*TID*/, $10/*PAL*/}   ; Grass I - frame 3
    TF{1228*2/*POS*/, 006/*TID*/, $20/*PAL*/}   ; Grass J - frame 3
    TF{1231*2/*POS*/, 027/*TID*/, $30/*PAL*/}   ; Grass K - frame 3
    TF{1232*2/*POS*/, 050/*TID*/, $40/*PAL*/}   ; Grass L - frame 3

    TF{1238*2/*POS*/, 027/*TID*/, $20/*PAL*/}   ; Grass M - frame 3
    TF{1239*2/*POS*/, 050/*TID*/, $70/*PAL*/}   ; Grass N - frame 3

tilemapAnimationRowsL3
    DW tilemapAnimationRow1L3, tilemapAnimationRow2L3, tilemapAnimationRow3L3

TILEMAP_ANIM_ROWS_L3    = 3

; ##############################################
; Level 5

tilemapAnimationRow1L5
    DB 19
    TF{1217*2/*POS*/, 080/*TID*/, $30/*PAL*/}   ; Pos Light Left - frame 1
    TF{1220*2/*POS*/, 080/*TID*/, $30/*PAL*/}   ; Pos Light Right - frame 1
    TF{1202*2/*POS*/, 082/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 1 - frame 1
    TF{1203*2/*POS*/, 083/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 2 - frame 1
    TF{1204*2/*POS*/, 086/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 3 - frame 1
    TF{1205*2/*POS*/, 087/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 4 - frame 1
    TF{1162*2/*POS*/, EMP/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 1 - frame 1
    TF{1163*2/*POS*/, EMP/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 2 - frame 1
    TF{1164*2/*POS*/, EMP/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 3 - frame 1
    TF{1165*2/*POS*/, EMP/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 4 - frame 1

    TF{1232*2/*POS*/, 122/*TID*/, $10/*PAL*/}   ; Saw B - Element Down 1 - frame 6
    TF{1233*2/*POS*/, 123/*TID*/, $10/*PAL*/}   ; Saw B - Element Down 2 - frame 6
    TF{1234*2/*POS*/, 126/*TID*/, $10/*PAL*/}   ; Saw B - Element Down 3 - frame 6
    TF{1235*2/*POS*/, 127/*TID*/, $10/*PAL*/}   ; Saw B - Element Down 4 - frame 6
    TF{1192*2/*POS*/, 120/*TID*/, $10/*PAL*/}   ; Saw B - Element Up 1 - frame 6
    TF{1193*2/*POS*/, 121/*TID*/, $10/*PAL*/}   ; Saw B - Element Up 2 - frame 6
    TF{1194*2/*POS*/, 124/*TID*/, $10/*PAL*/}   ; Saw B - Element Up 3 - frame 6
    TF{1195*2/*POS*/, 125/*TID*/, $10/*PAL*/}   ; Saw B - Element Up 4 - frame 6
    TF{0650*2/*POS*/, 039/*TID*/, $10/*PAL*/}   ; Tool A - Frame 1

tilemapAnimationRow2L5
    DB 14
    TF{1217*2/*POS*/, 081/*TID*/, $30/*PAL*/}   ; Pos Light Left - frame 2
    TF{1220*2/*POS*/, 081/*TID*/, $30/*PAL*/}   ; Pos Light Right - frame 2
    TF{1202*2/*POS*/, 090/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 1 - frame 2
    TF{1203*2/*POS*/, 091/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 2 - frame 2
    TF{1204*2/*POS*/, 094/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 3 - frame 2
    TF{1205*2/*POS*/, 095/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 4 - frame 2
    TF{1232*2/*POS*/, 130/*TID*/, $10/*PAL*/}   ; Saw B - Element Down 1 - frame 7
    TF{1233*2/*POS*/, 131/*TID*/, $10/*PAL*/}   ; Saw B - Element Down 2 - frame 7
    TF{1234*2/*POS*/, 134/*TID*/, $10/*PAL*/}   ; Saw B - Element Down 3 - frame 7
    TF{1235*2/*POS*/, 135/*TID*/, $10/*PAL*/}   ; Saw B - Element Down 4 - frame 7

    TF{1192*2/*POS*/, 128/*TID*/, $10/*PAL*/}   ; Saw B - Element Up 1 - frame 7
    TF{1193*2/*POS*/, 129/*TID*/, $10/*PAL*/}   ; Saw B - Element Up 2 - frame 7
    TF{1194*2/*POS*/, 132/*TID*/, $10/*PAL*/}   ; Saw B - Element Up 3 - frame 7
    TF{1195*2/*POS*/, 133/*TID*/, $10/*PAL*/}   ; Saw B - Element Up 4 - frame 7

tilemapAnimationRow3L5
    DB 19
    TF{1217*2/*POS*/, 084/*TID*/, $30/*PAL*/}   ; Pos Light Left - frame 3
    TF{1220*2/*POS*/, 084/*TID*/, $30/*PAL*/}   ; Pos Light Right - frame 3
    TF{1202*2/*POS*/, 098/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 1 - frame 3
    TF{1203*2/*POS*/, 099/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 2 - frame 3
    TF{1204*2/*POS*/, 102/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 3 - frame 3
    TF{1205*2/*POS*/, 103/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 4 - frame 3
    TF{1162*2/*POS*/, 096/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 1 - frame 3
    TF{1163*2/*POS*/, 097/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 2 - frame 3
    TF{1164*2/*POS*/, 100/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 3 - frame 3
    TF{1165*2/*POS*/, 101/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 4 - frame 3

    TF{1232*2/*POS*/, 138/*TID*/, $10/*PAL*/}   ; Saw B - Element Down 1 - frame 8
    TF{1233*2/*POS*/, 139/*TID*/, $10/*PAL*/}   ; Saw B - Element Down 2 - frame 8
    TF{1234*2/*POS*/, 142/*TID*/, $10/*PAL*/}   ; Saw B - Element Down 3 - frame 8
    TF{1235*2/*POS*/, 143/*TID*/, $10/*PAL*/}   ; Saw B - Element Down 4 - frame 8
    TF{1192*2/*POS*/, EMP/*TID*/, $10/*PAL*/}   ; Saw B - Element Up 1 - frame 8
    TF{1193*2/*POS*/, 137/*TID*/, $10/*PAL*/}   ; Saw B - Element Up 2 - frame 8
    TF{1194*2/*POS*/, 140/*TID*/, $10/*PAL*/}   ; Saw B - Element Up 3 - frame 8
    TF{1195*2/*POS*/, EMP/*TID*/, $10/*PAL*/}   ; Saw B - Element Up 4 - frame 8
    TF{0650*2/*POS*/, 052/*TID*/, $10/*PAL*/}   ; Tool A - Frame 2

tilemapAnimationRow4L5
    DB 19
    TF{1217*2/*POS*/, 085/*TID*/, $30/*PAL*/}   ; Pos Light Left - frame 4
    TF{1220*2/*POS*/, 085/*TID*/, $30/*PAL*/}   ; Pos Light Right - frame 4
    TF{1202*2/*POS*/, 106/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 1 - frame 4
    TF{1203*2/*POS*/, 107/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 2 - frame 4
    TF{1204*2/*POS*/, 110/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 3 - frame 4
    TF{1205*2/*POS*/, 111/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 4 - frame 4
    TF{1162*2/*POS*/, 104/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 1 - frame 4
    TF{1163*2/*POS*/, 105/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 2 - frame 4
    TF{1164*2/*POS*/, 108/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 3 - frame 4
    TF{1165*2/*POS*/, 109/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 4 - frame 4

    TF{1232*2/*POS*/, 082/*TID*/, $10/*PAL*/}   ; Saw B - Element Down 1 - frame 1
    TF{1233*2/*POS*/, 083/*TID*/, $10/*PAL*/}   ; Saw B - Element Down 2 - frame 1
    TF{1234*2/*POS*/, 086/*TID*/, $10/*PAL*/}   ; Saw B - Element Down 3 - frame 1
    TF{1235*2/*POS*/, 087/*TID*/, $10/*PAL*/}   ; Saw B - Element Down 4 - frame 1
    TF{1192*2/*POS*/, EMP/*TID*/, $10/*PAL*/}   ; Saw B - Element Up 1 - frame 1
    TF{1193*2/*POS*/, EMP/*TID*/, $10/*PAL*/}   ; Saw B - Element Up 2 - frame 1
    TF{1194*2/*POS*/, EMP/*TID*/, $10/*PAL*/}   ; Saw B - Element Up 3 - frame 1
    TF{1195*2/*POS*/, EMP/*TID*/, $10/*PAL*/}   ; Saw B - Element Up 4 - frame 1
    TF{0945*2/*POS*/, 039/*TID*/, $10/*PAL*/}   ; Tool B - Frame 1

tilemapAnimationRow5L5
    DB 15
    TF{1217*2/*POS*/, 085/*TID*/, $30/*PAL*/}   ; Pos Light Left - frame 5
    TF{1220*2/*POS*/, 085/*TID*/, $30/*PAL*/}   ; Pos Light Right - frame 5
    TF{1202*2/*POS*/, 114/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 1 - frame 5
    TF{1203*2/*POS*/, 115/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 2 - frame 5
    TF{1204*2/*POS*/, 118/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 3 - frame 5
    TF{1205*2/*POS*/, 119/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 4 - frame 5
    TF{1162*2/*POS*/, 112/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 1 - frame 5
    TF{1163*2/*POS*/, 113/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 2 - frame 5
    TF{1164*2/*POS*/, 116/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 3 - frame 5
    TF{1165*2/*POS*/, 117/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 4 - frame 5

    TF{1232*2/*POS*/, 090/*TID*/, $10/*PAL*/}   ; Saw B - Element Down 1 - frame 2
    TF{1233*2/*POS*/, 091/*TID*/, $10/*PAL*/}   ; Saw B - Element Down 2 - frame 2
    TF{1234*2/*POS*/, 094/*TID*/, $10/*PAL*/}   ; Saw B - Element Down 3 - frame 2
    TF{1235*2/*POS*/, 095/*TID*/, $10/*PAL*/}   ; Saw B - Element Down 4 - frame 2
    TF{0650*2/*POS*/, 042/*TID*/, $10/*PAL*/}   ; Tool A - Frame 3

tilemapAnimationRow6L5
    DB 19
    TF{1217*2/*POS*/, 084/*TID*/, $30/*PAL*/}   ; Pos Light Left - frame 6
    TF{1220*2/*POS*/, 084/*TID*/, $30/*PAL*/}   ; Pos Light Right - frame 6
    TF{1202*2/*POS*/, 122/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 1 - frame 6
    TF{1203*2/*POS*/, 123/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 2 - frame 6
    TF{1204*2/*POS*/, 126/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 3 - frame 6
    TF{1205*2/*POS*/, 127/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 4 - frame 6
    TF{1162*2/*POS*/, 120/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 1 - frame 6
    TF{1163*2/*POS*/, 121/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 2 - frame 6
    TF{1164*2/*POS*/, 124/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 3 - frame 6
    TF{1165*2/*POS*/, 125/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 4 - frame 6

    TF{1232*2/*POS*/, 098/*TID*/, $10/*PAL*/}   ; Saw B - Element Down 1 - frame 3
    TF{1233*2/*POS*/, 099/*TID*/, $10/*PAL*/}   ; Saw B - Element Down 2 - frame 3
    TF{1234*2/*POS*/, 102/*TID*/, $10/*PAL*/}   ; Saw B - Element Down 3 - frame 3
    TF{1235*2/*POS*/, 103/*TID*/, $10/*PAL*/}   ; Saw B - Element Down 4 - frame 3
    TF{1192*2/*POS*/, 096/*TID*/, $10/*PAL*/}   ; Saw B - Element Up 1 - frame 3
    TF{1193*2/*POS*/, 097/*TID*/, $10/*PAL*/}   ; Saw B - Element Up 2 - frame 3
    TF{1194*2/*POS*/, 100/*TID*/, $10/*PAL*/}   ; Saw B - Element Up 3 - frame 3
    TF{1195*2/*POS*/, 101/*TID*/, $10/*PAL*/}   ; Saw B - Element Up 4 - frame 3
    TF{0945*2/*POS*/, 052/*TID*/, $10/*PAL*/}   ; Tool B - Frame 2

tilemapAnimationRow7L5
    DB 18
    TF{1217*2/*POS*/, 081/*TID*/, $30/*PAL*/}   ; Pos Light Left - frame 7
    TF{1220*2/*POS*/, 081/*TID*/, $30/*PAL*/}   ; Pos Light Right - frame 7
    TF{1202*2/*POS*/, 130/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 1 - frame 7
    TF{1203*2/*POS*/, 131/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 2 - frame 7
    TF{1204*2/*POS*/, 134/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 3 - frame 7
    TF{1205*2/*POS*/, 135/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 4 - frame 7
    TF{1162*2/*POS*/, 128/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 1 - frame 7
    TF{1163*2/*POS*/, 129/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 2 - frame 7
    TF{1164*2/*POS*/, 132/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 3 - frame 7
    TF{1165*2/*POS*/, 133/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 4 - frame 7

    TF{1232*2/*POS*/, 106/*TID*/, $10/*PAL*/}   ; Saw B - Element Down 1 - frame 4
    TF{1233*2/*POS*/, 107/*TID*/, $10/*PAL*/}   ; Saw B - Element Down 2 - frame 4
    TF{1234*2/*POS*/, 110/*TID*/, $10/*PAL*/}   ; Saw B - Element Down 3 - frame 4
    TF{1235*2/*POS*/, 111/*TID*/, $10/*PAL*/}   ; Saw B - Element Down 4 - frame 4
    TF{1192*2/*POS*/, 104/*TID*/, $10/*PAL*/}   ; Saw B - Element Up 1 - frame 4
    TF{1193*2/*POS*/, 105/*TID*/, $10/*PAL*/}   ; Saw B - Element Up 2 - frame 4
    TF{1194*2/*POS*/, 108/*TID*/, $10/*PAL*/}   ; Saw B - Element Up 3 - frame 4
    TF{1195*2/*POS*/, 109/*TID*/, $10/*PAL*/}   ; Saw B - Element Up 4 - frame 4

tilemapAnimationRow8L5
    DB 19
    TF{1217*2/*POS*/, 080/*TID*/, $30/*PAL*/}   ; Pos Light Left - frame 8
    TF{1220*2/*POS*/, 080/*TID*/, $30/*PAL*/}   ; Pos Light Right - frame 8
    TF{1202*2/*POS*/, 138/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 1 - frame 8
    TF{1203*2/*POS*/, 139/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 2 - frame 8
    TF{1204*2/*POS*/, 142/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 3 - frame 8
    TF{1205*2/*POS*/, 143/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 4 - frame 8
    TF{1162*2/*POS*/, EMP/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 1 - frame 8
    TF{1163*2/*POS*/, 137/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 2 - frame 8
    TF{1164*2/*POS*/, 140/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 3 - frame 8
    TF{1165*2/*POS*/, EMP/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 4 - frame 8

    TF{1232*2/*POS*/, 114/*TID*/, $10/*PAL*/}   ; Saw B - Element Down 1 - frame 5
    TF{1233*2/*POS*/, 115/*TID*/, $10/*PAL*/}   ; Saw B - Element Down 2 - frame 5
    TF{1234*2/*POS*/, 118/*TID*/, $10/*PAL*/}   ; Saw B - Element Down 3 - frame 5
    TF{1235*2/*POS*/, 119/*TID*/, $10/*PAL*/}   ; Saw B - Element Down 4 - frame 5
    TF{1192*2/*POS*/, 112/*TID*/, $10/*PAL*/}   ; Saw B - Element Up 1 - frame 5
    TF{1193*2/*POS*/, 113/*TID*/, $10/*PAL*/}   ; Saw B - Element Up 2 - frame 5
    TF{1194*2/*POS*/, 116/*TID*/, $10/*PAL*/}   ; Saw B - Element Up 3 - frame 5
    TF{1195*2/*POS*/, 117/*TID*/, $10/*PAL*/}   ; Saw B - Element Up 4 - frame 5
    TF{0945*2/*POS*/, 042/*TID*/, $10/*PAL*/}   ; Tool B - Frame 3

tilemapAnimationRowsL5
    DW tilemapAnimationRow1L5, tilemapAnimationRow2L5, tilemapAnimationRow3L5, tilemapAnimationRow4L5, tilemapAnimationRow5L5, tilemapAnimationRow6L5, tilemapAnimationRow7L5, tilemapAnimationRow8L5

TILEMAP_ANIM_ROWS_L5    = 8


; ##############################################
; Level 6
tilemapAnimationRow1L6
    DB 25
    TF{0885*2/*POS*/, 148/*TID*/, $10/*PAL*/}   ; Pole Light Left C - frame 1
    TF{0886*2/*POS*/, 149/*TID*/, $10/*PAL*/}   ; Pole Light Right C - frame 1
    TF{0485*2/*POS*/, 148/*TID*/, $10/*PAL*/}   ; Pole Light Left B - frame 1
    TF{0486*2/*POS*/, 149/*TID*/, $10/*PAL*/}   ; Pole Light Right B - frame 1
    TF{0165*2/*POS*/, 168/*TID*/, $10/*PAL*/}   ; Pole Light Left A - frame 3
    TF{0166*2/*POS*/, 169/*TID*/, $10/*PAL*/}   ; Pole Light Right A - frame 3
    TF{0195*2/*POS*/, 154/*TID*/, $10/*PAL*/}   ; Pole Light Left D - frame 2
    TF{0196*2/*POS*/, 155/*TID*/, $10/*PAL*/}   ; Pole Light Right D - frame 2
    TF{0715*2/*POS*/, 190/*TID*/, $10/*PAL*/}   ; Pole Light Left E - frame 4
    TF{0716*2/*POS*/, 191/*TID*/, $10/*PAL*/}   ; Pole Light Right E - frame 4

    TF{0945*2/*POS*/, 039/*TID*/, $10/*PAL*/}   ; Tool A - Frame 1
    TF{1207*2/*POS*/, 080/*TID*/, $30/*PAL*/}   ; Rocket Light Left - Frame 1
    TF{1210*2/*POS*/, 080/*TID*/, $30/*PAL*/}   ; Rocket Right Left - Frame 1
    TF{0347*2/*POS*/, 050/*TID*/, $10/*PAL*/}   ; Post Left Down A - Frame 1
    TF{0348*2/*POS*/, 051/*TID*/, $10/*PAL*/}   ; Post Right Down A - Frame 1
    TF{0307*2/*POS*/, EMP/*TID*/, $10/*PAL*/}   ; Post Left Up A - Frame 1
    TF{0308*2/*POS*/, EMP/*TID*/, $10/*PAL*/}   ; Post Right Up A - Frame 1
    TF{1232*2/*POS*/, 122/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 1 - frame 6
    TF{1233*2/*POS*/, 123/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 2 - frame 6
    TF{1234*2/*POS*/, 126/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 3 - frame 6

    TF{1235*2/*POS*/, 127/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 4 - frame 6
    TF{1192*2/*POS*/, 120/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 1 - frame 6
    TF{1193*2/*POS*/, 121/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 2 - frame 6
    TF{1194*2/*POS*/, 124/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 3 - frame 6
    TF{1195*2/*POS*/, 125/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 4 - frame 6

tilemapAnimationRow2L6
    DB 23

    TF{0885*2/*POS*/, 154/*TID*/, $10/*PAL*/}   ; Pole Light Left C - frame 2
    TF{0886*2/*POS*/, 155/*TID*/, $10/*PAL*/}   ; Pole Light Right C - frame 2
    TF{0485*2/*POS*/, 154/*TID*/, $10/*PAL*/}   ; Pole Light Left B - frame 2
    TF{0486*2/*POS*/, 155/*TID*/, $10/*PAL*/}   ; Pole Light Right B - frame 2
    TF{0165*2/*POS*/, 190/*TID*/, $10/*PAL*/}   ; Pole Light Left A - frame 4
    TF{0166*2/*POS*/, 191/*TID*/, $10/*PAL*/}   ; Pole Light Right A - frame 4
    TF{0195*2/*POS*/, 168/*TID*/, $10/*PAL*/}   ; Pole Light Left D - frame 3
    TF{0196*2/*POS*/, 169/*TID*/, $10/*PAL*/}   ; Pole Light Right D - frame 3
    TF{0715*2/*POS*/, 148/*TID*/, $10/*PAL*/}   ; Pole Light Left E - frame 1
    TF{0716*2/*POS*/, 149/*TID*/, $10/*PAL*/}   ; Pole Light Right E - frame 1

    TF{0945*2/*POS*/, 052/*TID*/, $10/*PAL*/}   ; Tool A - Frame 2
    TF{1207*2/*POS*/, 081/*TID*/, $30/*PAL*/}   ; Rocket Light Left - Frame 2
    TF{1210*2/*POS*/, 081/*TID*/, $30/*PAL*/}   ; Rocket Right Left - Frame 2
    TF{0347*2/*POS*/, 054/*TID*/, $10/*PAL*/}   ; Post Left Down A - Frame 1
    TF{0348*2/*POS*/, 055/*TID*/, $10/*PAL*/}   ; Post Right Down A - Frame 1
    TF{1232*2/*POS*/, 130/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 1 - frame 7
    TF{1233*2/*POS*/, 131/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 2 - frame 7
    TF{1234*2/*POS*/, 134/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 3 - frame 7
    TF{1235*2/*POS*/, 135/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 4 - frame 7
    TF{1192*2/*POS*/, 128/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 1 - frame 7

    TF{1193*2/*POS*/, 129/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 2 - frame 7
    TF{1194*2/*POS*/, 132/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 3 - frame 7
    TF{1195*2/*POS*/, 133/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 4 - frame 7

tilemapAnimationRow3L6
    DB 25
    TF{0885*2/*POS*/, 168/*TID*/, $10/*PAL*/}   ; Pole Light Left C - frame 3
    TF{0886*2/*POS*/, 169/*TID*/, $10/*PAL*/}   ; Pole Light Right C - frame 3
    TF{0485*2/*POS*/, 168/*TID*/, $10/*PAL*/}   ; Pole Light Left B - frame 3
    TF{0486*2/*POS*/, 169/*TID*/, $10/*PAL*/}   ; Pole Light Right B - frame 3
    TF{0165*2/*POS*/, 148/*TID*/, $10/*PAL*/}   ; Pole Light Left A - frame 1
    TF{0166*2/*POS*/, 149/*TID*/, $10/*PAL*/}   ; Pole Light Right A - frame 1
    TF{0195*2/*POS*/, 190/*TID*/, $10/*PAL*/}   ; Pole Light Left D - frame 4
    TF{0196*2/*POS*/, 191/*TID*/, $10/*PAL*/}   ; Pole Light Right D - frame 4
    TF{0715*2/*POS*/, 154/*TID*/, $10/*PAL*/}   ; Pole Light Left E - frame 2
    TF{0716*2/*POS*/, 155/*TID*/, $10/*PAL*/}   ; Pole Light Right E - frame 2

    TF{0945*2/*POS*/, 042/*TID*/, $10/*PAL*/}   ; Tool A - Frame 3
    TF{1207*2/*POS*/, 084/*TID*/, $30/*PAL*/}   ; Rocket Light Left - Frame 3
    TF{1210*2/*POS*/, 084/*TID*/, $30/*PAL*/}   ; Rocket Right Left - Frame 3
    TF{0347*2/*POS*/, 058/*TID*/, $10/*PAL*/}   ; Post Left Down A - Frame 1
    TF{0348*2/*POS*/, 059/*TID*/, $10/*PAL*/}   ; Post Right Down A - Frame 1
    TF{0307*2/*POS*/, 056/*TID*/, $10/*PAL*/}   ; Post Left Up A - Frame 1
    TF{0308*2/*POS*/, 057/*TID*/, $10/*PAL*/}   ; Post Right Up A - Frame 1
    TF{1232*2/*POS*/, 138/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 1 - frame 8
    TF{1233*2/*POS*/, 139/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 2 - frame 8
    TF{1234*2/*POS*/, 142/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 3 - frame 8

    TF{1235*2/*POS*/, 143/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 4 - frame 8
    TF{1192*2/*POS*/, EMP/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 1 - frame 8
    TF{1193*2/*POS*/, 137/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 2 - frame 8
    TF{1194*2/*POS*/, 140/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 3 - frame 8
    TF{1195*2/*POS*/, EMP/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 4 - frame 8

tilemapAnimationRow4L6
    DB 25
    TF{0885*2/*POS*/, 190/*TID*/, $10/*PAL*/}   ; Pole Light Left C - frame 4
    TF{0886*2/*POS*/, 191/*TID*/, $10/*PAL*/}   ; Pole Light Right C - frame 4
    TF{0485*2/*POS*/, 190/*TID*/, $10/*PAL*/}   ; Pole Light Left B - frame 4
    TF{0486*2/*POS*/, 191/*TID*/, $10/*PAL*/}   ; Pole Light Right B - frame 4
    TF{0165*2/*POS*/, 154/*TID*/, $10/*PAL*/}   ; Pole Light Left A - frame 2
    TF{0166*2/*POS*/, 155/*TID*/, $10/*PAL*/}   ; Pole Light Right A - frame 2
    TF{0195*2/*POS*/, 148/*TID*/, $10/*PAL*/}   ; Pole Light Left D - frame 1
    TF{0196*2/*POS*/, 149/*TID*/, $10/*PAL*/}   ; Pole Light Right D - frame 1
    TF{0715*2/*POS*/, 168/*TID*/, $10/*PAL*/}   ; Pole Light Left E - frame 3
    TF{0716*2/*POS*/, 169/*TID*/, $10/*PAL*/}   ; Pole Light Right E - frame 3

    TF{0945*2/*POS*/, 039/*TID*/, $10/*PAL*/}   ; Tool A - Frame 1
    TF{1207*2/*POS*/, 085/*TID*/, $30/*PAL*/}   ; Rocket Light Left - Frame 4
    TF{1210*2/*POS*/, 085/*TID*/, $30/*PAL*/}   ; Rocket Right Left - Frame 4
    TF{0347*2/*POS*/, 062/*TID*/, $10/*PAL*/}   ; Post Left Down A - Frame 1
    TF{0348*2/*POS*/, 063/*TID*/, $10/*PAL*/}   ; Post Right Down A - Frame 1
    TF{0307*2/*POS*/, 060/*TID*/, $10/*PAL*/}   ; Post Left Up A - Frame 1
    TF{0308*2/*POS*/, 061/*TID*/, $10/*PAL*/}   ; Post Right Up A - Frame 1
    TF{1232*2/*POS*/, 082/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 1 - frame 1
    TF{1233*2/*POS*/, 083/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 2 - frame 1
    TF{1234*2/*POS*/, 086/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 3 - frame 1

    TF{1235*2/*POS*/, 087/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 4 - frame 1
    TF{1192*2/*POS*/, EMP/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 1 - frame 1
    TF{1193*2/*POS*/, EMP/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 2 - frame 1
    TF{1194*2/*POS*/, EMP/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 3 - frame 1
    TF{1195*2/*POS*/, EMP/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 4 - frame 1

tilemapAnimationRow5L6
    DB 21
    TF{0885*2/*POS*/, 148/*TID*/, $10/*PAL*/}   ; Pole Light Left C - frame 1
    TF{0886*2/*POS*/, 149/*TID*/, $10/*PAL*/}   ; Pole Light Right C - frame 1
    TF{0485*2/*POS*/, 148/*TID*/, $10/*PAL*/}   ; Pole Light Left B - frame 1
    TF{0486*2/*POS*/, 149/*TID*/, $10/*PAL*/}   ; Pole Light Right B - frame 1
    TF{0165*2/*POS*/, 168/*TID*/, $10/*PAL*/}   ; Pole Light Left A - frame 3
    TF{0166*2/*POS*/, 169/*TID*/, $10/*PAL*/}   ; Pole Light Right A - frame 3
    TF{0195*2/*POS*/, 154/*TID*/, $10/*PAL*/}   ; Pole Light Left D - frame 2
    TF{0196*2/*POS*/, 155/*TID*/, $10/*PAL*/}   ; Pole Light Right D - frame 2
    TF{0715*2/*POS*/, 190/*TID*/, $10/*PAL*/}   ; Pole Light Left E - frame 4
    TF{0716*2/*POS*/, 191/*TID*/, $10/*PAL*/}   ; Pole Light Right E - frame 4

    TF{0945*2/*POS*/, 052/*TID*/, $10/*PAL*/}   ; Tool A - Frame 2
    TF{1207*2/*POS*/, 080/*TID*/, $30/*PAL*/}   ; Rocket Light Left - Frame 5
    TF{1210*2/*POS*/, 080/*TID*/, $30/*PAL*/}   ; Rocket Right Left - Frame 5
    TF{0347*2/*POS*/, 066/*TID*/, $10/*PAL*/}   ; Post Left Down A - Frame 1
    TF{0348*2/*POS*/, 067/*TID*/, $10/*PAL*/}   ; Post Right Down A - Frame 1
    TF{0307*2/*POS*/, 064/*TID*/, $10/*PAL*/}   ; Post Left Up A - Frame 1
    TF{0308*2/*POS*/, 065/*TID*/, $10/*PAL*/}   ; Post Right Up A - Frame 1
    TF{1232*2/*POS*/, 090/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 1 - frame 2
    TF{1233*2/*POS*/, 091/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 2 - frame 2
    TF{1234*2/*POS*/, 094/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 3 - frame 2

    TF{1235*2/*POS*/, 095/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 4 - frame 2

tilemapAnimationRow6L6
    DB 25
    TF{0885*2/*POS*/, 154/*TID*/, $10/*PAL*/}   ; Pole Light Left C - frame 2
    TF{0886*2/*POS*/, 155/*TID*/, $10/*PAL*/}   ; Pole Light Right C - frame 2
    TF{0485*2/*POS*/, 154/*TID*/, $10/*PAL*/}   ; Pole Light Left B - frame 2
    TF{0486*2/*POS*/, 155/*TID*/, $10/*PAL*/}   ; Pole Light Right B - frame 2
    TF{0165*2/*POS*/, 190/*TID*/, $10/*PAL*/}   ; Pole Light Left A - frame 4
    TF{0166*2/*POS*/, 191/*TID*/, $10/*PAL*/}   ; Pole Light Right A - frame 4
    TF{0195*2/*POS*/, 168/*TID*/, $10/*PAL*/}   ; Pole Light Left D - frame 3
    TF{0196*2/*POS*/, 169/*TID*/, $10/*PAL*/}   ; Pole Light Right D - frame 3
    TF{0715*2/*POS*/, 148/*TID*/, $10/*PAL*/}   ; Pole Light Left E - frame 1
    TF{0716*2/*POS*/, 149/*TID*/, $10/*PAL*/}   ; Pole Light Right E - frame 1

    TF{0945*2/*POS*/, 042/*TID*/, $10/*PAL*/}   ; Tool A - Frame 3
    TF{1207*2/*POS*/, 081/*TID*/, $30/*PAL*/}   ; Rocket Light Left - Frame 6
    TF{1210*2/*POS*/, 081/*TID*/, $30/*PAL*/}   ; Rocket Right Left - Frame 6
    TF{0347*2/*POS*/, 070/*TID*/, $10/*PAL*/}   ; Post Left Down A - Frame 1
    TF{0348*2/*POS*/, 071/*TID*/, $10/*PAL*/}   ; Post Right Down A - Frame 1
    TF{0307*2/*POS*/, 068/*TID*/, $10/*PAL*/}   ; Post Left Up A - Frame 1
    TF{0308*2/*POS*/, 069/*TID*/, $10/*PAL*/}   ; Post Right Up A - Frame 1
    TF{1232*2/*POS*/, 098/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 1 - frame 3
    TF{1233*2/*POS*/, 099/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 2 - frame 3
    TF{1234*2/*POS*/, 102/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 3 - frame 3

    TF{1235*2/*POS*/, 103/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 4 - frame 3
    TF{1192*2/*POS*/, 096/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 1 - frame 3
    TF{1193*2/*POS*/, 097/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 2 - frame 3
    TF{1194*2/*POS*/, 100/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 3 - frame 3
    TF{1195*2/*POS*/, 101/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 4 - frame 3

tilemapAnimationRow7L6
    DB 25
    TF{0885*2/*POS*/, 168/*TID*/, $10/*PAL*/}   ; Pole Light Left C - frame 3
    TF{0886*2/*POS*/, 169/*TID*/, $10/*PAL*/}   ; Pole Light Right C - frame 3
    TF{0485*2/*POS*/, 168/*TID*/, $10/*PAL*/}   ; Pole Light Left B - frame 3
    TF{0486*2/*POS*/, 169/*TID*/, $10/*PAL*/}   ; Pole Light Right B - frame 3
    TF{0165*2/*POS*/, 148/*TID*/, $10/*PAL*/}   ; Pole Light Left A - frame 1
    TF{0166*2/*POS*/, 149/*TID*/, $10/*PAL*/}   ; Pole Light Right A - frame 1
    TF{0195*2/*POS*/, 190/*TID*/, $10/*PAL*/}   ; Pole Light Left D - frame 4
    TF{0196*2/*POS*/, 191/*TID*/, $10/*PAL*/}   ; Pole Light Right D - frame 4
    TF{0715*2/*POS*/, 154/*TID*/, $10/*PAL*/}   ; Pole Light Left E - frame 2
    TF{0716*2/*POS*/, 155/*TID*/, $10/*PAL*/}   ; Pole Light Right E - frame 2

    TF{0945*2/*POS*/, 039/*TID*/, $10/*PAL*/}   ; Tool A - Frame 1
    TF{1207*2/*POS*/, 084/*TID*/, $30/*PAL*/}   ; Rocket Light Left - Frame 7
    TF{1210*2/*POS*/, 084/*TID*/, $30/*PAL*/}   ; Rocket Right Left - Frame 7
    TF{0347*2/*POS*/, 074/*TID*/, $10/*PAL*/}   ; Post Left Down A - Frame 1
    TF{0348*2/*POS*/, 075/*TID*/, $10/*PAL*/}   ; Post Right Down A - Frame 1
    TF{0307*2/*POS*/, 072/*TID*/, $10/*PAL*/}   ; Post Left Up A - Frame 1
    TF{0308*2/*POS*/, 073/*TID*/, $10/*PAL*/}   ; Post Right Up A - Frame 1
    TF{1232*2/*POS*/, 106/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 1 - frame 4
    TF{1233*2/*POS*/, 107/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 2 - frame 4
    TF{1234*2/*POS*/, 110/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 3 - frame 4

    TF{1235*2/*POS*/, 111/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 4 - frame 4
    TF{1192*2/*POS*/, 104/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 1 - frame 4
    TF{1193*2/*POS*/, 105/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 2 - frame 4
    TF{1194*2/*POS*/, 108/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 3 - frame 4
    TF{1195*2/*POS*/, 109/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 4 - frame 4

tilemapAnimationRow8L6
    DB 25
    TF{0885*2/*POS*/, 190/*TID*/, $10/*PAL*/}   ; Pole Light Left C - frame 4
    TF{0886*2/*POS*/, 191/*TID*/, $10/*PAL*/}   ; Pole Light Right C - frame 4
    TF{0485*2/*POS*/, 190/*TID*/, $10/*PAL*/}   ; Pole Light Left B - frame 4
    TF{0486*2/*POS*/, 191/*TID*/, $10/*PAL*/}   ; Pole Light Right B - frame 4
    TF{0165*2/*POS*/, 154/*TID*/, $10/*PAL*/}   ; Pole Light Left A - frame 2
    TF{0166*2/*POS*/, 155/*TID*/, $10/*PAL*/}   ; Pole Light Right A - frame 2
    TF{0195*2/*POS*/, 148/*TID*/, $10/*PAL*/}   ; Pole Light Left D - frame 1
    TF{0196*2/*POS*/, 149/*TID*/, $10/*PAL*/}   ; Pole Light Right D - frame 1
    TF{0715*2/*POS*/, 168/*TID*/, $10/*PAL*/}   ; Pole Light Left E - frame 3
    TF{0716*2/*POS*/, 169/*TID*/, $10/*PAL*/}   ; Pole Light Right E - frame 3

    TF{0945*2/*POS*/, 052/*TID*/, $10/*PAL*/}   ; Tool A - Frame 2
    TF{1207*2/*POS*/, 085/*TID*/, $30/*PAL*/}   ; Rocket Light Left - Frame 8
    TF{1210*2/*POS*/, 085/*TID*/, $30/*PAL*/}   ; Rocket Right Left - Frame 8
    TF{0347*2/*POS*/, 078/*TID*/, $10/*PAL*/}   ; Post Left Down A - Frame 1
    TF{0348*2/*POS*/, 079/*TID*/, $10/*PAL*/}   ; Post Right Down A - Frame 1
    TF{0307*2/*POS*/, 076/*TID*/, $10/*PAL*/}   ; Post Left Up A - Frame 1
    TF{0308*2/*POS*/, 077/*TID*/, $10/*PAL*/}   ; Post Right Up A - Frame 1
    TF{1232*2/*POS*/, 114/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 1 - frame 5
    TF{1233*2/*POS*/, 115/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 2 - frame 5
    TF{1234*2/*POS*/, 118/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 3 - frame 5

    TF{1235*2/*POS*/, 119/*TID*/, $10/*PAL*/}   ; Saw A - Element Down 4 - frame 5
    TF{1192*2/*POS*/, 112/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 1 - frame 5
    TF{1193*2/*POS*/, 113/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 2 - frame 5
    TF{1194*2/*POS*/, 116/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 3 - frame 5
    TF{1195*2/*POS*/, 117/*TID*/, $10/*PAL*/}   ; Saw A - Element Up 4 - frame 5

tilemapAnimationRowsL6
    DW tilemapAnimationRow1L6, tilemapAnimationRow2L6, tilemapAnimationRow3L6, tilemapAnimationRow4L6, tilemapAnimationRow5L6
    DW tilemapAnimationRow6L6, tilemapAnimationRow7L6, tilemapAnimationRow8L6

TILEMAP_ANIM_ROWS_L6    = 8

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

    ; ##########################################
    ASSERT $$ == dbs.TILE_ANIMATION_D34         ; Data should remain in the same bank

; ##############################################
; Level 9
tilemapAnimationRow1L9
    DB 25
    TF{1160*2/*POS*/, 048/*TID*/, $30/*PAL*/}   ; Robot A - frame 1
    TF{1161*2/*POS*/, 049/*TID*/, $30/*PAL*/}   ; Robot A - frame 1
    TF{1200*2/*POS*/, 050/*TID*/, $30/*PAL*/}   ; Robot A - frame 1
    TF{1201*2/*POS*/, 051/*TID*/, $30/*PAL*/}   ; Robot A - frame 1

    TF{0987*2/*POS*/, 064/*TID*/, $30/*PAL*/}   ; Robot B - frame 1
    TF{0988*2/*POS*/, 065/*TID*/, $30/*PAL*/}   ; Robot B - frame 1
    TF{1027*2/*POS*/, 066/*TID*/, $30/*PAL*/}   ; Robot B - frame 1
    TF{1028*2/*POS*/, 067/*TID*/, $30/*PAL*/}   ; Robot B - frame 1
    TF{1067*2/*POS*/, 080/*TID*/, $30/*PAL*/}   ; Robot B - frame 1
    TF{1068*2/*POS*/, 081/*TID*/, $30/*PAL*/}   ; Robot B - frame 1

    TF{0741*2/*POS*/, 130/*TID*/, $30/*PAL*/}   ; Robot C - frame 1
    TF{0742*2/*POS*/, 131/*TID*/, $30/*PAL*/}   ; Robot C - frame 1
    TF{0781*2/*POS*/, 082/*TID*/, $30/*PAL*/}   ; Robot C - frame 1
    TF{0782*2/*POS*/, 083/*TID*/, $30/*PAL*/}   ; Robot C - frame 1
    TF{0821*2/*POS*/, 096/*TID*/, $30/*PAL*/}   ; Robot C - frame 1
    TF{0822*2/*POS*/, 097/*TID*/, $30/*PAL*/}   ; Robot C - frame 1
    TF{0861*2/*POS*/, 098/*TID*/, $30/*PAL*/}   ; Robot C - frame 1
    TF{0862*2/*POS*/, 099/*TID*/, $30/*PAL*/}   ; Robot C - frame 1

    TF{1257*2/*POS*/, 134/*TID*/, $10/*PAL*/}   ; Launch Pad - frame 1
    TF{1258*2/*POS*/, 135/*TID*/, $10/*PAL*/}   ; Launch Pad - frame 1
    TF{1259*2/*POS*/, 138/*TID*/, $10/*PAL*/}   ; Launch Pad - frame 1

    TF{0485*2/*POS*/, 164/*TID*/, $10/*PAL*/}   ; Tower A - frame 1
    TF{0486*2/*POS*/, 165/*TID*/, $10/*PAL*/}   ; Tower A - frame 1

    TF{0271*2/*POS*/, 164/*TID*/, $10/*PAL*/}   ; Tower B - frame 1
    TF{0272*2/*POS*/, 165/*TID*/, $10/*PAL*/}   ; Tower B - frame 1

tilemapAnimationRow2L9
    DB 25
    TF{1160*2/*POS*/, 052/*TID*/, $30/*PAL*/}   ; Robot A - frame 2
    TF{1161*2/*POS*/, 053/*TID*/, $30/*PAL*/}   ; Robot A - frame 2
    TF{1200*2/*POS*/, 054/*TID*/, $30/*PAL*/}   ; Robot A - frame 2
    TF{1201*2/*POS*/, 055/*TID*/, $30/*PAL*/}   ; Robot A - frame 2

    TF{0987*2/*POS*/, 068/*TID*/, $30/*PAL*/}   ; Robot B - frame 2
    TF{0988*2/*POS*/, 069/*TID*/, $30/*PAL*/}   ; Robot B - frame 2
    TF{1027*2/*POS*/, 070/*TID*/, $30/*PAL*/}   ; Robot B - frame 2
    TF{1028*2/*POS*/, 071/*TID*/, $30/*PAL*/}   ; Robot B - frame 2
    TF{1067*2/*POS*/, 084/*TID*/, $30/*PAL*/}   ; Robot B - frame 2
    TF{1068*2/*POS*/, 085/*TID*/, $30/*PAL*/}   ; Robot B - frame 2

    TF{0741*2/*POS*/, 130/*TID*/, $30/*PAL*/}   ; Robot C - frame 2
    TF{0742*2/*POS*/, 131/*TID*/, $30/*PAL*/}   ; Robot C - frame 2
    TF{0781*2/*POS*/, 086/*TID*/, $30/*PAL*/}   ; Robot C - frame 2
    TF{0782*2/*POS*/, 087/*TID*/, $30/*PAL*/}   ; Robot C - frame 2
    TF{0821*2/*POS*/, 100/*TID*/, $30/*PAL*/}   ; Robot C - frame 2
    TF{0822*2/*POS*/, 101/*TID*/, $30/*PAL*/}   ; Robot C - frame 2
    TF{0861*2/*POS*/, 102/*TID*/, $30/*PAL*/}   ; Robot C - frame 2
    TF{0862*2/*POS*/, 103/*TID*/, $30/*PAL*/}   ; Robot C - frame 2

    TF{1257*2/*POS*/, 148/*TID*/, $10/*PAL*/}   ; Launch Pad - frame 2
    TF{1258*2/*POS*/, 149/*TID*/, $10/*PAL*/}   ; Launch Pad - frame 2
    TF{1259*2/*POS*/, 152/*TID*/, $10/*PAL*/}   ; Launch Pad - frame 2

    TF{0485*2/*POS*/, 060/*TID*/, $10/*PAL*/}   ; Tower A - frame 2
    TF{0486*2/*POS*/, 061/*TID*/, $10/*PAL*/}   ; Tower A - frame 2

    TF{0271*2/*POS*/, 060/*TID*/, $10/*PAL*/}   ; Tower B - frame 2
    TF{0272*2/*POS*/, 061/*TID*/, $10/*PAL*/}   ; Tower B - frame 2

tilemapAnimationRow3L9
    DB 25
    TF{1160*2/*POS*/, 056/*TID*/, $30/*PAL*/}   ; Robot A - frame 3
    TF{1161*2/*POS*/, 057/*TID*/, $30/*PAL*/}   ; Robot A - frame 3
    TF{1200*2/*POS*/, 058/*TID*/, $30/*PAL*/}   ; Robot A - frame 3
    TF{1201*2/*POS*/, 059/*TID*/, $30/*PAL*/}   ; Robot A - frame 3

    TF{0987*2/*POS*/, 072/*TID*/, $30/*PAL*/}   ; Robot B - frame 3
    TF{0988*2/*POS*/, 073/*TID*/, $30/*PAL*/}   ; Robot B - frame 3
    TF{1027*2/*POS*/, 074/*TID*/, $30/*PAL*/}   ; Robot B - frame 3
    TF{1028*2/*POS*/, 075/*TID*/, $30/*PAL*/}   ; Robot B - frame 3
    TF{1067*2/*POS*/, 088/*TID*/, $30/*PAL*/}   ; Robot B - frame 3
    TF{1068*2/*POS*/, 089/*TID*/, $30/*PAL*/}   ; Robot B - frame 3

    TF{0741*2/*POS*/, 130/*TID*/, $30/*PAL*/}   ; Robot C - frame 3
    TF{0742*2/*POS*/, 131/*TID*/, $30/*PAL*/}   ; Robot C - frame 3
    TF{0781*2/*POS*/, 090/*TID*/, $30/*PAL*/}   ; Robot C - frame 3
    TF{0782*2/*POS*/, 091/*TID*/, $30/*PAL*/}   ; Robot C - frame 3
    TF{0821*2/*POS*/, 104/*TID*/, $30/*PAL*/}   ; Robot C - frame 3
    TF{0822*2/*POS*/, 105/*TID*/, $30/*PAL*/}   ; Robot C - frame 3
    TF{0861*2/*POS*/, 106/*TID*/, $30/*PAL*/}   ; Robot C - frame 3
    TF{0862*2/*POS*/, 107/*TID*/, $30/*PAL*/}   ; Robot C - frame 3

    TF{1257*2/*POS*/, 150/*TID*/, $10/*PAL*/}   ; Launch Pad - frame 3
    TF{1258*2/*POS*/, 151/*TID*/, $10/*PAL*/}   ; Launch Pad - frame 3
    TF{1259*2/*POS*/, 154/*TID*/, $10/*PAL*/}   ; Launch Pad - frame 3

    TF{0485*2/*POS*/, 164/*TID*/, $10/*PAL*/}   ; Tower A - frame 1
    TF{0486*2/*POS*/, 165/*TID*/, $10/*PAL*/}   ; Tower A - frame 1

    TF{0271*2/*POS*/, 164/*TID*/, $10/*PAL*/}   ; Tower B - frame 1
    TF{0272*2/*POS*/, 165/*TID*/, $10/*PAL*/}   ; Tower B - frame 1

tilemapAnimationRow4L9
    DB 25
    TF{1160*2/*POS*/, 048/*TID*/, $30/*PAL*/}   ; Robot A - frame 1
    TF{1161*2/*POS*/, 049/*TID*/, $30/*PAL*/}   ; Robot A - frame 1
    TF{1200*2/*POS*/, 050/*TID*/, $30/*PAL*/}   ; Robot A - frame 1
    TF{1201*2/*POS*/, 051/*TID*/, $30/*PAL*/}   ; Robot A - frame 1

    TF{0987*2/*POS*/, 064/*TID*/, $30/*PAL*/}   ; Robot B - frame 1
    TF{0988*2/*POS*/, 065/*TID*/, $30/*PAL*/}   ; Robot B - frame 1
    TF{1027*2/*POS*/, 066/*TID*/, $30/*PAL*/}   ; Robot B - frame 1
    TF{1028*2/*POS*/, 067/*TID*/, $30/*PAL*/}   ; Robot B - frame 1
    TF{1067*2/*POS*/, 080/*TID*/, $30/*PAL*/}   ; Robot B - frame 1
    TF{1068*2/*POS*/, 081/*TID*/, $30/*PAL*/}   ; Robot B - frame 1

    TF{0741*2/*POS*/, 130/*TID*/, $30/*PAL*/}   ; Robot C - frame 4
    TF{0742*2/*POS*/, 131/*TID*/, $30/*PAL*/}   ; Robot C - frame 4
    TF{0781*2/*POS*/, 094/*TID*/, $30/*PAL*/}   ; Robot C - frame 4
    TF{0782*2/*POS*/, 095/*TID*/, $30/*PAL*/}   ; Robot C - frame 4
    TF{0821*2/*POS*/, 108/*TID*/, $30/*PAL*/}   ; Robot C - frame 4
    TF{0822*2/*POS*/, 109/*TID*/, $30/*PAL*/}   ; Robot C - frame 4
    TF{0861*2/*POS*/, 110/*TID*/, $30/*PAL*/}   ; Robot C - frame 4
    TF{0862*2/*POS*/, 111/*TID*/, $30/*PAL*/}   ; Robot C - frame 4

    TF{1257*2/*POS*/, 139/*TID*/, $10/*PAL*/}   ; Launch Pad - frame 4
    TF{1258*2/*POS*/, 142/*TID*/, $10/*PAL*/}   ; Launch Pad - frame 4
    TF{1259*2/*POS*/, 143/*TID*/, $10/*PAL*/}   ; Launch Pad - frame 4

    TF{0485*2/*POS*/, 060/*TID*/, $10/*PAL*/}   ; Tower A - frame 2
    TF{0486*2/*POS*/, 061/*TID*/, $10/*PAL*/}   ; Tower A - frame 2

    TF{0271*2/*POS*/, 060/*TID*/, $10/*PAL*/}   ; Tower B - frame 2
    TF{0272*2/*POS*/, 061/*TID*/, $10/*PAL*/}   ; Tower B - frame 2

tilemapAnimationRow5L9
    DB 25
    TF{1160*2/*POS*/, 052/*TID*/, $30/*PAL*/}   ; Robot A - frame 2
    TF{1161*2/*POS*/, 053/*TID*/, $30/*PAL*/}   ; Robot A - frame 2
    TF{1200*2/*POS*/, 054/*TID*/, $30/*PAL*/}   ; Robot A - frame 2
    TF{1201*2/*POS*/, 055/*TID*/, $30/*PAL*/}   ; Robot A - frame 2

    TF{0987*2/*POS*/, 068/*TID*/, $30/*PAL*/}   ; Robot B - frame 2
    TF{0988*2/*POS*/, 069/*TID*/, $30/*PAL*/}   ; Robot B - frame 2
    TF{1027*2/*POS*/, 070/*TID*/, $30/*PAL*/}   ; Robot B - frame 2
    TF{1028*2/*POS*/, 071/*TID*/, $30/*PAL*/}   ; Robot B - frame 2
    TF{1067*2/*POS*/, 084/*TID*/, $30/*PAL*/}   ; Robot B - frame 2
    TF{1068*2/*POS*/, 085/*TID*/, $30/*PAL*/}   ; Robot B - frame 2

    TF{0741*2/*POS*/, 112/*TID*/, $30/*PAL*/}   ; Robot C - frame 5
    TF{0742*2/*POS*/, 113/*TID*/, $30/*PAL*/}   ; Robot C - frame 5
    TF{0781*2/*POS*/, 114/*TID*/, $30/*PAL*/}   ; Robot C - frame 5
    TF{0782*2/*POS*/, 115/*TID*/, $30/*PAL*/}   ; Robot C - frame 5
    TF{0821*2/*POS*/, 128/*TID*/, $30/*PAL*/}   ; Robot C - frame 5
    TF{0822*2/*POS*/, 129/*TID*/, $30/*PAL*/}   ; Robot C - frame 5
    TF{0861*2/*POS*/, 130/*TID*/, $30/*PAL*/}   ; Robot C - frame 5
    TF{0862*2/*POS*/, 131/*TID*/, $30/*PAL*/}   ; Robot C - frame 5

    TF{1257*2/*POS*/, 153/*TID*/, $10/*PAL*/}   ; Launch Pad - frame 5
    TF{1258*2/*POS*/, 156/*TID*/, $10/*PAL*/}   ; Launch Pad - frame 5
    TF{1259*2/*POS*/, 157/*TID*/, $10/*PAL*/}   ; Launch Pad - frame 5

    TF{0485*2/*POS*/, 164/*TID*/, $10/*PAL*/}   ; Tower A - frame 1
    TF{0486*2/*POS*/, 165/*TID*/, $10/*PAL*/}   ; Tower A - frame 1

    TF{0271*2/*POS*/, 164/*TID*/, $10/*PAL*/}   ; Tower B - frame 1
    TF{0272*2/*POS*/, 165/*TID*/, $10/*PAL*/}   ; Tower B - frame 1

tilemapAnimationRow6L9
    DB 25
    TF{1160*2/*POS*/, 056/*TID*/, $30/*PAL*/}   ; Robot A - frame 3
    TF{1161*2/*POS*/, 057/*TID*/, $30/*PAL*/}   ; Robot A - frame 3
    TF{1200*2/*POS*/, 058/*TID*/, $30/*PAL*/}   ; Robot A - frame 3
    TF{1201*2/*POS*/, 059/*TID*/, $30/*PAL*/}   ; Robot A - frame 3

    TF{0987*2/*POS*/, 072/*TID*/, $30/*PAL*/}   ; Robot B - frame 3
    TF{0988*2/*POS*/, 073/*TID*/, $30/*PAL*/}   ; Robot B - frame 3
    TF{1027*2/*POS*/, 074/*TID*/, $30/*PAL*/}   ; Robot B - frame 3
    TF{1028*2/*POS*/, 075/*TID*/, $30/*PAL*/}   ; Robot B - frame 3
    TF{1067*2/*POS*/, 088/*TID*/, $30/*PAL*/}   ; Robot B - frame 3
    TF{1068*2/*POS*/, 089/*TID*/, $30/*PAL*/}   ; Robot B - frame 3

    TF{0741*2/*POS*/, 116/*TID*/, $30/*PAL*/}   ; Robot C - frame 6
    TF{0742*2/*POS*/, 117/*TID*/, $30/*PAL*/}   ; Robot C - frame 6
    TF{0781*2/*POS*/, 118/*TID*/, $30/*PAL*/}   ; Robot C - frame 6
    TF{0782*2/*POS*/, 119/*TID*/, $30/*PAL*/}   ; Robot C - frame 6
    TF{0821*2/*POS*/, 132/*TID*/, $30/*PAL*/}   ; Robot C - frame 6
    TF{0822*2/*POS*/, 133/*TID*/, $30/*PAL*/}   ; Robot C - frame 6
    TF{0861*2/*POS*/, 130/*TID*/, $30/*PAL*/}   ; Robot C - frame 6
    TF{0862*2/*POS*/, 131/*TID*/, $30/*PAL*/}   ; Robot C - frame 6

    TF{1257*2/*POS*/, 155/*TID*/, $10/*PAL*/}   ; Launch Pad - frame 6
    TF{1258*2/*POS*/, 158/*TID*/, $10/*PAL*/}   ; Launch Pad - frame 6
    TF{1259*2/*POS*/, 159/*TID*/, $10/*PAL*/}   ; Launch Pad - frame 6

    TF{0485*2/*POS*/, 060/*TID*/, $10/*PAL*/}   ; Tower A - frame 2
    TF{0486*2/*POS*/, 061/*TID*/, $10/*PAL*/}   ; Tower A - frame 2

    TF{0271*2/*POS*/, 060/*TID*/, $10/*PAL*/}   ; Tower B - frame 2
    TF{0272*2/*POS*/, 061/*TID*/, $10/*PAL*/}   ; Tower B - frame 2

tilemapAnimationRowsL9
    DW tilemapAnimationRow1L9, tilemapAnimationRow2L9, tilemapAnimationRow3L9, tilemapAnimationRow4L9, tilemapAnimationRow5L9
    DW tilemapAnimationRow6L9

TILEMAP_ANIM_ROWS_L9    = 6


    ; ##########################################
    ASSERT $$ == dbs.TILE_ANIMATION_D34         ; Data should remain in the same bank
;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE