;----------------------------------------------------------;
;                Background Image Effects                  ;
;----------------------------------------------------------;
	MODULE bg

GROUND_LEVEL			= sc.SCR_Y_MAX_POS - 10

;----------------------------------------------------------;
;                   UpdateOnYChange                        ;
;----------------------------------------------------------;
UpdateOnYChange
	LD A, (jp.jetY)

	SRL A
	SRL A
	SRL A
	SRL A
	NEXTREG _DC_REG_L2_OFFSET_Y_H17, A

	LD B, 30
	LD H, 0
	LD L, A
	CALL tx.PrintNumHL		

	RET

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE	
