;----------------------------------------------------------;
;                    Binary Data Loader                    ;
;----------------------------------------------------------;
	module db

;----------------------------------------------------------;
;                Game Sprites (Bank 28...29)               ;
;----------------------------------------------------------;
; Load sprites (16KB) into bank 20,29 mapping it to slot 6,7.
	MMU _RAM_SLOT6 _RAM_SLOT7, _DB_SPRITE_BANK1_D28
	ORG _RAM_SLOT6_START_HC000

spritesBin INCBIN "assets/sprites.spr", 0, _DB_SPRITE_BYT_D16384
spritesBinLength = $ - spritesBin
	ASSERT $$ == _DB_SPRITE_BANK2_D29

;----------------------------------------------------------;
;         Game Tile Sprites and Palette (Bank 30)          ;
;----------------------------------------------------------;
	MMU _RAM_SLOT7, _DB_TI_SPR_BANK_D30 		; Assign slots 7 to bank 30.
	ORG _RAM_SLOT7_START_HE000					; Set memory pointer to start of the slot 6.

; Sprite editor settings: 4bit, 8x8. After downloading manually remove empty data!
; Sprites
;  - 00 - 56: Font, palette 0
;  - 59     : Empty, each palette
;  - 60 - 67: Ground 1, palette 1
;  - 68 - 95: Tree 1, 6x6 , palette 2, bytes: 2176-3071, last two 4x4 tiles (stump) are combined into one 4x4
;  - 96 - 131: Tree 2, 6x6 , palette 2, bytes: 3072-4023

tileSprBin INCBIN "assets/tiles.spr"
tileSprBinLength = $ - tileSprBin
	ASSERT tileSprBinLength <= TI_DEF_MAX_D6910

; Palettes:
;	1: Text
;	2: Ground
;	3: Trees
;   4-6: Platforms

;  Values for Remy's editor:
/*
  $1C7    $0    $5   $27   $2F   $6F   $B7  $13F   $10   $13   $15   $17   $18   $1B   $1D   $1F
  $1C7    $8   $40   $41   $40   $21   $2D   $2F   $1B   $1D   $35   $37   $3B   $18   $3D   $80
  $1C7   $80   $18   $41   $A8   $10   $40   $60    $0  $1C1   $80  $1C1  $1C1  $1C1  $1C1   $DF
  $1C7  $1BB  $1B3  $1AB  $1A3  $19B  $193  $18B  $183  $1C0  $128  $1FB   $4D   $55  $178  $1C7
  $1C7  $1F8  $1F0  $1E8  $1E0  $1D8  $1D0  $1C8  $1C0  $1C0  $1C7  $1C7  $1C7  $1C7  $1C7  $1C7
  $1C7   $85   $7D   $75   $6D   $65   $5D   $55   $4D  $5  $1C7  $1C7  $1C7  $1C7  $1C7  $1C7
*/
tilePaletteBin									; RGB332, 8 bit
	DB $E3, $00, $02, $13, $17, $37, $5B, $9F, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F
	DB $E3, $04, $20, $20, $20, $10, $16, $17, $0D, $0E, $1A, $1B, $1D, $0C, $1E, $40
	DB $E3, $40, $0C, $20, $54, $08, $20, $30, $00, $E0, $40, $E0, $E0, $E0, $E0, $6F
	DB $E3, $DD, $D9, $D5, $D1, $CD, $C9, $C5, $C1, $E0, $94, $FD, $26, $2A, $BC, $E3
	DB $E3, $FC, $F8, $F4, $F0, $EC, $E8, $E4, $E0, $E0, $E3, $E3, $E3, $E3, $E3, $E3
	DB $E3, $42, $3E, $3A, $36, $32, $2E, $2A, $26, $02, $E3, $E3, $E3, $E3, $E3, $E3
tilePaletteBinLength = $ - tilePaletteBin
	
	ASSERT $ > _RAM_SLOT6_START_HC000			; All data should fit into slot 6,7.
	ASSERT $ <= _RAM_SLOT7_END_HFFFF 			
	ASSERT $$ <= _DB_TI_SPR_BANK_D30 			; All data should fit into bank 30.

;----------------------------------------------------------;
;                Star Tiles (Bank 31, 32)                  ;
;----------------------------------------------------------;
	MMU _RAM_SLOT6 _RAM_SLOT7, _DB_RO_STAR_BANK1_D31
	ORG _RAM_SLOT6_START_HC000					; Set memory pointer to start of the slot 6,7.

starsBin INCBIN "assets/stars.map"
starsBinSize = $ - starsBin

	ASSERT starsBinSize == _TIS_BYTES_D10240
	ASSERT $ > _RAM_SLOT6_START_HC000			; All data should fit into slot 6.
	ASSERT $ <= _RAM_SLOT7_END_HFFFF 			
	ASSERT $$ == _DB_RO_STAR_BANK2_D32 			; All data should fit into bank 32.

;----------------------------------------------------------;
;                Layer 2 Palettes (Bank 33)                ;
;----------------------------------------------------------;
	MMU _RAM_SLOT6, _DB_PAL2_BANK_D33
	ORG _RAM_SLOT6_START_HC000

 ; #############################################
bgrL1PaletteAdr
	INCBIN  "assets/l01/bg.nxp"

bgrL1PaletteBytes = $ - bgrL1PaletteAdr
	ASSERT bgrL1PaletteBytes <= _BM_PAL2_BYTES_D512

 ; #############################################
bgrL2PaletteAdr
	INCBIN  "assets/l02/bg.nxp"

bgrL2PaletteBytes = $ - bgrL2PaletteAdr
	ASSERT bgrL2PaletteBytes <= _BM_PAL2_BYTES_D512

 ; #############################################
bgrL3PaletteAdr
	INCBIN  "assets/l03/bg.nxp"

bgrL3PaletteBytes = $ - bgrL3PaletteAdr
	ASSERT bgrL3PaletteBytes <= _BM_PAL2_BYTES_D512

 ; #############################################
bgrL4PaletteAdr
	INCBIN  "assets/l04/bg.nxp"

bgrL4PaletteBytes = $ - bgrL4PaletteAdr
	ASSERT bgrL4PaletteBytes <= _BM_PAL2_BYTES_D512

 ; #############################################
bgrL5PaletteAdr
	INCBIN  "assets/l05/bg.nxp"

bgrL5PaletteBytes = $ - bgrL5PaletteAdr
	ASSERT bgrL5PaletteBytes <= _BM_PAL2_BYTES_D512

 ; #############################################
bgrL6PaletteAdr
	INCBIN  "assets/l06/bg.nxp"

bgrL6PaletteBytes = $ - bgrL6PaletteAdr
	ASSERT bgrL6PaletteBytes <= _BM_PAL2_BYTES_D512
	
 ; #############################################
bgrL7PaletteAdr
	INCBIN  "assets/l07/bg.nxp"

bgrL7PaletteBytes = $ - bgrL7PaletteAdr
	ASSERT bgrL7PaletteBytes <= _BM_PAL2_BYTES_D512

 ; #############################################
bgrL8PaletteAdr
	INCBIN  "assets/l08/bg.nxp"

bgrL8PaletteBytes = $ - bgrL8PaletteAdr
	ASSERT bgrL8PaletteBytes <= _BM_PAL2_BYTES_D512

 ; #############################################
bgrL9PaletteAdr
	INCBIN  "assets/l09/bg.nxp"

bgrL9PaletteBytes = $ - bgrL9PaletteAdr
	ASSERT bgrL9PaletteBytes <= _BM_PAL2_BYTES_D512

 ; #############################################
bgrL10PaletteAdr
	INCBIN  "assets/l10/bg.nxp"

bgrL10PaletteBytes = $ - bgrL10PaletteAdr
	ASSERT bgrL10PaletteBytes <= _BM_PAL2_BYTES_D512
	
 ; #############################################
	ASSERT $$ == _DB_PAL2_BANK_D33	

;----------------------------------------------------------;
;          Layer 2 Brightness Palettes (Bank 34)           ;
;----------------------------------------------------------;
todL2Palettes									; Palette will be generated during runtime.

;----------------------------------------------------------;
;              Game Background (Bank 35...44)              ;
;----------------------------------------------------------;
; The screen size is 320x256 (81920 bytes, 80KiB) -> 10 8KB banks.

;----------------------------------------------------------;
;                  Star Data (Bank 45)                     ;
;----------------------------------------------------------;
; Before using it call #dbs.SetupStarsBank

	MMU _RAM_SLOT7, _DB_ST_BANK_D45
	ORG _RAM_SLOT7_START_HE000
starsBankStart

starsData1
	st.SC {0/*BANK*/, 02/*X_OFFSET*/, 6/*SIZE*/}	; X=2
	DB 12,1, 15,4, 70,5, 94,15, 160,8, 250,19

	st.SC {0/*BANK*/, 08/*X_OFFSET*/, 5/*SIZE*/}	; X=8
	DB 5,3, 38,6, 120,10, 158,4, 245,18

	st.SC {0/*BANK*/, 20/*X_OFFSET*/, 4/*SIZE*/}	; X=20
	DB 4,4, 42,8, 133,1, 245,15

	st.SC {1/*BANK*/, 05/*X_OFFSET*/, 5/*SIZE*/}	; X=37
	DB 20,3, 80,8, 104,12, 150,9, 255,5

	st.SC {1/*BANK*/, 15/*X_OFFSET*/, 5/*SIZE*/}	; X=47
	DB 10,1, 115,4, 130,9, 155,2, 230,15

	st.SC {1/*BANK*/, 23/*X_OFFSET*/, 6/*SIZE*/}	; X=55
	DB 4,4, 90,1, 144,8, 148,2, 202,5, 251,16

	st.SC {2/*BANK*/, 04/*X_OFFSET*/, 5/*SIZE*/}	; X=68
	DB 14,2, 52,4, 113,6, 189,8, 241,16

	st.SC {2/*BANK*/, 11/*X_OFFSET*/, 4/*SIZE*/}	; X=75
	DB 21,1, 92,6, 158,9, 221,19

	st.SC {2/*BANK*/, 20/*X_OFFSET*/, 5/*SIZE*/}	; X=84
	DB 31,5, 93,4, 159,13, 178,8, 248,19

	st.SC {3/*BANK*/, 01/*X_OFFSET*/, 6/*SIZE*/}	; X=97
	DB 26,3, 45,8, 125,4, 138,11, 160,9, 193,12

	st.SC {3/*BANK*/, 20/*X_OFFSET*/, 5/*SIZE*/}	; X=116
	DB 10,4, 104,5, 145,6, 190,8, 249,12

	st.SC {3/*BANK*/, 28/*X_OFFSET*/, 4/*SIZE*/}	; X=124
	DB 86,11, 123,7, 158,1, 233,19

	st.SC {4/*BANK*/, 05/*X_OFFSET*/, 6/*SIZE*/}	; X=133
	DB 21,19, 55,11, 80,8, 144,3, 148,13, 243,2

	st.SC {4/*BANK*/, 15/*X_OFFSET*/, 6/*SIZE*/}	; X=143
	DB 47,13, 77,2, 93,18, 139,1, 188,5, 233,7

	st.SC {4/*BANK*/, 23/*X_OFFSET*/, 6/*SIZE*/}	; X=151
	DB 5,3, 84,5, 98,9, 142,12, 168,11, 201,10

	st.SC {5/*BANK*/, 11/*X_OFFSET*/, 5/*SIZE*/}	; X=171
	DB 38,1, 78,5, 132,9, 149,12, 231,11

	st.SC {5/*BANK*/, 20/*X_OFFSET*/, 5/*SIZE*/}	; X=180
	DB 24,2, 44,9, 126,3, 160,7, 243,17

	st.SC {6/*BANK*/, 05/*X_OFFSET*/, 3/*SIZE*/}	; X=197
	DB 64,11, 116,3, 174,15

	st.SC {6/*BANK*/, 20/*X_OFFSET*/, 5/*SIZE*/}	; X=212
	DB 13,15, 44,3, 100,5, 143,7, 199,2

	st.SC {7/*BANK*/, 03/*X_OFFSET*/, 5/*SIZE*/}	; X=227
	DB 55,2, 98,3, 120,7, 187,11, 255,19

	st.SC {7/*BANK*/, 12/*X_OFFSET*/, 4/*SIZE*/}	; X=236
	DB 11,14, 82,16, 148,11, 213,9

	st.SC {7/*BANK*/, 30/*X_OFFSET*/, 4/*SIZE*/}	; X=254
	DB 44,1, 113,12, 192,15, 253,12

	st.SC {8/*BANK*/, 08/*X_OFFSET*/, 5/*SIZE*/}	; X=264
	DB 4,3, 39,1, 88,13, 133,2, 152,15

	st.SC {8/*BANK*/, 16/*X_OFFSET*/, 3/*SIZE*/}	; X=272
	DB 3,1, 142,4, 241,9

	st.SC {8/*BANK*/, 31/*X_OFFSET*/, 4/*SIZE*/}	; X=287
	DB 30,12, 103,3, 150,8, 189,2

	st.SC {9/*BANK*/, 20/*X_OFFSET*/, 4/*SIZE*/}	; X=308
	DB 5,4, 36,11, 120,14, 211,2

	st.SC {9/*BANK*/, 30/*X_OFFSET*/, 4/*SIZE*/}	; X=318
	DB 5,3, 102,6, 142,9, 240,12

starsData2
	st.SC {0/*BANK*/, 15/*X_OFFSET*/, 4/*SIZE*/}	; X=15
	DB 4,4, 42,8, 133,1, 245,9

	st.SC {1/*BANK*/, 10/*X_OFFSET*/, 6/*SIZE*/}	; X=42
	DB 26,3, 45,8, 125,4, 138,3, 160,9, 193,2

	st.SC {1/*BANK*/, 20/*X_OFFSET*/, 5/*SIZE*/}	; X=52
	DB 14,2, 52,4, 113,6, 189,8, 241,1

	st.SC {2/*BANK*/, 06/*X_OFFSET*/, 5/*SIZE*/}	; X=70
	DB 10,1, 115,4, 130,9, 155,2, 230,4

	st.SC {2/*BANK*/, 18/*X_OFFSET*/, 5/*SIZE*/}	; X=82
	DB 38,1, 78,5, 132,9, 149,2, 231,5

	st.SC {3/*BANK*/, 12/*X_OFFSET*/, 5/*SIZE*/}	; X=108
	DB 5,3, 38,6, 120,9, 158,4, 245,1

	st.SC {3/*BANK*/, 18/*X_OFFSET*/, 5/*SIZE*/}	; X=114
	DB 31,5, 93,4, 159,1, 178,8, 248,4

	st.SC {4/*BANK*/, 1/*X_OFFSET*/, 5/*SIZE*/}		; X=129
	DB 10,4, 104,5, 145,6, 190,8, 249,3

	st.SC {4/*BANK*/, 30/*X_OFFSET*/, 4/*SIZE*/}	; X=158
	DB 21,1, 92,6, 158,9, 221,6

	st.SC {5/*BANK*/, 15/*X_OFFSET*/, 6/*SIZE*/}	; X=175
	DB 4,4, 90,1, 144,8, 148,2, 202,5, 251,7

	st.SC {6/*BANK*/, 04/*X_OFFSET*/, 6/*SIZE*/}	; X=194
	DB 12,1, 15,4, 70,5, 94,3, 160,8, 250,2

	st.SC {6/*BANK*/, 10/*X_OFFSET*/, 4/*SIZE*/}	; X=202
	DB 86,3, 123,7, 158,1, 233,9

	st.SC {7/*BANK*/, 11/*X_OFFSET*/, 5/*SIZE*/}	; X=235
	DB 20,3, 80,8, 104,2, 150,9, 255,5

	st.SC {8/*BANK*/, 12/*X_OFFSET*/, 6/*SIZE*/}	; X=268
	DB 21,3, 55,4, 80,8, 144,5, 148,8, 243,6

	st.SC {8/*BANK*/, 25/*X_OFFSET*/, 6/*SIZE*/}	; X=281
	DB 47,3, 77,2, 93,5, 139,7, 188,4, 233,1

	st.SC {9/*BANK*/, 13/*X_OFFSET*/, 6/*SIZE*/}	; X=301
	DB 5,3, 84,5, 98,9, 142,1, 168,4, 201,5

; Max horizontal star position for each column (#SC). Starts reaching it will be hidden.
starsData1MaxYL1
	DB 143/*X=002*/, 154/*X=008*/, 159/*X=020*/, 196/*X=037*/, 195/*X=047*/, 196/*X=055*/, 140/*X=068*/, 134/*X=075*/, 106/*X=084*/
	DB 192/*X=097*/, 049/*X=116*/, 039/*X=124*/, 022/*X=133*/, 019/*X=143*/, 023/*X=151*/, 123/*X=171*/, 062/*X=180*/, 082/*X=197*/
	DB 104/*X=212*/, 187/*X=227*/, 187/*X=236*/, 187/*X=254*/, 128/*X=264*/, 119/*X=272*/, 102/*X=287*/, 221/*X=308*/, 230/*X=318*/
starsData2MaxYL1
	DB 154/*X=015*/, 196/*X=042*/, 195/*X=052*/, 139/*X=070*/, 106/*X=082*/, 086/*X=108*/, 082/*X=114*/, 037/*X=129*/, 168/*X=158*/
	DB 121/*X=175*/, 080/*X=194*/, 087/*X=202*/, 187/*X=235*/, 123/*X=268*/, 106/*X=281*/, 222/*X=301*/

starsData1MaxYL2
	DB 084/*X=002*/, 082/*X=008*/, 085/*X=020*/, 087/*X=037*/, 089/*X=047*/, 089/*X=055*/, 093/*X=068*/, 094/*X=075*/, 096/*X=084*/
	DB 099/*X=097*/, 100/*X=116*/, 102/*X=124*/, 104/*X=133*/, 106/*X=143*/, 108/*X=151*/, 103/*X=171*/, 101/*X=180*/, 096/*X=197*/
	DB 095/*X=212*/, 096/*X=227*/, 092/*X=236*/, 088/*X=254*/, 086/*X=264*/, 089/*X=272*/, 088/*X=287*/, 084/*X=308*/, 083/*X=318*/
starsData2MaxYL2
	DB 082/*X=015*/, 088/*X=042*/, 088/*X=052*/, 092/*X=070*/, 095/*X=082*/, 101/*X=108*/, 101/*X=114*/, 103/*X=129*/, 107/*X=158*/
	DB 103/*X=175*/, 097/*X=194*/, 096/*X=202*/, 095/*X=235*/, 087/*X=268*/, 088/*X=281*/, 087/*X=301*/

starsData1MaxYL3
	DB 173/*X=002*/, 173/*X=008*/, 193/*X=020*/, 193/*X=037*/, 116/*X=047*/, 107/*X=055*/, 199/*X=068*/, 098/*X=075*/, 065/*X=084*/
	DB 146/*X=097*/, 101/*X=116*/, 179/*X=124*/, 018/*X=133*/, 020/*X=143*/, 000/*X=151*/, 000/*X=171*/, 175/*X=180*/, 065/*X=197*/
	DB 068/*X=212*/, 088/*X=227*/, 148/*X=236*/, 073/*X=254*/, 099/*X=264*/, 097/*X=272*/, 193/*X=287*/, 188/*X=308*/, 188/*X=318*/
starsData2MaxYL3
	DB 175/*X=015*/, 193/*X=042*/, 107/*X=052*/, 199/*X=070*/, 088/*X=082*/, 104/*X=108*/, 079/*X=114*/, 056/*X=129*/, 000/*X=158*/
	DB 002/*X=175*/, 089/*X=194*/, 069/*X=202*/, 148/*X=235*/, 193/*X=268*/, 190/*X=281*/, 176/*X=301*/

starsData1MaxYL4
	DB 003/*X=002*/, 043/*X=008*/, 077/*X=020*/, 109/*X=037*/, 098/*X=047*/, 045/*X=055*/, 141/*X=068*/, 144/*X=075*/, 133/*X=084*/
	DB 085/*X=097*/, 114/*X=116*/, 135/*X=124*/, 131/*X=133*/, 110/*X=143*/, 129/*X=151*/, 055/*X=171*/, 108/*X=180*/, 116/*X=197*/
	DB 118/*X=212*/, 073/*X=227*/, 095/*X=236*/, 142/*X=254*/, 010/*X=264*/, 058/*X=272*/, 135/*X=287*/, 093/*X=308*/, 072/*X=318*/
starsData2MaxYL4
	DB 088/*X=015*/, 079/*X=042*/, 050/*X=052*/, 141/*X=070*/, 120/*X=082*/, 090/*X=108*/, 102/*X=114*/, 135/*X=129*/, 116/*X=158*/
	DB 052/*X=175*/, 136/*X=194*/, 111/*X=202*/, 096/*X=235*/, 016/*X=268*/, 133/*X=281*/, 102/*X=301*/

starsData1MaxYL5
	DB 004/*X=002*/, 010/*X=008*/, 020/*X=020*/, 028/*X=037*/, 028/*X=047*/, 033/*X=055*/, 064/*X=068*/, 064/*X=075*/, 062/*X=084*/
	DB 056/*X=097*/, 059/*X=116*/, 063/*X=124*/, 087/*X=133*/, 106/*X=143*/, 117/*X=151*/, 210/*X=171*/, 217/*X=180*/, 221/*X=197*/
	DB 217/*X=212*/, 224/*X=227*/, 229/*X=236*/, 074/*X=254*/, 053/*X=264*/, 051/*X=272*/, 037/*X=287*/, 023/*X=308*/, 025/*X=318*/
starsData2MaxYL5
	DB 016/*X=015*/, 028/*X=042*/, 030/*X=052*/, 045/*X=070*/, 062/*X=082*/, 051/*X=108*/, 061/*X=114*/, 075/*X=129*/, 127/*X=158*/
	DB 214/*X=175*/, 221/*X=194*/, 221/*X=202*/, 229/*X=235*/, 052/*X=268*/, 042/*X=281*/, 024/*X=301*/

starsData1MaxYL6
	DB 115/*X=002*/, 109/*X=008*/, 114/*X=020*/, 126/*X=037*/, 129/*X=047*/, 135/*X=055*/, 136/*X=068*/, 135/*X=075*/, 142/*X=084*/
	DB 154/*X=097*/, 166/*X=116*/, 166/*X=124*/, 166/*X=133*/, 163/*X=143*/, 157/*X=151*/, 144/*X=171*/, 140/*X=180*/, 133/*X=197*/
	DB 018/*X=212*/, 003/*X=227*/, 017/*X=236*/, 167/*X=254*/, 157/*X=264*/, 155/*X=272*/, 148/*X=287*/, 013/*X=308*/, 134/*X=318*/
starsData2MaxYL6
	DB 109/*X=015*/, 126/*X=042*/, 133/*X=052*/, 136/*X=070*/, 137/*X=082*/, 163/*X=108*/, 166/*X=114*/, 166/*X=129*/, 155/*X=158*/
	DB 142/*X=175*/, 132/*X=194*/, 062/*X=202*/, 016/*X=235*/, 161/*X=268*/, 152/*X=281*/, 134/*X=301*/

starsData1MaxYL7
	DB 056/*X=002*/, 056/*X=008*/, 056/*X=020*/, 055/*X=037*/, 056/*X=047*/, 055/*X=055*/, 056/*X=068*/, 056/*X=075*/, 058/*X=084*/
	DB 058/*X=097*/, 058/*X=116*/, 053/*X=124*/, 039/*X=133*/, 041/*X=143*/, 034/*X=151*/, 029/*X=171*/, 039/*X=180*/, 036/*X=197*/
	DB 028/*X=212*/, 021/*X=227*/, 018/*X=236*/, 007/*X=254*/, 004/*X=264*/, 004/*X=272*/, 006/*X=287*/, 005/*X=308*/, 000/*X=318*/
starsData2MaxYL7
	DB 056/*X=015*/, 055/*X=042*/, 056/*X=052*/, 056/*X=070*/, 058/*X=082*/, 058/*X=108*/, 051/*X=114*/, 039/*X=129*/, 037/*X=158*/
	DB 034/*X=175*/, 038/*X=194*/, 034/*X=202*/, 018/*X=235*/, 005/*X=268*/, 004/*X=281*/, 004/*X=301*/

starsData1MaxYL8
	DB 081/*X=002*/, 082/*X=008*/, 082/*X=020*/, 083/*X=037*/, 083/*X=047*/, 084/*X=055*/, 084/*X=068*/, 084/*X=075*/, 084/*X=084*/
	DB 084/*X=097*/, 084/*X=116*/, 084/*X=124*/, 084/*X=133*/, 082/*X=143*/, 026/*X=151*/, 025/*X=171*/, 035/*X=180*/, 081/*X=197*/
	DB 080/*X=212*/, 078/*X=227*/, 077/*X=236*/, 079/*X=254*/, 079/*X=264*/, 079/*X=272*/, 079/*X=287*/, 078/*X=308*/, 078/*X=318*/
starsData2MaxYL8
	DB 082/*X=015*/, 083/*X=042*/, 083/*X=052*/, 084/*X=070*/, 084/*X=082*/, 084/*X=108*/, 084/*X=114*/, 084/*X=129*/, 022/*X=158*/
	DB 028/*X=175*/, 082/*X=194*/, 081/*X=202*/, 077/*X=235*/, 079/*X=268*/, 079/*X=281*/, 078/*X=301*/

starsData1MaxYL9
	DB 003/*X=002*/, 000/*X=008*/, 002/*X=020*/, 009/*X=037*/, 011/*X=047*/, 016/*X=055*/, 019/*X=068*/, 025/*X=075*/, 032/*X=084*/
	DB 061/*X=097*/, 060/*X=116*/, 059/*X=124*/, 058/*X=133*/, 058/*X=143*/, 059/*X=151*/, 058/*X=171*/, 058/*X=180*/, 057/*X=197*/
	DB 058/*X=212*/, 059/*X=227*/, 061/*X=236*/, 058/*X=254*/, 058/*X=264*/, 059/*X=272*/, 054/*X=287*/, 047/*X=308*/, 046/*X=318*/
starsData2MaxYL9
	DB 000/*X=015*/, 008/*X=042*/, 013/*X=052*/, 020/*X=070*/, 032/*X=082*/, 061/*X=108*/, 060/*X=114*/, 058/*X=129*/, 059/*X=158*/
	DB 057/*X=175*/, 057/*X=194*/, 056/*X=202*/, 061/*X=235*/, 058/*X=268*/, 059/*X=281*/, 050/*X=301*/

starsData1MaxYL10
	DB 217/*X=002*/, 166/*X=008*/, 162/*X=020*/, 163/*X=037*/, 116/*X=047*/, 081/*X=055*/, 103/*X=068*/, 107/*X=075*/, 048/*X=084*/
	DB 044/*X=097*/, 199/*X=116*/, 199/*X=124*/, 000/*X=133*/, 000/*X=143*/, 000/*X=151*/, 000/*X=171*/, 000/*X=180*/, 163/*X=197*/
	DB 188/*X=212*/, 072/*X=227*/, 072/*X=236*/, 072/*X=254*/, 071/*X=264*/, 080/*X=272*/, 141/*X=287*/, 142/*X=308*/, 198/*X=318*/
starsData2MaxYL10
	DB 163/*X=015*/, 120/*X=042*/, 113/*X=052*/, 106/*X=070*/, 062/*X=082*/, 114/*X=108*/, 199/*X=114*/, 000/*X=129*/, 000/*X=158*/
	DB 000/*X=175*/, 000/*X=194*/, 195/*X=202*/, 068/*X=235*/, 072/*X=268*/, 102/*X=281*/, 128/*X=301*/

starsPalL1
	DW $1FF, $1FF, $1FF, $120, $123, $125, $127, $128, $12B, $12D, $12F, $130, $133, $135, $137, $138, $13B, $13D, $13F, $0, $0, $0, $0, $0, $0

starsPalL2
	DW  $40, $36, $48, $8, $B, $0, $0, $0, $0, $0

	; ##########################################
	ASSERT $$ == _DB_ST_BANK_D45					; Data should remain in the same bank
	ASSERT $$starsBankStart == _DB_ST_BANK_D45 		; Make sure that we have configured the right bank.

;----------------------------------------------------------;
;                    Arrays (Bank 46)                      ;
;----------------------------------------------------------;
; Before using it call #SetupArraysBank
	MMU _RAM_SLOT7, _DB_ARR_BANK_D46
	ORG _RAM_SLOT7_START_HE000
spritesBankStart

; ##############################################
; Movement patterns.

; Horizontal movement.
movePattern01
	DB 2, %0'000'1'111,$10

; 10deg move down.
movePattern02
	DB 2, %1'001'1'111,$20

; 10deg move up.
movePattern03
	DB 2, %0'001'1'111,$00

; 45deg move down.
movePattern04
	DB 2, %1'001'1'001,$20

; 5x horizontal, 2x 45deg down,...
movePattern05
	DB 4, %0'000'1'111,$05, %1'111'1'111,$02

; Half sinus.
movePattern06
	DB 32, %0'010'1'001,$02, %0'011'1'010,$02, %0'100'1'011,$01, %0'011'1'011,$01, %0'010'1'011,$03, %0'001'1'011,$02, %0'001'1'100,$02, %0'001'1'101,$01 	; going up
		DB %1'001'1'101,$01, %1'001'1'100,$02, %1'001'1'011,$02, %1'010'1'011,$03, %1'011'1'011,$01, %1'100'1'011,$01, %1'011'1'010,$02, %1'010'1'001,$02	; going down

; sinus.
movePattern07
	DB 64, %0'010'1'001,$32, %0'011'1'010,$32, %0'100'1'011,$31, %0'011'1'011,$31, %0'010'1'011,$33, %0'001'1'011,$32, %0'001'1'100,$32, %0'001'1'101,$31 	; going up, above X
		DB %1'001'1'101,$21, %1'001'1'100,$22, %1'001'1'011,$22, %1'010'1'011,$23, %1'011'1'011,$21, %1'100'1'011,$21, %1'011'1'010,$22, %1'010'1'001,$22	; going down, above X
		DB %1'010'1'001,$11, %1'011'1'010,$11, %1'100'1'011,$11, %1'011'1'011,$01, %1'010'1'011,$03, %1'001'1'011,$02, %1'001'1'100,$02, %1'001'1'101,$01 	; going down, below X
		DB %0'001'1'101,$11, %0'001'1'100,$12, %0'001'1'011,$22, %0'010'1'011,$23, %0'011'1'011,$21, %0'100'1'011,$31, %0'011'1'010,$32, %0'010'1'001,$32	; going up, below X
		
; Square wave.
movePattern08
	DB 8, %0'000'1'111,$25, %1'111'1'000,$23, %0'000'1'111,$25, %0'111'1'000,$23

; Triangle wave.
movePattern09
	DB 4, %0'111'1'111,5, %1'111'1'111,5

; Square, triangle wave.
movePattern10
	DB 24, %0'000'1'111,$25, %1'111'1'000,$23, %0'000'1'111,$25, %0'111'1'000,$23, %0'000'1'111,$25, %1'111'1'000,$23, %0'000'1'111,$25, %0'111'1'000,$23, %1'111'1'111,$03, %0'111'1'111,$03, %1'111'1'111,$03, %0'111'1'111,$03

; Single enemies.
spriteEx01
	ep.ENP {%000000'1'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 020/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 060/*RESPAWN_Y*/, movePattern05/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx02
	ep.ENP {%000000'1'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 020/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 105/*RESPAWN_Y*/, movePattern06/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx03
	ep.ENP {%000000'0'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 020/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 200/*RESPAWN_Y*/, movePattern07/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx04
	ep.ENP {%000000'1'0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 020/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 010/*RESPAWN_Y*/, movePattern01/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx05
	ep.ENP {%000000'1'1/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 020/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 030/*RESPAWN_Y*/, movePattern04/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx06
	ep.ENP {%000000'1'0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 020/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 060/*RESPAWN_Y*/, movePattern02/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx07
	ep.ENP {%000000'1'0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 020/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 090/*RESPAWN_Y*/, movePattern01/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx08
	ep.ENP {%000000'1'0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 020/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 140/*RESPAWN_Y*/, movePattern02/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx09
	ep.ENP {%000000'1'0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 020/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 230/*RESPAWN_Y*/, movePattern01/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}	
spriteEx10
	ep.ENP {%000000'0'0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 020/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 030/*RESPAWN_Y*/, movePattern01/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx11
	ep.ENP {%000000'0'0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 020/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 005/*RESPAWN_Y*/, movePattern02/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx12
	ep.ENP {%000000'0'0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 020/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 070/*RESPAWN_Y*/, movePattern02/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx13
	ep.ENP {%000000'0'0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 020/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 120/*RESPAWN_Y*/, movePattern04/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx14
	ep.ENP {%000000'0'0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 020/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 160/*RESPAWN_Y*/, movePattern02/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteEx15
	ep.ENP {%000000'0'0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 020/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 220/*RESPAWN_Y*/, movePattern02/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}

; Enemies reserved for enemyFormation.
spriteExEf01
	ep.ENP {%000000'1'0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 000/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 200/*RESPAWN_Y*/, movePattern07/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteExEf02
	ep.ENP {%000000'1'0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 100/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 200/*RESPAWN_Y*/, movePattern07/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteExEf03
	ep.ENP {%000000'1'0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 100/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 200/*RESPAWN_Y*/, movePattern07/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteExEf04
	ep.ENP {%000000'1'0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 080/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 200/*RESPAWN_Y*/, movePattern07/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteExEf05
	ep.ENP {%000000'1'0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 080/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 200/*RESPAWN_Y*/, movePattern07/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteExEf06
	ep.ENP {%000000'1'0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 080/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 200/*RESPAWN_Y*/, movePattern07/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}
spriteExEf07
	ep.ENP {%000000'1'0/*SETUP*/, 0/*MOVE_DELAY_CNT*/, 080/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 200/*RESPAWN_Y*/, movePattern07/*MOVE_PAT_POINTER*/, ep.MOVE_PAT_STEP_OFFSET/*MOVE_PAT_POS*/, 0/*MOVE_PAT_STEP*/, 0/*MOVE_PAT_STEP_RCNT*/}

; Single sprites, used by single enemies (#spriteExXX).
sprite01
	sr.SPR {20/*ID*/, sr.SDB_ENEMY2/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx01/*EXT_DATA_POINTER*/}
sprite02
	sr.SPR {21/*ID*/, sr.SDB_ENEMY2/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx02/*EXT_DATA_POINTER*/}
sprite03
	sr.SPR {22/*ID*/, sr.SDB_ENEMY2/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx03/*EXT_DATA_POINTER*/}
sprite04
	sr.SPR {23/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx04/*EXT_DATA_POINTER*/}
sprite05
	sr.SPR {24/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx05/*EXT_DATA_POINTER*/}
sprite06
	sr.SPR {25/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx06/*EXT_DATA_POINTER*/}
sprite07
	sr.SPR {26/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx07/*EXT_DATA_POINTER*/}
sprite08
	sr.SPR {27/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx08/*EXT_DATA_POINTER*/}
sprite09
	sr.SPR {28/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx09/*EXT_DATA_POINTER*/}
sprite10
	sr.SPR {29/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx10/*EXT_DATA_POINTER*/}
sprite11
	sr.SPR {30/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx11/*EXT_DATA_POINTER*/}
sprite12
	sr.SPR {31/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx12/*EXT_DATA_POINTER*/}
sprite13
	sr.SPR {32/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx13/*EXT_DATA_POINTER*/}
sprite14
	sr.SPR {33/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx14/*EXT_DATA_POINTER*/}
sprite15
	sr.SPR {34/*ID*/, sr.SDB_ENEMY1/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteEx15/*EXT_DATA_POINTER*/}

; Formation sprites used by enemyFormation enemies (#spriteExEfXX).
spriteEf01
	sr.SPR {35/*ID*/, sr.SDB_ENEMY3/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteExEf01/*EXT_DATA_POINTER*/}
spriteEf02
	sr.SPR {36/*ID*/, sr.SDB_ENEMY3/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteExEf02/*EXT_DATA_POINTER*/}
spriteEf03
	sr.SPR {37/*ID*/, sr.SDB_ENEMY3/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteExEf03/*EXT_DATA_POINTER*/}
spriteEf04
	sr.SPR {38/*ID*/, sr.SDB_ENEMY3/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteExEf04/*EXT_DATA_POINTER*/}
spriteEf05
	sr.SPR {39/*ID*/, sr.SDB_ENEMY3/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteExEf05/*EXT_DATA_POINTER*/}
spriteEf06
	sr.SPR {40/*ID*/, sr.SDB_ENEMY3/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteExEf06/*EXT_DATA_POINTER*/}
spriteEf07
	sr.SPR {41/*ID*/, sr.SDB_ENEMY3/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, spriteExEf07/*EXT_DATA_POINTER*/}

enemiesSize					BYTE 15+7			; The total amount of visible sprites - including single enemies (15) and enemyFormation (7)
singleEnemiesSize			BYTE 15				; Amount of sprites that can respawn as a single enemy

enemyFormation ef.EF{spriteEf01/*SPRITE_POINTER*/, 200/*RESPAWN_DELAY*/, 0/*RESPAWN_DELAY_CNT*/, 7/*SPRITES*/, 0/*SPRITES_CNT*/}

; ##############################################
; Jetman Sprite Data

; The animation system is based on a state machine. Its database is divided into records, each containing a list of frames to be played and 
; a reference to the next record that will be played once all frames from the current record have been executed.
; DB Record:
;    [ID], [OFF_NX], [SIZE], [DELAY], [[FRAME_UP,FRAME_LW], [FRAME_UP,FRAME_LW],...,[FRAME_UP,FRAME_LW]] 
; where:
;	- ID: 			Entry ID for lookup via CPIR.
;	- OFF_NX:		ID of the following animation DB record. We subtract from this ID the 100 so that CPIR does not find OFF_NX but ID.
;	- SIZE:			Amount of bytes in this record.
;	- DELAY:		Amount animation calls to skip (slows down animation).
;	- FRAME_UP:		Offset for the upper part of the Jetman.
;	- FRAME_LW: 	Offset for the lower part of the Jetman.
jetSpriteDB
	; Jetman is flaying.
	DB js.SDB_FLY,		js.SDB_FLY - js.SDB_SUB,		48, 5
											DB 00,10, 00,11, 01,12, 01,13, 02,11, 02,12, 03,10, 03,11, 04,12, 04,13
											DB 05,12, 05,11, 03,10, 03,11, 04,12, 04,13, 05,10, 05,12, 03,10, 03,11
											DB 04,12, 04,13, 05,12, 05,10

	; Jetman is flaying down.
	DB js.SDB_FLYD, 	js.SDB_FLYD - js.SDB_SUB,		48, 5
											DB 00,12, 00,37, 01,38, 01,37, 02,12, 02,38, 03,12, 03,37, 04,38, 04,12
											DB 05,38, 05,37, 03,37, 03,12, 04,38, 04,12, 05,37, 05,38, 03,37, 03,12
											DB 04,12, 04,37, 05,38, 05,37

	; Jetman hovers.
	DB js.SDB_HOVER, 	js.SDB_HOVER - js.SDB_SUB,		48, 10
											DB 00,14, 00,15, 01,16, 01,10, 02,11, 02,12, 03,13, 03,10, 04,11, 04,12 
											DB 05,13, 05,14, 03,15, 03,16, 04,10, 04,11, 05,12, 05,13, 03,10, 03,11
											DB 04,12, 04,13, 05,10, 05,11

	; Jetman starts walking with raised feet to avoid moving over the ground and standing still.
	DB js.SDB_WALK_ST,	js.SDB_WALK	- js.SDB_SUB,		02, 3
											DB 03,07

	; Jetman is walking.
	DB js.SDB_WALK, 	js.SDB_WALK - js.SDB_SUB,		48, 3
											DB 03,06, 03,07, 04,08, 04,09, 05,06, 05,06, 03,08, 03,09, 04,06, 04,07
											DB 05,08, 05,09, 00,06, 00,07, 01,08, 01,09, 02,06, 02,07, 03,08, 03,09 
											DB 04,06, 04,07, 05,08, 05,09

	; Jetman stands in place.
	DB js.SDB_STAND,	js.SDB_STAND - js.SDB_SUB,		46, 5
											DB 03,06, 03,18, 04,19, 04,18, 05,06, 05,19, 03,06, 03,18, 04,19, 04,06
											DB 05,19, 05,18, 00,19, 00,18, 01,06, 01,18, 02,06, 02,19, 03,18, 03,18
											DB 04,19, 05,06, 05,18

	; Jetman stands on the ground for a very short time.
	DB js.SDB_JSTAND,	js.SDB_STAND - js.SDB_SUB, 		02, 3
											DB 03,11

	; Jetman got hit.
	DB js.SDB_RIP,		js.SDB_RIP - js.SDB_SUB,		08, 5 
											DB 00,27, 01,28, 02,15, 03,29

	; Transition: walking -> flaying.
	DB js.SDB_T_WF,		js.SDB_FLY - js.SDB_SUB, 		08, 5
											DB 03,26, 04,25, 05,24, 03,23

	; Transition: flaying -> standing.
	DB js.SDB_T_FS, 	js.SDB_STAND - js.SDB_SUB,		08, 5
											DB 03,23, 04,24, 05,25, 03,26

	; Transition: flaying -> walking.
	DB js.SDB_T_FW, 	js.SDB_WALK - js.SDB_SUB,		08, 5
											DB 03,23, 04,24, 05,25, 03,26

	; Transition: kinking -> flying.
	DB js.SDB_T_KF,		js.SDB_FLY - js.SDB_SUB, 		10, 5
											DB 03,15, 04,16, 05,27, 03,28, 04,29

; ##############################################
; Rocket Sprite Data.

rocketEl
; Rocket element.
	ro.RO {050/*DROP_X*/, 108/*DROP_LAND_Y*/, 227/*ASSEMBLY_Y*/, _RO_DOWN_SPR_ID_D50/*SPRITE_ID*/, 60/*SPRITE_REF*/, 0/*Y*/}	; bottom element
	ro.RO {072/*DROP_X*/, 235/*DROP_LAND_Y*/, 211/*ASSEMBLY_Y*/,                 51/*SPRITE_ID*/,  56/*SPRITE_REF*/, 0/*Y*/}	; middle element
	ro.RO {140/*DROP_X*/, 235/*DROP_LAND_Y*/, 195/*ASSEMBLY_Y*/,                 52/*SPRITE_ID*/,  52/*SPRITE_REF*/, 0/*Y*/}	; top of the rocket
; Fuel tank.
	ro.RO {030/*DROP_X*/, 107/*DROP_LAND_Y*/, 226/*ASSEMBLY_Y*/, 43/*SPRITE_ID*/, 17/*SPRITE_REF*/, 0/*Y*/}
	ro.RO {070/*DROP_X*/, 235/*DROP_LAND_Y*/, 226/*ASSEMBLY_Y*/, 43/*SPRITE_ID*/, 17/*SPRITE_REF*/, 0/*Y*/}
	ro.RO {250/*DROP_X*/, 235/*DROP_LAND_Y*/, 226/*ASSEMBLY_Y*/, 43/*SPRITE_ID*/, 17/*SPRITE_REF*/, 0/*Y*/}
	
; Three explode DBs for three rocket elements.
rocketExplodeDB1		DB 60,60,60,60, 60,60,60,60, 30,31,32,31, 30,32,31,31, 30,31,32,33	; bottom element
rocketExplodeDB2		DB 56,56,56,56, 30,31,32,31, 30,31,32,31, 32,30,32,31, 30,31,32,33	; middle element
rocketExplodeDB3		DB 30,31,32,31, 30,31,32,31, 30,31,32,31, 30,32,31,30, 30,31,32,33	; top of the rocket

rocketExhaustDB									; Sprite IDs for exhaust
	DB 53,57,62,  57,62,53,  62,53,57,  53,62,57,  62,57,53,  57,53,62

rocketExplodeTankDB		DB 30, 31, 32, 33		; Sprite IDs for explosion.

; ##############################################
; Platforms
; [amount of platforms], #PLA,..., #PLA]. Platforms are tiles. Each tile has 8x8 pixels.

; Level 1
platformsL1
	pl.PLA {03*8/*X_LEFT*/, 08*8/*X_RIGHT*/, 15*8/*Y_TOP*/, 15*8/*Y_BOTTOM*/}
	pl.PLA {11*8/*X_LEFT*/, 17*8/*X_RIGHT*/, 21*8/*Y_TOP*/, 21*8/*Y_BOTTOM*/}
	pl.PLA {25*8/*X_LEFT*/, 30*8/*X_RIGHT*/, 10*8/*Y_TOP*/, 10*8/*Y_BOTTOM*/}
platformsSizeL1 		BYTE 3

; Level 2
platformsL2
	pl.PLA {02*8/*X_LEFT*/, 22*8/*X_RIGHT*/, 08*8/*Y_TOP*/, 08*8/*Y_BOTTOM*/}
	pl.PLA {27*8/*X_LEFT*/, 35*8/*X_RIGHT*/, 08*8/*Y_TOP*/, 08*8/*Y_BOTTOM*/}
	pl.PLA {08*8/*X_LEFT*/, 19*8/*X_RIGHT*/, 21*8/*Y_TOP*/, 21*8/*Y_BOTTOM*/}
	pl.PLA {26*8/*X_LEFT*/, 33*8/*X_RIGHT*/, 21*8/*Y_TOP*/, 21*8/*Y_BOTTOM*/}
platformsSizeL2 		BYTE 4

; Level 3
platformsL3
	pl.PLA {09*8/*X_LEFT*/, 18*8/*X_RIGHT*/, 06*8/*Y_TOP*/, 06*8/*Y_BOTTOM*/}
platformsSizeL3 		BYTE 1

; Level 9
platformsL4
	pl.PLA {04*8/*X_LEFT*/, 11*8/*X_RIGHT*/, 07*8/*Y_TOP*/, 07*8/*Y_BOTTOM*/}
	pl.PLA {24*8/*X_LEFT*/, 33*8/*X_RIGHT*/, 11*8/*Y_TOP*/, 11*8/*Y_BOTTOM*/}

	pl.PLA {14*8/*X_LEFT*/, 14*8/*X_RIGHT*/, 13*8/*Y_TOP*/, 14*8/*Y_BOTTOM*/}
	pl.PLA {14*8/*X_LEFT*/, 14*8/*X_RIGHT*/, 17*8/*Y_TOP*/, 18*8/*Y_BOTTOM*/}
	pl.PLA {14*8/*X_LEFT*/, 14*8/*X_RIGHT*/, 21*8/*Y_TOP*/, 22*8/*Y_BOTTOM*/}
	pl.PLA {14*8/*X_LEFT*/, 14*8/*X_RIGHT*/, 25*8/*Y_TOP*/, 26*8/*Y_BOTTOM*/}

	pl.PLA {23*8/*X_LEFT*/, 23*8/*X_RIGHT*/, 17*8/*Y_TOP*/, 18*8/*Y_BOTTOM*/}
	pl.PLA {23*8/*X_LEFT*/, 23*8/*X_RIGHT*/, 21*8/*Y_TOP*/, 22*8/*Y_BOTTOM*/}
	pl.PLA {23*8/*X_LEFT*/, 23*8/*X_RIGHT*/, 25*8/*Y_TOP*/, 26*8/*Y_BOTTOM*/}
platformsSizeL4 		BYTE 9

; Level 5
platformsL5
	pl.PLA {09*8/*X_LEFT*/, 15*8/*X_RIGHT*/, 07*8/*Y_TOP*/, 07*8/*Y_BOTTOM*/}
	pl.PLA {22*8/*X_LEFT*/, 30*8/*X_RIGHT*/, 12*8/*Y_TOP*/, 12*8/*Y_BOTTOM*/}

	pl.PLA {15*8/*X_LEFT*/, 15*8/*X_RIGHT*/, 08*8/*Y_TOP*/, 09*8/*Y_BOTTOM*/}
	pl.PLA {15*8/*X_LEFT*/, 15*8/*X_RIGHT*/, 12*8/*Y_TOP*/, 14*8/*Y_BOTTOM*/}
	pl.PLA {15*8/*X_LEFT*/, 15*8/*X_RIGHT*/, 17*8/*Y_TOP*/, 19*8/*Y_BOTTOM*/}
	pl.PLA {15*8/*X_LEFT*/, 15*8/*X_RIGHT*/, 22*8/*Y_TOP*/, 24*8/*Y_BOTTOM*/}
	pl.PLA {15*8/*X_LEFT*/, 15*8/*X_RIGHT*/, 27*8/*Y_TOP*/, 28*8/*Y_BOTTOM*/}

	pl.PLA {22*8/*X_LEFT*/, 22*8/*X_RIGHT*/, 13*8/*Y_TOP*/, 14*8/*Y_BOTTOM*/}
	pl.PLA {22*8/*X_LEFT*/, 22*8/*X_RIGHT*/, 17*8/*Y_TOP*/, 19*8/*Y_BOTTOM*/}
	pl.PLA {22*8/*X_LEFT*/, 22*8/*X_RIGHT*/, 22*8/*Y_TOP*/, 24*8/*Y_BOTTOM*/}
	pl.PLA {22*8/*X_LEFT*/, 22*8/*X_RIGHT*/, 27*8/*Y_TOP*/, 28*8/*Y_BOTTOM*/}
platformsSizeL5 		BYTE 11


; Level 6
platformsL6
	pl.PLA {08*8/*X_LEFT*/, 10*8/*X_RIGHT*/, 04*8/*Y_TOP*/, 04*8/*Y_BOTTOM*/}
	pl.PLA {11*8/*X_LEFT*/, 13*8/*X_RIGHT*/, 07*8/*Y_TOP*/, 07*8/*Y_BOTTOM*/}
	pl.PLA {14*8/*X_LEFT*/, 19*8/*X_RIGHT*/, 10*8/*Y_TOP*/, 10*8/*Y_BOTTOM*/}
	pl.PLA {19*8/*X_LEFT*/, 19*8/*X_RIGHT*/, 10*8/*Y_TOP*/, 16*8/*Y_BOTTOM*/}
	pl.PLA {22*8/*X_LEFT*/, 22*8/*X_RIGHT*/, 10*8/*Y_TOP*/, 16*8/*Y_BOTTOM*/}
	pl.PLA {22*8/*X_LEFT*/, 25*8/*X_RIGHT*/, 19*8/*Y_TOP*/, 19*8/*Y_BOTTOM*/}
	pl.PLA {26*8/*X_LEFT*/, 28*8/*X_RIGHT*/, 22*8/*Y_TOP*/, 22*8/*Y_BOTTOM*/}
	pl.PLA {29*8/*X_LEFT*/, 31*8/*X_RIGHT*/, 25*8/*Y_TOP*/, 25*8/*Y_BOTTOM*/}
	pl.PLA {32*8/*X_LEFT*/, 34*8/*X_RIGHT*/, 28*8/*Y_TOP*/, 28*8/*Y_BOTTOM*/}
platformsSizeL6 		BYTE 9

; Level 7
platformsL7
	pl.PLA {10*8/*X_LEFT*/, 27*8/*X_RIGHT*/, 06*8/*Y_TOP*/, 06*8/*Y_BOTTOM*/}

	pl.PLA {10*8/*X_LEFT*/, 10*8/*X_RIGHT*/, 07*8/*Y_TOP*/, 08*8/*Y_BOTTOM*/}
	pl.PLA {10*8/*X_LEFT*/, 10*8/*X_RIGHT*/, 11*8/*Y_TOP*/, 13*8/*Y_BOTTOM*/}
	pl.PLA {10*8/*X_LEFT*/, 10*8/*X_RIGHT*/, 16*8/*Y_TOP*/, 20*8/*Y_BOTTOM*/}
	pl.PLA {10*8/*X_LEFT*/, 10*8/*X_RIGHT*/, 23*8/*Y_TOP*/, 25*8/*Y_BOTTOM*/}
	pl.PLA {10*8/*X_LEFT*/, 10*8/*X_RIGHT*/, 29*8/*Y_TOP*/, 30*8/*Y_BOTTOM*/}

	pl.PLA {27*8/*X_LEFT*/, 27*8/*X_RIGHT*/, 07*8/*Y_TOP*/, 08*8/*Y_BOTTOM*/}
	pl.PLA {27*8/*X_LEFT*/, 27*8/*X_RIGHT*/, 11*8/*Y_TOP*/, 13*8/*Y_BOTTOM*/}
	pl.PLA {27*8/*X_LEFT*/, 27*8/*X_RIGHT*/, 16*8/*Y_TOP*/, 20*8/*Y_BOTTOM*/}
	pl.PLA {27*8/*X_LEFT*/, 27*8/*X_RIGHT*/, 23*8/*Y_TOP*/, 25*8/*Y_BOTTOM*/}
platformsSizeL7 		BYTE 10

; Level 8
platformsL8
	pl.PLA {01*8/*X_LEFT*/, 01*8/*X_RIGHT*/, 01*8/*Y_TOP*/, 30*8/*Y_BOTTOM*/}
	pl.PLA {04*8/*X_LEFT*/, 05*8/*X_RIGHT*/, 04*8/*Y_TOP*/, 06*8/*Y_BOTTOM*/}
	pl.PLA {04*8/*X_LEFT*/, 05*8/*X_RIGHT*/, 25*8/*Y_TOP*/, 27*8/*Y_BOTTOM*/}
	pl.PLA {08*8/*X_LEFT*/, 09*8/*X_RIGHT*/, 11*8/*Y_TOP*/, 13*8/*Y_BOTTOM*/}
	pl.PLA {08*8/*X_LEFT*/, 09*8/*X_RIGHT*/, 19*8/*Y_TOP*/, 21*8/*Y_BOTTOM*/}
	pl.PLA {17*8/*X_LEFT*/, 18*8/*X_RIGHT*/, 07*8/*Y_TOP*/, 09*8/*Y_BOTTOM*/}
	pl.PLA {15*8/*X_LEFT*/, 18*8/*X_RIGHT*/, 22*8/*Y_TOP*/, 22*8/*Y_BOTTOM*/}
	pl.PLA {23*8/*X_LEFT*/, 24*8/*X_RIGHT*/, 12*8/*Y_TOP*/, 14*8/*Y_BOTTOM*/}
	pl.PLA {23*8/*X_LEFT*/, 24*8/*X_RIGHT*/, 26*8/*Y_TOP*/, 28*8/*Y_BOTTOM*/}
	pl.PLA {26*8/*X_LEFT*/, 27*8/*X_RIGHT*/, 19*8/*Y_TOP*/, 21*8/*Y_BOTTOM*/}
	pl.PLA {31*8/*X_LEFT*/, 32*8/*X_RIGHT*/, 13*8/*Y_TOP*/, 15*8/*Y_BOTTOM*/}
	pl.PLA {35*8/*X_LEFT*/, 36*8/*X_RIGHT*/, 08*8/*Y_TOP*/, 11*8/*Y_BOTTOM*/}
	pl.PLA {34*8/*X_LEFT*/, 35*8/*X_RIGHT*/, 22*8/*Y_TOP*/, 24*8/*Y_BOTTOM*/}
	pl.PLA {33*8/*X_LEFT*/, 34*8/*X_RIGHT*/, 27*8/*Y_TOP*/, 29*8/*Y_BOTTOM*/}
	pl.PLA {39*8/*X_LEFT*/, 29*8/*X_RIGHT*/, 00*8/*Y_TOP*/, 30*8/*Y_BOTTOM*/}
platformsSizeL8 		BYTE 15

; Level 9
platformsL9
	pl.PLA {03*8/*X_LEFT*/, 08*8/*X_RIGHT*/, 12*8/*Y_TOP*/, 12*8/*Y_BOTTOM*/}
	pl.PLA {12*8/*X_LEFT*/, 17*8/*X_RIGHT*/, 17*8/*Y_TOP*/, 17*8/*Y_BOTTOM*/}
	pl.PLA {23*8/*X_LEFT*/, 27*8/*X_RIGHT*/, 06*8/*Y_TOP*/, 06*8/*Y_BOTTOM*/}

	pl.PLA {23*8/*X_LEFT*/, 27*8/*X_RIGHT*/, 23*8/*Y_TOP*/, 23*8/*Y_BOTTOM*/}
	pl.PLA {00*8/*X_LEFT*/, 00*8/*X_RIGHT*/, 00*8/*Y_TOP*/, 00*8/*Y_BOTTOM*/}
platformsSizeL9 		BYTE 5

; Level 10
platformsL10
	pl.PLA {03*8/*X_LEFT*/, 03*8/*X_RIGHT*/, 07*8/*Y_TOP*/, 08*8/*Y_BOTTOM*/}
	pl.PLA {03*8/*X_LEFT*/, 03*8/*X_RIGHT*/, 11*8/*Y_TOP*/, 12*8/*Y_BOTTOM*/}
	pl.PLA {03*8/*X_LEFT*/, 03*8/*X_RIGHT*/, 15*8/*Y_TOP*/, 16*8/*Y_BOTTOM*/}
	pl.PLA {03*8/*X_LEFT*/, 03*8/*X_RIGHT*/, 19*8/*Y_TOP*/, 20*8/*Y_BOTTOM*/}
	pl.PLA {03*8/*X_LEFT*/, 03*8/*X_RIGHT*/, 23*8/*Y_TOP*/, 24*8/*Y_BOTTOM*/}
	pl.PLA {03*8/*X_LEFT*/, 03*8/*X_RIGHT*/, 27*8/*Y_TOP*/, 28*8/*Y_BOTTOM*/}

	pl.PLA {08*8/*X_LEFT*/, 08*8/*X_RIGHT*/, 07*8/*Y_TOP*/, 08*8/*Y_BOTTOM*/}
	pl.PLA {08*8/*X_LEFT*/, 08*8/*X_RIGHT*/, 11*8/*Y_TOP*/, 12*8/*Y_BOTTOM*/}
	pl.PLA {08*8/*X_LEFT*/, 08*8/*X_RIGHT*/, 15*8/*Y_TOP*/, 16*8/*Y_BOTTOM*/}
	pl.PLA {08*8/*X_LEFT*/, 08*8/*X_RIGHT*/, 19*8/*Y_TOP*/, 20*8/*Y_BOTTOM*/}
	pl.PLA {08*8/*X_LEFT*/, 08*8/*X_RIGHT*/, 23*8/*Y_TOP*/, 24*8/*Y_BOTTOM*/}
	pl.PLA {08*8/*X_LEFT*/, 08*8/*X_RIGHT*/, 27*8/*Y_TOP*/, 28*8/*Y_BOTTOM*/}

	pl.PLA {13*8/*X_LEFT*/, 25*8/*X_RIGHT*/, 18*8/*Y_TOP*/, 18*8/*Y_BOTTOM*/}
	pl.PLA {13*8/*X_LEFT*/, 13*8/*X_RIGHT*/, 18*8/*Y_TOP*/, 26*8/*Y_BOTTOM*/}
	pl.PLA {25*8/*X_LEFT*/, 25*8/*X_RIGHT*/, 18*8/*Y_TOP*/, 30*8/*Y_BOTTOM*/}

	pl.PLA {30*8/*X_LEFT*/, 30*8/*X_RIGHT*/, 07*8/*Y_TOP*/, 08*8/*Y_BOTTOM*/}
	pl.PLA {30*8/*X_LEFT*/, 30*8/*X_RIGHT*/, 11*8/*Y_TOP*/, 12*8/*Y_BOTTOM*/}
	pl.PLA {30*8/*X_LEFT*/, 30*8/*X_RIGHT*/, 15*8/*Y_TOP*/, 16*8/*Y_BOTTOM*/}
	pl.PLA {30*8/*X_LEFT*/, 30*8/*X_RIGHT*/, 19*8/*Y_TOP*/, 20*8/*Y_BOTTOM*/}
	pl.PLA {30*8/*X_LEFT*/, 30*8/*X_RIGHT*/, 23*8/*Y_TOP*/, 24*8/*Y_BOTTOM*/}
	pl.PLA {30*8/*X_LEFT*/, 30*8/*X_RIGHT*/, 27*8/*Y_TOP*/, 28*8/*Y_BOTTOM*/}

	pl.PLA {35*8/*X_LEFT*/, 35*8/*X_RIGHT*/, 07*8/*Y_TOP*/, 08*8/*Y_BOTTOM*/}
	pl.PLA {35*8/*X_LEFT*/, 35*8/*X_RIGHT*/, 11*8/*Y_TOP*/, 12*8/*Y_BOTTOM*/}
	pl.PLA {35*8/*X_LEFT*/, 35*8/*X_RIGHT*/, 15*8/*Y_TOP*/, 16*8/*Y_BOTTOM*/}
	pl.PLA {35*8/*X_LEFT*/, 35*8/*X_RIGHT*/, 19*8/*Y_TOP*/, 20*8/*Y_BOTTOM*/}
	pl.PLA {35*8/*X_LEFT*/, 35*8/*X_RIGHT*/, 23*8/*Y_TOP*/, 24*8/*Y_BOTTOM*/}
	pl.PLA {35*8/*X_LEFT*/, 35*8/*X_RIGHT*/, 27*8/*Y_TOP*/, 28*8/*Y_BOTTOM*/}

platformsSizeL10 		BYTE 27

; ##############################################
; Final Checks.

	ASSERT $$ == _DB_ARR_BANK_D46					; Data should remain in the same bank
	ASSERT $$spritesBankStart == _DB_ARR_BANK_D46 	; Make sure that we have configured the right bank.

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE