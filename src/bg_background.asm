;----------------------------------------------------------;
;                Background Image Effects                  ;
;----------------------------------------------------------;
	MODULE bg

bgOffset				BYTE 0

;----------------------------------------------------------;
;             UpdateBackgroundOnJetmanMove                 ;
;----------------------------------------------------------;
; The background starts at the bottom of the screen with offset 16. That is the height of the ground. The background should begin where 
; the ground ends (2 pixels overlap). From the bottom of the screen, there is ground, 16 pixels high, and the background follows after it. 
; When Jetman moves upwards, the background should move down and hide behind the ground. For that, we are decreasing the background offset. 
; It starts with 16 (Jetman stands on the ground), counts down to 0, then rolls over to 255, and counts towards 0.
UpdateBackgroundOnJetmanMove

	; Divide the Jetman's position by _GB_MOVE_SLOW_D3 to slow down the movement of the background.
	LD A, (jpo.jetY)
	LD C, A
	LD D, _GB_MOVE_SLOW_D3
	CALL ut.CdivD
	LD B, C										; B contains #jetY/_GB_MOVE_SLOW_D3.

	; Take Jemtan's ground position and subtract it from its current position (half of it). If Jetman is on the ground, it should be 0.
	LD A, _GSC_JET_GND_D217/_GB_MOVE_SLOW_D3
	SUB B										; A contains _GSC_JET_GND_D217 - #jetY. It's 0 when Jemant stands on the ground.
	LD B, A
	LD (bgOffset), A

	; Move background above the ground line
	LD A, _GB_OFFSET_D14
	SUB B										; B contains background offset.
	NEXTREG _DC_REG_L2_OFFSET_Y_H17, A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                GetBottomBackgroundLine                   ;
;----------------------------------------------------------;
; Return:
;  - A: A number of bottom image lines based on the background offset.
GBL_RET_A_GND				= _BM_YRES_D256-1

GetBottomBackgroundLine

	; Calculate the line number that needs to be replaced. It's the line going behind the horizon.  It's always the bottom line on the image.
	LD A, (bgOffset)
	LD B, A
	LD A, _BM_YRES_D256-1
	SUB B										; Move A by B (background offset).

	RET											; ## END of the function ##

;----------------------------------------------------------;
;              HideBackgroundBehindHorizon                 ;
;----------------------------------------------------------;
; Hide picture line going behind the horizon	
HideBackgroundBehindHorizon

	CALL GetBottomBackgroundLine

	; Do not remove the line if the Jetman is on the ground (offset is 255).
	CP GBL_RET_A_GND
	RET Z

	INC A										; Move image one pixel down (TODO why is that ncessary?)
	LD E, A										; E contains bottom line.
	CALL bm.HideImageLine

	RET											; ## END of the function ##

;----------------------------------------------------------;
;              ShowBackgroundAboveHorizon                  ;
;----------------------------------------------------------;
; Copy lower background image line from original picture.
ShowBackgroundAboveHorizon

	CALL GetBottomBackgroundLine

	; Do not remove the line if the Jetman is on the ground (offset is 255).
	CP GBL_RET_A_GND
	RET Z

	INC A										; Move image one pixel down (TODO why is that ncessary?)
	LD E, A										; E contains bottom line.

	LD C, _BN_BG_L1_ST_BANK_D48
	CALL bm.ReplaceImageLine

	RET											; ## END of the function ##

;----------------------------------------------------------;
;             #AnimateBackgroundOnFlyRocket                ;
;----------------------------------------------------------;
AnimateBackgroundOnFlyRocket

	; Return if rocket is not flying.
	LD A, (ro.rocketState)
	CP ro.RO_ST_FLY
	RET NZ

	; ##########################################
	; Start animation when the rocket reaches given height.
	LD HL, (ro.rocketDistance)
	LD A, H
	CP 0										; If H > 0 then distance is definitely > _GB_MOVE_ROCKET_D100.
	JR NZ, .afterAnimationStart

	LD A, L
	CP _GB_MOVE_ROCKET_D100
	RET C
.afterAnimationStart

	; ##########################################
	; Move the background image.
	
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
