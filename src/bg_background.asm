;----------------------------------------------------------;
;                Background Image Effects                  ;
;----------------------------------------------------------;
	MODULE bg


;----------------------------------------------------------;
;                   UpdateOnJetmanMove                     ;
;----------------------------------------------------------;
UpdateOnJetmanMove

	; Horizontal movement
	LD A, (jo.jetY)

	; Divide position to limit movement
	LD C, A
	LD D, 3
	CALL ut.CdivD
	LD A, C
	NEXTREG _DC_REG_L2_OFFSET_Y_H17, A

	RET
	
;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE	
