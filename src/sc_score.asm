;----------------------------------------------------------;
;                        Score                             ;
;----------------------------------------------------------;
    MODULE sc

; Memory layout: LO, HI
scoreLo                  WORD 0
scoreHi                  WORD 0

HIT_ENEMY1              = 50
HIT_ENEMY2              = 100
HIT_ENEMY3              = 150

PICKUP_ROCKET           = 200

PICKUP_ROCKET_AIR       = 250
PICKUP_ROCKET_AIR_REP   = 4

DROP_ROCKET             = 255

BOARD_ROCKET            = 250
BOARD_ROCKET_REP        = 10

;----------------------------------------------------------;
;                       #ResetScore                        ;
;----------------------------------------------------------;
ResetScore

    XOR A
    LD H, A
    LD L, A
    LD (scoreHi), HL
    LD (scoreLo), HL

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        #HitEnemy                         ;
;----------------------------------------------------------;
; Input:
;  - IX:    Pointer enemy's #SPR.
HitEnemy
    LD A, (IX + sr.SPR.SDB_INIT)

    ; Hit enemy 1?
    CP sr.SDB_ENEMY1
    JR NZ,.afterHitEnemy1
    LD C, HIT_ENEMY1
    JR .endHit
.afterHitEnemy1

    ; ##########################################
    ; Hit enemy 2?
    CP sr.SDB_ENEMY2
    JR NZ,.afterHitEnemy2
    LD C, HIT_ENEMY2
    JR .endHit
.afterHitEnemy2

    ; ##########################################
    ; Hit enemy 3?
    CP sr.SDB_ENEMY3
    JR NZ,.afterHitEnemy3
    LD C, HIT_ENEMY3
    JR .endHit
.afterHitEnemy3

.endHit
    LD B, 1
    CALL _UpdateScore

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     #HitRocketTank                       ;
;----------------------------------------------------------;
HitRocketTank

    LD HL, (scoreLo)
    
    ; Decrement H by 2 and set L to 0 (if possible).
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
;                     #BoardRocket                         ;
;----------------------------------------------------------;
BoardRocket

    LD C, BOARD_ROCKET
    LD B, BOARD_ROCKET_REP
    CALL _UpdateScore

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   #PickupRocketElement                   ;
;----------------------------------------------------------;
PickupRocketElement

    LD C, PICKUP_ROCKET
    LD B, 1
    CALL _UpdateScore 

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;               #PickupRocketElementInAir                  ;
;----------------------------------------------------------;
PickupRocketElementInAir

    LD C, PICKUP_ROCKET_AIR
    LD B, PICKUP_ROCKET_AIR_REP
    CALL _UpdateScore

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     #DropRocketElement                   ;
;----------------------------------------------------------;
DropRocketElement

    LD C, DROP_ROCKET
    LD B, 1
    CALL _UpdateScore

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       #PrintScore                        ;
;----------------------------------------------------------;
PrintScore

    LD B, 4
    LD HL, (scoreHi)
    CALL ut.PrintNumber

    LD B, 9
    LD HL, (scoreLo)
    CALL ut.PrintNumber

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;
;----------------------------------------------------------;
;                      #_UpdateScore                       ;
;----------------------------------------------------------;
; Input
;  - C: new score value for ADD
;  - B: repeat
_UpdateScore

.loop
    PUSH BC
    LD HL, scoreLo
    LD A, C
    CALL ut.Add8To32
    POP BC
    DJNZ .loop

    ; #########################################
    ; Update UI, but return if gamebar is hidden.
    LD A, (gb.gamebarState)
    CP gb.GB_VISIBLE
    RET NZ

    CALL PrintScore

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE
