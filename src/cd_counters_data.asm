;----------------------------------------------------------;
;                   Global Counters                        ;
;----------------------------------------------------------;
	MODULE cd 

FLIP_ON				= 1	
FLIP_OFF			= 0

COUNTER02_MAX		= 2
counter02			BYTE 0
counter02FliFLop	BYTE 0						; Changes with evety counter run from 1 to 0 and so on

COUNTER04_MAX		= 4
counter04			BYTE 0
counter04FliFLop	BYTE 0						; Changes with evety counter run from 1 to 0 and so on

COUNTER06_MAX		= 6
counter06			BYTE 0
counter06FliFLop	BYTE 0						; Changes with evety counter run from 1 to 0 and so on

COUNTER08_MAX		= 8
counter08			BYTE 0
counter08FliFLop	BYTE 0						; Changes with evety counter run from 1 to 0 and so on

COUNTER10_MAX		= 10
counter10			BYTE 0
counter10FliFLop	BYTE 0						; Changes with evety counter run from 1 to 0 and so on

COUNTER40_MAX		= 40
counter40			BYTE 0
counter40FliFLop	BYTE 0						; Changes with evety counter run from 1 to 0 and so on

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE