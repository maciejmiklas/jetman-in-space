/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                Joystick and Keyboard input               ;
;----------------------------------------------------------;
    MODULE gi

;----------------------------------------------------------;
;                        _JoyEnd                           ;
;----------------------------------------------------------;
    MACRO _JoyMoveEnd

    CALL jm.JoystickMoveProcessed

    ; ##########################################
    ; Down key has been released?
    LD A, (gid.joyDirection)
    BIT gid.MOVE_DOWN_BIT_D3, A
    JR NZ, .afterJoyDownRelease                 ; Jump if down is pressed now.

    ; Down is not pressed, now check whether it was pressed during the last loop.
    LD A, (gid.joyPrevDirection)
    BIT gid.MOVE_DOWN_BIT_D3, A
    JR Z, .afterJoyDownRelease                  ; Jump if down was not pressed.

    ; Down is not pressed now, but was in previous loop.
    CALL jm.JoyMoveDownRelease
.afterJoyDownRelease

    ; ##########################################
    ; Update previous state

    LD A, (gid.joyDirection)
    LD (gid.joyPrevDirection), A

    ; ##########################################
    ; Handle fire released.
    LD A, (gid.fireOffCnt)
    CP gid.FIRE_RELEASED_D5
    JR NZ, .fireNorReleased
    CALL jw.FireReleased
.fireNorReleased

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PUBLIC FUNCTIONS                       ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                    JetMovementInput                      ;
;----------------------------------------------------------;
; Options are active durign pause, movement is not.
; Input:
; - A: number of movement steps
JetMovementInput

    LD (gid.moveDistance), A

    XOR A
    LD (gid.joyDirection), A

    LD A, (gid.fireOffCnt)
    CP gid.FIRE_RELEASED_D5+1
    JR Z, .afterFireOffCnt
    INC A
    LD (gid.fireOffCnt), A
.afterFireOffCnt

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
    LD A, _JOY_MASK_H20                         ; Activate joystick register.
    IN A, (_JOY_REG_H1F)                        ; Read joystick input into A.

    ; Joystick right
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

    ; ##########################################
    ; Row: G, F, D, S, T, A
    LD A, _KB_G_TO_A_HFD
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A.

    ; Key A
    BIT 0, A
    CALL Z, _JoyDown

    ; ##########################################
    ; Row T...Q
    LD A, _KB_T_TO_Q_HFB
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A.

    ; Key Q
    BIT 0, A
    CALL Z, _JoyUp

    ; ##########################################
    ; Row H, J, K, L, ENTER
    LD A, _KB_H_TO_ENT_HBF
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A.

    ; Key L
    BIT 1, A
    PUSH AF
    CALL Z, _JoyRight
    POP AF

    ; Key K
    BIT 2, A
    CALL Z, _JoyLeft

    ; ##########################################
    _JoyMoveEnd

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   GameOptionsInput                       ;
;----------------------------------------------------------;
; Options are active durign pause, movement is not.
GameOptionsInput

    ; ##########################################
    ; Read Kempston input
    LD A, _JOY_MASK_H20                         ; Activate joystick register.
    IN A, (_JOY_REG_H1F)                        ; Read joystick input into A.
    ; Joystick fire B
    PUSH AF
    BIT 4, A
    CALL NZ, _Fire
    POP AF

    PUSH AF
    CP 64
    CALL Z, _NextSong
    POP AF

    PUSH AF
    CP 128
    CALL Z, _Pause
    POP AF

    ; Joystick fire C
    BIT 5, A
    CALL NZ, _ThrowGranade

    ; ##########################################
    ; Row: V, C, X, Z, SHIFT
    
    ; Key Fire (Z)
    LD A, _KB_V_TO_SH_HFE
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A.

    ; Key Z
    BIT 1, A
    CALL Z, _Fire

    ; ##########################################
    ; Row: H, J, K, L, ENTER

    ; Key ENTER
    LD A, _KB_H_TO_ENT_HBF
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A.
    BIT 0, A                                    ; Bit 0 reset -> ENTER pressed.
    CALL Z, _Fire

    ; ##########################################
    ; Row: Y...P

    ; Key P
    LD A, _KB_P_TO_Y_HDF
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A.
    PUSH AF                                     ; Keep A on the stack to avoid rereading the same input.
    BIT 0, A                                    ; P
    CALL Z, _Pause
    POP AF

    ; ##########################################
    ; Row: G, F, D, S, T, A

    LD A, _KB_G_TO_A_HFD
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A.

    ; Key F
    BIT 3, A                                    ; F
    CALL Z, _Key_F

    IFDEF DEBUG_KEYS
    ; ##########################################
    ; Row T...Q
    LD A, _KB_T_TO_Q_HFB
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A.

    ; Key R
    PUSH AF                                     ; Keep A on the stack to avoid rereading the same input.
    BIT 3, A                                    ; R
    CALL Z, _Key_R
    POP AF

    ; Key Q
    BIT 0, A                                    ; Q
    CALL Z, _Key_Q
    ENDIF

    ; ##########################################
    ; Row: B, M, M, FULL-STOP, SPACE

    ; Key N
    LD A, _KB_B_TO_SPC_H7F
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A.
    PUSH AF                                     ; Keep A on the stack to avoid rereading the same input.
    BIT 3, A                                    ; N
    CALL Z, _NextSong
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
    OR A                                        ; Same as CP 0, but faster.
    JR NZ, .notBreak

    ; SHIFT pressed?
    LD A, _KB_V_TO_SH_HFE                       ; Row: V, C, X, Z, SHIFT
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A.

    BIT 0, A                                    ; Bit 0 reset -> SHIFT pressed.
    JR NZ, .notBreak

    CALL _Key_Break

.notSpace
.notBreak

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

    IFDEF DEBUG_KEYS
;----------------------------------------------------------;
;                        _Key_Q                            ;
;----------------------------------------------------------;
_Key_Q

    CALL dbs.SetupInGameMusicBank
    LD A, (aml.gameMusicCnt)
    DEC A
    _DEB

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        _Key_R                            ;
;----------------------------------------------------------;
_Key_R

    CALL ki.CanProcessKeyInput
    RET NZ

    dbs.SetupRocketBank
    CALL roa.AssemblyRocketForDebug

    RET                                         ; ## END of the function ##

    ENDIF

;----------------------------------------------------------;
;                      _NextSong                           ;
;----------------------------------------------------------;
_NextSong

    CALL ki.CanProcessKeyInput
    RET NZ

    dbs.SetupCodeMusicBank
    CALL aml.NextGameSong

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        _Key_M                            ;
;----------------------------------------------------------;
_Key_M

    CALL ki.CanProcessKeyInput
    RET NZ

    dbs.SetupCodeMusicBank
    CALL aml.FlipOnOff

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        _Pause                            ;
;----------------------------------------------------------;
; Pause game
_Pause

    CALL ki.CanProcessKeyInput
    RET NZ

    LD A, (ms.mainState)

    CP ms.MS_PAUSE_D30
    JR Z, .pause

    LD A, ms.MS_PAUSE_D30
    CALL ms.SetMainStateAndBackup
    
    dbs.SetupCodeMusicBank
    CALL aml.MusicOff
    RET

.pause

    dbs.SetupCodeMusicBank
    CALL aml.MusicOn
    CALL ms.RestoreMainState

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        _Key_F                            ;
;----------------------------------------------------------;
_Key_F

    CALL ki.CanProcessKeyInput
    RET NZ

    CALL jw.FlipFireFx

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      _Key_Break                          ;
;----------------------------------------------------------;
_Key_Break

    CALL ki.CanProcessKeyInput
    RET NZ

    LD A, (gid.breakCnt)
    INC A
    LD (gid.breakCnt), A

    CP gid.BREAK_CNT_D3
    RET NZ

    ; The break has been pressed long enough to exit the game.
    CALL gc.ExitToLoadMainMenu

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        _JoyRight                         ;
;----------------------------------------------------------;
_JoyRight

    ; Update temp state
    LD A, (gid.joyDirection)
    SET gid.MOVE_RIGHT_BIT_D1, A
    LD (gid.joyDirection), A

    ; ##########################################
    LD A, (gid.moveDistance)
    CP gid.MOVE_2PX
    JR Z, .move2Px
    CALL jm.JoyMoveRight
    RET
.move2Px
    CALL jm.JoyMoveRight
    CALL jm.JoyMoveRight

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       _JoyLeft                           ;
;----------------------------------------------------------;
_JoyLeft

    ; Update #joyDirection state
    LD A, (gid.joyDirection)
    SET gid.MOVE_LEFT_BIT_D0, A
    LD (gid.joyDirection), A

    ; ##########################################
    LD A, (gid.moveDistance)
    CP gid.MOVE_2PX
    JR Z, .move2Px
    CALL jm.JoyMoveLeft
    RET
.move2Px
    CALL jm.JoyMoveLeft
    CALL jm.JoyMoveLeft

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                          _JoyUp                          ;
;----------------------------------------------------------;
_JoyUp

    ; Update #joyDirection state
    LD A, (gid.joyDirection)
    SET gid.MOVE_UP_BIT_D2, A  
    LD (gid.joyDirection), A

    ; ##########################################
    LD A, (gid.moveDistance)
    CP gid.MOVE_2PX
    JR Z, .move2Px
    CALL jm.JoyMoveUp
    RET
.move2Px
    CALL jm.JoyMoveUp
    CALL jm.JoyMoveUp

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        _JoyDown                          ;
;----------------------------------------------------------;
_JoyDown

    ; Update #joyDirection state
    LD A, (gid.joyDirection)
    SET gid.MOVE_DOWN_BIT_D3, A
    LD (gid.joyDirection), A

    ; ##########################################
    LD A, (gid.moveDistance)
    CP gid.MOVE_2PX
    JR Z, .move2Px
    CALL jm.JoyMoveDown
    RET
.move2Px
    CALL jm.JoyMoveDown
    CALL jm.JoyMoveDown

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     _JoyDownRelease                      ;
;----------------------------------------------------------;
_JoyDownRelease

    CALL jm.JoyMoveDownRelease

    RET                                         ; ## END of the function ## 


;----------------------------------------------------------;
;                         _Fire                            ;
;----------------------------------------------------------;
_Fire

    XOR A
    LD (gid.fireOffCnt), A

    CALL jw.FirePress

    RET                                         ; ## END of the function ##


;----------------------------------------------------------;
;                    _ThrowGranade                         ;
;----------------------------------------------------------;
_ThrowGranade

    CALL ki.CanProcessKeyInput
    RET NZ

    CALL gr.UseGrenade

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE