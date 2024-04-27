;----------------------------------------------------------;
;                          #UtPause                        ;
;----------------------------------------------------------;
; Params
; D - delay factor
UtPause
	PUSH BC
.start
    LD BC, 0
.loop:
	BIT 0, A
	AND A, 255
	DEC BC
	LD A,C
	OR A,B
	JP NZ,.loop
	DEC D
	LD A, D	
	JP NZ,.start
	POP BC
	RET