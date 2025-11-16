;----------------------------------------------------------;
;                      Flying the Rocket                   ;
;----------------------------------------------------------;
    MODULE rof

FLAME_OFFSET_D16        = 16
RO_FLY_DELAY_D8         = 8
RO_FLY_DELAY_DIST_D5    = 5
EXPLODE_Y_HI_H4         = 4                     ; HI byte from #starsDistance to explode rocket,1070 = $42E.
EXPLODE_Y_LO_H7E        = $2E                   ; LO byte from #starsDistance to explode rocket.
EXHAUST_SPRID_D83       = 83                    ; Sprite ID for exhaust.
RO_MOVE_STOP_D120       = 120                   ; After the takeoff, the rocket starts moving toward the middle of the screen and will stop at this position.

rocketExplodeCnt        DB 0                    ; Counts from 1 to RO_EXPLODE_MAX (both inclusive).
RO_EXPLODE_MAX          = 20                    ; Amount of explosion frames stored in #rocketExplodeDB[1-3].

rocketExhaustCnt        DB 0                    ; Counts from 0 (inclusive) to #RO_EXHAUST_MAX (exclusive).
rocketDistance          DW 0                    ; Increments with every rocket move when the rocket is flying towards the next planet.
rocketDelayDistance     DB 0                    ; Counts from 0 to RO_FLY_DELAY_DIST_D5, increments with every rocket move (when #rocketFlyDelay resets).
rocketFlyDelay          DB RO_FLY_DELAY_D8      ; Counts from #rocketFlyDelayCnt to 0, decrement with every skipped rocket move.
rocketFlyDelayCnt       DB RO_FLY_DELAY_D8      ; Counts from RO_FLY_DELAY_D8 to 0, decrements when #rocketDelayDistance resets.

FLY_SOUND_REPEAT        = 20
soundRepeatDelay        DB FLY_SOUND_REPEAT

;----------------------------------------------------------;
;               ResetAndDisableFlyRocket                   ;
;----------------------------------------------------------;
ResetAndDisableFlyRocket
    CALL dbs.SetupArrays2Bank

    XOR A
    LD (rocketExplodeCnt), A
    LD (rocketDelayDistance), A
    LD (rocketExhaustCnt), A

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

    LD A, af.FX_ROCKET_FLY
    CALL dbs.SetupAyFxsBank
    CALL af.AfxPlay

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        FlyRocket                         ;
;----------------------------------------------------------;
FlyRocket

    CALL dbs.SetupArrays2Bank

    CALL _ShakeTilemapOnFlyingRocket
    CALL _MoveFlyingRocket
    
    ; ##########################################
    ; Set X/Y coordinates for flames coming out of the exhaust.
    LD A, EXHAUST_SPRID_D83
    NEXTREG _SPR_REG_NR_H34, A                  ; Set the ID of the sprite for the following commands.

    ; Sprite X coordinate from assembly location.
    LD A, (ro.rocketAssemblyX)
    NEXTREG _SPR_REG_X_H35, A

    LD A, _SPR_REG_ATR2_EMPTY
    NEXTREG _SPR_REG_ATR2_H37, A

    ; Sprite Y coordinate
    LD IX, (ro.rocketElPtr)
        
    LD A, (IX + ro.RO.Y)                           ; Lowest rocket element + 16px.
    ADD A, FLAME_OFFSET_D16
    NEXTREG _SPR_REG_Y_H36, A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    BlinkFlyingRocket                     ;
;----------------------------------------------------------;
BlinkFlyingRocket
    CALL dbs.SetupArrays2Bank
        
    LD A, ro.EL_LOW_D1
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

    CALL dbs.SetupArrays2Bank

    ; ##########################################
    ; Is the exploding sequence over?
    LD A, (rocketExplodeCnt)
    CP RO_EXPLODE_MAX
    JR Z, .explodingEnds
    ; Nope, keep exploding.

    ; ##########################################
    ; FX
    LD A, af.FX_EXPLODE_ENEMY_2
    CALL dbs.SetupAyFxsBank
    CALL af.AfxPlay
    
    ; ##########################################
    ; Animation for the top rockets element.
    LD IX, (ro.rocketElPtr)
    LD A, ro.EL_TOP_D3
    CALL ro.MoveIXtoGivenRocketElement

    ; Move HL to current frame.
    LD DE, (rocketExplodeCnt)
    LD D, 0                                     ; Reset D, we have an 8-bit counter here.
    LD HL, db2.rocketExplodeDB3
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
    LD HL, db2.rocketExplodeDB2
    DEC DE                                      ; Counter starts at 1.
    ADD HL, DE
    LD D, (HL)
    CALL ro.UpdateRocketSpritePattern

    ; ##########################################
    ; Animation for the bottom rockets element.
    LD IX, (ro.rocketElPtr)
    LD A, ro.EL_LOW_D1
    CALL ro.MoveIXtoGivenRocketElement

    ; Move HL to current frame.
    LD DE, (rocketExplodeCnt)
    LD D, 0                                     ; Reset D, we have an 8-bit counter here.
    LD HL, db2.rocketExplodeDB1
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

    CALL dbs.SetupArrays2Bank

    ; Increment sprite pattern counter.
    LD A, (rocketExhaustCnt)
    INC A
    CP db2.RO_EXHAUST_MAX
    JP NZ, .afterIncrement
    XOR A                                       ; Reset counter.
.afterIncrement 

    LD (rocketExhaustCnt), A                    ; Store current counter (increment or reset).

    ; Set the ID of the sprite for the following commands.
    LD A, EXHAUST_SPRID_D83
    NEXTREG _SPR_REG_NR_H34, A

    ; Load sprite pattern to A.
    LD HL, db2.rocketExhaustDB
    LD A, (rocketExhaustCnt)
    ADD HL, A
    LD A, (HL)

    ; Set sprite pattern.
    OR _SPR_PATTERN_SHOW                        ; Set show bit.
    NEXTREG _SPR_REG_ATR3_H38, A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                  _MoveFlyingRocket                       ;
;----------------------------------------------------------;
_MoveFlyingRocket
    CALL dbs.SetupArrays2Bank

    ; Slow down rocket movement speed while taking off.
    ; The rocket slowly accelerates, and the whole process is divided into sections. During each section, the rocket travels some distance 
    ; with a given delay. When the current section ends, the following section begins, but with decrement delay. During each section, 
    ; the rocket moves by the same amount of pixels on the Y axis, only the delay decrements with each following section.

    ; #rocketFlyDelayCnt == 0 when the whole delay sequence is over.
    LD A, (rocketFlyDelayCnt)
    CP 0
    JR Z, .afterDelay

    ; Decrement delay counter.
    LD A, (rocketFlyDelay)
    DEC A
    LD (rocketFlyDelay), A

    CP 0
    RET NZ                                      ; Return if delay counter has not been reached.
    
    ; The counter reached 0, reset it and increment the distance counter.
    LD A, (rocketFlyDelayCnt)
    LD (rocketFlyDelay), A

    LD A, (rocketDelayDistance)
    INC A
    LD (rocketDelayDistance), A

    ; Has the traveled distance of the rocket with the current delay been reached?
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

    CALL gc.RocketFlying
    CALL dbs.SetupArrays2Bank                    ; gc-call can change bank!

    ; ##########################################
    ; Increment total distance.
    LD HL, (rocketDistance)
    INC HL
    LD (rocketDistance), HL

    ; ##########################################
    ; Has the rocket reached the asteroid, and should the explosion sequence begin?
    LD A, H
    CP EXPLODE_Y_HI_H4
    JR NZ, .notAtAsteroid

    LD A, L
    CP EXPLODE_Y_LO_H7E
    JR C, .notAtAsteroid

    CALL _StartRocketExplosion
    RET
.notAtAsteroid

    ; ##########################################
    ; The current position of rocket elements is stored in #rocketAssemblyX and #ro.RO.Y 
    ; It was set when elements were falling towards the platform. Now, we need to decrement Y to animate the rocket.

    LD IX, (ro.rocketElPtr)                               ; Load the pointer to #rocket into IX.

    ; ##########################################
    ; Did the rocket reach the middle of the screen, and should it stop moving?
    LD A, (IX + ro.RO.Y)
    CP RO_MOVE_STOP_D120
    JR NC, .keepMoving

    ; Do not move the rocket anymore, but keep updating the lower part to keep blinking animation.
    LD A, (ro.rocketAssemblyX)
    CALL ro.UpdateElementPosition
    
    RET
.keepMoving
    ; Keep moving
    
    ; ##########################################
    ; Move bottom rocket element.
    LD A, (IX + ro.RO.Y)

    DEC A
    LD (IX + ro.RO.Y), A

    LD A, (ro.rocketAssemblyX)
    CALL ro.UpdateElementPosition

    ; ##########################################
    ; Move middle rocket element.
    LD A, ro.EL_MID_D2
    CALL ro.MoveIXtoGivenRocketElement

    LD A, (IX + ro.RO.Y)
    DEC A
    LD (IX + ro.RO.Y), A

    LD A, (ro.rocketAssemblyX)
    CALL ro.UpdateElementPosition

    ; ##########################################
    ; Move top rocket element.
    LD A, ro.EL_TOP_D3
    CALL ro.MoveIXtoGivenRocketElement

    LD A, (IX + ro.RO.Y)
    DEC A
    LD (IX + ro.RO.Y), A
    
    LD A, (ro.rocketAssemblyX)
    CALL ro.UpdateElementPosition

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                _StartRocketExplosion                     ;
;----------------------------------------------------------;
; Start explosion sequence. The rocket explodes when the state is flying and counter above zero.
_StartRocketExplosion

    LD A, 1
    LD (rocketExplodeCnt), A

    ; ##########################################
    ; Hide exhaust
    LD A, EXHAUST_SPRID_D83                     ; Hide sprite on display.
    CALL sp.SetIdAndHideSprite

    ; ##########################################
    ; Update state
    LD A, ro.ROST_EXPLODE
    LD (ro.rocketState), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                _ShakeTilemapOnFlyingRocket               ;
;----------------------------------------------------------;
_ShakeTilemapOnFlyingRocket

    ; Execute function until the rocket has reached its destination, where it stops and only stars are moving.
    LD HL, (rocketDistance)
    LD A, H                                     ; H is always 0, because distance < 255.
    CP 0
    RET NZ

    LD A, L
    CP RO_MOVE_STOP_D120
    RET NC

    ; ##########################################
    CALL ti.ShakeTilemap

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE