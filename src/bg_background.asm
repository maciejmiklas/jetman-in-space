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

	; Take Jemtan's ground position and subtract it from its current position (half of it). If Jetman is on the ground, it should be 0
	LD A, _CF_GSC_JET_GND/_CF_GBG_MOVE_SLOW
	SUB B										; A contains _CF_GSC_JET_GND - #jetY
	LD B, A

	; Move background above the ground line
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
;                 #LoadBackgroundImage                     ;
;----------------------------------------------------------;
; Input:
;  - D: start bank containing background image source
LoadBackgroundImage
	
	; Layer 2 Palette
	NEXTREG _MMU_REG_SLOT6_H56, _CF_BIN_BGR_PAL_BANK ; Memory bank (8KiB) containing layer 2 palette data
	LD HL, db.backGroundL1Palette				; Address of first byte of layer 2 palette data
	CALL sc.SetupLayer2Palette

	LD E, _CF_BIN_BGR_ST_BANK					; Destination bank where layer 2 image is expected. See "NEXTREG _DC_REG_L2_BANK_H12 ...."

	LD B, _CF_GBG_IMG_BANKS						; Number of banks/iterations
.slotLoop										; Image has 320x256 and occupies 10 banks, each loop copies single bank
	PUSH BC

	LD A, D
	NEXTREG _MMU_REG_SLOT6_H56, A				; Read from

	LD A, E
	NEXTREG _MMU_REG_SLOT7_H57, A				; Write to

	PUSH DE
	LD HL, _RAM_SLOT6_START_HC000				; Source
	LD DE, _RAM_SLOT7_START_HE000				; Destination
	LD BC, _CF_BANK_BYTES
	LDIR
	POP DE

	INC D										; Next bank
	INC E										; Next bank
	
	POP BC
	DJNZ .slotLoop
	RET											; ## END of the function ##
;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE	
