;----------------------------------------------------------;
;                         #PrintNumHL                      ;
;----------------------------------------------------------;
formatted16:
	DB "00000"									; Contains a number formatted into a string

; Print 16 bit numer from HL  
; Params:
PrintNumHL
	LD DE, formatted16							; Point to output buffor.
	CALL num16ToString						

	; Text is formatted and stored at the Label: "formatted16", now it's time to show it on the monitor.
	LD A, PR_AT_H16								; AT control character
	RST ROM_PRINT_H10

	LD A, 0										; Y text coordinate (row)
	RST ROM_PRINT_H10

	LD A, 12									; X text coordinate (collumn)
	RST ROM_PRINT_H10

	LD A, PR_INK_H10							; Set ink color
	RST ROM_PRINT_H10
	LD A, COL_RED
	RST ROM_PRINT_H10

	LD A, PR_PAPER_H11							; Set paper color
	RST ROM_PRINT_H10
	LD A, COL_GREEN
	RST ROM_PRINT_H10

	; Print label: "formatted16" on display 
	LD DE, formatted16							; The RAM address containing the text to be printed.
	LD BC, 5									; Contains the number of characters to be printed.
	CALL ROM_PRINT_TEXT_H203C

	RET

;----------------------------------------------------------;
;                      #num16ToString                      ;
;----------------------------------------------------------;
; Converts a given 16-bit number into a 5-character string with padding zeros. 
; IN:  HL = 16-bit number to convert.
; OUT: ASCII string at DE, 5-charactes long, 0 padded.
num16ToString

	; Each line prints one digit into DE, starting with the most significant. 
	ld	BC, -10000						
	CALL .format

	LD	BC, -1000
	CALL .format

	LD	BC, -100
	CALL .format

	LD	C, -10
	CALL .format

	LD	C, B									; Last, the rightmost digit.

.format
	LD	A, '0'-1								; Load ASCI code for 0.
.loop 
	INC A
	ADD	HL, BC									; Substract (add negative) given number from input number

	; Keep looping and subtracting until the carry bit is set. 
	; It happens when subtracting resets the most significant number, i.e., 1234 -> 0123.
	JR	C, .loop
	
	SUB	HL, BC									; ADD above caused an overflow. Subsctract will turn the value one step back, ie: 59857 -> 4321 for input: 54321
	LD (DE), A									; A contains the ASCII value of the most significant number, store it in DE.
	INC DE										; Move DE offset to the next position to store next number
	RET