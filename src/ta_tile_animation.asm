;----------------------------------------------------------;
;                     Tile Animation                       ;
;----------------------------------------------------------;
    ; ### TO USE THIS MODULE: CALL dbs.SetupTileAnimationBank ###

    MODULE ta

currentRowIdx           DB 0
maxRows                 DB 0
rowsPointer             DW 0                    ; Pointer to a list containing pointers to concrete rows

; Tilemap animation can animate any tile on the screen by replacing it with another one. Each single frame is defined as #TF - it contains
; X/Y coordinates of the tile that will be replaced and the ID. Animation data is stored as a two-dimensional array: Each row contains #TF
; elements that will be replaced in a single frame. Animation ticks with defined speed, each tick takes the next row and applies all tiles
; from it at once. Animation ticks fast, so it is possible to achieve different animation speeds by splitting the animation of a particular
; tile between different rows.
;----------------------------------------------------------;
;                  DisableTileAnimation                    ;
;----------------------------------------------------------;
DisableTileAnimation

    XOR A
    LD (maxRows), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                NextTileAnimationFrame                    ;
;----------------------------------------------------------;
NextTileAnimationFrame

    ; Increment #currentRowIdx
    LD A, (maxRows)
    CP 0
    RET Z
    LD B, A
    LD A, (currentRowIdx)
    INC A
    CP B
    JR NZ, .afterIncrementRow
    XOR A
.afterIncrementRow
    LD (currentRowIdx), A

    ; ##########################################
    ; A contains the current row index, load pointer to the row into DE.
    LD HL, (rowsPointer)
    LD D, A
    LD E, 2
    MUL D, E
    ADD HL, DE                                  ; HL points to value in #rowsPointer containing pointer to current row
    LD DE, (HL)                                 ; DE points to current animation row

    ; ##########################################
    ; Load number of #TF elements into B, this is the first byte pointed by DE
    LD A, (DE)
    LD B, A
    INC DE                                      ; Now DE points to first #TF
    LD IX, DE
.tfLoop
    LD DE, (IX + TF.POS)

    ; HL will point to the memory location containing the tile that will be replaced.
    LD HL, ti.TI_MAP_RAM_H5B00
    ADD HL, DE

    ; Set tile ID
    LD A, (IX + TF.TID)
    LD (HL), A

    ; Set palette
    INC HL
    LD A, (IX + TF.PAL)
    LD (HL), A

    ; Next #TF
    LD HL, IX
    ADD HL, TF
    LD IX, HL
    DJNZ .tfLoop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   SetupTileAnimation                     ;
;----------------------------------------------------------;
; Input:
;  - A:  max rows
;  - HL: pointer to a list containing pointers to concrete rows
SetupTileAnimation

    LD (maxRows), A
    LD (rowsPointer), HL

    XOR A
    LD (currentRowIdx), A

    RET                                         ; ## END of the function ##
;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE