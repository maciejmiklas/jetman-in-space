/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                      Jetman Data                         ;
;----------------------------------------------------------;
    MODULE gid

; The counter turns off the joystick for a few iterations. Each call #JetMovementInput decrements it by one
; It's used for effects like bumping from the platform's edge or falling.
joyOffCnt           DB 0

; Possible move directions##
MOVE_INACTIVE           = 0                     ; No movement.

MOVE_LEFT_BIT           = 0                     ; Bit 0 - Jetman moving left, facing left.
MOVE_LEFT_MASK          = %0000'0001

MOVE_RIGHT_BIT          = 1                     ; Bit 1 - Jetman moving right, facing right.
MOVE_RIGHT_MASK         = %0000'0010

MOVE_UP_BIT             = 2                     ; Bit 2 - Jetman moving up, facing up.
MOVE_UP_MASK            = %0000'0100

MOVE_DOWN_BIT           = 3                     ; Bit 3 - Jetman moving down, facing up.
MOVE_DOWN_MASK          = %0000'1000

MOVE_MSK_LR             = %0000'0011            ; Left + Right

; This byte holds the direction in which Jetman is facing(#MOVE_XXX_MASK). It takes movement bits as arguments but gets updated only when 
; the opposite direction changes. Pressing left will reset the right bit and set left; pressing up will reset the down bit and set up. 
; However, only opposite directions are reset, so for example, when Jetman is facing right, and the right button is released, 
; it still looks right; now, when up is pressed, it will look upright, and the right will be reset only when left is pressed. 
; Prolonged inactivity resets #jetDirection to #MOVE_INACTIVE.
jetDirection            DB MOVE_INACTIVE  ; Jetman initially hovers, no movement.

; Holds currently pressed direction button. State will be updated right at the beginning of each joystick loop.
joyDirection            DB MOVE_INACTIVE

; Holds #joyDirection from previous loop
joyPrevDirection        DB MOVE_INACTIVE

joyOverheatDelayCnt     DB 0                    ; The delay counter for joystick input and Jetman movement speed when jetpack overheats.

; Button state keeps state for 8 buttons.
; The button state for the current game loop is reset before the keys are processed in the current game loop.
gameInputState          DB 0
gameInputPrevState      DB 0                    ; Keeps state from the previous game loop.
BS_FIRE_BIT             = 0

breakCnt                DB 0
BREAK_CNT               = 50

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PUBLIC FUNCTIONS                       ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                  gid.ResetKeysState                      ;
;----------------------------------------------------------;
    MACRO gid.ResetKeysState

    XOR A
    LD (gid.joyOffCnt), A
    LD (gid.jetDirection), A
    LD (gid.joyDirection), A
    LD (gid.joyPrevDirection), A
    LD (gid.joyOverheatDelayCnt), A
    LD (gid.gameInputState), A
    LD (gid.gameInputPrevState), A
    LD (gid.breakCnt), A

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE
