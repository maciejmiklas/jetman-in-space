;----------------------------------------------------------;
;                   Global Counters                        ;
;----------------------------------------------------------;
	MODULE cd 

FLIP_ON				= 1	
FLIP_OFF			= 0

COUNTER10_MAX		= 10
counter10			BYTE 0
counter10FliFLop	BYTE 0						; Changes with evety counter run from 1 to 0 and so on

COUNTER4_MAX		= 4
counter4			BYTE 0
counter4FliFLop		BYTE 0						; Changes with evety counter run from 1 to 0 and so on

COUNTER2_MAX		= 2
counter2			BYTE 0
counter2FliFLop		BYTE 0						; Changes with evety counter run from 1 to 0 and so on

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE