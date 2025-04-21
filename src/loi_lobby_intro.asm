;----------------------------------------------------------;
;                   Lobby Game Intro                       ;
;----------------------------------------------------------;
	MODULE loi

FILE_IMG_POS			= 19					; Position of a image part number (0-9) in the file name of the background image.
introFileName 			DB "assets/lobby/intro_0.nxi",0

;----------------------------------------------------------;
;                #LoadIntroBackground                      ;
;----------------------------------------------------------;
LoadIntroBackground

	; Load palette
	LD HL, db.gameIntroPaletteAdr
	LD A, (db.gameIntroPaletteBytes)
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
;                    #LoadIntroTilemap                     ;
;----------------------------------------------------------;
LoadIntroTilemap

	RET											; ## END of the function ##


;----------------------------------------------------------;
;                    #AnimateIntro                         ;
;----------------------------------------------------------;
AnimateIntro

	RET											; ## END of the function ##
	
;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE