;----------------------------------------------------------;
;                Background Image Effects                  ;
;----------------------------------------------------------;
	MODULE bg

bgOffset				BYTE 0
tmp				BYTE 0
;----------------------------------------------------------;
;             UpdateBackgroundOnJetmanMove                 ;
;----------------------------------------------------------;
; The background starts at the bottom of the screen with offset 16. That is the height of the ground. The background should begin exactly
; where the ground ends. From the bottom of the screen, there is ground, 16 pixels high, and the background follows after it. When Jetman
; moves upwards, the background should move down and hide behind the ground. For that, we are decreasing the background offset. It starts 
; with 16 (Jetman stands on the ground), counts down to 0, then rolls over to 255, and counts towards 0.
UpdateBackgroundOnJetmanMove

	; Divide the Jetman's position by _GBG_MOVE_SLOW_D3 to slow down the movement of the background
	LD A, (jpo.jetY)
	LD C, A
	LD D, _GBG_MOVE_SLOW_D3
	CALL ut.CdivD
	LD B, C										; B contains #jetY/_GBG_MOVE_SLOW_D3

	; Take Jemtan's ground position and subtract it from its current position (half of it). If Jetman is on the ground, it should be 0
	LD A, _GSC_JET_GND_D217/_GBG_MOVE_SLOW_D3
	SUB B										; A contains _GSC_JET_GND_D217 - #jetY. It's 0 when Jemant stands on the ground.
	LD B, A
	LD (bgOffset), A

	; Move background above the ground line
	LD A, _GBG_OFFSET_D24
	SUB B										; B contains background offset
	NEXTREG _DC_REG_L2_OFFSET_Y_H17, A

	; ##########################################
	; Hide picture line going behind the horizon	

	; Calculate the line number that needs to be replaced. It's the line going behind the horizon.  It's always the bottom line on the image
	LD A, _BM_YRES_D256-1
	SUB B										; B contains background offset

	; Do not remove the line if the Jetman is on the ground (offset is 255)
	CP _BM_YRES_D256-1
	RET Z

	LD (tmp), A
	LD E, A
	CALL bm.HideImageLine
	RET											; ## END of the function ##

;----------------------------------------------------------;
;            #SetupBackgroundOnRocketTakeoff               ;
;----------------------------------------------------------;
SetupBackgroundOnRocketTakeoff

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
	CP 0										; If H > 0 then distance is definitely > _GBG_MOVE_ROCKET_D100
	JR NZ, .afterAnimationStart

	LD A, L
	CP _GBG_MOVE_ROCKET_D100
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
