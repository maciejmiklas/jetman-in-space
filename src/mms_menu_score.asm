/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                        High Score                        ;
;----------------------------------------------------------;
    MODULE mms

LINES_D10               = 10                    ; There are 10 score lines, but we display only 9, skipping first one in #db2.highScore.
LINE_INDICATION_TI_D10  = 10

ASCII_A                 = 64                    ; 64 is space, it's not proper ASCII code, but tiles are set so.
ASCII_Z                 = 90

MARGIN_TOP_LI_D2        = 2                     ; Top margin has 3 lines.
MARGIN_TOP_TI_D80       = MARGIN_TOP_LI_D2*_TI_H_D40

SPACE_LINES_LI_D2       = 2                     ; Space between score lines is 2 lines.
SPACE_LINES_TI_D80      = SPACE_LINES_LI_D2*_TI_H_D40 ; Number of tiles taken by the space between score lines.
SCORE_H_LI_D3           = 3                     ; Number of lines taken by the single score.
SCORE_H_TI_D120         = SCORE_H_LI_D3*_TI_H_D40; Number of tiles taken by the single score.
CURSOR_SPR_ADJ          = -4

NAME_TI_SPACE_D3        = 3                     ; Before the name there are 3 spaces.
SCORE_TI_D10            = 10                    ; 2x16 bit has 2x5 = 10 characters.
SCORE_BYTES_D4          = 4                     ; Hi score takes 4 bytes, 2x16bit number.
SCORE_TX_START_BYT_D7   = SCORE_BYTES_D4+NAME_TI_SPACE_D3; Whole text has 13 characters, but starts with 3 spaces.
SCORE_TX_BYTES_D13      = NAME_TI_SPACE_D3+SCORE_TI_D10; User can enter 10 character, but we display 13: [3xSPACE][10 characters for user name].
LINE_BYTES_D15          = 4+SCORE_TX_BYTES_D13  ; 2*DW + text
SCORE_BYTES_D150        = LINE_BYTES_D15 * 10   ; Whole score table for a particular difficulty.

; This menu has two modes:
;  - Read only, where #nameChPos == NAME_CH_POS_OFF.
;  - Update new high score, wehre 0<= #nameChPos <= 9, plus #nameChPos == 10 when at ENTER.
NAME_CH_POS_OFF         = $FF
NAME_CH_POS_MIN         = 0
NAME_CH_POS_MAX         = 9
NAME_CH_POS_ENTER       = 10
nameChPos               DB NAME_CH_POS_OFF      ; Cursor position where the user enters the name.

ENTER_TI_POS            = LINE_INDICATION_TI_D10+SCORE_TI_D10+SCORE_TX_BYTES_D13+1
ENTER_SPACE_PX          = 8                     ; Space between name text and ENTER in pixels.

tileChar                DB ASCII_A              ; Currently visible character from tile map.
scoreLine               DB $FF                  ; Score line where user enters the name, 1 - first place, 9 - last place.

menuScoreCursor
    SPR {10/*ID*/, sr.SDB_FIRE/*SDB_INIT*/, 0/*SDB_POINTER*/, 0/*X*/, 0/*Y*/, 0/*STATE*/, 0/*NEXT*/, 0/*REMAINING*/, 0/*EXT_DATA_POINTER*/}


;----------------------------------------------------------;
;----------------------------------------------------------;
;                        MACROS                            ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                    _StoreNewScore                        ;
;----------------------------------------------------------;
; Store the last user's high score into #db2.highScore, position is given by #scoreLine.
    MACRO _StoreNewScore

    ; Set IX to #db2.highScore that will be updated.
    CALL dbs.SetupStorageBank
    LD A, (scoreLine)

    ; Does the user qualify for the scoreboard?
    CP LINES_D10
    JR C, .prepareEdit
    
    CALL _SetScoreToReadOnly
    JR .end
.prepareEdit

    CALL _LineToIX

    ; ##########################################
    ; Copy score from game to the line.
    LD HL, (sc.scoreHi)
    LD (IX), HL

    INC IX
    INC IX

    LD HL, (sc.scoreLo)
    LD (IX), HL

    ; ##########################################
    ; Clear users name.
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
    LD IX, menuScoreCursor

    CALL sr.SetSpriteId                         ; Set the ID of the sprite for the following commands
    CALL sr.SetStateVisible
    CALL sr.ShowSprite

    ; ##########################################
    ; Show enter tile on the end the of score line.
    CALL _SetDeToEnterTiRam

    ; Load tile and palette into tile ram.
    LD A, ti.TX_PALETTE_D0
    LD (DE), A
    INC DE
    
    LD A, ti.TI_ENTER
    LD (DE), A

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                     _PrintWholeScore                     ;
;----------------------------------------------------------;
; Prints structure from #db2.highScore
    MACRO _PrintWholeScore

    CALL dbs.SetupStorageBank

    LD B, LINES_D10
.placesLoop
    PUSH BC

    LD A, B
    CALL _PrintScoreLine

    POP BC
    DJNZ .placesLoop

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;                  _CalculateScoreLine                     ;
;----------------------------------------------------------;
; Return:
;  A: contains line number for high score based on new users' game score. Values 0-9, 10+ means not qualified.
    MACRO _CalculateScoreLine

    CALL dbs.SetupStorageBank

    ; Compare the new score starting from the bottom line (nr 9) until we find a line in the score that is larger than the current score.
    LD B, LINES_D10-1
.linesLoop                                      ; Loop over score lines, starting from the bottom.

    ; ##########################################
    LD A, B                                     ; Set current score line
    CALL _LineToIX                              ; IX points to the score line compared to new users' game score.

    ; 32bit number is stored in RAM in little-endian: [DB1][DB0][DB3][DB2], but we compare 8bit values from new score and score line.
    ; Because of that, this is the processing order: [DB0][DB1][DB2][DB3].

    LD IY, sc.scoreHi
    ; Compare score byte: [THIS][DB][DB][DB]
    LD A, (IY+1)                                ; #sc.scoreHi:          [THIS][DB]
    LD D, (IX+1)                                ; #db2.highScore[line]: [THIS][DB][DB][DB]
    CP D
    JR Z, .byte1                                ; Bytes from the current line and the new score are equal -> check the next byte.
    JR NC, .nextScoreLine                       ; New score is > than value in current line -> go one line up.
    JR C, .break                                ; New score is < than value in current line -> break search.

.byte1
    ; Compare score byte: [DB][THIS][DB][DB]
    LD A, (IY)                                  ; #sc.scoreHi:          [DB][THIS]
    LD D, (IX)                                  ; #db2.highScore[line]: [DB][THIS][DB][DB]
    CP D
    JR Z, .byte2                                ; Bytes from the current line and the new score are equal -> check the next byte
    JR NC, .nextScoreLine                       ; New score is > than value in current line -> go one line up
    JR C, .break                                ; New score is < than value in current line -> break search

.byte2
     LD IY, sc.scoreLo
    ; Compare score byte: [DB][DB][THIS][DB]
    LD A, (IY+1)                                ; #sc.scoreLo:                  [THIS][DB]
    LD D, (IX+3)                                ; #db2.highScore[line]: [DB][DB][THIS][DB]
    CP D
    JR Z, .byte3                                ; Bytes from the current line and the new score are equal -> check the next byte.
    JR NC, .nextScoreLine                       ; New score is > than value in current line -> go one line up.
    JR C, .break                                ; New score is < than value in current line -> break search.

.byte3
    ; Compare score byte: [DB][DB][DB][THIS]
    LD A, (IY)                                  ; #sc.scoreLo:              [DB][THIS]
    LD D, (IX+2)                                ; #highScore[line]: [DB][DB][DB][THIS]
    CP D
    JR Z, .break                                ; 4 bytes from the new score and current line are equal -> take this line.
    JR NC, .nextScoreLine                       ; New score is > than value in current line -> go one line up.
    JR C, .break                                ; New score is < than value in current line -> break search.

    ; ##########################################
.nextScoreLine
    DJNZ .linesLoop

    ; ##########################################
    ; Update found the line, but it still could be out of the scoreboard (A > 9)!
.break
    LD A, B
    INC A
    LD (scoreLine), A

.end
    ENDM                                        ; ## END of the macro ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PUBLIC FUNCTIONS                       ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                      EnterNewScore                       ;
;----------------------------------------------------------;
EnterNewScore

    ; Music off
    CALL dbs.SetupMusicBank
    CALL aml.MusicOff

    XOR A                                       ; Enable user name input
    LD (nameChPos), A

    CALL _SetupMenuScore
    _CalculateScoreLine
    _StoreNewScore

    LD A, (scoreLine)
    CALL _PrintScoreLine

    ; ##########################################
    ; Music on
    CALL dbs.SetupMusicBank
    LD A, aml.MUSIC_HIGH_SCORE
    CALL aml.LoadSong
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      LoadMenuScore                       ;
;----------------------------------------------------------;
LoadMenuScore

    ; Music off
    CALL dbs.SetupMusicBank
    CALL aml.MusicOff

    ; Read only mode.
    LD A, NAME_CH_POS_OFF
    LD (nameChPos), A

    CALL _SetupMenuScore

    ; ##########################################
    ; Music on
    CALL dbs.SetupMusicBank
    CALL aml.MusicOn

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       AnimateCursor                      ;
;----------------------------------------------------------;
AnimateCursor

    LD A, (nameChPos)
    CP NAME_CH_POS_OFF
    RET Z

    LD IX, menuScoreCursor
    CALL sr.SetSpriteId
    CALL sr.UpdateSpritePattern

    RET                                         ; ## END of the function ##
    
;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                     _SetupMenuScore                      ;
;----------------------------------------------------------;
_SetupMenuScore

    ; ##########################################
    ; Setup joystick
    CALL ki.ResetKeyboard

    LD DE, _JoyFire
    LD (ki.callbackFire), DE

    ; Menu in read-only mode accepts only fire as input to exit the main menu.
    LD A, (nameChPos)
    CP NAME_CH_POS_OFF
    JR Z, .noJoystick

    LD DE, _JoyDown
    LD (ki.callbackDown), DE

    LD DE, _JoyUp
    LD (ki.callbackUp), DE

    LD DE, _JoyLeft
    LD (ki.callbackLeft), DE

    LD DE, _JoyRight
    LD (ki.callbackRight), DE
.noJoystick

    ; ###########################################
    LD A, ms.MENU_SCORE
    CALL ms.SetMainState

    CALL js.HideJetSprite
    CALL bm.HideImage
    CALL ti.CleanAllTiles

    ; ###########################################
    ; Load palette
    LD D, "0"
    LD A, (jt.difLevel)
    ADD A, '0'                                  ; Convert int to string character.
    LD E, A

    PUSH DE
    CALL fi.LoadMenuScorePalFile
    CALL bp.LoadDefaultPalette
    POP DE

    ; ###########################################
    ; Load background image
    CALL fi.LoadMenuScoreImageFile
    CALL bm.CopyImageData

    ; ###########################################
    _PrintWholeScore
    
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                         _JoyFire                         ;
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

    ; Return if cursor is at ENTER
    LD A, (nameChPos)
    CP NAME_CH_POS_ENTER
    RET NZ

    ; ##########################################
    ; User finished entering his name
    CALL _SetScoreToReadOnly

    ; FX
    CALL dbs.SetupAyFxsBank
    LD A, af.MENU_ENTER
    CALL af.AfxPlay

    ; ##########################################
    ; Music for main menu
    CALL dbs.SetupMusicBank
    LD A, aml.MUSIC_MAIN_MENU
    CALL aml.LoadSong

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                         _JoyDown                         ;
;----------------------------------------------------------;
_JoyDown

    ; Return if cursor is at ENTER
    LD A, (nameChPos)
    CP NAME_CH_POS_ENTER
    RET Z

    ; Previous character
    LD A, (tileChar)
    CP ASCII_A
    JR NZ, .prevChar
    ; We are at first letter, jump to last one: 0 -> Z.
    LD A, ASCII_Z
    JR .afterNextChar
.prevChar
    DEC A
.afterNextChar
    LD (tileChar), A

    CALL _StoreCurrentChar

    ; FX
    CALL dbs.SetupAyFxsBank
    LD A, af.FX_FIRE2
    CALL af.AfxPlay

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                          _JoyUp                          ;
;----------------------------------------------------------;
_JoyUp

    ; Return if cursor is at ENTER.
    LD A, (nameChPos)
    CP NAME_CH_POS_ENTER
    RET Z

    ; Next character
    LD A, (tileChar)
    CP ASCII_Z
    JR NZ, .nextChar
    ; We are at last letter, jump to first one: Z -> 0.
    LD A, ASCII_A
    JR .afterNextChar
.nextChar
    INC A
.afterNextChar
    LD (tileChar), A

    CALL _StoreCurrentChar

    ; FX
    CALL dbs.SetupAyFxsBank
    LD A, af.FX_FIRE1
    CALL af.AfxPlay

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        _JoyLeft                          ;
;----------------------------------------------------------;
_JoyLeft

    ; Update position.
    LD A, (nameChPos)
    CP NAME_CH_POS_MIN
    RET Z

    DEC A
    LD (nameChPos), A

    ; Reset character to first one.
    LD A, ASCII_A
    LD (tileChar), A

    ; FX
    CALL dbs.SetupAyFxsBank
    LD A, af.FX_MENU_MOVE
    CALL af.AfxPlay

    CALL _UpdateCursor

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        _JoyRight                         ;
;----------------------------------------------------------;
_JoyRight

    ; Update position
    LD A, (nameChPos)
    CP NAME_CH_POS_ENTER
    RET Z

    INC A
    LD (nameChPos), A

    ; Reset character to first one.
    LD A, ASCII_A
    LD (tileChar), A

    ; FX
    CALL dbs.SetupAyFxsBank
    LD A, af.FX_MENU_MOVE
    CALL af.AfxPlay

    CALL _UpdateCursor

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  _SetScoreToReadOnly                     ;
;----------------------------------------------------------;
_SetScoreToReadOnly

    ; Hide ENTER char
    CALL _SetDeToEnterTiRam

    ; Load tile and palette into tile ram.
    LD A, ti.TX_PALETTE_D0
    LD (DE), A
    INC DE
    
    LD A, ti.TI_EMPTY_D198
    LD (DE), A

    ; Set to read only
    LD A, NAME_CH_POS_OFF
    LD (nameChPos), A

    ; Disable name input
    CALL ki.ResetKeyboard

    LD DE, _JoyFire
    LD (ki.callbackFire), DE

    ; Hide cursor
    LD IX, menuScoreCursor
    CALL sr.HideSimpleSprite

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     _UpdateCursor                        ;
;----------------------------------------------------------;
_UpdateCursor

    CALL dbs.SetupStorageBank

    ; Calculate X postion
    LD DE, (nameChPos)
    ADD DE, LINE_INDICATION_TI_D10
    ADD DE, SCORE_TI_D10
    ADD DE, NAME_TI_SPACE_D3
    LD D, ti._TI_PIXELS_D8
    MUL D, E
    ADD DE, CURSOR_SPR_ADJ

    ; Add an extra character if the cursor is at ENTER.
    LD A, (nameChPos)
    CP NAME_CH_POS_ENTER
    JR NZ, .notEnter
    ADD DE, ENTER_SPACE_PX
.notEnter

    LD HL, DE                                   ; Store calculated X to HL

    ; ##########################################
    ; Calculate the Y position for the cursor.

    ; First calculate the amount of tiles taken by.
    LD A, (scoreLine)
    LD D, SCORE_H_LI_D3
    LD E, A
    MUL D, E                                    ; DE has been moved A lines.
    ADD DE, MARGIN_TOP_LI_D2                    ; Add top margin.

    ; E contains the number of lines from the top to the current score, D is 0.
    LD D, ti._TI_PIXELS_D8
    MUL D, E                                    ; E contains number of pixels from the top, D is 0.

    ; ##########################################
    ; Store X, Y position to sprite
    LD IX, menuScoreCursor
    LD (IX + SPR.X), HL
    LD (IX + SPR.Y), E

    ; ##########################################
    CALL sr.UpdateSpritePosition

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    _PrintScoreLine                       ;
;----------------------------------------------------------;
; Input:
;  A:  line from #db2.highScore to print as tilemap, 0 to 9 inklusive.
_PrintScoreLine

    CALL _LineToIX                              ; IX points to #db2.highScore that will be updated.

    ; ##########################################
    ; DE will point to the position when we print line given by A.
    LD D, SCORE_H_TI_D120
    LD E, A
    MUL D, E                                    ; DE has been moved A lines.
    ADD DE, MARGIN_TOP_TI_D80                   ; Add top margin.
    ADD DE, LINE_INDICATION_TI_D10              ; Add line indication.

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
    ; Move IX and DE from LO byte to text
    INC IX
    INC IX
    ADD DE, _16BIT_CHARS_D5                     ; DE points to text line with players name.

    LD BC, DE
    LD A, SCORE_TX_BYTES_D13
    LD DE, IX
    CALL ti.PrintText

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       _LineToIX                          ;
;----------------------------------------------------------;
; Input:
;  A: Score line in #db2.highScore, 0 (first entry in #db2.highScore) to 9 (bottom, lowest score) inklusive.
; Return:
;  IX: Points to score line.
_LineToIX

    LD IX, so.highScore                        ; Pointer to high score data.

    ; Each difficulty level has a dedicated score table, which starts with easy at #highScore. Each board takes #SCORE_BYTES_D150 bytes.
    ; Now we have to move to the line on the scoreboard labeled A, and also to the line within the scoreboard for the current difficulty.

    ; Calculate offset based on difficulty.
    PUSH AF
    LD A, (jt.difLevel)
    DEC A                                       ; The level has values 1-3; we need 0-2, so the first board does not have an offset.
    LD D, A
    LD E, SCORE_BYTES_D150
    MUL D, E
    LD HL, DE                                   ; HL contains an offset to the right scoreboard.
    POP AF
    
    LD E, LINE_BYTES_D15
    LD D, A
    MUL D, E
    ADD DE, HL
    ADD IX, DE

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   _SetDeToEnterTiRam                     ;
;----------------------------------------------------------;
; Return:
;  DE:  Points to the RAM position when enter-character should be printed. This is the end of the active score line.
_SetDeToEnterTiRam

    LD A, (scoreLine)
    LD E, A
    LD D, SCORE_H_TI_D120*2                     ; *2 because each tile has 2 bytes.
    MUL D, E                                    ; DE has been moved A lines.
    ADD DE, MARGIN_TOP_TI_D80*2                 ; Add top margin.
    ADD DE, ENTER_TI_POS*2                      ; Add enter offset within the line.
    ADD DE, ti.TI_MAP_RAM_H5B00 -1              ; Tiles start RAM.

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  #_StoreCurrentChar                      ;
;----------------------------------------------------------;
_StoreCurrentChar

    CALL dbs.SetupStorageBank

     ; DE will point to RAM containing the character the user currently enters.
    LD A, (scoreLine)
    CALL _LineToIX                              ; IX points to #db2.highScore that will be updated.
    LD DE, IX
    ADD DE, SCORE_TX_START_BYT_D7               ; Move DE to start of user name.
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