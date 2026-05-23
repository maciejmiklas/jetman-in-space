;----------------------------------------------------------;
;                        Debugger                          ;
;----------------------------------------------------------;

    MODULE deb

TEMP_SLOT_D200          = 140

;----------------------------------------------------------;
;                 _Copy8KSlotXTo6                          ;
;----------------------------------------------------------;
    MACRO deb._Copy8KSlotXTo6 SLOT_X

    NEXTREG _MMU_REG_SLOT6_H56, TEMP_SLOT_D200

    LD HL, SLOT_X
    LD DE, _RAM_SLOT6_STA_HC000
    LD BC, _BANK_BYTES_D8192
    LDIR

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                  Copy8KSlot0To6                          ;
;----------------------------------------------------------;
    MACRO deb.Copy8KSlot0To6

    deb._Copy8KSlotXTo6 _RAM_SLOT0_STA_H0000

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                  Copy8KSlot1To6                          ;
;----------------------------------------------------------;
    MACRO deb.Copy8KSlot1To6

    deb._Copy8KSlotXTo6 _RAM_SLOT1_STA_H2000

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                  Copy8KSlot2To6                          ;
;----------------------------------------------------------;
    MACRO deb.Copy8KSlot2To6

    deb._Copy8KSlotXTo6 _RAM_SLOT2_STA_H4000

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                  Copy8KSlot3To6                          ;
;----------------------------------------------------------;
    MACRO deb.Copy8KSlot3To6

    deb._Copy8KSlotXTo6 _RAM_SLOT3_STA_H6000

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                  Copy8KSlot4To6                          ;
;----------------------------------------------------------;
    MACRO deb.Copy8KSlot4To6

    deb._Copy8KSlotXTo6 _RAM_SLOT4_STA_H8000

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                  Copy8KSlot5To6                          ;
;----------------------------------------------------------;
    MACRO deb.Copy8KSlot5To6

    deb._Copy8KSlotXTo6 _RAM_SLOT5_STA_HA000

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                  Copy8KSlot6To7                          ;
;----------------------------------------------------------;
; Remember to call #dbs function to map slot 6 bank.
    MACRO deb.Copy8KSlot6To7

    NEXTREG _MMU_REG_SLOT7_H57, TEMP_SLOT_D200

    LD HL, _RAM_SLOT6_STA_HC000
    LD DE, _RAM_SLOT7_STA_HE000
    LD BC, _BANK_BYTES_D8192
    LDIR

    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                   SetupTestBank                          ;
;----------------------------------------------------------;
SetupTestBank

    dbs.SetupCodeMusicBank
    deb.Copy8KSlot6To7

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     CompareBank                          ;
;----------------------------------------------------------;
; debugBuffer    BLOCK 1000, $FF      ; 1000 bytes filled with $FF
; :LD A, $02: CALL deb.CompareBank
; Input:
;  - A: number to print for debugger.
CompareBank

    dbs.SetupCodeMusicBank
    LD BC, 990
    LD DE, 0
    CALL CompareBank6to7

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  CompareBank2to6                         ;
;----------------------------------------------------------;
; Remember to call #dbs function to map slot 6 bank.
; Input:
;  - A: number to print for debugger.
;  - BC: amount of bytes to compare.
;  - DE: amount of bytes to skip.
CompareBank2to6

    PUSH AF
    NEXTREG _MMU_REG_SLOT6_H56, TEMP_SLOT_D200

    PUSH BC

    LD BC, DE

    LD HL, _RAM_SLOT2_STA_H4000
    ADD HL, BC
    
    LD DE, _RAM_SLOT6_STA_HC000
    ADD DE, BC

    POP BC
.loop
    LD A, (DE)
    CP (HL)
    JR NZ, .bytesDiffer

    INC HL
    INC DE
    DEC BC

    ; Check if BC reached zero
    LD A, B
    OR C
    JR NZ, .loop
    
    JR .end

.bytesDiffer
    POP AF
    _DEB

.end
    POP AF

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  CompareBank6to7                         ;
;----------------------------------------------------------;
; Remember to call #dbs function to map slot 6 bank.
; Input:
;  - A: number to print for debugger.
;  - BC: amount of bytes to compare.
;  - DE: amount of bytes to skip.
CompareBank6to7

    PUSH AF
    NEXTREG _MMU_REG_SLOT7_H57, TEMP_SLOT_D200

    PUSH BC

    LD BC, DE

    LD HL, _RAM_SLOT6_STA_HC000
    ADD HL, BC
    
    LD DE, _RAM_SLOT7_STA_HE000
    ADD DE, BC

    POP BC
.loop
    LD A, (DE)
    CP (HL)
    JR NZ, .bytesDiffer

    INC HL
    INC DE
    DEC BC

    ; Check if BC reached zero
    LD A, B
    OR C
    JR NZ, .loop
    
    JR .end

.bytesDiffer
    POP AF
    _DEB

.end
    POP AF

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE


