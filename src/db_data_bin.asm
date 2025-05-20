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
    ASSERT $$ == dbs.PAL2_BANK_S6_D31

;----------------------------------------------------------;
;          Layer 2 Brightness Palettes (Bank 32)           ;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                Game Sprites (Bank 33...34)               ;
;----------------------------------------------------------;
; Load sprites (16KB) into 2 banks mapping it to slot 6,7.

;----------------------------------------------------------;
;              Game Background (Bank 35...44)              ;
;----------------------------------------------------------;
; The screen size is 320x256 (81920 bytes, 80KiB) -> 10 8KB banks.

;----------------------------------------------------------;
;              16KiB Tilemap (Bank 45, 46)                 ;
;----------------------------------------------------------;

;----------------------------------------------------------;
;               AY FX Sound (Bank 47)                      ;
;----------------------------------------------------------;

;----------------------------------------------------------;
;               Empty image (Bank 48)                      ;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE