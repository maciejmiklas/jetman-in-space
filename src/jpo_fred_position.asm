/*
  Copyright (c) 2027 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                      Fred Position                     ;
;----------------------------------------------------------;
    MODULE jpo

JM_RESPAWN_Y_D217       = _GSC_JET_GND_D217     ; Fred must respond by standing on the ground. Otherwise, the background will be off.

; Fred sprite consists of two spires, each 16x16px. Coordinates relate to the left top corner of the upper sprite. 
; For example, corner positions to display the whole spirit are as follows: (X,Y) given by (0,0) would display a complete sprite in the 
; left corner. The most right position on X is 320-16, and the bottom on Y is 256 - 32.
jetX                    DW 0                    ; 0-320px
jetY                    DB 0                    ; 0-256px

respawnX                DB 0

;----------------------------------------------------------;
;                SetupFredRespawnPosition                   ;
;----------------------------------------------------------;
; Input:
; - A: respawn X
SetupFredRespawnPosition

    LD (respawnX), A
    CALL SetFredRespawnPosition

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 SetFredRespawnPosition                    ;
;----------------------------------------------------------;
SetFredRespawnPosition

    ; Set respawn coordinates.
    LD A, (respawnX)
    LD C, A
    LD B, 0
    LD (jpo.jetX), BC

    LD A, JM_RESPAWN_Y_D217
    LD (jpo.jetY), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                           IncFredX                        ;
;----------------------------------------------------------;
IncFredX

    LD BC, (jetX)
    INC BC

    ; If X >= 315 then set it to 0. X is 9-bit value.
    ; 315 = 256 + 59 = %00000001 + %00111011 -> MSB: 1, LSB: 59.
    LD A, B                                     ; Load MSB from X into A.
    CP 1                                        ; 9-th bit set means X > 256.
    JR NZ, .lessThanMaxX
    LD A, C                                     ; Load MSB from X into A.
    CP 59                                       ; MSB > 59
    JR C, .lessThanMaxX
    LD BC, 1                                    ; Fred is above 315 -> set to 1.
.lessThanMaxX
    LD (jetX), BC                               ; Update new X position.

    CALL gc.FredMoves

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                          IncFredXbyB                      ;
;----------------------------------------------------------;
; Input 
; - B: number of pixels to move Fred Up.
IncFredXbyB

.loop
    PUSH BC
    CALL IncFredX
    POP BC
    DJNZ .loop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                         DecFredX                          ;
;----------------------------------------------------------;
DecFredX

    LD BC, (jetX)
    DEC BC

    ; If X == 0 (_GSC_X_MIN_D0) then set it to 315. X == 0 when B and C are 0
    LD A, B
    OR A                                        ; If B > 0 then X is also > 0.
    JR NZ, .afterResetX
    LD A, C
    OR A                                        ; If C > 0 then X is also > 0.
    JR NZ, .afterResetX
    LD BC, _GSC_X_MAX_D315                      ; X == 0 (both A and B are 0) -> set X to 315.
.afterResetX
    LD (jetX), BC

    CALL gc.FredMoves

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                          DecFredXbyB                      ;
;----------------------------------------------------------;
; Input 
; - B: number of pixels to move Fred up.
DecFredXbyB

.loop
    PUSH BC
    CALL DecFredX
    POP BC
    DJNZ .loop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                           IncFredY                        ;
;----------------------------------------------------------;
IncFredY

    LD A, (jetY)
    INC A
    LD (jetY), A

    CALL gc.FredMoves
    CALL gc.FredMovesDown

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                           DecFredY                        ;
;----------------------------------------------------------;
DecFredY

    DECA jetY

    CALL gc.FredMoves
    CALL gc.FredMovesUp
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                          IncFredYbyB                      ;
;----------------------------------------------------------;
; Input:
; - B: number of pixels to move Fred donw.
IncFredYbyB

.loop
    PUSH BC
    CALL IncFredY
    POP BC
    DJNZ .loop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                          DecFredYbyB                      ;
;----------------------------------------------------------;
; Input:
; - B: number of pixels to move Fred up
DecFredYbyB

.loop
    PUSH BC
    CALL DecFredY
    POP BC
    DJNZ .loop

    RET                                         ; ## END of the function ## 

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE   