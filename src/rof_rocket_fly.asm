/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                      Flying the Rocket                   ;
;----------------------------------------------------------;
    MODULE rof
    ; TO USE THIS MODULE: CALL dbs.SetupRocketBank

RO_FLY_DELAY_D8         = 8
RO_FLY_DELAY_DIST_D5    = 5

; Max rocket fly distance, when reached, it will explode.
EXPLODE_Y_HI_H4         = $F0
EXPLODE_Y_LO_H7E        = $FF

rocketExplodeCnt        DB 0                    ; Counts from 1 to RO_EXPLODE_SIZE (both inclusive).
RO_EXPLODE_SIZE         = 28                    ; Amount of explosion frames stored in #rocketExplodeDB[1-3].

rocketExhaustCnt        DB 0                    ; Counts from 0 (inclusive) to #RO_EXHAUST_MAX (exclusive).
rocketDistance          DW 0                    ; Increments with every rocket move when the rocket is flying towards the next planet.
rocketDelayDistance     DB 0                    ; Counts from 0 to RO_FLY_DELAY_DIST_D5, increments with every rocket move (when #rocketFlyDelay resets).
rocketFlyDelay          DB RO_FLY_DELAY_D8      ; Counts from #rocketFlyDelayCnt to 0, decrement with every skipped rocket move.
rocketFlyDelayCnt       DB RO_FLY_DELAY_D8      ; Counts from RO_FLY_DELAY_D8 to 0, decrements when #rocketDelayDistance resets.

FLY_SOUND_REPEAT        = 20
soundRepeatDelay        DB FLY_SOUND_REPEAT

DELAY_TILE              = 5
decTileDelayCnt         DB DELAY_TILE

roctExhaustMax                                 ; Sprite IDs for exhaust at max speed.
    DB 53,57,62,  57,62,53,  62,53,57,  53,62,57,  62,57,53,  57,53,62

roctExhaustPoint        DW roctExhaustMax

roctExhaustSlow                                ; Sprite IDs for exhaust at slow speed.
    DB 58,59,63,  58,63,59,  63,58,59,  58,59,63,  58,59,63,  59,58,63

RO_EXHAUST_MAX          = 18

ROC_Y_MIN_D70           = 70
ROC_Y_MAX_D220          = 240

ROC_X_MIN_D10           = 15

; $12C = 300
ROC_Y_MAX_LO_H36        = $2C
ROC_Y_MAX_HI_H1         = $1

;----------------------------------------------------------;
;----------------------------------------------------------;
;                        MACROS                            ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                  _UpdateRocketFlyPhase                   ;
;----------------------------------------------------------;
; Input:
;  - HL: current #rocketDistance value.
    MACRO _UpdateRocketFlyPhase

    ; Phase 2?
    LD A, H
    CP ro.PHASE_2_ALTITUDE_HI
    JR NZ, .not2

    LD A, L
    CP ro.PHASE_2_ALTITUDE_LO
    JR NZ, .not2

    ; Rocket has reached pahse 2.
    LD A, ro.PHASE_2
    LD (ro.rocketFlyPhase), A
    CALL gc.RocketFLyStartPhase2
.not2

    ; ##########################################
    ; Phase 3?
    LD A, H
    CP ro.PHASE_3_ALTITUDE_HI
    JR NZ, .not3

    LD A, L
    CP ro.PHASE_3_ALTITUDE_LO
    JR NZ, .not3

    ; Rocket has reached pahse 3.
    LD A, ro.PHASE_3
    LD (ro.rocketFlyPhase), A
.not3

    ; ##########################################
    ; Phase 4?
    LD A, H
    CP ro.PHASE_4_ALTITUDE_HI
    JR NZ, .not4

    LD A, L
    CP ro.PHASE_4_ALTITUDE_LO
    JR NZ, .not4

    ; Rocket has reached pahse 4.
    LD A, ro.PHASE_4
    LD (ro.rocketFlyPhase), A
    CALL _RocketFLyStartPhase4
    CALL gc.RocketFLyStartPhase4

.not4

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                  _MoveFlyingRocket                       ;
;----------------------------------------------------------;
    MACRO _MoveFlyingRocket

    ; Slow down rocket movement speed while taking off.
    ; The rocket slowly accelerates, and the whole process is divided into sections. During each section, the rocket travels some distance 
    ; with a given delay. When the current section ends, the following section begins, but with decrement delay. During each section, 
    ; the rocket moves by the same amount of pixels on the Y axis, only the delay decrements with each following section.

    ; #rocketFlyDelayCnt == 0 when the whole delay sequence is over.
    LD A, (rocketFlyDelayCnt)
    OR A                                        ; Same as CP 0, but faster.
    JR Z, .afterDelay

    ; Decrement delay counter.
    LD A, (rocketFlyDelay)
    DEC A
    LD (rocketFlyDelay), A

    OR A                                        ; Same as CP 0, but faster.
    JP NZ, .end                                 ; Return if delay counter has not been reached.

    ; The counter reached 0, reset it and increment the distance counter.
    LD A, (rocketFlyDelayCnt)
    LD (rocketFlyDelay), A

    LD A, (rocketDelayDistance)
    INC A
    LD (rocketDelayDistance), A

    CP RO_FLY_DELAY_DIST_D5
    JR NZ, .afterDelay                          ; Jump if rocket should still move with current delay.

    ; The rocket traveled far enough, decrement the delay for the next section.
    LD A, (rocketFlyDelayCnt)
    DEC A
    LD (rocketFlyDelayCnt), A
    LD (rocketFlyDelay), A

    XOR A
    LD (rocketDelayDistance), A
.afterDelay

     ; ##########################################
     ; Execute when in phase 2 or 3
    LD A, (ro.rocketFlyPhase)
    PUSH AF
    AND ro.PHASE_2_3
    JR Z, .afterBoosting

    CALL gc.RocketFLyPhase2and3
    POP AF
    JR .notFlygin
.afterBoosting
    POP AF

    CP ro.PHASE_4
    JR C, .notFlygin
    CALL gc.RocketFLyPhase4
.notFlygin

    ; ##########################################
    ; Increment total distance.
    LD HL, (rocketDistance)
    INC HL
    LD (rocketDistance), HL

    PUSH HL
    _UpdateRocketFlyPhase
    POP HL

    ; ##########################################
    ; The current position of rocket elements is stored in #ro.rocAssemblyX and #ro.RO.Y 
    ; It was set when elements were falling towards the platform. Now, we need to decrement Y to animate the rocket.

    LD IX, (ro.rocketElPtr)                               ; Load the pointer to rocket into IX.

    ; ##########################################
    ; Did the rocket reach the middle of the screen, and should it stop moving?
    LD A, (ro.rocketFlyPhase)
    CP ro.PHASE_3
    JR C, .keepMoving

    ; Do not move the rocket anymore, but keep updating the lower part to keep blinking animation.
    LD D, (IX + ro.RO.SPRITE_REF)
    CALL ro.UpdateRocketSpritePattern

    JR .end

    ; Keep moving
.keepMoving

    ; ##########################################
    ; Update Y position.
    LD A, (ro.rocY)
    DEC A
    LD (ro.rocY), A

    CALL ro.UpdateRocketPosition

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                _ControlFlyingRocket                      ;
;----------------------------------------------------------;
    MACRO _ControlFlyingRocket

    CALL _ProcessJoystickInput

    ; ##########################################
    ; Increment total distance.
    LD HL, (rocketDistance)
    INC HL
    LD (rocketDistance), HL

    ; ##########################################
    ; Has the rocket reached the asteroid, and should the explosion sequence begin?
    LD A, H
    CP EXPLODE_Y_HI_H4
    JR NZ, .notAtExpolodeDistance

    LD A, L
    CP EXPLODE_Y_LO_H7E
    JR C, .notAtExpolodeDistance

    CALL StartRocketExplosion
    JR .end
.notAtExpolodeDistance

    ; ##########################################
    CALL ro.UpdateRocketPosition
    CALL gc.RocketFLyPhase4

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PUBLIC FUNCTIONS                       ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;               ResetAndDisableFlyRocket                   ;
;----------------------------------------------------------;
ResetAndDisableFlyRocket

    XOR A
    LD (rocketExplodeCnt), A
    LD (rocketDelayDistance), A
    LD (rocketExhaustCnt), A
    LD (ro.rocketFlyPhase), A

    LD HL, 0
    LD (rocketDistance), HL

    ; ##########################################
    LD A, RO_FLY_DELAY_D8
    LD (rocketFlyDelay), A
    LD (rocketFlyDelayCnt), A
    
    ; ##########################################
    LD A, FLY_SOUND_REPEAT
    LD (soundRepeatDelay), A                    ;Set the count to max so the sound plays immediately when the rocket takes off.

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    FlyRocketSound                        ;
;----------------------------------------------------------;
FlyRocketSound

    ; Loop rocket sound by repeating it every few game loops.
    LD A, (soundRepeatDelay)
    CP FLY_SOUND_REPEAT
    JR Z, .play
    INC A
    LD (soundRepeatDelay), A
    RET

.play
    XOR A
    LD (soundRepeatDelay), A

    CALL gc.PlayRocketSound

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  RocketFLyStartPhase1                    ;
;----------------------------------------------------------;
RocketFLyStartPhase1

    LD A, ro.PHASE_1
    LD (ro.rocketFlyPhase), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        FlyRocket                         ;
;----------------------------------------------------------;
FlyRocket

    LD A, (ro.rocketFlyPhase)
    CP ro.PHASE_4
    JR NZ,.notPhase4

    _ControlFlyingRocket

    JP .afterPhaseCase
.notPhase4

    PUSH AF
    _MoveFlyingRocket
    POP AF

     ; ##########################################
     ; Shake tiles
     CP ro.PHASE_1
     JR NZ, .afterPhaseCase
     CALL ti.ShakeTilemap

.afterPhaseCase

    ; ##########################################
    ; Set X/Y coordinates for flames coming out of the exhaust.
    LD A, _EXHAUST_SPRID_D83
    NEXTREG _SPR_REG_NR_H34, A                  ; Set the ID of the sprite for the following commands.

    ; Sprite X coordinate.
    CALL ro.SetRocketXSpriteCoordinate

    ; Sprite Y coordinate
    LD A, (ro.rocY)
    ADD ro.OFS_FLAME_D16
    NEXTREG _SPR_REG_Y_H36, A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  StartRocketExplosion                    ;
;----------------------------------------------------------;
; Start explosion sequence. The rocket explodes when the state is flying and counter above zero.
StartRocketExplosion

    LD A, 1
    LD (rocketExplodeCnt), A

    ; ##########################################
    ; Hide exhaust
    LD A, _EXHAUST_SPRID_D83                     ; Hide sprite on display.
    sp.SetIdAndHideSprite

    ; ##########################################
    ; Update state
    LD A, ro.ROST_EXPLODE_D102
    LD (ro.rocketState), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    BlinkFlyingRocket                     ;
;----------------------------------------------------------;
BlinkFlyingRocket

    LD A, ro.EL_EXH_D1
    CALL ro.MoveIXtoGivenRocketElement

    ; Set sprite pattern - one for flip, one for flop -> rocket will blink.
    LD A, (mld.counter008FliFLop)
    CP _GC_FLIP_ON_D1
    JR Z, .flip
    LD A, ro.SPR_PAT_READY1_D60
    JR .afterSet
.flip
    LD A, ro.SPR_PAT_READY2_D61
.afterSet

    LD (IX + ro.RO.SPRITE_REF), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                AnimateRocketExplosion                    ;
;----------------------------------------------------------;
AnimateRocketExplosion

    ; Is the exploding sequence over?
    LD A, (rocketExplodeCnt)
    CP RO_EXPLODE_SIZE
    JR Z, .explodingEnds

    ; Nope, keep exploding.
    ; ##########################################
    ; FX
    CALL gc.RocketExpolodes
    
    ; ##########################################
    ; Animation for the top rockets element.
    LD IX, (ro.rocketElPtr)
    LD A, ro.EL_TIP_D3
    CALL ro.MoveIXtoGivenRocketElement

    ; Move HL to current frame.
    LD DE, (rocketExplodeCnt)
    LD D, 0                                     ; Reset D, we have an 8-bit counter here.
    LD HL, rod.rocketExplodeDB3
    DEC DE                                      ; Counter starts at 1.
    ADD HL, DE
    LD D, (HL)
    CALL ro.UpdateRocketSpritePattern

    ; ##########################################
    ; Animation for the middle rockets element.
    LD IX, (ro.rocketElPtr)
    LD A, ro.EL_MID_D2
    CALL ro.MoveIXtoGivenRocketElement

    ; Move HL to current frame.
    LD DE, (rocketExplodeCnt)
    LD D, 0                                     ; Reset D, we have an 8-bit counter here.
    LD HL, rod.rocketExplodeDB2
    DEC DE                                      ; Counter starts at 1.
    ADD HL, DE
    LD D, (HL)
    CALL ro.UpdateRocketSpritePattern

    ; ##########################################
    ; Animation for the bottom rockets element.
    LD IX, (ro.rocketElPtr)
    LD A, ro.EL_EXH_D1
    CALL ro.MoveIXtoGivenRocketElement

    ; Move HL to current frame.
    LD DE, (rocketExplodeCnt)
    LD D, 0                                     ; Reset D, we have an 8-bit counter here.
    LD HL, rod.rocketExplodeDB1
    DEC DE                                      ; Counter starts at 1.
    ADD HL, DE
    LD D, (HL)
    CALL ro.UpdateRocketSpritePattern

    ; ##########################################
    ; Update explosion frame counter.
    LD A, (rocketExplodeCnt)
    INC A
    LD (rocketExplodeCnt), A

    RET
.explodingEnds

    ; sequence is over, load next level.
    CALL gc.LoadNextLevel

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  AnimateRocketExhaust                    ;
;----------------------------------------------------------;
AnimateRocketExhaust

    ; Increment sprite pattern counter.
    LD A, (rocketExhaustCnt)
    INC A
    CP RO_EXHAUST_MAX
    JP NZ, .afterIncrement
    XOR A                                       ; Reset counter.
.afterIncrement 

    LD (rocketExhaustCnt), A                    ; Store current counter (increment or reset).

    ; Set the ID of the sprite for the following commands.
    LD A, _EXHAUST_SPRID_D83
    NEXTREG _SPR_REG_NR_H34, A

    ; Load sprite pattern to A.
    LD HL, (roctExhaustPoint)
    LD A, (rocketExhaustCnt)
    ADD HL, A
    LD A, (HL)

    ; Set sprite pattern.
    OR _SPR_ATTR3_SHOW                        ; Set show bit.
    NEXTREG _SPR_REG_ATR3_H38, A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                 _RocketFLyStartPhase4                    ;
;----------------------------------------------------------;
_RocketFLyStartPhase4

    ; Setup joystick
    CALL ki.ResetKeyboard

    LD DE, _JoyDown
    LD (ki.callbackDown), DE

    LD DE, _JoyUp
    LD (ki.callbackUp), DE

    LD DE, _JoyLeft
    LD (ki.callbackLeft), DE

    LD DE, _JoyRight
    LD (ki.callbackRight), DE

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 _ProcessJoystickInput                    ;
;----------------------------------------------------------;
_ProcessJoystickInput

    LD HL, roctExhaustMax
    LD (roctExhaustPoint), HL

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

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                         _JoyUp                           ;
;----------------------------------------------------------;
_JoyUp

    LD A, (ro.rocY)
    CP ROC_Y_MIN_D70
    RET C

    DEC A
    DEC A
    LD (ro.rocY), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       _JoyDown                           ;
;----------------------------------------------------------;
_JoyDown

    LD A, (ro.rocY)
    CP ROC_Y_MAX_D220
    RET NC

    INC A
    INC A
    LD (ro.rocY), A

    CALL ros.PauseScrollStars

    LD HL, roctExhaustSlow
    LD (roctExhaustPoint), HL

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      _JoyLeft                            ;
;----------------------------------------------------------;
_JoyLeft

    LD BC, (ro.rocX)
    LD A, B
    OR A                                        ; Same as CP 0, but faster.
    JR NZ, .afterMinX
    LD A, C
    CP ROC_X_MIN_D10
    RET C
.afterMinX

    DEC BC
    DEC BC
    LD (ro.rocX), BC

    ; ##########################################
    LD A, (decTileDelayCnt)
    DEC A
    OR A                                        ; Same as CP 0, but faster.
    JR NZ, .afterDec

    CALL ros.DecTileOffsetX

    LD A, DELAY_TILE
.afterDec
    LD (decTileDelayCnt), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      _JoyRight                           ;
;----------------------------------------------------------;
_JoyRight

    LD BC, (ro.rocX)
    LD A, B
    CP ROC_Y_MAX_HI_H1
    JR NZ, .afterMaxX
    LD A, C
    CP ROC_Y_MAX_LO_H36
    RET NC
.afterMaxX

    INC BC
    INC BC
    LD (ro.rocX), BC

    ; ##########################################
    LD A, (decTileDelayCnt)
    DEC A
    OR A                                        ; Same as CP 0, but faster.
    JR NZ, .afterDec

    CALL ros.IncTileOffsetX

    LD A, DELAY_TILE
.afterDec
    LD (decTileDelayCnt), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE