
/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                Persistant Game Storage                   ;
;----------------------------------------------------------;
    module so
   ; TO USE THIS MODULE: CALL dbs.SetupStorageBank

unlockedLevel           DB 07,10,06             ; Levels: easy, normal, hard. Values: 1-10

; User can enter 10 character, but we display 13: [3xSPACE][10 characters for user name]
highScore                                       ; This score does not show on screen, it's only there for the sorting ;)

; Easy
    DW $FFFF
    DW $FFFF
    DB "E  FREDUS    "
   
    DW 00000
    DW 09000
    DB "E  MACIEJ    "

    DW 00000
    DW 08000
    DB "E  ARTUR     "

    DW 00000
    DW 07000
    DB "E  MARCIN    "

    DW 00000
    DW 06000
    DB "E  MACIEJ    "

    DW 00000
    DW 05000
    DB "E  JUREK     "

    DW 00000
    DW 04000
    DB "E  FRANEK    "

    DW 00000
    DW 03000
    DB "E  ZUZA      "

    DW 00000
    DW 02000
    DB "E  KAROL     "

    DW 00000
    DW 01000
    DB "E  FRED      "

; Normal
    DW $FFFF
    DW $FFFF
    DB "N  FREDUS    "
   
    DW 00000
    DW 09000
    DB "N  MACIEJ    "

    DW 00000
    DW 08000
    DB "N  ARTUR     "

    DW 00000
    DW 07000
    DB "N  MARCIN    "

    DW 00000
    DW 06000
    DB "N  MACIEJ    "

    DW 00000
    DW 05000
    DB "N  JUREK     "

    DW 00000
    DW 04000
    DB "N  FRANEK    "

    DW 00000
    DW 03000
    DB "N  ZUZA      "

    DW 00000
    DW 02000
    DB "N  KAROL     "

    DW 00000
    DW 01000
    DB "N  FRED      "

; Hard
    DW $FFFF
    DW $FFFF
    DB "H  FREDUS    "
   
    DW 00000
    DW 09000
    DB "H  MACIEJ    "

    DW 00000
    DW 08000
    DB "H  ARTUR     "

    DW 00000
    DW 07000
    DB "H  MARCIN    "

    DW 00000
    DW 06000
    DB "H  MACIEJ    "

    DW 00000
    DW 05000
    DB "H  JUREK     "

    DW 00000
    DW 04000
    DB "H  FRANEK    "

    DW 00000
    DW 03000
    DB "H  ZUZA      "

    DW 00000
    DW 02000
    DB "H  KAROL     "

    DW 00000
    DW 01000
    DB "H  FRED      "

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE