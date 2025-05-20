;----------------------------------------------------------;
;                          Utils                           ;
;----------------------------------------------------------;
    MODULE ui

userInputDelayCnt       DB 0
USER_INPUT_DELAY        = 10

userInputInactiveCnt    DB 0
USER_INPUT_RESET        = 5

;----------------------------------------------------------;
;                 #UserInputLastLoop                       ;
;----------------------------------------------------------;
UserInputLastLoop

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
;                 #CanProcessKeyboardInput                 ;
;----------------------------------------------------------;
; Output:
;  A: _RET_YES_D1 or _RET_NO_D0
CanProcessKeyboardInput

    ; Reset inactivity count.
    XOR A
    LD (userInputInactiveCnt), A

    ; Delay user input processing.
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
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE