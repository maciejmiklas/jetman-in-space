;----------------------------------------------------------;
;                Joystick and Keyboard input               ;
;----------------------------------------------------------;
	MODULE in

JOY_SLOWDOWN_RET_CONT 	= 1						; Disable joystick input processing for this loop
JOY_SLOWDOWN_RET_BREAK	= 2						; Process joystick input

;----------------------------------------------------------;
;                         #JoyInput                        ;
;----------------------------------------------------------;
JoyInput
	LD A, (jd.jetState)							; Do not process movement if Jetman is dying
	CP jd.JET_STATE_RIP
	RET Z

	CALL JoySlowdown
	CP JOY_SLOWDOWN_RET_BREAK
	RET Z
	
	CALL JoyStart
	
	; Key Rright pressed ?
	LD A, _KB_6_TO_0_HEF						; $EF -> A (6...0)
	IN A, (_KB_REG_HFE)							; Read keyboard input into A
	PUSH AF										; Keep A on the stack to avoid rereading the same input
	BIT 2, A									; Bit 2 reset -> Rright pressed
	CALL Z, JoyMoveRight
	POP AF

	; Key Up pressed ?
	PUSH AF
	BIT 3, A									; Bit 3 reset -> Up pressed
	CALL Z, JoyMoveUp
	POP AF

	; Key Down pressed ?
	BIT 4, A									; Bit 4 reset -> Down pressed
	CALL Z, JoyMoveDown	

	; Joystick right pressed ?
	LD A, _JOY_MASK_H20							; Activete joystick register
	IN A, (_JOY_REG_H1F) 						; Read joystick input into A
	PUSH AF										; Keep A on the stack to avoid rereading the same input
	BIT 0, A									; Bit 0 set -> Right pressed
	CALL NZ, JoyMoveRight	
	POP AF

	; Joystick left pressed ?
	PUSH AF
	BIT 1, A									; Bit 1 set -> Left pressed
	CALL NZ, JoyMoveLeft
	POP AF

	; Joystick down pressed ?
	PUSH AF
	BIT 2, A									; Bit 2 set -> Down pressed
	CALL NZ, JoyMoveDown
	POP AF

	; Joystick fire pressed ?
	PUSH AF
	AND %01110000								; Any of three fires pressed?
	CALL NZ, JoyPressFire	
	POP AF

	; Joystick up pressed ?
	BIT 3, A									; Bit 3 set -> Up pressed
	CALL NZ, JoyMoveUp

	; Key Fire (Z) pressed ?
	LD A, _KB_V_TO_Z_HFE						; $FD -> A (5...1)
	IN A, (_KB_REG_HFE)							; Read keyboard input into A
	BIT 1, A									; Bit 1 reset -> Z pressed
	CALL Z, JoyPressFire

	; Key Left pressed ?
	LD A, _KB_5_TO_1_HF7						; $FD -> A (5...1)
	IN A, (_KB_REG_HFE)							; Read keyboard input into A
	BIT 4, A									; Bit 4 reset -> Left pressed
	CALL Z, JoyMoveLeft		

	CALL JoyEnd

	RET											; END JoyInput

;----------------------------------------------------------;
;                     JoySlowdown                          ;
;----------------------------------------------------------;
JoySlowdown
	CALL jt.JoySlowdown

	RET

;----------------------------------------------------------;
;                        JoyStart                          ;
;----------------------------------------------------------;
JoyStart
	CALL jt.JoyStart

	RET

;----------------------------------------------------------;
;                         JoyEnd                           ;
;----------------------------------------------------------;
JoyEnd
	CALL jt.JoyEnd

	RET

;----------------------------------------------------------;
;                      JoyMoveRight                        ;
;----------------------------------------------------------;
JoyMoveRight
	CALL jt.JoyMoveRight

	RET

;----------------------------------------------------------;
;                      JoyMoveLeft                         ;
;----------------------------------------------------------;
JoyMoveLeft
	CALL jt.JoyMoveLeft

	RET

;----------------------------------------------------------;
;                        JoyMoveUp                         ;
;----------------------------------------------------------;
JoyMoveUp
	CALL jt.JoyMoveUp

	RET

;----------------------------------------------------------;
;                       JoyMoveDown                        ;
;----------------------------------------------------------;
JoyMoveDown
	CALL jt.JoyMoveDown

	RET

;----------------------------------------------------------;
;                      JoyPressFire                        ;
;----------------------------------------------------------;
JoyPressFire
	CALL jt.JoyPressFire

	RET

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE