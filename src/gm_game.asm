;----------------------------------------------------------;
;                        Main Game                         ;
;----------------------------------------------------------;
	MODULE gm 

;----------------------------------------------------------;
;                      #GameInit                           ;
;----------------------------------------------------------;
GameInit

	CALL gc.RespawnJet
	CALL ro.StartRocketAssembly

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                      #GameLoop                           ;
;----------------------------------------------------------;
	//DEFINE  PERFORMANCE_BORDER 

GameLoop

	IFDEF PERFORMANCE_BORDER
		LD	A, _COL_GREEN_D4
		OUT (_BORDER_IO_HFE), A
	ENDIF

	CALL sc.WaitForScanline

	IFDEF PERFORMANCE_BORDER
		LD	A, _COL_RED_D2
		OUT (_BORDER_IO_HFE), A
	ENDIF	

	CALL gl.GameLoop

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE