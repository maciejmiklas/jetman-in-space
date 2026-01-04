/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                     Jetpack Overheating                  ;
;----------------------------------------------------------;
    MODULE jo 
; During the flight, the Jetpack heats up. When it overheats, the Jetman can only fly slowly. To cool down the Jetpack,
; the Jetman needs to land.

; Jetpack temperature and the temp bar in UI increase in two steps. First, when Jetman is flying, the #jetHeatCnt will increase.
; When it reaches JM_HEAT_CNT, the jetpack temperature will increase (#jetTempLevel) until it reaches MAX_TEMP. Then, it will update Jetman
; state to #JETST_OVERHEAT and slow flying down. 
; When Jetman lands, the #jetCoolCnt decreases. When it reaches JM_COOL_CNT, the jetpack temperature decreases,
; until it reaches #TEMP_NORM. At this point, the Jetman state changes to #JETST_NORMAL, and Jetman can fly at a full speed.

; Jetpack heats up/cools down during the flight
jetHeatCnt              DB 0                    ; Runs from 0 to JM_HEAT_CNT
jetCoolCnt              DB 0                    ; Runs from 0 to JM_COOL_CNT

jetTempLevel            DB 0

TEMP_MAX                = 6                     ; The heat bar in UI (H) has 5 elements, 6 means it's overheated.
TEMP_RED                = 4
TEMP_MIN                = 0

TEMP_NORM               = 4                     ; Jetman can move at full speed when Jetpack cools down, and this level is reached.

; The Jetpack heating up / cooling down thresholds.
JM_HEAT_RED_CNT         = 100
JM_HEAT_CNT             = 60
JM_COOL_CNT             = 15

BAR_TILE_START         = 33*2                   ; *2 because each tile takes 2 bytes.
BAR_RAM_START          = ti.TI_MAP_RAM_H5B00 + BAR_TILE_START ; HL points to screen memory containing tilemap.
BAR_TILE_PAL           = $30

BAR_ICON               = 38
BAR_ICON_RAM_START     = BAR_RAM_START - 2
BAR_ICON_PAL           = $00

;----------------------------------------------------------;
;----------------------------------------------------------;
;                        MACROS                            ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                    _ShowHeatBarIcon                      ;
;----------------------------------------------------------;
    MACRO _ShowHeatBarIcon

    LD HL, BAR_ICON_RAM_START

    LD (HL), BAR_ICON                           ; Set tile id.
    INC HL
    LD (HL), BAR_ICON_PAL                       ; Set palette for tile.

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                    _JetpackTempDown                      ;
;----------------------------------------------------------;
    MACRO _JetpackTempDown

    ; Exit if jetpack is cold
    LD A, (jetTempLevel)
    CP TEMP_MIN
    JR Z, .end

    ; ##########################################
    ; Increase the cool down counter, and check whether it's necessary to decrease the heat level of the jetpack.
    LD A, (jetCoolCnt)
    INC A
    LD (jetCoolCnt),A

    CP JM_COOL_CNT
    JR NZ, .end                                 ; The counter did not reach the required value to decrease jeptack temp.

    ; Cool down counter has reached max value, reset it.
    XOR A
    LD (jetCoolCnt), A

    ; ##########################################
    ; Decrease jetpack temp
    LD A, (jetTempLevel)
    DEC A
    LD (jetTempLevel),A

    CP TEMP_NORM
    JR NZ, .afterNormTempCheck

    ; #########################################
    ; Is Jetpack going to temp normal from overheated?
    LD A, (jt.jetState)
    CP jt.JETST_OVERHEAT
    JR NZ, .afterNormTempCheck

    ; Jetpack is coll again
    LD A, jt.JETST_NORMAL
    LD (jt.jetState), A

    CALL gc.JetpackTempNormal
.afterNormTempCheck

    CALL _UpdateUiHeatBar

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                     _JetpackTempUp                       ;
;----------------------------------------------------------;
    MACRO _JetpackTempUp

    ; Check if Jetpack has overheated already.
    LD A, (jetTempLevel)
    CP TEMP_MAX
    JR Z, .end

    ; ##########################################
    ; Increase the heat counter, and check whether it's necessary to increase the heat level of the jetpack.
    LD A, (jetHeatCnt)
    INC A
    LD (jetHeatCnt),A

    ; Temperature increase speed slows down hen #jetTempLevel is over TEMP_RED.
    ; if #jetTempLevel < TEMP_RED then compare #jetHeatCnt with JM_HEAT_CNT.
    ; if #jetTempLevel >= TEMP_RED then compare #jetHeatCnt with JM_HEAT_RED_CNT.
    LD A, (jetTempLevel)
    CP TEMP_RED
    JR NC, .increaseSlow

    ; Fast heat increase.
    LD A, (jetHeatCnt)
    CP JM_HEAT_CNT
    JR NZ, .end                                 ; The counter did not reach the required value to increase jeptack's temp.
    JR .afterIncrease

.increaseSlow
    ; Slow down hating.
    LD A, (jetHeatCnt)
    CP JM_HEAT_RED_CNT
    JR NZ, .end                                 ; The counter did not reach the required value to increase jeptack's temp.
.afterIncrease

    ; Heat up counter has reached max value, reset it.
    XOR A
    LD (jetHeatCnt),A

    ; ##########################################
    ; Increase jetpack temp.
    LD A, (jetTempLevel)
    INC A
    LD (jetTempLevel),A

    CP TEMP_MAX
    JR NZ, .afterTempCheck

    ; Jetpack has overhated.
    LD A, jt.JETST_OVERHEAT
    jt.SetJetState
    LD (jt.jetState), A

    CALL dbs.SetupAyFxsBank
    LD A, af.FX_JET_OVERHEAT
    CALL af.AfxPlay

.afterTempCheck

    CALL _UpdateUiHeatBar

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PUBLIC FUNCTIONS                       ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                  AnimateJetpackOverheat                  ;
;----------------------------------------------------------;
; Replace last two tiles in heat bar for blinking effect: _BAR_RED_A1_SPR,_BAR_RED_A2_SPR -> _BAR_RED_B1_SPR,_BAR_RED_B2_SPR
AnimateJetpackOverheat

    ; Animate only when overheated, and Jetman slows down.
    LD A, (jt.jetState)
    CP jt.JETST_OVERHEAT
    RET NZ

    ; Move HL so that it points to first read tile.
    LD HL, BAR_RAM_START
    ADD HL, TEMP_RED*2

    ; Do not animate when on the ground.
    LD A, (jt.jetGnd)
    CP jt.JT_STATE_INACTIVE
    JR NZ, .normal

    ; Change between two colors based on the flip-flop counter.
    LD A, (mld.counter008FliFLop)
    CP _GC_FLIP_ON_D1
    JR Z, .on

.normal
    LD (HL), _BAR_RED_A1_SPR                    ; Set tile id.
    INC HL
    LD (HL), BAR_TILE_PAL                       ; Set palette for tile.
    INC HL
    LD (HL), _BAR_RED_A2_SPR                    ; Set tile id.
    INC HL
    LD (HL), BAR_TILE_PAL                       ; Set palette for tile.
    RET
.on
    LD (HL), _BAR_RED_B1_SPR                    ; Set tile id.
    INC HL
    LD (HL), BAR_TILE_PAL                       ; Set palette for tile.
    INC HL
    LD (HL), _BAR_RED_B2_SPR                    ; Set tile id.
    INC HL
    LD (HL), BAR_TILE_PAL                       ; Set palette for tile.

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  ResetJetpackOverheating                 ;
;----------------------------------------------------------;
ResetJetpackOverheating

    XOR A
    LD (jetHeatCnt), A
    LD (jetCoolCnt), A
    LD (jetTempLevel), A
    CALL _UpdateUiHeatBar
    _ShowHeatBarIcon

    jt.ResetOverheat

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 UpdateJetpackOverheating                 ;
;----------------------------------------------------------;
UpdateJetpackOverheating

    ; Increase the overheating timer if Jetman is flying.
    LD A, (jt.jetAir)
    CP jt.JT_STATE_INACTIVE
    JR Z, .afterFlaying
    
    ; Jetman is flying
    _JetpackTempUp
    RET
.afterFlaying

    ; ##########################################
    ; Increase the cool down timer if Jetman is walking.
    LD A, (jt.jetGnd)
    CP jt.JT_STATE_INACTIVE
    RET Z
    
    ; Jetman is walking.
    _JetpackTempDown

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   JetpackOverheatFx                      ;
;----------------------------------------------------------;
JetpackOverheatFx

    LD A, (jt.jetState)
    CP jt.JETST_OVERHEAT
    RET NZ

    ; Do not beep when walking.
    LD A, (jt.jetGnd)
    CP jt.JT_STATE_INACTIVE
    RET NZ

    CALL dbs.SetupAyFxsBank
    LD A, af.FX_JET_OVERHEAT
    CALL af.AfxPlay

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                    _UpdateUiHeatBar                      ;
;----------------------------------------------------------;
_UpdateUiHeatBar

    ; Return if gamebar is hidden.
    LD A, (gb.gamebarState)
    CP gb.GB_VISIBLE
    RET NZ

    LD B, 0
    LD HL, BAR_RAM_START
.tilesLoop

    ; ##########################################
    ; Load heat progress bar.
    LD A, (jetTempLevel)
    CP B
    JR NC, .fullBar                            ; Jump if B >= #jetTempLevel.
    LD A, _BAR_EMPTY_SPR
    JR .afterBar
.fullBar
    LD A, _BAR_FULL_SPR
.afterBar
    ADD B
    
    LD (HL), A                                  ; Set tile id.
    INC HL
    LD (HL), BAR_TILE_PAL                       ; Set palette for tile.
    INC HL

    ; ##########################################
    ; Loop
    INC B
    LD A, B
    CP _BAR_TILES
    JR NZ, .tilesLoop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE
