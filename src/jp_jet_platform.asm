;----------------------------------------------------------;
;                    Platforms and Ground                  ;
;----------------------------------------------------------;
	MODULE jp

JOY_DISABLED_FALL		= 6						; Disable the joystick for a few frames because Jetman is falling from the platform
JOY_DISABLED_BUMP		= 6						; Disable the joystick for a few frames because Jetman is bumping into the platform

; Coordinates for walking on a platform
; [amount of plaftorms], [[Y], [X start], [X end]],...]
platformWalk DB 3, 094,012,065, 142,075,136, 054,190,240

; [amount of plaftorms], [[X platform start],[X platform end],[Y platform start],[Y platform end]], ...]
platformBump DB 3, 009,070,093,120, 073,142,141,169, 187,245,054,079

;----------------------------------------------------------;
;              #AnimateOnJoystickDisabled                  ;
;----------------------------------------------------------;
AnimateOnJoystickDisabled

	; Is Jetman falling from the platform on the right side?
	LD A, (jt.jetAir)
	CP jt.AIR_FALL_RIGHT
	JR NZ, .afterFallingRight

	; Yes, Jetman is falling from the platform
	LD A, (jp.jetmanX)
	INC A
	LD (jp.jetmanX), A

	LD A, (jp.jetmanY)
	INC A
	INC A
	LD (jp.jetmanY), A

	JR .afterAnimate							; Do not check falling left or bumping because Jetman is already falling
.afterFallingRight	

	; Is Jetman falling from the platform on the left side?
	LD A, (jt.jetAir)
	CP jt.AIR_FALL_LEFT
	JR NZ, .afterFallingLeft

	; Yes, Jetman is falling from the platform
	LD A, (jp.jetmanX)
	DEC A
	LD (jp.jetmanX), A

	LD A, (jp.jetmanY)
	INC A
	INC A
	LD (jp.jetmanY), A
	JR .afterAnimate							; Do not check for bumping, as Jetman is falling
.afterFallingLeft	

	; Is Jetman bumping into the platform from the right?
	LD A, (jt.jetAir)
	CP jt.AIR_BUMP_RIGHT
	JR NZ, .afterBumpingRight

	; Yes
	CALL jp.IncJetX
	JR .afterAnimate							; Do not check bumping left
.afterBumpingRight

	; Is Jetman bumping into the platform from the left?
	LD A, (jt.jetAir)
	CP jt.AIR_BUMP_LEFT
	JR NZ, .afterBumpingLeft

	; Yes
	CALL jp.DecJetX	
	JR .afterAnimate
.afterBumpingLeft

	; Or finally, maybe Jetmat hits the platform from the bottom?
	LD A, (jt.jetAir)
	CP jt.AIR_BUMP_BOTTOM
	JR NZ, .afterAnimate

	; Yes
	LD A, (jp.jetmanY)	
	INC A
	LD (jp.jetmanY), A
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
	LD BC, (jp.jetmanX)
	LD A, B										; #jetmanX has 16bit, load MSB into A to see if its > 0 (jetmanX >= 257)
	CP 0
	RET NZ										; Return if Jetman is after 257 on X
	
	LD HL, platformWalk
	LD B, (HL)									; Load into B the number of platforms to check
.platformsLoop	
	INC HL										; HL points to [Y]
	LD C, (HL)									; C contains [Y]

	INC HL										; HL points to [X start]
	LD D, (HL)									; D contains [X start]	

	INC HL										; HL points to [X end]
	LD E, (HL)									; E contains [X end]		
	
	LD A, (jp.jetmanY)							; A holds current Y position
	CP C
	JR NZ, .platformsLoopEnd					; Jump if Jetman is on a different level than the current platform

	; Jetman is on Y of the current platform, now check X
	LD A, (jp.jetmanX)									; A holds current X position
	CP D										; Compare #jetmanX position to [X start]
	JR C, .platformsLoopEnd						; Jump if #jetmanX < [X start]

	; Jetman is on the current platform level after it's begun, we have to check if he is not too far to the right
	CP E
	JR NC, .platformsLoopEnd					; Jump if #jetmanX > [X end]

	; Jetman is landing on the platform!
	CALL JetLanding
	RET

.platformsLoopEnd
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
	LD BC, (jp.jetmanX)
	LD A, B										; #jetmanX has 16bit, load MSB into A to see if its > 0 (jetmanX >= 257)
	CP 0
	RET NZ										; Return if Jetman is after 257 on X

	LD HL, platformBump
	LD B, (HL)									; Load into B the number of platforms to check
.platformsLoop	
	INC HL										; HL points to [X start]
	LD D, (HL)									; D contains [X start]	

	INC HL										; HL points to [Y end]
	LD E, (HL)									; E contains [Y end]

	INC HL										; HL points to [Y start]
	INC HL										; HL points to [Y end]
	LD C, (HL)									; C contains [Y end]

	LD A, (jp.jetmanY)							; A holds current Y position
	CP C
	JR NZ, .platformsLoopEnd					; Jump if Jetman is not precisely on the bottom level of the platform -> [Y] != #jetmanY

	; Jetman is on the bottom of the platform, now check whether he is withing its horizonlat bounds
	LD A, (jp.jetmanX)							; A holds current X position

	CP D										; Compare #jetmanX position to [X start]
	JR C, .platformsLoopEnd						; Jump if #jetmanX < [X start]

	CP E
	JR NC, .platformsLoopEnd					; Jump if #jetmanX > [X end]

	; Jetman hits the platform!
	LD A, jt.AIR_BUMP_BOTTOM					; Change air state
	LD (jt.jetAir), A
	
	PUSH BC

	LD A, js.SDB_T_WL							; Play animation
	CALL js.ChangeJetSpritePattern
	
	; Disable joystick, because Jetman looses control for a few frames
	LD A, JOY_DISABLED_BUMP						
	LD (id.joyDisabledCnt), A

	POP BC
.platformsLoopEnd
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
	LD BC, (jp.jetmanX)
	LD A, B										; #jetmanX has 16bit, load MSB into A to see if its > 0 (jetmanX >= 257)
	CP 0
	RET NZ										; Return if Jetman is after 257 on X
	
	LD IX, platformBump
	LD B, (IX)									; Load into B the number of platforms to check
.platformsLoop	

	; Check whether we should consider the left or right side of the platform.
	LD A, H										; A holds AIR_BUMP_LEFT or AIR_BUMP_RIGHT
	CP jt.AIR_BUMP_LEFT
	JR Z, .bumpLeft

	; We will check whether Jetman bumps into the platform from the right
	INC IX										; HL points to [X start]
	INC IX										; HL points to [X end]
	LD C, (IX)									; C contains [X end]
	JR .afterBumpSideCheck
.bumpLeft	
	; We will check whether Jetman bumps into the platform from the left
	INC IX										; HL points to [X start]
	LD C, (IX)									; C contains [X start]
	INC IX										; Moving the pointer to the correct position for further reading
.afterBumpSideCheck

	INC IX										; HL points to [Y start]
	LD D, (IX)									; D contains [Y start]	

	INC IX										; HL points to [Y end]
	LD E, (IX)									; E contains [Y end]

	LD A, (jp.jetmanX)							; A holds current X position
	CP C
	JR NZ, .platformsLoopEnd					; Jump if Jetman is not close to the left/right edge of the platform

	; Jetman is close to the left/right edge of the platform
	LD A, (jp.jetmanY)							; A holds current Y position
	CP D										; Compare #jetmanY position to [Y start]
	JR C, .platformsLoopEnd						; Jump if #jetmanY < [Y start]

	CP E
	JR NC, .platformsLoopEnd					; Jump if #jetmanY > [Y end]

	; Jetman hits the platform from the left/right!
	LD A, H										; Change air state, H is a method param
	LD (jt.jetAir), A

	PUSH BC

	LD A, js.SDB_T_WL							; Play animation
	CALL js.ChangeJetSpritePattern
	
	; Disable joystick, because Jetman looses control for a few frames
	LD A, JOY_DISABLED_BUMP						
	LD (id.joyDisabledCnt), A

	POP BC
.platformsLoopEnd
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

	LD HL, platformWalk							
	LD B, (HL)									; Load into B the number of platforms to check
.platformsLoop	
	INC HL										; HL points to [Y]
	LD C, (HL)									; C contains [Y]

	INC HL										; HL points to [X start]
	LD D, (HL)									; D contains [X start]

	INC HL										; HL points to [X end]
	LD E, (HL)									; E contains [X end]

	LD A, (jp.jetmanY)							; A holds current Y position
	CP C
	JR NZ, .platformsLoopEnd					; Jump if Jetman is on a different level than the current platform

	; Jetman is on Y of the current platform, now check X
	LD A, (jp.jetmanX)							; A holds current X position
	CP D										; Compare #jetmanX position to [X start]
	JR C, .fallingLeft							; Jump if #jetmanX < [X start], meaning Jetman is falling from the left side of the platform

	CP E
	JR NC, .fallingRight						; Jump if #jetmanX > [X end], meaning Jetman is falling from the right side of the platform

.platformsLoopEnd
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
	LD A, js.SDB_T_WL
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