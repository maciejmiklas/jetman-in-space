;----------------------------------------------------------;
;                    Platforms and Ground                  ;
;----------------------------------------------------------;
	MODULE pl

Y_OFFSET				= 2

; Platform margin/border
	STRUCT PLAM
X_LEFT					WORD
X_RIGHT					WORD
Y_TOP					BYTE
Y_BOTTOM				BYTE
	ENDS

enemyHitMargin	PLAM { 15/*X_LEFT*/, 15/*X_RIGHT*/, 07/*Y_TOP*/, 00/*Y_BOTTOM*/}
shotHitMargin	PLAM { 10/*X_LEFT*/, 10/*X_RIGHT*/, 07/*Y_TOP*/, -8/*Y_BOTTOM*/}
jetHitMargin	PLAM { 15/*X_LEFT*/, 07/*X_RIGHT*/, 22/*Y_TOP*/, 02/*Y_BOTTOM*/}

; Be careful - Jetman bumps into a platform and gets pushed away, which counts as movement. When Jetman gets pushed too far,
; it exceeds the margin defined here, resetting #joyOffBump.
jetAwayMargin	PLAM { 30/*X_LEFT*/, 20/*X_RIGHT*/, 30/*Y_TOP*/, 10/*Y_BOTTOM*/}

; Coordinates for a platform
	STRUCT PLA
X_LEFT					WORD					; X start of the platform.
X_RIGHT					WORD					; X end of the platform.
Y_TOP					BYTE					; Y start of the platform.
Y_BOTTOM				BYTE					; Y end of the platform.
	ENDS

; [amount of platforms], #PLA,..., #PLA]. Platforms are tiles. Each tile has 8x8 pixels.
platforms
	PLA {3*8/*X_LEFT*/,  8*8/*X_RIGHT*/,  14*8/*Y_TOP*/, 14*8+8/*Y_BOTTOM*/}
platform2
	PLA {11*8/*X_LEFT*/, 17*8/*X_RIGHT*/, 20*8/*Y_TOP*/, 20*8+8/*Y_BOTTOM*/}
platform3
	PLA {25*8/*X_LEFT*/, 30*8/*X_RIGHT*/, 9*8/*Y_TOP*/,  9*8+8/*Y_BOTTOM*/}
platformsSize 			BYTE 3

; A number of the platform that Jetman walks on. This byte is only set to the proper value when jt.jetGnd == jt.GND_WALK.
PLATFORM_WALK_INACTIVE	= $FF					; Not on any platform.

platformWalkNumber		BYTE PLATFORM_WALK_INACTIVE

joyOffBump				BYTE _PL_BUMP_JOY_D15; The amount of pixels to bump off the platform decrements with each hit.

;----------------------------------------------------------;
;                #JetPlatformHitOnJoyMove                  ;
;----------------------------------------------------------;
JetPlatformHitOnJoyMove

	; Check whether a collision with a platform is possible.
	LD A, (jt.jetAir)
	CP jt.AIR_FLY
	RET NZ										; Return if Jetman is not flaying.

	; ##########################################
	; Check for platform hit.

	; Params for _PlatformHit.
	LD HL, jpo.jetX

	LD IY, platforms

	LD A, (platformsSize)
	LD B, A

	LD IX, jetHitMargin

	CALL _PlatformDirectionHit

	CP PL_DHIT_RET_A_NO
	RET Z
	LD D, A										; Keep return flag D.


	; ##########################################
	; Jetman hits the platform, now check what it means.

	; ##########################################
	; Is Jetman landing on the platform?

	; Did Jetman hit top of the platform?
	LD A, D
	CP PL_DHIT_RET_A_TOP
	JR NZ, .afterLanding
	
	; Is Jetman moving down?
	LD A, (gid.joyDirection)
	BIT gid.MOVE_DOWN_BIT, A
	JR Z, .afterLanding							; Jump if move down bit is not set.
	
	; Update #platformWalkNumber = #platformSize - B.
	LD A, (platformsSize)
	SUB B
	LD (platformWalkNumber), A
	
	CALL JetLanding

	RET
.afterLanding	

	; ##########################################
	; Does Jetman hit the platform from the left side?
	LD A, D
	CP PL_DHIT_RET_A_LEFT
	JR NZ, .afterHitLeft
	
	; Is Jetman moving right (Jetman have to move right to hit the left side of the platform)?
	LD A, (gid.joyDirection)
	BIT gid.MOVE_RIGHT_BIT, A
	JR Z, .afterHitLeft							; Jump if right down bit is not set.
	
	; Jetman hits the platform.
	LD A, jt.AIR_BUMP_LEFT
	CALL jt.SetJetStateAir

	CALL _JetHitsPlatform

	; When Jetman bumps away from the platform, he has to move left at least one pixel to compensate for Joystick's movement,
	; or a few pixels to really bump off.
	LD A, (joyOffBump)
	CP _C_PL_BUMP_JOY_DEC_D1+1
	JR C, .bumpLeftOnPixel

	LD B, _PL_BUMP_X_D4
	CALL jpo.DecJetXbyB
	RET
.bumpLeftOnPixel
	CALL jpo.DecJetX

	RET
.afterHitLeft

	; ##########################################
	; Does Jetman hit the platform from the right side?
	LD A, D
	CP PL_DHIT_RET_A_RIGHT
	JR NZ, .afterHitRight
	
	; Is Jetman moving left (Jetman have to move left to hit the right side of the platform)?
	LD A, (gid.joyDirection)
	BIT gid.MOVE_LEFT_BIT, A
	JR Z, .afterHitRight						; Jump if left down bit is not set.
	
	; Jetman hits the platform from the right side and bumps off to the right.
	LD A, jt.AIR_BUMP_RIGHT
	CALL jt.SetJetStateAir

	CALL _JetHitsPlatform

	; When Jetman bumps away from the platform, he has to move right at least one pixel to compensate for Joystick's movement or a few pixels to really bump off.
	LD A, (joyOffBump)
	CP _C_PL_BUMP_JOY_DEC_D1+1
	JR C, .bumpRightOnPixel

	LD B, _PL_BUMP_X_D4
	CALL jpo.IncJetXbyB
	RET
.bumpRightOnPixel
	CALL jpo.IncJetX

	RET
.afterHitRight

	; ##########################################
	; Does Jetman hit the platform from the bottom?
	LD A, D
	CP PL_DHIT_RET_A_BOTTOM
	JR NZ, .afterHitBottom

	; Is Jetman moving up?
	LD A, (gid.joyDirection)
	BIT gid.MOVE_UP_BIT, A
	JR Z, .afterHitBottom						; Jump if left down bit is not set.
	
	; Jetman hits the platform from the bottom.
	LD A, jt.AIR_BUMP_BOTTOM
	CALL jt.SetJetStateAir

	CALL _JetHitsPlatform

	; When Jetman bumps away from the platform, he has to move down at least one pixel to compensate for Joystick's movement or a few pixels to really bump off.
	LD A, (joyOffBump)
	CP _C_PL_BUMP_JOY_DEC_D1+1
	JR C, .bumpDonwOnPixel

	LD B, _PL_BUMP_Y_D4
	CALL jpo.IncJetYbyB
	RET

.bumpDonwOnPixel
	CALL jpo.IncJetY

	RET
.afterHitBottom	

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                   #ResetJoyOffBump                       ;
;----------------------------------------------------------;
ResetJoyOffBump
	
	; Do not reset if already done.
	LD A, (joyOffBump)
	CP _PL_BUMP_JOY_D15
	RET Z

	; Reset the joystick bump only if Jetman is away from the platform,  or it walks on it.

	; Does Jetman walk on the platform?
	LD A, (jt.jetGnd)
	CP jt.STATE_INACTIVE
	JR NZ, .reset								; Reset immediately if walking.
	
	; Call _PlatformHit to check whether Jetman is close to the platform. now, we will load the params for this method.
	LD HL, jpo.jetX

	LD IY, platforms

	LD A, (platformsSize)
	LD B, A

	LD IX, jetAwayMargin

	CALL _PlatformHit
	CP PL_HIT_RET_A_YES							; Jetman is close to platform - do not reset the bump.
	RET Z	

.reset
	; Jetman far from the platform - reset.
	LD A, _PL_BUMP_JOY_D15
	LD (joyOffBump), A
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #PlatformEnemyHit                       ;
;----------------------------------------------------------;
; Check whether the sprite (#SPR) given by IX hits one of the platforms.
; Input:
;  - IX: 	Pointer to sr.SPR, single sprite to check cloison for.
; Output:
;  - A: 	#PL_HIT_RET_A_YES/ #PL_HIT_RET_A_NO
PlatformEnemyHit

	LD IY, enemyHitMargin
	CALL _PlatformSpriteHit

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                 #PlatformWeaponHit                       ;
;----------------------------------------------------------;
; Check whether the sprite (#SPR) given by IX hits one of the platforms.
; Input:
;  - IX: 	Pointer to sr.SPR, single sprite to check cloison for.
; Output:
;  - A: 	#PL_HIT_RET_A_YES/ #PL_HIT_RET_A_NO
PlatformWeaponHit

	LD IY, shotHitMargin
	CALL _PlatformSpriteHit

	RET											; ## END of the function ##

;----------------------------------------------------------;
;              #MoveJetOnFallingFromPlatform               ;
;----------------------------------------------------------;
MoveJetOnFallingFromPlatform

	; Is Jetman falling from the platform on the right side?
	LD A, (jt.jetAir)
	CP jt.AIR_FALL_RIGHT
	JR NZ, .afterFallingRight

	; Yes, Jetman is falling from the platform.
	LD B, _PL_FALL_X_D2
	CALL jpo.IncJetXbyB

	LD B, _PL_FALL_Y_D4
	CALL jpo.IncJetYbyB

	RET											; Do not check falling left  because Jetman is already falling.
.afterFallingRight	

	; Is Jetman falling from the platform on the left side?
	LD A, (jt.jetAir)
	CP jt.AIR_FALL_LEFT
	RET NZ

	; Yes, Jetman is falling from the platform.
	CALL jpo.DecJetX
	CALL jpo.DecJetX
	
	LD B, _PL_FALL_Y_D4
	CALL jpo.IncJetYbyB

	RET											; ## END of the function ##

;----------------------------------------------------------;
;              #MoveJetOnHitPlatformBelow                  ;
;----------------------------------------------------------;
MoveJetOnHitPlatformBelow

	; Jetman hits the platform from the bottom?
	LD A, (jt.jetAir)
	CP jt.AIR_BUMP_BOTTOM
	RET NZ

	; Yes, Jetman hits the platform.

	; Move down.
	CALL jpo.IncJetY

	; Move left/right in the opposite direction to joystick.
	LD A, (gid.joyDirection)

	; Joystick points right, move left.
	BIT gid.MOVE_RIGHT_BIT, A
	JR Z, .afterRight
	CALL jpo.IncJetX
	JR .afterLeft
.afterRight

	; Joystick points left, move right.
	BIT gid.MOVE_LEFT_BIT, A
	JR Z, .afterLeft
	CALL jpo.DecJetX
.afterLeft	

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                    #JetPlatformTakesOff                  ;
;----------------------------------------------------------;
JetPlatformTakesOff

	; Transition from walking to flaying.
	LD A, (jt.jetGnd)
	CP jt.STATE_INACTIVE						; Check if Jetman is on the ground/platform.
	RET Z

	; Jetman is taking off.
	LD A, jt.AIR_FLY
	CALL jt.SetJetStateAir

	; Play takeoff animation.
	LD A, js.SDB_T_WF
	CALL js.ChangeJetSpritePattern

	; Not walking on platform anymore.
	LD A, PLATFORM_WALK_INACTIVE
	LD (platformWalkNumber), A	

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                      #JetLanding                         ;
;----------------------------------------------------------;
JetLanding
	
	; Ignore landing if jetman is already on the ground.
	LD A, (jt.jetGnd)
	CP jt.STATE_INACTIVE
	RET NZ

	; Update state as we are walking.
	LD A, jt.GND_WALK
	CALL jt.SetJetStateGnd
	
	; Jetman is landing, trigger transition: flying -> standing/walking.
	LD A, (gid.joyDirection)
	AND gid.MOVE_MSK_LR
	CP 1	
	JR C, .afterMoveLR							; Jump, if there is no movement right/left (A >= 1) -> Jetman lands horizontally and stands still.
	
	LD A, js.SDB_T_FW							; Play transition from landing -> walking.
	CALL js.ChangeJetSpritePattern

	JR .afterStand								; The animation is already loaded, do not overweigh it with standing.
.afterMoveLR

	LD A, jt.GND_STAND
	CALL jt.SetJetStateGnd						; Update state as we are standing.

	LD A, js.SDB_T_FS							; Play transition from landing -> standing.
	CALL js.ChangeJetSpritePattern
.afterStand

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                #MoveJetOnPlatformSideHit                 ;
;----------------------------------------------------------;
MoveJetOnPlatformSideHit

	; Is Jetman bumping into the platform from the right?
	LD A, (jt.jetAir)
	CP jt.AIR_BUMP_RIGHT
	JR NZ, .afterBumpingRight

	; Yes
	CALL jpo.IncJetX
	RET										; Do not check bumping left.
.afterBumpingRight

	; Is Jetman bumping into the platform from the left?
	LD A, (jt.jetAir)
	CP jt.AIR_BUMP_LEFT
	RET NZ

	; Yes
	CALL jpo.DecJetX	

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                #JetFallingFromPlatform                   ;
;----------------------------------------------------------;
; Jetman walks to the edge of the platform and falls.
JetFallingFromPlatform

	; Does Jetman walk on any platform?
	LD A, (platformWalkNumber)
	CP PLATFORM_WALK_INACTIVE
	RET Z

	; #platform contains a list of all platforms, each with a size of #PLA. #platformWalkNumber contains offset to current platform.
	; Now, we have to set IX so that it points to the platform on which the Jetman walks: IX = #platform + #PLA * #platformWalkNumber.
	LD IX, platforms
	LD A, (platformWalkNumber)					; Jetman is walking on this platform.
	LD D, A
	LD E, PLA
	MUL D, E									; E contains #platformWalkNumber * #PLA, D is 0 (D * E < 256).
	ADD IX, DE									; IX points to the current platform.

	; Does Jetman fall from the platform on the left side?
	LD HL, (jpo.jetX)							; HL = X postion of the Jetman.
	LD DE, _PL_FALL_LX_D8
	ADD HL, DE
	LD DE, (IX + PLA.X_LEFT)					; DE = start of the platform (left side).
	SBC HL, DE									; HL - DE
	JP M, .fallingLeft							; HL - DE < 0 -> falling left.

	; Does Jetman fall from the platform on the right side?
	LD DE, (jpo.jetX)							; DE = X postion of the Jetman.
	LD HL, _C_PL_FALL_RX_N1
	ADD DE, HL
	LD HL, (IX + PLA.X_RIGHT)					; HL = start of the platform (left side).
	SBC HL, DE									; HL - DE
	JP M, .fallingRight							; HL - DE < 0 -> falling right.
	
	RET											; Still on the platform.

; Jetman is falling from the platform, left or right.
.fallingLeft
	LD A, jt.AIR_FALL_LEFT
	JR .afterFallingRight

.fallingRight
	LD A, jt.AIR_FALL_RIGHT

.afterFallingRight
	
	; Jetman if falling, in the air - A contains proper air state.
	CALL jt.SetJetStateAir

	; Trigger transition: walking -> falling.
	LD A, js.SDB_T_KF
	CALL js.ChangeJetSpritePattern

	; Disable joystick, because Jetman loses control for #_PL_FALL_JOY_OFF_D10 frames.
	LD A, _PL_FALL_JOY_OFF_D10
	LD (gid.joyOffCnt), A

.afterFalling

	; Not walking on platrofm anymore.
	LD A, PLATFORM_WALK_INACTIVE
	LD (platformWalkNumber), A	
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                    #_PlatformHit                         ;
;----------------------------------------------------------;
; Check whether the sprite given by coordinates hits one of the platforms. It does not provide direction, just an indication that 
; there was a hit. To get directions use #_PlatformDirectionHit.
; Input:
;  - HL: 	Pointer to memory containing (X[WORD],Y[BYTE]) coordinates to check for the collision.
;  - IY:	Pointer to #PLA list.
;  - B:		Number of elements in #PLA list.
;  - IX:	Pointer to #PLAM.
; Output:
;  - A: 	PL_HIT_RET_XXX
;  - B:		The current value of the platform counter. It counts from the maximum amount of platforms to zero.
;  - IY:	Set to current platform.
PL_HIT_RET_A_NO 		= 0						; No collision.
PL_HIT_RET_A_YES 		= 1						; Sprite hits the platform.
; Modifies:  A, BC, DE, IY
; Unchanged: HL, IX
_PlatformHit

.loopOverPlatforms

	; ##########################################
	; Check the collision from the left side of the platform.

	; HL points for memory location containing X; now we load into HL its value.
	PUSH HL 									; Keep HL for later use.

	; Load the sprite's X position into HL and push it into the stack so that we can use HL for something else.
	LD DE, (HL)
	LD HL, DE									; HL holds X postion of the sprite.
	PUSH HL

	; Subtracting the left margin from the left side of the platform will move the left margin to the left and increment the platform's left width.
	LD HL, (IY + PLA.X_LEFT)					; HL holds start of the platform (left side).
	LD DE, (IX + PLAM.X_LEFT)					; DE holds left margin.
	SBC HL, DE
	LD DE, HL
	POP HL

	; Now DE contains the left coordinate of the platform inclusive margin, and HL the sprite's X.
	SBC HL, DE									; HL - DE

	POP HL

	JP M, .continueLoopOverPlatforms			; continue (no collision) if HL - DE < 0.

	; ##########################################
	; Sprite is on the left from the platform's left corner. Now check whether it's not over the end.
	LD DE, (HL)									; DE holds X postion of the sprite.

	PUSH HL
	LD HL, (IY + PLA.X_RIGHT)					; HL holds end of the platform (right side).

	; Add margin to  HL (platform right).
	PUSH DE
	LD DE, (IX + PLAM.X_RIGHT)
	ADD HL, DE
	POP DE

	SBC HL, DE									; HL - DE
	POP HL

	JP M, .continueLoopOverPlatforms			; continue (no collision) if HL - DE < 0.

	; Sprite is within the platform's horizontal position. Now check whether it's within vertical bounds.

	; ##########################################
	; Check platform's top level.
	; Load the sprite's Y coordinate. It's in memory right after X, but HL points to X, so we must move it by size of WORD.
	LD DE, HL
	ADD DE, Y_OFFSET
	LD A, (DE)
	LD C, A										; C holds current sprite Y position.

	; Check platform's top level.
	LD A, (IY + PLA.Y_TOP)
	SUB (IX + PLAM.Y_TOP)						; Add platform top margin.

	CP C										; Compare [Y sprite] position to [Y start].
	JR NC, .continueLoopOverPlatforms			; Jump if sprite < [Y platform start].

	; ##########################################
	; Check platform's bottom level.
	LD A, (IY + PLA.Y_BOTTOM)
	ADD (IX + PLAM.Y_BOTTOM)					; Add platform bottom margin.

	CP C
	JR C, .continueLoopOverPlatforms			; Jump if sprite > [Y end].

	; ##########################################
	; Sprite hits the platform!
	LD A, PL_HIT_RET_A_YES
	RET

.continueLoopOverPlatforms
	LD DE, PLA
	ADD IY, DE
	DJNZ .loopOverPlatforms						; decrement B until all platforms have been evaluated.

	LD A, PL_HIT_RET_A_NO
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;               #_PlatformDirectionHit                     ;
;----------------------------------------------------------;
; Check whether the sprite given by coordinates hits one of the platforms, also provides platform number and side.
; Input:
;  - HL: 	Pointer to memory containing (X[WORD],Y[BYTE]) coordinates to check for the collision.
;  - IX:	Pointer to #PLAM.
;  - IY:	Pointer to #PLA list.
;  - B:		Number of elements in #PLA list.
; Output:
;  - A: 	#PL_DHIT_RET_XXX.
;  - B:		Platform counter set to the current platform. The counter starts with the number (inclusive) of platforms and counts toward 1 (inclusive).
PL_DHIT_RET_A_NO		= 0						; No collision
PL_DHIT_RET_A_LEFT		= 1						; Sprite hits the platform from the left
PL_DHIT_RET_A_RIGHT		= 2						; Sprite hits the platform from the right
PL_DHIT_RET_A_TOP		= 3						; Sprite hits the platform from above
PL_DHIT_RET_A_BOTTOM	= 4						; Sprite hits the platform from below
; Modifies: All

_PlatformDirectionHit

.loopOverPlatforms

	; ##########################################
	; Check the collision from the left side of the platform.

	PUSH BC
	CALL _CheckPlatformHitLeft
	POP BC

	CP PL_COL_RET_A_YES
	JR NZ, .afterHitLeft

	; We have a hit from the left side, now check whether Jetman is within the vertical bounds of the platform.
	CALL _CheckPlatformHitVertical

	CP PL_COL_RET_A_YES
	JR NZ, .afterHitLeft

	LD A, PL_DHIT_RET_A_LEFT
	RET
.afterHitLeft	

	; ##########################################
	; Check the collision from the right side of the platform.

	PUSH BC
	CALL _CheckPlatformHitRight
	POP BC

	CP PL_COL_RET_A_YES
	JR NZ, .afterHitRight

	; We have a hit from the right side, now check whether Jetman is within the vertical bounds of the platform.
	CALL _CheckPlatformHitVertical

	CP PL_COL_RET_A_YES
	JR NZ, .afterHitRight

	LD A, PL_DHIT_RET_A_RIGHT
	RET
.afterHitRight

	; ##########################################
	; Check the collision from the top side of the platform.

	CALL _CheckPlatformHitTop
	CP PL_COL_RET_A_YES
	JR NZ, .afterHitTop

	; We have a hit from the top side, now check whether Jetman is within the horizontal bounds of the platform.
	PUSH BC
	CALL _CheckPlatformHitHorizontal
	POP BC

	CP PL_COL_RET_A_YES
	JR NZ, .afterHitTop

	LD A, PL_DHIT_RET_A_TOP
	RET
.afterHitTop

	; ##########################################
	; Check the collision from the bottom side of the platform.

	CALL _CheckPlatformHitBottom
	CP PL_COL_RET_A_YES
	JR NZ, .afterHitBottom

	; We have a hit from the top side, now check whether Jetman is within the horizontal bounds of the platform.
	PUSH BC
	CALL _CheckPlatformHitHorizontal
	POP BC

	CP PL_COL_RET_A_YES
	JR NZ, .afterHitBottom

	LD A, PL_DHIT_RET_A_BOTTOM
	RET
.afterHitBottom

	; ##########################################
	; Lopp over platforms
	LD DE, PLA
	ADD IY, DE
	DJNZ .loopOverPlatforms							; decrement B until all platforms have been evaluated.

	; We've iterated over all platforms, and there was no hit.
	LD A, PL_HIT_RET_A_NO
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                   #_LoadSpriteYtoA                       ;
;----------------------------------------------------------;
; Load the sprite's Y coordinate. It's in memory right after X, but HL points to X, so we must move it by size of WORD.
; Input:
;  - HL: 	Pointer to memory containing (X[WORD],Y[BYTE]) coordinates to check for the collision.
; Output:
;  - A: 	Sprite's Y coordinate.
; Modifies: DE
_LoadSpriteYtoA

	LD DE, HL
	ADD DE, Y_OFFSET
	LD A, (DE)									; A holds current sprite Y position.

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                #_CheckPlatformHitTop                     ;
;----------------------------------------------------------;
; Check the collision with the top side of the platform.
; Collision when: [#PLA.Y_TOP - #PLAM.Y_TOP + #_PL_HIT_MARGIN_D5] > [sprite Y] > [#PLA.Y_TOP - #PLAM.Y_TOP].
; Input:
;  - HL: 	Pointer to memory containing (X[WORD],Y[BYTE]) coordinates to check for the collision.
;  - IX:	Pointer to #PLAM.
;  - IY:	Pointer to #PLA.
; Output:
;  - A: 	#PL_COL_RET_A_NO/#PL_COL_RET_A_YES
; Modifies: C
PL_COL_RET_A_NO			= 0						; No collision
PL_COL_RET_A_YES		= 1						; Collision

_CheckPlatformHitTop

	; ##########################################
	; Check [#PLA.Y_TOP - #PLAM.Y_TOP + #_PL_HIT_MARGIN_D5] > [sprite Y]
	LD A, (IY + PLA.Y_TOP)
	LD C, _PL_HIT_MARGIN_D5
	ADD C
	SUB (IX + PLAM.Y_TOP)
	LD C, A										; C holds [#PLA.Y_TOP + #_PL_HIT_MARGIN_D5].

	CALL _LoadSpriteYtoA						; A holds current sprite Y position.

	CP C
	JR C, .keepChecking							; Jump if A (sprite Y) < C.
	
	LD A, PL_COL_RET_A_NO						;  A (sprite Y) > C -> no collision.
	RET
	
.keepChecking

	; ##########################################
	; Check [sprite Y] > [#PLA.Y_TOP - #PLAM.Y_TOP].

	LD A, (IY + PLA.Y_TOP)
	SUB (IX + PLAM.Y_TOP)
	LD C, A										; C holds [#PLA.Y_TOP - #PLAM.Y_TOP].

	CALL _LoadSpriteYtoA						; A holds current sprite Y position.

	CP C
	JR NC, .hit									; Jump if A (sprite Y) >= C.
	
	LD A, PL_COL_RET_A_NO
	RET
.hit
	LD A, PL_COL_RET_A_YES

	RET											; ## END of the function ##

;----------------------------------------------------------;
;               #_CheckPlatformHitBottom                   ;
;----------------------------------------------------------;
; Check the collision with the bottom side of the platform.
; Collision when: [#PLA.Y_BOTTOM + #PLAM.Y_BOTTOM] > [sprite Y] > [#PLA.Y_BOTTOM + #PLAM.Y_BOTTOM - #_PL_HIT_MARGIN_D5]
; Input:
;  - HL: 	Pointer to memory containing (X[WORD],Y[BYTE]) coordinates to check for the collision. 
;  - IX:	Pointer to #PLAM.
;  - IY:	Pointer to #PLA.
; Output:
;  - A: 	#PL_COL_RET_A_NO/#PL_COL_RET_A_YES
; Modifies: C
_CheckPlatformHitBottom
	
	; Check [#PLA.Y_BOTTOM + #PLAM.Y_BOTTOM] > [sprite Y].
	LD A, (IY + PLA.Y_BOTTOM)
	ADD (IX + PLAM.Y_BOTTOM)
	LD C, A										; C holds [#PLA.Y_BOTTOM + #PLAM.Y_BOTTOM].

	CALL _LoadSpriteYtoA						; A holds current sprite Y position.

	CP C
	JR C, .keepChecking							; Jump if A (sprite Y) < C.
	
	LD A, PL_COL_RET_A_NO						;  A (sprite Y) > C -> no collision.
	RET	
.keepChecking

	; ##########################################
	; Check [sprite Y] > [#PLA.Y_BOTTOM + #PLAM.Y_BOTTOM - #_PL_HIT_MARGIN_D5].

	LD A, (IY + PLA.Y_BOTTOM)
	ADD (IX + PLAM.Y_BOTTOM)
	SUB _PL_HIT_MARGIN_D5
	LD C, A										; C holds [#PLA.Y_BOTTOM + #PLAM.Y_BOTTOM - #_PL_HIT_MARGIN_D5].

	CALL _LoadSpriteYtoA							; A holds current sprite Y position.

	CP C
	JR NC, .hit									; Jump if A (sprite Y) >= C.
	
	LD A, PL_COL_RET_A_NO
	RET
.hit
	LD A, PL_COL_RET_A_YES

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                #_CheckPlatformHitLeft                    ;
;----------------------------------------------------------;
; Check the collision with the left side of the platform.
; Collision when: [#PLA.X_LEFT - #PLAM.X_LEFT + #_PL_HIT_MARGIN_D5] > [sprite X] > [#PLA.X_LEFT - #PLAM.X_LEFT].
; Input:
;  - HL: 	Pointer to memory containing (X[WORD],Y[BYTE]) coordinates to check for the collision.
;  - IX:	Pointer to #PLAM.
;  - IY:	Pointer to #PLA.
; Output:
;  - A: 	#PL_COL_RET_A_NO/#PL_COL_RET_A_YES
; Modifies: BC, DE
_CheckPlatformHitLeft

	; Check [#PLA.X_LEFT - #PLAM.X_LEFT + #_PL_HIT_MARGIN_D5] > [sprite X].
	LD DE, (IY + PLA.X_LEFT)
	LD BC, _PL_HIT_MARGIN_D5
	ADD DE, BC

	LD BC, (IX + PLAM.X_LEFT)
	SUB DE, BC									; DE contains [#PLA.X_LEFT - #PLAM.X_LEFT + #_PL_HIT_MARGIN_D5].

	; Load (HL) into HL (sprite X), as preparation for SBC.
	PUSH HL
	LD BC, (HL)
	LD HL, BC									; HL contains sprite X.

	SBC HL, DE									; if HL(sprite X) - DE < 0 then we have collision.
	POP HL
	JP M, .keepChecking
	
	LD A, PL_COL_RET_A_NO						; HL(sprite X) - DE > 0 -> No collision.
	RET
.keepChecking

	; ##########################################
	; Check [sprite X] > [#PLA.X_LEFT - #PLAM.X_LEFT].
	PUSH HL

	LD BC, (HL)									; BC contains sprite X.

	LD HL, (IY + PLA.X_LEFT)
	LD DE, (IX + PLAM.X_LEFT)
	SBC HL, DE									; HL contains [#PLA.X_LEFT - #PLAM.X_LEFT].

	SBC HL, BC									; Jump if HL - DE (sprite X) < 0.
	POP HL
	JP M, .hit

	LD A, PL_COL_RET_A_NO
	RET
.hit	
	LD A, PL_COL_RET_A_YES

	RET											; ## END of the function ##

;----------------------------------------------------------;
;               #_CheckPlatformHitRight                    ;
;----------------------------------------------------------;
; Check the collision with the left side of the platform.
; Collision when: [#PLA.X_RIGHT + PLAM.X_RIGHT] > [sprite X] > [#PLA.X_RIGHT + PLAM.X_RIGHT - #_PL_HIT_MARGIN_D5].
; Input:
;  - HL: 	Pointer to memory containing (X[WORD],Y[BYTE]) coordinates to check for the collision.
;  - IX:	Pointer to #PLAM.
;  - IY:	Pointer to #PLA.
; Output:
;  - A: 	#PL_COL_RET_A_NO/#PL_COL_RET_A_YES
; Modifies: BC, DE
_CheckPlatformHitRight

	; Check [#PLA.X_RIGHT + PLAM.X_RIGHT] > [sprite X].
	LD DE, (IY + PLA.X_RIGHT)
	LD BC, (IX + PLAM.X_RIGHT)
	ADD DE, BC									; DE contains [#PLA.X_RIGHT + #PLAM.X_RIGHT].

	; Load (HL) into HL (sprite X), as preparation for SBC.
	PUSH HL
	LD BC, (HL)
	LD HL, BC									; HL contains sprite X.

	SBC HL, DE									; if HL(sprite X) - DE < 0 then we have collision.
	POP HL
	JP M, .keepChecking
	
	LD A, PL_COL_RET_A_NO						; HL(sprite X) - DE > 0 -> No collision.
	RET
.keepChecking

	; ##########################################
	; Check [sprite X] > [#PLA.X_RIGHT  + PLAM.X_RIGHT- #_PL_HIT_MARGIN_D5].
	PUSH HL

	LD BC, (HL)									; BC contains sprite X.

	LD HL, (IY + PLA.X_RIGHT)
	LD DE, _PL_HIT_MARGIN_D5
	SBC HL, DE
	LD DE, (IX + PLAM.X_RIGHT)
	ADD HL, DE 									; HL contains [#PLA.X_RIGHT  + PLAM.X_RIGHT- #PLAM.X_RIGHT].

	SBC HL, BC									; Jump if HL - DE (sprite X) < 0.
	POP HL
	JP M, .hit

	LD A, PL_COL_RET_A_NO
	RET
.hit
	LD A, PL_COL_RET_A_YES

	RET											; ## END of the function ##

;----------------------------------------------------------;
;             #_CheckPlatformHitHorizontal                 ;
;----------------------------------------------------------;
; Jetman is within the platform's horizontal bounds when:
; [#PLA.X_RIGHT + PLAM.X_RIGHT] > [sprite X] > [#PLA.X_LEFT - #PLAM.X_LEFT].
; Input:
;  - HL: 	Pointer to memory containing (X[WORD],Y[BYTE]) coordinates to check for the collision. 
;  - IX:	Pointer to #PLAM.
;  - IY:	Pointer to #PLA.
; Output:
;  - A: 	#PL_COL_RET_A_NO/#PL_COL_RET_A_YES
; Modifies: BC, DE
_CheckPlatformHitHorizontal

	; Check [#PLA.X_RIGHT + PLAM.X_RIGHT] > [sprite X].
	LD DE, (IY + PLA.X_RIGHT)
	LD BC, (IX + PLAM.X_RIGHT)
	ADD DE, BC									; DE contains [#PLA.X_RIGHT + #PLAM.X_RIGHT].

	; Load (HL) into HL (sprite X), as preparation for SBC.
	PUSH HL
	LD BC, (HL)
	LD HL, BC									; HL contains sprite X.

	SBC HL, DE									; if HL(sprite X) - DE < 0 then we have collision.
	POP HL
	JP M, .keepChecking
	
	LD A, PL_COL_RET_A_NO						; HL(sprite X) - DE > 0 -> No collision.
	RET
.keepChecking

	; ##########################################
	; Check [sprite X] > [#PLA.X_LEFT - #PLAM.X_LEFT].
	PUSH HL

	LD BC, (HL)									; BC contains sprite X.

	LD HL, (IY + PLA.X_LEFT)
	LD DE, (IX + PLAM.X_LEFT)
	SBC HL, DE									; HL contains [#PLA.X_LEFT - #PLAM.X_LEFT].

	SBC HL, BC									; Jump if HL - DE (sprite X) < 0.
	POP HL
	JP M, .hit

	LD A, PL_COL_RET_A_NO
	RET
.hit
	LD A, PL_COL_RET_A_YES

	RET											; ## END of the function ##

;----------------------------------------------------------;
;               #_CheckPlatformHitVertical                 ;
;----------------------------------------------------------;
; Jetman is within the platform's vertical bounds when:
; [#PLA.Y_BOTTOM + PLAM.Y_BOTTOM] > [sprite Y] > [#PLA.Y_TOP - #PLAM.Y_TOP].
; Input:
;  - HL: 	Pointer to memory containing (X[WORD],Y[BYTE]) coordinates to check for the collision. 
;  - IX:	Pointer to #PLAM.
;  - IY:	Pointer to #PLA.
; Output:
;  - A: 	#PL_COL_RET_A_NO/#PL_COL_RET_A_YES
_CheckPlatformHitVertical

	; Check [#PLA.Y_BOTTOM + PLAM.Y_BOTTOM] > [sprite Y] > [sprite Y].
	LD A, (IY + PLA.Y_BOTTOM)
	ADD (IX + PLAM.Y_BOTTOM)
	LD C, A										; C holds [#PLA.Y_BOTTOM + PLAM.Y_BOTTOM].

	CALL _LoadSpriteYtoA							; A holds current sprite Y position.

	CP C
	JR C, .keepChecking							; Jump if A (sprite Y) < C.
	
	LD A, PL_COL_RET_A_NO						;  A (sprite Y) > C -> no collision.
	RET
	
.keepChecking

	; ##########################################
	; Check [sprite Y] > [#PLA.Y_TOP - #PLAM.Y_TOP].

	LD A, (IY + PLA.Y_TOP)
	SUB (IX + PLAM.Y_TOP)
	LD C, A										; C holds [#PLA.Y_TOP - #PLAM.Y_TOP].

	CALL _LoadSpriteYtoA							; A holds current sprite Y position.

	CP C
	JR NC, .hit									; Jump if A (sprite Y) >= C.
	
	LD A, PL_COL_RET_A_NO
	RET
.hit
	LD A, PL_COL_RET_A_YES

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                 #_PlatformSpriteHit                      ;
;----------------------------------------------------------;
; Check whether the sprite (#SPR) one of the platforms.
; Input:
;  - IX: 	Pointer to #SPR, single sprite to check collision for.
;  - IY:	Pointer to #PLAM.
; Output:
;  - A: 	#PL_HIT_RET_A_YES/ #PL_HIT_RET_A_NO
_PlatformSpriteHit

	; Exit if sprite is not alive.
	BIT sr.SPRITE_ST_ACTIVE_BIT, (IX + sr.SPR.STATE)	
	JR NZ, .alive								; Jump if sprite is alive.

	LD A, PL_HIT_RET_A_NO
	RET
.alive

	PUSH IX

	; Params for _PlatformHit.
	LD HL, IX
	ADD	HL, sr.SPR.X

	LD IX, IY
	LD IY, platforms

	LD A, (platformsSize)
	LD B, A

	CALL _PlatformHit

	POP IX

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #_JetHitsPlatform                       ;
;----------------------------------------------------------;
_JetHitsPlatform

	LD A, js.SDB_T_KF							; Play animation.
	CALL js.ChangeJetSpritePattern
	
	; Disable joystick, because Jetman looses control for a few frames.
	LD A, (joyOffBump)
	LD (gid.joyOffCnt), A

	; ##########################################
	; Decrement joystick off time with every bump.
	
	CP _C_PL_BUMP_JOY_DEC_D1+1
	RET C										; Do not allow #joyOffBump to reach 0, otherwise Jetman will go trough the obstacle.
	
	SUB _C_PL_BUMP_JOY_DEC_D1
	LD (joyOffBump), A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE