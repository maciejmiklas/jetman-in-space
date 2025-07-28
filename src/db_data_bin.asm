;----------------------------------------------------------;
;                    Binary Data Loader                    ;
;----------------------------------------------------------;
    module db

;----------------------------------------------------------;
;                Layer 2 Palettes (Bank 31)                ;
;----------------------------------------------------------;
    MMU _RAM_SLOT6, dbs.PAL2_BANK_S6_D31
    ORG _RAM_SLOT6_STA_HC000

 ; #############################################
bgrL1PaletteAdr
    INCBIN  "assets/01/bg.nxp"

bgrL1PaletteBytes = $ - bgrL1PaletteAdr
    ASSERT bgrL1PaletteBytes <= btd.PAL2_BYTES_D512

 ; #############################################
bgrL2PaletteAdr
    INCBIN  "assets/02/bg.nxp"

bgrL2PaletteBytes = $ - bgrL2PaletteAdr
    ASSERT bgrL2PaletteBytes <= btd.PAL2_BYTES_D512

 ; #############################################
bgrL3PaletteAdr
    INCBIN  "assets/03/bg.nxp"

bgrL3PaletteBytes = $ - bgrL3PaletteAdr
    ASSERT bgrL3PaletteBytes <= btd.PAL2_BYTES_D512

 ; #############################################
bgrL4PaletteAdr
    INCBIN  "assets/04/bg.nxp"

bgrL4PaletteBytes = $ - bgrL4PaletteAdr
    ASSERT bgrL4PaletteBytes <= btd.PAL2_BYTES_D512

 ; #############################################
bgrL5PaletteAdr
    INCBIN  "assets/05/bg.nxp"

bgrL5PaletteBytes = $ - bgrL5PaletteAdr
    ASSERT bgrL5PaletteBytes <= btd.PAL2_BYTES_D512

 ; #############################################
bgrL6PaletteAdr
    INCBIN  "assets/06/bg.nxp"

bgrL6PaletteBytes = $ - bgrL6PaletteAdr
    ASSERT bgrL6PaletteBytes <= btd.PAL2_BYTES_D512
    
 ; #############################################
bgrL7PaletteAdr
    INCBIN  "assets/07/bg.nxp"

bgrL7PaletteBytes = $ - bgrL7PaletteAdr
    ASSERT bgrL7PaletteBytes <= btd.PAL2_BYTES_D512

 ; #############################################
bgrL8PaletteAdr
    INCBIN  "assets/08/bg.nxp"

bgrL8PaletteBytes = $ - bgrL8PaletteAdr
    ASSERT bgrL8PaletteBytes <= btd.PAL2_BYTES_D512

 ; #############################################
bgrL9PaletteAdr
    INCBIN  "assets/09/bg.nxp"

bgrL9PaletteBytes = $ - bgrL9PaletteAdr
    ASSERT bgrL9PaletteBytes <= btd.PAL2_BYTES_D512

 ; #############################################
bgrL10PaletteAdr
    INCBIN  "assets/10/bg.nxp"

bgrL10PaletteBytes = $ - bgrL10PaletteAdr
    ASSERT bgrL10PaletteBytes <= btd.PAL2_BYTES_D512

 ; #############################################
gameIntroPaletteAdr
    INCBIN  "assets/01/intro.nxp"

gameIntroPaletteBytes = $ - gameIntroPaletteAdr
    ASSERT gameIntroPaletteBytes <= btd.PAL2_BYTES_D512

 ; ############################################
menuMainBgPaletteAdr
    INCBIN  "assets/ma/bg.nxp"

menuMainBgPaletteBytes = $ - menuMainBgPaletteAdr
    ASSERT menuMainBgPaletteBytes <= btd.PAL2_BYTES_D512

 ; #############################################
menuGameplayBgPaletteAdr
    INCBIN  "assets/mg/bg.nxp"

menuGameplayBgPaletteBytes = $ - menuGameplayBgPaletteAdr
    ASSERT menuGameplayBgPaletteBytes <= btd.PAL2_BYTES_D512

 ; #############################################
menuKeysBgPaletteAdr
    INCBIN  "assets/mk/bg.nxp"

menuKeysBgPaletteBytes = $ - menuKeysBgPaletteAdr
    ASSERT menuKeysBgPaletteBytes <= btd.PAL2_BYTES_D512

 ; #############################################
menuEasyBgPaletteAdr
    INCBIN  "assets/ma/easy.nxp"

menuEasyBgPaletteBytes = $ - menuEasyBgPaletteAdr
    ASSERT menuEasyBgPaletteBytes <= btd.PAL2_BYTES_D512

 ; #############################################
menuHardBgPaletteAdr
    INCBIN  "assets/ma/hard.nxp"

menuHardBgPaletteBytes = $ - menuHardBgPaletteAdr
    ASSERT menuHardBgPaletteBytes <= btd.PAL2_BYTES_D512

 ; #############################################
menuScoreBgPaletteAdr
    INCBIN  "assets/ms/bg.nxp"

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
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE