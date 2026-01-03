/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                      Times of Day                        ;
;----------------------------------------------------------;
    MODULE td

TOD_STEPS_D4            = 4                     ; Total number of steps (times of the day) from day to night.
TOD_STEP_DURATION       = 20                    ; Duration of a single time of day, except for a full day.
TOD_DAY_DURATION        = 10                    ; Duration of the full day.

; State for #stepDir indicating the direction of the change: from day to night, night to day, or full day.
TOD_DIR_DAY_NIGHT       = 1                     ; Environment changes from day to night.
TOD_DIR_NIGHT_DAY       = 2                     ; Environment changes from night to day.
TOD_DIR_FULL_DAY        = 3                     ; It's a full day.

step                    DB TOD_STEPS_D4         ; Counts from TOD_STEPS_D4 (inclusive) to 0 (exclusive).
stepDuration            DB TOD_DAY_DURATION     ; Counts toward 0, when reached, the next #step executes.
stepDir                 DB TOD_DIR_DAY_NIGHT    ; TOD_DIR_DAY_NIGHT or TOD_DIR_NIGHT_DAY.

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
    CP 0
    JR NZ, .nextStep

    ; ##########################################
    ; Counter has reached 0, reverse direction.

    LD A, TOD_STEPS_D4
    LD (step), A

    ; Reverse from day->night to night->day.
    LD A, TOD_DIR_NIGHT_DAY
    LD (stepDir), A

    LD A, 1                                 ; Switching should be short.
    LD (stepDuration), A

    gc.NightEnds
    JR .end

.nextStep
    ; ##########################################
    ; Execute the next step, first, reset the counter for its duration.

    ; Duration for the next step.
    LD A, TOD_STEP_DURATION
    LD (stepDuration), A

    gc.NextDayToNight

    ; Decrement step
    LD A, (step)
    DEC A
    LD (step), A

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
    LD A, TOD_DIR_DAY_NIGHT
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
    CP 0
    JR NZ, .nextStep

    ; ##########################################
    ; Counter has reached 0, switch to full day.

    LD A, TOD_DIR_FULL_DAY
    LD (stepDir), A

    LD A, TOD_DAY_DURATION
    LD (stepDuration), A

    gc.ChangeToFullDay

    JR .end

.nextStep
    ; ##########################################
    ; Execute the next step, first, reset the counter for its duration.

    ; Duration for the next step.
    LD A, TOD_STEP_DURATION
    LD (stepDuration), A

    gc.NextNightToDay

    ; Decrement step
    LD A, (step)
    DEC A
    LD (step), A

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

    LD A, TOD_DAY_DURATION
    LD (stepDuration), A

    LD A, TOD_DIR_DAY_NIGHT
    LD (stepDir), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  NextTimeOfDayTrigger                    ;
;----------------------------------------------------------;
NextTimeOfDayTrigger

    ; Decrement count and return if not reached 0
    LD A, (stepDuration)
    DEC A
    LD (stepDuration), A

    CP 0
    RET NZ                                      ; Keep counting down.

    ; ##########################################
    ; The counter reached 0, set up the next step. There are two transition options: day changes to night or night to day.

    LD A, (stepDir)
    
    ; Full day?
    CP TOD_DIR_FULL_DAY
    JR NZ, .notFullDay

    ; Yes, it's full day.
    _NextStepFullDay
    RET
.notFullDay
    ; It's not a full day, so it must be day->night or night->day.

    CP TOD_DIR_DAY_NIGHT
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