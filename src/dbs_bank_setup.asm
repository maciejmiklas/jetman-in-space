;----------------------------------------------------------;
;                      Bank Setup                          ;
;----------------------------------------------------------;
    MODULE dbs

; We hold two background images in RAM: Image A and Image B. Image A is the original image read from the file. Image B is the image being 
; displayed. It was set using: "NEXTREG _DC_REG_L2_BANK_H12, BM_16KBANK_D9" (16K bank 9 = 8k bank 18).
; This is necessary because Image B moves with Jetman and hides behind the horizon. We replace image lines with black. Once Jetman moves in 
; the opposite direction, we have to copy the original image line from A to B.

BMB_ST_BANK_S7_D18      = 18                    ; Slot 7. Start of displayed Layer 2 image
BMB_END_BANK_S7_D27     = 27                    ; Last background bank (inclusive)

ST_BANK_S7_D28          = 28                    ; Slot 7. Bank for stars, slot 6
ARR_BANK_S7_D29         = 29                    ; Slot 7. Bank for arrays, slot 6
TI_SPR_BANK_S7_D30      = 30
PAL2_BANK_S6_D31        = 31                    ; Slot 6. Layer 2 pallettes
AY_FX_S6_D32            = 32                    ; Slot 6. FX sound
AY_MUSIC_S6_D33         = 33                    ; Slot 6. FX sound

PAL2_BR_BANK_S7_D70     = 70                    ; Slot 7. Layer 2 brightness change for pallettes from PAL2_BANK_S6_D31
SPR_BANK1_S6_D71        = 71
SPR_BANK2_S7_D72        = 72

; Original background image (all values inclusive), Slot 6. Background image has 80KiB (320x256), taking 10 banks.
BM_BANKS_D10            = 10                    ; Background image occupies 10 8K banks from 72 to 82 (starts on 16K bank 9, uses 5 16K banks)
BMA_ST_BANK_S6_D73      = 73
BMA_EN_BANK_S6_D82  = BMA_ST_BANK_S6_D73+BM_BANKS_D10-1; -1 because inclusive
    ASSERT BMA_EN_BANK_S6_D82 == 82

LONG_TI_BANK1_S6_D82    = 83                   ; Slot 6. Tilemap up to 16KiB
LONG_TI_BANK2_S7_D84    = 84                   ; Slot 7
EMPTY_IMG_S6_D86        = 86                   ; Slot 6. Empty image

;----------------------------------------------------------;
;                 #SetupEmptyImageBank                     ;
;----------------------------------------------------------;
SetupEmptyImageBank

    NEXTREG _MMU_REG_SLOT6_H56, EMPTY_IMG_S6_D86

    RET                                         ; ## END of the function ## 

;----------------------------------------------------------;
;               #SetupVortexTrackerBank                    ;
;----------------------------------------------------------;
SetupVortexTrackerBank

    NEXTREG _MMU_REG_SLOT6_H56, AY_MUSIC_S6_D33

    RET                                         ; ## END of the function ## 

;----------------------------------------------------------;
;                    #SetupAyFxsBank                       ;
;----------------------------------------------------------;
SetupAyFxsBank

    NEXTREG _MMU_REG_SLOT6_H56, AY_FX_S6_D32    ; $C000 - $DFFF

    RET                                         ; ## END of the function ## 

;----------------------------------------------------------;
;                    #SetupTilesBank                       ;
;----------------------------------------------------------;
SetupTilesBank

    NEXTREG _MMU_REG_SLOT7_H57, TI_SPR_BANK_S7_D30

    RET                                         ; ## END of the function ## 

;----------------------------------------------------------;
;                #Setup16KTilemapBank                      ;
;----------------------------------------------------------;
Setup16KTilemapBank

    NEXTREG _MMU_REG_SLOT6_H56, LONG_TI_BANK1_S6_D82
    NEXTREG _MMU_REG_SLOT7_H57, LONG_TI_BANK2_S7_D84

    RET                                         ; ## END of the function ##


;----------------------------------------------------------;
;                 #Setup8KTilemapBank                      ;
;----------------------------------------------------------;
Setup8KTilemapBank

    NEXTREG _MMU_REG_SLOT6_H56, LONG_TI_BANK1_S6_D82

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  #SetupSpritesBank                       ;
;----------------------------------------------------------;
SetupSpritesBank

    NEXTREG _MMU_REG_SLOT6_H56, SPR_BANK1_S6_D71
    NEXTREG _MMU_REG_SLOT7_H57, SPR_BANK2_S7_D72

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    #SetupStarsBank                       ;
;----------------------------------------------------------;
SetupStarsBank

    NEXTREG _MMU_REG_SLOT7_H57, ST_BANK_S7_D28

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   #SetupArraysBank                       ;
;----------------------------------------------------------;
SetupArraysBank

    NEXTREG _MMU_REG_SLOT7_H57, ARR_BANK_S7_D29

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   #SetupPaletteBank                      ;
;----------------------------------------------------------;
SetupPaletteBank

    ; Memory bank (8KiB) containing layer 2 palette data
    NEXTREG _MMU_REG_SLOT6_H56, PAL2_BANK_S6_D31

    ; Memory bank (8KiB) containing layer 2 palettes with brightness for times of the day
    NEXTREG _MMU_REG_SLOT7_H57, PAL2_BR_BANK_S7_D70
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE
