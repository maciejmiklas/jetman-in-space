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
	LD A, GB_TILES_D13
	LD B, A
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
/*
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

	CALL dbs.SetupArraysBank

	; ##########################################
	LD B, 40
	LD H, 0
	LD IX, db.spriteEx01
	LD A, (IX + ep.ENP.RESPAWN_DELAY_CNT)
	LD L, A	
	CALL ut.PrintDebugNum

	; ##########################################
	LD B, 46
	LD H, 0
	LD IX, db.spriteEx02
	LD A, (IX + ep.ENP.RESPAWN_DELAY_CNT)
	LD L, A	
	CALL ut.PrintDebugNum

	; ##########################################
	LD B, 52
	LD H, 0
	LD IX, db.spriteEx03
	LD A, (IX + ep.ENP.RESPAWN_DELAY_CNT)
	LD L, A	
	CALL ut.PrintDebugNum

	; ##########################################
	LD B, 58
	LD H, 0
	LD IX, db.spriteEx04
	LD A, (IX + ep.ENP.RESPAWN_DELAY_CNT)
	LD L, A	
	CALL ut.PrintDebugNum

	; ##########################################
	LD B, 64
	LD H, 0
	LD IX, db.spriteEx05
	LD A, (IX + ep.ENP.RESPAWN_DELAY_CNT)
	LD L, A	
	CALL ut.PrintDebugNum

	; ##########################################
	LD B, 70
	LD H, 0
	LD IX, db.spriteEx06
	LD A, (IX + ep.ENP.RESPAWN_DELAY_CNT)
	LD L, A	
	CALL ut.PrintDebugNum

	; ##########################################
	LD B, 76
	LD H, 0
	LD IX, db.spriteEx07
	LD A, (IX + ep.ENP.RESPAWN_DELAY_CNT)
	LD L, A	
	CALL ut.PrintDebugNum

	; ##########################################
	LD B, 82
	LD H, 0
	LD IX, db.spriteEx08
	LD A, (IX + ep.ENP.RESPAWN_DELAY_CNT)
	LD L, A	
	CALL ut.PrintDebugNum		
*/


	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE