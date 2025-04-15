;----------------------------------------------------------;
;                         Game Bar                         ;
;----------------------------------------------------------;
	MODULE gb 

GB_VISIBLE				= 1
GB_HIDDEN				= 0
GB_TILES_D13			= 320 / 8 * 3

gamebarState			BYTE GB_VISIBLE
refreshCnt 				BYTE 0
;----------------------------------------------------------;
;                    #HideGameBar                          ;
;----------------------------------------------------------;
HideGameBar

	; Update state
	LD A, GB_HIDDEN
	LD (gamebarState), A

	; ##########################################
	; Remove gamebar from screen.
	LD B, GB_TILES_D13
	CALL ti.CleanTiles

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                    #ShowGameBar                          ;
;----------------------------------------------------------;
ShowGameBar

	; Update state
	LD A, GB_VISIBLE
	LD (gamebarState),A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                     #PrintDebug                          ;
;----------------------------------------------------------;
PrintDebug
	
	; Return if gamebar is hidden.
	LD A, (gamebarState)
	CP GB_VISIBLE
	RET NZ

	; ##########################################
	LD B, 40
	LD H, 0
	LD A, (jpo.jetX)
	LD L, A	
	CALL ut.PrintDebugNum

	; ##########################################
	LD B, 46
	LD H, 0
	LD A, (jpo.jetY)
	LD L, A	
	CALL ut.PrintDebugNum

	; ##########################################
	LD B, 80
	LD H, 0
	LD A, (jt.jetState)
	LD L, A	
	CALL ut.PrintDebugNum

	; ##########################################
	LD B, 86
	LD H, 0
	LD A, (jo.jetHeatCnt)
	LD L, A	
	CALL ut.PrintDebugNum

	; ##########################################
	LD B, 92
	LD H, 0
	LD A, (jo.jetCoolCnt)
	LD L, A	
	CALL ut.PrintDebugNum	

	; ##########################################
	LD B, 98
	LD H, 0
	LD A, (jo.jetTempLevel)
	LD L, A	
	CALL ut.PrintDebugNum


	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE