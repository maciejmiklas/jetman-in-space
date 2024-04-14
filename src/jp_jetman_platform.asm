;----------------------------------------------------------;
;                    Platforms and Ground                  ;
;----------------------------------------------------------;

; Coordinates for walking on a platform
; [amount of plaftorms], [[Y], [X start], [X end]],...]
jpPlatformWalk DB 3, 94,12,65, 142,83,136, 54,190,240

; Coordinates for bumping right into a platform
; [amount of plaftorms], [[X], [Y start], [Y end]],...]
jpPlatformBumpRight DB 3, 70,93,119, 140,142,164 ,245,54,76

; Coordinates for bumping right into a platform
; [amount of plaftorms], [[X], [Y start], [Y end]],...]
jpPlatformBumpLeft DB 3, 9,93,119, 71,142,164 ,181,54,76

; Coordinates for bumping into the platform from below
; [amount of plaftorms], [[Y], [X start], [X end]],...]
jpPlatformBumpBottom DB 3, 119,12,65, 167,83,136, 80,190,240

;----------------------------------------------------------;
;               #JpBumpOnJoystickDisabled                  ;
;----------------------------------------------------------;
JpBumpOnJoystickDisabled

	; Is Jetman falling from the platform on the right side?
	LD A, (jtAir)
	CP JT_AIR_FALL_RIGHT
	JR NZ, .afterFallingRight

	; Yes, Jetman is falling from the platform
	LD A, (jtX)
	INC A
	LD (jtX), A

	LD A, (jtY)
	INC A
	INC A
	LD (jtY), A

	JR .afterBumping							; Do not check falling left or bumping because Jetman is already falling
.afterFallingRight	

	; Is Jetman falling from the platform on the left side?
	LD A, (jtAir)
	CP JT_AIR_FALL_LEFT
	JR NZ, .afterFallingLeft

	; Yes, Jetman is falling from the platform
	LD A, (jtX)
	DEC A
	LD (jtX), A

	LD A, (jtY)
	INC A
	INC A
	LD (jtY), A
	JR .afterBumping							; Do not check for bumping, as Jetman is falling
.afterFallingLeft	

	; Is Jetman bumping into the platform from the right?
	LD A, (jtAir)
	CP JT_AIR_BUMP_RIGHT
	JR NZ, .afterBumpingRight

	; Yes
	CALL JtIncJetX
	JR .afterBumping							; Do not check bumping left
.afterBumpingRight

	; Is Jetman bumping into the platform from the left?
	LD A, (jtAir)
	CP JT_AIR_BUMP_LEFT
	JR NZ, .afterBumpingLeft

	; Yes
	CALL JtDecJetX	
	JR .afterBumping
.afterBumpingLeft

	; Or finally, maybe Jetmat hits the platform from the bottom?
	LD A, (jtAir)
	CP JT_AIR_BUMP_BOTTOM
	JR NZ, .afterBumping

	; Yes
	LD A, (jtY)	
	INC A
	LD (jtY), A
	JR .afterBumping

.afterBumping

	RET											; END #JpBumpOnJoystickDisabled	
;----------------------------------------------------------;
;                   #JpJetmanTakesoff                      ;
;----------------------------------------------------------;
JpJetmanTakesoff
	; Jetman is taking off - set #jtAir and reset #jtGnd
	LD A, JT_AIR_FLY
	LD (jtAir), A

	LD A, JT_GND_INACTIVE
	LD (jtGnd), A

	; Play takeoff animation					
	LD A, JS_SDB_T_WF
	CALL JsChangeJetmanSpritePattern
	RET											; END #JpJetmanTakesoff

;----------------------------------------------------------;
;                    #JpJetmanLanding                      ;
;----------------------------------------------------------;
JpJetmanLanding

	; Jemans is landing, trigger transition: falying -> standing/walking
	LD A, (jtMove)
	AND JT_MOVE_MSK_LR
	CP 1	
	JR C, .afterMoveLR							; Jump, if there is no movement right/left (A >= 1) -> Jemtan lands and stands still
	
	; Jetman moves left/right
	LD A, JT_GND_WALK							; Update #jtGnd as we are walking		
	LD (jtGnd), A	

	LD A, JS_SDB_T_FW							; Play transition from landing -> walking	
	CALL JsChangeJetmanSpritePattern

	JR .afterStand								; The animation is already loaded, do not overweigh it with standing
.afterMoveLR	

	LD A, JT_GND_STAND							; Update #jtGnd as we are standing		
	LD (jtGnd), A	

	LD A, JS_SDB_T_FS							; Play transition from landing -> standing
	CALL JsChangeJetmanSpritePattern
.afterStand

	; Reset #jtAir as we are walking
	LD A, JT_AIR_INACTIVE						
	LD (jtAir), A

	RET											; END JpJetmanLanding	

;----------------------------------------------------------;
;                 #JpLandingOnPlatform                     ;
;----------------------------------------------------------;
; Is Jetman landing on one of the platforms?
JpLandingOnPlatform
	LD A, (jtAir)
	CP JT_AIR_INACTIVE							; Is Jemtan in the air?
	RET Z										; Return if not flaying, no flying - no landing ;)

	LD HL, jpPlatformWalk
	LD B, (HL)									; Load into B the number of platforms to check
.platformsLoop	
	INC HL										; HL points to [Y]
	LD C, (HL)									; C contains [Y]

	INC HL										; HL points to [X start]
	LD D, (HL)									; D contains [X start]	

	INC HL										; HL points to [X end]
	LD E, (HL)									; E contains [X end]		
	
	LD A, (jtY)									; A holds current Y position
	CP C
	JR NZ, .platformsLoopEnd					; Jump if Jetman is on a different level than the current platform

	; Jetman is on Y of the current platform, now check X
	LD A, (jtX)									; A holds current X position
	CP D										; Compare #jtX postion to [X start]
	JR C, .platformsLoopEnd						; Jump if #jtX < [X start]

	; Jetman is on the current platform level after it's begun, we have to check if he is not too far to the right
	CP E
	JR NC, .platformsLoopEnd					; Jump if #jtX > [X end]

	; Jetman is landing on the platform!
	CALL JpJetmanLanding
	RET

.platformsLoopEnd
	DJNZ .platformsLoop							; Decrease B until all platforms have been evaluated
	RET											; END JpLandingOnPlatform

;----------------------------------------------------------;
;              #JpBumpIntoPlatformBottom                   ;
;----------------------------------------------------------;
JpBumpIntoPlatformBottom

	LD A, (jtAir)
	CP JT_AIR_INACTIVE							; Is Jemtan in the air?
	RET Z										; Return if not flaying, no flying - no colision ;)

	LD HL, jpPlatformBumpBottom
	LD B, (HL)									; Load into B the number of platforms to check
.platformsLoop	
	INC HL										; HL points to [Y]
	LD C, (HL)									; C contains [Y]

	INC HL										; HL points to [X start]
	LD D, (HL)									; D contains [X start]	

	INC HL										; HL points to [Y end]
	LD E, (HL)									; E contains [Y end]

	LD A, (jtY)									; A holds current Y position
	CP C
	JR NZ, .platformsLoopEnd					; Jump if Jetman is not close to the bottom of the platform

	; Jetman is close to the bottom of the platform
	LD A, (jtX)								; A holds current X position
	CP D										; Compare #jtX postion to [X start]
	JR C, .platformsLoopEnd						; Jump if #jtX < [X start]

	CP E
	JR NC, .platformsLoopEnd					; Jump if #jtX > [X end]

	; Jetman hits the platform!
	LD A, JT_AIR_BUMP_BOTTOM					; Change air state
	LD (jtAir), A

	PUSH BC

	LD A, JS_SDB_T_WL							; Play animation
	CALL JsChangeJetmanSpritePattern
	
	; Disable joystick, because Jetman looses control for a few frames
	LD A, JT_JOY_DISABLED_BUMP						
	LD (joDisabledCnt), A

	POP BC
.platformsLoopEnd
	DJNZ .platformsLoop							; Decrease B until all platforms have been evaluated
	RET											; END #JpBumpIntoPlatformLR

;----------------------------------------------------------;
;                 #JpBumpIntoPlatformLR                    ;
;----------------------------------------------------------;
; Input
;  - IX:	jpPlatformBumpLeft or jpPlatformBumpRight
;  - H: 	JT_AIR_BUMP_LEFT or JT_AIR_BUMP_RIGHT
JpBumpIntoPlatformLR
	LD A, (jtAir)
	CP JT_AIR_INACTIVE							; Is Jemtan in the air?
	RET Z										; Return if not flaying, no flying - no colision ;)

	LD B, (IX)									; Load into B the number of platforms to check
.platformsLoop	
	INC IX										; HL points to [X]
	LD C, (IX)									; C contains [X]

	INC IX										; HL points to [Y start]
	LD D, (IX)									; D contains [Y start]	

	INC IX										; HL points to [Y end]
	LD E, (IX)									; E contains [Y end]

	LD A, (jtX)									; A holds current X position
	CP C
	JR NZ, .platformsLoopEnd					; Jump if Jetman is not close to the right edge of the platform

	; Jetman is close to the right edge of the platform
	LD A, (jtY)									; A holds current Y position
	CP D										; Compare #jtY postion to [Y start]
	JR C, .platformsLoopEnd						; Jump if #jtY < [Y start]

	CP E
	JR NC, .platformsLoopEnd					; Jump if #jtY > [Y end]

	; Jetman hits the platform from the right!
	LD A, H										; Change air state, H is a method param
	LD (jtAir), A

	PUSH BC

	LD A, JS_SDB_T_WL							; Play animation
	CALL JsChangeJetmanSpritePattern
	
	; Disable joystick, because Jetman looses control for a few frames
	LD A, JT_JOY_DISABLED_BUMP						
	LD (joDisabledCnt), A

	POP BC
.platformsLoopEnd
	DJNZ .platformsLoop							; Decrease B until all platforms have been evaluated
	RET											; END #JpBumpIntoPlatformLR

;----------------------------------------------------------;
;                 #JpFallingFromPlatform                   ;
;----------------------------------------------------------;
; Jetman walks to the edge of the platform and falls 
JpFallingFromPlatform
	LD A, (jtGnd)
	CP JT_GND_WALK								; Is Jemtan in the air?
	RET NZ										; Return if not walking, no walking - no falling ;)

	LD HL, jpPlatformWalk							
	LD B, (HL)									; Load into B the number of platforms to check
.platformsLoop	
	INC HL										; HL points to [Y]
	LD C, (HL)									; C contains [Y]

	INC HL										; HL points to [X start]
	LD D, (HL)									; D contains [X start]	

	INC HL										; HL points to [X end]
	LD E, (HL)									; E contains [X end]		

	LD A, (jtY)									; A holds current Y position
	CP C
	JR NZ, .platformsLoopEnd					; Jump if Jetman is on a different level than the current platform

	; Jetman is on Y of the current platform, now check X
	LD A, (jtX)									; A holds current X position
	CP D										; Compare #jtX postion to [X start]
	JR C, .fallingLeft							; Jump if #jtX < [X start], meaning Jetman is falling from the left side of the platform

	CP E
	JR NC, .fallingRight						; Jump if #jtX > [X end], meaning Jetman is falling from the right side of the platform

.platformsLoopEnd
	DJNZ .platformsLoop							; Decrease B until all platforms have been evaluated
	JR .afterFalling							; Jetman is still on the platform

; Jetman is falling from the platform, left or right
.fallingLeft									
	LD A, JT_AIR_FALL_LEFT						
	LD (jtAir), A
	JR .afterFallingRight

.fallingRight
	LD A, JT_AIR_FALL_RIGHT
	LD (jtAir), A

.afterFallingRight
	; Trigger ransition: walking -> falling
	LD A, JS_SDB_T_WL
	CALL JsChangeJetmanSpritePattern

	; Disable joystick, because Jetman looses control for #JT_JOY_DISABLED_FALL frames
	LD A, JT_JOY_DISABLED_FALL						
	LD (joDisabledCnt), A
	
	; Reset #jtGnd as we are not walking anymore
	LD A, JT_GND_INACTIVE						
	LD (jtGnd), A	

.afterFalling
	RET											; END JpFallingFromPlatform
