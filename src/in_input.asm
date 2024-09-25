;----------------------------------------------------------;
;                Joystick and Keyboard input               ;
;----------------------------------------------------------;
	MODULE in

;----------------------------------------------------------;
;                         #JoyInput                        ;
;----------------------------------------------------------;
JoyInput
	CALL JoySlowdown
	CP JOY_SL_RET_JOY_OFF
	RET Z
	
	CALL JoyDisabled
	CP JOY_DIS_RET_JOY_OFF
	RET Z

	LD A, (jt.jetState)
	BIT jt.JET_STATE_RIP_BIT, A
	RET NZ										; Do not process input if Jetman is dying

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
;                       #JoySlowdown                       ;
;----------------------------------------------------------;
; Slow down joystick input and, therefore, speed of Jetman movement
; Input:
; Output:
;	A containing one of the values given by #JOY_SL_RET_JOY_XXX
JOY_SL_RET_JOY_ON 		= 1						; Process joystick input
JOY_SL_RET_JOY_OFF		= 2						; Disable joystick input processing for this loop

JoySlowdown
	LD A, (id.joyDelayCnt)
	INC A
	LD (id.joyDelayCnt), A

	CP id.JOY_DELAY
	JR Z, .delayReached

	LD A, JOY_SL_RET_JOY_OFF					; Return because #joyDelayCnt !=  #JOY_DELAY
	RET
.delayReached									; Delay counter has been reached	

	XOR A										; Set A to 0						
	LD (id.joyDelayCnt), A						; Reset delay counter

	LD A, JOY_SL_RET_JOY_ON						; Process input, because counter has been reached
	RET

;----------------------------------------------------------;
;                       #JoyDisabled                       ;
;----------------------------------------------------------;
; Disable joystick and, therefore, controle over the Jetman 
; Output:
;	A containing one of the values given by #JOY_DIS_RET_JOY_XXX
JOY_DIS_RET_JOY_ON 		= 1						; Process joystick input
JOY_DIS_RET_JOY_OFF		= 2						; Disable joystick input processing for this loop

JoyDisabled

	; Joystic disabled if flying rocket
	LD A, (jt.jetAir)
	CP jt.AIR_FLY_ROCKET
	JR NZ, .notFlying

	; Do not process input, flying rocket
	LD A, JOY_DIS_RET_JOY_OFF
	RET
.notFlying	

	LD A, (id.joyDisabledCnt)
	CP 0
	JR Z, .afterjoystickDisabled				; Jump if joystick is enabled -> #joyDisabledCnt > 0

	; Joystick is disabled
	DEC A										; Decrement disabled counter
	LD (id.joyDisabledCnt), A

	LD A, JOY_DIS_RET_JOY_OFF
	RET											; Do not process input, as the joystick is disabled

.afterjoystickDisabled							; Process input
	LD A, JOY_DIS_RET_JOY_ON
	RET

;----------------------------------------------------------;
;                        JoyStart                          ;
;----------------------------------------------------------;
JoyStart
	CALL jm.JoyStart

	RET

;----------------------------------------------------------;
;                         JoyEnd                           ;
;----------------------------------------------------------;
JoyEnd
	CALL jm.JoyEnd

	RET

;----------------------------------------------------------;
;                      JoyMoveRight                        ;
;----------------------------------------------------------;
JoyMoveRight
	CALL jm.JoyMoveRight

	RET

;----------------------------------------------------------;
;                      JoyMoveLeft                         ;
;----------------------------------------------------------;
JoyMoveLeft
	CALL jm.JoyMoveLeft

	RET

;----------------------------------------------------------;
;                        JoyMoveUp                         ;
;----------------------------------------------------------;
JoyMoveUp
	CALL jm.JoyMoveUp

	RET

;----------------------------------------------------------;
;                       JoyMoveDown                        ;
;----------------------------------------------------------;
JoyMoveDown
	CALL jm.JoyMoveDown

	RET

;----------------------------------------------------------;
;                      JoyPressFire                        ;
;----------------------------------------------------------;
JoyPressFire
	CALL jw.Fire

	RET

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE