/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                    Keyboard Input                        ;
;----------------------------------------------------------;
    MODULE ki

userInputDelayCnt       DB 0
USER_INPUT_DELAY        = 15

userInputInactiveCnt    DB 0
USER_INPUT_RESET        = 5

callbackRight           DW _DummyFunction
callbackLeft            DW _DummyFunction
callbackUp              DW _DummyFunction
callbackDown            DW _DummyFunction
callbackFire            DW _DummyFunction

;----------------------------------------------------------;
;                 KeyboardInputLastLoop                    ;
;----------------------------------------------------------;
KeyboardInputLastLoop

    ; Reset #userInputDelayCnt when timer #userInputInactiveCnt has reached #USER_INPUT_RESET. By doing it, the next button press will
    ; execute immediately.

    ; Do not reset #userInputDelayCnt if already at #USER_INPUT_DELAY.
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
;                      ResetKeyboard                       ;
;----------------------------------------------------------;
; Input:
;  - A: user input delay
ResetKeyboard

    XOR A
    LD (userInputInactiveCnt), A
    LD (userInputDelayCnt),A
    
    LD DE, _DummyFunction
    LD (callbackRight), DE
    LD (callbackLeft), DE
    LD (callbackUp), DE
    LD (callbackDown), DE
    LD (callbackFire), DE

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     KeyboardInput                        ;
;----------------------------------------------------------;
KeyboardInput

    ; Key right pressed ?
    LD A, _KB_6_TO_0_HEF
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A.
    BIT 2, A                                    ; Bit 2 reset -> right pressed.
    JR Z, .pressRight

    ; ##########################################
    ; Key up pressed ?
    BIT 3, A                                    ; Bit 3 reset -> Up pressed.
    JR Z, .pressUp
    
    ; ##########################################
    ; Key down pressed ?
    BIT 4, A                                    ; Bit 4 reset -> Down pressed.
    JR Z, .pressDown

    ; ##########################################
    ; Joystick right pressed ?
    LD A, _JOY_MASK_H20                         ; Activate joystick register.
    IN A, (_JOY_REG_H1F)                        ; Read joystick input into A.
    BIT 0, A                                    ; Bit 0 set -> Right pressed.
    JR NZ, .pressRight

    ; ##########################################
    ; Joystick left pressed ?
    BIT 1, A                                    ; Bit 1 set -> Left pressed.
    JR NZ, .pressLeft

    ; ##########################################
    ; Joystick down pressed ?
    BIT 2, A                                    ; Bit 2 set -> Down pressed.
    JR NZ, .pressDown

    ; ##########################################
    ; Joystick fire pressed ?
    PUSH AF
    AND %01110000                               ; Any of three fires pressed?
    JR NZ, .pressFire
    POP AF
    
    ; ##########################################
    ; Joystick up pressed ?
    BIT 3, A                                    ; Bit 3 set -> Up pressed.
    JR NZ, .pressUp

    ; ##########################################
    ; Key Fire (Z) pressed ?
    LD A, _KB_V_TO_SH_HFE
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A.
    BIT 1, A                                    ; Bit 1 reset -> Z pressed.
    JR Z, .pressFire

    ; ##########################################
    ; Key SPACE pressed ?
    LD A, _KB_B_TO_SPC_H7F
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A.
    BIT 0, A                                    ; Bit 0 reset -> SPACE pressed.
    JR Z, .pressFire

    ; ##########################################
    ; Key ENTER pressed ?
    LD A, _KB_H_TO_ENT_HBF
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A.
    BIT 0, A                                    ; Bit 0 reset -> SPACE pressed.
    JR Z, .pressFire
    
    ; ##########################################
    ; Key Left pressed ?
    LD A, _KB_5_TO_1_HF7
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A.
    BIT 4, A                                    ; Bit 4 reset -> Left pressed.
    JR Z, .pressLeft

    RET                                         ; None of the keys pressed.

.pressRight
    CALL ki.CanProcessKeyInput
    RET NZ

    LD HL, .pressRightReturn
    PUSH HL
    LD HL, (callbackRight)
    JP (HL)
.pressRightReturn
    RET

.pressLeft
    CALL ki.CanProcessKeyInput
    RET NZ

    LD HL, .pressLeftReturn
    PUSH HL
    LD HL, (callbackLeft)
    JP (HL)
.pressLeftReturn
    RET

.pressUp
    CALL ki.CanProcessKeyInput
    RET NZ

    LD HL, .pressUpReturn
    PUSH HL
    LD HL, (callbackUp)
    JP (HL)
.pressUpReturn
    RET

.pressDown
    CALL ki.CanProcessKeyInput
    RET NZ

    LD HL, .pressDownReturn
    PUSH HL
    LD HL, (callbackDown)
    JP (HL)
.pressDownReturn
    RET

.pressFire
    CALL ki.CanProcessKeyInput
    RET NZ

    LD HL, .pressFireReturn
    PUSH HL
    LD HL, (callbackFire)
    JP (HL)
.pressFireReturn
    RET

    RET                                         ; ## END of the function ##


;----------------------------------------------------------;
;                   CanProcessKeyInput                     ;
;----------------------------------------------------------;
; Output:
;  A: YES: Z is set (JP Z), NO: Z is reset (JP NZ)
CanProcessKeyInput

    ; Reset inactivity count
    XOR A
    LD (userInputInactiveCnt), A

    ; Delay user input processing
    LD A, (userInputDelayCnt)
    CP USER_INPUT_DELAY
    JR Z, .processInput
    INC A
    LD (userInputDelayCnt), A


    ; Return NO, A!=0, Z is reset
    RET
.processInput

    XOR A                                       ; A=0 and set Z for the return value from the function.
    LD (userInputDelayCnt), A

    ; Return YES, A=0, Z is set

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                      _DummyFunction                      ;
;----------------------------------------------------------;
_DummyFunction

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;

    ENDMODULE