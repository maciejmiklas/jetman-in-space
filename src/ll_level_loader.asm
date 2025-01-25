;----------------------------------------------------------;
;                       Level Data                         ;
;----------------------------------------------------------;
	MODULE ll

;----------------------------------------------------------;
;                  #LoadLevelData1                         ;
;----------------------------------------------------------;
LoadLevelData1

	; ##########################################
	; Load palettes

	; Load palette size into a global variable.
	LD HL, dbi.bgrL1PaletteBytes
	LD (bp.palBytes), HL

	; Load the address of the original palette into a global variable.
	LD HL, dbi.bgrL1PaletteAdr
	LD (bp.palAdr), HL

	CALL bp.BgImageVariablesSet					; Palette global variables are set.
	CALL bp.LoadLayer2Palette					; Load orginal palette into hardware.
	CALL bp.CreateTimeOfDayPalettes				; Create palettes for different times of day.

	; ##########################################
	; Load background image

	; Load the address of the image into a global variable.
	LD A, $$dbi.bgrL1Img
	LD (bm.imageBank), A

	CALL bm.LoadLevel2Image						; Load image into hardware.
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE
