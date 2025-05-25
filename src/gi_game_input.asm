;----------------------------------------------------------;
;                Joystick and Keyboard input               ;
;----------------------------------------------------------;
    MODULE gi

;----------------------------------------------------------;
;                    #ResetKeysState                       ;
;----------------------------------------------------------;
ResetKeysState

    XOR A
    LD (gid.joyOffCnt), A
    LD (gid.jetDirection), A
    LD (gid.joyDirection), A
    LD (gid.joyPrevDirection), A
    LD (gid.joyOverheatDelayCnt), A
    LD (gid.buttonState), A
    LD (gid.buttonPrevState), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  #GameJoystickInput                      ;
;----------------------------------------------------------;
GameJoystickInput

    XOR A
    LD (gid.buttonState), A
    LD (gid.joyDirection), A

    ; ##########################################
    ; Key right pressed ?
    LD A, _KB_6_TO_0_HEF                        ; $EF -> A (6...0)
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A
    PUSH AF                                     ; Keep A on the stack to avoid rereading the same input
    BIT 2, A                                    ; Bit 2 reset -> right pressed
    CALL Z, _JoyRight
    POP AF

    ; ##########################################
    ; Key up pressed ?
    PUSH AF
    BIT 3, A                                    ; Bit 3 reset -> Up pressed
    CALL Z, _JoyUp
    POP AF
    
    ; ##########################################
    ; Key down pressed ?
    BIT 4, A                                    ; Bit 4 reset -> Down pressed
    CALL Z, _JoyDown

    ; ##########################################
    ; Joystick right pressed ?
    LD A, _JOY_MASK_H20                         ; Activate joystick register
    IN A, (_JOY_REG_H1F)                        ; Read joystick input into A
    PUSH AF                                     ; Keep A on the stack to avoid rereading the same input
    BIT 0, A                                    ; Bit 0 set -> Right pressed
    CALL NZ, _JoyRight  
    POP AF

    ; ##########################################
    ; Joystick left pressed ?
    PUSH AF
    BIT 1, A                                    ; Bit 1 set -> Left pressed
    CALL NZ, _JoyLeft
    POP AF

    ; ##########################################
    ; Joystick down pressed ?
    PUSH AF
    BIT 2, A                                    ; Bit 2 set -> Down pressed
    CALL NZ, _JoyDown
    POP AF

    ; ##########################################
    ; Joystick fire pressed ?
    PUSH AF
    AND %01110000                               ; Any of three fires pressed?
    CALL NZ, _JoyFire
    POP AF

    ; ##########################################
    ; Joystick up pressed ?
    BIT 3, A                                    ; Bit 3 set -> Up pressed
    CALL NZ, _JoyUp

    ; ##########################################
    ; Key Fire (Z) pressed ?
    LD A, _KB_V_TO_SH_HFE                       ; $FD -> A (5...1)
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A
    BIT 1, A                                    ; Bit 1 reset -> Z pressed
    CALL Z, _JoyFire

    ; ##########################################
    ; Key SPACE pressed ?
    LD A, _KB_B_TO_SPC_H7F
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A
    BIT 0, A                                    ; Bit 0 reset -> SPACE pressed
    CALL Z, _JoyFire

    ; ##########################################
    ; Key ENTER pressed ?
    LD A, _KB_H_TO_ENT_HBF
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A
    BIT 0, A                                    ; Bit 0 reset -> SPACE pressed
    CALL Z, _JoyFire        
    
    ; ##########################################
    ; Key Left pressed ?
    LD A, _KB_5_TO_1_HF7                        ; $FD -> A (5...1)
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A
    BIT 4, A                                    ; Bit 4 reset -> Left pressed
    CALL Z, _JoyLeft

    CALL _JoyEnd

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   #GameKeyboardInput                     ;
;----------------------------------------------------------;
GameKeyboardInput

    ; Handle row T...Q
    LD A, _KB_T_TO_Q_HFB
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A
    PUSH AF                                     ; Keep A on the stack to avoid rereading the same input
    BIT 0, A                                    ; Q
    CALL Z, _Key_Q
    POP AF

    ; ##########################################
    PUSH AF                                     ; Keep A on the stack to avoid rereading the same input
    BIT 1, A                                    ; W
    CALL Z, _Key_W
    POP AF  

    ; ##########################################
    PUSH AF                                     ; Keep A on the stack to avoid rereading the same input
    BIT 2, A                                    ; E
    CALL Z, _Key_E
    POP AF

    ; ##########################################
    PUSH AF                                     ; Keep A on the stack to avoid rereading the same input
    BIT 3, A                                    ; R
    CALL Z, _Key_R
    POP AF

    ; ##########################################
    PUSH AF                                     ; Keep A on the stack to avoid rereading the same input
    BIT 4, A                                    ; T
    CALL Z, _Key_T
    POP AF

    ; ##########################################
    ; Handle row Y...P
    LD A, _KB_P_TO_Y_HDF
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A
    PUSH AF                                     ; Keep A on the stack to avoid rereading the same input
    BIT 0, A                                    ; P
    CALL Z, _Key_P
    POP AF

    ; ##########################################
    PUSH AF                                     ; Keep A on the stack to avoid rereading the same input.
    BIT 1, A                                    ; O
    CALL Z, _Key_O
    POP AF

    ; ##########################################
    PUSH AF                                     ; Keep A on the stack to avoid rereading the same input
    BIT 2, A                                    ; I
    CALL Z, _Key_I
    POP AF

    ; ##########################################
    PUSH AF                                     ; Keep A on the stack to avoid rereading the same input
    BIT 3, A                                    ; U
    CALL Z, _Key_U
    POP AF

    ; ##########################################
    PUSH AF                                     ; Keep A on the stack to avoid rereading the same input
    BIT 4, A                                    ; Y
    CALL Z, _Key_Y
    POP AF  

    ; ##########################################
    ; Handle row G...A
    LD A, _KB_G_TO_A_HFD
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A
    PUSH AF                                     ; Keep A on the stack to avoid rereading the same input
    BIT 3, A                                    ; F
    CALL Z, _Key_F
    POP AF

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                        _Key_Q                            ;
;----------------------------------------------------------;
_Key_Q

    ;CALL gc.LoadLevel1
   ; CALL ro.AssemblyRocketForDebug
    CALL ft.RespawnFuelThief
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        _Key_W                            ;
;----------------------------------------------------------;
_Key_W

    ;CALL gc.LoadLevel2
    CALL ft.HideFuelThief

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        _Key_E                            ;
;----------------------------------------------------------;
_Key_E

    CALL gc.LoadLevel3

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        _Key_R                            ;
;----------------------------------------------------------;
_Key_R

    CALL gc.LoadLevel4

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        _Key_T                            ;
;----------------------------------------------------------;
_Key_T

    CALL gc.LoadLevel5

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        _Key_Y                            ;
;----------------------------------------------------------;
_Key_Y

    CALL gc.LoadLevel6

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        _Key_U                            ;
;----------------------------------------------------------;
_Key_U

    CALL gc.LoadLevel7

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        _Key_I                            ;
;----------------------------------------------------------;
_Key_I

    CALL gc.LoadLevel8

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        _Key_O                            ;
;----------------------------------------------------------;
_Key_O

    CALL gc.LoadLevel9

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        _Key_P                            ;
;----------------------------------------------------------;
_Key_P

    CALL gc.LoadLevel10

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        _Key_F                            ;
;----------------------------------------------------------;
_Key_F

    CALL jw.FlipFireFx

    RET                                         ; ## END of the function ##


