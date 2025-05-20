;----------------------------------------------------------;
;                      Jetman Sprite                       ;
;----------------------------------------------------------;
    MODULE js

SPR_ID_JET_UP           = 0                     ; ID of Jetman upper sprite.
SPR_ID_JET_LW           = 1                     ; ID of Jetman lower sprite.

; IDs for #jetSpriteDB.
SDB_FLY                 = 201                   ; Jetman is flaying.
SDB_FLYD                = 202                   ; Jetman is flaying down.
SDB_WALK                = 203                   ; Jetman is walking.
SDB_WALK_ST             = 204                   ; Jetman starts walking with raised feet to avoid moving over the ground and standing still.
SDB_HOVER               = 205                   ; Jetman hovers.
SDB_STAND               = 206                   ; Jetman stands in place.
SDB_JSTAND              = 207                   ; Jetman quickly stops walking.
SDB_RIP                 = 208                   ; Jetman got hit.

SDB_T_WF                = 220                   ; Transition: walking -> flaying.
SDB_T_FS                = 221                   ; Transition: flaying -> standing.
SDB_T_FW                = 222                   ; Transition: flaying -> walking.
SDB_T_KF                = 223                   ; Transition: kinking -> flying.
SDB_T_KO                = 224                   ; Transition: kinking -> hovering.

SDB_SUB                 = 100                   ; 100 for OFF_NX that CPIR finds ID and not OFF_NX (see record doc below, look for: OFF_NX).
SDB_FRAME_SIZE          = 2

sprDBIdx                DW 0                    ; Current position in DB.
sprDBRemain             DB 0                    ; Amount of bytes that have to be still processed from the current record.
sprDBCurrentID          DB SDB_STAND            ; Active animation.
sprDBNextID             DB SDB_STAND            ; ID in #jetSpriteDB for next animation/DB record.
sprDBDelay              DB 0                    ; Value from #DELAY.
sprDBDelayCnt           DB 0                    ; Counter from #sprDBDelay to 0.

SPR_STATE_HIDE          = 0
SPR_STATE_SHOW          = 1
sprState                DB SPR_STATE_SHOW

;----------------------------------------------------------;
;             #UpdateJetSpritePositionRotation             ;
;----------------------------------------------------------;
UpdateJetSpritePositionRotation

    CALL dbs.SetupArraysBank

    ; Move Jetman Sprite to the current X position, the 9-bit value requires two writes (8 bit from C + 1 bit from B).
    LD BC, (jpo.jetX)

    ; Set _SPR_REG_NR_H34 with LDB from Jetman's X postion.
    LD A, C         
    NEXTREG _SPR_REG_NR_H34, SPR_ID_JET_UP      ; Set the ID of the Jetman's sprite for the following commands.
    NEXTREG _SPR_REG_X_H35, A                   ; Set LSB from BC (X).

    NEXTREG _SPR_REG_NR_H34, SPR_ID_JET_LW      ; Set the ID of the Jetman's sprite for the following commands.
    NEXTREG _SPR_REG_X_H35, A                   ; Set LSB from BC (X).

    ; Set _SPR_REG_ATR2_H37 containing overflow bit from X position, rotation and mirror.
    LD A, (gid.jetDirection)
    LD D, A
    XOR A                                       ; Clear A to set only rotation/mirror bits.
    BIT gid.MOVE_LEFT_BIT, D                    ; Moving left bit set?
    JR Z, .rotateRight
    SET _SPR_REG_ATR2_MIRX_BIT, A               ; Rotate sprite left.
    JR .afterRotate 
.rotateRight    
    RES _SPR_REG_ATR2_MIRX_BIT, A               ; Rotate sprite right.
.afterRotate
    LD E, A                                     ; Backup A.

    LD A, B                                     ; Load MSB from X into A.
    AND %00000001                               ; Keep only an overflow bit.
    OR E                                        ; Apply rotation from A (E now).

    NEXTREG _SPR_REG_NR_H34, SPR_ID_JET_UP      ; Set the ID of the Jetman's sprite for the following commands.
    NEXTREG _SPR_REG_ATR2_H37, A

    NEXTREG _SPR_REG_NR_H34, SPR_ID_JET_LW      ; Set the ID of the Jetman's sprite for the following commands.
    NEXTREG _SPR_REG_ATR2_H37, A

    ; Move Jetman sprite to current Y postion, 8-bit value is simple.
    LD A, (jpo.jetY)

    NEXTREG _SPR_REG_NR_H34, SPR_ID_JET_UP      ; Set the ID of the Jetman's sprite for the following commands.
    NEXTREG _SPR_REG_Y_H36, A                   ; Set Y position.

    NEXTREG _SPR_REG_NR_H34, SPR_ID_JET_LW      ; Set the ID of the Jetman's sprite for the following commands.
    ADD 16                                      ; Lower part is 16px below upper.
    NEXTREG _SPR_REG_Y_H36, A                   ; Set Y position.

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                #ChangeJetSpritePattern                   ;
;----------------------------------------------------------;
; Switches immediately to the given animation, breaking the currently running one.
; Input:
;   - A: ID for #jesSprites, to switch to the next animation record.
ChangeJetSpritePattern

    ; Do not change the animation if the same animation is already playing, it will restart it.
    LD B, A
    LD A, (sprDBCurrentID)
    CP B
    RET Z

    LD A, B                                     ; Restore method param.

    LD (sprDBNextID), A                         ; Next animation record.
    LD (sprDBCurrentID), A

    XOR A                                       ; Set A to 0.
    LD (sprDBRemain), A                         ; No more bytes to process within the current DB record will cause the fast switch to the next.

    CALL AnimateJetSprite                       ; Update the next animation frame immediately.

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  #AnimateJetSprite                       ;
;----------------------------------------------------------;
; Update sprite pattern for the next animation frame.
AnimateJetSprite
    
    CALL dbs.SetupArraysBank

    ; Delay animation.
    LD A, (sprDBDelay)
    CP 0
    JR Z, .afterAnimationDelay                  ; Jump if delay is off
    
    ; Animation delay is on. Check if counter has reached 0 and needs to be reset.
    LD A, (sprDBDelayCnt)
    CP 0
    JR NZ, .decResetDelay
    
    ; Delay counter is 0, reset it.
    LD A, (sprDBDelay)
    LD (sprDBDelayCnt), A
    JR .afterAnimationDelay
.decResetDelay
    DEC A
    LD (sprDBDelayCnt), A

    RET 
.afterAnimationDelay
    ; ##########################################
    ; Switch to the next DB record if all bytes from the current one have been used.
    LD A, (sprDBRemain)
    CP 0
    JR NZ, .afterRecordChange                   ; Jump if there are still bytes to be processed.
    
    ; Load new record.
    LD HL, db.jetSpriteDB                           ; HL points to the beginning of the DB.
    LD A, (sprDBNextID)                         ; CPIR will keep increasing HL until it finds the record ID from A.
    LD (sprDBCurrentID), A                      ; Store current animation.
    LD BC, 0                                    ; Do not limit CPIR search.
    CPIR

    ; Now we are at the correct DB position containing the following sprite pattern and will load it into the registry.
    LD A, (HL)                                  ; Update next pointer to next animation record.
    ADD SDB_SUB                                 ; Add 100 because DB value had  -100, to avoid collision with ID.
    LD (sprDBNextID), A 

    INC HL                                      ; HL points to [SIZE].
    LD A, (HL)                                  ; Update SIZE.
    LD (sprDBRemain), A

    INC HL                                      ; HL points to [DELAY].
    LD A, (HL)
    LD (sprDBDelay), A
    LD (sprDBDelayCnt), A

    INC HL                                      ; HL points to first sprite data (upper/lower parts).
    LD (sprDBIdx), HL                           ; Database offset points to be bytes containing sprite offsets from sprite file.
.afterRecordChange

    ; 2 bytes will be consumed from current DB record -> upper and lower sprite for Jetman.
    LD A, (sprDBRemain)
    ADD -SDB_FRAME_SIZE
    LD (sprDBRemain), A

    ; Now we are at correct DB position containing next sprite pattern and will load it into registry.
    LD HL, (sprDBIdx)

    ; Store in B _SPR_PATTERN_SHOW/_HIDE depending on the #sprState.
    LD A, (sprState)
    CP SPR_STATE_HIDE
    JR Z, .hide
    LD B, _SPR_PATTERN_SHOW                     ; Sprite is visible.
    JR .afterShow
.hide
    LD B, _SPR_PATTERN_HIDE                     ; Sprite is hidden.
.afterShow  

    ; Update upper sprite.
    NEXTREG _SPR_REG_NR_H34, SPR_ID_JET_UP      ; Set the ID of the Jetman's sprite for the following commands.
    LD A, (HL)                                  ; Store pattern number into sprite attribute.
    OR B                                        ; Store visibility sprite attribute.
    NEXTREG _SPR_REG_ATR3_H38, A    

    ; Update lower sprite.
    NEXTREG _SPR_REG_NR_H34, SPR_ID_JET_LW      ; Set the ID of the Jetman's sprite for the following commands.
    INC HL
    LD A, (HL)                                  ; Store pattern number into sprite attribute.
    OR B                                        ; Store visibility sprite attribute.
    NEXTREG _SPR_REG_ATR3_H38, A    

    ; Update pointer to DB.
    INC HL
    LD (sprDBIdx), HL

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    #BlinkJetSprite                       ;
;----------------------------------------------------------;
; Input:
; - A:  Flip Flop counter, ie: #counter002FliFLop.
BlinkJetSprite

    CALL dbs.SetupArraysBank

    CP _GC_FLIP_ON_D1
    JR NZ, .flipOff
    
    ; Show sprite
    CALL HideJetSprite
    RET
.flipOff
    ; Hide sprite
    CALL ShowJetSprite

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     #ShowJetSprite                       ;
;----------------------------------------------------------;
ShowJetSprite

    LD A, SPR_STATE_SHOW
    LD (sprState), A

    LD B, _SPR_PATTERN_SHOW
    CALL _ShowOrHideJetSprite

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     #HideJetSprite                       ;
;----------------------------------------------------------;
HideJetSprite

    LD A, SPR_STATE_HIDE
    LD (sprState), A

    LD B, _SPR_PATTERN_HIDE
    CALL _ShowOrHideJetSprite

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                #ChangeJetSpriteOnFlyDown                 ;
;----------------------------------------------------------;
ChangeJetSpriteOnFlyDown

    ; Change animation only if Jetman is flying.
    LD A, (jt.jetAir)
    CP jt.AIR_FLY
    RET NZ

    ; Switch to flaying down animation.
    LD A, SDB_FLYD
    CALL ChangeJetSpritePattern

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;               #ChangeJetSpriteOnFlyUp                    ;
;----------------------------------------------------------;
ChangeJetSpriteOnFlyUp

    ; Change animation only if Jetman is flying.
    LD A, (jt.jetAir)
    CP jt.AIR_FLY
    RET NZ

    ; Switch to flaying animation.
    LD A, SDB_FLY
    CALL ChangeJetSpritePattern
    RET                                         ; ## END of the function ## 

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                 #_ShowOrHideJetSprite                    ;
;----------------------------------------------------------;
; Input:
;  - B: _SPR_PATTERN_SHOW or _SPR_PATTERN_HIDE.
_ShowOrHideJetSprite
    CALL dbs.SetupArraysBank
    
    LD HL, (sprDBIdx)                           ; Load current sprite pattern.
    ADD HL, -SDB_FRAME_SIZE                     ; Every update sprite pattern moves db pointer to the next record, but blinking has to show current record.

    ; Update upper sprite
    NEXTREG _SPR_REG_NR_H34, SPR_ID_JET_UP      ; Set the ID of the Jetman's sprite for the following commands.
    LD A, (HL)
    OR B                                        ; Store pattern number into Sprite Attribute.
    NEXTREG _SPR_REG_ATR3_H38, A    

    ; Update lower sprite
    NEXTREG _SPR_REG_NR_H34, SPR_ID_JET_LW      ; Set the ID of the Jetman's sprite for the following commands.
    INC HL
    LD A, (HL)
    OR B                                        ; Store pattern number into Sprite Attribute.
    NEXTREG _SPR_REG_ATR3_H38, A    

    RET                                         ; ## END of the function ##
;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE
