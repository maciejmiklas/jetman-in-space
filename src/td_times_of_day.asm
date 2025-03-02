;----------------------------------------------------------;
;                      Times of Day                        ;
;----------------------------------------------------------;
	MODULE td

step 					BYTE _TOD_STEPS_D4			; Counts from _TOD_STEPS_D4 (inclusive) to 0 (exclusive)
stepDuration			BYTE _TOD_DAY_DURATION	; Counts toward 0, when reached, the next #step executes.
stepDir					BYTE _TOD_DIR_DAY_NIGHT	; _TOD_DIR_DAY_NIGHT or _TOD_DIR_NIGHT_DAY

;----------------------------------------------------------;
;               #NextTimeOfDayTrigger                      ;
;----------------------------------------------------------;
NextTimeOfDayTrigger

	; Decrement count and return if not reached 0.
	LD A, (stepDuration)
	DEC A
	LD (stepDuration), A

	CP 0
	RET NZ										; Keep counting down.

	; ##########################################
	; The counter reached 0, set up the next step. There are two transition options: day changes to night or night to day.

	LD A, (stepDir)
	
	; Full day?
	CP _TOD_DIR_FULL_DAY
	JR NZ, .notFullDay

	; Yes, it's full day
	CALL _NextStepFullDay
	RET
.notFullDay
	; It's not a full day, so it must be day->night or night->day

	CP _TOD_DIR_DAY_NIGHT
	JR Z, .transtionDayToNight

	CALL _NextStepNightToDay
	RET

.transtionDayToNight	
	CALL _NextStepDayToNight

	RET											; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                  #_NextStepFullDay                       ;
;----------------------------------------------------------;
_NextStepFullDay

	; Switching should be short
	LD A, 1
	LD (stepDuration), A

	; Reverse from night->day to day->night.
	LD A, _TOD_DIR_DAY_NIGHT
	LD (stepDir), A

	LD A, _TOD_STEPS_D4
	LD (step), A	

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                 #_NextStepDayToNight                     ;
;----------------------------------------------------------;
_NextStepDayToNight

	; Decrement counter and execute next step if not 0, otherwise, change direction from day->night to night->day.
	LD A, (step)
	CP 0
	JR NZ, .nextStep

	; ##########################################
	; Counter has reached 0, reverse direction.

	LD A, _TOD_STEPS_D4
	LD (step), A

	; Reverse from day->night to night->day.
	LD A, _TOD_DIR_NIGHT_DAY
	LD (stepDir), A

	LD A, 1									; Switching should be short
	LD (stepDuration), A

	CALL gc.NightEnds
	RET

.nextStep
	; ##########################################
	; Execute the next step, first, reset the counter for its duration.

	; Duration for the next step.
	LD A, _TOD_STEP_DURATION
	LD (stepDuration), A

	CALL gc.NextDayToNight

	; Decrement step
	LD A, (step)
	DEC A
	LD (step), A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                #_NextStepNightToDay                      ;
;----------------------------------------------------------;
_NextStepNightToDay

	; Decrement counter and execute next step if not 0, otherwise, change direction from night->day to day->night.
	LD A, (step)
	CP 0
	JR NZ, .nextStep

	; ##########################################
	; Counter has reached 0, switch to full day.

	LD A, _TOD_DIR_FULL_DAY
	LD (stepDir), A

	LD A, _TOD_DAY_DURATION
	LD (stepDuration), A

	CALL gc.ChangeToFullDay

	RET

.nextStep
	; ##########################################
	; Execute the next step, first, reset the counter for its duration.

	; Duration for the next step.
	LD A, _TOD_STEP_DURATION
	LD (stepDuration), A

	CALL gc.NextNightToDay

	; Decrement step
	LD A, (step)
	DEC A
	LD (step), A

	RET											; ## END of the function ##	

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE