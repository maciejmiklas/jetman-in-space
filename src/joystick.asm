;----------------------------------------------------------;
;                   #HandleJoystickInput                   ;
;----------------------------------------------------------;

; The counter turns off the joystick for a few iterations. Each call #HandleJoystickInput decreases it by one. 
; It's used for effects like bumping from the platform's edge or falling.
joystickDisabledCnt		BYTE 0

HandleJoystickInput

	; Handle disabled joystick
	LD A, (joystickDisabledCnt)
	CP 0
	JR Z, .afterjoystickDisabled				; Jump if joystick is not disabled -> #joystickDisabledCnt > 0

	; Joystick is disabled
	DEC A										; Decrement disabled counter
	LD (joystickDisabledCnt), A
	RET											; Do not process input, as joystick is disabled
.afterjoystickDisabled	

	CALL JoyStart
	
	; Key Up pressed ?
	LD A, KB_6_TO_0_HEF							; $EF -> A (6...0)
	IN A, (KB_REG_HFE) 							; Read keyboard input into A
	BIT 3, A									; Bit 3 reset -> Up pessed
	CALL Z, JoyMoveUp	

	; Joystick up pressed ?
	LD A, JOY_MASK_H20							; Activete joystick register
	IN A, (JOY_REG_H1F) 						; Read joystick input into A
	BIT 3, A									; Bit 3 set -> Up pessed
	CALL NZ, JoyMoveUp

	; Key Down pressed ?
	LD A, KB_6_TO_0_HEF							; $EF -> A (6...0)
	IN A, (KB_REG_HFE) 							; Read keyboard input into A
	BIT 4, A									; Bit 4 reset -> Down pessed
	CALL Z, JoyMoveDown				

	; Joystick down pressed ?
	LD A, JOY_MASK_H20							; Activete joystick register
	IN A, (JOY_REG_H1F) 						; Read joystick input into A
	BIT 2, A									; Bit 2 set -> Down pessed
	CALL NZ, JoyMoveDown

	; Key Rright pressed ?
	LD A, KB_6_TO_0_HEF							; $EF -> A (6...0)
	IN A, (KB_REG_HFE) 							; Read keyboard input into A
	BIT 2, A									; Bit 2 reset -> Rright pessed
	CALL Z, JoyMoveRight

	; Joystick right pressed ?
	LD A, JOY_MASK_H20							; Activete joystick register
	IN A, (JOY_REG_H1F) 						; Read joystick input into A
	BIT 0, A									; Bit 0 set -> Right pessed
	CALL NZ, JoyMoveRight			

	; Key Left pressed ?
	LD A, KB_5_TO_1_HF7							; $FD -> A (5...1)
	IN A, (KB_REG_HFE) 							; Read keyboard input into A
	BIT 4, A									; Bit 4 reset -> Left pessed
	CALL Z, JoyMoveLeft		

	; Joystick left pressed ?
	LD A, JOY_MASK_H20							; Activete joystick register
	IN A, (JOY_REG_H1F) 						; Read joystick input into A
	BIT 1, A									; Bit 1 set -> Left pessed
	CALL NZ, JoyMoveLeft

	; Key Fire (Z) pressed ?
	LD A, KB_V_TO_Z_HFE							; $FD -> A (5...1)
	IN A, (KB_REG_HFE) 							; Read keyboard input into A
	BIT 1, A									; Bit 1 reset -> Z pessed
	CALL Z, JoyPressFire

	; Joystick fire pressed ?
	LD A, JOY_MASK_H20							; Activete joystick register
	IN A, (JOY_REG_H1F) 						; Read joystick input into A
	AND %01110000								; Any of three fires pressed?
	CALL NZ, JoyPressFire	
	
	CALL JoyEnd

	RET											; END HandleJoystickInput