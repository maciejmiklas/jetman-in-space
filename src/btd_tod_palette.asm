;----------------------------------------------------------;
;                  Tinme of Day Palette                    ;
;----------------------------------------------------------;
	MODULE btd
	
; TOD - Time of Day
palBytes				WORD 0					; Size in bytes of background palette, max 512.
palColors				BYTE 0					; Amount of colors in background palette, max 255.
palAdr					WORD 0					; Address of the orginal palette data.
todPalAddr 				WORD 0					; Pointer to current brightness palette.

;----------------------------------------------------------;
;                     #NextTodPalette                      ;
;----------------------------------------------------------;
NextTodPalette
	
	LD HL, (todPalAddr)
	LD A, (palColors)
	LD B, A	
	PUSH HL
	CALL bp.LoadColors
	CALL gc.BackgroundPaletteLoaded
	POP HL

	; Moves #todPalAddr to the next palette
	ADD HL, _BM_PAL2_BYTES_D512
	LD (todPalAddr), HL
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                     #PrevTodPalette                      ;
;----------------------------------------------------------;
PrevTodPalette
	
	LD HL, (todPalAddr)
	LD A, (palColors)
	LD B, A
	CALL bp.LoadColors
	CALL gc.BackgroundPaletteLoaded

	CALL PrevTodPaletteAddr
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                   #PrevTodPaletteAddr                    ;
;----------------------------------------------------------;
PrevTodPaletteAddr
	
	; Moves #todPalAddr to the previous palette
	LD HL, (todPalAddr)	
	ADD HL, -_BM_PAL2_BYTES_D512
	LD (todPalAddr), HL

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                 #LoadCurrentTodPalette                   ;
;----------------------------------------------------------;
LoadCurrentTodPalette
	
	CALL bp.SetupPaletteLoad

	LD HL, (palAdr)
	LD A, (palColors)
	LD B, A	
	CALL bp.WriteColors

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #LoadLevelPalette                       ;
;----------------------------------------------------------;
; Method called after settgin: #palBytes and #palAdr
LoadLevelPalette

	CALL _VariablesSet							; Palette global variables are set.
	CALL _LoadTodPalette						; Load orginal palette into hardware.
	CALL _CreateTodPalettes						; Create palettes for different times of day.
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #ResetPaletteArrd                       ;
;----------------------------------------------------------;
ResetPaletteArrd

	CALL bp.SetupPaletteBank
	
	; Set the palette address to the beginning of the bank holding it.
	LD DE, dbi.todL2Palettes
	LD (todPalAddr), DE

	RET											; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                 #_CreateTodPalettes                      ;
;----------------------------------------------------------;
; This function creates up to 6 palettes for the transition from day to night from the palette given by HL.
; Palettes are stored in #todL2Palettes; each one has 512 bytes. #todPalAddr points to the first palette.
; Palettes are stored in: $E000,$E200,$E400,$E600,$E800,$EA000
_CreateTodPalettes

	CALL bp.SetupPaletteLoad

	; ##########################################
	; Copy the original palette into the address given by #todPalAddr, creating the first palette to be modified by the loop below.

	; Set the palette address to the beginning of the bank holding it, and copy initial palette.
	LD HL, (palAdr)
	LD BC, (palColors)
	CALL ResetPaletteArrd						; Sets bank and DE as destination for LDIR
	LDIR										; HL (source) and BC (amount) are method params

	; ##########################################
	; Copy remaining palettes.

	LD B, _TOD_STEPS_D4							
.copyLoop
	PUSH BC

	CALL _DecrementPaletteColors
	CALL _NextBrightnessPalette

	POP BC
	DJNZ .copyLoop

	; ##########################################
	;Reset palette pointer
	CALL ResetPaletteArrd

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                    #_VariablesSet                        ;
;----------------------------------------------------------;
; Method called after settgin: #palBytes and #palAdr
_VariablesSet

	; Set #palColors from #palBytes
	LD BC, (palBytes)
	CALL bp.BytesToColors
	LD A, B
	LD (palColors), A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;              #_NextBrightnessPalette                     ;
;----------------------------------------------------------;
; Moves #todPalAddr to the next palette and copies the previous palette there.
_NextBrightnessPalette

	; ##########################################
	; Moves #todPalAddr to the next palette 
	LD HL, (todPalAddr)							; Use HL for LDIR below.
	LD DE, HL
	ADD DE, _BM_PAL2_BYTES_D512					; Move DE to the next (destination) palette.
	LD (todPalAddr), DE							; Move palette pointer to copied palette.

	; ##########################################
	; Copy current palette to new addres given by #todPalAddr
	LD BC, (palBytes)							; Number of bytes to be copied by LDIR
	LDIR										; Copy palette from HL to DE

	RET											; ## END of the function ##
	
;----------------------------------------------------------;
;                #_DecrementPaletteColors                  ;
;----------------------------------------------------------;
; This function will decrease palette brighteners given by #todPalAddr.
_DecrementPaletteColors

	; ##########################################
	; Copy 9 bit (2 bytes per color) palette
	LD HL, (todPalAddr)							; The address of current palette set by #_NextBrightnessPalette.

	LD A, (palColors)
	LD B, A
.loopColor
	PUSH BC

	; ##########################################
	; Decrement the brightness of the current color.
	LD DE, (HL)									; DE contains color that will be changed.
	CALL bp.BrightnessDown
	LD (HL), DE									; Update temp color.
	INC HL
	INC HL

	POP BC
	DJNZ .loopColor

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                    #_LoadTodPalette                      ;
;----------------------------------------------------------;
_LoadTodPalette

	CALL bp.SetupPaletteLoad

	; ##########################################
	; Copy 9 bit (2 bytes per color) palette. Nubmer of colors is giveb by B (method param).
	LD A, (palColors)							; Number of colors/iterations.
	LD B, A

	LD HL, (palAdr)								; Address of the palette.
.loopCopyColor
	
	; 1st write
	LD A, (HL)
	LD E, A
	INC HL

	; 2nd write
	LD A, (HL)
	LD D, A
	INC HL
	CALL bp.WriteColor

	DJNZ .loopCopyColor

	CALL gc.BackgroundPaletteLoaded
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE
