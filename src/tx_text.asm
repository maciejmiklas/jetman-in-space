;----------------------------------------------------------;
;                        Text on Screen                    ;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                        #TxPrintNumHL                     ;
;----------------------------------------------------------;
; Print 16 bit numer from HL. Each character takes 8x8 pixels
; Method Parameters:
;  - IN: HL = 16-bit number to print
;        B - Character offset from top left corner. Each character takes 8 pixels, screen can contain 40x23 characters. 
;            For B=5 -> First characters starts at 5x8 in first line, for B=41 first charactes starts in second line.	 
TxPrintNumHL

	; Print number from HL into formatted16
	PUSH BC
	LD DE, formatted16
	CALL TxNum16ToString
	POP BC

	; Print text from formatted16 on screen using tiles
	LD DE, formatted16							; Contains 16-bit number as ASCII
	LD C, B										; C - Character offset from top left corner.
	LD B, 5										; Print 5 characters
	CALL TiPrintText

	RET

formatted16
	DB "00000"									; Contains a number formatted into a string

;----------------------------------------------------------;
;                     #TxNum16ToString                     ;
;----------------------------------------------------------;
; Converts a given 16-bit number into a 5-character string with padding zeros. 
; Method Parameters:
;   - IN:  HL = 16-bit number to convert
;   - OUT: ASCII string at DE, 5-charactes long, 0 padded.
TxNum16ToString

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