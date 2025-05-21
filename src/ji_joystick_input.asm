;----------------------------------------------------------;
;                    Main Hight Score                      ;
;----------------------------------------------------------;
    MODULE ji

userInputDelayCnt       DB 0
USER_INPUT_DELAY        = 10
USER_INPUT_DELAY_OFF    = $FF

userInputInactiveCnt    DB 0
USER_INPUT_RESET        = 5

callbackRight           DW _DummyFunction
callbackLeft            DW _DummyFunction
callbackUp              DW _DummyFunction
callbackDown            DW _DummyFunction
callbackFire            DW _DummyFunction

;----------------------------------------------------------;
;                #JoystickInputLastLoop                    ;
;----------------------------------------------------------;
JoystickInputLastLoop

    ; Reset #userInputDelayCnt when timer #userInputInactiveCnt has reached #USER_INPUT_RESET. By doing it, the next button press will 
    ; execute immediately.

    ; Do not reset #userInputDelayCnt if already at #USER_INPUT_DELAY
    LD A, (userInputDelayCnt)
    CP USER_INPUT_DELAY
    RET Z

    LD A, (userInputInactiveCnt)
    CP USER_INPUT_RESET
    JR Z, .reset
    INC A
    LD (userInputInactiveCnt),A
    RET
.reset
    XOR A
    LD (userInputInactiveCnt), A

    LD A, USER_INPUT_DELAY
    LD (userInputDelayCnt), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     #SetupJoystick                       ;
;----------------------------------------------------------;
; Input:
;  - A: User input delay
SetupJoystick

    LD (userInputDelayCnt),A

    XOR A
    LD (userInputInactiveCnt), 0

    LD DE, _DummyFunction
    LD (callbackRight), DE
    LD (callbackLeft), DE
    LD (callbackUp), DE
    LD (callbackDown), DE
    LD (callbackFire), DE

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       #JoystickInput                     ;
;----------------------------------------------------------;
JoystickInput

    ; Key right pressed ?
    LD A, _KB_6_TO_0_HEF
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A
    BIT 2, A                                    ; Bit 2 reset -> right pressed
    JR Z, .pressRight

    ; ##########################################
    ; Key up pressed ?
    BIT 3, A                                    ; Bit 3 reset -> Up pressed
    JR Z, .pressUp
    
    ; ##########################################
    ; Key down pressed ?
    BIT 4, A                                    ; Bit 4 reset -> Down pressed
    JR Z, .pressDown

    ; ##########################################
    ; Joystick right pressed ?
    LD A, _JOY_MASK_H20                         ; Activate joystick register
    IN A, (_JOY_REG_H1F)                        ; Read joystick input into A
    BIT 0, A                                    ; Bit 0 set -> Right pressed
    JR NZ, .pressRight

    ; ##########################################
    ; Joystick left pressed ?
    BIT 1, A                                    ; Bit 1 set -> Left pressed
    JR NZ, .pressLeft

    ; ##########################################
    ; Joystick down pressed ?
    BIT 2, A                                    ; Bit 2 set -> Down pressed
    JR NZ, .pressDown

    ; ##########################################
    ; Joystick fire pressed ?
    PUSH AF
    AND %01110000                               ; Any of three fires pressed?
    JR NZ, .pressFire
    POP AF
    
    ; ##########################################
    ; Joystick up pressed ?
    BIT 3, A                                    ; Bit 3 set -> Up pressed
    JR NZ, .pressUp

    ; ##########################################
    ; Key Fire (Z) pressed ?
    LD A, _KB_V_TO_SH_HFE
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A
    BIT 1, A                                    ; Bit 1 reset -> Z pressed
    JR Z, .pressFire

    ; ##########################################
    ; Key SPACE pressed ?
    LD A, _KB_B_TO_SPC_H7F
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A
    BIT 0, A                                    ; Bit 0 reset -> SPACE pressed
    JR Z, .pressFire

    ; ##########################################
    ; Key ENTER pressed ?
    LD A, _KB_H_TO_ENT_HBF
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A
    BIT 0, A                                    ; Bit 0 reset -> SPACE pressed
    JR Z, .pressFire
    
    ; ##########################################
    ; Key Left pressed ?
    LD A, _KB_5_TO_1_HF7
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A
    BIT 4, A                                    ; Bit 4 reset -> Left pressed
    JR Z, .pressLeft

    RET                                         ; None of the keys pressed

.pressRight
    CALL CanProcessJoystickInput
    CP _RET_NO_D0
    RET Z

    LD HL, .pressRightReturn
    PUSH HL
    LD HL, (callbackRight)
    JP (HL)
.pressRightReturn
    RET

.pressLeft
    CALL CanProcessJoystickInput
    CP _RET_NO_D0
    RET Z

    LD HL, .pressLeftReturn
    PUSH HL
    LD HL, (callbackLeft)
    JP (HL)
.pressLeftReturn
    RET

.pressUp
    CALL CanProcessJoystickInput
    CP _RET_NO_D0
    RET Z

    LD HL, .pressUpReturn
    PUSH HL
    LD HL, (callbackUp)
    JP (HL)
.pressUpReturn
    RET

.pressDown
    CALL CanProcessJoystickInput
    CP _RET_NO_D0
    RET Z

    LD HL, .pressDownReturn
    PUSH HL
    LD HL, (callbackDown)
    JP (HL)
.pressDownReturn
    RET

.pressFire
    CALL CanProcessJoystickInput
    CP _RET_NO_D0
    RET Z

    LD HL, .pressFireReturn
    PUSH HL
    LD HL, (callbackFire)
    JP (HL)
.pressFireReturn
    RET

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

tmpNO byte 0
tmpYES byte 0


;----------------------------------------------------------;
;                 #CanProcessJoystickInput                 ;
;----------------------------------------------------------;
; Output:
;  A: _RET_YES_D1 or _RET_NO_D0
CanProcessJoystickInput

    ; Reset inactivity count
    XOR A
    LD (userInputInactiveCnt), A

    ; Delay user input processing
    LD A, (userInputDelayCnt)
    CP USER_INPUT_DELAY
    JR Z, .processInput
    INC A
    LD (userInputDelayCnt), A

    LD A, _RET_NO_D0
    RET
.processInput

    XOR A
    LD (userInputDelayCnt), A
    LD A, _RET_YES_D1

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     #_DummyFunction                      ;
;----------------------------------------------------------;
_DummyFunction

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;

    ENDMODULE