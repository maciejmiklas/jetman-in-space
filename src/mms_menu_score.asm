;----------------------------------------------------------;
;                    Main Hight Score                      ;
;----------------------------------------------------------;
    MODULE mms

LINES_D10               = 10
LINE_INDICATION_D10     = 10

SCORE_BYTES_D4          = 4
TILE_START              = _TI_H_D40*2
SCORE_TEXT_SIZE_D13     = 13
LINE_SPACE              = _TI_H_D40*2
LINE_DATA_SIZE          = 4 + SCORE_TEXT_SIZE_D13   ; 2*DW + text

; This menu has two modes:
;  - Read only, where #nameChPos == NAME_CH_POS_OFF
;  - Update new high score, wehre 0<= #nameChPos <= 9, plus #nameChPos == 10 when at ENTER
NAME_CH_POS_OFF         = $FF
NAME_CH_POS_MIN         = 0
NAME_CH_POS_MAX         = 9
NAME_CH_POS_ENTER       = 10
nameChPos               DB NAME_CH_POS_OFF

;----------------------------------------------------------;
;                     #EnterNewScore                       ;
;----------------------------------------------------------;
EnterNewScore

    XOR A                                       ; Enable user name input
    LD (nameChPos), A

    CALL _SetupMenuScore

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     #LoadMenuScore                       ;
;----------------------------------------------------------;
LoadMenuScore

    ; Read only mode.
    LD A, NAME_CH_POS_OFF
    LD (nameChPos), A

    CALL _SetupMenuScore

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                    #_SetupMenuScore                      ;
;----------------------------------------------------------;
_SetupMenuScore

    ; Setup joystick
    CALL mij.SetupJoystick

    LD DE, _JoyFire
    LD (mij.callbackFire), DE

    LD DE, _JoyDown
    LD (mij.callbackDown), DE

    LD DE, _JoyUp
    LD (mij.callbackUp), DE

    LD DE, _JoyLeft
    LD (mij.callbackLeft), DE

    LD DE, _JoyRight
    LD (mij.callbackRight), DE

    ; ###########################################
    LD A, ms.MENU_SCORE
    CALL ms.SetMainState

    CALL js.HideJetSprite
    CALL ti.CleanAllTiles
    CALL bm.HideImage

    ; ###########################################
    ; Load palette
    LD HL, db.menuScoreBgPaletteAdr
    LD A, (db.menuScoreBgPaletteBytes)
    LD B, A
    CALL bp.LoadPalette

    ; ###########################################
    ; Load background image
    CALL fi.LoadMenuScoreImage
    CALL bm.CopyImageData

    CALL _PrintScore

    LD A, 2
    CALL _StoreNewScore

    LD A, 2
    CALL _PrintScoreLine
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        #_JoyFire                         ;
;----------------------------------------------------------;
_JoyFire

    ; Can user input name?
    LD A, (nameChPos)
    CP NAME_CH_POS_OFF
    RET Z

    CALL gc.LoadMainMenu

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        #_JoyDown                         ;
;----------------------------------------------------------;
_JoyDown

    ; Can user input name?
    LD A, (nameChPos)
    CP NAME_CH_POS_OFF
    RET Z

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                         #_JoyUp                          ;
;----------------------------------------------------------;
_JoyUp

    ; Can user input name?
    LD A, (nameChPos)
    CP NAME_CH_POS_OFF
    RET Z

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       #_JoyLeft                          ;
;----------------------------------------------------------;
_JoyLeft

    ; Can user input name?
    LD A, (nameChPos)
    CP NAME_CH_POS_OFF
    RET Z

    CP NAME_CH_POS_MIN
    RET Z

    DEC A
    LD (nameChPos), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       #_JoyRight                         ;
;----------------------------------------------------------;
_JoyRight

    ; Can user input name?
    LD A, (nameChPos)
    CP NAME_CH_POS_OFF
    RET Z

    CP NAME_CH_POS_MAX
    RET Z

    INC A
    LD (nameChPos), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      #_PrintScore                        ;
;----------------------------------------------------------;
; Prints structure from #dba.menuScore
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
;  A:  Line from #dba.menuScore to print as tilemap, 0 to 9 inklusive
_PrintScoreLine

    CALL _LineToIX                              ; IX points to #dba.menuScore that will be updated

    ; ##########################################
    ; DE will point to the position when we print line given by A
    LD D, LINE_SPACE + _TI_H_D40
    LD E, A
    MUL DE                                      ; DE has been moved A lines
    ADD DE, TILE_START                          ; Add top margin
    ADD DE, LINE_INDICATION_D10                 ; Add line indication

    ; ##########################################
    ; Print HI byte from current score line.  HL points to HI byte
    LD HL, (IX)
    LD BC, DE
    PUSH DE
    CALL tx.PrintNum16
    POP DE

    ; ##########################################
    ; Print LO byte

    ; Move IX from HI byte to LO byte
    INC IX
    INC IX
    LD HL, (IX)

    ADD DE, _16BIT_CHARS_D5                     ; DE points to LO byte from high score
    LD BC, DE
    PUSH DE
    CALL tx.PrintNum16
    POP DE

    ; ##########################################
    ; Print name
    ; Move IX from LO byte to text
    INC IX
    INC IX
    
    ADD DE, _16BIT_CHARS_D5                     ; DE points to text line with players name
    LD BC, DE
    LD A, SCORE_TEXT_SIZE_D13

    LD DE, IX
    CALL ti.PrintText

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      #_LineToIX                          ;
;----------------------------------------------------------;
; Input:
;  A: Score line in #dba.menuScore, 0 to 9 inklusive
_LineToIX

    LD IX, dba.menuScore                         ; Pointer to high score data.

    LD E, LINE_DATA_SIZE
    LD D, A
    MUL D, E
    ADD IX, DE

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   #_StoreNewScore                        ;
;----------------------------------------------------------;
; Store the last user's high score into #dba.menuScore.
; Input:
;  A: Line from #dba.menuScore to update, 0 to 9 inklusive
_StoreNewScore

    CALL dbs.SetupArraysBank
    CALL _LineToIX                              ; IX points to #dba.menuScore that will be updated.

    LD HL, (sc.scoreHi)
    LD (IX), HL

    INC IX
    INC IX
    LD HL, (sc.scoreLo)
    LD (IX), HL

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  #_LoadCharPosToDe                       ;
;----------------------------------------------------------;
; Input:
;  A: Line from #dba.menuScore to update, 0 to 9 inklusive
_LoadCharPosToDe

    CALL _LineToIX                              ; IX points to #dba.menuScore that will be updated.

    LD DE, IX
    ADD DE, SCORE_BYTES_D4
    LD A, (nameChPos)
    ADD DE, A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     #_EnterName                          ;
;----------------------------------------------------------;
; Input:
;  A: Line from #dba.menuScore to update, 0 to 9 inklusive
_EnterName

    CALL dbs.SetupArraysBank

    CALL _LoadCharPosToDe                       ; DE points to the letter currently changing in  #dba.menuScore.

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;

    ENDMODULE