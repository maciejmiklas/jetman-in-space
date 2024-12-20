;----------------------------------------------------------;
;                Background Image Effects                  ;
;----------------------------------------------------------;
	MODULE bg

bgOffset				BYTE _CF_TI_GND


;----------------------------------------------------------;
;             UpdateBackgroundOnJetmanMove                 ;
;----------------------------------------------------------;
; The background starts at the bottom of the screen with offset 16. That is the height of the ground. The background should begin exactly
; where the ground ends. From the bottom of the screen, there is ground, 16 pixels high, and the background follows after it. When Jetman
; moves upwards, the background should move down and hide behind the ground. For that, we are decreasing the background offset. It starts 
; with 16 (Jetman stands on the ground), counts down to 0, then rolls over to 255, and counts towards 0.
UpdateBackgroundOnJetmanMove

	; Divide the Jetman's position by _CF_GBG_MOVE_SLOW to slow down the movement of the background
	LD A, (jpo.jetY)
	LD C, A
	LD D, _CF_GBG_MOVE_SLOW
	CALL ut.CdivD
	LD B, C										; B contains #jetY/_CF_GBG_MOVE_SLOW

	; Take Jemtan's ground position and subtract it from its current Jetman's position (half of it). If Jetman is on the ground, it should be 0
	LD A, _CF_GSC_JET_GND/_CF_GBG_MOVE_SLOW
	SUB B										; A contains _CF_GSC_JET_GND - #jetY
	LD B, A

	; Move background above the ground
	LD A, _CF_TI_GND
	SUB B
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
