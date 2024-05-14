;----------------------------------------------------------;
;              Jetman Movement, States and Logic           ;
;----------------------------------------------------------;
	MODULE jt

jetmanX					WORD 100				; 0-320px
jetmanY 				BYTE 100				; 0-256px

; States for Jetmain in the air, 0 for not in the air
AIR_INACTIVE			= 0						; Jetman is not in the air
AIR_FLY					= 1						; Jetman is flaying
AIR_HOOVER				= 2						; Jetman is hovering
AIR_FALL_RIGHT			= 3						; Jetmal falls from paltform on the right
AIR_FALL_LEFT			= 4						; Jetmal falls from paltform on the left
AIR_BUMP_RIGHT			= 5						; Jetban bumps into a platform from the right, he faces/moves left
AIR_BUMP_LEFT			= 6						; Jetban bumps into a platform from the left, he faces/moves right
AIR_BUMP_BOTTOM			= 7						; Jetban bumps into a platform from the bottom

JOY_DISABLED_FALL		= 6						; Disable the joystick for a few frames because Jetman is falling from the platform
JOY_DISABLED_BUMP		= 6						; Disable the joystick for a few frames because Jetman is bumping into the platform

jetmanAir				BYTE AIR_FLY			; Jetman initially hovers, no movement

; States for Jetman on the platform/ground
GND_INACTIVE			= 0						; Jetman is not on ground
GND_WALK				= 1						; Jetman walks on the ground
GND_JSTAND				= 3						; Jetman stands on the ground for a very short time, not enougt to switch to #GND_STAND
GND_STAND				= 4						; Jetman stands on the ground

jetmanGnd				BYTE GND_INACTIVE	; Jetman initially hovers, no movement

; Hovering/Standing
jetmanInactivityCnt		BYTE 0					; The counter increases with each frame when no up/down is pressed. 
												; When it reaches #HOVER_START, Jetman will start hovering
HOVER_START				= 40
STAND_START				= 30
JSTAND_START			= 5

; Misc
GROUND_LEVEL			= 230					; The lowest walking platform.

;----------------------------------------------------------;
;                          #IncJetX                        ;
;----------------------------------------------------------;
; Increment X position
IncJetX
	LD BC, (jetmanX)	
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
	LD (jetmanX), BC							; Update new X position

	RET

;----------------------------------------------------------;
;                        #DecJetX                          ;
;----------------------------------------------------------;
; Decrement X position
DecJetX
	LD BC, (jetmanX)	
	DEC BC

	; If X == 0 (SCR_X_MIN_POS) then set it to 315. X == 0 when B and C are 0
	LD A, B
	CP sc.SCR_X_MIN_POS							; If B > 0 then X is also > 0
	JR NZ, .afterResetX
	LD A, C
	CP sc.SCR_X_MIN_POS							; If C > 0 then X is also > 0
	JR NZ, .afterResetX
	LD BC, sc.SCR_X_MAX_POS						; X == 0 (both A and B are 0) -> set X to 315
.afterResetX
	LD (jetmanX), BC
	RET

;----------------------------------------------------------;
;                       #StandToWalk                       ; 
;----------------------------------------------------------;
; Transition from standing on ground to walking
StandToWalk
	LD A, (jetmanGnd)
	CP GND_INACTIVE
	RET Z										; Exit if Jetman is not on the ground
	 
	; Jetman is on the ground, is he already walking?
	CP GND_WALK
	RET Z										; Exit if Jetman is already walking

	; Jetman is standing and starts walking now
	LD A, GND_WALK
	LD (jetmanGnd), A

	LD A, js.SDB_WALK_ST
	CALL js.ChangeJetmanSpritePattern	
	RET

;----------------------------------------------------------;
;                       #JetmanMoves                       ;
;----------------------------------------------------------;
; Method gets called on any movement, but not fire pressed
JetmanMoves

	; Reset inactivity counter as we have movement
	LD A, 0
	LD (jetmanInactivityCnt), A

	; Transition from hovering to flying?
	LD A, (jetmanAir)
	CP AIR_HOOVER								; Is Jemtman hovering?			
	JR NZ, .afterHovering						; Jump if not hovering

	; Jetman is hovering, but we have movement, so switch state to fly
	LD A, AIR_FLY
	LD (jetmanAir), A
	
	LD A, js.SDB_FLY							; Switch to flaying animation
	CALL js.ChangeJetmanSpritePattern
.afterHovering	

	RET

;----------------------------------------------------------;
;                            END                           ;
;----------------------------------------------------------;
	ENDMODULE	