;----------------------------------------------------------;
;                        _JoyEnd                           ;
;----------------------------------------------------------;
_JoyEnd
    CALL jm.JoystickInputProcessed

    ; ##########################################
    ; Down key has been released?
    LD A, (gid.joyDirection)
    BIT gid.MOVE_DOWN_BIT, A
    JR NZ, .afterJoyDownRelease                 ; Jump if down is pressed now

    ; Down is not pressed, now check whether it was pressed during the last loop
    LD A, (gid.joyPrevDirection)
    BIT gid.MOVE_DOWN_BIT, A
    JR Z, .afterJoyDownRelease                  ; Jump if down was not pressed

    ; Down is not pressed now, but was in previous loop
    CALL jm.JoyMoveDownRelease
.afterJoyDownRelease

    ; ##########################################
    ; Fire key has been released?
    LD A, (gid.buttonState)
    BIT gid.BS_FIRE_BIT, A
    JR NZ, .afterFireRelease                 ; Jump if fire is pressed now

    ; Fire is not pressed, now check whether it was pressed during the last loop
    LD A, (gid.buttonPrevState)
    BIT gid.BS_FIRE_BIT, A
    JR Z, .afterFireRelease                  ; Jump if down was not pressed

    ; Fire is not pressed now, but was in previous loop
    CALL _JoyFireRelease

.afterFireRelease 

    ; ##########################################
    ; Update previous state

    LD A, (gid.joyDirection)
    LD (gid.joyPrevDirection), A

    LD A, (gid.buttonState)
    LD (gid.buttonPrevState), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        _JoyRight                         ;
;----------------------------------------------------------;
_JoyRight
    ; Update temp state
    LD A, (gid.joyDirection)
    SET gid.MOVE_RIGHT_BIT, A
    LD (gid.joyDirection), A

    ; ##########################################
    CALL jm.JoyMoveRight

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       _JoyLeft                           ;
;----------------------------------------------------------;
_JoyLeft

    ; Update #joyDirection state
    LD A, (gid.joyDirection)
    SET gid.MOVE_LEFT_BIT, A
    LD (gid.joyDirection), A

    ; ##########################################
    CALL jm.JoyMoveLeft

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                          _JoyUp                          ;
;----------------------------------------------------------;
_JoyUp

    ; Update #joyDirection state
    LD A, (gid.joyDirection)
    SET gid.MOVE_UP_BIT, A  
    LD (gid.joyDirection), A

    ; ##########################################
    CALL jm.JoyMoveUp

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        _JoyDown                          ;
;----------------------------------------------------------;
_JoyDown

    ; Update #joyDirection state
    LD A, (gid.joyDirection)
    SET gid.MOVE_DOWN_BIT, A
    LD (gid.joyDirection), A

    ; ##########################################
    CALL jm.JoyMoveDown

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     _JoyDownRelease                      ;
;----------------------------------------------------------;
_JoyDownRelease

    CALL jm.JoyMoveDownRelease

    RET                                         ; ## END of the function ## 

;----------------------------------------------------------;
;                        _JoyFire                          ;
;----------------------------------------------------------;
_JoyFire
    
    LD A, (gid.buttonState)
    SET gid.BS_FIRE_BIT, A
    LD (gid.buttonState), A

    CALL jw.Fire

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   _JoyFireRelease                        ;
;----------------------------------------------------------;
_JoyFireRelease

    CALL jw.FireReleased

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE