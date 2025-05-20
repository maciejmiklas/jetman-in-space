;----------------------------------------------------------;
;                    Main Hight Score                      ;
;----------------------------------------------------------;
    MODULE mms

PLACES                  = 10
TILE_LINE_START         = 5
TILE_START              = 40*3 + TILE_LINE_START
SCORE_TEXT_SIZE         = 13
LINE_SPACE              = 40*2
LINE_FILL               = 40 - (TILE_LINE_START + 2*_16BIT_CHARS_D5 + SCORE_TEXT_SIZE)

;----------------------------------------------------------;
;                     #LoadMenuScore                       ;
;----------------------------------------------------------;
LoadMenuScore

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

    LD IX, db.menuScore                         ; Pointer to high score data.
    LD DE, TILE_START                           ; Tilemap position to print the first high score.

    LD B, PLACES
.placesLoop
    PUSH BC

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
    LD A, SCORE_TEXT_SIZE

    PUSH DE
    LD DE, IX
    CALL ti.PrintText
    POP DE

    ; Move IX to the high score line for the next player.
    LD BC, IX
    ADD BC, SCORE_TEXT_SIZE
    LD IX, BC

    ; Move DE after the text, than to the end of the line, and finally insert line breaks.
    ADD DE, SCORE_TEXT_SIZE + LINE_FILL + LINE_SPACE

    ; ##########################################
    ; Loop
    POP BC
    DJNZ .placesLoop
    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE