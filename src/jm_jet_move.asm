/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                     Jetman Movement                      ;
;----------------------------------------------------------;
    MODULE jm

; Hovering/Standing
; The counter increments with each frame when no up/down is pressed.
; When it reaches #HOVER_START_D250, Jetman will start hovering.
jetInactivityCnt        DB 0

;----------------------------------------------------------;
;----------------------------------------------------------;
;                        MACROS                            ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                     _JoyCntEnabled                       ;
;----------------------------------------------------------;
; Disable joystick and, therefore, control over the Jetman.
; Return:
;  - YES: Z is reset (JP Z).
;  - NO:  Z is set (JP NZ).
    MACRO _JoyCntEnabled

    LD A, (gid.joyOffCnt)
    CP 0
    JR Z, .joyEnabled                           ; Jump if joystick is enabled -> #joyOffCnt > 0.

    ; ##########################################
    ; Joystick is disabled
    DEC A                                       ; Decrement disabled counter.
    LD (gid.joyOffCnt), A

    ; Joystick will enable on the next loop?
    CP 0
    JR NZ, .afterEnableCheck

    ; Yes, this was the last blocking loop.
    gc.JoyWillEnable
.afterEnableCheck   

    ; ##########################################
    ; Allow input processing if Jetman is close to the platform and #joyOffCnt is > 0. It allows, for example, to move left/right when
    ; hitting the platform from below and pressing up + left (or right). 
    ; We can have the following situation: Jetman is below the platform and is not bumping off anymore because it's close long enough.
    ; The player still keeps pressing up and simultaneously, let's say, left. We want to allow movement to the left, but not up.
    ; Because #joyOffCnt > 0, the function #_MainLoop000OnDisabledJoy will be executed. It will move Jetman one pixel down, which is good
    ; because pressing up has moved him one pixel up. To allow movement left, we ignore #joyOffBump because it is so small that we know
    ; that Jetman is right below the platform. Keeping #joyOffCnt > 0 reverses Joystick's movement up, ignoring #joyOffBump allows movement to the left.

    LD A, (pl.joyOffBump)
    CP pl.PL_BUMP_JOY_DEC_D1+1
    JR C, .joyEnabled

    OR 1                                        ; Return NO (Z set).
    JR .end                                     ; Do not process input, as the joystick is disabled.

.joyEnabled                                     ; Process input.
    XOR A                                       ; Return YES (Z is reset).

.end
    ENDM                                        ; ## END of the macro #

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PUBLIC FUNCTIONS                       ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                      #JoyMoveUp                          ;
;----------------------------------------------------------;
JoyMoveUp

    CALL _CanJetMove
    RET NZ                                      ; Do not process input on disabled joystick.

    ; ##########################################
    ; Direction change: down -> up.
    LD A, (gid.jetDirection)
    AND gid.MOVE_UP_MASK                        ; Are we moving Up already?
    CP gid.MOVE_UP_MASK
    JR Z, .afterDirectionChange

    ; We have direction change!
    LD A, (gid.jetDirection)                    ; Update #jetState by resetting down and setting up.
    RES gid.MOVE_DOWN_BIT, A
    SET gid.MOVE_UP_BIT, A
    LD (gid.jetDirection), A
.afterDirectionChange

    ; ##########################################
    CALL _SholdProcessJoyOnOverheat
    RET NZ

    ; ##########################################
    CALL _JoystickMoves

    ; ##########################################
    ; Decrement Y position.
    LD A, (jpo.jetY)    
    CP _GSC_Y_MIN_D15                           ; Do not decrement if Jetman has reached the top of the screen.
    JR Z, .afterDec
    CALL jpo.DecJetY
.afterDec

    ; ##########################################
    gc.JetPlatformTakesOff                      ; Transition from walking to flaying.

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      JoyMoveRight                        ;
;----------------------------------------------------------;
JoyMoveRight

    CALL _CanJetMove
    RET NZ                                      ; Do not process input on disabled joystick.

    ; ##########################################
    ; Direction change: left -> right
    LD A, (gid.jetDirection)
    AND gid.MOVE_RIGHT_MASK                     ; Are we moving right already?
    CP gid.MOVE_RIGHT_MASK
    JR Z, .afterDirectionChange

    ; We have direction change!
    LD A, (gid.jetDirection)                    ; Reset left and set right.
    RES gid.MOVE_LEFT_BIT, A
    SET gid.MOVE_RIGHT_BIT, A
    LD (gid.jetDirection), A
.afterDirectionChange

    ; ##########################################
    CALL _SholdProcessJoyOnOverheat
    RET NZ

    ; ##########################################
    CALL _JoystickMoves
    CALL _StandToWalk
    CALL jpo.IncJetX

    ; ##########################################
    ; Fall from the platform?
    CALL pl.JetFallingFromPlatform

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       JoyMoveLeft                        ;
;----------------------------------------------------------;
JoyMoveLeft

    CALL _CanJetMove
    RET NZ                                      ; Do not process input on disabled joystick.

    ; ##########################################
    ; Direction change: right -> left
    LD A, (gid.jetDirection)
    AND gid.MOVE_LEFT_MASK                      ; Are we moving left already?
    CP gid.MOVE_LEFT_MASK
    JR Z, .afterDirectionChange                 ; Jetman is moving left already -> end.

    ; We have direction change! 
    LD A, (gid.jetDirection)                    ; Reset right and set left.
    RES gid.MOVE_RIGHT_BIT, A
    SET gid.MOVE_LEFT_BIT, A
    LD (gid.jetDirection), A
.afterDirectionChange

    ; ##########################################
    CALL _SholdProcessJoyOnOverheat
    RET NZ

    ; ##########################################
    CALL _JoystickMoves 
    CALL _StandToWalk
    CALL jpo.DecJetX

    ; ##########################################
    ; Fall from the platform?
    CALL pl.JetFallingFromPlatform

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       JoyMoveDown                        ;
;----------------------------------------------------------;
JoyMoveDown

    CALL _CanJetMove
    RET NZ                                      ; Do not process input on disabled joystick.

    ; ##########################################
    ; Cannot move down when walking
    LD A, (jt.jetGnd)
    CP jt.JT_STATE_INACTIVE
    RET NZ

    ; ##########################################
    ; Direction change? 
    LD A, (gid.jetDirection)
    AND gid.MOVE_DOWN_MASK                      ; Are we moving down already?
    CP gid.MOVE_DOWN_MASK
    JR Z, .afterDirectionChange

    ; We have direction change!
    LD A, (gid.jetDirection)                    ; Update #jetState by resetting Up/Hover and setting down.
    RES gid.MOVE_UP_BIT, A
    SET gid.MOVE_DOWN_BIT, A    
    LD (gid.jetDirection), A
    
    CALL js.ChangeJetSpriteOnFlyDown
.afterDirectionChange

    ; ##########################################
    CALL _SholdProcessJoyOnOverheat
    RET NZ

    ; ##########################################
    CALL _JoystickMoves

    ; ##########################################
    ; Increment Y position
    LD A, (jpo.jetY)
    CP _GSC_JET_GND_D217                        ; Do not increment if Jetman has reached the ground.
    JR Z, .afterInc
    CALL jpo.IncJetY                            ; Move Jetman 1px down.
.afterInc   

    ; ##########################################
    ; Landing on the ground
    LD A, (jpo.jetY)
    CP _GSC_JET_GND_D217
    CALL Z, pl.JetLanding                       ; Execute landing on the ground if Jetman has reached the ground.

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  JoyMoveDownRelease                      ;
;----------------------------------------------------------;
JoyMoveDownRelease

    CALL js.ChangeJetSpriteOnFlyUp

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                JoystickMoveProcessed                    ;
;----------------------------------------------------------;
; It gets executed as a last procedure after the input has been processed, regardless of whether there was movement, or not.
JoystickMoveProcessed

    CALL _CanJetMove
    RET NZ                                      ; Do not process input on disabled joystick.

    ; ##########################################
    ; Ignore the situation when Jetman stands on the ground and only down is present. This does not count as movement.
    LD A, (jt.jetGnd)
    CP jt.JT_STATE_INACTIVE
    JR Z, .afterDownOnGround

    ; Jetman is on the ground, but is only down key pressed (without left/right)?
    LD A, (gid.joyDirection)
    CP gid.MOVE_DOWN_MASK
    JR Z, .inactive                             ; Jump if, Jetman is on the ground and only down is pressed, we have inactivity, skip other checks.

.afterDownOnGround
    
    ; ##########################################
    ; Is there a movement?
    LD A, (gid.joyDirection)
    CP gid.MOVE_INACTIVE
    RET NZ                                      ; Jump if there is a movement.

.inactive

    gc.MovementInactivity

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;               _SholdProcessJoyOnOverheat                 ;
;----------------------------------------------------------;
; Slow down joystick input and, therefore, the speed of Jetman's movement when jetpack has overheated.
; Return:
;  - YES: Process joystick input, Z is reset (JP Z).
;  - NO:  Disable joystick input processing for this loop, Z is set (JP NZ).
_SholdProcessJoyOnOverheat
    LD A, (jt.jetState)
    CP jt.JETST_OVERHEAT
    JR NZ, .yes

    LD A, (jt.jetGnd)
    CP jt.JT_STATE_INACTIVE
    JR NZ, .yes

    LD A, (mld.counter000FliFLop)
    CP _GC_FLIP_ON_D1
    JR Z, .delayReached

    ; Return because #joyDelayCnt !=  #pl.PL_JOY_DELAY
    OR 1                                        ; Return NO (Z set).
    RET
.delayReached                                   ; Delay counter has been reached.

    XOR A                                       ; Set A to 0.
    LD (gid.joyOverheatDelayCnt), A             ; Reset delay counter.

    ; Process input, because counter has been reached.

.yes
    XOR A                                       ; Return YES (Z is reset).

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     _JoystickMoves                       ;
;----------------------------------------------------------;
; Method gets called on any joystick movement (only real key press), but not fire pressed.
_JoystickMoves

    CALL pl.ResetJoyOffBump

    CALL dbs.SetupRocketBank
    CALL roa.UpdateRocketOnJetmanMove
    
    CALL pl.JetPlatformHitOnJoyMove

    ; ##########################################
    ; Reset inactivity counter as we have movement.
    XOR A                                       ; Set A to 0
    LD (jetInactivityCnt), A

    ; ##########################################
    ; Transition from hovering to flying?
    LD A, (jt.jetAir)
    CP jt.AIR_HOOVER                            ; Is Jetman hovering?
    JR NZ, .afterHovering                       ; Jump if not hovering.

    ; Jetman is hovering, but we have movement, so switch state to fly.
    LD A, jt.AIR_FLY
    CALL jt.SetJetStateAir
    
    ; Switch to flaying animation
    LD A, js.SDB_FLY
    CALL js.ChangeJetSpritePattern
.afterHovering  

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     _StandToWalk                         ; 
;----------------------------------------------------------;
; Transition from standing/landing on ground to walking
_StandToWalk

    LD A, (jt.jetGnd)
    CP jt.JT_STATE_INACTIVE
    RET Z                                       ; Exit if Jetman is not on the ground.

    ; Jetman is on the ground, is he already walking?
    LD A, (jt.jetGnd)   
    CP jt.GND_WALK
    RET Z                                       ; Exit if Jetman is already walking.

    ; Jetman is standing and starts walking now.
    LD A, jt.GND_WALK
    CALL jt.SetJetStateGnd
    
    LD A, js.SDB_WALK_ST
    CALL js.ChangeJetSpritePattern

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      _CanJetMove                         ;
;----------------------------------------------------------;
; Return:
;  - YES: Z is reset (JP Z).
;  - NO:  Z is set (JP NZ).
_CanJetMove

    _JoyCntEnabled
    RET NZ

    ; ##########################################
    ; Joystick disabled if Jetman is inactive.
    LD A, (jt.jetState)
    CP jt.JT_STATE_INACTIVE
    JR NZ, .jetActive

    ; Do not process input.
    OR 1                                        ; Return NO (Z set).
    RET
.jetActive

    ; ##########################################
    LD A, (jt.jetState)
    CP jt.JETST_RIP
    JR NZ, .afterRip                            ; Do not process input if Jetman is dying.

    ; Do not process input, Jet is dying.
    OR 1                                        ; Return NO (Z set).
    RET
.afterRip

    ; ##########################################
    ; Process input
    XOR A                                       ; Return YES (Z is reset).

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE