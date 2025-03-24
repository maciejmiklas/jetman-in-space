;----------------------------------------------------------;
;                       Level Data                         ;
;----------------------------------------------------------;
	MODULE ll

;----------------------------------------------------------;
;                    #LoadLevel1Data                       ;
;----------------------------------------------------------;
LoadLevel1Data

	; Load palettes
	CALL bs.SetupPaletteBank
	
	; Load palette size into a global variable.
	LD HL, db.bgrL1PaletteBytes
	LD (btd.palBytes), HL

	; Load the address of the original palette into a global variable.
	LD HL, db.bgrL1PaletteAdr
	LD (btd.palAdr), HL

	CALL btd.CreateTodPalettes

	; ##########################################
	; Load background image

	; Load the address of the image into a global variable. LoadImage will be called on #RespawnJet
	LD A, $$db.bgrImgL1
	LD (bm.imageBank), A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #LoadLevel2Data                         ;
;----------------------------------------------------------;
LoadLevel2Data

	; Load palettes
	CALL bs.SetupPaletteBank

	; Load palette size into a global variable.
	LD HL, db.bgrL2PaletteBytes
	LD (btd.palBytes), HL

	; Load the address of the original palette into a global variable.
	LD HL, db.bgrL2PaletteAdr
	LD (btd.palAdr), HL

	CALL btd.CreateTodPalettes

	; ##########################################
	; Load background image

	; Load the address of the image into a global variable. LoadImage will be called on #RespawnJet
	LD A, $$db.bgrImgL2
	LD (bm.imageBank), A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #LoadLevel3Data                         ;
;----------------------------------------------------------;
LoadLevel3Data

	; Load palettes
	CALL bs.SetupPaletteBank

	; Load palette size into a global variable.
	LD HL, db.bgrL3PaletteBytes
	LD (btd.palBytes), HL

	; Load the address of the original palette into a global variable.
	LD HL, db.bgrL3PaletteAdr
	LD (btd.palAdr), HL

	CALL btd.CreateTodPalettes

	; ##########################################
	; Load background image

	; Load the address of the image into a global variable. LoadImage will be called on #RespawnJet
	LD A, $$db.bgrImgL3
	LD (bm.imageBank), A
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #LoadLevel4Data                         ;
;----------------------------------------------------------;
LoadLevel4Data

	; Load palettes
	CALL bs.SetupPaletteBank

	; Load palette size into a global variable.
	LD HL, db.bgrL4PaletteBytes
	LD (btd.palBytes), HL

	; Load the address of the original palette into a global variable.
	LD HL, db.bgrL4PaletteAdr
	LD (btd.palAdr), HL

	CALL btd.CreateTodPalettes

	; ##########################################
	; Load background image

	; Load the address of the image into a global variable. LoadImage will be called on #RespawnJet
	LD A, $$db.bgrImgL4
	LD (bm.imageBank), A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #LoadLevel5Data                         ;
;----------------------------------------------------------;
LoadLevel5Data

	; Load palettes
	CALL bs.SetupPaletteBank

	; Load palette size into a global variable.
	LD HL, db.bgrL5PaletteBytes
	LD (btd.palBytes), HL

	; Load the address of the original palette into a global variable.
	LD HL, db.bgrL5PaletteAdr
	LD (btd.palAdr), HL

	CALL btd.CreateTodPalettes

	; ##########################################
	; Load background image

	; Load the address of the image into a global variable. LoadImage will be called on #RespawnJet
	LD A, $$db.bgrImgL5
	LD (bm.imageBank), A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #LoadLevel6Data                         ;
;----------------------------------------------------------;
LoadLevel6Data

	; Load palettes
	CALL bs.SetupPaletteBank

	; Load palette size into a global variable.
	LD HL, db.bgrL6PaletteBytes
	LD (btd.palBytes), HL

	; Load the address of the original palette into a global variable.
	LD HL, db.bgrL6PaletteAdr
	LD (btd.palAdr), HL

	CALL btd.CreateTodPalettes

	; ##########################################
	; Load background image

	; Load the address of the image into a global variable. LoadImage will be called on #RespawnJet
	LD A, $$db.bgrImgL6
	LD (bm.imageBank), A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #LoadLevel7Data                         ;
;----------------------------------------------------------;
LoadLevel7Data

	; Load palettes
	CALL bs.SetupPaletteBank

	; Load palette size into a global variable.
	LD HL, db.bgrL7PaletteBytes
	LD (btd.palBytes), HL

	; Load the address of the original palette into a global variable.
	LD HL, db.bgrL7PaletteAdr
	LD (btd.palAdr), HL

	CALL btd.CreateTodPalettes

	; ##########################################
	; Load background image

	; Load the address of the image into a global variable. LoadImage will be called on #RespawnJet
	LD A, $$db.bgrImgL7
	LD (bm.imageBank), A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #LoadLevel8Data                         ;
;----------------------------------------------------------;
LoadLevel8Data

	; Load palettes
	CALL bs.SetupPaletteBank
	
	; Load palette size into a global variable.
	LD HL, db.bgrL8PaletteBytes
	LD (btd.palBytes), HL

	; Load the address of the original palette into a global variable.
	LD HL, db.bgrL8PaletteAdr
	LD (btd.palAdr), HL

	CALL btd.CreateTodPalettes

	; ##########################################
	; Load background image

	; Load the address of the image into a global variable. LoadImage will be called on #RespawnJet
	LD A, $$db.bgrImgL8
	LD (bm.imageBank), A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #LoadLevel9Data                         ;
;----------------------------------------------------------;
LoadLevel9Data

	; Load palettes
	CALL bs.SetupPaletteBank

	; Load palette size into a global variable.
	LD HL, db.bgrL9PaletteBytes
	LD (btd.palBytes), HL

	; Load the address of the original palette into a global variable.
	LD HL, db.bgrL9PaletteAdr
	LD (btd.palAdr), HL

	CALL btd.CreateTodPalettes

	; ##########################################
	; Load background image

	; Load the address of the image into a global variable. LoadImage will be called on #RespawnJet
	LD A, $$db.bgrImgL9
	LD (bm.imageBank), A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #LoadLevel10Data                        ;
;----------------------------------------------------------;
LoadLevel10Data

	; Load palettes
	CALL bs.SetupPaletteBank

	; Load palette size into a global variable.
	LD HL, db.bgrL10PaletteBytes
	LD (btd.palBytes), HL

	; Load the address of the original palette into a global variable.
	LD HL, db.bgrL10PaletteAdr
	LD (btd.palAdr), HL

	CALL btd.CreateTodPalettes

	; ##########################################
	; Load background image

	; Load the address of the image into a global variable. LoadImage will be called on #RespawnJet
	LD A, $$db.bgrImgL10
	LD (bm.imageBank), A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE
