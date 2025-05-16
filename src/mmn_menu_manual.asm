;----------------------------------------------------------;
;                     Game Manual                          ;
;----------------------------------------------------------;
; Manual handles two menus: MENU_EL_KEYS (IN GAME KEYS) and MENU_EL_GAMEPLAY (GAMEPLAY)
    MODULE mmn

;----------------------------------------------------------;
;                    #LoadMenuGameplay                     ;
;----------------------------------------------------------;
LoadMenuGameplay

    CALL _PreLoadMenu

    ; Load tiles with manual.
    CALL fi.LoadMenuGameplayTilemap
    
    ; Load palette.
    LD HL, db.menuGameplayBgPaletteAdr
    LD A, (db.menuGameplayBgPaletteBytes)
    LD B, A
    CALL bp.LoadPalette

    ; Load background image.
    CALL fi.LoadMenuGameplayImage
    CALL bm.CopyImageData

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     #LoadMenuKeys                        ;
;----------------------------------------------------------;
LoadMenuKeys

    CALL _PreLoadMenu

    ; Load tiles with manual.
    CALL fi.LoadMenuKeysTilemap

    ; Load palette.
    LD HL, db.menuKeysBgPaletteAdr
    LD A, (db.menuKeysBgPaletteBytes)
    LD B, A
    CALL bp.LoadPalette

    ; Load background image.
    CALL fi.LoadMenuKeysImage
    CALL bm.CopyImageData

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   #MenuManualUserInput                   ;
;----------------------------------------------------------;
MenuManualUserInput

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
;                      #_PreLoadMenu                       ;
;----------------------------------------------------------;
_PreLoadMenu

    LD A, ms.MENU_MANUAL
    CALL ms.SetMainState

    CALL js.HideJetSprite
    CALL ti.CleanAllTiles
    CALL bm.HideImage
    RET                                         ; ## END of the function ##
    
;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE