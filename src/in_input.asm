;----------------------------------------------------------;
;                Joystick and Keyboard input               ;
;----------------------------------------------------------;
	MODULE in

;----------------------------------------------------------;
;                         #JoyInput                        ;
;----------------------------------------------------------;
JoyInput

	LD A, ind.MOVE_INACTIVE						; Update #jetState by resetting left/hover and setting right.
	LD (ind.joyDirection), A

	; ##########################################	
	; Key Rright pressed ?
	LD A, _KB_6_TO_0_HEF						; $EF -> A (6...0).
	IN A, (_KB_REG_HFE)							; Read keyboard input into A.
	PUSH AF										; Keep A on the stack to avoid rereading the same input.
	BIT 2, A									; Bit 2 reset -> Rright pressed.
	CALL Z, _JoyRight
	POP AF

	; ##########################################
	; Key Up pressed ?
	PUSH AF
	BIT 3, A									; Bit 3 reset -> Up pressed.
	CALL Z, _JoyUp
	POP AF
	
	; ##########################################
	; Key Down pressed ?
	BIT 4, A									; Bit 4 reset -> Down pressed.
	CALL Z, _JoyDown

	; ##########################################
	; Joystick right pressed ?
	LD A, _JOY_MASK_H20							; Activete joystick register.
	IN A, (_JOY_REG_H1F) 						; Read joystick input into A.
	PUSH AF										; Keep A on the stack to avoid rereading the same input.
	BIT 0, A									; Bit 0 set -> Right pressed.
	CALL NZ, _JoyRight	
	POP AF

	; ##########################################
	; Joystick left pressed ?
	PUSH AF
	BIT 1, A									; Bit 1 set -> Left pressed.
	CALL NZ, _JoyLeft
	POP AF

	; ##########################################
	; Joystick down pressed ?
	PUSH AF
	BIT 2, A									; Bit 2 set -> Down pressed.
	CALL NZ, _JoyDown
	POP AF

	; ##########################################
	; Joystick fire pressed ?
	PUSH AF
	AND %01110000								; Any of three fires pressed?
	CALL NZ, _JoyFire	
	POP AF

	; ##########################################
	; Joystick up pressed ?
	BIT 3, A									; Bit 3 set -> Up pressed.
	CALL NZ, _JoyUp

	; ##########################################
	; Key Fire (Z) pressed ?
	LD A, _KB_V_TO_Z_HFE						; $FD -> A (5...1).
	IN A, (_KB_REG_HFE)							; Read keyboard input into A.
	BIT 1, A									; Bit 1 reset -> Z pressed.
	CALL Z, _JoyFire
	
	; ##########################################
	; Key Left pressed ?
	LD A, _KB_5_TO_1_HF7						; $FD -> A (5...1).
	IN A, (_KB_REG_HFE)							; Read keyboard input into A.
	BIT 4, A									; Bit 4 reset -> Left pressed.
	CALL Z, _JoyLeft		

	CALL _JoyEnd

	RET											; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                        _JoyEnd                           ;
;----------------------------------------------------------;
_JoyEnd
	CALL jm.JoystickInputProcessed

	; ##########################################
	; Down key has been released?
	LD A, (ind.joyDirection)
	BIT ind.MOVE_DOWN_BIT, A
	JR NZ, .afterJoyDownRelease					; Jump if down is pressed now.

	; Down is not pressed, now check whether it was pressed during the last loop.
	LD A, (ind.joyPrevDirection)
	BIT ind.MOVE_DOWN_BIT, A
	JR Z, .afterJoyDownRelease					; Jump if down was not pressed.

	; Down is not pressed now, but was in previous loop.
	CALL jm.JoyMoveDownRelease
	
.afterJoyDownRelease
	; ##########################################
	LD A, (ind.joyDirection)
	LD (ind.joyPrevDirection), A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                        _JoyRight                         ;
;----------------------------------------------------------;
_JoyRight
	; Update temp state.
	LD A, (ind.joyDirection)
	SET ind.MOVE_RIGHT_BIT, A	
	LD (ind.joyDirection), A

	; ##########################################
	CALL jm.JoyMoveRight

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       _JoyLeft                           ;
;----------------------------------------------------------;
_JoyLeft

	; Update #joyDirection state.
	LD A, (ind.joyDirection)
	SET ind.MOVE_LEFT_BIT, A	
	LD (ind.joyDirection), A

	; ##########################################
	CALL jm.JoyMoveLeft

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                          _JoyUp                          ;
;----------------------------------------------------------;
_JoyUp

	; Update #joyDirection state.
	LD A, (ind.joyDirection)
	SET ind.MOVE_UP_BIT, A	
	LD (ind.joyDirection), A

	; ##########################################
	CALL jm.JoyMoveUp

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                        _JoyDown                          ;
;----------------------------------------------------------;
_JoyDown

	; Update #joyDirection state.
	LD A, (ind.joyDirection)
	SET ind.MOVE_DOWN_BIT, A	
	LD (ind.joyDirection), A

	; ##########################################
	CALL jm.JoyMoveDown

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                     _JoyDownRelease                      ;
;----------------------------------------------------------;
_JoyDownRelease

	CALL jm.JoyMoveDownRelease

	RET											; ## END of the function ##	

;----------------------------------------------------------;
;                        _JoyFire                          ;
;----------------------------------------------------------;
_JoyFire

	CALL jw.Fire

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE