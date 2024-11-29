;----------------------------------------------------------;
;                Joystick and Keyboard input               ;
;----------------------------------------------------------;
	MODULE in

;----------------------------------------------------------;
;                         #JoyInput                        ;
;----------------------------------------------------------;
JoyInput

	LD A, ind.MOVE_INACTIVE						; Update #jetState by resetting left/hover and setting right
	LD (ind.joyDirection), A

	; ##########################################	
	; Key Rright pressed ?
	LD A, _KB_6_TO_0_HEF						; $EF -> A (6...0)
	IN A, (_KB_REG_HFE)							; Read keyboard input into A
	PUSH AF										; Keep A on the stack to avoid rereading the same input
	BIT 2, A									; Bit 2 reset -> Rright pressed
	CALL Z, JoyRight
	POP AF

	; ##########################################
	; Key Up pressed ?
	PUSH AF
	BIT 3, A									; Bit 3 reset -> Up pressed
	CALL Z, JoyUp
	POP AF
	
	; ##########################################
	; Key Down pressed ?
	BIT 4, A									; Bit 4 reset -> Down pressed
	CALL Z, JoyDown

	; ##########################################
	; Joystick right pressed ?
	LD A, _JOY_MASK_H20							; Activete joystick register
	IN A, (_JOY_REG_H1F) 						; Read joystick input into A
	PUSH AF										; Keep A on the stack to avoid rereading the same input
	BIT 0, A									; Bit 0 set -> Right pressed
	CALL NZ, JoyRight	
	POP AF

	; ##########################################
	; Joystick left pressed ?
	PUSH AF
	BIT 1, A									; Bit 1 set -> Left pressed
	CALL NZ, JoyLeft
	POP AF

	; ##########################################
	; Joystick down pressed ?
	PUSH AF
	BIT 2, A									; Bit 2 set -> Down pressed
	CALL NZ, JoyDown
	POP AF

	; ##########################################
	; Joystick fire pressed ?
	PUSH AF
	AND %01110000								; Any of three fires pressed?
	CALL NZ, JoyFire	
	POP AF

	; ##########################################
	; Joystick up pressed ?
	BIT 3, A									; Bit 3 set -> Up pressed
	CALL NZ, JoyUp

	; ##########################################
	; Key Fire (Z) pressed ?
	LD A, _KB_V_TO_Z_HFE						; $FD -> A (5...1)
	IN A, (_KB_REG_HFE)							; Read keyboard input into A
	BIT 1, A									; Bit 1 reset -> Z pressed
	CALL Z, JoyFire
	
	; ##########################################
	; Key Left pressed ?
	LD A, _KB_5_TO_1_HF7						; $FD -> A (5...1)
	IN A, (_KB_REG_HFE)							; Read keyboard input into A
	BIT 4, A									; Bit 4 reset -> Left pressed
	CALL Z, JoyLeft		

	CALL JoyEnd

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                         JoyEnd                           ;
;----------------------------------------------------------;
JoyEnd
	CALL jm.JoystickInputProcessed

	; ##########################################
	; Down key has been released?
	LD A, (ind.joyDirection)
	BIT ind.MOVE_DOWN_BIT, A
	JR NZ, .afterJoyDownRelease					; Jump if down is pressed now

	; Down is not pressed, now check whether it was pressed during the last loop
	LD A, (ind.joyPrevDirection)
	BIT ind.MOVE_DOWN_BIT, A
	JR Z, .afterJoyDownRelease					; Jump if down was not pressed

	; Down is not pressed now, but was in previous loop
	CALL jm.JoyMoveDownRelease
	
.afterJoyDownRelease
	; ##########################################
	LD A, (ind.joyDirection)
	LD (ind.joyPrevDirection), A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                        JoyRight                          ;
;----------------------------------------------------------;
JoyRight
	; Update temp state
	LD A, (ind.joyDirection)
	SET ind.MOVE_RIGHT_BIT, A	
	LD (ind.joyDirection), A

	; ##########################################
	CALL jm.JoyMoveRight

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                        JoyLeft                           ;
;----------------------------------------------------------;
JoyLeft

	; Update #joyDirection state
	LD A, (ind.joyDirection)
	SET ind.MOVE_LEFT_BIT, A	
	LD (ind.joyDirection), A

	; ##########################################
	CALL jm.JoyMoveLeft

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                          JoyUp                           ;
;----------------------------------------------------------;
JoyUp

	; Update #joyDirection state
	LD A, (ind.joyDirection)
	SET ind.MOVE_UP_BIT, A	
	LD (ind.joyDirection), A

	; ##########################################
	CALL jm.JoyMoveUp

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                         JoyDown                          ;
;----------------------------------------------------------;
JoyDown

	; Update #joyDirection state
	LD A, (ind.joyDirection)
	SET ind.MOVE_DOWN_BIT, A	
	LD (ind.joyDirection), A

	; ##########################################
	CALL jm.JoyMoveDown

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                     JoyDownRelease                       ;
;----------------------------------------------------------;
JoyDownRelease

	CALL jm.JoyMoveDownRelease

	RET											; ## END of the function ##	

;----------------------------------------------------------;
;                        JoyFire                           ;
;----------------------------------------------------------;
JoyFire

	CALL jw.Fire

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE