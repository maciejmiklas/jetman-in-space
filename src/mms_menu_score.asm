;----------------------------------------------------------;
;                    Main Hight Score                      ;
;----------------------------------------------------------;
    MODULE mms

LINES_D10               = 10
LINE_INDICATION_D10     = 10
           
TILE_START              = _TI_H_D40*2
SCORE_TEXT_SIZE_D13     = 13
LINE_SPACE              = _TI_H_D40*2
LINE_DATA_SIZE          = 4 + SCORE_TEXT_SIZE_D13   ; 2*DW + text

; This menu has two modes:
;  - Read only, where #nameChPos == NAME_CH_POS_OFF
;  - Update new high score, wehre 0<= #nameChPos <= 9
NAME_CH_POS_OFF         = $FF
NAME_CH_POS_MAX         = 9
nameChPos               = NAME_CH_POS_OFF

;----------------------------------------------------------;
;                     #EnterNewScore                       ;
;----------------------------------------------------------;
EnterNewScore

    ; User name char at first position.
    XOR A
    LD (nameChPos), A

    CALL LoadMenuScore

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     #LoadMenuScore                       ;
;----------------------------------------------------------;
LoadMenuScore

    ; Read only mode.
    LD A, NAME_CH_POS_OFF
    LD (nameChPos), A

    LD A, ms.MENU_SCORE
    CALL ms.SetMainState

    CALL js.HideJetSprite
    CALL ti.CleanAllTiles
    CALL bm.HideImage

    ; Load palette.
    LD HL, db.menuScoreBgPaletteAdr
    LD A, (db.menuScoreBgPaletteBytes)
    LD B, A
    CALL bp.LoadPalette

    ; Load background image.
    CALL fi.LoadMenuScoreImage
    CALL bm.CopyImageData

    CALL _PrintScore

    LD A, 2
    CALL _StoreNewScore

    LD A, 2
    CALL _PrintScoreLine
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    #MenuScoreUserInput                   ;
;----------------------------------------------------------;
MenuScoreUserInput

     ; Joystick fire pressed ?
    LD A, _JOY_MASK_H20                         ; Activate joystick register.
    IN A, (_JOY_REG_H1F)                        ; Read joystick input into A.
    AND %01110000                               ; Any of three fires pressed?
    JR NZ, .enterPressed

    ; ##########################################
    ; Key SPACE pressed ?
    LD A, _KB_B_TO_SPC_H7F
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A.
    BIT 0, A                                    ; Bit 0 reset -> SPACE pressed.
    JR Z, .enterPressed

    ; ##########################################
    ; Key ENTER pressed ?
    LD A, _KB_H_TO_ENT_HBF
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A.
    BIT 0, A                                    ; Bit 0 reset -> SPACE pressed.
    JR Z, .enterPressed

    RET                                         ; None of the keys pressed.

.enterPressed
    CALL gc.LoadMainMenu
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                      #_PrintScore                        ;
;----------------------------------------------------------;
; Prints structure from #db.menuScore
_PrintScore

    CALL dbs.SetupArraysBank

    LD B, LINES_D10
.placesLoop
    PUSH BC

    LD A, B
    CALL _PrintScoreLine

    POP BC
    DJNZ .placesLoop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   #_PrintScoreLine                       ;
;----------------------------------------------------------;
; Remember to "CALL dbs.SetupArraysBank"
; Input:
;  A:  Line from #db.menuScore to print as tilemap, 0 to 9 inklusive.
_PrintScoreLine

    CALL _LineToIX                              ; IX points to #db.menuScore that will be updated.

    ; ##########################################
    ; DE will point to the position when we print line given by A.
    LD D, LINE_SPACE + _TI_H_D40
    LD E, A
    MUL DE                                      ; DE has been moved A lines.
    ADD DE, TILE_START                          ; Add top margin.
    ADD DE, LINE_INDICATION_D10                     ; Add line indication.

    ; ##########################################
    ; Print HI byte from current score line.  HL points to HI byte.
    LD HL, (IX)
    LD BC, DE
    PUSH DE
    CALL tx.PrintNum16
    POP DE

    ; ##########################################
    ; Print LO byte.

    ; Move IX from HI byte to LO byte.
    INC IX
    INC IX
    LD HL, (IX)

    ADD DE, _16BIT_CHARS_D5                     ; DE points to LO byte from high score.
    LD BC, DE
    PUSH DE
    CALL tx.PrintNum16
    POP DE

    ; ##########################################
    ; Print name
    ; Move IX from LO byte to text.
    INC IX
    INC IX
    
    ADD DE, _16BIT_CHARS_D5                     ; DE points to text line with players name.
    LD BC, DE
    LD A, SCORE_TEXT_SIZE_D13

    LD DE, IX
    CALL ti.PrintText

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      #_LineToIX                          ;
;----------------------------------------------------------;
; Input:
;  A: Score line in #db.menuScore, 0 to 9 inklusive.
_LineToIX

    LD IX, db.menuScore                         ; Pointer to high score data.

    LD E, LINE_DATA_SIZE
    LD D, A
    MUL D, E
    ADD IX, DE

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   #_StoreNewScore                        ;
;----------------------------------------------------------;
; Store the last user's high score into #db.menuScore.
; Input:
;  A: Line from #db.menuScore to update, 0 to 9 inklusive.
_StoreNewScore

    CALL dbs.SetupArraysBank
    CALL _LineToIX                              ; IX points to #db.menuScore that will be updated.

    LD HL, (sc.scoreHi)
    LD (IX), HL

    INC IX
    INC IX
    LD HL, (sc.scoreLo)
    LD (IX), HL

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     #_EnterName                          ;
;----------------------------------------------------------;
; Input:
;  D: Line from #db.menuScore to update, 0 to 9 inklusive.
_EnterName

    CALL dbs.SetupArraysBank

    CALL _LineToIX                              ; IX points to #db.menuScore that will be updated.

    ; Move IX to text with user's name.
    INC IX
    INC IX
    INC IX
    INC IX

//menuScoreEmptyName
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;

    ENDMODULE