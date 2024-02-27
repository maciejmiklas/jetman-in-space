;----------------------------------------------------------;
;                   #HandleJoystickInput                   ;
;----------------------------------------------------------;
HandleJoystickInput:
	; Key Up pressed ?
	LD A, KB_6_TO_0							; $EF -> A (6...0)
	IN A, (KB_REG) 							; Read keyboard input into A
	BIT 3, A								; Bit 3 reset -> Up pessed
	CALL Z, MoveUp	

	; Key Down pressed ?
	LD A, KB_6_TO_0							; $EF -> A (6...0)
	IN A, (KB_REG) 							; Read keyboard input into A
	BIT 4, A								; Bit 4 reset -> Down pessed
	CALL Z, MoveDown				

	; Key Rright pressed ?
	LD A, KB_6_TO_0							; $EF -> A (6...0)
	IN A, (KB_REG) 							; Read keyboard input into A
	BIT 2, A								; Bit 2 reset -> Rright pessed
	CALL Z, MoveRight

	; Key Left pressed ?
	LD A, KB_5_TO_1							; $FD -> A (5...1)
	IN A, (KB_REG) 							; Read keyboard input into A
	BIT 4, A								; Bit 4 reset -> Left pessed
	CALL Z, MoveLeft		

	; Key Fire (Z) pressed ?
	LD A, KB_V_TO_Z							; $FD -> A (5...1)
	IN A, (KB_REG) 							; Read keyboard input into A
	BIT 1, A								; Bit 1 reset -> Z pessed
	CALL Z, PressFire

	; Joystick up pressed ?
	LD A, JOY_MASK							; Activete joystick register
	IN A, (JOY_REG) 						; Read joystick input into A
	BIT 3, A								; Bit 3 set -> Up pessed
	CALL NZ, MoveUp

	; Joystick down pressed ?
	LD A, JOY_MASK							; Activete joystick register
	IN A, (JOY_REG) 						; Read joystick input into A
	BIT 2, A								; Bit 2 set -> Down pessed
	CALL NZ, MoveDown

	; Joystick right pressed ?
	LD A, JOY_MASK							; Activete joystick register
	IN A, (JOY_REG) 						; Read joystick input into A
	BIT 0, A								; Bit 0 set -> Right pessed
	CALL NZ, MoveRight			

	; Joystick left pressed ?
	LD A, JOY_MASK							; Activete joystick register
	IN A, (JOY_REG) 						; Read joystick input into A
	BIT 1, A								; Bit 1 set -> Left pessed
	CALL NZ, MoveLeft	

	; Joystick fire pressed ?
	LD A, JOY_MASK							; Activete joystick register
	IN A, (JOY_REG) 						; Read joystick input into A
	AND %01110000							; Any of three fires pressed?
	CALL NZ, PressFire	

	RET