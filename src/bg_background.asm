;----------------------------------------------------------;
;                Background Image Effects                  ;
;----------------------------------------------------------;
	MODULE bg

;----------------------------------------------------------;
;             UpdateBackgroundOnJetmanMove                 ;
;----------------------------------------------------------;
UpdateBackgroundOnJetmanMove

	; Horizontal movement
	LD A, (jpo.jetY)

	; Divide position to limit movement
	LD C, A
	LD D, 3
	CALL ut.CdivD
	LD A, C
	NEXTREG _DC_REG_L2_OFFSET_Y_H17, A

	RET											; ## END of the function ##
	
;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE	
