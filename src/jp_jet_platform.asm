;----------------------------------------------------------;
;                    Platforms and Ground                  ;
;----------------------------------------------------------;
	MODULE jp

JOY_DISABLED_FALL		= 6						; Disable the joystick for a few frames because Jetman is falling from the platform
JOY_DISABLED_BUMP		= 6						; Disable the joystick for a few frames because Jetman is bumping into the platform

; Coordinates for walking on a platform
	STRUCT P_WALK
Y						BYTE					; Height of the platform
X_START					BYTE					; X start of the platform
X_END					BYTE					; X end of the platform
	ENDS

; Coordinates for walking on a platform
; [amount of plaftorms], #P_WALK,..., #P_WALK]
platformWalk
	P_WALK {089/*Y*/, 012/*X_START*/, 065/*X_END*/}
platformWalk2
	P_WALK {137/*Y*/, 075/*X_START*/, 136/*X_END*/}
platformWalk3	
	P_WALK {049/*Y*/, 190/*X_START*/, 240/*X_END*/}
platformWalkSize 		BYTE 3

; Coordinates for bumping into a platform
	STRUCT PCL									; Platform Collision
X_START					WORD					; X start of the platform
X_END					WORD					; X end of the platform
Y_START					BYTE					; Y start of the platform
Y_END					BYTE					; Y end of the platform
	ENDS

; [amount of plaftorms], #PCL,..., #PCL]
platformCollision
	PCL {009/*X_START*/, 070/*X_END*/, 093/*Y_START*/, 120/*Y_END*/}
platformCollision2	
	PCL {073/*X_START*/, 142/*X_END*/, 141/*Y_START*/, 169/*Y_END*/}
platformCollision3
	PCL {187/*X_START*/, 245/*X_END*/, 054/*Y_START*/, 079/*Y_END*/}
platformCollisionSize	BYTE 3

; We are using platform coordinates for bumping, which are too thick for the thin sprite
PLATFROM_MARGIN_UP		= 10
PLATFROM_MARGIN_DOWN	= 5

;----------------------------------------------------------;
;                 #LevelPlaftormColision                   ;
;----------------------------------------------------------;
; Check whether the sprite given by IX hits one of the platforms
;  - IX: 	Pointer to #SPR, single sprite to check colsion for
;  - L:		Half of the height of the sprite
LevelPlaftormColision

	LD IY, platformCollision

	LD A, (jp.platformCollisionSize)
	LD B, A

	CALL jp.PlaftormColision
	RET

;----------------------------------------------------------;
;                    #PlaftormColision                     ;
;----------------------------------------------------------;
; Check whether the sprite given by IX hits one of the platforms
; Input:
;  - IX: 	Pointer to #SPR, single sprite to check colsion for
;  - IY:	Pointert to #PCL list
;  - B:		Number of elements in #PCL list
;  - C:		Half of the height of the sprite
; Output:
;  - A: 	MOVE_RET_XXX
PL_COL_RET_A_NO 			= 0					; No colision
PL_COL_RET_A_YES 			= 1					; Sprite hits the platform

PlaftormColision

	; Exit if sprite is not alive
	BIT sr.SPRITE_ST_ACTIVE_BIT, (IX + sr.SPR.STATE)	
	JR NZ, .alive								; Jump if sprite is alive

	LD A, PL_COL_RET_A_NO
	RET
.alive

.loopOverPlatforms
	; Check the collision from the left side of the platform
	LD DE, (IY + PCL.X_START)					; DE = start of the platform (left side)
	LD HL, (IX + sr.SPR.X)						; HL = X postion of the sprite		
	SBC HL, DE									; HL - DE
	JP M, .continueLoopOverPlatfroms			; continue (no collision) if HL - DE < 0

	; Sprite is on the left from the platform's left corner. Now check whether it's not over the end 
	LD DE, (IX + sr.SPR.X)						; DE = X postion of the sprite
	LD HL, (IY + PCL.X_END)						; HL = start of the platform (left side)
	SBC HL, DE									; HL - DE
	JP M, .continueLoopOverPlatfroms			; continue (no collision) if HL - DE < 0
	
	; Sprite is within the platform's horizontal position. Now check whether it's within vertical bounds
	LD A, (IY + PCL.Y_START)
	ADD PLATFROM_MARGIN_UP						; Increase start Y to make platform thinner
	LD D, A

	LD A, (IY + PCL.Y_END)
	SUB PLATFROM_MARGIN_DOWN					; Decrease end Y to make the platform thinner
	LD E, A

	LD A, (IX + sr.SPR.Y)						; A holds current sprite Y position
	
	CP D										; Compare [Y sprite] position to [Y start]
	JR C, .continueLoopOverPlatfroms			; Jump if shot < [Y platform start]

	CP E
	JR NC, .continueLoopOverPlatfroms			; Jump if shot > [Y end]

	; Sprite hits the platform!
	LD A, PL_COL_RET_A_YES

	RET

