;----------------------------------------------------------;
;                    Main Hight Score                      ;
;----------------------------------------------------------;
    MODULE mms

LINES_D10               = 10
LINE_INDICATION_D10     = 10

ASCII_A                 = 64                    ; 64 is space, it's not proper ASCII code, but tiles are set so
ASCII_Z                 = 90

SCORE_BYTES_D4          = 4
TILE_START              = _TI_H_D40*2
SCORE_TEXT_SIZE_D13     = 13
SCORE_TEXT_START        = SCORE_BYTES_D4 + 3    ; Whole text has 13 characters, but starts with 3 spaces
LINE_SPACE              = _TI_H_D40*2
LINE_DATA_SIZE          = 4 + SCORE_TEXT_SIZE_D13; 2*DW + text

; This menu has two modes:
;  - Read only, where #nameChPos == NAME_CH_POS_OFF
;  - Update new high score, wehre 0<= #nameChPos <= 9, plus #nameChPos == 10 when at ENTER
NAME_CH_POS_OFF         = $FF
NAME_CH_POS_MIN         = 0
NAME_CH_POS_MAX         = 9
NAME_CH_POS_ENTER       = 10
nameChPos               DB NAME_CH_POS_OFF      ; Cursor position where the user enters the name

tileChar                DB ASCII_A              ; Currently visible character from tile map
scoreLine               DB 2                    ; Score line where user enters the name

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

    ; Menu in read-only mode accepts only fire as input to exit the main menu.
    LD A, (nameChPos)
    CP NAME_CH_POS_OFF
    JR Z, .noJoystick

    LD DE, _JoyDown
    LD (mij.callbackDown), DE

    LD DE, _JoyUp
    LD (mij.callbackUp), DE

    LD DE, _JoyLeft
    LD (mij.callbackLeft), DE

    LD DE, _JoyRight
    LD (mij.callbackRight), DE
.noJoystick

    ; ###########################################
    LD A, ms.MENU_SCORE
    CALL ms.SetMainState

    CALL js.HideJetSprite
    CALL bm.HideImage
    CALL ti.CleanAllTiles

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

    ; ###########################################
    CALL _PrintWholeScore

    ; ###########################################
    LD A, 2
    CALL _StoreNewScore

    LD A, 2
    CALL _PrintScoreLine
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        #_JoyFire                         ;
;----------------------------------------------------------;
_JoyFire

    ; Fire can exit to the main menu, confirm letter selection, or enter to finish name entry.
    LD A, (nameChPos)
    CP NAME_CH_POS_OFF
    JR NZ, .enter

    ; Read-only mode, exit.
    CALL gc.LoadMainMenu
    RET
.enter

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        #_JoyDown                         ;
;----------------------------------------------------------;
_JoyDown

    ; Previous character
    LD A, (tileChar)
    CP ASCII_A
    JR NZ, .prevChar
    ; We are at first letter, jump to last one: 0 -> Z
    LD A, ASCII_Z
    JR .afterNextChar
.prevChar
    DEC A
.afterNextChar
    LD (tileChar), A

    CALL _StoreCurrentChar

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                         #_JoyUp                          ;
;----------------------------------------------------------;
_JoyUp

    ; Next character
    LD A, (tileChar)
    CP ASCII_Z
    JR NZ, .nextChar
    ; We are at last letter, jump to first one: Z -> 0
    LD A, ASCII_A
    JR .afterNextChar
.nextChar
    INC A
.afterNextChar
    LD (tileChar), A

    CALL _StoreCurrentChar

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       #_JoyLeft                          ;
;----------------------------------------------------------;
_JoyLeft

    ; Update position
    LD A, (nameChPos)
    CP NAME_CH_POS_MIN
    RET Z

    DEC A
    LD (nameChPos), A

    ; Reset character to first one
    LD A, ASCII_A
    LD (tileChar), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       #_JoyRight                         ;
;----------------------------------------------------------;
_JoyRight

    ; Update position
    LD A, (nameChPos)
    CP NAME_CH_POS_MAX
    RET Z

    INC A
    LD (nameChPos), A

    ; Reset character to first one
    LD A, ASCII_A
    LD (tileChar), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    #_PrintWholeScore                     ;
;----------------------------------------------------------;
; Prints structure from #dba.menuScore
_PrintWholeScore

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

    LD IX, dba.menuScore                        ; Pointer to high score data.

    LD E, LINE_DATA_SIZE
    LD D, A
    MUL D, E
    ADD IX, DE

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   #_StoreNewScore                        ;
;----------------------------------------------------------;
; Store the last user's high score into #dba.menuScore.
_StoreNewScore

    CALL dbs.SetupArraysBank

    LD A, (scoreLine)
    CALL _LineToIX                              ; IX points to #dba.menuScore that will be updated

    LD HL, (sc.scoreHi)
    LD (IX), HL

    INC IX
    INC IX
    LD HL, (sc.scoreLo)
    LD (IX), HL

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  #_StoreCurrentChar                      ;
;----------------------------------------------------------;
_StoreCurrentChar

    CALL dbs.SetupArraysBank

     ; DE will point to RAM containing the character the user currently enters.
    LD A, (scoreLine)
    CALL _LineToIX                              ; IX points to #dba.menuScore that will be updated
    LD DE, IX
    ADD DE, SCORE_TEXT_START                    ; Move DE to start of user name
    LD A, (nameChPos)
    ADD DE, A

    ; Store current character
    LD A, (tileChar)
    LD (DE), A

    ; Repaint score line
    LD A, (scoreLine)
    CALL _PrintScoreLine

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;

    ENDMODULE