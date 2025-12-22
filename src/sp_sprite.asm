/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                     Common Sprite API                    ;
;----------------------------------------------------------;
    MODULE sp

SPR_BYT_D16384          = 16384
SP_ADDR_HC000           = _RAM_SLOT6_STA_HC000 ; RAM start address for sprites.

;----------------------------------------------------------;
;                   Reserved Sprite IDs                    ;
;----------------------------------------------------------;
; Jetman:               00-09
; Jetman's Weapon:      10-19
; Single Enemy:         20-59
; Enemy Formation:      60-69
; Rocket:               80-89
; Pickups:              90
; Jetman's Weapon:      91-95
; Fuel thief:           96-97
; Following Enemy:      98-108

;----------------------------------------------------------;
;                      LoadSpritesFPGA                     ;
;----------------------------------------------------------;
; Loads sprites from a file into hardware using DMA.
LoadSpritesFPGA

    CALL dbs.SetupSpritesBank

    LD HL, SP_ADDR_HC000             ; RAM address containing sprite binary data.
    LD BC, SPR_BYT_D16384               ; Copy 63 sprites, each 16x16 pixels.
    
    ; ##########################################
    ; Store dynamic values into DMA program
    LD (spSpriteDMAPortA), HL                   ; Copy sprite sheet address from HL.
    LD (spSpriteDMADataLength), BC              ; Copy sprite file length into WR0.

    ; Execute DMA program
    LD HL, spSpriteDMAProgram                   ; Setup source for OTIR.
    LD B, spSpriteDMAProgramLength              ; Setup length for OTIR.
    LD C, _DMA_PORT_H6B                         ; Setup DMA port.
    OTIR                                        ; Upload DMA program and execute.

; More Info: https://wiki.specnext.dev/DMA
spSpriteDMAProgram
    DB %1'00000'11                              ; WR6: Disable DMA (the last command will re-enable it).

    ; WR0 - Direction, Operation, Port A Configuration:
    ;  - D2 = 1 -> Port A is a source, port B destination.
    ;  - D4,D3 = 11 -> Port A address is a byte that directly follows DW0 byte.
    ;  - D6,D5 = 11 -> The number of bytes to be copied by DMA is 16-bit and directly follows the Port A address.
    ; DW0 consists of 4 bytes: DW0 -> A address -> data length (LSB) -> data length (MSB).
    DB %0'11111'01

spSpriteDMAPortA
    DW 0                                        ; WR0 parameter pointing to RAM containing sprite data.

spSpriteDMADataLength
    DW 0                                        ; WR0 parameter defining the amount of bytes for sprite data.

    ; WR1 - port A configuration:
    ;   - D3 = 0 -> Port A is memory.
    ;   - D5,D4 = 01 -> Port A address increments.
    DB %0'0010'100

    ; WR2 - port B configuration:
    ;   - D3 = 1 -> Port B is IO (FPGA Sprite Hardware).
    ;   - D5 = 0 -> Port B address is fixed.
    DB %0'0101'000                              ; WR2 - B fixed, B=I/O.

    ; WR4 - Port B, Timing, Interrupt Control.
    DB %1'01011'01                              ; WR4 - continuous mode, append port B address.
    DW $005B                                    ; 16-bit port B starting address.

    ; WR5 - ready and stop configuration:
    ;   - D4 = 0 -> CE only (the only option anyway).
    ;   - D5 = 0 -> Stop operation on end of block.
    DB %1'00000'10                          

    ; WR6 - command register:
    ;   - D6,D5,D4,D3,D2 = 10011 -> LOAD command, to start copy from A to B.
    DB %1'10011'11
    DB %1'00001'11                              ; Again WR6, now enable DMA and copy!

spSpriteDMAProgramLength = $ - spSpriteDMAProgram

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      HideSprite                          ;
;----------------------------------------------------------;
HideSprite

    LD A, _SPR_ATTR3_HIDE                     ; Hide sprite on display.
    NEXTREG _SPR_REG_ATR3_H38, A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  SetIdAndHideSprite                      ;
;----------------------------------------------------------;
SetIdAndHideSprite
; Input:
;  - A: Sprite ID.

    NEXTREG _SPR_REG_NR_H34, A                  ; Set the ID of the sprite for the following commands

    CALL HideSprite

    RET                                         ; ## END of the function ##
;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE