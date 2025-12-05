/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                Joystick and Keyboard input               ;
;----------------------------------------------------------;
    MODULE gi

;----------------------------------------------------------;
;                     ResetKeysState                       ;
;----------------------------------------------------------;
ResetKeysState

    XOR A
    LD (gid.joyOffCnt), A
    LD (gid.jetDirection), A
    LD (gid.joyDirection), A
    LD (gid.joyPrevDirection), A
    LD (gid.joyOverheatDelayCnt), A
    LD (gid.gameInputState), A
    LD (gid.gameInputPrevState), A
    LD (gid.breakCnt), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    JetMovementInput                      ;
;----------------------------------------------------------;
; On hard difficulty, Jetman moves faster. Therefore, movement direction is handled separately from keyboard movement. 
; Keys are always processed at the same speed.
JetMovementInput

    XOR A
    LD (gid.joyDirection), A

    ; ##########################################
    ; Row: 1, 2, 3, 4, 5, read left arrow key

    ; Key Left
    LD A, _KB_5_TO_1_HF7                        ; $FD -> A (5...1).
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A.
    BIT 4, A                                    ; Bit 4 reset -> Left pressed.
    CALL Z, _JoyLeft

    ; ##########################################
    ; Row: 6, 7, 8 ,9, 0 and to read arrow keys: up/down/right

    ; Key right
    LD A, _KB_6_TO_0_HEF                        ; $EF -> A (6...0).
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A.
    PUSH AF                                     ; Keep A on the stack to avoid rereading the same input.
    BIT 2, A                                    ; Bit 2 reset -> right pressed.
    CALL Z, _JoyRight
    POP AF

    ; Key up
    PUSH AF
    BIT 3, A                                    ; Bit 3 reset -> Up pressed.
    CALL Z, _JoyUp
    POP AF
    
    ; Key down
    BIT 4, A                                    ; Bit 4 reset -> Down pressed.
    CALL Z, _JoyDown

    ; ##########################################
    ; Read Kempston input

    ; Joystick right
    LD A, _JOY_MASK_H20                         ; Activate joystick register.
    IN A, (_JOY_REG_H1F)                        ; Read joystick input into A.
    PUSH AF                                     ; Keep A on the stack to avoid rereading the same input.
    BIT 0, A                                    ; Bit 0 set -> Right pressed.
    CALL NZ, _JoyRight  
    POP AF

    ; Joystick left
    PUSH AF
    BIT 1, A                                    ; Bit 1 set -> Left pressed.
    CALL NZ, _JoyLeft
    POP AF

    ; Joystick down
    PUSH AF
    BIT 2, A                                    ; Bit 2 set -> Down pressed.
    CALL NZ, _JoyDown
    POP AF

    ; Joystick up
    BIT 3, A                                    ; Bit 3 set -> Up pressed.
    CALL NZ, _JoyUp

    CALL _JoyMoveEnd

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   GameOptionsInput                       ;
;----------------------------------------------------------;
; On hard difficulty, Jetman moves faster. Therefore, movement direction is handled separately from keyboard movement.
; Keys are always processed at the same speed. Also, only one option key is being processed during a single loop.
GameOptionsInput

    XOR A
    LD (gid.gameInputState), A
    
    ; ##########################################
    ; Read Kempston input
    LD A, _JOY_MASK_H20                         ; Activate joystick register.
    IN A, (_JOY_REG_H1F)                        ; Read joystick input into A.

    ; Joystick fire A
    PUSH AF
    AND %01000000                               ; Any of three fires pressed?
    CALL NZ, _JoyFireA
    POP AF

    ; Joystick fire B
    PUSH AF
    AND %00010000                               ; Any of three fires pressed?
    CALL NZ, _JoyFireB
    POP AF

    ; Joystick fire C
    AND %00100000                               ; Any of three fires pressed?
    CALL NZ, _JoyFireC

    ; ##########################################
    ; Row: V, C, X, Z, SHIFT
    
    ; Key Fire (Z)
    LD A, _KB_V_TO_SH_HFE
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A.
    
    BIT 1, A                                    ; Bit 1 reset -> Z pressed.
    CALL Z, _JoyFireB

    ; ##########################################
    ; Row: H, J, K, L, ENTER

    ; Key ENTER
    LD A, _KB_H_TO_ENT_HBF
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A.
    BIT 0, A                                    ; Bit 0 reset -> ENTER pressed.
    CALL Z, _JoyFireA

    ; ##########################################
    ; Row T...Q
    LD A, _KB_T_TO_Q_HFB
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A.
    PUSH AF                                     ; Keep A on the stack to avoid rereading the same input.
    BIT 0, A                                    ; Q
    CALL Z, _Key_Q
    POP AF

    ; Key W
    PUSH AF                                     ; Keep A on the stack to avoid rereading the same input.
    BIT 1, A                                    ; W
    CALL Z, _Key_W
    POP AF  

    ; Key E
    PUSH AF                                     ; Keep A on the stack to avoid rereading the same input.
    BIT 2, A                                    ; E
    CALL Z, _Key_E
    POP AF

    ; Key R
    PUSH AF                                     ; Keep A on the stack to avoid rereading the same input.
    BIT 3, A                                    ; R
    CALL Z, _Key_R
    POP AF

    ; Key T
    BIT 4, A                                    ; T
    CALL Z, _Key_T

    ; ##########################################
    ; Row: Y...P

    ; Key P
    LD A, _KB_P_TO_Y_HDF
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A.
    PUSH AF                                     ; Keep A on the stack to avoid rereading the same input.
    BIT 0, A                                    ; P
    CALL Z, _Key_P
    POP AF

    ; Key O
    PUSH AF                                     ; Keep A on the stack to avoid rereading the same input.
    BIT 1, A                                    ; O
    CALL Z, _Key_O
    POP AF

    ; Key I
    PUSH AF                                     ; Keep A on the stack to avoid rereading the same input.
    BIT 2, A                                    ; I
    CALL Z, _Key_I
    POP AF

    ; Key U
    PUSH AF                                     ; Keep A on the stack to avoid rereading the same input.
    BIT 3, A                                    ; U
    CALL Z, _Key_U
    POP AF

    ; Key Y
    BIT 4, A                                    ; Y
    CALL Z, _Key_Y

    ; ##########################################
    ; Row: G...A

    ; Key F
    LD A, _KB_G_TO_A_HFD
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A.
    PUSH AF                                     ; Keep A on the stack to avoid rereading the same input.
    BIT 3, A                                    ; F
    CALL Z, _Key_F
    POP AF

    ; ##########################################
    ; Row: B, M, M, FULL-STOP, SPACE

    ; Key N
    LD A, _KB_B_TO_SPC_H7F
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A.
    PUSH AF                                     ; Keep A on the stack to avoid rereading the same input.
    BIT 3, A                                    ; N
    CALL Z, _Key_N
    POP AF

    ; Key M
    PUSH AF                                     ; Keep A on the stack to avoid rereading the same input.
    BIT 2, A                                    ; M
    CALL Z, _Key_M
    POP AF

    ; Key SPACE
    BIT 0, A                                    ; Bit 0 reset -> SPACE pressed.
    JR NZ, .notSpace

    CALL _ThrowGranade

    ; ##########################################
    ; Key Break = SPACE + SHIFT, space is down, now check SHIFT

    ; Do not detect a break when Jetman is moving.
    LD A, (gid.joyDirection)
    CP 0
    JR NZ, .notBreak

    ; SHIFT pressed?
    LD A, _KB_V_TO_SH_HFE                       ; Row: V, C, X, Z, SHIFT
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A.

    BIT 0, A                                    ; Bit 0 reset -> SHIFT pressed.
    JR NZ, .notBreak

    CALL _Key_Break

.notSpace
.notBreak


    ; ##########################################
    CALL _GameInputEnd

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                        _Key_N                            ;
;----------------------------------------------------------;
_Key_N

    CALL _NextSong

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        _Key_M                            ;
;----------------------------------------------------------;
_Key_M

    CALL ki.CanProcessKeyInput
    CP _RET_NO_D0
    RET Z
    
    CALL dbs.SetupMusicBank
    CALL aml.FlipOnOff

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        _Key_Q                            ;
;----------------------------------------------------------;
_Key_Q

  ;CALL gc.LoadLevel1
   ;CALL ro.AssemblyRocketForDebug

    LD HL, (jco.invincibleCnt)
    LD A, (jt.jetState)
    LD A,B
    LD A, (js.sprState)
    nextreg 2,8

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        _Key_W                            ;
;----------------------------------------------------------;
_Key_W
    CALL ro.AssemblyRocketForDebug
  ;  CALL gc.LoadLevel2

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
; Pause game
_Key_P

    CALL ki.CanProcessKeyInput
    CP _RET_NO_D0
    RET Z
    
    LD A, (ms.mainState)

    CP ms.PAUSE
    JR Z, .pause

    LD A, ms.PAUSE
    CALL ms.SetMainStateAndBackup
    RET

.pause

    CALL ms.RestoreMainState

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        _Key_F                            ;
;----------------------------------------------------------;
_Key_F

    CALL jw.FlipFireFx

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      _Key_Break                          ;
;----------------------------------------------------------;
_Key_Break

    LD A, (gid.breakCnt)
    INC A
    LD (gid.breakCnt), A

    CP gid.BREAK_CNT
    RET NZ

    ; The break has been pressed long enough to exit the game.
    CALL gc.ExitGameToMainMenu

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   _GameInputEnd                          ;
;----------------------------------------------------------;
_GameInputEnd

    ; Fire key has been released?
    LD A, (gid.gameInputState)
    BIT gid.BS_FIRE_BIT, A
    JR NZ, .afterFireRelease                 ; Jump if fire is pressed now.

    ; Fire is not pressed, now check whether it was pressed during the last loop.
    LD A, (gid.gameInputPrevState)
    BIT gid.BS_FIRE_BIT, A
    JR Z, .afterFireRelease                  ; Jump if down was not pressed.

    ; Fire is not pressed now, but was in previous loop.
    CALL _JoyFireRelease
.afterFireRelease 

    ; ##########################################
    LD A, (gid.gameInputState)
    LD (gid.gameInputPrevState), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        _JoyEnd                           ;
;----------------------------------------------------------;
_JoyMoveEnd

    CALL jm.JoystickMoveProcessed

    ; ##########################################
    ; Down key has been released?
    LD A, (gid.joyDirection)
    BIT gid.MOVE_DOWN_BIT, A
    JR NZ, .afterJoyDownRelease                 ; Jump if down is pressed now.

    ; Down is not pressed, now check whether it was pressed during the last loop.
    LD A, (gid.joyPrevDirection)
    BIT gid.MOVE_DOWN_BIT, A
    JR Z, .afterJoyDownRelease                  ; Jump if down was not pressed.

    ; Down is not pressed now, but was in previous loop.
    CALL jm.JoyMoveDownRelease
.afterJoyDownRelease

    ; ##########################################
    ; Update previous state

    LD A, (gid.joyDirection)
    LD (gid.joyPrevDirection), A

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
;                       _JoyFireA                          ;
;----------------------------------------------------------;
_JoyFireA

    CALL _ThrowGranade

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       _JoyFireB                          ;
;----------------------------------------------------------;
_JoyFireB

    LD A, (gid.gameInputState)
    SET gid.BS_FIRE_BIT, A
    LD (gid.gameInputState), A

    CALL jw.FirePress

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       _JoyFireC                          ;
;----------------------------------------------------------;
_JoyFireC

    CALL _NextSong

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   _JoyFireRelease                        ;
;----------------------------------------------------------;
_JoyFireRelease

    CALL jw.FireReleased

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     _JoyGrenade                          ;
;----------------------------------------------------------;
_ThrowGranade

    CALL ki.CanProcessKeyInput
    CP _RET_NO_D0
    RET Z

    CALL gr.UseGrenade

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      _NextSong                           ;
;----------------------------------------------------------;
_NextSong

    CALL ki.CanProcessKeyInput
    CP _RET_NO_D0
    RET Z

    CALL dbs.SetupMusicBank
    CALL aml.NextGameSong

    RET                                         ; ## END of the function ##
;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE