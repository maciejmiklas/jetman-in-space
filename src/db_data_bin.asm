;----------------------------------------------------------;
;                    Binary Data Loader                    ;
;----------------------------------------------------------;
    module db

;----------------------------------------------------------;
;         Game Background Image (Bank 18...27)             ;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                  Star Data (Bank 28)                     ;
;----------------------------------------------------------;
; see: dbs_data_starts.asm
;----------------------------------------------------------;
;                    Arrays (Bank 29)                      ;
;----------------------------------------------------------;
; see: dba_data_arrays.asm

;----------------------------------------------------------;
;         Game Tile Sprites and Palette (Bank 30)          ;
;----------------------------------------------------------;
    MMU _RAM_SLOT7, dbs.TI_SPR_BANK_S7_D30      ; Assign slots 7 to bank 30
    ORG _RAM_SLOT7_STA_HE000                    ; Set memory pointer to start of the slot 6

; Sprite editor settings: 4bit, 8x8. After downloading manually remove empty data!
; Sprites
;  - 00 - 56:  Font, palette 0
;  - 59     :  Empty, each palette
;  - 60 - 67:  Ground 1, palette 1
;  - 68 - 95:  Tree 1, 6x6 , palette 2, bytes: 2176-3071, last two 4x4 tiles (stump) are combined into one 4x4
;  - 96 - 131: Tree 2, 6x6 , palette 2, bytes: 3072-4023

tileSprBin INCBIN "assets/com/tiles.spr"
tileSprBinLength = $ - tileSprBin
    ASSERT tileSprBinLength <= ti.TI_DEF_MAX_D6910

; Palettes:
;   0: Text
;   1: Ground and brown platforms
;   2: Trees
;   3: Jetpack overheat
;   4-5: Colored platforms
;   6: Rocket progress bar

;  Values for Remy's editor:
/*
  $1C7    $0    $5   $27   $2F   $6F   $B7  $13F   $10   $13   $15   $17   $18   $1B   $1D   $1F
  $1C7    $8   $40   $41   $40   $21   $2D   $2F   $1B   $1D   $35   $37   $3B   $18   $3D   $80
  $1C7   $80   $18   $41   $A8   $10   $40   $60    $0  $1C1   $80  $1C1  $1C1  $1C1  $1C1   $DF
  $1C7  $1C7  $1F8  $1AB  $1A3  $19B  $193  $18B  $183  $1C0   $B0  $1F0   $4D   $55   $38  $1C7
  $1C7  $1F8  $1F0  $1E8  $1E0  $1D8  $1D0  $1C8  $1C0  $1C0  $1C7  $1C7  $1C7  $1C7  $1C7  $1C7
  $1C7   $85   $7D   $75   $6D   $65   $5D   $55   $4D  $5    $1C7  $1C7  $1C7  $1C7  $1C7  $1C7
  $1C7  $1BB  $1BA  $1B3  $1A3  $1B0  $193  $18B  $1AB  $1C0  $1B3  $1FB   $4D   $55  $1B5  $1C7
*/
tilePaletteBin                                  ; RGB332, 8 bit
	DB $E3, $00, $02, $13, $17, $37, $5B, $9F, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F
	DB $E3, $04, $20, $20, $20, $10, $16, $17, $0D, $0E, $1A, $1B, $1D, $0C, $1E, $40
	DB $E3, $40, $0C, $20, $54, $08, $20, $30, $00, $E0, $40, $E0, $E0, $E0, $E0, $6F
	DB $E3, $E3, $FC, $D5, $D1, $CD, $C9, $C5, $C1, $E0, $58, $F8, $26, $2A, $1C, $E3
	DB $E3, $FC, $F8, $F4, $F0, $EC, $E8, $E4, $E0, $E0, $E3, $E3, $E3, $E3, $E3, $E3
	DB $E3, $42, $3E, $3A, $36, $32, $2E, $2A, $26, $02, $E3, $E3, $E3, $E3, $E3, $E3
	DB $E3, $DD, $DD, $D9, $D1, $D8, $C9, $C5, $D5, $E0, $D9, $FD, $26, $2A, $DA, $E3
tilePaletteBinLength = $ - tilePaletteBin
    
    ASSERT $ > _RAM_SLOT6_STA_HC000             ; All data should fit into slot 6,7
    ASSERT $ <= _RAM_SLOT7_END_HFFFF
    ASSERT $$ <= dbs.TI_SPR_BANK_S7_D30         ; All data should fit into bank 45
    
;----------------------------------------------------------;
;                Layer 2 Palettes (Bank 31)                ;
;----------------------------------------------------------;
    MMU _RAM_SLOT6, dbs.PAL2_BANK_S6_D31
    ORG _RAM_SLOT6_STA_HC000

 ; #############################################
bgrL1PaletteAdr
    INCBIN  "assets/l01/bg.nxp"

bgrL1PaletteBytes = $ - bgrL1PaletteAdr
    ASSERT bgrL1PaletteBytes <= btd.PAL2_BYTES_D512

 ; #############################################
bgrL2PaletteAdr
    INCBIN  "assets/l02/bg.nxp"

bgrL2PaletteBytes = $ - bgrL2PaletteAdr
    ASSERT bgrL2PaletteBytes <= btd.PAL2_BYTES_D512

 ; #############################################
bgrL3PaletteAdr
    INCBIN  "assets/l03/bg.nxp"

bgrL3PaletteBytes = $ - bgrL3PaletteAdr
    ASSERT bgrL3PaletteBytes <= btd.PAL2_BYTES_D512

 ; #############################################
bgrL4PaletteAdr
    INCBIN  "assets/l04/bg.nxp"

bgrL4PaletteBytes = $ - bgrL4PaletteAdr
    ASSERT bgrL4PaletteBytes <= btd.PAL2_BYTES_D512

 ; #############################################
bgrL5PaletteAdr
    INCBIN  "assets/l05/bg.nxp"

bgrL5PaletteBytes = $ - bgrL5PaletteAdr
    ASSERT bgrL5PaletteBytes <= btd.PAL2_BYTES_D512

 ; #############################################
bgrL6PaletteAdr
    INCBIN  "assets/l06/bg.nxp"

bgrL6PaletteBytes = $ - bgrL6PaletteAdr
    ASSERT bgrL6PaletteBytes <= btd.PAL2_BYTES_D512
    
 ; #############################################
bgrL7PaletteAdr
    INCBIN  "assets/l07/bg.nxp"

bgrL7PaletteBytes = $ - bgrL7PaletteAdr
    ASSERT bgrL7PaletteBytes <= btd.PAL2_BYTES_D512

 ; #############################################
bgrL8PaletteAdr
    INCBIN  "assets/l08/bg.nxp"

bgrL8PaletteBytes = $ - bgrL8PaletteAdr
    ASSERT bgrL8PaletteBytes <= btd.PAL2_BYTES_D512

 ; #############################################
bgrL9PaletteAdr
    INCBIN  "assets/l09/bg.nxp"

bgrL9PaletteBytes = $ - bgrL9PaletteAdr
    ASSERT bgrL9PaletteBytes <= btd.PAL2_BYTES_D512

 ; #############################################
bgrL10PaletteAdr
    INCBIN  "assets/l10/bg.nxp"

bgrL10PaletteBytes = $ - bgrL10PaletteAdr
    ASSERT bgrL10PaletteBytes <= btd.PAL2_BYTES_D512

 ; #############################################
gameIntroPaletteAdr
    INCBIN  "assets/l01/intro.nxp"

gameIntroPaletteBytes = $ - gameIntroPaletteAdr
    ASSERT gameIntroPaletteBytes <= btd.PAL2_BYTES_D512

 ; ############################################
menuMainBgPaletteAdr
    INCBIN  "assets/mma/bg.nxp"

menuMainBgPaletteBytes = $ - menuMainBgPaletteAdr
    ASSERT menuMainBgPaletteBytes <= btd.PAL2_BYTES_D512

 ; #############################################
menuGameplayBgPaletteAdr
    INCBIN  "assets/mmg/bg.nxp"

menuGameplayBgPaletteBytes = $ - menuGameplayBgPaletteAdr
    ASSERT menuGameplayBgPaletteBytes <= btd.PAL2_BYTES_D512

 ; #############################################
menuKeysBgPaletteAdr
    INCBIN  "assets/mmk/bg.nxp"

menuKeysBgPaletteBytes = $ - menuKeysBgPaletteAdr
    ASSERT menuKeysBgPaletteBytes <= btd.PAL2_BYTES_D512

 ; #############################################
menuEasyBgPaletteAdr
    INCBIN  "assets/mma/easy.nxp"

menuEasyBgPaletteBytes = $ - menuEasyBgPaletteAdr
    ASSERT menuEasyBgPaletteBytes <= btd.PAL2_BYTES_D512

 ; #############################################
menuHardBgPaletteAdr
    INCBIN  "assets/mma/hard.nxp"

menuHardBgPaletteBytes = $ - menuHardBgPaletteAdr
    ASSERT menuHardBgPaletteBytes <= btd.PAL2_BYTES_D512

 ; #############################################
menuScoreBgPaletteAdr
    INCBIN  "assets/mms/bg.nxp"

menuScoreBgPaletteBytes = $ - menuScoreBgPaletteAdr
    ASSERT menuHardBgPaletteBytes <= btd.PAL2_BYTES_D512

 ; #############################################
gameOverBgPaletteAdr
    INCBIN  "assets/go/bg.nxp"

gameOverBgPaletteBytes = $ - gameOverBgPaletteAdr
    ASSERT menuHardBgPaletteBytes <= btd.PAL2_BYTES_D512

 ; #############################################
    ASSERT $$ == dbs.PAL2_BANK_S6_D31

;----------------------------------------------------------;
;               AY FX Sound (Bank 32)                      ;
;----------------------------------------------------------;

;----------------------------------------------------------;
;          Layer 2 Brightness Palettes (Bank 70)           ;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                Game Sprites (Bank 71...72)               ;
;----------------------------------------------------------;
; Load sprites (16KB) into 2 banks mapping it to slot 6,7

;----------------------------------------------------------;
;              Game Background (Bank 73...82)              ;
;----------------------------------------------------------;
; The screen size is 320x256 (81920 bytes, 80KiB) -> 10 8KB banks

;----------------------------------------------------------;
;              16KiB Tilemap (Bank 83, 84)                 ;
;----------------------------------------------------------;

;----------------------------------------------------------;
;               Empty image (Bank 86)                      ; TODO -> 85
;----------------------------------------------------------;

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE