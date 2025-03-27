;----------------------------------------------------------;
;                    Binary Data Loader                    ;
;----------------------------------------------------------;
	module db

;----------------------------------------------------------;
;                Game Sprites (Bank 40...41)               ;
;----------------------------------------------------------;
; Load sprites (16KB) into bank 40,41 mapping it to slot 6,7.
	MMU _RAM_SLOT6 _RAM_SLOT7, _BN_SPRITE_BANK1_D40
	ORG _RAM_SLOT6_START_HC000

; Sprites:
;   - 00-02: top, breathe
;   - 03-05: top, no breathe
;   - 06-11: low, walk
;   - 12-17: low, fly
;   - 18-21: low, hover
;   - 22-25: low, walk -> fly
;   - 26-29: low, fly -> walk
;   - 30-33: low, walk -> fall
;   - 34-37: low, stand
;   - 38-41: explosion
;   - 42-44: fire	
;   - 45-47: Flying enemy 1
;   - 48-50: Flying enemy 2
spritesBin INCBIN "assets/sprites.spr", 0, _BN_SPRITE_BYT_D16384
spritesBinLength = $ - spritesBin
	ASSERT $$ == _BN_SPRITE_BANK2_D41

;----------------------------------------------------------;
;               Game Tiles (Bank 42...43)                  ;
;----------------------------------------------------------;
; Load tiles and palette into 8K bank 42,42 mapping it to slot 6,7.
; Tilemap settings: 8px, 40x32 (2 bytes pre pixel), disable "include header" when downloading, file is then usable as is.

;Tiles:
;  - 00 - 56: Font, palette 0
;  - 59     : Empty, each palette
;  - 60 - 67: Ground 1, palette 1
;  - 68 - 95: Tree 1, 6x6 , palette 2, bytes: 2176-3071, last two 4x4 tiles (stump) are combined into one 4x4
;  - 96 - 131: Tree 2, 6x6 , palette 2, bytes: 3072-4023

	MMU _RAM_SLOT6 _RAM_SLOT7, _BN_TILES_BANK1_D42 ; Assign slots 6,7 to banks 42,43.
	ORG _RAM_SLOT6_START_HC000					; Set memory pointer to start of the slot 6.

tilesL10 INCBIN "assets/l05_tiles.map"			; Tiles for level 1-10 are below
tilesL10Bytes = $ - tilesL10
	ASSERT tilesL10Bytes == _TI_MAP_BYTES_D2560

; Sprite editor settings: 4bit, 8x8. After downloading manually remove empty data!
; Sprites
;  - 00 - 56: Font, palette 0
;  - 59     : Empty, each palette
;  - 60 - 67: Ground 1, palette 1
;  - 68 - 95: Tree 1, 6x6 , palette 2, bytes: 2176-3071, last two 4x4 tiles (stump) are combined into one 4x4
;  - 96 - 131: Tree 2, 6x6 , palette 2, bytes: 3072-4023

tileDefBin INCBIN "assets/tiles.spr"
tileDefBinLength = $ - tileDefBin
	ASSERT tileDefBinLength <= TI_DEF_MAX_D6910


; Palettes:
;	1: Text
;	2: Ground
;	3: Trees
;   4-6: Platforms

;  Values for Remy's editor:
/*
  $1C7    $0    $5   $27   $2F   $6F   $B7  $13F   $10   $13   $15   $17   $18   $1B   $1D   $1F
  $1C7    $8   $40   $41   $40   $21   $2D   $2F   $1B   $1D   $35   $37   $3B   $18   $3D   $80
  $1C7   $80   $18   $41   $A8   $10   $40   $60    $0   $1C1  $80   $1C1  $1C1  $1C1  $1C1   $DF
  $1C7   $1BB  $1B3  $1AB  $1A3  $19B  $193  $18B  $183  $1C7  $1C7  $1C7  $1C7  $1C7  $1C7  $1C7
  $1C7   $1F8  $1F0  $1E8  $1E0  $1D8  $1D0  $1C8  $1C0  $1C7  $1C7  $1C7  $1C7  $1C7  $1C7  $1C7
  $1C7   $85   $7D   $75   $6D   $65   $5D   $55   $4D   $1C7  $1C7  $1C7  $1C7  $1C7  $1C7  $1C7
*/
tilePaletteBin									; RGB332, 8 bit
	DB $E3, $00, $02, $13, $17, $37, $5B, $9F, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F
	DB $E3, $04, $20, $20, $20, $10, $16, $17, $0D, $0E, $1A, $1B, $1D, $0C, $1E, $40
	DB $E3, $40, $0C, $20, $54, $08, $20, $30, $00, $E0, $40, $E0, $E0, $E0, $E0, $6F
	DB $E3, $DD, $D9, $D5, $D1, $CD, $C9, $C5, $C1, $E3, $E3, $E3, $E3, $E3, $E3, $E3
	DB $E3, $FC, $F8, $F4, $F0, $EC, $E8, $E4, $E0, $E3, $E3, $E3, $E3, $E3, $E3, $E3
	DB $E3, $42, $3E, $3A, $36, $32, $2E, $2A, $26, $E3, $E3, $E3, $E3, $E3, $E3, $E3
tilePaletteBinLength = $ - tilePaletteBin
	
	ASSERT $ > _RAM_SLOT6_START_HC000			; All data should fit into slot 6,7.
	ASSERT $ <= _RAM_SLOT7_END_HFFFF 			
	ASSERT $$ <= _BN_TILES_BANK2_D43 			; All data should fit into bank 43.

;----------------------------------------------------------;
;                   Star Tiles (Bank 44)                   ;
;----------------------------------------------------------;
	MMU _RAM_SLOT6 _RAM_SLOT7, _BN_STARTS_BANK1_D44 ; Assign slots 6,7 to banks 44,45.
	ORG _RAM_SLOT6_START_HC000					; Set memory pointer to start of the slot 6.

starsBin INCBIN "assets/stars.map"
starsBinSize = $ - starsBin

	ASSERT starsBinSize == _TIS_BYTES_D10240
	ASSERT $ > _RAM_SLOT6_START_HC000			; All data should fit into slot 6,7.
	ASSERT $ <= _RAM_SLOT7_END_HFFFF 			
	ASSERT $$ == _BN_STARTS_BANK2_D45 			; All data should fit into bank 43.

;----------------------------------------------------------;
;                Layer 2 Palettes (Bank 46)                ;
;----------------------------------------------------------;
	MMU _RAM_SLOT6, _BN_PAL2_BANK_D46
	ORG _RAM_SLOT6_START_HC000

 ; #############################################
bgrL1PaletteAdr
	INCBIN  "assets/l01_background.nxp"

bgrL1PaletteBytes = $ - bgrL1PaletteAdr
	ASSERT bgrL1PaletteBytes <= _BM_PAL2_BYTES_D512

 ; #############################################
bgrL2PaletteAdr
	INCBIN  "assets/l02_background.nxp"

bgrL2PaletteBytes = $ - bgrL2PaletteAdr
	ASSERT bgrL2PaletteBytes <= _BM_PAL2_BYTES_D512

 ; #############################################
bgrL3PaletteAdr
	INCBIN  "assets/l03_background.nxp"

bgrL3PaletteBytes = $ - bgrL3PaletteAdr
	ASSERT bgrL3PaletteBytes <= _BM_PAL2_BYTES_D512

 ; #############################################
bgrL4PaletteAdr
	INCBIN  "assets/l04_background.nxp"

bgrL4PaletteBytes = $ - bgrL4PaletteAdr
	ASSERT bgrL4PaletteBytes <= _BM_PAL2_BYTES_D512

 ; #############################################
bgrL5PaletteAdr
	INCBIN  "assets/l05_background.nxp"

bgrL5PaletteBytes = $ - bgrL5PaletteAdr
	ASSERT bgrL5PaletteBytes <= _BM_PAL2_BYTES_D512

 ; #############################################
bgrL6PaletteAdr
	INCBIN  "assets/l06_background.nxp"

bgrL6PaletteBytes = $ - bgrL6PaletteAdr
	ASSERT bgrL6PaletteBytes <= _BM_PAL2_BYTES_D512
	
 ; #############################################
bgrL7PaletteAdr
	INCBIN  "assets/l07_background.nxp"

bgrL7PaletteBytes = $ - bgrL7PaletteAdr
	ASSERT bgrL7PaletteBytes <= _BM_PAL2_BYTES_D512

 ; #############################################
bgrL8PaletteAdr
	INCBIN  "assets/l08_background.nxp"

bgrL8PaletteBytes = $ - bgrL8PaletteAdr
	ASSERT bgrL8PaletteBytes <= _BM_PAL2_BYTES_D512

 ; #############################################
bgrL9PaletteAdr
	INCBIN  "assets/l09_background.nxp"

bgrL9PaletteBytes = $ - bgrL9PaletteAdr
	ASSERT bgrL9PaletteBytes <= _BM_PAL2_BYTES_D512

 ; #############################################
bgrL10PaletteAdr
	INCBIN  "assets/l10_background.nxp"

bgrL10PaletteBytes = $ - bgrL10PaletteAdr
	ASSERT bgrL10PaletteBytes <= _BM_PAL2_BYTES_D512
	
 ; #############################################
	ASSERT $$ == _BN_PAL2_BANK_D46	

;----------------------------------------------------------;
;          Layer 2 Brightness Palettes (Bank 47)           ;
;----------------------------------------------------------;
todL2Palettes									; Palette will be generated during runtime.

;----------------------------------------------------------;
;              Game Background (Bank 48...57)              ;
;----------------------------------------------------------;
; The screen size is 320x256 (81920 bytes, 80KiB) -> 10 8KB banks.

;----------------------------------------------------------;
;                  Star Data (Bank 148)                    ;
;----------------------------------------------------------;
; Before using it call #bs.SetupStarsDataBank

	MMU _RAM_SLOT7, _ST_BANK_D148
	ORG _RAM_SLOT7_START_HE000
starsBankStart

starsDataL1
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

	st.SC {1/*BANK*/, 19/*X_OFFSET*/, 6/*SIZE*/}	; X=51
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

	st.SC {4/*BANK*/, 02/*X_OFFSET*/, 6/*SIZE*/}	; X=130
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

starsDataL2
	st.SC {0/*BANK*/, 10/*X_OFFSET*/, 4/*SIZE*/}	; X=10
	DB 4,4, 42,8, 133,1, 245,9

	st.SC {1/*BANK*/, 10/*X_OFFSET*/, 6/*SIZE*/}	; X=42
	DB 26,3, 45,8, 125,4, 138,3, 160,9, 193,2

	st.SC {1/*BANK*/, 20/*X_OFFSET*/, 5/*SIZE*/}	; X=52
	DB 14,2, 52,4, 113,6, 189,8, 241,1

	st.SC {2/*BANK*/, 02/*X_OFFSET*/, 5/*SIZE*/}	; X=66
	DB 10,1, 115,4, 130,9, 155,2, 230,4

	st.SC {2/*BANK*/, 18/*X_OFFSET*/, 5/*SIZE*/}	; X=82
	DB 38,1, 78,5, 132,9, 149,2, 231,5

	st.SC {3/*BANK*/, 12/*X_OFFSET*/, 5/*SIZE*/}	; X=108
	DB 5,3, 38,6, 120,9, 158,4, 245,1

	st.SC {3/*BANK*/, 18/*X_OFFSET*/, 5/*SIZE*/}	; X=114
	DB 31,5, 93,4, 159,1, 178,8, 248,4

	st.SC {4/*BANK*/, 1/*X_OFFSET*/, 5/*SIZE*/}		; X=129
	DB 10,4, 104,5, 145,6, 190,8, 249,3

	st.SC {4/*BANK*/, 25/*X_OFFSET*/, 4/*SIZE*/}	; X=153
	DB 21,1, 92,6, 158,9, 221,6

	st.SC {5/*BANK*/, 15/*X_OFFSET*/, 6/*SIZE*/}	; X=175
	DB 4,4, 90,1, 144,8, 148,2, 202,5, 251,7

	st.SC {5/*BANK*/, 20/*X_OFFSET*/, 5/*SIZE*/}	; X=180
	DB 24,2, 44,9, 126,3, 160,7, 243,9

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
starsDataL1MaxY
	DB 143/*X=002*/, 154/*X=008*/, 159/*X=020*/, 196/*X=037*/, 195/*X=047*/, 195/*X=051*/, 140/*X=068*/, 134/*X=075*/, 106/*X=084*/, 192/*X=097*/
	DB 049/*X=116*/, 039/*X=124*/, 023/*X=130*/, 019/*X=143*/, 023/*X=151*/, 123/*X=171*/, 062/*X=180*/, 082/*X=197*/, 104/*X=212*/, 187/*X=227*/
	DB 187/*X=236*/, 187/*X=254*/, 128/*X=264*/, 119/*X=272*/, 102/*X=287*/, 221/*X=308*/, 230/*X=318*/

starsDataL2MaxY
	DB 153/*X=010*/, 196/*X=042*/, 195/*X=052*/, 142/*X=066*/, 106/*X=082*/, 086/*X=108*/, 082/*X=114*/, 037/*X=129*/, 024/*X=153*/
	DB 121/*X=175*/, 063/*X=180*/, 080/*X=194*/, 087/*X=202*/, 187/*X=235*/, 123/*X=268*/, 106/*X=281*/, 222/*X=301*/

starsPalL1
	DW $1FF, $1FF, $1FF, $120, $123, $125, $127, $128, $12B, $12D, $12F, $130, $133, $135, $137, $138, $13B, $13D, $13F, $0, $0, $0, $0, $0, $0

starsPalL2
	DW  $40, $36, $48, $8, $B, $0, $0, $0, $0, $0

	; ##########################################
	ASSERT $$ == _ST_BANK_D148					; Data should remain in the same bank
	ASSERT $$starsBankStart == _ST_BANK_D148 	; Make sure that we have configured the right bank.

;----------------------------------------------------------;
;                  Arrays (Bank 149)                       ;
;----------------------------------------------------------;
; Before using it call #SetupArraysDataBank
	MMU _RAM_SLOT7, _BN_SPR_BANK_D149
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
											DB 03,17, 03,18, 04,19, 04,18, 05,17, 05,19, 03,17, 03,18, 04,19, 04,17
											DB 05,19, 05,18, 00,19, 00,18, 01,17, 01,18, 02,17, 02,19, 03,18, 03,18
											DB 04,19, 05,17, 05,18

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
	ro.RO {030/*DROP_X*/, 107/*DROP_LAND_Y*/, 226/*ASSEMBLY_Y*/, 43/*SPRITE_ID*/, 51/*SPRITE_REF*/, 0/*Y*/}
	ro.RO {070/*DROP_X*/, 235/*DROP_LAND_Y*/, 226/*ASSEMBLY_Y*/, 43/*SPRITE_ID*/, 51/*SPRITE_REF*/, 0/*Y*/}
	ro.RO {250/*DROP_X*/, 235/*DROP_LAND_Y*/, 226/*ASSEMBLY_Y*/, 43/*SPRITE_ID*/, 51/*SPRITE_REF*/, 0/*Y*/}
	
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
	pl.PLA {3*8/*X_LEFT*/,  8*8/*X_RIGHT*/,  15*8/*Y_TOP*/, 16*8/*Y_BOTTOM*/}
	pl.PLA {11*8/*X_LEFT*/, 17*8/*X_RIGHT*/, 21*8/*Y_TOP*/, 22*8/*Y_BOTTOM*/}
	pl.PLA {25*8/*X_LEFT*/, 30*8/*X_RIGHT*/, 10*8/*Y_TOP*/, 11*8/*Y_BOTTOM*/}
platformsSizeL1 		BYTE 3

; Level 2
platformsL2
	pl.PLA {3*8/*X_LEFT*/,  8*8/*X_RIGHT*/,  15*8/*Y_TOP*/, 16*8/*Y_BOTTOM*/}
	pl.PLA {11*8/*X_LEFT*/, 17*8/*X_RIGHT*/, 21*8/*Y_TOP*/, 22*8/*Y_BOTTOM*/}
	pl.PLA {25*8/*X_LEFT*/, 30*8/*X_RIGHT*/, 10*8/*Y_TOP*/, 11*8/*Y_BOTTOM*/}
platformsSizeL2 		BYTE 3

; Level 3
platformsL3
	pl.PLA {3*8/*X_LEFT*/,  8*8/*X_RIGHT*/,  15*8/*Y_TOP*/, 16*8/*Y_BOTTOM*/}
	pl.PLA {11*8/*X_LEFT*/, 17*8/*X_RIGHT*/, 21*8/*Y_TOP*/, 22*8/*Y_BOTTOM*/}
	pl.PLA {25*8/*X_LEFT*/, 30*8/*X_RIGHT*/, 10*8/*Y_TOP*/, 11*8/*Y_BOTTOM*/}
platformsSizeL3 		BYTE 3

; Level 4
platformsL4
	pl.PLA {3*8/*X_LEFT*/,  8*8/*X_RIGHT*/,  15*8/*Y_TOP*/, 16*8/*Y_BOTTOM*/}
	pl.PLA {11*8/*X_LEFT*/, 17*8/*X_RIGHT*/, 21*8/*Y_TOP*/, 22*8/*Y_BOTTOM*/}
	pl.PLA {25*8/*X_LEFT*/, 30*8/*X_RIGHT*/, 10*8/*Y_TOP*/, 11*8/*Y_BOTTOM*/}
platformsSizeL4 		BYTE 3

; Level 5
platformsL5
	pl.PLA {3*8/*X_LEFT*/,  8*8/*X_RIGHT*/,  15*8/*Y_TOP*/, 16*8/*Y_BOTTOM*/}
	pl.PLA {11*8/*X_LEFT*/, 17*8/*X_RIGHT*/, 21*8/*Y_TOP*/, 22*8/*Y_BOTTOM*/}
	pl.PLA {25*8/*X_LEFT*/, 30*8/*X_RIGHT*/, 10*8/*Y_TOP*/, 11*8/*Y_BOTTOM*/}
platformsSizeL5 		BYTE 3

; Level 6
platformsL6
	pl.PLA {3*8/*X_LEFT*/,  8*8/*X_RIGHT*/,  15*8/*Y_TOP*/, 16*8/*Y_BOTTOM*/}
	pl.PLA {11*8/*X_LEFT*/, 17*8/*X_RIGHT*/, 21*8/*Y_TOP*/, 22*8/*Y_BOTTOM*/}
	pl.PLA {25*8/*X_LEFT*/, 30*8/*X_RIGHT*/, 10*8/*Y_TOP*/, 11*8/*Y_BOTTOM*/}
platformsSizeL6 		BYTE 3

; Level 7
platformsL7
	pl.PLA {3*8/*X_LEFT*/,  8*8/*X_RIGHT*/,  15*8/*Y_TOP*/, 16*8/*Y_BOTTOM*/}
	pl.PLA {11*8/*X_LEFT*/, 17*8/*X_RIGHT*/, 21*8/*Y_TOP*/, 22*8/*Y_BOTTOM*/}
	pl.PLA {25*8/*X_LEFT*/, 30*8/*X_RIGHT*/, 10*8/*Y_TOP*/, 11*8/*Y_BOTTOM*/}
platformsSizeL7 		BYTE 3

; Level 8
platformsL8
	pl.PLA {3*8/*X_LEFT*/,  8*8/*X_RIGHT*/,  15*8/*Y_TOP*/, 16*8/*Y_BOTTOM*/}
	pl.PLA {11*8/*X_LEFT*/, 17*8/*X_RIGHT*/, 21*8/*Y_TOP*/, 22*8/*Y_BOTTOM*/}
	pl.PLA {25*8/*X_LEFT*/, 30*8/*X_RIGHT*/, 10*8/*Y_TOP*/, 11*8/*Y_BOTTOM*/}
platformsSizeL8 		BYTE 3

; Level 9
platformsL9
	pl.PLA {3*8/*X_LEFT*/,  8*8/*X_RIGHT*/,  15*8/*Y_TOP*/, 16*8/*Y_BOTTOM*/}
	pl.PLA {11*8/*X_LEFT*/, 17*8/*X_RIGHT*/, 21*8/*Y_TOP*/, 22*8/*Y_BOTTOM*/}
	pl.PLA {25*8/*X_LEFT*/, 30*8/*X_RIGHT*/, 10*8/*Y_TOP*/, 11*8/*Y_BOTTOM*/}
platformsSizeL9 		BYTE 3

; Level 10
platformsL10
	pl.PLA {3*8/*X_LEFT*/,  8*8/*X_RIGHT*/,  15*8/*Y_TOP*/, 16*8/*Y_BOTTOM*/}
	pl.PLA {11*8/*X_LEFT*/, 17*8/*X_RIGHT*/, 21*8/*Y_TOP*/, 22*8/*Y_BOTTOM*/}
	pl.PLA {25*8/*X_LEFT*/, 30*8/*X_RIGHT*/, 10*8/*Y_TOP*/, 11*8/*Y_BOTTOM*/}
platformsSizeL10 		BYTE 3

; ##############################################
; Final Checks.

	ASSERT $$ == _BN_SPR_BANK_D149					; Data should remain in the same bank
	ASSERT $$spritesBankStart == _BN_SPR_BANK_D149 	; Make sure that we have configured the right bank.

;----------------------------------------------------------;
;            Game Tiles L1 to L3 (Bank 150)                ;
;----------------------------------------------------------;
	; Tilemap settings: 8px, 40x32 (2 bytes pre pixel), disable "include header" when downloading, file is then usable as is.

	MMU _RAM_SLOT6, _BN_TI_L1_3_BANK_D150
	ORG _RAM_SLOT6_START_HC000

	; Level 1
tilesL1 INCBIN "assets/l01_tiles.map"
tilesL1Bytes = $ - tilesL1
	ASSERT tilesL1Bytes == _TI_MAP_BYTES_D2560

	ASSERT $$ == _BN_TI_L1_3_BANK_D150

	; Level 2
tilesL2 INCBIN "assets/l02_tiles.map"
tilesL2Bytes = $ - tilesL2
	ASSERT tilesL2Bytes == _TI_MAP_BYTES_D2560

	ASSERT $$ == _BN_TI_L1_3_BANK_D150

	; Level 3
tilesL3 INCBIN "assets/l03_tiles.map"
tilesL3Bytes = $ - tilesL3
	ASSERT tilesL3Bytes == _TI_MAP_BYTES_D2560

	ASSERT $$ == _BN_TI_L1_3_BANK_D150

;----------------------------------------------------------;
;            Game Tiles L4 to L6 (Bank 151)                ;
;----------------------------------------------------------;
	MMU _RAM_SLOT6, _BN_TI_L4_6_BANK_D151
	ORG _RAM_SLOT6_START_HC000

	; Level 4
tilesL4 INCBIN "assets/l04_tiles.map"
tilesL4Bytes = $ - tilesL4
	ASSERT tilesL4Bytes == _TI_MAP_BYTES_D2560

	; Level 5
tilesL5 INCBIN "assets/l05_tiles.map"
tilesL5Bytes = $ - tilesL5
	ASSERT tilesL5Bytes == _TI_MAP_BYTES_D2560

	; Level 6
tilesL6 INCBIN "assets/l05_tiles.map"
tilesL6Bytes = $ - tilesL6
	ASSERT tilesL6Bytes == _TI_MAP_BYTES_D2560

	ASSERT $$ == _BN_TI_L4_6_BANK_D151

;----------------------------------------------------------;
;            Game Tiles L7 to L9 (Bank 152)                ;
;----------------------------------------------------------;
	MMU _RAM_SLOT6, _BN_TI_L7_9_BANK_D152
	ORG _RAM_SLOT6_START_HC000

	; Level 7
tilesL7 INCBIN "assets/l05_tiles.map"
tilesL7Bytes = $ - tilesL7
	ASSERT tilesL7Bytes == _TI_MAP_BYTES_D2560

	; Level 8
tilesL8 INCBIN "assets/l05_tiles.map"
tilesL8Bytes = $ - tilesL8
	ASSERT tilesL8Bytes == _TI_MAP_BYTES_D2560

	; Level 9
tilesL9 INCBIN "assets/l05_tiles.map"
tilesL9Bytes = $ - tilesL9
	ASSERT tilesL9Bytes == _TI_MAP_BYTES_D2560

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE