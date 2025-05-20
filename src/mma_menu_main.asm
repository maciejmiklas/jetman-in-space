;----------------------------------------------------------;
;                       Main Menu                          ;
;----------------------------------------------------------;
    MODULE mma

GAME_VERSION_OFFSET     = 40*30                 ; Version is in the last line.

EL_DIST                 = 40*3
EL_SDIST                = 40*2
TOP_OFS                 = 40*5
LOF                     = 7                     ; Menu entry offset from the left.

    STRUCT MENU
TILE_OFFSET             DW                      ; Tile offset.
TEXT_POINT              DW                      ; Text pointer.
TEXT_SIZE               DB                      ; Length of menu text.
JET_X                   DB                      ; X postion of Jetman pointing to active element.
JET_Y                   DB                      ; Y postion of Jetman pointing to active element.
    ENDS

menuPos                 DB MENU_EL_MIN
MENU_EL_START           = 1                     ; START GAME
MENU_EL_LSELECT         = 2                     ; LEVEL SELECT
MENU_EL_SCORE           = 3                     ; HIGH SCORE
MENU_EL_SETTINGS        = 4                     ; SETTINGS
MENU_EL_KEYS            = 5                     ; IN GAME KEYS
MENU_EL_GAMEPLAY        = 6                     ; GAMEPLAY
MENU_EL_DIFFICULTY      = 7                     ; DIFFICULTY

MENU_EL_MIN             = MENU_EL_START
MENU_EL_MAX             = MENU_EL_DIFFICULTY

;----------------------------------------------------------;
;                     #LoadMainMenu                        ;
;----------------------------------------------------------;
LoadMainMenu

    ; Update menu state.
    LD A, ms.MENU_MAIN
    CALL ms.SetMainState

    ; ##########################################
    CALL _LoadMenuNormal

    ; ##########################################
    ; Load game version.
    LD BC, GAME_VERSION_OFFSET
    LD DE, gameVersion
    LD A, GAME_VERSION_SIZE
    CALL ti.PrintText

    ; ##########################################
    ; Load sprites from any level.
    LD D, "0"
    LD E, "1"
    CALL fi.LoadSprites

    ; ##########################################
    ; Setup Jetman sprite.
    CALL jt.SetJetStateInactive

    ; Jetman is facing left
    XOR A
    SET gid.MOVE_LEFT_BIT, A
    LD (gid.jetDirection), A

    LD A, js.SDB_HOVER
    CALL js.ChangeJetSpritePattern

    CALL js.ShowJetSprite

    ; ##########################################
    CALL _LoadStaticMenuText
    CALL _SetIXToActiveMenu
    CALL _UpdateJetPostion

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     #MenuMainUserInput                   ;
;----------------------------------------------------------;
MenuMainUserInput

    ; Key right pressed ?
    LD A, _KB_6_TO_0_HEF
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A.
    BIT 2, A                                    ; Bit 2 reset -> right pressed.
    JR Z, .pressRight

    ; ##########################################
    ; Key up pressed ?
    BIT 3, A                                    ; Bit 3 reset -> Up pressed.
    JR Z, .pressUp
    
    ; ##########################################
    ; Key down pressed ?
    BIT 4, A                                    ; Bit 4 reset -> Down pressed.
    JR Z, .pressDown

    ; ##########################################
    ; Joystick right pressed ?
    LD A, _JOY_MASK_H20                         ; Activate joystick register.
    IN A, (_JOY_REG_H1F)                        ; Read joystick input into A.
    BIT 0, A                                    ; Bit 0 set -> Right pressed.
    JR NZ, .pressRight

    ; ##########################################
    ; Joystick left pressed ?
    BIT 1, A                                    ; Bit 1 set -> Left pressed.
    JR NZ, .pressLeft

    ; ##########################################
    ; Joystick down pressed ?
    BIT 2, A                                    ; Bit 2 set -> Down pressed.
    JR NZ, .pressDown

    ; ##########################################
    ; Joystick fire pressed ?
    PUSH AF
    AND %01110000                               ; Any of three fires pressed?
    JR NZ, .pressFire
    POP AF
    
    ; ##########################################
    ; Joystick up pressed ?
    BIT 3, A                                    ; Bit 3 set -> Up pressed.
    JR NZ, .pressUp

    ; ##########################################
    ; Key Fire (Z) pressed ?
    LD A, _KB_V_TO_SH_HFE
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A.
    BIT 1, A                                    ; Bit 1 reset -> Z pressed.
    JR Z, .pressFire

    ; ##########################################
    ; Key SPACE pressed ?
    LD A, _KB_B_TO_SPC_H7F
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A.
    BIT 0, A                                    ; Bit 0 reset -> SPACE pressed.
    JR Z, .pressFire

    ; ##########################################
    ; Key ENTER pressed ?
    LD A, _KB_H_TO_ENT_HBF
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A.
    BIT 0, A                                    ; Bit 0 reset -> SPACE pressed.
    JR Z, .pressFire
    
    ; ##########################################
    ; Key Left pressed ?
    LD A, _KB_5_TO_1_HF7
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A.
    BIT 4, A                                    ; Bit 4 reset -> Left pressed.
    JR Z, .pressLeft

    RET                                         ; None of the keys pressed.

.pressRight
    CALL _JoyRight
    RET

.pressLeft
    CALL _JoyLeft
    RET

.pressUp
    CALL _JoyUp
    RET

.pressDown
    CALL _JoyDown
    RET

.pressFire
    CALL _JoyFire
    RET

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                     #_LoadMenuEasy                       ;
;----------------------------------------------------------;
_LoadMenuEasy
 
    ; Hide current image.
    CALL bm.HideImage

    ; ##########################################
    ; Load palette.
    LD HL, db.menuEasyBgPaletteAdr
    LD A, (db.menuEasyBgPaletteBytes)
    LD B, A
    CALL bp.LoadPalette

    ; ##########################################
    ; Load background image.
    CALL fi.LoadMenuEasyImage
    CALL bm.CopyImageData

    ; ##########################################
    LD A, jt.DIF_EASY
    LD (jt.difLevel), A

    CALL gc.SetDifficultyToEasy

    ; ##########################################
    CALL dbs.SetupArraysBank
    LD IX, db.menuDifEasy
    CALL _PrintMenu

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     #_LoadMenuNormal                     ;
;----------------------------------------------------------;
_LoadMenuNormal

    ; Hide current image.
    CALL bm.HideImage

    ; ##########################################
    ; Load palette.
    LD HL, db.menuMainBgPaletteAdr
    LD A, (db.menuMainBgPaletteBytes)
    LD B, A
    CALL bp.LoadPalette

    ; ##########################################
    ; Load background image.
    CALL fi.LoadMenuMainImage
    CALL bm.CopyImageData

    ; ##########################################
    LD A, jt.DIF_NORMAL
    LD (jt.difLevel), A

    CALL gc.SetDifficultyToNormal

    ; ##########################################
    CALL dbs.SetupArraysBank
    LD IX, db.menuDifNorm
    CALL _PrintMenu

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     #_LoadMenuHard                       ;
;----------------------------------------------------------;
_LoadMenuHard
 
    ; Hide current image.
    CALL bm.HideImage

    ; ##########################################
    ; Load palette.
    LD HL, db.menuHardBgPaletteAdr
    LD A, (db.menuHardBgPaletteBytes)
    LD B, A
    CALL bp.LoadPalette

    ; ##########################################
    ; Load background image.
    CALL fi.LoadMenuHardImage
    CALL bm.CopyImageData

    ; ##########################################
    LD A, jt.DIF_HARD
    LD (jt.difLevel), A

    CALL gc.SetDifficultyToHard

    ; ##########################################
    CALL dbs.SetupArraysBank
    LD IX, db.menuDifHard
    CALL _PrintMenu

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      #_PrintMenu                         ;
;----------------------------------------------------------;
; Input:
;  - IX: Pointer to #MENU
_PrintMenu

    LD BC, (IX + MENU.TILE_OFFSET)
    LD DE, (IX + MENU.TEXT_POINT)
    LD A, (IX + MENU.TEXT_SIZE)
    CALL ti.PrintText

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  #_SetIXToActiveMenu                     ;
;----------------------------------------------------------;
_SetIXToActiveMenu
    CALL dbs.SetupArraysBank

    ; Load into DE "current position" * "menu size" 
    LD A, (menuPos)
    DEC A
    LD D, A
    LD E, MENU
    MUL D, E
    
    LD IX, db.menuEl
    ADD IX, DE                                  ; Move IX to current menu position (IX + #menuPos * #MENU)

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  #_UpdateSelection                       ;
;----------------------------------------------------------;
_UpdateSelection
    
    CALL _SetIXToActiveMenu
    CALL _UpdateJetPostion

    LD A, js.SDB_T_KO
    CALL js.ChangeJetSpritePattern

    LD A, af.FX_MENU_MOVE
    CALL af.AfxPlay

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 #_UpdateJetPostion                       ;
;----------------------------------------------------------;
; Input:
;  - IX: Pointer to currently selected #MENU.
_UpdateJetPostion

    ; Set X Jet position.
    LD D, 0
    LD E, (IX + MENU.JET_X)
    LD (jpo.jetX), DE
 
    ; Set Y Jet position.
    LD A, (IX + MENU.JET_Y)
    LD (jpo.jetY), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                #_LoadStaticMenuText                      ;
;----------------------------------------------------------;
_LoadStaticMenuText

    CALL dbs.SetupArraysBank

    LD B, db.MENU_EL_SIZE
    LD IX, db.menuEl
.elementLoop
    PUSH BC

    CALL _PrintMenu

    ; Move IX to next #MENU
    LD DE, IX
    ADD DE, MENU
    LD IX, DE

    POP BC
    DJNZ .elementLoop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       _JoyRight                          ;
;----------------------------------------------------------;
_JoyRight

    CALL ui.CanProcessKeyboardInput
    CP _RET_YES_D1
    RET NZ

    LD A, (menuPos)
    CP MENU_EL_DIFFICULTY
    CALL Z, _DifficultyUp

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       _JoyLeft                           ;
;----------------------------------------------------------;
_JoyLeft

    CALL ui.CanProcessKeyboardInput
    CP _RET_YES_D1
    RET NZ

    LD A, (menuPos)
    CP MENU_EL_DIFFICULTY
    CALL Z, _DifficultyDown

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                         _JoyUp                           ;
;----------------------------------------------------------;
_JoyUp

    CALL ui.CanProcessKeyboardInput
    CP _RET_YES_D1
    RET NZ
    
    ; ##########################################
    ; Decrement #menuPos
    LD A, (menuPos)
    DEC A
    CP MENU_EL_MIN-1
    JR NZ, .afterActiveReset
    LD A, MENU_EL_MAX
.afterActiveReset
    LD (menuPos), A

    ; ##########################################
    CALL _UpdateSelection

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        _JoyDown                          ;
;----------------------------------------------------------;
_JoyDown

    CALL ui.CanProcessKeyboardInput
    CP _RET_YES_D1
    RET NZ

    ; ##########################################
    ; Increment #menuPos
    LD A, (menuPos)
    INC A
    CP MENU_EL_MAX+1
    JR NZ, .afterActiveReset
    LD A, MENU_EL_MIN
.afterActiveReset
    LD (menuPos), A

    ; ##########################################
    CALL _UpdateSelection

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        _JoyFire                          ;
;----------------------------------------------------------;
_JoyFire

    CALL ui.CanProcessKeyboardInput
    CP _RET_YES_D1
    RET NZ

    LD A, (menuPos)

    ; ##########################################
    ; Start game.
    CP MENU_EL_START
    JR NZ, .notStartGame
    CALL gc.StartGameWithIntro
    RET
.notStartGame

    ; ##########################################
    ; Show gameplay.
    CP MENU_EL_GAMEPLAY
    JR NZ, .notShowGameplay
    CALL mmn.LoadMenuGameplay
    RET
.notShowGameplay

    ; ##########################################
    ; Show game keys.
    CP MENU_EL_KEYS
    JR NZ, .notShowKeys
    CALL mmn.LoadMenuKeys
    RET
.notShowKeys

    ; ##########################################
    ; Difficulty up.
    CP MENU_EL_DIFFICULTY
    JR NZ, .notDifficulty
    CALL _DifficultyUp
    RET
.notDifficulty

    ; ##########################################
    ; Show gameplay.
    CP MENU_EL_SCORE
    JR NZ, .notShowScore
    ;CALL mms.LoadMenuScore
    CALL mms.EnterNewScore
    RET
.notShowScore


    ; ##########################################
    ; Wrong key hit, play sound
    LD A, af.FX_JET_KILL
    CALL af.AfxPlay

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     _DifficultyUp                        ;
;----------------------------------------------------------;
_DifficultyUp

    LD A, (jt.difLevel)
    CP jt.DIF_HARD
    JR Z, .overflow
    INC A
    LD (jt.difLevel), A
    CALL _SetupDifficulty
    RET
.overflow
    LD A, jt.DIF_EASY
    LD (jt.difLevel), A
    CALL _SetupDifficulty

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    _DifficultyDown                       ;
;----------------------------------------------------------;
_DifficultyDown

    LD A, (jt.difLevel)
    CP jt.DIF_EASY
    JR Z, .overflow
    DEC A
    LD (jt.difLevel), A
    CALL _SetupDifficulty
    RET
.overflow
    LD A, jt.DIF_HARD
    LD (jt.difLevel), A
    CALL _SetupDifficulty

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   _SetupDifficulty                       ;
;----------------------------------------------------------;
_SetupDifficulty

    LD A, js.SDB_T_KO
    CALL js.ChangeJetSpritePattern

    LD A, (jt.difLevel)
    CP jt.DIF_EASY
    JR NZ, .notEasy
    CALL _LoadMenuEasy
    RET
.notEasy

    LD A, (jt.difLevel)
    CP jt.DIF_NORMAL
    JR NZ, .notNormal
    CALL _LoadMenuNormal
    RET
.notNormal

    LD A, (jt.difLevel)
    CP jt.DIF_HARD
    JR NZ, .notHard
    CALL _LoadMenuHard
    RET
.notHard

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE