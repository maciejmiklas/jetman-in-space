/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                        Score                             ;
;----------------------------------------------------------;
    MODULE sc

; Memory layout: LO, HI:
;  - scoreLo low byte  (bits 0..7)
;  - scoreLo high byte (bits 8..15)
;  - scoreHi low byte  (bits 16..23)
;  - scoreHi high byte (bits 24..31)
scoreLo                  DW 0
scoreHi                  DW 0

HIT_ENEMY1              = 20
HIT_ENEMY2              = 30
HIT_ENEMY3              = 35

; Points are stored as a 32-bit number. Each life is granted every 65k points, that is, when 3-rd byte value increases by 1.
NEXT_EXTRA_LIVE_INIT_D1 = 1
nextExtraLive           DB NEXT_EXTRA_LIVE_INIT_D1

PICKUP_ROCKET           = 200

PICKUP_ROCKET_AIR       = 250
PICKUP_ROCKET_AIR_REP   = 10

DROP_ROCKET             = 255

ROCKET_FLY              = 255

BOARD_ROCKET            = 250
BOARD_ROCKET_REP        = 20

NO_REP                  = 1

PICKUP_IN_AIR           = 200
PICKUP_IN_AIR_REP       = 5

PICKUP_REG              = 255

PICKUP_DIAMOND          = 250
PICKUP_DIAMOND_REP      = 10

SCORE_TI_START          = 4

;----------------------------------------------------------;
;                        ResetScore                        ;
;----------------------------------------------------------;
ResetScore

    XOR A
    LD H, A
    LD L, A
    LD (scoreHi), HL
    LD (scoreLo), HL

    LD A, NEXT_EXTRA_LIVE_INIT_D1
    LD (nextExtraLive), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       PickupInAir                        ;
;----------------------------------------------------------;
PickupInAir

    LD C, PICKUP_IN_AIR
    LD B, PICKUP_IN_AIR_REP
    CALL _UpdateScore

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     PickupRegular                        ;
;----------------------------------------------------------;
PickupRegular

    LD C, PICKUP_REG
    LD B, NO_REP
    CALL _UpdateScore

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     PickupDiamond                        ;
;----------------------------------------------------------;
PickupDiamond

    LD C, PICKUP_DIAMOND
    LD B, PICKUP_DIAMOND_REP
    CALL _UpdateScore

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        HitEnemy1                         ;
;----------------------------------------------------------;
HitEnemy1

    LD C, HIT_ENEMY1
    LD B, NO_REP
    CALL _UpdateScore

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        HitEnemy2                         ;
;----------------------------------------------------------;
HitEnemy2

    LD C, HIT_ENEMY2
    LD B, NO_REP
    CALL _UpdateScore

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        HitEnemy3                         ;
;----------------------------------------------------------;
HitEnemy3

    LD C, HIT_ENEMY3
    LD B, NO_REP
    CALL _UpdateScore
 
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      HitRocketTank                       ;
;----------------------------------------------------------;
HitRocketTank

    LD HL, (scoreLo)

    ; Decrement H by 3 and set L to 0 (if possible).
    LD A, H
    CP 3
    RET C

    SUB 3
    LD H, A

    XOR A
    LD L, A
    LD (scoreLo),HL

    CALL PrintScore

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      BoardRocket                         ;
;----------------------------------------------------------;
BoardRocket

    LD C, BOARD_ROCKET
    LD B, BOARD_ROCKET_REP
    CALL _UpdateScore

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    PickupRocketElement                   ;
;----------------------------------------------------------;
PickupRocketElement

    LD C, PICKUP_ROCKET
    LD B, NO_REP
    CALL _UpdateScore

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                PickupRocketElementInAir                  ;
;----------------------------------------------------------;
PickupRocketElementInAir

    LD C, PICKUP_ROCKET_AIR
    LD B, PICKUP_ROCKET_AIR_REP
    CALL _UpdateScore

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      DropRocketElement                   ;
;----------------------------------------------------------;
DropRocketElement

    LD C, DROP_ROCKET
    LD B, NO_REP
    CALL _UpdateScore

    RET                                         ; ## END of the function ##


;----------------------------------------------------------;
;                        RocketFly                         ;
;----------------------------------------------------------;
RocketFly

    LD C, ROCKET_FLY
    LD B, NO_REP
    CALL _UpdateScore

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        PrintScore                        ;
;----------------------------------------------------------;
PrintScore

    LD BC, SCORE_TI_START
    LD HL, (scoreHi)
    CALL tx.PrintNum16

    LD BC, SCORE_TI_START+_16BIT_CHARS_D5
    LD HL, (scoreLo)
    CALL tx.PrintNum16

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;


;----------------------------------------------------------;
;                 _CheckExtraLive                          ;
;----------------------------------------------------------;
    MACRO _CheckExtraLive

    LD A, (scoreHi)                             ; A = current 3rd byte (bits 16..23) of high score.
    LD B, A
    LD A, (nextExtraLive)                       ; C = next threshold byte.

    CP B
    JR NZ, .end                                 ; Not at threshold yet.

    ; We hit a new 65k block – move threshold and award life.
    INC A
    LD (nextExtraLive), A

    CALL gc.JetExtraLife

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                       _UpdateScore                       ;
;----------------------------------------------------------;
; Input
;  - C: new score value for ADD
;  - B: repeat
_UpdateScore

    ; This will also update scoreHi due to everflow in ut.Add8To32
.loop
    PUSH BC
    LD HL, scoreLo
    LD A, C
    CALL ut.Add8To32
    POP BC
    DJNZ .loop

    _CheckExtraLive

    ; #########################################
    ; Update UI, but return if gamebar is hidden
    LD A, (gb.gamebarState)
    CP gb.GB_VISIBLE_D1
    RET NZ

    CALL PrintScore

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE
