/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;          Screen Setup, Synchronization and Timing        ;
;----------------------------------------------------------;
    MODULE sc

SYNC_TOP_D0             = 0
SYNC_BOTTOM_D192        = 192                   ; Sync to scanline 192, scanline on the frame (256 > Y > 192) might be skipped on 60Hz.
TI_CLIP_TOP_D8          = _TI_PIXELS_D8
TI_CLIP_BOTTOM_D247     = _SC_RESY1_D255 - _TI_PIXELS_D8
CLIP_TOP50_D50          = 40

;----------------------------------------------------------;
;----------------------------------------------------------;
;                        MACROS                            ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                  #_WaitForScanline                       ;
;----------------------------------------------------------;
    MACRO _WaitForScanline line

; Read NextReg $1F - LSB of current raster line.
    LD BC, _GL_REG_SELECT_H243B                 ; TBBlue Register Select.
    LD A, _GL_REG_VL_H1F                        ; Port to access - Active Video Line LSB Register.
    OUT (C), A                                  ; Select NextReg $1F.
    INC B                                       ; TBBlue Register Access.

; Wait for scanline.
.waitForScanline
    IN A, (C)                                   ; Read the raster line LSB into A.
    CP line
    JR NZ, .waitForScanline

    ENDM

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PUBLIC FUNCTIONS                       ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                      #SetupScreen                        ;
;----------------------------------------------------------;
SetupScreen

    ; Sprite and Layers system. Bits:
    ;  - 7: 0 - low RES mode off.
    ;  - 6: 1 - sprite on top.
    ;  - 5: 1 - sprite clipping disabled.
    ;  - 4-2: 110 - S(U+L) ULA and Layer 2 combined (tiles + background).
    ;  - 1: 1 - sprite over border.
    ;  - 0: 1 - sprites visible.
    NEXTREG _SPR_REG_SETUP_H15, %0'1'1'110'1'1

    NEXTREG _DC_REG_CONTROL1_H69, %1'0'0'00000  ; Enable Layer 2
    
    NEXTREG _GL_REG_TRANP_COL_H14, _COL_BLACK_D0 ; Global transparency.

    NEXTREG _DC_REG_LA2_H70, %00'01'0000        ; Layer 2 320x256x8bpp, palette offset at 0.

    LD  A, _COL_BLACK_D0                        ; Set border color.
    OUT (_BORDER_IO_HFE), A

    CALL ResetClippings

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      SetClipTop50                        ;
;----------------------------------------------------------;
; 8px clip from top and 8px clip from the bottom.
SetClipTop50

    ; Reset clip index.
    NEXTREG _GL_REG_CLIP_CTR_H1C, _GL_REG_CLIP_VAL

    ; Clip Window layer 2
    NEXTREG _DC_REG_L2_CLIP_H18, _CLIP_FULL_X1_D0
    NEXTREG _DC_REG_L2_CLIP_H18, _CLIP_FULL_X2_D159
    NEXTREG _DC_REG_L2_CLIP_H18, CLIP_TOP50_D50
    NEXTREG _DC_REG_L2_CLIP_H18, _CLIP_FULL_FULLY2_D255

    ; Clip window sprites.
    NEXTREG _GL_REG_CLIP_SPR_H19, _CLIP_FULL_X1_D0
    NEXTREG _GL_REG_CLIP_SPR_H19, _CLIP_FULL_X2_D159
    NEXTREG _GL_REG_CLIP_SPR_H19, CLIP_TOP50_D50
    NEXTREG _GL_REG_CLIP_SPR_H19, _CLIP_FULL_FULLY2_D255

    ; Clip window tilemap.
    NEXTREG _GL_REG_CLIP_TI_H1, _CLIP_FULL_X1_D0
    NEXTREG _GL_REG_CLIP_TI_H1, _CLIP_FULL_X2_D159
    NEXTREG _GL_REG_CLIP_TI_H1, CLIP_TOP50_D50
    NEXTREG _GL_REG_CLIP_TI_H1, _CLIP_FULL_FULLY2_D255

    RET                                         ; ## END of the function ##
    
;----------------------------------------------------------;
;                  SetClipTilesHorizontal                  ;
;----------------------------------------------------------;
; 8px clip from top and 8px clip from the bottom.
SetClipTilesHorizontal

    NEXTREG _GL_REG_CLIP_TI_H1, _CLIP_FULL_X1_D0
    NEXTREG _GL_REG_CLIP_TI_H1, _CLIP_FULL_X2_D159
    NEXTREG _GL_REG_CLIP_TI_H1, TI_CLIP_TOP_D8
    NEXTREG _GL_REG_CLIP_TI_H1, TI_CLIP_BOTTOM_D247

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    #ResetClippings                       ;
;----------------------------------------------------------;
ResetClippings

    ; Reset clip index.
    NEXTREG _GL_REG_CLIP_CTR_H1C, _GL_REG_CLIP_VAL

    ; Clip Window layer 2
    NEXTREG _DC_REG_L2_CLIP_H18, _CLIP_FULL_X1_D0
    NEXTREG _DC_REG_L2_CLIP_H18, _CLIP_FULL_X2_D159
    NEXTREG _DC_REG_L2_CLIP_H18, _CLIP_FULL_Y1_D0
    NEXTREG _DC_REG_L2_CLIP_H18, _CLIP_FULL_FULLY2_D255

    ; Clip window sprites.
    NEXTREG _GL_REG_CLIP_SPR_H19, _CLIP_FULL_X1_D0
    NEXTREG _GL_REG_CLIP_SPR_H19, _CLIP_FULL_X2_D159
    NEXTREG _GL_REG_CLIP_SPR_H19, _CLIP_FULL_Y1_D0
    NEXTREG _GL_REG_CLIP_SPR_H19, _CLIP_FULL_FULLY2_D255

    ; Clip window tilemap.
    NEXTREG _GL_REG_CLIP_TI_H1, _CLIP_FULL_X1_D0
    NEXTREG _GL_REG_CLIP_TI_H1, _CLIP_FULL_X2_D159
    NEXTREG _GL_REG_CLIP_TI_H1, _CLIP_FULL_Y1_D0
    NEXTREG _GL_REG_CLIP_TI_H1, _CLIP_FULL_FULLY2_D255

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 #WaitForTopScanline                      ;
;----------------------------------------------------------;
; Pauses executing for single frame, 1/60 or 1/50 of a second.
; Based on: https://github.com/robgmoran/DougieDoSource
WaitForTopScanline

   ; _WaitForScanline SYNC_TOP_D0

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 #WaitForBottomScanline                   ;
;----------------------------------------------------------;
; Pauses executing for single frame, 1/60 or 1/50 of a second.
; Based on: https://github.com/robgmoran/DougieDoSource
WaitForBottomScanline

    _WaitForScanline SYNC_BOTTOM_D192

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE