;----------------------------------------------------------;
;                Background Image Effects                  ;
;----------------------------------------------------------;
	MODULE bg

bgOffset				BYTE 0					; Offset of the background image.
GB_OFFSET_D6 			= _TI_GND_D8-2

fileName 				DB "assets/l00/bg_0.nxi",0
FILE_LEVEL_POS			= 8						; Position of a level number (00-99) in the file name of the background image.
FILE_IMG_POS			= 14					; Position of a image part number (0-9) in the file name of the background image.

GB_MOVE_SLOW_D2			= 2						; Slows down background movement (when Jetman moves).

;----------------------------------------------------------;
;                      #LoadBgImage                        ;
;----------------------------------------------------------;
; The screen size is 320x256 (81920 bytes, 80KiB).
; Input:
;  - DE: Level number as ASCII, for example for level 4: D="0", E="4"
LoadBgImage

	; Set the level number in the file name, DE="35" will give: "assets/l00_background_0.nxi" -> "assets/l35_background_0.nxi"
	LD HL, fileName
	LD IX, HL									; Param for #LoadImage
	ADD HL, FILE_LEVEL_POS						; Move HL to "assets/l"
	LD (HL), D									; Set first number.
	INC HL
	LD (HL), E									; Set second number.

	LD C, FILE_IMG_POS
	CALL fi.LoadImage

	RET											; ## END of the function ##

;----------------------------------------------------------;
;             UpdateBackgroundOnJetmanMove                 ;
;----------------------------------------------------------;
; The background starts at the bottom of the screen with offset 16. That is the height of the ground. The background should begin where
; the ground ends (2 pixels overlap). From the bottom of the screen, there is ground, 16 pixels high, and the background follows after it.
; When Jetman moves upwards, the background should move down and hide behind the ground. For that, we are decreasing the background offset.
; It starts with 16 (Jetman stands on the ground), counts down to 0, then rolls over to 255, and counts towards 0.
UpdateBackgroundOnJetmanMove

	; Divide the Jetman's position by GB_MOVE_SLOW_D2 to slow down the movement of the background.
	LD A, (jpo.jetY)
	LD C, A
	LD D, GB_MOVE_SLOW_D2
	CALL ut.CdivD
	LD B, C										; B contains #jetY/GB_MOVE_SLOW_D2.

	; Take Jemtan's ground position and subtract it from its current position (half of it). If Jetman is on the ground, it should be 0.
	LD A, _GSC_JET_GND_D217/GB_MOVE_SLOW_D2
	SUB B										; A contains _GSC_JET_GND_D217 - #jetY. It's 0 when Jetman stands on the ground.
	LD B, A
	LD (bgOffset), A

	CALL _MoveBackground

	RET											; ## END of the function ##

;----------------------------------------------------------;
;             UpdateBackgroundOnRocketMove                 ;
;----------------------------------------------------------;
UpdateBackgroundOnRocketMove

	LD A, (bgOffset)
	CP _SC_RESY1_D255							; Keep increasing until we reach 255, the whole image is hidden afterward.
	RET Z

	INC A
	LD (bgOffset), A

	CALL _MoveBackground
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;              HideBackgroundBehindHorizon                 ;
;----------------------------------------------------------;
; Hide picture line going behind the horizon
HideBackgroundBehindHorizon

	CALL _GetGroundImageLine

	; Do not remove the line if the Jetman is on the ground (offset is 255).
	CP GBL_RET_A_GND
	RET Z

	INC A										; Move image one pixel down (TODO why is that necessary?)
	LD E, A										; E contains bottom line.
	CALL bm.HideImageLine

	RET											; ## END of the function ##

;----------------------------------------------------------;
;              ShowBackgroundAboveHorizon                  ;
;----------------------------------------------------------;
; Copy lower background image line from original picture.
ShowBackgroundAboveHorizon

	CALL _GetGroundImageLine

	; Do not remove the line if the Jetman is on the ground (offset is 255).
	CP GBL_RET_A_GND
	RET Z

	INC A										; Move image one pixel down (TODO why is that necessary?)
	LD E, A										; E contains bottom line.

	CALL bm.ReplaceImageLine

	RET											; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                    _MoveBackground                       ;
;----------------------------------------------------------;
_MoveBackground

	LD (bgOffset), A
	LD B, A
	LD A, GB_OFFSET_D6
	SUB B										; B contains background offset (current #bgOffset).
	NEXTREG _DC_REG_L2_OFFSET_Y_H17, A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  _GetGroundImageLine                     ;
;----------------------------------------------------------;
; Return:
;  - A: Returns the line number of the background image at ground level based on the horizontal image movement given by #bgOffset.
GBL_RET_A_GND				= _BM_YRES_D256-1

_GetGroundImageLine

	; Calculate the line number that needs to be replaced. It's the line going behind the horizon. It's always the bottom line of the image.
	LD A, (bgOffset)
	LD B, A
	LD A, _BM_YRES_D256-1
	SUB B										; Move A by B (background offset).

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE	
