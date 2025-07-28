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
gameIntroPaletteAdr
    INCBIN  "assets/01/intro.nxp"

gameIntroPaletteBytes = $ - gameIntroPaletteAdr
    ASSERT gameIntroPaletteBytes <= btd.PAL_BYTES_D512

 ; ############################################
menuMainBgPaletteAdr
    INCBIN  "assets/ma/bg.nxp"

menuMainBgPaletteBytes = $ - menuMainBgPaletteAdr
    ASSERT menuMainBgPaletteBytes <= btd.PAL_BYTES_D512

 ; #############################################
menuGameplayBgPaletteAdr
    INCBIN  "assets/mg/bg.nxp"

menuGameplayBgPaletteBytes = $ - menuGameplayBgPaletteAdr
    ASSERT menuGameplayBgPaletteBytes <= btd.PAL_BYTES_D512

 ; #############################################
menuKeysBgPaletteAdr
    INCBIN  "assets/mk/bg.nxp"

menuKeysBgPaletteBytes = $ - menuKeysBgPaletteAdr
    ASSERT menuKeysBgPaletteBytes <= btd.PAL_BYTES_D512

 ; #############################################
menuEasyBgPaletteAdr
    INCBIN  "assets/ma/easy.nxp"

menuEasyBgPaletteBytes = $ - menuEasyBgPaletteAdr
    ASSERT menuEasyBgPaletteBytes <= btd.PAL_BYTES_D512

 ; #############################################
menuHardBgPaletteAdr
    INCBIN  "assets/ma/hard.nxp"

menuHardBgPaletteBytes = $ - menuHardBgPaletteAdr
    ASSERT menuHardBgPaletteBytes <= btd.PAL_BYTES_D512

 ; #############################################
menuScoreBgPaletteAdr
    INCBIN  "assets/ms/bg.nxp"

menuScoreBgPaletteBytes = $ - menuScoreBgPaletteAdr
    ASSERT menuHardBgPaletteBytes <= btd.PAL_BYTES_D512

 ; #############################################
gameOverBgPaletteAdr
    INCBIN  "assets/go/bg.nxp"

gameOverBgPaletteBytes = $ - gameOverBgPaletteAdr
    ASSERT menuHardBgPaletteBytes <= btd.PAL_BYTES_D512

 ; #############################################
    ASSERT $$ == dbs.PAL2_BANK_S6_D31


;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE