;----------------------------------------------------------;
;                    Main Hight Score                      ;
;----------------------------------------------------------;
    MODULE mms

LINES_D10               = 10
LINE_INDICATION_TI_D10  = 10

ASCII_A                 = 64                    ; 64 is space, it's not proper ASCII code, but tiles are set so
ASCII_Z                 = 90

MARGIN_TOP_LI_D2        = 2                     ; Top margin has 3 lines
MARGIN_TOP_TI_D80       = MARGIN_TOP_LI_D2*ti.H_D40

SPACE_LINES_LI_D2       = 2                     ; Space between score lines is 2 lines
SPACE_LINES_TI_D80      = SPACE_LINES_LI_D2*ti.H_D40 ; Number of tiles taken by the space between score lines
SCORE_H_LI_D3           = 3                     ; Number of lines taken by the single score
SCORE_H_TI_D120         = SCORE_H_LI_D3*ti.H_D40; Number of tiles taken by the single score

NAME_TI_SPACE_D3        = 3                     ; Before the name there are 3 spaces
SCORE_TI_D10            = 10                    ; 2x16 bit has 2x5 = 10 characters
SCORE_BYTES_D4          = 4                     ; Hi score takes 4 bytes, 2x16bit number
SCORE_TX_START_BYT_D7   = SCORE_BYTES_D4+NAME_TI_SPACE_D3; Whole text has 13 characters, but starts with 3 spaces
SCORE_TX_BYTES_D13      = NAME_TI_SPACE_D3+SCORE_TI_D10; User can enter 10 character, but we display 13: [3xSPACE][10 characters for user name]
LINE_BYTES_D15          = 4+SCORE_TX_BYTES_D13  ; 2*DW + text

; This menu has two modes:
;  - Read only, where #nameChPos == NAME_CH_POS_OFF
;  - Update new high score, wehre 0<= #nameChPos <= 9, plus #nameChPos == 10 when at ENTER
NAME_CH_POS_OFF         = $FF
NAME_CH_POS_MIN         = 0
NAME_CH_POS_MAX         = 9
NAME_CH_POS_ENTER       = 10
nameChPos               DB NAME_CH_POS_OFF      ; Cursor position where the user enters the name

tileChar                DB ASCII_A              ; Currently visible character from tile map
scoreLine               DB 6                    ; Score line where user enters the name

;----------------------------------------------------------;
;                      #AnimateCursor                      ;
;----------------------------------------------------------;
AnimateCursor

    CALL dbs.SetupArraysBank
    LD IX, dba.menuScoreCursor
    CALL sr.SetSpriteId
    CALL sr.UpdateSpritePattern

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     #EnterNewScore                       ;
;----------------------------------------------------------;
EnterNewScore

    XOR A                                       ; Enable user name input
    LD (nameChPos), A

    CALL _SetupMenuScore
    CALL _StoreNewScore

    LD A, (scoreLine)
    CALL _PrintScoreLine

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

    ; FX
    LD A, af.MENU_ENTER
    CALL af.AfxPlay

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

    ; FX
    LD A, af.FX_FIRE2
    CALL af.AfxPlay

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

    ; FX
    LD A, af.FX_FIRE1
    CALL af.AfxPlay

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

    ; FX
    LD A, af.FX_MENU_MOVE
    CALL af.AfxPlay

    CALL _UpdateCursor

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

    ; FX
    LD A, af.FX_MENU_MOVE
    CALL af.AfxPlay

    CALL _UpdateCursor

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    #_UpdateCursor                        ;
;----------------------------------------------------------;
_UpdateCursor

    CALL dbs.SetupArraysBank

    ; Calculate X postion
    LD DE, (nameChPos)
    ADD DE, LINE_INDICATION_TI_D10
    ADD DE, SCORE_TI_D10
    ADD DE, NAME_TI_SPACE_D3
    LD D, ti.TI_PIXELS_D8
    MUL D, E
    ADD DE, -4
    LD HL, DE

    ; ##########################################
    ; Calculate the Y position for the cursor

    ; First calculate the amount of tiles taken by
    LD A, (scoreLine)
    LD D, SCORE_H_LI_D3
    LD E, A
    MUL D, E                                    ; DE has been moved A lines
    ADD DE, MARGIN_TOP_LI_D2                    ; Add top margin

    ; E contains the number of lines from the top to the current score, D is 0.
    LD D, ti.TI_PIXELS_D8
    MUL D, E                                    ; E contains number of pixels from the top, D is 0.

    ; ##########################################
    ; Store X, Y position to sprite
    LD IX, dba.menuScoreCursor
    LD (IX + sr.SPR.X), HL
    LD (IX + sr.SPR.Y), E

    ; ##########################################
    CALL sr.UpdateSpritePosition

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
    LD D, SCORE_H_TI_D120
    LD E, A
    MUL D, E                                    ; DE has been moved A lines
    ADD DE, MARGIN_TOP_TI_D80                   ; Add top margin
    ADD DE, LINE_INDICATION_TI_D10                 ; Add line indication

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
    ; Move IX and DE from LO byte to text
    INC IX
    INC IX
    ADD DE, _16BIT_CHARS_D5                     ; DE points to text line with players name

    LD BC, DE
    LD A, SCORE_TX_BYTES_D13
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

    LD E, LINE_BYTES_D15
    LD D, A
    MUL D, E
    ADD IX, DE

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   #_StoreNewScore                        ;
;----------------------------------------------------------;
; Store the last user's high score into #dba.menuScore, position is given by #scoreLine
_StoreNewScore

    ; Set IX to #dba.menuScore that will be updated 
    CALL dbs.SetupArraysBank
    LD A, (scoreLine)
    CALL _LineToIX

    ; ##########################################
    ; Copy score from game to the line
    LD HL, (sc.scoreHi)
    LD (IX), HL

    INC IX
    INC IX

    LD HL, (sc.scoreLo)
    LD (IX), HL

    ; ##########################################
    ; Clear users name
    LD B, SCORE_TX_BYTES_D13 +2                ; +2 for size of #sc.scoreLo
    LD A, ti.TX_IDX_EMPTY
.nameLoop
    LD (IX), A
    INC IX
    DJNZ .nameLoop

    ; ##########################################
    ; Show cursor
    CALL _UpdateCursor

    XOR A
    LD IX, dba.menuScoreCursor

    CALL sr.SetSpriteId                         ; Set the ID of the sprite for the following commands
    CALL sr.SetStateVisible
    CALL sr.ShowSprite

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  #_StoreCurrentChar                      ;
;----------------------------------------------------------;
_StoreCurrentChar

    CALL dbs.SetupArraysBank

     ; DE will point to RAM containing the character the user currently enters.
    LD A, (scoreLine)
    CALL _LineToIX                                 ; IX points to #dba.menuScore that will be updated
    LD DE, IX
    ADD DE, SCORE_TX_START_BYT_D7                    ; Move DE to start of user name
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