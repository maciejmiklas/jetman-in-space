;----------------------------------------------------------;
;              Jetman Movement, States and Logic           ;
;----------------------------------------------------------;

jtX						WORD 100				; 0-320px
jtY 					BYTE 100				; 0-256px

; States for Jetmain in the air, 0 for not in the air
JT_AIR_INACTIVE			= 0						; Jetman is not in the air
JT_AIR_FLY				= 1						; Jetman is flaying
JT_AIR_HOOVER			= 2						; Jetman is hovering
JT_AIR_FALL_RIGHT		= 3						; Jetmal falls from paltform on the right
JT_AIR_FALL_LEFT		= 4						; Jetmal falls from paltform on the left
JT_AIR_BUMP_RIGHT		= 5						; Jetban bumps into a platform from the right, he faces/moves left
JT_AIR_BUMP_LEFT		= 6						; Jetban bumps into a platform from the left, he faces/moves right
JT_AIR_BUMP_BOTTOM		= 7						; Jetban bumps into a platform from the bottom

JT_JOY_DISABLED_FALL	= 6						; Disable the joystick for a few frames because Jetman is falling from the platform
JT_JOY_DISABLED_BUMP	= 6						; Disable the joystick for a few frames because Jetman is bumping into the platform

jtAir					BYTE JT_AIR_FLY			; Jetman initially hovers, no movement

; States for Jetman on the platform/ground
JT_GND_INACTIVE			= 0						; Jetman is not on ground
JT_GND_WALK				= 1						; Jetman walks on the ground
JT_GND_JSTAND			= 3						; Jetman stands on the ground for a very short time, not enougt to switch to #JT_GND_STAND
JT_GND_STAND			= 4						; Jetman stands on the ground

jtGnd					BYTE JT_GND_INACTIVE	; Jetman initially hovers, no movement

; Hovering/Standing
jtInactivityCnt			BYTE 0					; The counter increases with each frame when no up/down is pressed. 
												; When it reaches #JT_HOVER_START, Jetman will start hovering
JT_HOVER_START			= 40
JT_STAND_START			= 30
JT_JSTAND_START			= 5

; Misc
JT_GROUND_LEVEL			= 230					; The lowest walking platform.

;----------------------------------------------------------;
;                         #JtIncJetX                       ;
;----------------------------------------------------------;
; Increment X position
JtIncJetX
	LD BC, (jtX)	
	INC BC

	; If X >= 315 then set it to 0. X is 9-bit value. 
	; 315 = 256 + 59 = %00000001 + %00111011 -> MSB: 1, LSB: 59
	LD A, B										; Load MSB from X into A
	CP 1										; 9-th bit set means X > 256
	JR NZ, .lessThanMaxX
	LD A, C										; Load MSB from X into A
	CP 59										; MSB > 59 
	JR C, .lessThanMaxX
	LD BC, 1									; Jetman is above 315 -> set to 1
.lessThanMaxX
	LD (jtX), BC								; Update new X position

	RET

;----------------------------------------------------------;
;                       #JtDecJetX                         ;
;----------------------------------------------------------;
; Decrement X position
JtDecJetX
	LD BC, (jtX)	
	DEC BC

	; If X == 0 (SC_X_MIN_POS) then set it to 315. X == 0 when B and C are 0
	LD A, B
	CP SC_X_MIN_POS								; If B > 0 then X is also > 0
	JR NZ, .afterResetX
	LD A, C
	CP SC_X_MIN_POS								; If C > 0 then X is also > 0
	JR NZ, .afterResetX
	LD BC, SC_X_MAX_POS							; X == 0 (both A and B are 0) -> set X to 315
.afterResetX
	LD (jtX), BC
	RET

;----------------------------------------------------------;
;                      #JtStandToWalk                      ; 
;----------------------------------------------------------;
; Transition from standing on ground to walking
JtStandToWalk
	LD A, (jtGnd)
	CP JT_GND_INACTIVE
	RET Z										; Exit if Jetman is not on the ground
	 
	; Jetman is on the ground, is he already walking?
	CP JT_GND_WALK
	RET Z										; Exit if Jetman is already walking

	; Jetman is standing and starts walking now
	LD A, JT_GND_WALK
	LD (jtGnd), A

	LD A, JS_SDB_WALK_ST
	CALL JsChangeJetmanSpritePattern	
	RET

;----------------------------------------------------------;
;                      #JtJetmanMoves                      ;
;----------------------------------------------------------;
; Method gets called on any movement, but not fire pressed
JtJetmanMoves

	; Reset inactivity counter as we have movement
	LD A, 0
	LD (jtInactivityCnt), A

	; Transition from hovering to flying?
	LD A, (jtAir)
	CP JT_AIR_HOOVER							; Is Jemtman hovering?			
	JR NZ, .afterHovering						; Jump if not hovering

	; Jetman is hovering, but we have movement, so switch state to fly
	LD A, JT_AIR_FLY
	LD (jtAir), A
	
	LD A, JS_SDB_FLY							; Switch to flaying animation
	CALL JsChangeJetmanSpritePattern
.afterHovering	

	RET