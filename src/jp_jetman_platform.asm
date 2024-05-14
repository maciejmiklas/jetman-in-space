;----------------------------------------------------------;
;                    Platforms and Ground                  ;
;----------------------------------------------------------;

; Coordinates for walking on a platform
; [amount of plaftorms], [[Y], [X start], [X end]],...]
platformWalk DB 3, 094,012,065, 142,075,136, 054,190,240

; [amount of plaftorms], [[X platform start],[X platform end],[Y platform start],[Y platform end]], ...]
platformBump DB 3, 009,070,093,120, 073,142,141,169, 187,245,054,079

;----------------------------------------------------------;
;                #BumpOnJoystickDisabled                   ;
;----------------------------------------------------------;
BumpOnJoystickDisabled

	; Is Jetman falling from the platform on the right side?
	LD A, (jd.jetmanAir)
	CP jd.AIR_FALL_RIGHT
	JR NZ, .afterFallingRight

	; Yes, Jetman is falling from the platform
	LD A, (jd.jetmanX)
	INC A
	LD (jd.jetmanX), A

	LD A, (jd.jetmanY)
	INC A
	INC A
	LD (jd.jetmanY), A

	JR .afterBumping							; Do not check falling left or bumping because Jetman is already falling
.afterFallingRight	

	; Is Jetman falling from the platform on the left side?
	LD A, (jd.jetmanAir)
	CP jd.AIR_FALL_LEFT
	JR NZ, .afterFallingLeft

	; Yes, Jetman is falling from the platform
	LD A, (jd.jetmanX)
	DEC A
	LD (jd.jetmanX), A

	LD A, (jd.jetmanY)
	INC A
	INC A
	LD (jd.jetmanY), A
	JR .afterBumping							; Do not check for bumping, as Jetman is falling
.afterFallingLeft	

	; Is Jetman bumping into the platform from the right?
	LD A, (jd.jetmanAir)
	CP jd.AIR_BUMP_RIGHT
	JR NZ, .afterBumpingRight

	; Yes
	CALL jt.IncJetX
	JR .afterBumping							; Do not check bumping left
.afterBumpingRight

	; Is Jetman bumping into the platform from the left?
	LD A, (jd.jetmanAir)
	CP jd.AIR_BUMP_LEFT
	JR NZ, .afterBumpingLeft

	; Yes
	CALL jt.DecJetX	
	JR .afterBumping
.afterBumpingLeft

	; Or finally, maybe Jetmat hits the platform from the bottom?
	LD A, (jd.jetmanAir)
	CP jd.AIR_BUMP_BOTTOM
	JR NZ, .afterBumping

	; Yes
	LD A, (jd.jetmanY)	
	INC A
	LD (jd.jetmanY), A
	JR .afterBumping

.afterBumping

	RET	
;----------------------------------------------------------;
;                    #JetmanTakesoff                       ;
;----------------------------------------------------------;
JetmanTakesoff

	; Transition from walking to flaying
	LD A, (jd.jetmanGnd)
	CP jd.GND_INACTIVE							; Check if Jetnan is on the ground/platform
	RET Z

	; Jetman is taking off - set #jetmanAir and reset #jetmanGnd
	LD A, jd.AIR_FLY
	LD (jd.jetmanAir), A

	LD A, jd.GND_INACTIVE
	LD (jd.jetmanGnd), A

	; Play takeoff animation					
	LD A, js.SDB_T_WF
	CALL js.ChangeJetmanSpritePattern
	RET											; END #JetmanTakesoff

;----------------------------------------------------------;
;                     #JetmanLanding                       ;
;----------------------------------------------------------;
JetmanLanding

	; Jemans is landing, trigger transition: flying -> standing/walking
	LD A, (jd.joyDirection)
	AND jd.MOVE_MSK_LR
	CP 1	
	JR C, .afterMoveLR							; Jump, if there is no movement right/left (A >= 1) -> Jemtan lands and stands still
	
	; Jetman moves left/right
	LD A, jd.GND_WALK							; Update #jetmanGnd as we are walking		
	LD (jd.jetmanGnd), A	

	LD A, js.SDB_T_FW							; Play transition from landing -> walking	
	CALL js.ChangeJetmanSpritePattern

	JR .afterStand								; The animation is already loaded, do not overweigh it with standing
.afterMoveLR	

	LD A, jd.GND_STAND							; Update #jetmanGnd as we are standing		
	LD (jd.jetmanGnd), A	

	LD A, js.SDB_T_FS							; Play transition from landing -> standing
	CALL js.ChangeJetmanSpritePattern
.afterStand

	; Reset #jetmanAir as we are walking
	LD A, jd.AIR_INACTIVE						
	LD (jd.jetmanAir), A

	RET

;----------------------------------------------------------;
;                  #LandingOnPlatform                      ;
;----------------------------------------------------------;
; Is Jetman landing on one of the platforms?
LandingOnPlatform
	LD A, (jd.jetmanAir)
	CP jd.AIR_INACTIVE							; Is Jemtan in the air?
	RET Z										; Return if not flaying, no flying - no landing ;)

	LD HL, platformWalk
	LD B, (HL)									; Load into B the number of platforms to check
.platformsLoop	
	INC HL										; HL points to [Y]
	LD C, (HL)									; C contains [Y]

	INC HL										; HL points to [X start]
	LD D, (HL)									; D contains [X start]	

	INC HL										; HL points to [X end]
	LD E, (HL)									; E contains [X end]		
	
	LD A, (jd.jetmanY)							; A holds current Y position
	CP C
	JR NZ, .platformsLoopEnd					; Jump if Jetman is on a different level than the current platform

	; Jetman is on Y of the current platform, now check X
	LD A, (jd.jetmanX)									; A holds current X position
	CP D										; Compare #jetmanX position to [X start]
	JR C, .platformsLoopEnd						; Jump if #jetmanX < [X start]

	; Jetman is on the current platform level after it's begun, we have to check if he is not too far to the right
	CP E
	JR NC, .platformsLoopEnd					; Jump if #jetmanX > [X end]

	; Jetman is landing on the platform!
	CALL JetmanLanding
	RET

.platformsLoopEnd
	DJNZ .platformsLoop							; Decrease B until all platforms have been evaluated
	RET

;----------------------------------------------------------;
;                #BumpIntoPlatFormBelow                    ;
;----------------------------------------------------------;
BumpIntoPlatFormBelow

	LD A, (jd.jetmanAir)
	CP jd.AIR_INACTIVE							; Is Jemtan in the air?
	RET Z										; Return if not flaying, no flying - no collision ;)

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

	LD A, (jd.jetmanY)							; A holds current Y position
	CP C
	JR NZ, .platformsLoopEnd					; Jump if Jetman is not precisely on the bottom level of the platform -> [Y] != #jetmanY

	; Jetman is on the bottom of the platform, now check whether he is withing its horizonlat bounds
	LD A, (jd.jetmanX)									; A holds current X position

	CP D										; Compare #jetmanX position to [X start]
	JR C, .platformsLoopEnd						; Jump if #jetmanX < [X start]

	CP E
	JR NC, .platformsLoopEnd					; Jump if #jetmanX > [X end]

	; Jetman hits the platform!
	LD A, jd.AIR_BUMP_BOTTOM					; Change air state
	LD (jd.jetmanAir), A

	PUSH BC

	LD A, js.SDB_T_WL							; Play animation
	CALL js.ChangeJetmanSpritePattern
	
	; Disable joystick, because Jetman looses control for a few frames
	LD A, jd.JOY_DISABLED_BUMP						
	LD (jd.joyDisabledCnt), A

	POP BC
.platformsLoopEnd
	DJNZ .platformsLoop							; Decrease B until all platforms have been evaluated
	RET

;----------------------------------------------------------;
;                  #BumpIntoPlatformLR                     ;
;----------------------------------------------------------;
; Bump into a platform from left or right
; Input
;  - H:		jd.AIR_BUMP_LEFT or jd.AIR_BUMP_RIGHT
BumpIntoPlatformLR
	LD A, (jd.jetmanAir)
	CP jd.AIR_INACTIVE							; Is Jemtan in the air?
	RET Z										; Return if not flaying, no flying - no collision ;)

	LD IX, platformBump
	LD B, (IX)									; Load into B the number of platforms to check
.platformsLoop	

	; Check whether we should consider the left or right side of the platform.
	LD A, H										; A holds AIR_BUMP_LEFT or AIR_BUMP_RIGHT
	CP jd.AIR_BUMP_LEFT
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

	LD A, (jd.jetmanX)							; A holds current X position
	CP C
	JR NZ, .platformsLoopEnd					; Jump if Jetman is not close to the left/right edge of the platform

	; Jetman is close to the left/right edge of the platform
	LD A, (jd.jetmanY)							; A holds current Y position
	CP D										; Compare #jetmanY position to [Y start]
	JR C, .platformsLoopEnd						; Jump if #jetmanY < [Y start]

	CP E
	JR NC, .platformsLoopEnd					; Jump if #jetmanY > [Y end]

	; Jetman hits the platform from the left/right!
	LD A, H										; Change air state, H is a method param
	LD (jd.jetmanAir), A

	PUSH BC

	LD A, js.SDB_T_WL							; Play animation
	CALL js.ChangeJetmanSpritePattern
	
	; Disable joystick, because Jetman looses control for a few frames
	LD A, jd.JOY_DISABLED_BUMP						
	LD (jd.joyDisabledCnt), A

	POP BC
.platformsLoopEnd
	DJNZ .platformsLoop							; Decrease B until all platforms have been evaluated
	RET
;----------------------------------------------------------;
;                  #FallingFromPlatform                    ;
;----------------------------------------------------------;
; Jetman walks to the edge of the platform and falls 
FallingFromPlatform
	LD A, (jd.jetmanGnd)
	CP jd.GND_WALK								; Is Jemtan in the air?
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

	LD A, (jd.jetmanY)							; A holds current Y position
	CP C
	JR NZ, .platformsLoopEnd					; Jump if Jetman is on a different level than the current platform

	; Jetman is on Y of the current platform, now check X
	LD A, (jd.jetmanX)							; A holds current X position
	CP D										; Compare #jetmanX position to [X start]
	JR C, .fallingLeft							; Jump if #jetmanX < [X start], meaning Jetman is falling from the left side of the platform

	CP E
	JR NC, .fallingRight						; Jump if #jetmanX > [X end], meaning Jetman is falling from the right side of the platform

.platformsLoopEnd
	DJNZ .platformsLoop							; Decrease B until all platforms have been evaluated
	JR .afterFalling							; Jetman is still on the platform

; Jetman is falling from the platform, left or right
.fallingLeft									
	LD A, jd.AIR_FALL_LEFT						
	LD (jd.jetmanAir), A
	JR .afterFallingRight

.fallingRight
	LD A, jd.AIR_FALL_RIGHT
	LD (jd.jetmanAir), A

.afterFallingRight
	; Trigger transition: walking -> falling
	LD A, js.SDB_T_WL
	CALL js.ChangeJetmanSpritePattern

	; Disable joystick, because Jetman loses control for #JOY_DISABLED_FALL frames
	LD A, jd.JOY_DISABLED_FALL						
	LD (jd.joyDisabledCnt), A
	
	; Reset #jetmanGnd as we are not walking anymore
	LD A, jd.GND_INACTIVE						
	LD (jd.jetmanGnd), A	

.afterFalling
	RET
