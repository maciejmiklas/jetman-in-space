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
	LD (btd.palBytes), HL

	; Load the address of the original palette into a global variable.
	LD HL, dbi.bgrL1PaletteAdr
	LD (btd.palAdr), HL

	CALL btd.LoadLevelPalette

	; ##########################################
	; Load background image

	; Load the address of the image into a global variable. LoadImage will be called on #RespawnJet
	LD A, $$dbi.bgrL1Img
	LD (bm.imageBank), A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE
