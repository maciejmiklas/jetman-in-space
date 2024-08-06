;----------------------------------------------------------;
;                      Common Data                         ;
;----------------------------------------------------------;
	MODULE dc 

FLIP_ON				= 1	
FLIP_OFF			= 0

COUNTER10_MAX		= 10
counter10			BYTE 0
counter10FliFLop	BYTE 0						; Changes with evety counter run from 1 to 0 and so on

COUNTER5_MAX		= 5
counter5			BYTE 0
counter5FliFLop		BYTE 0						; Changes with evety counter run from 1 to 0 and so on

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE