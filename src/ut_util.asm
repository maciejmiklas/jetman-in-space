;----------------------------------------------------------;
;                          Utils                           ;
;----------------------------------------------------------;
	MODULE ut

;----------------------------------------------------------;
;                          AbsHL                           ;
;----------------------------------------------------------;
; http://z80-heaven.wikidot.com/math#toc12
AbsHL
	BIT 7, H
	RET Z
	XOR A
	SUB L 
	LD L, A
	SBC A, A 
	SUB H 
	LD H, A
	
	RET

;----------------------------------------------------------;
;                          AbsA                            ;
;----------------------------------------------------------;
AbsA
	OR A
	RET P
	NEG
	RET	
;----------------------------------------------------------;
;                       #HlEqualB                          ;
;----------------------------------------------------------;
HL_IS_B					= 0
HL_NOT_B				= 1
; Input:
;  - HL:		Value to compare to B
;  - B:			Value to compare to HL
; Return:
;  - A:		HL_IS_0 or HL_NOT_0
HlEqualB
	LD A, H										; Check H if == 0
	CP B
	JR NZ, .notEqual							; H == 0
	LD A, L										; Check L if == 0
	CP B
	JR NZ, .notEqual							; L == 0
	
	; H == 0 and L == 0
	LD A, HL_IS_B
	RET												
	
.notEqual
	LD A, HL_NOT_B

	RET

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