
; Coordinates for walking on a platform
; [amount of plaftorms], [[Y], [X start], [X end]],...]
platformWalk DB 3, 94,12,65, 142,83,136, 54,190,240

; Coordinates for bumping right into a platform
; [amount of plaftorms], [[X], [Y start], [Y end]],...]
platformBumpRight DB 3, 70,93,119, 140,142,164 ,245,54,76

; Coordinates for bumping right into a platform
; [amount of plaftorms], [[X], [Y start], [Y end]],...]
platformBumpLeft DB 3, 9,93,119, 71,142,164 ,181,54,76

; Coordinates for bumping into the platform from below
; [amount of plaftorms], [[Y], [X start], [X end]],...]
platformBumpBottom DB 3, 119,12,65, 167,83,136, 80,190,240

;----------------------------------------------------------;
;                 #BumpOnJoystickDisabled                  ;
;----------------------------------------------------------;
BumpOnJoystickDisabled

	; Is Jetman falling from the platform on the right side?
	LD A, (jetAir)
	CP JET_AIR_FALL_RIGHT
	JR NZ, .afterFallingRight

	; Yes, Jetman is falling from the platform
	LD A, (jetX)
	INC A
	LD (jetX), A

	LD A, (jetY)
	INC A
	INC A
	LD (jetY), A

	JR .afterBumping							; Do not check falling left or bumping because Jetman is already falling
.afterFallingRight	

	; Is Jetman falling from the platform on the left side?
	LD A, (jetAir)
	CP JET_AIR_FALL_LEFT
	JR NZ, .afterFallingLeft

	; Yes, Jetman is falling from the platform
	LD A, (jetX)
	DEC A
	LD (jetX), A

	LD A, (jetY)
	INC A
	INC A
	LD (jetY), A
	JR .afterBumping							; Do not check for bumping, as Jetman is falling
.afterFallingLeft	

	; Is Jetman bumping into the platform from the right?
	LD A, (jetAir)
	CP JET_AIR_BUMP_RIGHT
	JR NZ, .afterBumpingRight

	; Yes
	CALL incJetX
	JR .afterBumping							; Do not check bumping left
.afterBumpingRight

	; Is Jetman bumping into the platform from the left?
	LD A, (jetAir)
	CP JET_AIR_BUMP_LEFT
	JR NZ, .afterBumpingLeft

	; Yes
	CALL decJetX	
	JR .afterBumping
.afterBumpingLeft

	; Or finally, maybe Jetmat hits the platform from the bottom?
	LD A, (jetAir)
	CP JET_AIR_BUMP_BOTTOM
	JR NZ, .afterBumping

	; Yes
	LD A, (jetY)	
	INC A
	LD (jetY), A
	JR .afterBumping

.afterBumping

	RET												; END #JoystickDisabled	
;----------------------------------------------------------;
;                    #JetmanTakesoff                       ;
;----------------------------------------------------------;
JetmanTakesoff
	; Jetman is taking off - set #jetAir and reset #jetGnd
	LD A, JET_AIR_FLY
	LD (jetAir), A

	LD A, JET_GND_INACTIVE
	LD (jetGnd), A

	; Play takeoff animation					
	LD A, JET_SDB_T_WF
	CALL ChangeJetmanSpritePattern
	RET											; END #JetmanTakesoff

;----------------------------------------------------------;
;                     #JetmanLanding                       ;
;----------------------------------------------------------;
JetmanLanding

	; Jemans is landing, trigger transition: falying -> standing/walking
	LD A, (jetMove)
	AND JET_MOVE_MSK_LR
	CP 1	
	JR C, .afterMoveLR							; Jump, if there is no movement right/left (A >= 1) -> Jemtan lands and stands still
	
	; Jetman moves left/right
	LD A, JET_GND_WALK							; Update #jetGnd as we are walking		
	LD (jetGnd), A	

	LD A, JET_SDB_T_FW							; Play transition from landing -> walking	
	CALL ChangeJetmanSpritePattern

	JR .afterStand								; The animation is already loaded, do not overweigh it with standing
.afterMoveLR	

	LD A, JET_GND_STAND							; Update #jetGnd as we are standing		
	LD (jetGnd), A	

	LD A, JET_SDB_T_FS							; Play transition from landing -> standing
	CALL ChangeJetmanSpritePattern
.afterStand

	; Reset #jetAir as we are walking
	LD A, JET_AIR_INACTIVE						
	LD (jetAir), A

	RET											; END JetmanLanding	

;----------------------------------------------------------;
;                  #LandingOnPlatform                      ;
;----------------------------------------------------------;
; Is Jetman landing on one of the platforms?
LandingOnPlatform
	LD A, (jetAir)
	CP JET_AIR_INACTIVE							; Is Jemtan in the air?
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
	
	LD A, (jetY)								; A holds current Y position
	CP C
	JR NZ, .platformsLoopEnd					; Jump if Jetman is on a different level than the current platform

	; Jetman is on Y of the current platform, now check X
	LD A, (jetX)								; A holds current X position
	CP D										; Compare #jetX postion to [X start]
	JR C, .platformsLoopEnd						; Jump if #jetX < [X start]

	; Jetman is on the current platform level after it's begun, we have to check if he is not too far to the right
	CP E
	JR NC, .platformsLoopEnd					; Jump if #jetX > [X end]

	; Jetman is landing on the platform!
	CALL JetmanLanding
	RET

.platformsLoopEnd
	DJNZ .platformsLoop							; Decrease B until all platforms have been evaluated
	RET											; END LandingOnPlatform

;----------------------------------------------------------;
;               #BumpIntoPlatformBottom                    ;
;----------------------------------------------------------;
BumpIntoPlatformBottom

	LD A, (jetAir)
	CP JET_AIR_INACTIVE							; Is Jemtan in the air?
	RET Z										; Return if not flaying, no flying - no colision ;)

	LD HL, platformBumpBottom
	LD B, (HL)									; Load into B the number of platforms to check
.platformsLoop	
	INC HL										; HL points to [Y]
	LD C, (HL)									; C contains [Y]

	INC HL										; HL points to [X start]
	LD D, (HL)									; D contains [X start]	

	INC HL										; HL points to [Y end]
	LD E, (HL)									; E contains [Y end]

	LD A, (jetY)								; A holds current Y position
	CP C
	JR NZ, .platformsLoopEnd					; Jump if Jetman is not close to the bottom of the platform

	; Jetman is close to the bottom of the platform
	LD A, (jetX)								; A holds current X position
	CP D										; Compare #jetX postion to [X start]
	JR C, .platformsLoopEnd						; Jump if #jetX < [X start]

	CP E
	JR NC, .platformsLoopEnd					; Jump if #jetX > [X end]

	; Jetman hits the platform!
	LD A, JET_AIR_BUMP_BOTTOM					; Change air state
	LD (jetAir), A

	PUSH BC

	LD A, JET_SDB_T_WL							; Play animation
	CALL ChangeJetmanSpritePattern
	
	; Disable joystick, because Jetman looses control for a few frames
	LD A, JOY_DISABLE_BUMP						
	LD (joystickDisabledCnt), A

	POP BC
.platformsLoopEnd
	DJNZ .platformsLoop							; Decrease B until all platforms have been evaluated
	RET											; END #BumpIntoPlatformLR

;----------------------------------------------------------;
;                  #BumpIntoPlatformLR                     ;
;----------------------------------------------------------;
; Input
;  - IX:	platformBumpLeft or platformBumpRight
;  - H: 	JET_AIR_BUMP_LEFT or JET_AIR_BUMP_RIGHT
BumpIntoPlatformLR
	LD A, (jetAir)
	CP JET_AIR_INACTIVE							; Is Jemtan in the air?
	RET Z										; Return if not flaying, no flying - no colision ;)

	LD B, (IX)									; Load into B the number of platforms to check
.platformsLoop	
	INC IX										; HL points to [X]
	LD C, (IX)									; C contains [X]

	INC IX										; HL points to [Y start]
	LD D, (IX)									; D contains [Y start]	

	INC IX										; HL points to [Y end]
	LD E, (IX)									; E contains [Y end]

	LD A, (jetX)								; A holds current X position
	CP C
	JR NZ, .platformsLoopEnd					; Jump if Jetman is not close to the right edge of the platform

	; Jetman is close to the right edge of the platform
	LD A, (jetY)								; A holds current Y position
	CP D										; Compare #jetY postion to [Y start]
	JR C, .platformsLoopEnd						; Jump if #jetY < [Y start]

	CP E
	JR NC, .platformsLoopEnd					; Jump if #jetY > [Y end]

	; Jetman hits the platform from the right!
	LD A, H										; Change air state, H is a method param
	LD (jetAir), A

	PUSH BC

	LD A, JET_SDB_T_WL							; Play animation
	CALL ChangeJetmanSpritePattern
	
	; Disable joystick, because Jetman looses control for a few frames
	LD A, JOY_DISABLE_BUMP						
	LD (joystickDisabledCnt), A

	POP BC
.platformsLoopEnd
	DJNZ .platformsLoop							; Decrease B until all platforms have been evaluated
	RET											; END #BumpIntoPlatformLR

;----------------------------------------------------------;
;                  #FallingFromPlatform                    ;
;----------------------------------------------------------;
; Jetman walks to the edge of the platform and falls 
FallingFromPlatform
	LD A, (jetGnd)
	CP JET_GND_WALK								; Is Jemtan in the air?
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

	LD A, (jetY)								; A holds current Y position
	CP C
	JR NZ, .platformsLoopEnd					; Jump if Jetman is on a different level than the current platform

	; Jetman is on Y of the current platform, now check X
	LD A, (jetX)								; A holds current X position
	CP D										; Compare #jetX postion to [X start]
	JR C, .fallingLeft							; Jump if #jetX < [X start], meaning Jetman is falling from the left side of the platform

	CP E
	JR NC, .fallingRight						; Jump if #jetX > [X end], meaning Jetman is falling from the right side of the platform

.platformsLoopEnd
	DJNZ .platformsLoop							; Decrease B until all platforms have been evaluated
	JR .afterFalling							; Jetman is still on the platform

; Jetman is falling from the platform, left or right
.fallingLeft									
	LD A, JET_AIR_FALL_LEFT						
	LD (jetAir), A
	JR .afterFallingRight

.fallingRight
	LD A, JET_AIR_FALL_RIGHT						
	LD (jetAir), A

.afterFallingRight
	; Trigger ransition: walking -> falling
	LD A, JET_SDB_T_WL
	CALL ChangeJetmanSpritePattern

	; Disable joystick, because Jetman looses control for #JOY_DISABLE_FALL frames
	LD A, JOY_DISABLE_FALL						
	LD (joystickDisabledCnt), A
	
	; Reset #jetGnd as we are not walking anymore
	LD A, JET_GND_INACTIVE						
	LD (jetGnd), A	

.afterFalling
	RET											; END FallingFromPlatform