.continueLoopOverPlatfroms
	LD DE, PCL
	ADD IY, DE
	DJNZ .loopOverPlatforms							; Decrease B until all platforms have been evaluated

	LD A, PL_COL_RET_A_NO
	RET

;----------------------------------------------------------;
;              #AnimateOnJoystickDisabled                  ;
;----------------------------------------------------------;
AnimateOnJoystickDisabled
	; Is Jetman falling from the platform on the right side?
	LD A, (jt.jetAir)
	CP jt.AIR_FALL_RIGHT
	JR NZ, .afterFallingRight

	; Yes, Jetman is falling from the platform
	CALL jo.IncJetX

	LD B, 2
	CALL jo.IncJetYbyB

	JR .afterAnimate							; Do not check falling left or bumping because Jetman is already falling
.afterFallingRight	

	; Is Jetman falling from the platform on the left side?
	LD A, (jt.jetAir)
	CP jt.AIR_FALL_LEFT
	JR NZ, .afterFallingLeft

	; Yes, Jetman is falling from the platform
	CALL jo.DecJetX
	
	LD B, 2
	CALL jo.IncJetYbyB
	JR .afterAnimate							; Do not check for bumping, as Jetman is falling
.afterFallingLeft	

	; Is Jetman bumping into the platform from the right?
	LD A, (jt.jetAir)
	CP jt.AIR_BUMP_RIGHT
	JR NZ, .afterBumpingRight

	; Yes
	CALL jo.IncJetX
	JR .afterAnimate							; Do not check bumping left
.afterBumpingRight

	; Is Jetman bumping into the platform from the left?
	LD A, (jt.jetAir)
	CP jt.AIR_BUMP_LEFT
	JR NZ, .afterBumpingLeft

	; Yes
	CALL jo.DecJetX	
	JR .afterAnimate
.afterBumpingLeft

	; Or finally, maybe Jetmat hits the platform from the bottom?
	LD A, (jt.jetAir)
	CP jt.AIR_BUMP_BOTTOM
	JR NZ, .afterAnimate

	; Yes
	CALL jo.IncJetY
	JR .afterAnimate

.afterAnimate

	RET	
	
;----------------------------------------------------------;
;                      #JetTakesoff                        ;
;----------------------------------------------------------;
JetTakesoff

	; Transition from walking to flaying
	LD A, (jt.jetState)
	BIT jt.JET_STATE_GND_BIT, A					; Check if Jetnan is on the ground/platform
	RET Z

	; Jetman is taking off
	LD A, jt.AIR_FLY
	CALL jt.ChangeJetStateAir

	; Play takeoff animation					
	LD A, js.SDB_T_WF
	CALL js.ChangeJetSpritePattern
	RET											; END #JetTakesoff

;----------------------------------------------------------;
;                       #JetLanding                        ;
;----------------------------------------------------------;
JetLanding
	; Update state as we are walking
	CALL jt.ChangeJetStateGnd
	
	; Jemans is landing, trigger transition: flying -> standing/walking
	LD A, (id.joyDirection)
	AND id.MOVE_MSK_LR
	CP 1	
	JR C, .afterMoveLR							; Jump, if there is no movement right/left (A >= 1) -> Jemtan lands and stands still
	
	; Jetman moves left/right
	LD A, jt.GND_WALK							; Update #jetGnd as we are walking
	LD (jt.jetGnd), A	

	LD A, js.SDB_T_FW							; Play transition from landing -> walking
	CALL js.ChangeJetSpritePattern

	JR .afterStand								; The animation is already loaded, do not overweigh it with standing
.afterMoveLR	

	LD A, jt.GND_STAND							; Update #jetGnd as we are standing
	LD (jt.jetGnd), A	

	LD A, js.SDB_T_FS							; Play transition from landing -> standing
	CALL js.ChangeJetSpritePattern
.afterStand
	RET

;----------------------------------------------------------;
;                  #LandingOnPlatform                      ;
;----------------------------------------------------------;
; Is Jetman landing on one of the platforms?
LandingOnPlatform
	LD A, (jt.jetState)
	BIT jt.JET_STATE_AIR_BIT, A					; Is Jemtan in the air?
	RET Z										; Return if not flaying, no flying - no landing ;)

	; Is Jetman too far right (above 255 there are no platforms)?
	LD BC, (jo.jetX)
	LD A, B										; #jetX has 16bit, load MSB into A to see if its > 0 (jetX >= 257)
	CP 0
	RET NZ										; Return if Jetman is after 257 on X
	
	LD IX, platformWalk
	LD A, (platformWalkSize)					; Load into B the number of platforms to check
	LD B, A
.platformsLoop	
	LD A, (jo.jetY)								; A holds current Y position
	LD C, (IX + P_WALK.Y)						; C contains [Y]
	CP C
	JR NZ, .platformsLoopEnd					; Jump if Jetman is on a different level than the current platform

	; Jetman is on Y of the current platform, now check X
	LD A, (jo.jetX)								; A holds current X position
	LD D, (IX + P_WALK.X_START)					; D contains [X start]		
	CP D										; Compare #jetX position to [X start]
	JR C, .platformsLoopEnd						; Jump if #jetX < [X start]

	; Jetman is on the current platform level after it's begun, we have to check if he is not too far to the right
	LD E, (IX + P_WALK.X_END)					; E contains [X end]		
	CP E
	JR NC, .platformsLoopEnd					; Jump if #jetX > [X end]

	; Jetman is landing on the platform!
	CALL JetLanding
	RET

.platformsLoopEnd
	LD DE, P_WALK
	ADD IX, DE
	DJNZ .platformsLoop							; Decrease B until all platforms have been evaluated
	RET

;----------------------------------------------------------;
;                #BumpIntoPlatFormBelow                    ;
;----------------------------------------------------------;
BumpIntoPlatFormBelow
	LD A, (jt.jetState)
	BIT jt.JET_STATE_AIR_BIT, A					; Is Jemtan in the air?
	RET Z										; Return if not flaying, no flying - no collision ;)

	; Is Jetman too far right (above 255 there are no platforms)?
	LD BC, (jo.jetX)
	LD A, B										; #jetX has 16bit, load MSB into A to see if its > 0 (jetX >= 257)
	CP 0
	RET NZ										; Return if Jetman is after 257 on X

	LD IX, platformCollision
	LD A, (platformCollisionSize)						; Load into B the number of platforms to check
	LD B, A
.platformsLoop	
	LD A, (jo.jetY)								; A holds current Y position
	LD C, (IX + PCL.Y_END)					; C contains [Y end]
	CP C
	JR NZ, .platformsLoopEnd					; Jump if Jetman is not precisely on the bottom level of the platform -> [Y] != #jetY

	; Jetman is on the bottom of the platform, now check whether he is withing its horizonlat bounds
	LD A, (jo.jetX)								; A holds current X position

	LD D, (IX + PCL.X_START)					; D contains [X start]	
	CP D										; Compare #jetX position to [X start]
	JR C, .platformsLoopEnd						; Jump if #jetX < [X start]

	LD E, (IX + PCL.X_END)					; E contains [Y end]
	CP E
	JR NC, .platformsLoopEnd					; Jump if #jetX > [X end]

	; Jetman hits the platform!
	LD A, jt.AIR_BUMP_BOTTOM					; Change air state
	LD (jt.jetAir), A
	
	PUSH BC

	LD A, js.SDB_T_KF							; Play animation
	CALL js.ChangeJetSpritePattern
	
	; Disable joystick, because Jetman looses control for a few frames
	LD A, JOY_DISABLED_BUMP						
	LD (id.joyDisabledCnt), A

	POP BC
.platformsLoopEnd
	LD DE, PCL
	ADD IX, DE
	DJNZ .platformsLoop							; Decrease B until all platforms have been evaluated
	RET

;----------------------------------------------------------;
;                  #BumpIntoPlatformLR                     ;
;----------------------------------------------------------;
; Bump into a platform from left or right
; Input
;  - H:		jt.AIR_BUMP_LEFT or jt.AIR_BUMP_RIGHT
BumpIntoPlatformLR

	; Is Jemtan in the air?
	LD A, (jt.jetState)
	BIT jt.JET_STATE_AIR_BIT, A
	RET Z										; Return if not flaying, no flying - no collision ;)

	; Is Jetman too far right (above 255 there are no platforms)?
	LD BC, (jo.jetX)
	LD A, B										; #jetX has 16bit, load MSB into A to see if its > 0 (jetX >= 257)
	CP 0
	RET NZ										; Return if Jetman is after 257 on X
	
	LD IX, platformCollision
	LD A, (platformCollisionSize)						; Load into B the number of platforms to check
	LD B, A
.platformsLoop	

	; Check whether we should consider the left or right side of the platform.
	LD A, H										; A holds AIR_BUMP_LEFT or AIR_BUMP_RIGHT
	CP jt.AIR_BUMP_LEFT
	JR Z, .bumpLeft

	; Jetman bumps into the platform from the right
	LD C, (IX + PCL.X_END)					; C contains [X end]
	JR .afterBumpSideCheck
.bumpLeft	
	; Jetman bumps into the platform from the left
	LD C, (IX + PCL.X_START)
.afterBumpSideCheck

	LD D, (IX + PCL.Y_START)
	LD E, (IX + PCL.Y_END)

	LD A, (jo.jetX)								; A holds current X position
	CP C
	JR NZ, .platformsLoopEnd					; Jump if Jetman is not close to the left/right edge of the platform

	; Jetman is close to the left/right edge of the platform
	LD A, (jo.jetY)								; A holds current Y position
	CP D										; Compare #jetY position to [Y start]
	JR C, .platformsLoopEnd						; Jump if #jetY < [Y start]

	CP E
	JR NC, .platformsLoopEnd					; Jump if #jetY > [Y end]

	; Jetman hits the platform from the left/right!
	LD A, H										; Change air state, H is a method param
	LD (jt.jetAir), A

	PUSH BC

	LD A, js.SDB_T_KF							; Play animation
	CALL js.ChangeJetSpritePattern
	
	; Disable joystick, because Jetman looses control for a few frames
	LD A, JOY_DISABLED_BUMP						
	LD (id.joyDisabledCnt), A

	POP BC
.platformsLoopEnd
	LD DE, PCL
	ADD IX, DE
	DJNZ .platformsLoop							; Decrease B until all platforms have been evaluated
	RET
;----------------------------------------------------------;
;                  #FallingFromPlatform                    ;
;----------------------------------------------------------;
; Jetman walks to the edge of the platform and falls 
FallingFromPlatform
	LD A, (jt.jetGnd)
	CP jt.GND_WALK								; Is Jemtan in the air?
	RET NZ										; Return if not walking, no walking - no falling ;)

	LD IX, platformWalk
	LD A, (platformCollisionSize)
	LD B, A										; Load into B the number of platforms to check
.platformsLoop	
	LD A, (jo.jetY)								; A holds current Y position
	LD C, (IX + P_WALK.Y)						; C contains [Y]
	CP C
	JR NZ, .platformsLoopEnd					; Jump if Jetman is on a different level than the current platform

	; Jetman is on Y of the current platform, now check X
	LD A, (jo.jetX)								; A holds current X position
	LD D, (IX + P_WALK.X_START)					; D contains [X start]	
	CP D										; Compare #jetX position to [X start]
	JR C, .fallingLeft							; Jump if #jetX < [X start], meaning Jetman is falling from the left side of the platform

	LD E, (IX + P_WALK.X_END)					; E contains [X end]
	CP E
	JR NC, .fallingRight						; Jump if #jetX > [X end], meaning Jetman is falling from the right side of the platform

.platformsLoopEnd
	LD DE, P_WALK
	ADD IX, DE
	DJNZ .platformsLoop							; Decrease B until all platforms have been evaluated
	JR .afterFalling							; Jetman is still on the platform

; Jetman is falling from the platform, left or right
.fallingLeft
	LD A, jt.AIR_FALL_LEFT
	JR .afterFallingRight

.fallingRight
	LD A, jt.AIR_FALL_RIGHT

.afterFallingRight
	; Jetman if falling, in the air - A contains poroper air state
	CALL jt.ChangeJetStateAir

	; Trigger transition: walking -> falling
	LD A, js.SDB_T_KF
	CALL js.ChangeJetSpritePattern

	; Disable joystick, because Jetman loses control for #JOY_DISABLED_FALL frames
	LD A, JOY_DISABLED_FALL
	LD (id.joyDisabledCnt), A

.afterFalling
	RET

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE