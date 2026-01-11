/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;          Stars for Layer 2 bitmap at 320x256             ;
;----------------------------------------------------------;
    module st

; The starfield is grouped into columns (#SC). When Jetman moves, the whole starfield and, respectively, all columns move in the
; opposite direction.
; The image on Layer 2 splits over 10 banks, each containing 32 columns, 256 pixels long. 
; Each star column (#SC) is assigned to a concrete bank and contains precisely one column with starts that will be injected into the picture.
; This column can be 256 pixels long and contains #SC.SIZE stars. Each star's vertical (Y) position is given as an offset from the top of
; the screen.
; #SC.X_OFFSET defines the placement of a star column within the memory bank -  this is the image column within this particular bank where
; stars will be injected.
; Because starfield moves together with Jetman, a new position for each star in this row is calculated by adding an offset value to each
; start position with every move.
; Each column rolls from the bottom to the top when its position byte overflows. Each column also has a maximal horizontal position 
; (#SC.Y_MAX), after which the starts will not be painted to avoid overlapping with the background image.

ST_PAL_FIRST_D1         = 1                     ; Offset for the first color used to blink star.

ST_PAL_TRANSP_D0        = 0                     ; Index of transparent color.

ST_L1_SIZE_D27          = 27                    ; Number start columns on layer 1.
ST_L2_SIZE_D16          = 16                    ; Number start columns on layer 2.

SC_BLINK_OFF            = 0

ST_HIDDEN               = 0
ST_C_HIDDEN             = ST_HIDDEN+1           ; Value for RET C.
ST_SHOW                 = 1
ST_MOVE_UP              = 3
ST_MOVE_DOWN            = 4

starsState              DB ST_SHOW

ST_L1_MOVE_DEL_D8       = 8                     ; Stars move delay for layer 1.
ST_L2_MOVE_DEL_D2       = 3                     ; Stars move delay for layer 2.

starsMoveL1Delay        DB ST_L1_MOVE_DEL_D8    ; Delay counter for stars on layer 1 (there are 2 layers of stars).
starsMoveL2Delay        DB ST_L2_MOVE_DEL_D2    ; Delay counter for stars on layer 2.

randColor               DB 0                    ; Rand value from the previous call.

; Currently rendered palette
starsPalAddr            DW 0
starsPalSize            DB 0
starsPalOffset          DB 0

; Currently rendered stars
starsSCSize             DB 0                    ; Number of SC elements (star columns).
starsSCAddr             DW 0

; An array containing the maximum Y value to render the star column to avoid printing over the background image. 
; The size of this array is equal to the #starsSCSize
starsMaxY               DW 0
starsMaxYL1Addr         DW 0                    ; Address for layer 1.
starsMaxYL2Addr         DW 0                    ; Address for layer 2.

paletteNumber           DB 0                    ; Palette number, values from 0-3
PALETTE_CNT             = 4

ST_PAL_L1_SIZE_D32      = 32                    ; Number of colors for stars on layer 1 (each color takes 2 bytes).
ST_PAL_L2_SIZE_D8       = 8                     ; Number of colors for stars on layer 2 (each color takes 2 bytes).

ST_PAL_L1_BYTES_D64     = ST_PAL_L1_SIZE_D32*2
ST_PAL_L2_BYTES_D16     = ST_PAL_L2_SIZE_D8*2

starsPalL1Addr         DW 0
starsPalL2Addr         DW 0

;----------------------------------------------------------;
;----------------------------------------------------------;
;                        MACROS                            ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                     _CanShowStar                         ;
;----------------------------------------------------------;
; Input 
;  - B:  Star y-postion to be checked.
;  - IY: Points to the current max y postion for the star.
; Return:
;  - YES: Z is reset (JP Z).
;  - NO:  Z is set (JP NZ).
    MACRO _CanShowStar

    LD A, (IY)                                  ; Load into A max star y-postion

    ; A holds max star y-position and B current
    CP B
    JR C, .maxBelowCurrent                      ; Jump if the max position (A) is below the current (B).

.allowed
    _YES
    JR .end

.maxBelowCurrent

    ; Stars could be behind the building, in which case it should be hidden, but it's also possible that the star is
    ; below the building (basement?) in the picture that rolls over to the top of the screen. In this case, the star should be visible.
    LD A, (bg.bgOffset)                         ; The background image moves down, releasing more room for stars.
    LD C, A
    LD A, _SC_RESY1_D255
    SUB C

    CP B
    JR NC, .notAllowed2                         ; Jump if the max position (A) is below the current (B).
    _YES
    JR .end

.notAllowed2
    _NO

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                      _GetStarColor                       ;
;----------------------------------------------------------;
; Input:
;  - HL: Points to the source pixel from stars column.
; Return:
;  A: contains next star color.
; Modifies: A, B, C, DE
    MACRO _GetStarColor

    LD DE, HL                                   ; DE points to the star position in the column.
    INC DE                                      ; DE points to the color info.

    ; DE points to the color offset from #starsPalAddr. Now, we have to move it to the offset in the layer two palette.
    ; #btd.palColors points right after the colors registered for the image.
    LD A, (DE)
    LD B, A

    LD A, (starsPalOffset)
    LD C, A

    LD A, (btd.palColors)
    ADD B
    ADD C

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                _MoveAndRenderStarColumn                  ;
;----------------------------------------------------------;
; Input 
;  - IX: Pointer to SC.
;  - IY: Points to the current max y postion for the star.
    MACRO _MoveAndRenderStarColumn

    ; Assign image bank that will be modified to slot 6.
    LD A, (IX + SC.BANK)
    LD B, A
    LD A, dbs.BMB_ST_BANK_S7_D18                ; First image bank. See "NEXTREG _DC_REG_L2_BANK_H12, BM_16KBANK_D9".
    ADD B
    NEXTREG _MMU_REG_SLOT6_H56, A               ; Assign image bank to slot 6.

    ; ##########################################
    ; DE will point to the address of the column that will contain starts.
    ; The picture is coded horizontally, and each column contains 256 pixels. DE should point to the column given by SC.X_OFFSET ->
    ; DE = SC.X_OFFSET * 256. However, the byte max value is 255, therefore, DE = SC.X_OFFSET * 255 + SC.X_OFFSET.
    LD D, (IX + SC.X_OFFSET)
    LD E, _SC_RESY1_D255
    MUL D, E
    LD A, (IX + SC.X_OFFSET)
    ADD DE, A

    LD HL, _RAM_SLOT6_STA_HC000                 ; Beginning of the image.
    ADD DE, HL                                  ; DE points to the byte in the image representing the column where we will inject stars.

    ; ##########################################
    ; HL will point to the first pixel that is right after #SC.
    LD HL, IX
    LD A, SC
    ADD HL, A

    ; ##########################################
    ; Loop over stars and inject those into the image's column.
    LD B, (IX + SC.SIZE)                        ; Number of pixels in this column = number of iterations.
    
    ; Register values:
    ; B:  Number of stars in the row.
    ; HL: Points to the first source pixel from stars column.
    ; DE: Points to the top destination pixel (byte) in the column on the background (destination) image.
    ; IY: Points to the current max y postion for the star.
    ; In this loop, we will copy one column of the stars from the source data (HL) into the layer 2 image (DE) column.

.starsLoop
    PUSH DE, BC                                     ;  Keep DE so it always points to the top of the column in the image.

    ; ##########################################
    ; Move star up/down or just show it.
    LD A, (starsState)
    
    ; Do not move star if the command only shows it.
    CP ST_SHOW
    JR NZ, .moveStar

    ; Only show the current star without movement?
    LD A, (HL)                                  ; A contains current star y-position.
    JR .showStar

.moveStar
    ; ##########################################
    ; Move star up/down
    CP ST_MOVE_UP
    JR NZ, .afterMoveUp
    
    ; Move star up
    LD A, (HL)                                  ; A contains current star y-position.
    LD B, A                                     ; Keep the original star position before movement because we have to paint transparent pixel.
    DEC A
    LD (HL), A                                  ; Store new star y-position.
    JR .afterMoveDown

.afterMoveUp
    ; Move star down
    LD A, (HL)                                  ; A contains current star y-position.
    LD B, A                                     ; Keep the original star y-position before movement because we have to paint transparent pixel.
    INC A
    LD (HL), A                                  ; Store new star position.
.afterMoveDown

    ; ##########################################
    ; Hide star only if it's not being placed on the original image.
    ; B contains a star position before it was moved - that's the one that should be hidden.
    
    _CanShowStar
    JR NZ, .afterPaintStar                      ; Skip this star if it cannot be hidden.

    ; Hide star
    PUSH DE                                     ; Keep DE to point to the top of the column on the destination image.
    LD A, B                                     ; B contains the position of the star that needs to be hidden.
    ADD DE, A                                   ; DE contains a byte offset to a current column in the destination image, plus A will give the final star position.
    LD A, ST_PAL_TRANSP_D0
    LD (DE), A
    POP DE

.showStar
    ; ##########################################
    ; Print the moved (or not moved if #starsState == ST_SHOW) star if it's not behind something on the image.

    LD B, (HL)                                  ; A contains the position of the already moved star.
    _CanShowStar
    JR NZ, .afterPaintStar                      ; Skip this star if it cannot be painted.

    ; Paint star on new postion
    LD A, (HL)                                  ; A contains the position of the already moved star.
    ADD DE, A                                   ; DE contains a byte offset to a current column in the destination image, plus A will give the final star position.

    POP BC                                      ; Restore B, and keep it for the main loop.
    PUSH BC
    PUSH DE
    _GetStarColor                          ; Load star color
    POP DE
    LD (DE), A

.afterPaintStar

    ; ##########################################
    ; Keep looping over stars in the column.

    ; Move to the next pixel.
    INC HL                                      ; Pixel postion
    INC HL                                      ; Color info

    POP BC, DE
    
    DJNZ .starsLoop

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                     _MoveStarsL1Up                       ;
;----------------------------------------------------------;
    MACRO _MoveStarsL1Up

    ; Delay movement
    LD A, (starsMoveL1Delay)
    DEC A
    LD (starsMoveL1Delay), A
    OR A                                        ; Same as CP 0, but faster.
    JR NZ, .end                                 ; Do not move yet, wait for 0.

    ; Reset delay
    LD A, ST_L1_MOVE_DEL_D8
    LD (starsMoveL1Delay), A

    ;###########################################
    ; Render
    CALL _SetupLayer1
    CALL _MoveAndRenderStars

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                     _MoveStarsL2Up                       ;
;----------------------------------------------------------;
    MACRO _MoveStarsL2Up

    ; Delay movement
    LD A, (starsMoveL2Delay)
    DEC A
    LD (starsMoveL2Delay), A
    OR A                                        ; Same as CP 0, but faster.
    JR NZ, .end                                 ; Do not move yet, wait for 0.

    ; Reset delay
    LD A, ST_L2_MOVE_DEL_D2
    LD (starsMoveL2Delay), A

    ;###########################################
    ; Render
    CALL _SetupLayer2
    CALL _MoveAndRenderStars

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                    _MoveStarsL1Down                      ;
;----------------------------------------------------------;
    MACRO _MoveStarsL1Down

    ; Delay movement
    LD A, (starsMoveL1Delay)
    DEC A
    LD (starsMoveL1Delay), A
    OR A                                        ; Same as CP 0, but faster.
    JR NZ, .end                                 ; Do not move yet, wait for 0.

    ; Reset delay
    LD A, ST_L1_MOVE_DEL_D8
    LD (starsMoveL1Delay), A

    ;###########################################
    ; Render
    CALL _SetupLayer1
    CALL _MoveAndRenderStars

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                    _MoveStarsL2Down                      ;
;----------------------------------------------------------;
    MACRO _MoveStarsL2Down

    ; Delay movement
    LD A, (starsMoveL2Delay)
    DEC A
    LD (starsMoveL2Delay), A
    OR A                                        ; Same as CP 0, but faster.
    JR NZ, .end                                      ; Do not move yet, wait for 0.

    ; Reset delay
    LD A, ST_L2_MOVE_DEL_D2
    LD (starsMoveL2Delay), A

    ;###########################################
    ; Render
    CALL _SetupLayer2
    CALL _MoveAndRenderStars

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                   _PrepRenderStars                       ;
;----------------------------------------------------------;
    MACRO _PrepRenderStars

    ; Move stars only if enabled.
    LD A, (starsState)
    CP ST_C_HIDDEN
    RET C

    CALL dbs.SetupArrays1Bank

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PUBLIC FUNCTIONS                       ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                       SetupStars                         ;
;----------------------------------------------------------;
; Input:
;  - A: palette number, values from 0-3.
;  - DE: array containing max horizontal star position for each column (#SC) for Layer 1.
;  - HL: same as DE, but for Layer 2.
SetupStars

    LD (paletteNumber), A
    LD (starsMaxYL1Addr), DE
    LD (starsMaxYL2Addr), HL
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    LoadStarsPalette                      ;
;----------------------------------------------------------;
LoadStarsPalette

    CALL dbs.SetupArrays1Bank

    ; Palettes for L1/L2 are stored as a continuous array. The pointer to the start of this array is given by #starsPalL1/L2.
    ; A gives the palette number. To load L1: #starsPalL1+A*32.

    ; Load colors for the stars on layer 1.
    LD A, (paletteNumber)
  
    PUSH AF
    LD D, A
    LD E, ST_PAL_L1_BYTES_D64
    MUL D, E                                    ; DE contains palette offset.
    LD HL, db1.starsPalL1
    ADD HL, DE                                  ; HL points to data with palette colors.
    LD (starsPalL1Addr), HL
    LD A, ST_PAL_L1_SIZE_D32
    LD B, A
    CALL bp.WritePalette

    ; ##########################################
    ; Load colors for the stars on layer 2.
    POP AF                                      ; A contains palette number.
    LD D, A
    LD E, ST_PAL_L2_BYTES_D16
    MUL D, E                                    ; DE contains palette offset.
    LD HL, db1.starsPalL2
    ADD HL, DE                                  ; HL points to data with palette colors.
    
    LD (starsPalL2Addr), HL
    LD A, ST_PAL_L2_SIZE_D8
    LD B, A
    CALL bp.WritePalette

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        ShowStars                         ;
;----------------------------------------------------------;
ShowStars

    LD A, ST_SHOW
    LD (starsState), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        HideStars                         ;
;----------------------------------------------------------;
HideStars

    LD A, ST_HIDDEN
    LD (starsState), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       MoveStarsUp                        ;
;----------------------------------------------------------;
MoveStarsUp

    ; Move stars only if enabled.
    LD A, (starsState)
    CP ST_C_HIDDEN
    RET C

    CALL dbs.SetupArrays1Bank

    ;###########################################
    ; Update state
    LD A, ST_MOVE_UP
    LD (starsState), A

    ;###########################################
    _MoveStarsL1Up
    _MoveStarsL2Up

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      MoveStarsDown                       ;
;----------------------------------------------------------;
MoveStarsDown

    _PrepRenderStars

    ;###########################################
    ; Update state
    LD A, ST_MOVE_DOWN
    LD (starsState), A

    ;###########################################
    _MoveStarsL1Down
    _MoveStarsL2Down

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  MoveFastStarsDown                       ;
;----------------------------------------------------------;
MoveFastStarsDown

    _PrepRenderStars

    CALL _SetupLayer2
    CALL _MoveAndRenderStars

    LD A, (mld.counter000FliFLop)
    CP _GC_FLIP_ON_D1
    RET NZ

    CALL _MoveAndRenderStars

    CALL _SetupLayer1
    CALL _MoveAndRenderStars

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      BlinkStars                          ;
;----------------------------------------------------------;
BlinkStars

    _PrepRenderStars

    LD A, (starsState)
    CP ST_SHOW

    ; We would like to execute _MoveAndRenderStars only if there is no movement up/down. If previous state is ST_SHOW, it means that there
    ; is no movement. Otherwise state should be ST_MOVE_UP/ST_MOVE_DOWN (is cannot be ST_HIDDEN, see _PrepRenderStars).
    PUSH AF

    JR Z, .afterStateUpdate
    LD A, ST_SHOW
    LD (starsState), A
.afterStateUpdate

    ; Blink L1
    CALL _SetupLayer1
    CALL _NextStarsColor

    POP AF
    PUSH AF
    CALL Z, _MoveAndRenderStars                 ; Call only when #starsState == ST_SHOW

    ; Blink L2
    CALL _SetupLayer2
    CALL _NextStarsColor

    POP AF
    CALL Z, _MoveAndRenderStars                 ; Call only when #starsState == ST_SHOW

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                      _SetupLayer1                        ;
;----------------------------------------------------------;
_SetupLayer1

    ; Palette
    LD DE, (starsPalL1Addr)
    LD (starsPalAddr), DE

    LD A, ST_PAL_L1_SIZE_D32
    LD (starsPalSize), A

    ; The colors for the first layer do not have offset; they are directly after the palette for the image.
    XOR A
    LD (starsPalOffset), A

    ; ##########################################
    ; Data
    LD DE, db1.starsData1
    LD (starsSCAddr), DE

    LD A, ST_L1_SIZE_D27
    LD (starsSCSize), A

    LD DE, (starsMaxYL1Addr)
    LD (starsMaxY), DE

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      _SetupLayer2                        ;
;----------------------------------------------------------;
_SetupLayer2

    ; Palette
    LD DE, (starsPalL2Addr)
    LD (starsPalAddr), DE
    
    LD A, ST_PAL_L2_SIZE_D8
    LD (starsPalSize), A

    ; The colors for stars on layer 2 are stored after those for layer 1.
    LD A, ST_PAL_L1_SIZE_D32
    LD (starsPalOffset), A

    ; ##########################################
    ; Data
    LD DE, db1.starsData2
    LD (starsSCAddr), DE

    LD A, ST_L2_SIZE_D16
    LD (starsSCSize), A

    LD DE, (starsMaxYL2Addr)
    LD (starsMaxY), DE

    RET                                         ; ## END of the function ##


;----------------------------------------------------------;
;                     _NextStarsColor                      ;
;----------------------------------------------------------;
_NextStarsColor
 
    LD HL, (starsSCAddr)
    LD A, (starsSCSize)
    LD B, A

    ; Loop over stars data (SC elements).
.scLoop
    PUSH BC
    LD IX, HL

    ; Move HL to stars pixel data.
    LD A, SC
    ADD HL, A
    LD A, (IX + SC.SIZE)                        ; Number of stars in column.
    LD B, A

    ;###########################################
    ; Loop over alls stars in column.
.starsLoop
    INC HL                                      ; Move HL after star position to color info.

    ; ##########################################
    ; Do not change the color always, randomize it.
    LD A, (randColor)
    LD C, A
    LD A, R                                     ; Load the random number into A register.
    LD (randColor), A
    CP C
    JR C, .nextStarPixel

    ; ##########################################
    ; Change the color
    LD A, (starsPalSize)
    LD C, A
    LD A, (HL)                                  ; A contains star color.
    INC A                                       ; Next color
    LD (HL), A
    CP C                                        ; Did we reach the max color and have to reset it?
    JR NZ, .nextStarPixel

    ; Reset color
    LD A, ST_PAL_FIRST_D1
    LD (HL), A
.nextStarPixel
    INC HL                                      ; Move HL to next star postion.
    DJNZ .starsLoop

.nextColumn

    ; Move HL to the next stars column.
    POP BC
    DJNZ .scLoop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  _MoveAndRenderStars                     ;
;----------------------------------------------------------;
_MoveAndRenderStars

    LD A, (starsSCSize)
    LD B, A
    LD HL, (starsSCAddr)

    ; Loop over all stars.
    LD IY, (starsMaxY)
.columnsLoop

    LD IX, HL
    PUSH IX, HL, BC
    _MoveAndRenderStarColumn
    POP BC, HL, IX

    ; Move HL to the next stars column
    LD A, SC                                    ; Move HL after SC.
    ADD HL, A

    LD A, (IX + SC.SIZE)                        ; Move HL after pixel data of the current stars column.
    ADD HL, A                                   ; 2x because each star has color byte.
    ADD HL, A

    INC IY                                      ; Move to the next max-y.

    DEC B
    JP NZ, .columnsLoop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE