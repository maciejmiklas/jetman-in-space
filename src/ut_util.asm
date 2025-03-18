;----------------------------------------------------------;
;                          Utils                           ;
;----------------------------------------------------------;
	MODULE ut

;----------------------------------------------------------;
;                          CdivD                           ;
;----------------------------------------------------------;
; http://z80-heaven.wikidot.com/math#toc12
CdivD

; Input:
;  - C: numerator
;  - D: denominator
; Output:
;  - A: remainder
;  - C: result C/D
	LD B,8
	XOR A
	SLA C
	RLA
	CP D
	JR C, $+4
	INC C
	SUB D
	DJNZ $-8

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                          AbsDE                           ;
;----------------------------------------------------------;
; http://z80-heaven.wikidot.com/math#toc12
AbsDE

	BIT 7, D
	RET Z
	XOR A
	SUB E 
	LD E, A
	SBC A, A 
	SUB D 
	LD D, A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                          AbsBC                           ;
;----------------------------------------------------------;
; http://z80-heaven.wikidot.com/math#toc12
AbsBC

	BIT 7, B
	RET Z
	XOR A 
	SUB C 
	LD C, A
	SBC A, A
	SUB B
	LD B, A

	RET											; ## END of the function ##
	
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
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                          AbsA                            ;
;----------------------------------------------------------;
AbsA

	OR A
	RET P
	NEG
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                    PrintNumHLDebug                       ;
;----------------------------------------------------------;
; Print 16 bit number from HL. Each character takes 8x8 pixels.
;Input:
;  - HL:	16-bit number to print.
;  - B:		Character offset from top left corner. Each character takes 8 pixels, screen can contain 40x23 characters.
;           For B=5 -> First characters starts at 40px (5*8) in first line, for B=41 first characters starts in second line.
PrintNumHLDebug

	PUSH BC, DE, IX, IY
	
	CALL tx.PrintNumHL
	
	POP IY, IX, DE, BC
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       #HlEqualB                          ;
;----------------------------------------------------------;
; Check if both H and L are equal to B.
HL_IS_B					= 0
HL_NOT_B				= 1
; Input:
;  - HL:	Value to compare to B.
;  - B:		Value to compare to HL.
; Return:
;  - A:		#HL_IS_0 or #HL_NOT_0
HlEqualB

	LD A, H										; Check if H == B
	CP B
	JR NZ, .notEqual							; Jump if H != B
	LD A, L										; Check if L == B
	CP B
	JR NZ, .notEqual							; Jump if L == B
	
	; H == B and L == B
	LD A, HL_IS_B
	RET												
	
.notEqual
	LD A, HL_NOT_B

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       #PauseShort                        ;
;----------------------------------------------------------;
PauseShort

	CALL CountdownBC
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                         #Pause                           ;
;----------------------------------------------------------;
Pause

	PUSH AF, BC, DE, HL, IX, IY

	LD A, _UT_PAUSE_TIME_D10
.loop:
	CALL CountdownBC

	DEC A
	CP 0
	JP NZ, .loop

	POP IY, IX, HL, DE, BC, AF

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       #CountdownBC                       ;
;----------------------------------------------------------;
CountdownBC

	PUSH AF, BC, DE, HL, IX, IY

	LD BC, 65000
.loop:
	DEC BC										; DEC BC from 65000 to 0
	LD A, B
	CP 0
	JP NZ,.loop

	POP IY, IX, HL, DE, BC, AF

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                        #FillBank                         ;
;----------------------------------------------------------;
; Input:
;  - A:  Destination bank.
;  - D:  Value to fill banks with.
;  - HL: Start address.
; Modifies: AF,BC,HL
FillBank

	LD BC, _BANK_BYTES_D8192					; 8192 bytes is a full bank.
.loop
	LD (HL), D
	INC HL
	DEC BC

	; Check if BC is 0. OR returns 0 when both params are 0, it also sets ZF.
	LD A, B
	OR C
	JR NZ, .loop								; Keep looping if ZF is not set (BC != 0).

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE