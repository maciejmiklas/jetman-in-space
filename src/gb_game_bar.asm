;----------------------------------------------------------;
;                         Game Bar                         ;
;----------------------------------------------------------;
	MODULE gb 

GB_ST_VISIBLE			= 1
GB_ST_HIDDEN			= 0

gamebarState			BYTE GB_ST_VISIBLE
refreshCnt 				BYTE 0
;----------------------------------------------------------;
;                    #HideGameBar                          ;
;----------------------------------------------------------;
HideGameBar
	RET ; TODO
	; Update state
	LD A, GB_ST_HIDDEN
	LD (gamebarState), A

	; ##########################################
	; Remove gamebar from screen.
	LD B, _C_GB_TILES_D13
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
	
	; Return if gamebar is hidden.
	LD A, (gamebarState)
	CP GB_ST_VISIBLE
	RET NZ


	; ##########################################
	LD B, 40
	LD H, 0
	LD A, (jpo.jetX)
	LD L, A	
	CALL ut.PrintNumHLDebug

	; ##########################################
	LD B, 46
	LD H, 0
	LD A, (jpo.jetY)
	LD L, A	
	CALL ut.PrintNumHLDebug


	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE