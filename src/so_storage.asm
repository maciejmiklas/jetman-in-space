
/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                Persistant Game Storage                   ;
;----------------------------------------------------------;
    module so
   ; TO USE THIS MODULE: CALL dbs.SetupStorageBank

unlockedLevel           DB 7,8,10             ; There are three difficulty levels, unlocked independently.

; User can enter 10 character, but we display 13: [3xSPACE][10 characters for user name]
highScore                                       ; This score does not show on screen, it's only there for the sorting ;)

; Easy
    DW $FFFF
    DW $FFFF
    DB "   FREDUS    "
   
    DW 00000
    DW 09000
    DB "   MACIEJ    "

    DW 00000
    DW 08000
    DB "   ARTUR     "

    DW 00000
    DW 07000
    DB "   MARCIN    "

    DW 00000
    DW 06000
    DB "   MACIEJ    "

    DW 00000
    DW 05000
    DB "   JUREK     "

    DW 00000
    DW 04000
    DB "   FRANEK    "

    DW 00000
    DW 03000
    DB "   ZUZA      "

    DW 00000
    DW 02000
    DB "   KAROL     "

    DW 00000
    DW 01000
    DB "   FRED      "

; Normal
    DW $FFFF
    DW $FFFF
    DB "   FREDUS    "
   
    DW 00000
    DW 09000
    DB "   MACIEJ    "

    DW 00000
    DW 08000
    DB "   ARTUR     "

    DW 00000
    DW 07000
    DB "   MARCIN    "

    DW 00000
    DW 06000
    DB "   MACIEJ    "

    DW 00000
    DW 05000
    DB "   JUREK     "

    DW 00000
    DW 04000
    DB "   FRANEK    "

    DW 00000
    DW 03000
    DB "   ZUZA      "

    DW 00000
    DW 02000
    DB "   KAROL     "

    DW 00000
    DW 01000
    DB "   FRED      "

; Hard
    DW $FFFF
    DW $FFFF
    DB "   FREDUS    "
   
    DW 00000
    DW 09000
    DB "   MACIEJ    "

    DW 00000
    DW 08000
    DB "   ARTUR     "

    DW 00000
    DW 07000
    DB "   MARCIN    "

    DW 00000
    DW 06000
    DB "   MACIEJ    "

    DW 00000
    DW 05000
    DB "   JUREK     "

    DW 00000
    DW 04000
    DB "   FRANEK    "

    DW 00000
    DW 03000
    DB "   ZUZA      "

    DW 00000
    DW 02000
    DB "   KAROL     "

    DW 00000
    DW 01000
    DB "   FRED      "

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE