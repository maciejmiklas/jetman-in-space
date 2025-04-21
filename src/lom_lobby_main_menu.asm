;----------------------------------------------------------;
;                   Lobby Main Menu                        ;
;----------------------------------------------------------;
	MODULE lom

FILE_IMG_POS			= 16					; Position of a image part number (0-9) in the file name of the background image.
introFileName 			DB "assets/lobby/bg_0.nxi",0

;----------------------------------------------------------;
;                     #LoadMainMenu                        ;
;----------------------------------------------------------;
LoadMainMenu

	CALL los.SetLobbyStateMainMenu

	; ##########################################
	; Load palette
	LD HL, db.menuBgPaletteAdr
	LD A, (db.menuBbPaletteBytes)
	LD B, A
	CALL bp.LoadPalette

	; ##########################################
	; Load background image
	LD IX, introFileName
	LD C, FILE_IMG_POS
	CALL fi.LoadImage
	CALL bm.LoadImage

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE	