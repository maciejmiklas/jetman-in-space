
; NextDAW
NextDAWMMUSlots:        defb    3, 6    ; Temporary MMU slots to be used for initialisation
SongIntroDataMapping:	defb	32, 33  ; Memory banks containing music data - Defned/Populated below 
Song2DataMapping:	    defb	34, 35  ; Memory banks containing music data - Defned/Populated below 
Song3DataMapping:	    defb	36, 37  ; Memory banks containing music data - Defned/Populated below 
NextDAW:		    equ     $E000
NextDAW_InitSong:	equ     NextDAW + $00
NextDAW_UpdateSong:	equ     NextDAW + $03
NextDAW_PlaySong:	equ     NextDAW + $06
NextDAW_StopSong:       equ     NextDAW + $09
NextDAW_StopSongHard:	equ     NextDAW + $0C

backupData              DW 1                    ; Used as memory backup

;----------------------------------------------------------;
;                     PlayNextDawSong                      ;
;----------------------------------------------------------;
; Play NextDAW Song 
; Params:
; de = SongDataMaping
PlayNextDawSong
; *** Map Memory Bank Containing NextData Player ***
; MEMORY MANAGEMENT SLOT 7 BANK Register
; -  Map 8kb memory bank 1 hosting NextData Player to slot 7 ($E000..$FFFF)
        nextreg $57, 31

        ld      hl, (NextDAWMMUSlots)
        call    MapNextDawMmus
        ld      a, 0
        call    NextDAW_InitSong

        ld      de, (backupData)
        ld      hl, (NextDAWMMUSlots)
        call    ReMapNextDawMmus

        call    NextDAW_PlaySong

        ret

;----------------------------------------------------------;
;                   MapNextDawMmus                         ;
;----------------------------------------------------------;
;-------------------------------------------------------------------------------------
; NextDAW - Map temporary song memory banks to MMUs
; Params:
; de = SongDataMappingReference i.e. Memory banks hosting songs
; hl = Temporary MMU slots
MapNextDawMmus:
        ld      ix, de
        
        push    de              ; Save value

; Obtain/Configure memory bank hosted in first temporary MMU
        ld      bc, $243B        ; TBBlue Register Select
        ld      a, $50           ; Port to access
        add     l
        out     (c), a           ; Select NextReg

        inc     b
        in      a, (c)          ; Select NextReg
        ld      e, a            ; Save memory bank reference
        
        ld      a, (ix)
        out     (c), a          ; Assign song memory bank to first temporary MMU slot

; Obtain/Configure memory bank hosted in second temporary MMU
        ld      bc,$243B        ; TBBlue Register Select
        ld      a,$50           ; Port to access
        add     h
        out     (c),a           ; Select NextReg

        inc     b
        in      a, (c)          ; Select NextReg
        ld      d, a            ; Save memory bank reference

        ld      a, (ix+1)
        out     (c), a          ; Assign song memory bank to second temporary MMU slot

        ld      (backupData), de  ; Save to enable restoration of MMU slots
        
        pop     de              ; Restore value

        ret

;----------------------------------------------------------;
;                   ReMapNextDawMmus                       ;
;----------------------------------------------------------;

;-------------------------------------------------------------------------------------
; NextDAW - Map original memory banks back to MMUs
; Params:
; de = Original memory banks
; hl = Temporary MMU slots
ReMapNextDawMmus
; Re-map original memory bank hosted in first temporary MMU
        ld      bc, $243B        ; TBBlue Register Select
        ld      a, $50           ; Port to access
        add     l
        out     (c), a           ; Select NextReg

        inc     b
        
        ;ld      a, e
        out     (c), e          ; Re-assign original memory bank to first temporary MMU slot

; Re-map original memory bank hosted in second temporary MMU
        ld      bc,$243B        ; TBBlue Register Select
        ld      a,$50           ; Port to access
        add     h
        out     (c),a           ; Select NextReg

        inc     b

        ;ld      a, d
        out     (c), d          ; Re-assign original memory bank to second temporary MMU slot

        ret
