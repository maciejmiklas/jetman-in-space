/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                      Times of Day                        ;
;----------------------------------------------------------;
    MODULE td

TOD_STEPS_D4            = 4                     ; Total number of steps (times of the day) from day to night.
TOD_STEP_DURATION_D20   = 20                    ; Duration of a single time of day, except for a full day.
TOD_DAY_DURATION_D10    = 40                    ; Duration of the full day.

; State for #stepDir indicating the direction of the change: from day to night, night to day, or full day.
TOD_DIR_DAY_NIGHT_D1    = 1                     ; Environment changes from day to night.
TOD_DIR_NIGHT_DAY_D2    = 2                     ; Environment changes from night to day.
TOD_DIR_FULL_DAY_D3     = 3                     ; It's a full day.

TOD_LIMITV_1_D1          = 1
TOD_LIMITV_2_D0          = 0

step                    DB TOD_STEPS_D4         ; Counts from TOD_STEPS_D4 (inclusive) to 0 (exclusive).
stepDuration            DB TOD_DAY_DURATION_D10 ; Counts toward 0, when reached, the next #step executes.
stepDir                 DB TOD_DIR_DAY_NIGHT_D1 ; TOD_DIR_DAY_NIGHT_D1 or TOD_DIR_NIGHT_DAY_D2.

;----------------------------------------------------------;
;----------------------------------------------------------;
;                        MACROS                            ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                  _NextStepDayToNight                     ;
;----------------------------------------------------------;
    MACRO _NextStepDayToNight

    ; Decrement counter and execute next step if not 0, otherwise, change direction from day->night to night->day.
    LD A, (step)
    OR A                                        ; Same as CP 0, but faster.
    JR NZ, .nextStep

    ; ##########################################
    ; Counter has reached 0, reverse direction.

    LD A, TOD_STEPS_D4
    LD (step), A

    ; Reverse from day->night to night->day.
    LD A, TOD_DIR_NIGHT_DAY_D2
    LD (stepDir), A

    LD A, 1                                 ; Switching should be short.
    LD (stepDuration), A

    CALL gc.NightEnds
    JR .end

.nextStep
    ; ##########################################
    ; Execute the next step, first, reset the counter for its duration.

    ; Duration for the next step.
    LD A, TOD_STEP_DURATION_D20
    LD (stepDuration), A

    CALL gc.NextDayToNight

    ; Decrement step
    LD A, (step)
    DEC A
    LD (step), A

    ; ##########################################
    ; Limit visibility
    CP TOD_LIMITV_1_D1
    JR NZ, .notLimit1
    CALL gc.NightLimitVisibility1
.notLimit1

    CP TOD_LIMITV_2_D0
    JR NZ, .notLimit0
    CALL gc.NightLimitVisibility2
.notLimit0

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                   _NextStepFullDay                       ;
;----------------------------------------------------------;
    MACRO _NextStepFullDay

    ; Switching should be short.
    LD A, 1
    LD (stepDuration), A

    ; Reverse from night->day to day->night.
    LD A, TOD_DIR_DAY_NIGHT_D1
    LD (stepDir), A

    LD A, TOD_STEPS_D4
    LD (step), A

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                   _NextStepNightToDay                    ;
;----------------------------------------------------------;
    MACRO _NextStepNightToDay

    ; Decrement counter and execute next step if not 0, otherwise, change direction from night->day to day->night.
    LD A, (step)
    OR A                                        ; Same as CP 0, but faster.
    JR NZ, .nextStep

    ; ##########################################
    ; Counter has reached 0, switch to full day.

    LD A, TOD_DIR_FULL_DAY_D3
    LD (stepDir), A

    LD A, TOD_DAY_DURATION_D10
    LD (stepDuration), A

    CALL gc.ChangeToFullDay

    JR .end

.nextStep
    ; ##########################################
    ; Execute the next step, first, reset the counter for its duration.

    ; Duration for the next step.
    LD A, TOD_STEP_DURATION_D20
    LD (stepDuration), A

    CALL gc.NextNightToDay

    ; Decrement step
    LD A, (step)
    DEC A
    LD (step), A

    CP TOD_DIR_NIGHT_DAY_D2
    JR NZ, .end
    CALL gc.NightLimitVisibilityOff

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PUBLIC FUNCTIONS                       ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                     ResetTimeOfDay                       ;
;----------------------------------------------------------;
ResetTimeOfDay

    LD A, TOD_STEPS_D4
    LD (step), A

    LD A, TOD_DAY_DURATION_D10
    LD (stepDuration), A

    LD A, TOD_DIR_DAY_NIGHT_D1
    LD (stepDir), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   NextTimeOfDayPhase                     ;
;----------------------------------------------------------;
NextTimeOfDayPhase

    ; Decrement count and return if not reached 0
    LD A, (stepDuration)
    DEC A
    LD (stepDuration), A

    OR A                                        ; Same as CP 0, but faster.
    RET NZ                                      ; Keep counting down.

    ; ##########################################
    ; The counter reached 0, set up the next step. There are two transition options: day changes to night or night to day.

    LD A, (stepDir)
    
    ; Full day?
    CP TOD_DIR_FULL_DAY_D3
    JR NZ, .notFullDay

    ; Yes, it's full day.
    _NextStepFullDay
    RET
.notFullDay
    ; It's not a full day, so it must be day->night or night->day.

    CP TOD_DIR_DAY_NIGHT_D1
    JR Z, .transitionDayToNight

    _NextStepNightToDay
    RET

.transitionDayToNight
    _NextStepDayToNight

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE