;----------------------------------------------------------;
;                Background Image Effects                  ;
;----------------------------------------------------------;
	MODULE bg

bgOffset				BYTE 0

;----------------------------------------------------------;
;             UpdateBackgroundOnJetmanMove                 ;
;----------------------------------------------------------;
UpdateBackgroundOnJetmanMove

	; Horizontal movement
	LD A, (jpo.jetY)
	LD B, A
	LD A, _CF_GSC_JET_GND
	SUB B
	LD (bgOffset), A

	; Divide position to limit movement
	LD C, A
	LD D, 2
	CALL ut.CdivD
	LD A, C
	LD (bgOffset), A
	NEXTREG _DC_REG_L2_OFFSET_Y_H17, A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;            #SetupBackgroundOnRocketTakeoff               ;
;----------------------------------------------------------;
SetupBackgroundOnRocketTakeoff

	;XOR A
	;LD (bgOffset), A
	RET											; ## END of the function ##

;----------------------------------------------------------;
;             #AnimateBackgroundOnFlyRocket                ;
;----------------------------------------------------------;
AnimateBackgroundOnFlyRocket

	; Return if rocket is not flying
	LD A, (ro.rocketState)
	CP ro.RO_ST_FLY
	RET NZ

	; ##########################################
	; Start animation when the rocket reaches given height
	LD HL, (ro.rocketDistance)
	LD A, H
	CP 0										; If H > 0 then distance is definitely > _CF_GBG_MOVE_ROCKET
	JR NZ, .afterAnimationStart

	LD A, L
	CP _CF_GBG_MOVE_ROCKET
	RET C
.afterAnimationStart

	; ##########################################
	; Move the background image
	LD A, (bgOffset)
	DEC A
	LD (bgOffset), A
	NEXTREG _DC_REG_L2_OFFSET_Y_H17, A

	CP 0
	JR NZ, .afterBgOffsetReset
	LD A, 192
	LD (bgOffset), A
.afterBgOffsetReset
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE	
