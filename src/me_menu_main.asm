;----------------------------------------------------------;
;                   Lobby Main Menu                        ;
;----------------------------------------------------------;
    MODULE me

GAME_VERSION_OFFSET     = 40*30                 ; Version is in the last line.

EL_DIST                 = 40*4
TOP_OFS                 = 40*6


    STRUCT MENU
TEXT_SIZE               BYTE                    ; Length of menu text.
TILE_OFFSET             WORD                    ; Tile offset.
TEXT_POINT              WORD                    ; Text pointer.
JET_X                   BYTE                    ; X postion of Jetman pointing to active element.
JET_Y                   BYTE                    ; Y postion of Jetman pointing to active element.
    ENDS

menuEl
    MENU {10/*TEXT_SIZE*/, TOP_OFS+15              /*TILE_OFFSET*/, menuTextSg/*TEXT_POINT*/, 100/*JET_X*/, 100/*JET_Y*/}  ; START GAME
    MENU {12/*TEXT_SIZE*/, TOP_OFS+(1*EL_DIST)+14  /*TILE_OFFSET*/, menuTextLs/*TEXT_POINT*/, 100/*JET_X*/, 100/*JET_Y*/}  ; LEVEL SELECT
    MENU {10/*TEXT_SIZE*/, TOP_OFS+(2*EL_DIST)+15  /*TILE_OFFSET*/, menuTextHs/*TEXT_POINT*/, 100/*JET_X*/, 100/*JET_Y*/}  ; HIGH SCORE
    MENU {08/*TEXT_SIZE*/, TOP_OFS+(3*EL_DIST)+16  /*TILE_OFFSET*/, menuTextSe/*TEXT_POINT*/, 100/*JET_X*/, 100/*JET_Y*/}  ; SETTINGS
    MENU {10/*TEXT_SIZE*/, TOP_OFS+(4*EL_DIST)+15  /*TILE_OFFSET*/, menuTextDi/*TEXT_POINT*/, 100/*JET_X*/, 100/*JET_Y*/}  ; DIFFICULTY
MENU_EL_SIZE            = 5

menuTextSg DB "START GAME"
menuTextLs DB "LEVEL SELECT"
menuTextHs DB "HIGH SCORE"
menuTextSe DB "SETTINGS"
menuTextDi DB "DIFFICULTY"

menuPos                 BYTE MENU_EL_MIN
MENU_EL_START           = 1
MENU_EL_LEV_SEL         = 2
MENU_EL_HS              = 3
MENU_EL_SET             = 4
MENU_EL_DIF             = 5

MENU_EL_MIN             = MENU_EL_START
MENU_EL_MAX             = MENU_EL_DIF

;----------------------------------------------------------;
;                     #LoadMainMenu                        ;
;----------------------------------------------------------;
LoadMainMenu

    LD A, ms.MAIN_MENU
    CALL ms.SetMainState

    ; ##########################################
    ; Load palette.
    LD HL, db.mainMenuBgPaletteAdr
    LD A, (db.mainMenuBbPaletteBytes)
    LD B, A
    CALL bp.LoadPalette

    ; ##########################################
    ; Load background image.
    CALL fi.LoadMainMenuImage
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
    CALL _LoadStaticMenuText

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     #MainMenuUserInput                   ;
;----------------------------------------------------------;
MainMenuUserInput

    ; ##########################################
    ; Key right pressed ?
    LD A, _KB_6_TO_0_HEF
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A.
    PUSH AF                                     ; Keep A on the stack to avoid rereading the same input.
    BIT 2, A                                    ; Bit 2 reset -> right pressed.
    CALL Z, _JoyRight
    POP AF

    ; ##########################################
    ; Key up pressed ?
    PUSH AF
    BIT 3, A                                    ; Bit 3 reset -> Up pressed.
    CALL Z, _JoyUp
    POP AF
    
    ; ##########################################
    ; Key down pressed ?
    BIT 4, A                                    ; Bit 4 reset -> Down pressed.
    CALL Z, _JoyDown

    ; ##########################################
    ; Joystick right pressed ?
    LD A, _JOY_MASK_H20                         ; Activate joystick register.
    IN A, (_JOY_REG_H1F)                        ; Read joystick input into A.
    PUSH AF                                     ; Keep A on the stack to avoid rereading the same input.
    BIT 0, A                                    ; Bit 0 set -> Right pressed.
    CALL NZ, _JoyRight  
    POP AF

    ; ##########################################
    ; Joystick left pressed ?
    PUSH AF
    BIT 1, A                                    ; Bit 1 set -> Left pressed.
    CALL NZ, _JoyLeft
    POP AF

    ; ##########################################
    ; Joystick down pressed ?
    PUSH AF
    BIT 2, A                                    ; Bit 2 set -> Down pressed.
    CALL NZ, _JoyDown
    POP AF

    ; ##########################################
    ; Joystick fire pressed ?
    PUSH AF
    AND %01110000                               ; Any of three fires pressed?
    CALL NZ, _JoyFire   
    POP AF

    ; ##########################################
    ; Joystick up pressed ?
    BIT 3, A                                    ; Bit 3 set -> Up pressed.
    CALL NZ, _JoyUp

    ; ##########################################
    ; Key Fire (Z) pressed ?
    LD A, _KB_V_TO_SH_HFE
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A.
    BIT 1, A                                    ; Bit 1 reset -> Z pressed.
    CALL Z, _JoyFire

    ; ##########################################
    ; Key SPACE pressed ?
    LD A, _KB_B_TO_SPC_H7F
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A.
    BIT 0, A                                    ; Bit 0 reset -> SPACE pressed.
    CALL Z, _JoyFire

    ; ##########################################
    ; Key ENTER pressed ?
    LD A, _KB_H_TO_ENT_HBF
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A.
    BIT 0, A                                    ; Bit 0 reset -> SPACE pressed.
    CALL Z, _JoyFire        
    
    ; ##########################################
    ; Key Left pressed ?
    LD A, _KB_5_TO_1_HF7
    IN A, (_KB_REG_HFE)                         ; Read keyboard input into A.
    BIT 4, A                                    ; Bit 4 reset -> Left pressed.
    CALL Z, _JoyLeft    

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                #_LoadStaticMenuText                      ;
;----------------------------------------------------------;
_LoadStaticMenuText

    LD B, MENU_EL_SIZE
    LD IX, menuEl
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
;                        _JoyRight                         ;
;----------------------------------------------------------;
_JoyRight

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       _JoyLeft                           ;
;----------------------------------------------------------;
_JoyLeft


    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                          _JoyUp                          ;
;----------------------------------------------------------;
_JoyUp

    CALL ut.CanProcessKeyboardInput
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

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        _JoyDown                          ;
;----------------------------------------------------------;
_JoyDown

    CALL ut.CanProcessKeyboardInput
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

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        _JoyFire                          ;
;----------------------------------------------------------;
_JoyFire

    CALL _ExitMenu

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       _ExitMenu                          ;
;----------------------------------------------------------;
_ExitMenu

    CALL gc.LoadLevel1Intro

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE