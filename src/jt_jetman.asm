jtX						WORD 100				; 0-320px
jtY 					BYTE 100				; 0-256px

; Possible move directions##
JT_MOVE_INACTIVE		= 0						; No movement

JT_MOVE_LEFT_BIT		= 0						; Bit 0 - Jetman moving left
JT_MOVE_LEFT_BM			= %0000'0001

JT_MOVE_RIGHT_BIT		= 1						; Bit 1 - Jetman moving right
JT_MOVE_RIGHT_BM		= %0000'0010

JT_MOVE_UP_BIT			= 2						; Bit 2 - Jetman moving up
JT_MOVE_UP_BM			= %0000'0100

JT_MOVE_DOWN_BIT		= 3						; Bit 3 - Jetman moving down
JT_MOVE_DOWN_BM			= %0000'1000

JT_MOVE_MSK_LR			= %0000'0011			; Left + Right

; This byte holds the direction in which Jetman is facing. It takes movement bits as arguments but gets updated only when 
; the opsite direction changes. Pressing left will reset the right bit and set left; pressing up will reset the down bit and set up. 
; However, only opposite directions are reset, so for example, when Jetman is facing right, and the right button is released, 
; it still looks right; now, when up is pressed, it will look upright, and the right will be reset only when left is pressed. 
; Prolonged inactivity resets #jtDirection to #JT_MOVE_INACTIVE.
jtDirection 		BYTE JT_MOVE_INACTIVE		; Jetman initially hovers, no movement

; Holds currently pressed direction button. State will be updated right on the beginnig of each joysting loop
jtMove 			BYTE JT_MOVE_INACTIVE

; States for Jetmain in the air, 0 for not in the air
JT_AIR_INACTIVE			= 0						; Jetman is not in the air
JT_AIR_FLY				= 1						; Jetman is flaying
JT_AIR_HOOVER			= 2						; Jetman is hovering
JT_AIR_FALL_RIGHT		= 3						; Jetmal falls from paltform on the right
JT_AIR_FALL_LEFT		= 4						; Jetmal falls from paltform on the left
JT_AIR_BUMP_RIGHT		= 5						; Jetban bumps into a platform from the right
JT_AIR_BUMP_LEFT		= 6						; Jetban bumps into a platform from the left
JT_AIR_BUMP_BOTTOM		= 7						; Jetban bumps into a platform from the bottom

JT_JOY_DISABLE_FALL		= 6						; Disable the joystick for a few frames because Jetman is falling from the platform
JT_JOY_DISABLE_BUMP		= 6						; Disable the joystick for a few frames because Jetman is bumping into the platform

jtAir					BYTE JT_AIR_FLY		; Jetman initially hovers, no movement

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
;                          #JtIncJetX                        ;
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
	LD BC, 1									; Jetman is above 320 -> set to 0
.lessThanMaxX
	LD (jtX), BC								; Update new X postion

	RET											; END #JtIncJetX 

;----------------------------------------------------------;
;                        #JtDecJetX                          ;
;----------------------------------------------------------;
; Decrement X position
JtDecJetX
	LD BC, (jtX)	
	DEC BC

	; If X == 0 (SC_X_MIN_POS) then set it to 315. X == 0 when B and C are 0
	LD A, B
	CP SC_X_MIN_POS								; If B > 0 then X is also X > 0
	JR NZ, .afterResetX
	LD A, C
	CP SC_X_MIN_POS								; If C > 0 then X is also X > 0
	JR NZ, .afterResetX
	LD BC, SC_X_MAX_POS							; X == 0 (both A and B are 0) -> set X to 315
	JR NZ, .afterResetX
.afterResetX
	LD (jtX), BC
	RET											; END #JtDecJetX

;----------------------------------------------------------;
;                       #JtStandToWalk                       ; 
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
	RET											; END #JtStandToWalk

;----------------------------------------------------------;
;                       #JtJetmanMoves                       ;
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

	RET 										; END #JtJetmanMoves