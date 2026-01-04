/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                    Jetman Collision                      ;
;----------------------------------------------------------;
    MODULE jco

; Margins for collision Jetman - enemy
MARG_HOR_D12            = 12
MARG_VERT_UP_D18        = 18
MARG_VERT_LOW_D15       = 15
MARG_VERT_KICK_D25      = 25

RIP_MOVE_LEFT           = 0
RIP_MOVE_RIGHT          = 1
ripMoveState            DB 0                    ; 1 - move right, 0 - move left

; Amount of steps to move in a direction is given by #ripMoveState. This counter counts down to 0. When that happens, 
; the counter gets initialized from #ripMoveMul, and the direction changes (#ripMoveState).
ripMoveCnt              DB RIP_MOVE_MUL_INC

RIP_MOVE_MUL_INC        = 5
ripMoveMul              DB RIP_MOVE_MUL_INC

invincibleCnt           DW 0                    ; Makes Jetman invincible when > 0.

; RIP movement.
JM_RIP_MOVE_R_D3        = 3
JM_RIP_MOVE_L_D3        = 3
JM_RIP_MOVE_Y_D4        = 4

JM_INV_BLINK_D100       = 100

PICK_MARGX_D8           = 8
PICK_MARGY_D16          = 16

; Invincibility
JM_INV_D400             = 400                   ; Number of loops to keep Jetman invincible.

;----------------------------------------------------------;
;----------------------------------------------------------;
;                        MACROS                            ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                      _RipMove                            ;
;----------------------------------------------------------;
; Jetman moves in zig-zac towards the upper side of the screen
    MACRO _RipMove

    ; Move left or right.
    LD A, (jco.ripMoveState)
    CP jco.RIP_MOVE_LEFT
    JR Z, .moveLeft

    ; Move right.
    LD B, jco.JM_RIP_MOVE_L_D3
    CALL jpo.DecJetXbyB
    JR .afterMove

.moveLeft
    ; Move left.
    LD B, jco.JM_RIP_MOVE_R_D3
    CALL jpo.IncJetXbyB
.afterMove

    LD B, jco.JM_RIP_MOVE_Y_D4                      ; Going up
    CALL jpo.DecJetYbyB

    ; Decrement move counter.
    LD A, (jco.ripMoveCnt)
    DEC A
    LD (jco.ripMoveCnt), A
    CP 0

    JR NZ, .end                                 ; Counter is still > 0 - keep going

    ; Counter has reached 0 - change direction.
    LD A, (jco.ripMoveState)
    XOR 1
    LD (jco.ripMoveState), A

    ; Increment zig-zag distance (gets bigger with every direction change).
    LD A, (jco.ripMoveMul)
    ADD jco.RIP_MOVE_MUL_INC
    LD (jco.ripMoveMul), A

    ; Counter (how far we go left/right in zig-zag) increments with every turn, and ripMoveMul holds the increasing value.
    LD (jco.ripMoveCnt), A

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                     _ResetRipMove                        ;
;----------------------------------------------------------;
    MACRO _ResetRipMove

    LD A, jco.RIP_MOVE_MUL_INC
    LD (jco.ripMoveMul), A
    LD (jco.ripMoveCnt), A

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                    _EnemyCollision                       ;
;----------------------------------------------------------;
; Checks whether a given enemy has been hit by the laser beam and eventually destroys it.
; Input:
;  - IX: pointer to concrete single enemy, single #SPR.
    MACRO _EnemyCollision

    ; Exit if enemy is not alive.
    BIT sr.SPRITE_ST_ACTIVE_BIT, (IX + SPR.STATE)
    JR Z, .end

    ; Exit if enemy is not visible.
    BIT sr.SPRITE_ST_VISIBLE_BIT, (IX + SPR.STATE)
    JR Z, .end

    ; ################################
    ; At first, check if Jetman is close to the enemy from above, enough to play "kick legs" animation, but still insufficient to kill the Jetman.

    ; It's flying, now check the collision.
    LD E, 0
    LD D, MARG_VERT_KICK_D25
    CALL _CheckCollision
    JR NZ, .noKicking

    ; Jetman is close enough to start kicking (to far to die), but first check if the animation does not play already.
    LD A, (jt.jetAir)
    CP jt.AIR_ENEMY_KICK
    JR Z, .end                                  ; Animation plays already.

    ; Play animation and set state
    LD A, jt.AIR_ENEMY_KICK
    CALL jt.SetJetStateAir

    LD A, js.SDB_T_KF
    CALL js.ChangeJetSpritePattern              ; Play the animation and keep checking for RiP collision.

.noKicking

    ; ################################
    ; Check if we should reset kicking state.
    LD A, (jt.jetAir)
    CP jt.AIR_ENEMY_KICK
    JR NZ, .afterKickReset

    ; Reset kick state.
    LD A, jt.AIR_FLY
    CALL jt.SetJetStateAir

    JR NZ, .afterKickReset
.afterKickReset

    ; ################################
    ; The distance to the enemy is not large enough for Jetman to start kicking. Now, check whether Jetman is close enough to the enemy to die.
    LD D, MARG_VERT_UP_D18
    LD E, MARG_VERT_LOW_D15
    CALL _CheckCollision
    JR NZ, .end

    ; We have collision!
    gc.EnemyHitsJet

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PUBLIC FUNCTIONS                       ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                   JetmanElementCollision                 ;
;----------------------------------------------------------;
; Checks whether Jetman overlaps with given element.
; Input:
;  - BC: X postion of the element.
;  - D:  Y postion of the element.
; Return:
;  - YES: Z is reset (JP Z).
;  - NO:  Z is set (JP NZ).
JetmanElementCollision

    ; Compare X coordinate of element and Jetman.
    LD B, 0                                     ; X is 8bit -> reset MSB.
    LD HL, (jpo.jetX)                           ; X of the Jetman.

    ; Check whether Jetman is horizontal with the element.
    SBC HL, BC  
    CALL ut.AbsHL                               ; HL contains a positive distance between the enemy and Jetman.
    LD A, H
    CP 0
    JR Z, .keepCheckingHorizontal               ; HL > 256 -> no collision.
    OR 1                                        ; Return NO (Z set).
    RET
.keepCheckingHorizontal
    LD A, L
    LD B, PICK_MARGX_D8
    CP B
    JR C, .checkVertical                        ; Jump if there is horizontal collision, check vertical.
    ; L >= D (Horizontal thickness of the enemy) -> no collision.
    OR 1                                        ; Return NO (Z set).
    RET
.checkVertical
    
    ; We are here because Jetman's horizontal position matches that of the element, now check vertical.
    LD A, (jpo.jetY)                            ; Y of the Jetman.

    ; Subtracts B from A and check whether the result is less than or equal to #PICK_MARGY_D16.
    SUB D                                       ; D is method param (Y postion of rocket element).
    CALL ut.AbsA
    LD B, A
    LD A, PICK_MARGY_D16
    CP B
    JR NC, .collision                           ; Jump if A(#PICK_MARGY_D16) >= B.

.noCollision
    OR 1                                        ; Return NO (Z set).
    RET
.collision
    XOR A                                       ; Return YES (Z is reset).

    RET                                         ; ## END of the function ##
    
;----------------------------------------------------------;
;                    EnemiesCollision                      ;
;----------------------------------------------------------;
; Checks all active enemies given by IX for collision with leaser beam.
; Input
;  - IX: pointer to #SPR, the enemies.
;  - A:  number of enemies in IX.
; Modifies: ALL
EnemiesCollision

    CP 0
    RET Z

    LD B, A
.loop
    PUSH BC                                     ; Preserve B for loop counter.
    _EnemyCollision
.continue
    ; Move HL to the beginning of the next #shotsX.
    LD DE, SPR
    ADD IX, DE
    POP BC

    DEC B
    JP NZ, .loop                                ; Jump if B > 0.

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       jco.JetRip                         ;
;----------------------------------------------------------;
    MACRO jco.JetRip

    LD A, (jt.jetState)
    CP jt.JETST_RIP
    JR NZ, .end                                  ; Exit if not RiP.

    _RipMove

    ; Did Jetman reach the top of the screen (the RIP sequence is over)?
    LD A, (jpo.jetY)
    CP 4                                        ; Going up is incremented by 2.
    JR NC, .end                                 ; Nope, still going up (#jetY >= 4).

    ; Sequence is over, respawn new live.
    _ResetRipMove
    CALL gc.RespawnJet

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                    MakeJetInvincible                     ;
;----------------------------------------------------------;
MakeJetInvincible

    ; Store invincibility duration.
    LD BC, JM_INV_D400
    LD (invincibleCnt), BC
    
    ; Update state
    LD A, jt.JETST_INV
    jt.SetJetState

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  jco.JetInvincible                       ;
;----------------------------------------------------------;
    MACRO jco.JetInvincible

    LD A, (jt.jetState)
    CP jt.JETST_INV
    JR NZ, .end

    ; ##########################################
    ; Decrement counter
    LD HL, (jco.invincibleCnt)
    DEC HL
    LD (jco.invincibleCnt), HL                      ; Decrement counter and store it.

    ; End invincibility if count is 0.
    CALL ut.HlEqual0
    JR Z, .endInvincibility

    ; ##########################################
    ; Still invincible - blink Jetman sprite (at first blink fast, last few seconds blink slow).
    ; Should blink slow or fast?
    LD A, H                                     ; H should be 0 because the last blink phase (slow blink) is 8 bits.
    CP 0
    JR NZ, .blinkFast                           ; #invincibleCnt > 255 (H != 0) -> blink fast.

    LD A, L
    CP jco.JM_INV_BLINK_D100
    JR NC, .blinkFast                           ; #invincibleCnt > #JM_INV_BLINK_D100 -> blink fast.

    ;  #invincibleCnt < #JM_INV_BLINK_D100 -> blink slow (invincibility is almost over).
    LD A, (mld.counter005FliFLop)
    JR .afterBlinkSet
.blinkFast  
    LD A, (mld.counter002FliFLop)
.afterBlinkSet

    CALL js.BlinkJetSprite
    JR .end

.endInvincibility
    ; ##########################################
    ; It is the last iteration, remove invincibility.
    LD A, jt.JETST_NORMAL
    jt.SetJetState

    CALL js.ShowJetSprite

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                    #_CheckCollision                      ;
;----------------------------------------------------------;
; Checks whether a given enemy has been hit by the laser beam and eventually destroys it.
; Input:
;  - IX: pointer to concrete single enemy, single #SPR.
;  - D:  upper thickness of the enemy (enemy above Jetman).
;  - E:  lower thickness of the enemy (enemy below Jetman).
; Return:
;  - YES: Z is reset (JP Z).
;  - NO:  Z is set (JP NZ).
_CheckCollision

    ; Compare X coordinate of enemy and Jetman
    LD BC, (IX + SPR.X)                         ; X of the enemy.
    LD HL, (jpo.jetX)                           ; X of the Jetman.

    ; Check whether Jetman is horizontal with the enemy.
    SBC HL, BC
    CALL ut.AbsHL                               ; HL contains a positive distance between the enemy and Jetman.
    LD A, H
    CP 0
    JR Z, .keepCheckingX                        ; HL > 256 -> no collision.

    OR 1                                        ; Return NO (Z set).
    RET
.keepCheckingX
    LD A, L
    LD B, MARG_HOR_D12
    CP B
    JR C, .checkX                               ; Jump if there is horizontal collision, check vertical.

    ; L >= D (Horizontal thickness of the enemy) -> no collision.
    OR 1                                        ; Return NO (Z set).
    RET
.checkX

    ; We are here because Jetman's horizontal position matches that of the enemy, now check vertical.
    LD B, (IX + SPR.Y)                          ; Y of the enemy.
    LD A, (jpo.jetY)                            ; Y of the Jetman.

    ; Is Jetman above or below the enemy?
    CP B
    JR C, .jetmanAboveEnemy                     ; Jump if "Jet Y" < "enemy Y". Jet is above enemy (0 is at the top, 256 bottom).

    ; Jetman is below enemy
    SUB B
    CP E
    JR C, .collision                            ; Jump if A - B < E
    JR .noCollision

.jetmanAboveEnemy
    ; Jetman is above enemy

    ; TODO do not load X/Y again, reuse already loaded values!
    ; Swap A and B to avoid negative value.
    LD A, (jpo.jetY)
    LD B, A                                     ; B: Y of the Jetman
    LD A, (IX + SPR.Y)                          ; A: Y of the enemy
    SUB B
    CP D
    JR C, .collision
    JR .noCollision

.noCollision
    OR 1                                        ; Return NO (Z set).
    RET
.collision
    XOR A                                       ; Return YES (Z is reset).

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE