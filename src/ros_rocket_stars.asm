/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                     Rocket Stars                         ;
;----------------------------------------------------------;
    MODULE ros
    ; TO USE THIS MODULE: CALL dbs.SetupRocketBank

; Moves the tilemap with platforms, then animates the stars.

; Tile stars
TI_ROWS_D96            = ti.TI_VTILES_D32*3    ; 128 rows (40*32), tile starts takes 4 horizontal screens.
    ASSERT TI_ROWS_D96 =  96

; 320/8*2 = 80 bytes pro row -> single tile has 8x8 pixels. 320/8 = 40 tiles pro line, each tile takes 2 bytes.
_TI_H_BYTES_D80       = 320/8 * 2

; In-game tilemap has 40x32 tiles, and stars have 40*64, therefore, there are two different counters.
tilesRow                DB ti.TI_VTILES_D32     ; Current tiles row, runs from TI_VTILES_D32-1 to 0.
sourceTilesRow          DB TI_ROWS_D96         ; Current tiles row in source file (RAM), runs from from TI_ROWS_D96 to 0.

tileOffsetY             DB _SC_RESY1_D255       ; Runs from 255 to 0, see also "NEXTREG _DC_REG_TI_Y_H31, _SC_RESY1_D255" in sc.SetupScreen.
tileOffsetX             DW 0
tilePixelCnt            DB ti._TI_PIXELS_D8      ; Runs from 0 to 7 (ti._TI_PIXELS_D8-1).

; There are 32 tile lines. We insert the black tile line starting from 32 to 1. However, the first black line is inserted when the rocket 
; takes off, so this counter runs not from 32 but from 31.
blackTilesRow           DB ti.TI_VTILES_D32-1 
TI_BLACK_UNTIL_D250    = 250                    ; Fill the bottom tile line with black tiles until the rocket reaches the given height.

PAUSE_SCROLL_STARTS     = 2
pauseScrollStars        DB 0
slowDownScrollY         DB 0

;----------------------------------------------------------;
;                    ResetRocketStars                      ;
;----------------------------------------------------------;
ResetRocketStars

    LD A, ti.TI_VTILES_D32
    LD (tilesRow), A

    DEC A
    LD (blackTilesRow), A

    LD A, TI_ROWS_D96
    LD (sourceTilesRow), A

    LD A, _SC_RESY1_D255
    LD (tileOffsetY), A

    XOR A
    LD (tilePixelCnt), A

    LD HL, 0
    LD (tileOffsetX), HL

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    PauseScrollStars                      ;
;----------------------------------------------------------;
PauseScrollStars

    LD A, PAUSE_SCROLL_STARTS
    LD (pauseScrollStars), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 ScrollStarsOnFlyRocket                   ;
;----------------------------------------------------------;
ScrollStarsOnFlyRocket

    ; Start animation when the rocket reaches given phase.
    LD A, (ro.rocketFlyPhase)
    CP ro.PHASE_2
    RET C                                       ; Do not animate when phase < 2

    ; ##########################################
    CALL _UpdateTileXOffset

    ; ##########################################
    ; Pause ?
    LD A, (pauseScrollStars)
    CP 0
    JR Z, .afterPause
    DEC A
    LD (pauseScrollStars), A

    ; Pase scrolling, acctually slow it down.
    LD A, (mld.counter000FliFLop)
    CP _GC_FLIP_ON_D1
    RET NZ

.afterPause
    ; ##########################################
    ; Increment the tile counter to determine whether we should load the next tile row.
    LD A, (tilePixelCnt)
    INC A
    LD (tilePixelCnt), A

    CP ti._TI_PIXELS_D8
    JR NZ, .afterNextTile
    
    ; Reset the counter and fetch the next tile row.
    XOR A
    LD (tilePixelCnt), A

    ; ##########################################
    ; Print black tile line until phase 4 is reached, or all black tiles have been printed.
    LD A, (ro.rocketFlyPhase)
    CP ro.PHASE_4
    JR NC, .afterClearTileLine                  ; Jump if phase >= 4

    ; We are not yet in phase 4, but all tiles are already transparent. There is nothing to do, wait for phase 4.
    LD A, (blackTilesRow)
    CP 0
    RET Z

    DEC A
    LD (blackTilesRow), A

    CALL ti.ClearTileLine
    JR .afterNextTile
.afterClearTileLine

    CALL _NextStarsTileRow
.afterNextTile

    ; ##########################################
    ; Move tiles by 1 pixel.

    LD A, (tileOffsetY)
    DEC A
    LD (tileOffsetY), A
    NEXTREG _DC_REG_TI_Y_H31, A                 ; Y tile offset.

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      DecTileOffsetX                      ;
;----------------------------------------------------------;
DecTileOffsetX

    LD BC, (tileOffsetX)

    ; If X == 0 then set it to 319. X == 0 when B and C are 0
    LD A, B
    CP 0
    JR NZ, .afterResetX
    LD A, C
    CP 0
    JR NZ, .afterResetX
    LD BC, _TI_OFFSET_X_MAX
    JR .afterDec
.afterResetX
    DEC BC
.afterDec
    LD (tileOffsetX), BC

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      IncTileOffsetX                      ;
;----------------------------------------------------------;
IncTileOffsetX

    LD BC, (tileOffsetX)
    INC BC
    ; If X >= 319 then set it to 0. X is 9-bit value.
    ; 319 = 256 + 63 = %0000'0001 + %0011'1111 -> MSB: 1, LSB: 63.
    LD A, B                                     ; Load MSB from X into A.
    CP 1                                        ; 9-th bit set means X > 256.
    JR NZ, .lessThanMaxX
    LD A, C                                     ; Load MSB from X into A.
    CP 63                                       ; MSB > 63
    JR C, .lessThanMaxX
    LD BC, 0                                    ; 319 -> set to 0.
.lessThanMaxX
    LD (tileOffsetX), BC                        ; Update new X position.

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                   _UpdateTileXOffset                     ;
;----------------------------------------------------------;
_UpdateTileXOffset

    LD HL, (tileOffsetX)
    LD A, L
    NEXTREG _DC_REG_TI_X_LSB_H30, A

    LD A, H
    NEXTREG _DC_REG_TI_X_MSB_H2F, A

    RET                                         ; ## END of the function ##
    
;----------------------------------------------------------;
;                 _NextStarsTileRow                        ;
;----------------------------------------------------------;
; This method is called when the in-game tilemap has moved by 8 pixels. It reads the next row from the tilemap and places it on the bottom row 
; on the screen. But as the tilemap moved by 8 pixels, so did the bottom row. Each time the method is called, we have to calculate the new 
; position of the bottom row (#tilesRow). We also need to read the next row from the starts tilemap (#sourceTilesRow).
_NextStarsTileRow

    CALL dbs.Setup8KTilemapBank

    ; ##########################################
    ; Decrement counters
    LD A, (tilesRow)
    DEC A
    LD (tilesRow), A

    LD A, (sourceTilesRow)
    DEC A
    LD (sourceTilesRow), A                          ; A is used below.

    ; ##########################################
    ; Prepare tile copy fom temp RAM to screen RAM

    ; Load the memory address of the starts row to be copied into HL. HL = TI_RAM_ADDR + sourceTilesRow * _TI_H_BYTES_D80.
    LD D, A
    LD E, _TI_H_BYTES_D80
    MUL D, E                                    ; DE contains byte offset to current row.
    LD HL, _RAM_SLOT7_STA_HE000
    ADD HL, DE                                  ; Move RAM pointer to current row.

    ; Load the memory address of in-game tiles into DE. This row will be replaced with stars.
    ; DE = ti.TI_MAP_RAM_H5B00 + tilesRow * _TI_H_BYTES_D80.
    LD A, (tilesRow)
    LD D, A
    LD E, _TI_H_BYTES_D80
    MUL D, E                                    ; DE contains #tilesRow * _TI_H_BYTES_D80.
    PUSH HL
    LD HL, ti.TI_MAP_RAM_H5B00                  ; HL contains memory offset to tiles.
    ADD HL, DE
    LD DE, HL
    POP HL

    LD BC, _TI_H_BYTES_D80                    ; Number of bytes to copy, it's one row.
    LDIR 

    ; ##########################################
    ; Reset stars counter ?
    LD A, (sourceTilesRow)
    CP A, 0
    JR NZ, .afterResetStarsRow                  ; Jump if #starsLine > 0.

    ; Reset stars counter
    LD A, TI_ROWS_D96
    LD (sourceTilesRow), A
.afterResetStarsRow

    ; ##########################################
    ; Reset tiles counter?
    LD A, (tilesRow)
    CP A, 0
    JR NZ, .afterResetTilesRow                  ; Jump if #tilesRow > 0.

    ; Reset tiles counter
    LD A, ti.TI_VTILES_D32
    LD (tilesRow), A
.afterResetTilesRow

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE