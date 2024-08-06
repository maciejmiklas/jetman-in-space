;----------------------------------------------------------;
;                          Utils                           ;
;----------------------------------------------------------;
	MODULE ut

;----------------------------------------------------------;
;                           #Pause                         ;
;----------------------------------------------------------;
; Input:
;  - DE:		Delay factor
Pause
	PUSH BC
	PUSH HL
.start

	LD HL, 65000
.loop:
	DEC HL										; DEC HL from 65000 to 0
	LD A, H
	CP 0

	CALL CountdownBC
	CALL CountdownBC
	CALL CountdownBC
	JP NZ,.loop

	; Count down DE
	DEC BC
	LD A, B
	CP 0
	JP NZ,.start
	
	POP HL
	POP BC
	RET

;----------------------------------------------------------;
;                       #CountdownBC                       ;
;----------------------------------------------------------;
CountdownBC
	LD BC, 65000
.loop:
	PUSH BC										; few ops just for delay
	PUSH HL
	
	POP HL
	POP BC

	DEC BC										; DEC BC from 65000 to 0
	LD A, B
	CP 0
	JP NZ,.loop

	RET

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE