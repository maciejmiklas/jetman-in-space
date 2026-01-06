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
; When it reaches JM_HEAT_CNT_D60, the jetpack temperature will increase (#jetTempLevel) until it reaches MAX_TEMP. Then, it will update Jetman
; state to #JETST_OVERHEAT_D104 and slow flying down. 
; When Jetman lands, the #jetCoolCnt decreases. When it reaches JM_COOL_CNT_D15, the jetpack temperature decreases,
; until it reaches #TEMP_NORM_D4. At this point, the Jetman state changes to #JETST_NORMAL_D101, and Jetman can fly at a full speed.

; Jetpack heats up/cools down during the flight
jetHeatCnt              DB 0                    ; Runs from 0 to JM_HEAT_CNT_D60
jetCoolCnt              DB 0                    ; Runs from 0 to JM_COOL_CNT_D15

jetTempLevel            DB 0

TEMP_MAX_D6             = 6                     ; The heat bar in UI (H) has 5 elements, 6 means it's overheated.
TEMP_RED_D4             = 4
TEMP_MIN_D0             = 0

TEMP_NORM_D4            = 4                     ; Jetman can move at full speed when Jetpack cools down, and this level is reached.

; The Jetpack heating up / cooling down thresholds.
JM_HEAT_RED_CNT_D100    = 100
JM_HEAT_CNT_D60         = 60
JM_COOL_CNT_D15         = 15

BAR_TILE_START         = 33*2                   ; *2 because each tile takes 2 bytes.
BAR_RAM_START          = ti.TI_MAP_RAM_H5B00 + BAR_TILE_START ; HL points to screen memory containing tilemap.
BAR_TILE_PAL_H30       = $30

BAR_ICON_D38            = 38
BAR_ICON_RAM_START     = BAR_RAM_START - 2
BAR_ICON_PAL_H00       = $00

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

    LD (HL), BAR_ICON_D38                           ; Set tile id.
    INC HL
    LD (HL), BAR_ICON_PAL_H00                       ; Set palette for tile.

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                    _JetpackTempDown                      ;
;----------------------------------------------------------;
    MACRO _JetpackTempDown

    ; Exit if jetpack is cold
    LD A, (jetTempLevel)
    OR A                                        ; Same as: CP TEMP_MIN_D0
    JR Z, .end

    ; ##########################################
    ; Increase the cool down counter, and check whether it's necessary to decrease the heat level of the jetpack.
    LD A, (jetCoolCnt)
    INC A
    LD (jetCoolCnt),A

    CP JM_COOL_CNT_D15
    JR NZ, .end                                 ; The counter did not reach the required value to decrease jeptack temp.

    ; Cool down counter has reached max value, reset it.
    XOR A
    LD (jetCoolCnt), A

    ; ##########################################
    ; Decrease jetpack temp
    LD A, (jetTempLevel)
    DEC A
    LD (jetTempLevel),A

    CP TEMP_NORM_D4
    JR NZ, .afterNormTempCheck

    ; #########################################
    ; Is Jetpack going to temp normal from overheated?
    LD A, (jt.jetState)
    CP jt.JETST_OVERHEAT_D104
    JR NZ, .afterNormTempCheck

    ; Jetpack is coll again
    LD A, jt.JETST_NORMAL_D101
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
    CP TEMP_MAX_D6
    JR Z, .end

    ; ##########################################
    ; Increase the heat counter, and check whether it's necessary to increase the heat level of the jetpack.
    LD A, (jetHeatCnt)
    INC A
    LD (jetHeatCnt),A

    ; Temperature increase speed slows down hen #jetTempLevel is over TEMP_RED_D4.
    ; if #jetTempLevel < TEMP_RED_D4 then compare #jetHeatCnt with JM_HEAT_CNT_D60.
    ; if #jetTempLevel >= TEMP_RED_D4 then compare #jetHeatCnt with JM_HEAT_RED_CNT_D100.
    LD A, (jetTempLevel)
    CP TEMP_RED_D4
    JR NC, .increaseSlow

    ; Fast heat increase.
    LD A, (jetHeatCnt)
    CP JM_HEAT_CNT_D60
    JR NZ, .end                                 ; The counter did not reach the required value to increase jeptack's temp.
    JR .afterIncrease

.increaseSlow
    ; Slow down hating.
    LD A, (jetHeatCnt)
    CP JM_HEAT_RED_CNT_D100
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

    CP TEMP_MAX_D6
    JR NZ, .afterTempCheck

    ; Jetpack has overhated.
    LD A, jt.JETST_OVERHEAT_D104
    CALL jt.SetJetState
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
; Replace last two tiles in heat bar for blinking effect: _BAR_RED_A1_SPR_D180,_BAR_RED_A2_SPR_D181 -> _BAR_RED_B1_SPR_D188,_BAR_RED_B2_SPR_D189
AnimateJetpackOverheat

    ; Animate only when overheated, and Jetman slows down.
    LD A, (jt.jetState)
    CP jt.JETST_OVERHEAT_D104
    RET NZ

    ; Move HL so that it points to first read tile.
    LD HL, BAR_RAM_START
    ADD HL, TEMP_RED_D4*2

    ; Do not animate when on the ground.
    LD A, (jt.jetGnd)
    OR A                                        ; Same as: CP jt.JT_STATE_INACTIVE_D0
    JR NZ, .normal

    ; Change between two colors based on the flip-flop counter.
    LD A, (mld.counter008FliFLop)
    CP _GC_FLIP_ON_D1
    JR Z, .on

.normal
    LD (HL), _BAR_RED_A1_SPR_D180                    ; Set tile id.
    INC HL
    LD (HL), BAR_TILE_PAL_H30                       ; Set palette for tile.
    INC HL
    LD (HL), _BAR_RED_A2_SPR_D181                    ; Set tile id.
    INC HL
    LD (HL), BAR_TILE_PAL_H30                       ; Set palette for tile.
    RET
.on
    LD (HL), _BAR_RED_B1_SPR_D188                    ; Set tile id.
    INC HL
    LD (HL), BAR_TILE_PAL_H30                       ; Set palette for tile.
    INC HL
    LD (HL), _BAR_RED_B2_SPR_D189                    ; Set tile id.
    INC HL
    LD (HL), BAR_TILE_PAL_H30                       ; Set palette for tile.

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

    CALL jt.ResetOverheat

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 UpdateJetpackOverheating                 ;
;----------------------------------------------------------;
UpdateJetpackOverheating

    ; Increase the overheating timer if Jetman is flying.
    LD A, (jt.jetAir)
    OR A                                        ; Same as: CP jt.JT_STATE_INACTIVE_D0
    JR Z, .afterFlaying
    
    ; Jetman is flying
    _JetpackTempUp
    RET
.afterFlaying

    ; ##########################################
    ; Increase the cool down timer if Jetman is walking.
    LD A, (jt.jetGnd)
    CP jt.JT_STATE_INACTIVE_D0
    RET Z
    
    ; Jetman is walking.
    _JetpackTempDown

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   JetpackOverheatFx                      ;
;----------------------------------------------------------;
JetpackOverheatFx

    LD A, (jt.jetState)
    CP jt.JETST_OVERHEAT_D104
    RET NZ

    ; Do not beep when walking.
    LD A, (jt.jetGnd)
    OR A                                        ; Same as: CP jt.JT_STATE_INACTIVE_D0
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
    CP gb.GB_VISIBLE_D1
    RET NZ

    LD B, 0
    LD HL, BAR_RAM_START
.tilesLoop

    ; ##########################################
    ; Load heat progress bar.
    LD A, (jetTempLevel)
    CP B
    JR NC, .fullBar                            ; Jump if B >= #jetTempLevel.
    LD A, _BAR_EMPTY_SPR_D182
    JR .afterBar
.fullBar
    LD A, _BAR_FULL_SPR_D176
.afterBar
    ADD B
    
    LD (HL), A                                  ; Set tile id.
    INC HL
    LD (HL), BAR_TILE_PAL_H30                       ; Set palette for tile.
    INC HL

    ; ##########################################
    ; Loop
    INC B
    LD A, B
    CP _BAR_TILES_D6
    JR NZ, .tilesLoop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE
