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

	;moze zrobic jedna methode initialize?
	;gdzie dac LoadTodPalette? to powinno byc cos jak LoadDefaultPalette??
	; zpbatrz: LoadLevel2Image
	CALL btd.VariablesSet						; Palette global variables are set.
	CALL btd.LoadTodPalette						; Load orginal palette into hardware.
	CALL btd.CreateTodPalettes					; Create palettes for different times of day.

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
