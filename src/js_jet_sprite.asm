/*
  Copyright (c) 2027 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                      Fred Sprite                       ;
;----------------------------------------------------------;
    MODULE js

SPR_ID_JET_UP           = 0                     ; ID of Fred upper sprite
SPR_ID_JET_LW           = 1                     ; ID of Fred lower sprite

; IDs for #jetSpriteDB.
SDB_FLY                 = 201                   ; Fred is flaying
SDB_FLYD                = 202                   ; Fred is flaying down
SDB_WALK                = 203                   ; Fred is walking
SDB_WALK_ST             = 204                   ; Fred starts walking with raised feet to avoid moving over the ground and standing still
SDB_HOVER               = 205                   ; Fred hovers
SDB_STAND               = 206                   ; Fred stands in place
SDB_JSTAND              = 207                   ; Fred quickly stops walking
SDB_RIP                 = 208                   ; Fred got hit

SDB_T_WF                = 220                   ; Transition: walking -> flaying
SDB_T_FS                = 221                   ; Transition: flaying -> standing
SDB_T_FW                = 222                   ; Transition: flaying -> walking
SDB_T_KF                = 223                   ; Transition: kicking -> flying
SDB_T_KO                = 224                   ; Transition: kicking -> hovering

SDB_SUB                 = 100                   ; 100 for OFF_NX that CPIR finds ID and not OFF_NX (see record doc below, look for: OFF_NX)
SDB_FRAME_SIZE          = 2

sprDBIdx                DW 0                    ; Current position in DB
sprDBRemain             DB 0                    ; Amount of bytes that have to be still processed from the current record
sprDBCurrentId          DB SDB_STAND            ; Active animation
sprDBNextId             DB SDB_STAND            ; ID in #jetSpriteDB for next animation/DB record
sprDBDelay              DB 0                    ; Value from #DELAY
sprDBDelayCnt           DB 0                    ; Counter from #sprDBDelay to 0

SPR_STATE_HIDE          = 0
SPR_STATE_SHOW          = 1
sprState                DB SPR_STATE_SHOW


;----------------------------------------------------------;
;                      InitFredSprite                       ;
;----------------------------------------------------------;
InitFredSprite

    ; Setup anchor sprite (head)
    NEXTREG _SPR_REG_NR_H34, SPR_ID_JET_UP      ; Set the ID of the Fred's sprite for the following commands
    NEXTREG _SPR_REG_X_H35, 0                   ; Set X position
    NEXTREG _SPR_REG_Y_H36, 0                   ; Set Y position
    NEXTREG _SPR_REG_ATR2_H37, 0
    NEXTREG _SPR_REG_ATR3_H38, _SPR_ATTR3_HIDE_EXT

    ; Set up the bottom sprite (legs) as a relative sprite. This attribute 4 for the head sprite will set it as an anchor and increase 
    ; the sprite id for the following commands. Head sprite becomes anchor for legs (relative sprite).
    NEXTREG _SPR_REG_ATR4_INC_H79, _SPR_ATR4_ANCHOR

    NEXTREG _SPR_REG_X_H35, 0                   ; Set X position

    ; Legs are 16px below head.
    NEXTREG _SPR_REG_Y_H36, 16                   ; Set Y position

    NEXTREG _SPR_REG_ATR2_H37, 0
    NEXTREG _SPR_REG_ATR3_H38, _SPR_ATTR3_HIDE_EXT

    ; Relative sprite
    NEXTREG _SPR_REG_ATR4_H39, _SPR_ATR4_RELATIVE

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;              UpdateFredSpritePositionRotation             ;
;----------------------------------------------------------;
UpdateFredSpritePositionRotation

    dbs.SetupArrays2Bank

    NEXTREG _SPR_REG_NR_H34, SPR_ID_JET_UP      ; Set the ID of the Fred's sprite for the following commands.

    ; Move Fred Sprite to the current X position, the 9-bit value requires two writes (8 bit from C + 1 bit from B)
    LD BC, (jpo.jetX)

    ; Set Fred's X postion.
    LD A, C
    NEXTREG _SPR_REG_X_H35, A                   ; Set LSB from BC (X)

    ; Move Fred sprite to current Y postion, 8-bit value is simple
    LD A, (jpo.jetY)
    NEXTREG _SPR_REG_Y_H36, A                   ; Set Y position

    ; Set overflow bit from X, rotation and mirror.
    LD A, (gid.jetDirection)
    LD D, A
    XOR A                                       ; Clear A to set only rotation/mirror bits
    BIT gid.MOVE_LEFT_BIT_D0, D                    ; Moving left bit set?
    JR Z, .rotateRight
    SET _SPR_REG_ATR2_MIRX_BIT, A               ; Rotate sprite left
    JR .afterRotate 
.rotateRight    
    RES _SPR_REG_ATR2_MIRX_BIT, A               ; Rotate sprite right
.afterRotate
    LD E, A                                     ; Backup A

    LD A, B                                     ; Load MSB from X into A
    AND _OVERFLOW_BIT                           ; Keep only an overflow bit
    OR E                                        ; Apply rotation from A (E now)

    NEXTREG _SPR_REG_ATR2_H37, A

    ; Anchor with relative sprite (see #InitFredSprite)
    NEXTREG _SPR_REG_ATR4_H39, _SPR_ATR4_ANCHOR

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 ChangeFredSpritePattern                   ;
;----------------------------------------------------------;
; Switches immediately to the given animation, breaking the currently running one.
; Input:
;   - A: ID for #jesSprites, to switch to the next animation record
ChangeFredSpritePattern

    ; Do not change the animation if the same animation is already playing, it will restart it
    LD B, A
    LD A, (sprDBCurrentId)
    CP B
    RET Z

    LD A, B                                     ; Restore method param

    LD (sprDBNextId), A                         ; Next animation record
    LD (sprDBCurrentId), A

    XOR A                                       ; Set A to 0
    LD (sprDBRemain), A                         ; No more bytes to process within the current DB record will cause the fast switch to the next

    CALL AnimateFredSprite                       ; Update the next animation frame immediately

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   AnimateFredSprite                       ;
;----------------------------------------------------------;
; Update sprite pattern for the next animation frame
AnimateFredSprite

    dbs.SetupArrays2Bank

    ; Delay animation.
    LD A, (sprDBDelay)
    OR A                                        ; Same as CP 0, but faster.
    JR Z, .afterAnimationDelay                  ; Jump if delay is off

    ; Animation delay is on. Check if counter has reached 0 and needs to be reset.
    LD A, (sprDBDelayCnt)
    OR A                                        ; Same as CP 0, but faster.
    JR NZ, .decResetDelay

    ; Delay counter is 0, reset it
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
    OR A                                        ; Same as CP 0, but faster.
    JR NZ, .afterRecordChange                   ; Jump if there are still bytes to be processed

    ; Load new record.
    LD HL, db2.jetSpriteDB                      ; HL points to the beginning of the DB
    LD A, (sprDBNextId)                         ; CPIR will keep increasing HL until it finds the record ID from A
    LD (sprDBCurrentId), A                      ; Store current animation
    LD BC, 0                                    ; Do not limit CPIR search
    CPIR

    ; Now we are at the correct DB position containing the following sprite pattern and will load it into the registry.
    LD A, (HL)                                  ; Update next pointer to next animation record
    ADD SDB_SUB                                 ; Add 100 because DB value had  -100, to avoid collision with ID
    LD (sprDBNextId), A 

    INC HL                                      ; HL points to [SIZE]
    LD A, (HL)                                  ; Update SIZE
    LD (sprDBRemain), A

    INC HL                                      ; HL points to [DELAY]
    LD A, (HL)
    LD (sprDBDelay), A
    LD (sprDBDelayCnt), A

    INC HL                                      ; HL points to first sprite data (upper/lower parts)
    LD (sprDBIdx), HL                           ; Database offset points to be bytes containing sprite offsets from sprite file
.afterRecordChange

    ; 2 bytes will be consumed from current DB record -> upper and lower sprite for Fred.
    LD A, (sprDBRemain)
    ADD -SDB_FRAME_SIZE
    LD (sprDBRemain), A

    ; Now we are at correct DB position containing next sprite pattern and will load it into registry.
    LD HL, (sprDBIdx)

    ; Store in B _SPR_ATTR3_SHOW/_HIDE depending on the #sprState
    LD A, (sprState)
    CP SPR_STATE_HIDE
    JR Z, .hide
    LD B, _SPR_ATTR3_SHOW                     ; Sprite is visible
    JR .afterShow
.hide
    LD B, _SPR_ATTR3_HIDE                     ; Sprite is hidden
.afterShow

    ; Update upper sprite
    NEXTREG _SPR_REG_NR_H34, SPR_ID_JET_UP      ; Set the ID of the Fred's sprite for the following commands.
    LD A, (HL)                                  ; Store pattern number into sprite attribute
    OR B                                        ; Store visibility sprite attribute
    SET _SPR_ATTR3_EX_BIT_6, A                  ; Set extendet attribue to keep anchor/relative sprite.
    NEXTREG _SPR_REG_ATR3_H38, A

    ; Update lower sprite
    NEXTREG _SPR_REG_NR_H34, SPR_ID_JET_LW      ; Set the ID of the Fred's sprite for the following commands.
    INC HL
    LD A, (HL)                                  ; Store pattern number into sprite attribute
    OR B                                        ; Store visibility sprite attribute
    SET _SPR_ATTR3_EX_BIT_6, A                  ; Set extendet attribue to keep anchor/relative sprite.
    NEXTREG _SPR_REG_ATR3_H38, A

    ; Update pointer to DB
    INC HL
    LD (sprDBIdx), HL

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     BlinkFredSprite                       ;
;----------------------------------------------------------;
; Input:
; - A: flip flop counter, ie: #counter002FliFLop
BlinkFredSprite

    CP _GC_FLIP_ON_D1
    JR NZ, .flipOff
    
    ; Show sprite
    CALL HideFredSprite
    RET
.flipOff
    ; Hide sprite
    CALL ShowFredSprite

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      ShowFredSprite                       ;
;----------------------------------------------------------;
ShowFredSprite

    LD A, SPR_STATE_SHOW
    LD (sprState), A

    LD B, _SPR_ATTR3_SHOW_EXT
    CALL _ShowOrHideFredSprite

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      HideFredSprite                       ;
;----------------------------------------------------------;
HideFredSprite

    LD A, SPR_STATE_HIDE
    LD (sprState), A

    LD B, _SPR_ATTR3_HIDE_EXT
    CALL _ShowOrHideFredSprite

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                 ChangeFredSpriteOnFlyDown                 ;
;----------------------------------------------------------;
ChangeFredSpriteOnFlyDown

    ; Change animation only if Fred is flying
    LD A, (jt.jetAir)
    CP jt.AIR_FLY_D10
    RET NZ

    ; Switch to flaying down animation
    LD A, SDB_FLYD
    CALL ChangeFredSpritePattern

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                ChangeFredSpriteOnFlyUp                    ;
;----------------------------------------------------------;
ChangeFredSpriteOnFlyUp

    ; Change animation only if Fred is flying.
    LD A, (jt.jetAir)
    CP jt.AIR_FLY_D10
    RET NZ

    ; Switch to flaying animation.
    LD A, SDB_FLY
    CALL ChangeFredSpritePattern
    RET                                         ; ## END of the function ## 

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                  _ShowOrHideFredSprite                    ;
;----------------------------------------------------------;
; Input:
;  - B: _SPR_ATTR3_SHOW_EXT or _SPR_ATTR3_HIDE_EXT
_ShowOrHideFredSprite

    dbs.SetupArrays2Bank

    LD HL, (sprDBIdx)                           ; Load current sprite pattern.

    ; Every update sprite pattern moves db pointer to the next record, but blinking has to show current record.
    ADD HL, -SDB_FRAME_SIZE

    ; Update upper sprite
    NEXTREG _SPR_REG_NR_H34, SPR_ID_JET_UP      ; Set the ID of the Fred's sprite for the following commands.
    LD A, (HL)                                  ; Store pattern number into Sprite Attribute.
    OR B                                        ; Add show/hide bit and ext.
    NEXTREG _SPR_REG_ATR3_H38, A

    ; Update lower sprite
    NEXTREG _SPR_REG_NR_H34, SPR_ID_JET_LW      ; Set the ID of the Fred's sprite for the following commands.
    INC HL
    LD A, (HL)                                  ; Store pattern number into Sprite Attribute.
    OR B                                        ; Add show/hide bit and ext.
    NEXTREG _SPR_REG_ATR3_H38, A

    RET                                         ; ## END of the function ##
;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE
