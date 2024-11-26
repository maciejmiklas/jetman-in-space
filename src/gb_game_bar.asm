;----------------------------------------------------------;
;                         Game Bar                         ;
;----------------------------------------------------------;
	MODULE gb 

GB_ST_VISIBLE			= 1
GB_ST_HIDDEN			= 0

gamebarState	BYTE GB_ST_VISIBLE
;----------------------------------------------------------;
;                    #HideGameBar                          ;
;----------------------------------------------------------;
HideGameBar
	RET ; TODO
	; Update state
	LD A, GB_ST_HIDDEN
	LD (gamebarState), A

	; ##########################################
	; Remove gamebar from screen
	LD B, _CF_GB_TILES
	CALL ti.CleanTiles

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                    #HideGameBar                          ;
;----------------------------------------------------------;
ShowGameBar

	; Update state
	LD A, GB_ST_VISIBLE
	LD (gamebarState),A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                     #PrintDebug                          ;
;----------------------------------------------------------;
PrintDebug

	; Return if gabebar is hidden
	LD A, (gamebarState)
	CP GB_ST_VISIBLE
	RET NZ

	; ##########################################
	LD B, 0
	LD HL, (jpo.jetX)
	CALL ut.PrintNumHLDebug

	; ##########################################
	LD B, 6
	LD H, 0
	LD A, (jpo.jetY)
	LD L, A
	CALL ut.PrintNumHLDebug

	; ##########################################
	LD B, 12
	LD H, 0
	LD A, (ro.rocketState)
	LD L, A
	CALL ut.PrintNumHLDebug

	; ##########################################
	LD B, 18
	LD H, 0
	LD A, (jt.jetGnd)
	LD L, A
	CALL ut.PrintNumHLDebug

	; ##########################################
	LD B, 24
	LD H, 0
	LD A,  (jt.jetGnd)
	LD L, A
	CALL ut.PrintNumHLDebug

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE


	