;----------------------------------------------------------;
;                       Level Data                         ;
;----------------------------------------------------------;
	MODULE ll

;----------------------------------------------------------;
;                  #LoadLevel1Data                         ;
;----------------------------------------------------------;
LoadLevel1Data

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
;                  #LoadLevel2Data                         ;
;----------------------------------------------------------;
LoadLevel2Data

	; ##########################################
	; Load palettes

	; Load palette size into a global variable.
	LD HL, dbi.bgrL2PaletteBytes
	LD (btd.palBytes), HL

	; Load the address of the original palette into a global variable.
	LD HL, dbi.bgrL2PaletteAdr
	LD (btd.palAdr), HL

	CALL btd.LoadLevelPalette

	; ##########################################
	; Load background image

	; Load the address of the image into a global variable. LoadImage will be called on #RespawnJet
	LD A, $$dbi.bgrL2Img
	LD (bm.imageBank), A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE
