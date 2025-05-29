;----------------------------------------------------------;
;                       Main Menu                          ;
;----------------------------------------------------------;
    MODULE mma

GAME_VERSION_OFFSET     = 40*30                 ; Version is in the last line

EL_DIST                 = 40*3
EL_SDIST                = 40*2
TOP_OFS                 = 40*5
LOF                     = 7                     ; Menu entry offset from the left

    STRUCT MENU
TILE_OFFSET             DW                      ; Tile offset
TEXT_POINT              DW                      ; Text pointer
TEXT_SIZE               DB                      ; Length of menu text
JET_X                   DB                      ; X postion of Jetman pointing to active element
JET_Y                   DB                      ; Y postion of Jetman pointing to active element
    ENDS

menuPos                 DB MENU_EL_MIN
MENU_EL_START           = 1                     ; START GAME
MENU_EL_LSELECT         = 2                     ; LEVEL SELECT
MENU_EL_SCORE           = 3                     ; HIGH SCORE
MENU_EL_KEYS            = 4                     ; IN GAME KEYS
MENU_EL_GAMEPLAY        = 5                     ; GAMEPLAY
MENU_EL_DIFFICULTY      = 6                     ; DIFFICULTY

MENU_EL_MIN             = MENU_EL_START
MENU_EL_MAX             = MENU_EL_DIFFICULTY

;----------------------------------------------------------;
;                      LoadMainMenu                        ;
;----------------------------------------------------------;
LoadMainMenu

    ; Update menu state
    LD A, ms.MENU_MAIN
    CALL ms.SetMainState

    ; ##########################################
    ; Setup joystick
    CALL mij.ResetJoystick

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

    ; ##########################################
    CALL _LoadMenuNormal

    ; ##########################################
    ; Load game version
    LD BC, GAME_VERSION_OFFSET
    LD DE, gameVersion
    LD A, GAME_VERSION_SIZE
    CALL ti.PrintText

    ; ##########################################
    ; Load sprites from any level
    LD D, "0"
    LD E, "1"
    CALL fi.LoadSprites

    ; ##########################################
    ; Setup Jetman sprite
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
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                      _LoadMenuEasy                       ;
;----------------------------------------------------------;
_LoadMenuEasy
 
    ; Hide current image
    CALL bm.HideImage

    ; ##########################################
    ; Load palette
    LD HL, db.menuEasyBgPaletteAdr
    LD A, (db.menuEasyBgPaletteBytes)
    LD B, A
    CALL bp.LoadPalette

    ; ##########################################
    ; Load background image
    CALL fi.LoadMenuEasyImage
    CALL bm.CopyImageData

    ; ##########################################
    LD A, jt.DIF_EASY
    LD (jt.difLevel), A

    ; ##########################################
    CALL dbs.SetupArraysBank
    LD IX, dba.menuDifEasy
    CALL _PrintMenu

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      _LoadMenuNormal                     ;
;----------------------------------------------------------;
_LoadMenuNormal

    ; Hide current image
    CALL bm.HideImage

    ; ##########################################
    ; Load palette
    LD HL, db.menuMainBgPaletteAdr
    LD A, (db.menuMainBgPaletteBytes)
    LD B, A
    CALL bp.LoadPalette

    ; ##########################################
    ; Load background image
    LD D, "m"
    LD E, "a"
    CALL fi.LoadBgImage
    CALL bm.CopyImageData

    ; ##########################################
    LD A, jt.DIF_NORMAL
    LD (jt.difLevel), A

    ; ##########################################
    CALL dbs.SetupArraysBank
    LD IX, dba.menuDifNorm
    CALL _PrintMenu

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      _LoadMenuHard                       ;
;----------------------------------------------------------;
_LoadMenuHard
 
    ; Hide current image
    CALL bm.HideImage

    ; ##########################################
    ; Load palette
    LD HL, db.menuHardBgPaletteAdr
    LD A, (db.menuHardBgPaletteBytes)
    LD B, A
    CALL bp.LoadPalette

    ; ##########################################
    ; Load background image
    CALL fi.LoadMenuHardImage
    CALL bm.CopyImageData

    ; ##########################################
    LD A, jt.DIF_HARD
    LD (jt.difLevel), A

    ; ##########################################
    CALL dbs.SetupArraysBank
    LD IX, dba.menuDifHard
    CALL _PrintMenu

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       _PrintMenu                         ;
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
;                   _SetIXToActiveMenu                     ;
;----------------------------------------------------------;
_SetIXToActiveMenu
    CALL dbs.SetupArraysBank

    ; Load into DE "current position" * "menu size"
    LD A, (menuPos)
    DEC A
    LD D, A
    LD E, MENU
    MUL D, E
    
    LD IX, dba.menuEl
    ADD IX, DE                                  ; Move IX to current menu position (IX + #menuPos * #MENU)

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   _UpdateSelection                       ;
;----------------------------------------------------------;
_UpdateSelection
    
    CALL _SetIXToActiveMenu
    CALL _UpdateJetPostion

    LD A, js.SDB_T_KO
    CALL js.ChangeJetSpritePattern

    LD A, af.FX_MENU_MOVE
    CALL dbs.SetupAyFxsBank
    CALL af.AfxPlay

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  _UpdateJetPostion                       ;
;----------------------------------------------------------;
; Input:
;  - IX: Pointer to currently selected #MENU
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
;                 _LoadStaticMenuText                      ;
;----------------------------------------------------------;
_LoadStaticMenuText

    CALL dbs.SetupArraysBank

    LD B, dba.MENU_EL_SIZE
    LD IX, dba.menuEl
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

    LD A, (menuPos)
    CP MENU_EL_DIFFICULTY
    CALL Z, _DifficultyUp

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       _JoyLeft                           ;
;----------------------------------------------------------;
_JoyLeft

    LD A, (menuPos)
    CP MENU_EL_DIFFICULTY
    CALL Z, _DifficultyDown

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                         _JoyUp                           ;
;----------------------------------------------------------;
_JoyUp

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

    LD A, (menuPos)

    ; ##########################################
    ; Start game
    CP MENU_EL_START
    JR NZ, .notStartGame
    CALL gc.StartGameWithIntro
    RET
.notStartGame

    ; ##########################################
    ; Show gameplay
    CP MENU_EL_GAMEPLAY
    JR NZ, .notShowGameplay
    CALL mmn.LoadMenuGameplay
    RET
.notShowGameplay

    ; ##########################################
    ; Show game keys
    CP MENU_EL_KEYS
    JR NZ, .notShowKeys
    CALL mmn.LoadMenuKeys
    RET
.notShowKeys

    ; ##########################################
    ; Difficulty up
    CP MENU_EL_DIFFICULTY
    JR NZ, .notDifficulty
    CALL _DifficultyUp
    RET
.notDifficulty

    ; ##########################################
    ; Show high score
    CP MENU_EL_SCORE
    JR NZ, .notShowScore
    CALL mms.LoadMenuScore
    RET
.notShowScore

    ; ##########################################
    ; Wrong key hit, play sound
    LD A, af.FX_JET_KILL
    CALL dbs.SetupAyFxsBank
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