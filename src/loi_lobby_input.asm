;----------------------------------------------------------;
;            Lobby Keyboard/Joystick Input.                ;
;----------------------------------------------------------;
    MODULE loi
    
;----------------------------------------------------------;
;                     #MainMenuUserInput                   ;
;----------------------------------------------------------;
MainMenuUserInput

    ; ##########################################    
    ; Key right pressed ?
    LD A, _KB_6_TO_0_HEF
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A.
    PUSH AF                                     ; Keep A on the stack to avoid rereading the same input.
    BIT 2, A                                    ; Bit 2 reset -> right pressed.
    CALL Z, _JoyRight
    POP AF

    ; ##########################################
    ; Key up pressed ?
    PUSH AF
    BIT 3, A                                    ; Bit 3 reset -> Up pressed.
    CALL Z, _JoyUp
    POP AF
    
    ; ##########################################
    ; Key down pressed ?
    BIT 4, A                                    ; Bit 4 reset -> Down pressed.
    CALL Z, _JoyDown

    ; ##########################################
    ; Joystick right pressed ?
    LD A, _JOY_MASK_H20                         ; Activate joystick register.
    IN A, (_JOY_REG_H1F)                        ; Read joystick input into A.
    PUSH AF                                     ; Keep A on the stack to avoid rereading the same input.
    BIT 0, A                                    ; Bit 0 set -> Right pressed.
    CALL NZ, _JoyRight  
    POP AF

    ; ##########################################
    ; Joystick left pressed ?
    PUSH AF
    BIT 1, A                                    ; Bit 1 set -> Left pressed.
    CALL NZ, _JoyLeft
    POP AF

    ; ##########################################
    ; Joystick down pressed ?
    PUSH AF
    BIT 2, A                                    ; Bit 2 set -> Down pressed.
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
    BIT 3, A                                    ; Bit 3 set -> Up pressed.
    CALL NZ, _JoyUp

    ; ##########################################
    ; Key Fire (Z) pressed ?
    LD A, _KB_V_TO_SH_HFE
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A.
    BIT 1, A                                    ; Bit 1 reset -> Z pressed.
    CALL Z, _JoyFire

    ; ##########################################
    ; Key SPACE pressed ?
    LD A, _KB_B_TO_SPC_H7F
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A.
    BIT 0, A                                    ; Bit 0 reset -> SPACE pressed.
    CALL Z, _JoyFire

    ; ##########################################
    ; Key ENTER pressed ?
    LD A, _KB_H_TO_ENT_HBF
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A.
    BIT 0, A                                    ; Bit 0 reset -> SPACE pressed.
    CALL Z, _JoyFire        
    
    ; ##########################################
    ; Key Left pressed ?
    LD A, _KB_5_TO_1_HF7
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A.
    BIT 4, A                                    ; Bit 4 reset -> Left pressed.
    CALL Z, _JoyLeft    

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                        _JoyRight                         ;
;----------------------------------------------------------;
_JoyRight

    CALL _ExitMenu

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       _JoyLeft                           ;
;----------------------------------------------------------;
_JoyLeft

    CALL _ExitMenu

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                          _JoyUp                          ;
;----------------------------------------------------------;
_JoyUp

    CALL _ExitMenu

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        _JoyDown                          ;
;----------------------------------------------------------;
_JoyDown

    CALL _ExitMenu

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        _JoyFire                          ;
;----------------------------------------------------------;
_JoyFire

    CALL _ExitMenu

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       _ExitMenu                          ;
;----------------------------------------------------------;
_ExitMenu

    LD A, (los.lobbyState)
    CP los.MAIN_MENU
    JR NZ, .afterMainMenu

    CALL gc.LoadLevel1Intro
    RET
.afterMainMenu

    LD A, (los.lobbyState)
    CP los.LEVEL_INTRO
    JR NZ, .afterLevelIntro

    CALL gc.LoadCurrentLevel
    RET
.afterLevelIntro

    RET                                         ; ## END of the function ## 

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE