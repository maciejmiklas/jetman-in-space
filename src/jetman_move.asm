MoveUp:
	LD A, 'U'								; Print U
	CALL PrintDirection
	RET

MoveDown:
	LD A, 'D'								; Print D
	CALL PrintDirection
	
	; Update X position
	LD A, (JetX)	
	DEC A
	LD (JetX), A

	NEXTREG SPR_NR, SPR_JETMAN_ID			; Player
	NEXTREG SPR_X, A

	RET

MoveRight:
	LD A, 'R'								; Print R
	CALL PrintDirection
	RET

MoveLeft:
	LD A, 'L'								; Print L
	CALL PrintDirection
	RET	

PressFire:
	LD A, 'F'								; Print F
	CALL PrintDirection
	RET

; A - contains character to print
PrintDirection
	PUSH AF									; Keep A containing character to print
	LD A, PR_AT								; AT control character
	RST ROM_PRINT
	LD A, 1									; Y
	RST ROM_PRINT
	LD A, 15								; X
	RST ROM_PRINT
	LD A, PR_INK							; Ink colour
	RST ROM_PRINT
	LD A, 2									; Red
	RST ROM_PRINT
	POP AF									; Restore character for printing
	RST ROM_PRINT
	RET		