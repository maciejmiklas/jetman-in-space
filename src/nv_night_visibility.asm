/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                   Night Visibility                       ;
;----------------------------------------------------------;
    MODULE nv
   ; TO USE THIS MODULE: CALL dbs.SetupCode1Bank

VISIBILITY_LIMIT_1      = 100
VISIBILITY_LIMIT_2      = 50
VISIBILITY_LIMIT_OFF    = 0

visibilityLimit DW VISIBILITY_LIMIT_OFF

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PUBLIC FUNCTIONS                       ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                   UpdateJetVisibility                    ;
;----------------------------------------------------------;
UpdateJetVisibility


    LD A, (visibilityLimit)
    OR A                                        ; Same as CP 0, but faster.
    RET Z

    ; ##########################################
    ; Store horizontal cipping into DE.

    ; X clipping uses only half of the resolution, because we run in 320 mode.
    ; Calculate for horizontal clipping the X-start as D, and the X-end as E. First, store half of the Jetman's X position in L. 
    ; Afterwards, use L to calculate D and E, including overflows. 
    LD HL, (jpo.jetX)
    LD C, 2
    CALL ut.HLdivC                              ; L contains jpo.jetX/2

    ; Calculate X-start as D.
    LD A, (visibilityLimit)
    SRL A                                       ; Divide A by 2 because x-clipping uses only half of the resolution value.
    LD C, A

    LD A, L
    SUB C
    JR NC, .storeXD                             ; No borrow => A is fine.
    XOR A                                       ; Borrow happened => clamp to 0.
.storeXD
    LD D, A

    ; Calculate X-end as E.
    LD A, L
    ADD C

    ; X-end must be <= 159
    CP _CLIP_FULL_X2_D159
    JR C, .storeXE
    LD A, _CLIP_FULL_X2_D159
.storeXE
    LD E, A

    ; ##########################################
    ; Store vertical cipping into HL, H will contain the y-start, L the y-end.

    ; Calculate y-start as H.
    LD A, (visibilityLimit)
    LD C, A
    LD A, (jpo.jetY)
    SUB C
    JR NC, .storeYH                             ; No borrow => A is fine.
    XOR A                                       ; Borrow happened => clamp to 0.
.storeYH
    LD H, A

    ; Calculate y-end as L.
    LD A, (jpo.jetY)
    ADD C
    JR NC, .storeYL                             ; No borrow => A is fine.
    LD A, _CLIP_FULL_FULLY2_D255                ; Borrow happened => clamp to 255.
.storeYL
    LD L, A

    ; ##########################################
    ; Reset clip index.
    NEXTREG _GL_REG_CLIP_CTR_H1C, _GL_REG_CLIP_ALL

    ; Clip window sprites, tilemap and layer 2.

    LD A, D
    NEXTREG _GL_REG_CLIP_SPR_H19, A 
    NEXTREG _GL_REG_CLIP_TI_H1, A
   ; NEXTREG _DC_REG_L2_CLIP_H18, A

    LD A, E
    NEXTREG _GL_REG_CLIP_SPR_H19, A
    NEXTREG _GL_REG_CLIP_TI_H1, A
    ;NEXTREG _DC_REG_L2_CLIP_H18, A

    LD A, H
    NEXTREG _GL_REG_CLIP_SPR_H19, A
    NEXTREG _GL_REG_CLIP_TI_H1, A
    ;NEXTREG _DC_REG_L2_CLIP_H18, A

    LD A, L
    NEXTREG _GL_REG_CLIP_SPR_H19, A
    NEXTREG _GL_REG_CLIP_TI_H1, A
    ;NEXTREG _DC_REG_L2_CLIP_H18, A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    LimitJetVisibility                    ;
;----------------------------------------------------------;
; Imput:
; - A: VISIBILITY_LIMIT_XXX
LimitJetVisibility

    LD (visibilityLimit), A
    CALL UpdateJetVisibility

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  LimitJetVisibilityOff                   ;
;----------------------------------------------------------;
LimitJetVisibilityOff

    LD A, VISIBILITY_LIMIT_OFF
    LD (visibilityLimit), A

    CALL sc.ResetClippings

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE