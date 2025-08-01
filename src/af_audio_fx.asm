;----------------------------------------------------------;
;                        Audio FX                          ;
;----------------------------------------------------------;

    MODULE af

    ; TO USE THIS MODULE: CALL dbs.SetupAyFxsBank

; Based on: https://github.com/robgmoran/DougieDoSource

; -Minimal ayFX player (Improved)  v2.05  25/01/21--------------;
; https://github.com/Threetwosevensixseven/ayfxedit-improved    ;
; Zeus format (http://www.desdes.com/products/oldfiles)         ;
;                                                               ;
; Forked from  v0.15  06/05/06                                  ;
; https://shiru.untergrund.net/software.shtml                   ;
;                                                               ;
; The simplest effects player. Plays effects on one AY,         ;
; without music in the background.                              ;
; Priority of the choice of channels: if there are free         ;
; channels, one of them is selected if free.                    ;
; If there are are no free channels, the longest-sounding       ;
; one is selected.                                              ;
; Procedure plays registers AF, BC, DE, HL, IX.                 ;
;                                                               ;
; Initialization:                                               ;
;   ld hl, the address of the effects bank                      ;
;   call AfxInit                                                ;
;                                                               ;
; Start the effect:                                             ;
;   ld a, the number of the effect (0..255)                     ;
;   call AfxPlay                                                ;
;                                                               ;
; In the interrupt handler:                                     ;
;   call AfxFrame                                               ;
;                                                               ;
; Start the effect on a specified channel:                      ;
;   ld a, the number of the effect (0..255)                     ;
;   ld e, the number of the channel (A=0, B=1, C=2)             ;
;   call AfxPlayChannel                                         ;
;                                                               ;
; Start the effect with sustain loop enabled:                   ;
;   ld a, the number of the effect (0..255)                     ;
;   ld e, the number of the channel (A=0, B=1, C=2)             ;
;   ld bc, the bank address + the release address offset        ;
;   call AfxPlayChannel                                         ;
;                                                               ;
; Notify AFX Frame that the sound be should be looped back to   ;
; the sustain point once the release point has been reached:    ;
;   ld a, the number of the effect (0..255)                     ;
;   ld e, the number of the channel (A=0, B=1, C=2)             ;
;   ld bc, the bank address + the sustain address offset        ;
;   call AfxSustain                                             ;
;                                                               ;
; Change log:
;   v2.05  25/01/21  Bug fix: AfxInit was overwriting itself    ;
;                    the first time it was called, so it        ;
;                    couldn't ever be called a second time.     ;
;   v2.04  22/10/17  Bug fix: EffectTime was not fully          ;
;                    initialised.                               ;
;   v2.03  22/10/17  Bug fix: disabled loop markers should have ;
;                    MSB $00, as $FF could be a valid address.  ;
;                    Backported Zeus player to Pasmo format.    ;
;   v2.02  21/10/17  Added the ability to loop a sound while    ;
;                    receiving sustain messages.                ;
;   v2.01  21/10/17  Added the ability to play a sound on a     ;
;                    specific channel.                          ;
;   v2.00  27/08/17  Converted Z80 player to Zeus format.       ;
; --------------------------------------------------------------;

; Channel descriptors, 4 bytes per channel:
; +0 (2) current address (channel is free if high byte=$00)
; +2 (2) sound effect time
; +2 (2) start address of sustain loop (disabled if high byte=$00)
; +2 (2) end address of sustain loop (disabled if high byte=$00)
AFX_CH_DESC_COUNT       = 3
afxChDesc               DS AFX_CH_DESC_COUNT*8
AFX_SMC                 = 0

FX_JET_LAND             = 1
FX_FIRE2                = 2
MENU_ENTER              = 3 
FX_ROCKET_START         = 4
FX_PICKUP_LIVE          = 5
FX_JET_NORMAL           = 6
FX_PICKUP_FUEL          = 7
FX_GRENADE_EXPLODE       = 8
FX_PICKUP_DIAMOND       = 9
FX_JET_OVERHEAT         = 10
FX_EXPLODE_TANK         = 11
FX_PICKUP_GUN           = 12
FX_BUMP_PLATFORM        = 13
FX_JET_KILL             = 14
FX_FIRE1                = 15
FX_EXPLODE_ENEMY_1      = 16
FX_ROCKET_READY         = 17
FX_EXPLODE_ENEMY_2      = 18
FX_EXPLODE_ENEMY_3      = 19
FX_ROCKET_FLY           = 20
FX_ROCKET_EL_DROP       = 21
FX_PICKUP_STRAWBERRY    = 22
FX_MENU_MOVE            = 23
FX_PICKUP_JAR           = 24
FX_PICKUP_ROCKET_EL     = 25
FX_FIRE_PLATFORM_HIT    = 26
FX_JET_TAKE_OFF         = 27
FX_THIEF                = 28
FX_FREEZE_ENEMIES       = 29

;----------------------------------------------------------;
;                         SetupAyFx                        ;
;----------------------------------------------------------;
; To use this function: CALL dbs.SetupAyFxsBank
;
; Setup AYFX for playing sound effects.
SetupAyFx

    LD HL, effectsFileAddr                      ; Address containing sound effects
    CALL _AfxInit

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       SetAy3ToMono                       ;
;----------------------------------------------------------;
; To use this function: CALL dbs.SetupAyFxsBank
;
; Configure AY3 as mono; call after PlayNextDawSong.
SetAy3ToMono

    LD A, _PERIPHERAL_04_H09
    CALL ut.ReadNextReg

    SET 7, A
    NEXTREG _PERIPHERAL_04_H09, A
        
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                         AfxFrame                         ;
;----------------------------------------------------------;
; To use this function: CALL dbs.SetupAyFxsBank
;
; Play the current frame.
AfxFrame

    LD A, %1'11'111'11                          ; Set FX to AY-1
    LD BC, _GL_REG_SOUND_HFFFD
    OUT (C), A

    LD BC, $03FD
    LD IX, afxChDesc

.afxFrame0
    PUSH BC

    LD A, 11
    LD H, (IX+1)                                ; Compare high-order byte of address to <11
    CP H
    JR NC, .afxFrame7                           ; The channel does not play, we skip
    LD L, (IX+0)
    LD E, (HL)                                  ; We take the value of the information byte
    INC HL

    SUB B                                       ; Select the volume register:
    LD D, B                                     ; (11-3=8, 11-2=9, 11-1=10)

    LD B, $FF                                   ; Output the volume value
    OUT (C), A
    LD B, $BF
    LD A, E
    AND $0F
    OUT (C), A
    BIT 5, E                                    ; Will the tone change?
    JR Z, .afxFrame1                            ; Tone does not change

    LD A, 3                                     ; Select the tone registers:
    SUB D                                       ; 3-3=0, 3-2=1, 3-1=2
    ADD A, A                                    ; 0*2=0, 1*2=2, 2*2=4

    LD B, $FF                                   ; Output the tone values
    OUT (C), A
    LD B, $BF
    LD D, (HL)
    INC HL
    OUT (C), D
    LD B, $FF
    INC A
    OUT (C), A
    LD B, $BF
    LD D, (HL)
    INC HL
    OUT (C), D

.afxFrame1
    BIT 6, E                                    ; Will the noise change?
    JR Z, .afxFrame3                            ; Noise does not change

    LD A, (HL)                                  ; Read the meaning of noise
    SUB $20
    JR C, .afxFrame2                            ; Less than $20, play on
    LD H, A                                     ; Otherwise the end of the effect
    LD C,$FF
    LD B, C                                     ; In BC we record the most time
    JR .afxFrame6

.afxFrame2
    INC HL
    LD (afxNseMix+1), A                        ; Keep the noise value

.afxFrame3
    POP BC                                      ; Restore the value of the cycle in B
    PUSH BC
    INC B                                       ; Number of shifts for flags TN

    LD A, %01101111                             ; Mask for flags TN
.afxFrame4:
    RRC E                                       ; Shift flags and mask
    RRCA
    DJNZ .afxFrame4
    LD D, A

    LD BC, afxNseMix+2                         ; Store the values of the flags
    LD A, (BC)
    XOR E
    AND D
    XOR E                                       ; E is masked with D
    LD (BC), A

.afxFrame5
    LD C, (IX+2)                                ; Increase the time counter
    LD B, (IX+3)
    INC BC

.afxFrame6
    LD (IX+2), C
    LD (IX+3), B

    LD (IX+0), L                                ; Save the changed address
    LD (IX+1), H

    CALL _CheckRelease
.afxFrame7
    LD BC, 8                                    ; Go to the next channel
    ADD IX, BC
    POP BC
    DJNZ .afxFrame0

    LD HL, $FFBF                                ; Output the value of noise and mixer

afxNseMix
    LD DE, 0                                    ; +1(E)=noise, +2(D)=mixer
    LD A, 6
    LD B, H
    OUT (C), A
    LD B, L
    OUT (C), E
    INC A
    LD B, H
    OUT (C), A
    LD B, L
    OUT (C), D

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        AfxPlay                           ;
;----------------------------------------------------------;
; To use this function: CALL dbs.SetupAyFxsBank
;
; Launch the effect on a free channel. If no free channels, the longest sounding is selected.
; Input: 
;  - A: Effect number 0..255
;  - BC: ReleaseAddrCh[N]
AfxPlay

    DEC A                                       ; Number effects from 1 as the ayfxedit.exe does
    
    PUSH AF
    LD A, C
    LD (releaseLoSMC), A                        ; SMC>
    LD A, B
    LD (releaseHiSmc), A                        ; SMC>
    POP AF
    
    LD DE, 0                                    ; In DE the longest time in search
    LD H, E
    LD L, A
    ADD HL, HL

afxBnkAdr1
    LD BC, 0                                    ; Address of the effect offsets table
    ADD HL, BC
    LD C, (HL)
    INC HL
    LD B, (HL)
    ADD HL, BC                                  ; The effect address is obtained in HL
    PUSH HL                                     ; Save the effect address on the stack
    LD HL, afxChDesc                            ; Empty channel search
    LD B, 3
.afxPlay0
    INC HL
    INC HL
    LD A, (HL)                                  ; Compare the channel time with the largest
    INC HL
    CP E
    JR C, .afxPlay1
    LD C, A
    LD A, (HL)
    CP D
    JR C, .afxPlay1
    LD E, C                                     ; Remember the longest time
    LD D, A
    PUSH HL                                     ; Remember the channel address+3 in IX
    POP IX

.afxPlay1
    LD A, 5
    ADD A, L                                    ; ADD(HL, A) }
    LD L, A	                                    ;            }
    ADC A, H                                    ;            }
    SUB L                                       ;            }
    LD H, A                                     ;            }
    DJNZ .afxPlay0

    POP DE                                      ; Take the effect address from the stack
    LD (IX-3), E                                ; Put in the channel descriptor
    LD (IX-2), D
    LD (IX-1), B                                ; Zero the playing time
    LD (IX-0), B 

releaseLoSMC equ $+3  
    LD (IX+3), AFX_SMC                          ; <SMC Release LSB
releaseHiSmc equ $+3
    LD (ix+4), AFX_SMC                          ; <SMC Release MSB
    XOR A
    LD (IX+1), A                                ; Reset sustain LSB
    LD (IX+2), A                                ; Reset sustain MSB

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;
;----------------------------------------------------------;
;                     _CheckRelease                        ;
;----------------------------------------------------------;
_CheckRelease
    LD A, (IX+6)                                ; get release LSB
    CP L
    RET NZ                                      ; Carry on if no MLB match
    LD A, (IX+7)                                ; Get release MSB
    OR A
    RET Z                                       ; Carry on if release disabled
    CP H
    RET NZ                                      ; Carry on if no MSB match
    PUSH BC
    LD A, (IX+4)
    OR A
    JP Z, .noLoop
    LD A, (IX+5)                                ; Set CurrentAddrCh[N] back
    LD (IX+1), A                                ; to SustainAddrCh[N] LSB
    LD A, (IX+4)                                ;
    LD (IX+0), A                                ; and MSB
    XOR A
    LD (IX+4), A                                ; then toggle off the sustain
    LD (IX+5), A                                ; to require it to be resent
.noLoop:
    POP BC

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                         _AfxInit                         ;
;----------------------------------------------------------;
; Initialize the effects player. Turns off all channels, sets variables.
; Input: 
;  -  HL: Address with effects
_AfxInit

    INC HL
    LD (afxBnkAdr1+1), HL                       ; Save the address of the table of offsets
    LD HL, afxChDesc                            ; Mark all channels as empty
    LD DE, $00FF
    LD BC, AFX_CH_DESC_COUNT*256+$FD
.afxInit0
    LD (HL), D
    INC HL
    LD (HL), D
    INC HL
    LD (HL), E
    INC HL
    LD (HL), E
    INC HL
   /* LD (HL), D
    INC HL
    LD (HL), D
    INC HL
    LD (HL), D
    INC HL
    LD (HL), D
    INC HL*/
    DJNZ .afxInit0

    LD HL, $FFBF                                ; Initialize  AY
    LD E, $15
.afxInit1
    DEC E
    LD B, H
    OUT (C), E
    LD B, L
    OUT (C), D
    JR NZ, .afxInit1

    LD (afxNseMix+1), DE                        ; Reset the player variables

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     Effects file                         ;
;----------------------------------------------------------;
effectsFileAddr
    INCBIN  "assets/com/effects.afb",0
effectsFileSize  = $ - effectsFileAddr
    ASSERT effectsFileSize <= 7 * 1024

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE