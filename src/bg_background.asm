;----------------------------------------------------------;
;                Background Image Effects                  ;
;----------------------------------------------------------;
	MODULE bg

bgOffset				BYTE 191

;----------------------------------------------------------;
;             UpdateBackgroundOnJetmanMove                 ;
;----------------------------------------------------------;
; Offset = _CF_SC_L2_MAX_OFFSET - (_CF_GSC_JET_GND - #jetY)/_CF_GBG_MOVE_SLOW, or with numbers: 191 - (217 - #jetY)/3
UpdateBackgroundOnJetmanMove

	LD A, (jpo.jetY)
	LD B, A
	LD A, _CF_GSC_JET_GND
	SUB B										; A = _CF_GSC_JET_GND - #jetY

	LD C, A
	LD D, _CF_GBG_MOVE_SLOW
	CALL ut.CdivD								; C contains (_CF_GSC_JET_GND - #jetY)/_CF_GBG_MOVE_SLOW

	LD A, _CF_SC_L2_MAX_OFFSET
	SUB C
	LD (bgOffset), A

	; Limit movement so that the planet does not roll over
	CP _CF_GBG_OFFSET_MAX
	RET C										; Return if A < _CF_GBG_OFFSET_MAX

	NEXTREG _DC_REG_L2_OFFSET_Y_H17, A			; Set layer 2 Offset

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
;                 #LoadBackgroundImage                     ;
;----------------------------------------------------------;
; Input:
;  - D: start bank containing background image source
;  - HL: Address of layer 2 palette data
LoadBackgroundImage

	LD B, _CF_GBG_IMG_BANKS
	CALL sc.LoadLevel2Image

	CALL sc.FillLevel2Image
	RET											; ## END of the function ##
	
;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE	
