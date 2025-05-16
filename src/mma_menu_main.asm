;----------------------------------------------------------;
;                       Main Menu                          ;
;----------------------------------------------------------;
    MODULE mma

GAME_VERSION_OFFSET     = 40*30                 ; Version is in the last line.

EL_DIST                 = 40*4
TOP_OFS                 = 40*6
LOF                     = 7                     ; Menu entry offset from the left.

    STRUCT MENU
TILE_OFFSET             WORD                    ; Tile offset.
TEXT_POINT              WORD                    ; Text pointer.
TEXT_SIZE               BYTE                    ; Length of menu text.
JET_X                   BYTE                    ; X postion of Jetman pointing to active element.
JET_Y                   BYTE                    ; Y postion of Jetman pointing to active element.
    ENDS

menuPos                 BYTE MENU_EL_MIN
MENU_EL_START           = 1                     ; START GAME
MENU_EL_LSELECT         = 2                     ; LEVEL SELECT
MENU_EL_HSCORE          = 3                     ; HIGH SCORE
MENU_EL_SETTINGS        = 4                     ; SETTINGS
MENU_EL_MANUAL          = 5                     ; MANUAL
MENU_EL_DIFFICULTY      = 6                     ; DIFFICULTY

MENU_EL_MIN             = MENU_EL_START
MENU_EL_MAX             = MENU_EL_DIFFICULTY

;----------------------------------------------------------;
;                     #LoadMainMenu                        ;
;----------------------------------------------------------;
LoadMainMenu

    LD A, MENU_EL_MIN
    LD (menuPos), A

    ; ##########################################
    ; Update menu state.
    LD A, ms.MENU_MAIN
    CALL ms.SetMainState

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

    ; ##########################################
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
    AND %01110000                               ; Any of three fires pressed?
    JR NZ, .pressFire

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

    LD BC, (IX + MENU.TILE_OFFSET)
    LD DE, (IX + MENU.TEXT_POINT)
    LD A, (IX + MENU.TEXT_SIZE)
    CALL ti.PrintText

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

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       _JoyLeft                           ;
;----------------------------------------------------------;
_JoyLeft


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

    LD A, (menuPos)

    ; ##########################################
    ; Start game.
    CP MENU_EL_START
    JR NZ, .notStartGame
    CALL gc.StartGameWithIntro
    RET
.notStartGame

    ; ##########################################
    ; Show manual.
    CP MENU_EL_MANUAL
    JR NZ, .notShowManual
    CALL mmn.LoadManualMenu
    RET
.notShowManual

    ; ##########################################
    ; Wrong key hit, play sound
    LD A, af.FX_JET_KILL
    CALL af.AfxPlay

    RET                                         ; ## END of the function ##


;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE