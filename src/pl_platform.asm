/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                    Platforms and Ground                  ;
;----------------------------------------------------------;
    MODULE pl

MAX_PLATFORM_Y          = 27*8
PL_FALL_JOY_OFF_D10     = 10                    ; Disable the joystick for a few frames because Jetman is falling from the platform.
PL_BUMP_JOY_D15         = 15                    ; Disable the joystick for a few frames because Jetman is bumping into the platform.
PL_BUMP_JOY_DEC_D1      = 1                     ; With each bump into the platform, the period to turn off the joystick decrements by this value.
PL_BUMP_Y_D4            = 4                     ; Amount of pixels to move Jetman down when hitting platform from below.
PL_BUMP_X_D4            = 4
PL_FALL_Y_D4            = 4                     ; Amount of pixels to move Jetman down when falling from the platform.
PL_FALL_X_D2            = 2

Y_SPR_RAMOFFSET         = 2

HIT_MARGIN_D5           = 5 

; Compensation for height of Jetman's sprite to fall from the platform.
FALL_LX_D8              = 8
FALL_RX_N1              = -1

; Platform margin/border
    STRUCT PLAM
X_LEFT                  DW
X_RIGHT                 DW
Y_TOP                   DB
Y_BOTTOM                DB
    ENDS

; Coordinates for a platform
    STRUCT PLA
X_LEFT                  DW                    ; X start of the platform.
X_RIGHT                 DW                    ; X end of the platform.
Y_TOP                   DB                    ; Y start of the platform.
Y_BOTTOM                DB                    ; Y end of the platform.
    ENDS

; [amount of platforms], #PLA,..., #PLA]. Platforms are tiles. Each tile has 8x8 pixels.
platformsPtr            DW 0                  ; Pointer value to platforms.
platformsSize           DB 0

; A number of the platform that Jetman walks on. This byte is only set to the proper value when jt.jetGnd == jt.GND_WALK_D51.
PLATFORM_WALK_INACTIVE  = $FF                   ; Not on any platform.

platformWalkNumber      DB PLATFORM_WALK_INACTIVE

joyOffBump              DB PL_BUMP_JOY_D15; The amount of pixels to bump off the platform decrements with each hit.

;----------------------------------------------------------;
;----------------------------------------------------------;
;                        MACROS                            ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                _PlatformDirectionHit                     ;
;----------------------------------------------------------;
; Check whether the sprite given by coordinates hits one of the platforms, also provides platform number and side.
; Input:
;  - HL: pointer to memory containing (X[DW],Y[DB]) coordinates to check for the collision.
;  - IX: pointer to #PLAM
;  - IY: pointer to #PLA list
;  - B:  number of elements in #PLA list
; Return:
;  - A:  #PL_DHIT_RET_XXX
;  - B:  platform counter set to the current platform. The counter starts with the number (inclusive) of platforms and counts toward 1 (inclusive).
PL_DHIT_NO_D0           = 0                     ; No collision.
PL_DHIT_LEFT_D1         = 1                     ; Sprite hits the platform from the left.
PL_DHIT_RIGHT_D2        = 2                     ; Sprite hits the platform from the right.
PL_DHIT_TOP_D3          = 3                     ; Sprite hits the platform from above.
PL_DHIT_BOTTOM_D4       = 4                     ; Sprite hits the platform from below.

    MACRO _PlatformDirectionHit

    CALL dbs.SetupArrays2Bank
.loopOverPlatforms

    ; ##########################################
    ; Check the collision from the left side of the platform.

    PUSH BC
    _CheckPlatformHitLeft
    POP BC

    JR NZ, .afterHitLeft

    ; We have a hit from the left side, now check whether Jetman is within the vertical bounds of the platform.
    CALL _CheckPlatformHitVertical
    JR NZ, .afterHitLeft

    LD A, PL_DHIT_LEFT_D1
    JP .end
.afterHitLeft

    ; ##########################################
    ; Check the collision from the right side of the platform.

    PUSH BC
    _CheckPlatformHitRight
    POP BC

    JR NZ, .afterHitRight

    ; We have a hit from the right side, now check whether Jetman is within the vertical bounds of the platform.
    CALL _CheckPlatformHitVertical
    JR NZ, .afterHitRight

    LD A, PL_DHIT_RIGHT_D2
    JP .end
.afterHitRight

    ; ##########################################
    ; Check the collision from the top side of the platform.

    _CheckPlatformHitTop
    JR NZ, .afterHitTop

    ; We have a hit from the top side, now check whether Jetman is within the horizontal bounds of the platform.
    PUSH BC
    CALL _CheckPlatformHitHorizontal
    POP BC

    JR NZ, .afterHitTop

    LD A, PL_DHIT_TOP_D3
    JR .end
.afterHitTop

    ; ##########################################
    ; Check the collision from the bottom side of the platform.

    _CheckPlatformHitBottom
    JR NZ, .afterHitBottom

    ; We have a hit from the top side, now check whether Jetman is within the horizontal bounds of the platform.
    PUSH BC
    CALL _CheckPlatformHitHorizontal
    POP BC

    JR NZ, .afterHitBottom

    LD A, PL_DHIT_BOTTOM_D4
    JR .end
.afterHitBottom

    ; ##########################################
    ; Loop over platforms.
    LD DE, PLA
    ADD IY, DE

    DEC B
    JP NZ, .loopOverPlatforms                         ; decrement B until all platforms have been evaluated.

    ; We've iterated over all platforms, and there was no hit.
    LD A, PL_DHIT_NO_D0

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                    _LoadSpriteYtoA                       ;
;----------------------------------------------------------;
; Load the sprite's Y coordinate. It's in memory right after X, but HL points to X, so we must move it by size of DW.
; Input:
;  - HL: pointer to memory containing (X[DW],Y[DB]) coordinates to check for the collision.
; Return:
;  - A:  sprite's Y coordinate.
; Modifies: DE
    MACRO _LoadSpriteYtoA

    LD DE, HL
    ADD DE, Y_SPR_RAMOFFSET
    LD A, (DE)                                  ; A holds current sprite Y position.

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                _CheckPlatformHitRight                    ;
;----------------------------------------------------------;
; Check the collision with the left side of the platform.
; Collision when: [#PLA.X_RIGHT + PLAM.X_RIGHT] > [sprite X] > [#PLA.X_RIGHT + PLAM.X_RIGHT - #HIT_MARGIN_D5].
; Input:
;  - HL: pointer to memory containing (X[DW],Y[DB]) coordinates to check for the collision.
;  - IX: pointer to #PLAM
;  - IY: pointer to #PLA
; Return:
;  - YES: Z is reset (JP Z).
;  - NO:  Z is set (JP NZ).
; Modifies: BC, DE
    MACRO _CheckPlatformHitRight

    ; Check [#PLA.X_RIGHT + PLAM.X_RIGHT] > [sprite X]
    LD DE, (IY + PLA.X_RIGHT)
    LD BC, (IX + PLAM.X_RIGHT)
    ADD DE, BC                                  ; DE contains [#PLA.X_RIGHT + #PLAM.X_RIGHT].

    ; Load (HL) into HL (sprite X), as preparation for SBC.
    PUSH HL
    LD BC, (HL)
    LD HL, BC                                   ; HL contains sprite X.

    SBC HL, DE                                  ; if HL(sprite X) - DE < 0 then we have collision.
    POP HL
    JP M, .keepChecking

    ; HL(sprite X) - DE > 0 -> No collision.
    OR 1                                        ; Return NO (Z set).`
    JR .end
.keepChecking

    ; ##########################################
    ; Check [sprite X] > [#PLA.X_RIGHT  + PLAM.X_RIGHT- #HIT_MARGIN_D5].
    PUSH HL

    LD BC, (HL)                                 ; BC contains sprite X.

    LD HL, (IY + PLA.X_RIGHT)
    LD DE, HIT_MARGIN_D5
    SBC HL, DE
    LD DE, (IX + PLAM.X_RIGHT)
    ADD HL, DE                                  ; HL contains [#PLA.X_RIGHT  + PLAM.X_RIGHT- #PLAM.X_RIGHT].

    SBC HL, BC                                  ; Jump if HL - DE (sprite X) < 0.
    POP HL
    JP M, .hit

    OR 1                                        ; Return NO (Z set).
    JR .end
.hit
    XOR A                                       ; Return YES (Z is reset).

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                 _CheckPlatformHitLeft                    ;
;----------------------------------------------------------;
; Check the collision with the left side of the platform.
; Collision when: [#PLA.X_LEFT - #PLAM.X_LEFT + #HIT_MARGIN_D5] > [sprite X] > [#PLA.X_LEFT - #PLAM.X_LEFT].
; Input:
;  - HL: pointer to memory containing (X[DW],Y[DB]) coordinates to check for the collision.
;  - IX: pointer to #PLAM
;  - IY: pointer to #PLA
; Return:
;  - YES: Z is reset (JP Z).
;  - NO:  Z is set (JP NZ).
; Modifies: BC, DE
    MACRO _CheckPlatformHitLeft

    ; Check if [#PLA.X_LEFT - #PLAM.X_LEFT + #HIT_MARGIN_D5] > [sprite X]
    LD DE, (IY + PLA.X_LEFT)
    LD BC, HIT_MARGIN_D5
    ADD DE, BC

    LD BC, (IX + PLAM.X_LEFT)

    SUB DE, BC                                  ; DE contains: #PLA.X_LEFT - #PLAM.X_LEFT + #HIT_MARGIN_D5.

    ; Load (HL) into HL (sprite X), as preparation for SBC.
    PUSH HL
    LD BC, (HL)
    LD HL, BC                                   ; HL contains sprite X.

    SBC HL, DE                                  ; if HL(sprite X) - DE < 0 then we have collision.
    POP HL
    JP M, .keepChecking

    ; HL(sprite X) - DE > 0 -> No collision.
    OR 1                                        ; Return NO (Z set).
    JR .end
.keepChecking

    ; ##########################################
    ; Check [sprite X] > [#PLA.X_LEFT - #PLAM.X_LEFT]
    PUSH HL

    LD BC, (HL)                                 ; BC contains sprite X.

    LD HL, (IY + PLA.X_LEFT)
    LD DE, (IX + PLAM.X_LEFT)
    SBC HL, DE                                  ; HL contains [#PLA.X_LEFT - #PLAM.X_LEFT].
    SBC HL, BC                                  ; Jump if HL - DE (sprite X) < 0.

    POP HL
    JP M, .hit

    OR 1                                        ; Return NO (Z set).
    JR .end
.hit
    XOR A                                       ; Return YES (Z is reset).

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                _CheckPlatformHitBottom                   ;
;----------------------------------------------------------;
; Check the collision with the bottom side of the platform.
; Collision when: [#PLA.Y_BOTTOM + #PLAM.Y_BOTTOM] > [sprite Y] > [#PLA.Y_BOTTOM + #PLAM.Y_BOTTOM - #HIT_MARGIN_D5].
; Input:
;  - HL: pointer to memory containing (X[DW],Y[DB]) coordinates to check for the collision.
;  - IX: pointer to #PLAM.
;  - IY: pointer to #PLA.
; Return:
;  - YES: Z is reset (JP Z).
;  - NO:  Z is set (JP NZ).
; Modifies: C
    MACRO _CheckPlatformHitBottom
    
    ; Check [#PLA.Y_BOTTOM + #PLAM.Y_BOTTOM] > [sprite Y]
    LD A, (IY + PLA.Y_BOTTOM)
    ADD (IX + PLAM.Y_BOTTOM)
    LD C, A                                     ; C holds [#PLA.Y_BOTTOM + #PLAM.Y_BOTTOM].

    _LoadSpriteYtoA                             ; A holds current sprite Y position.

    CP C
    JR C, .keepChecking                         ; Jump if A (sprite Y) < C.

    ;  A (sprite Y) > C -> no collision.
    OR 1                                        ; Return NO (Z set).
    JR .end
.keepChecking

    ; ##########################################
    ; Check [sprite Y] > [#PLA.Y_BOTTOM + #PLAM.Y_BOTTOM - #HIT_MARGIN_D5].

    LD A, (IY + PLA.Y_BOTTOM)
    ADD (IX + PLAM.Y_BOTTOM)
    SUB HIT_MARGIN_D5
    LD C, A                                     ; C holds [#PLA.Y_BOTTOM + #PLAM.Y_BOTTOM - #HIT_MARGIN_D5].

    _LoadSpriteYtoA                             ; A holds current sprite Y position.

    CP C
    JR NC, .hit                                 ; Jump if A (sprite Y) >= C.

    OR 1                                        ; Return NO (Z set).
    JR .end
.hit
    XOR A                                       ; Return YES (Z is reset).

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                 _CheckPlatformHitTop                     ;
;----------------------------------------------------------;
; Check the collision with the top side of the platform.
; Collision when: [#PLA.Y_TOP - #PLAM.Y_TOP + #HIT_MARGIN_D5] > [sprite Y] > [#PLA.Y_TOP - #PLAM.Y_TOP].
; Input:
;  - HL: pointer to memory containing (X[DW],Y[DB]) coordinates to check for the collision.
;  - IX: pointer to #PLAM
;  - IY: pointer to #PLA
; Return:
;  - YES: Z is reset (JP Z).
;  - NO:  Z is set (JP NZ).
; Modifies: C
    MACRO _CheckPlatformHitTop

    ; ##########################################
    ; Check [#PLA.Y_TOP - #PLAM.Y_TOP + #HIT_MARGIN_D5] > [sprite Y].
    LD A, (IY + PLA.Y_TOP)
    LD C, HIT_MARGIN_D5
    ADD C
    SUB (IX + PLAM.Y_TOP)
    LD C, A                                     ; C holds [#PLA.Y_TOP + #HIT_MARGIN_D5].

    _LoadSpriteYtoA                             ; A holds current sprite Y position.

    CP C
    JR Z, .keepChecking                         ; Jump if A (sprite Y) == C.
    JR C, .keepChecking                         ; Jump if A (sprite Y) < C.

    ;  A (sprite Y) > C -> no collision.
    OR 1                                        ; Return NO (Z set).
    JR .end

.keepChecking

    ; ##########################################
    ; Check [sprite Y] > [#PLA.Y_TOP - #PLAM.Y_TOP].

    LD A, (IY + PLA.Y_TOP)
    SUB (IX + PLAM.Y_TOP)
    LD C, A                                     ; C holds [#PLA.Y_TOP - #PLAM.Y_TOP].

    _LoadSpriteYtoA                             ; A holds current sprite Y position.

    CP C
    JR NC, .hit                                 ; Jump if A (sprite Y) >= C.
    
    OR 1                                        ; Return NO (Z set).
    JR .end
.hit
    XOR A                                       ; Return YES (Z is reset).

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PUBLIC FUNCTIONS                       ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                     SetupPlatforms                       ;
;----------------------------------------------------------;
; Input:
;  - A:  platforms size.
;  - HL: pointer to #PLA array containing A elements.
SetupPlatforms

    LD (platformsSize), A
    LD (platformsPtr), HL
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 JetPlatformHitOnJoyMove                  ;
;----------------------------------------------------------;
JetPlatformHitOnJoyMove

    ; Return if Jetman is below all platforms.
    LD A, (jpo.jetY)
    CP MAX_PLATFORM_Y
    RET NC

    CALL dbs.SetupArrays2Bank

    ; ##########################################
    ; Collision only possible when flying.
    LD A, (jt.jetAir)
    CP jt.AIR_FLY_D10
    RET NZ

    ; ##########################################
    ; Check for platform hit.

    ; Params for _PlatformHit.
    LD HL, jpo.jetX

    LD IY, (platformsPtr)

    LD A, (platformsSize)
    LD B, A

    LD IX, db2.jetHitMargin
    _PlatformDirectionHit

    CP PL_DHIT_NO_D0
    RET Z
    LD D, A                                     ; Keep return flag D

    ; ##########################################
    ; Jetman hits the platform, now check what it means.

    ; ##########################################
    ; Is Jetman landing on the platform?

    ; Did Jetman hit top of the platform?
    LD A, D
    CP PL_DHIT_TOP_D3
    JR NZ, .afterLanding
    
    ; Is Jetman moving down?
    LD A, (gid.joyDirection)
    BIT gid.MOVE_DOWN_BIT, A
    JR Z, .afterLanding                         ; Jump if move down bit is not set.
    
    ; Update #platformWalkNumber = #platformSize - B.
    LD A, (platformsSize)
    SUB B
    LD (platformWalkNumber), A
    
    CALL JetLanding
    RET
.afterLanding

    ; ##########################################
    ; Does Jetman hit the platform from the left side?
    LD A, D
    CP PL_DHIT_LEFT_D1
    JR NZ, .afterHitLeft
    
    ; Is Jetman moving right (Jetman have to move right to hit the left side of the platform)?
    LD A, (gid.joyDirection)
    BIT gid.MOVE_RIGHT_BIT, A
    JR Z, .afterHitLeft                         ; Jump if right down bit is not set.
    
    ; Jetman hits the platform.
    LD A, jt.AIR_BUMP_LEFT_D15
    CALL jt.SetJetStateAir

    CALL _JetHitsPlatform

    ; When Jetman bumps away from the platform, he has to move left at least one pixel to compensate for Joystick's movement,
    ; or a few pixels to really bump off.
    LD A, (joyOffBump)
    CP PL_BUMP_JOY_DEC_D1+1
    JR C, .bumpLeftOnPixel

    LD B, PL_BUMP_X_D4
    CALL jpo.DecJetXbyB
    RET
.bumpLeftOnPixel
    CALL jpo.DecJetX

    RET
.afterHitLeft

    ; ##########################################
    ; Does Jetman hit the platform from the right side?
    LD A, D
    CP PL_DHIT_RIGHT_D2
    JR NZ, .afterHitRight
    
    ; Is Jetman moving left (Jetman have to move left to hit the right side of the platform)?
    LD A, (gid.joyDirection)
    BIT gid.MOVE_LEFT_BIT, A
    JR Z, .afterHitRight                        ; Jump if left down bit is not set.
    
    ; Jetman hits the platform from the right side and bumps off to the right.
    LD A, jt.AIR_BUMP_RIGHT_D14
    CALL jt.SetJetStateAir

    CALL _JetHitsPlatform

    ; When Jetman bumps away from the platform, he has to move right at least one pixel to compensate for Joystick's movement or a 
    ; few pixels to really bump off.
    LD A, (joyOffBump)
    CP PL_BUMP_JOY_DEC_D1+1
    JR C, .bumpRightOnPixel

    LD B, PL_BUMP_X_D4
    CALL jpo.IncJetXbyB
    RET
.bumpRightOnPixel
    CALL jpo.IncJetX

    RET
.afterHitRight

    ; ##########################################
    ; Does Jetman hit the platform from the bottom?
    LD A, D
    CP PL_DHIT_BOTTOM_D4
    JR NZ, .afterHitBottom

    ; Is Jetman moving up?
    LD A, (gid.joyDirection)
    BIT gid.MOVE_UP_BIT, A
    JR Z, .afterHitBottom                       ; Jump if left down bit is not set.
    
    ; Jetman hits the platform from the bottom.
    LD A, jt.AIR_BUMP_BOTTOM_D16
    CALL jt.SetJetStateAir

    CALL _JetHitsPlatform

    ; When Jetman bumps away from the platform, he has to move down at least one pixel to compensate for Joystick's movement or a 
    ; few pixels to really bump off.
    LD A, (joyOffBump)
    CP PL_BUMP_JOY_DEC_D1+1
    JR C, .bumpDownOnPixel

    LD B, PL_BUMP_Y_D4
    CALL jpo.IncJetYbyB
    RET

.bumpDownOnPixel
    CALL jpo.IncJetY

    RET
.afterHitBottom 

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    ResetJoyOffBump                       ;
;----------------------------------------------------------;
ResetJoyOffBump
    
    CALL dbs.SetupArrays2Bank

    ; Do not reset if already done.
    LD A, (joyOffBump)
    CP PL_BUMP_JOY_D15
    RET Z

    ; Reset the joystick bump only if Jetman is away from the platform,  or it walks on it.

    ; Does Jetman walk on the platform?
    LD A, (jt.jetGnd)
    CP jt.JT_STATE_INACTIVE_D0
    JR NZ, .reset                               ; Reset immediately if walking.
    
    ; Call _PlatformHit to check whether Jetman is close to the platform. now, we will load the params for this method.
    LD HL, jpo.jetX

    LD IY, (platformsPtr)

    LD A, (platformsSize)
    LD B, A

    LD IX, db2.jetAwayMargin
    CALL _PlatformHit
    RET Z                                        ; Jetman is close to platform - do not reset the bump.

.reset
    ; Jetman far from the platform - reset.
    LD A, PL_BUMP_JOY_D15
    LD (joyOffBump), A
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   PlatformSpriteHit                      ;
;----------------------------------------------------------;
; Check whether the sprite (#SPR) given by IX hits one of the platforms.
; Input:
;  - IX: pointer to SPR, single sprite to check cloison for.
; Return:
;  - YES: Z is reset (JP Z). Sprite hits the platform.
;  - NO:  Z is set (JP NZ). No collision.
PlatformSpriteHit

    LD IY, db2.spriteHitMargin
    JP _PlatformSpriteHit

;----------------------------------------------------------;
;                   PlatformSpriteClose                    ;
;----------------------------------------------------------;
; Check whether the sprite (#SPR) given by IX gets close the platforms.
; Input:
;  - IX: pointer to SPR, single sprite to check cloison for.
; Return:
;  - YES: Z is reset (JP Z). Sprite hits the platform.
;  - NO:  Z is set (JP NZ). No collision.
PlatformSpriteClose

    LD IY, db2.closeMargin
    JP _PlatformSpriteHit

;----------------------------------------------------------;
;                  CheckPlatformWeaponHit                  ;
;----------------------------------------------------------;
; Check whether the sprite (#SPR) given by IX hits one of the platforms.
; Input:
;  - IX: pointer to SPR, single sprite to check cloison for.
; Return:
;  - YES: Z is reset (JP Z). Sprite hits the platform.
;  - NO:  Z is set (JP NZ). No collision.
CheckPlatformWeaponHit

    LD IY, db2.shotHitMargin
    JP _PlatformSpriteHit

;----------------------------------------------------------;
;               MoveJetOnFallingFromPlatform               ;
;----------------------------------------------------------;
MoveJetOnFallingFromPlatform

    ; Is Jetman falling from the platform on the right side?
    LD A, (jt.jetAir)
    CP jt.AIR_FALL_RIGHT_D12
    JR NZ, .afterFallingRight

    ; Yes, Jetman is falling from the platform.
    LD B, PL_FALL_X_D2
    CALL jpo.IncJetXbyB

    LD B, PL_FALL_Y_D4
    CALL jpo.IncJetYbyB

    RET                                         ; Do not check falling left  because Jetman is already falling.
.afterFallingRight  

    ; Is Jetman falling from the platform on the left side?
    LD A, (jt.jetAir)
    CP jt.AIR_FALL_LEFT_D13
    RET NZ

    ; Yes, Jetman is falling from the platform.
    CALL jpo.DecJetX
    CALL jpo.DecJetX
    
    LD B, PL_FALL_Y_D4
    CALL jpo.IncJetYbyB

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;               MoveJetOnHitPlatformBelow                  ;
;----------------------------------------------------------;
MoveJetOnHitPlatformBelow

    ; Jetman hits the platform from the bottom?
    LD A, (jt.jetAir)
    CP jt.AIR_BUMP_BOTTOM_D16
    RET NZ

    ; Yes, Jetman hits the platform.

    ; Move down.
    CALL jpo.IncJetY

    ; Move left/right in the opposite direction to joystick.
    LD A, (gid.joyDirection)

    ; Joystick points right, move left.
    BIT gid.MOVE_RIGHT_BIT, A
    JR Z, .afterRight
    CALL jpo.IncJetX
    JR .afterLeft
.afterRight

    ; Joystick points left, move right.
    BIT gid.MOVE_LEFT_BIT, A
    JR Z, .afterLeft
    CALL jpo.DecJetX
.afterLeft  

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       JetLanding                         ;
;----------------------------------------------------------;
JetLanding

    ; Ignore landing if Jetman is already on the ground.
    LD A, (jt.jetGnd)
    CP jt.JT_STATE_INACTIVE_D0
    RET NZ

    ; Update state as we are walking.
    LD A, jt.GND_WALK_D51
    CALL jt.SetJetStateGnd
    
    ; Jetman is landing, trigger transition: flying -> standing/walking.
    LD A, (gid.joyDirection)
    AND gid.MOVE_MSK_LR
    CP 1    
    JR C, .afterMoveLR                          ; Jump, if there is no movement right/left (A >= 1) -> Jetman lands horizontally and stands still.
    
    LD A, js.SDB_T_FW                           ; Play transition from landing -> walking.
    CALL js.ChangeJetSpritePattern

    JR .afterStand                              ; The animation is already loaded, do not overwrite it with standing.
.afterMoveLR

    LD A, jt.GND_STAND_D53
    CALL jt.SetJetStateGnd                      ; Update state as we are standing.

    LD A, js.SDB_T_FS                           ; Play transition from landing -> standing.
    CALL js.ChangeJetSpritePattern
.afterStand

    CALL gc.JetLanding

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   PlatformBounceOff                      ;
;----------------------------------------------------------;
; Input:
;  - HL: pointer to memory containing (X[DW],Y[DB]) coordinates to check for the collision.
PlatformBounceOff

    LD IY, (platformsPtr)

    LD A, (platformsSize)
    LD B, A

    LD IX, db2.bounceMargin


;----------------------------------------------------------;
;                 MoveJetOnPlatformSideHit                 ;
;----------------------------------------------------------;
MoveJetOnPlatformSideHit

    ; Is Jetman bumping into the platform from the right?
    LD A, (jt.jetAir)
    CP jt.AIR_BUMP_RIGHT_D14
    JR NZ, .afterBumpingRight

    ; Yes
    CALL jpo.IncJetX
    RET                                     ; Do not check bumping left.
.afterBumpingRight

    ; Is Jetman bumping into the platform from the left?
    LD A, (jt.jetAir)
    CP jt.AIR_BUMP_LEFT_D15
    RET NZ

    ; Yes
    CALL jpo.DecJetX

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 JetFallingFromPlatform                   ;
;----------------------------------------------------------;
; Jetman walks to the edge of the platform and falls.
JetFallingFromPlatform

    ; Return if Jetman is below all platforms.
    LD A, (jpo.jetY)
    CP MAX_PLATFORM_Y
    RET NC
    
    CALL dbs.SetupArrays2Bank

    ; Does Jetman walk on any platform?
    LD A, (platformWalkNumber)
    CP PLATFORM_WALK_INACTIVE
    RET Z

    ; #platform contains a list of all platforms, each with a size of #PLA. #platformWalkNumber contains offset to current platform.
    ; Now, we have to set IX so that it points to the platform on which the Jetman walks: IX = #platform + #PLA * #platformWalkNumber.
    LD IX, (platformsPtr)
    LD A, (platformWalkNumber)                  ; Jetman is walking on this platform.
    LD D, A
    LD E, PLA
    MUL D, E                                    ; E contains #platformWalkNumber * #PLA, D is 0 (D * E < 256).
    ADD IX, DE                                  ; IX points to the current platform.

    ; Does Jetman fall from the platform on the left side?
    LD HL, (jpo.jetX)                           ; HL = X postion of the Jetman.
    LD DE, FALL_LX_D8
    ADD HL, DE
    LD DE, (IX + PLA.X_LEFT)                    ; DE = start of the platform (left side).
    SBC HL, DE                                  ; HL - DE
    JP M, .fallingLeft                          ; HL - DE < 0 -> falling left.

    ; Does Jetman fall from the platform on the right side?
    LD DE, (jpo.jetX)                           ; DE = X postion of the Jetman.
    LD HL, FALL_RX_N1
    ADD DE, HL
    LD HL, (IX + PLA.X_RIGHT)                   ; HL = start of the platform (left side).
    SBC HL, DE                                  ; HL - DE
    JP M, .fallingRight                         ; HL - DE < 0 -> falling right.
    
    RET                                         ; Still on the platform.

; Jetman is falling from the platform, left or right.
.fallingLeft
    LD A, jt.AIR_FALL_LEFT_D13
    JR .afterFallingRight

.fallingRight
    LD A, jt.AIR_FALL_RIGHT_D12

.afterFallingRight
    
    ; Jetman if falling, in the air - A contains proper air state.
    CALL jt.SetJetStateAir

    ; Trigger transition: walking -> falling.
    LD A, js.SDB_T_KF
    CALL js.ChangeJetSpritePattern

    ; Disable joystick, because Jetman loses control for #PL_FALL_JOY_OFF_D10 frames.
    LD A, PL_FALL_JOY_OFF_D10
    LD (gid.joyOffCnt), A

.afterFalling

    ; Not walking on platform anymore.
    LD A, PLATFORM_WALK_INACTIVE
    LD (platformWalkNumber), A  
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                     _PlatformHit                         ;
;----------------------------------------------------------;
; Check whether the sprite given by coordinates hits one of the platforms. It does not provide direction, just an indication that 
; there was a hit. To get directions use #_PlatformDirectionHit.
; Input:
;  - HL: pointer to memory containing (X[DW],Y[DB]) coordinates to check for the collision.
;  - IY: pointer to #PLA list.
;  - B:  number of elements in #PLA list.
;  - IX: pointer to #PLAM.
; Return:
;  - YES: Z is reset (JP Z). Sprite hits the platform.
;  - NO:  Z is set (JP NZ). No collision.
;  - B:  the current value of the platform counter. It counts from the maximum amount of platforms to zero.
;  - IY: set to current platform.
;
; Modifies:  A, BC, DE, IY
; Unchanged: HL, IX
_PlatformHit

    CALL dbs.SetupArrays2Bank
.loopOverPlatforms

    ; ##########################################
    ; Check the collision from the left side of the platform.

    ; HL points to memory location containing X, now we load into HL its value.
    PUSH HL                                     ; Keep HL for later use.

    ; Load the sprite's X position into HL and push it into the stack so that we can use HL for something else.
    LD DE, (HL)
    LD HL, DE                                   ; HL holds X postion of the sprite.
    PUSH HL

    ; Subtracting the left margin from the left side of the platform will move the left margin to the left and increment the platform's left width.
    LD HL, (IY + PLA.X_LEFT)                    ; HL holds start of the platform (left side).
    LD DE, (IX + PLAM.X_LEFT)                   ; DE holds left margin.
    SBC HL, DE
    LD DE, HL
    POP HL

    ; Now DE contains the left coordinate of the platform inclusive margin, and HL the sprite's X.
    SBC HL, DE                                  ; HL - DE

    POP HL

    JP M, .continueLoopOverPlatforms            ; continue (no collision) if HL - DE < 0.

    ; ##########################################
    ; Sprite is on the left from the platform's left corner. Now check whether it's not over the end.
    LD DE, (HL)                                 ; DE holds X postion of the sprite.

    PUSH HL
    LD HL, (IY + PLA.X_RIGHT)                   ; HL holds end of the platform (right side).

    ; Add margin to  HL (platform right).
    PUSH DE
    LD DE, (IX + PLAM.X_RIGHT)
    ADD HL, DE
    POP DE

    SBC HL, DE                                  ; HL - DE
    POP HL

    JP M, .continueLoopOverPlatforms            ; continue (no collision) if HL - DE < 0.

    ; Sprite is within the platform's horizontal position. Now check whether it's within vertical bounds.

    ; ##########################################
    ; Check platform's top level.
    ; Load the sprite's Y coordinate. It's in memory right after X, but HL points to X, so we must move it by size of DW.
    LD DE, HL
    ADD DE, Y_SPR_RAMOFFSET
    LD A, (DE)
    LD C, A                                     ; C holds current sprite Y position.

    ; Check platform's top level.
    LD A, (IY + PLA.Y_TOP)
    SUB (IX + PLAM.Y_TOP)                       ; Add platform top margin.

    CP C                                        ; Compare [Y sprite] position to [Y start].
    JR NC, .continueLoopOverPlatforms           ; Jump if sprite < [Y platform start].

    ; ##########################################
    ; Check platform's bottom level.
    LD A, (IY + PLA.Y_BOTTOM)
    ADD (IX + PLAM.Y_BOTTOM)                    ; Add platform bottom margin.

    CP C
    JR C, .continueLoopOverPlatforms            ; Jump if sprite > [Y end].

    ; ##########################################
    ; Sprite hits the platform!
    XOR A                                       ; Return YES (Z is reset).
    RET

.continueLoopOverPlatforms
    LD DE, PLA
    ADD IY, DE
    DJNZ .loopOverPlatforms                     ; decrement B until all platforms have been evaluated.

    OR 1                                        ; Return NO (Z set).

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;              _CheckPlatformHitHorizontal                 ;
;----------------------------------------------------------;
; Jetman is within the platform's horizontal bounds when:
; [#PLA.X_RIGHT + PLAM.X_RIGHT] > [sprite X] > [#PLA.X_LEFT - #PLAM.X_LEFT].
; Input:
;  - HL: pointer to memory containing (X[DW],Y[DB]) coordinates to check for the collision.
;  - IX: pointer to #PLAM
;  - IY: pointer to #PLA
; Return:
;  - YES: Z is reset (JP Z).
;  - NO:  Z is set (JP NZ).
; Modifies: BC, DE
_CheckPlatformHitHorizontal

    ; Check [#PLA.X_RIGHT + PLAM.X_RIGHT] > [sprite X]
    LD DE, (IY + PLA.X_RIGHT)
    LD BC, (IX + PLAM.X_RIGHT)
    ADD DE, BC                                  ; DE contains [#PLA.X_RIGHT + #PLAM.X_RIGHT].

    ; Load (HL) into HL (sprite X), as preparation for SBC.
    PUSH HL
    LD BC, (HL)
    LD HL, BC                                   ; HL contains sprite X.

    SBC HL, DE                                  ; if HL(sprite X) - DE < 0 then we have collision.
    POP HL
    JP M, .keepChecking

    ; HL(sprite X) - DE > 0 -> No collision.
    OR 1                                        ; Return NO (Z set).
    RET
.keepChecking

    ; ##########################################
    ; Check [sprite X] > [#PLA.X_LEFT - #PLAM.X_LEFT]
    PUSH HL

    LD BC, (HL)                                 ; BC contains sprite X.

    LD HL, (IY + PLA.X_LEFT)
    LD DE, (IX + PLAM.X_LEFT)
    SBC HL, DE                                  ; HL contains [#PLA.X_LEFT - #PLAM.X_LEFT].

    SBC HL, BC                                  ; Jump if HL - DE (sprite X) < 0.
    POP HL
    JP M, .hit

    OR 1                                        ; Return NO (Z set).
    RET
.hit
    XOR A                                       ; Return YES (Z is reset).

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                _CheckPlatformHitVertical                 ;
;----------------------------------------------------------;
; Jetman is within the platform's vertical bounds when:
; [#PLA.Y_BOTTOM + PLAM.Y_BOTTOM] > [sprite Y] > [#PLA.Y_TOP - #PLAM.Y_TOP].
; Input:
;  - HL: pointer to memory containing (X[DW],Y[DB]) coordinates to check for the collision.
;  - IX: pointer to #PLAM
;  - IY: pointer to #PLA
; Return:
;  - YES: Z is reset (JP Z).
;  - NO:  Z is set (JP NZ).
_CheckPlatformHitVertical

    ; Check [#PLA.Y_BOTTOM + PLAM.Y_BOTTOM] > [sprite Y] > [sprite Y]
    LD A, (IY + PLA.Y_BOTTOM)
    ADD (IX + PLAM.Y_BOTTOM)
    LD C, A                                     ; C holds [#PLA.Y_BOTTOM + PLAM.Y_BOTTOM].

    _LoadSpriteYtoA                             ; A holds current sprite Y position.

    CP C
    JR C, .keepChecking                         ; Jump if A (sprite Y) < C.

    ; A (sprite Y) > C -> no collision.
    OR 1                                        ; Return NO (Z set).`
    RET
    
.keepChecking

    ; ##########################################
    ; Check [sprite Y] > [#PLA.Y_TOP - #PLAM.Y_TOP]

    LD A, (IY + PLA.Y_TOP)
    SUB (IX + PLAM.Y_TOP)
    LD C, A                                     ; C holds [#PLA.Y_TOP - #PLAM.Y_TOP].

    _LoadSpriteYtoA                             ; A holds current sprite Y position.

    CP C
    JR NC, .hit                                 ; Jump if A (sprite Y) >= C.

    OR 1                                        ; Return NO (Z set).
    RET
.hit
    XOR A                                       ; Return YES (Z is reset).

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  _PlatformSpriteHit                      ;
;----------------------------------------------------------;
; Check whether the sprite (#SPR) one of the platforms.
; Input:
;  - IX: pointer to #SPR, single sprite to check collision for.
;  - IY: pointer to #PLAM
; Return:
;  - YES: Z is reset (JP Z). Sprite hits the platform.
;  - NO:  Z is set (JP NZ). No collision.
_PlatformSpriteHit
    CALL dbs.SetupArrays2Bank
    
    ; Exit if sprite is not alive
    BIT sr.SPRITE_ST_ACTIVE_BIT, (IX + SPR.STATE)
    JR NZ, .alive                               ; Jump if sprite is alive.

    OR 1                                        ; Return NO (Z set).
    RET
.alive

    PUSH IX

    ; Params for _PlatformHit.
    LD HL, IX
    ADD HL, SPR.X

    LD IX, IY
    LD IY, (platformsPtr)

    LD A, (platformsSize)
    LD B, A

    CALL _PlatformHit

    POP IX

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   _JetHitsPlatform                       ;
;----------------------------------------------------------;
_JetHitsPlatform

    LD A, js.SDB_T_KF                           ; Play animation.
    CALL js.ChangeJetSpritePattern
    
    ; Disable joystick, because Jetman looses control for a few frames.
    LD A, (joyOffBump)
    LD (gid.joyOffCnt), A

    ; ##########################################
    ; Decrement joystick off time with every bump.
    
    CP PL_BUMP_JOY_DEC_D1+1
    RET C                                       ; Do not allow #joyOffBump to reach 0, otherwise Jetman will go trough the obstacle.
    
    SUB PL_BUMP_JOY_DEC_D1
    LD (joyOffBump), A

    ; ##########################################
    CALL gc.JetBumpsIntoPlatform

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE