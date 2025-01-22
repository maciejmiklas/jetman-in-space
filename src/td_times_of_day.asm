;----------------------------------------------------------;
;                      Times of Day                        ;
;----------------------------------------------------------;
	MODULE td

step 					BYTE _TOD_STEP_FULL_DAY	; Current time of the day, from _TOD_STEP_FULL_DAY to _TOD_STEP_NIGHT.

; Counter goes in two directions:
;  - for #stepCntDir == _TOD_STEPDIR_DAY it counts from _TOD_STEP_DAY to _TOD_STEP_NIGHT inclusive,
;  - for #stepCntDir == _TOD_STEPDIR_NIGHT it counts from _TOD_STEP_NIGHT to _TOD_STEP_FULL_DAY inclusive.
stepCnt					BYTE _TOD_DAY_DURATION

stepCntDir				BYTE _TOD_STEPDIR_DAY	; Counts toward 0, when that happens, the next step is executed.

;----------------------------------------------------------;
;               #NextTimeOfDayTrigger                      ;
;----------------------------------------------------------;
NextTimeOfDayTrigger

	; Decrement count and return if not reached 0.
	LD A, (stepCnt)
	DEC A
	LD (stepCnt), A

	CP 0
	RET NZ										; Keep counting down.

	; ##########################################
	; The counter reached 0, set up the next step. There are two transition options: day changes to night or night to day.

	LD A, (stepCntDir)
	CP _TOD_STEPDIR_DAY
	JR Z, .transtionDayToNight

	CALL NextStepNightToDay
	RET

.transtionDayToNight	
	CALL NextStepDayToNight

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                 #NextStepDayToNight                      ;
;----------------------------------------------------------;
; Environment brightness goes down from _TOD_STEP_DAY to _TOD_STEP_NIGHT.
NextStepDayToNight

	; Should we execute the next step, or was it the last one?
	LD A, (step)
	CP _TOD_STEP_NIGHT
	JR NZ, .nextStep

	; ##########################################
	; We've reached the last step; the transition from day to night ends here. Now revert it.

	; The duration of the next step should be very short because we only need to change direction.
	; The step itself does not change bacause was already executed.
	LD A, 1
	LD (stepCnt), A

	; Revert transtion from "day to night" to "night to day".
	LD A, _TOD_STEPDIR_NIGHT
	LD (stepCntDir), A

	RET

.nextStep
	; ##########################################
	; Execute the next step, first, reset the counter for its duration.

	; Duration for the next step.
	LD A, _TOD_STEP_DURATION
	LD (stepCnt), A

	; Next step
	LD A, (step)
	INC A
	LD (step), A

	CALL gc.NextFromNightToDay

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                 #NextStepNightToDay                      ;
;----------------------------------------------------------;
; Environment brightness increases from _TOD_STEP_NIGHT to _TOD_STEP_FULL_DAY.
NextStepNightToDay

	; Should we execute the next step, or was it the last one?
	LD A, (step)
	CP _TOD_STEP_DAY
	JR NZ, .nextStep

	; ##########################################
	; We have reached the end of dusk, and now the bright day starts.

	; Duration for the day.
	LD A, _TOD_DAY_DURATION
	LD (stepCnt), A

	; Next state, full day.
	LD A, _TOD_STEP_FULL_DAY
	LD (step), A

	; Revert transtion from "night to day" to "day to night".
	LD A, _TOD_STEPDIR_DAY
	LD (stepCntDir), A	

	CALL gc.TimeOfDayChangeToFullDay
	RET
	
.nextStep
	; ##########################################
	; Execute the next step, first, reset the counter for its duration.

	; Duration for the next step.
	LD A, _TOD_STEP_DURATION
	LD (stepCnt), A

	; Next step
	LD A, (step)
	DEC A
	LD (step), A

	CALL gc.NextFromDayToNight

	RET											; ## END of the function ##	

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE