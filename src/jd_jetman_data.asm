;----------------------------------------------------------;
;                      Jetman Data                         ;
;----------------------------------------------------------;
	MODULE jd

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

jetmanGnd				BYTE GND_INACTIVE		; Jetman initially hovers, no movement

; Hovering/Standing
jetmanInactivityCnt		BYTE 0					; The counter increases with each frame when no up/down is pressed. 
												; When it reaches #HOVER_START, Jetman will start hovering
HOVER_START				= 40
STAND_START				= 30
JSTAND_START			= 5

; Misc
GROUND_LEVEL			= 230					; The lowest walking platform.

; The counter turns off the joystick for a few iterations. Each call #JoyInput decreases it by one. 
; It's used for effects like bumping from the platform's edge or falling.
joyDisabledCnt			BYTE 0

; Possible move directions##
MOVE_INACTIVE			= 0						; No movement

MOVE_LEFT_BIT			= 0						; Bit 0 - Jetman moving left
MOVE_LEFT_MASK			= %0000'0001

MOVE_RIGHT_BIT			= 1						; Bit 1 - Jetman moving right
MOVE_RIGHT_MASK			= %0000'0010

MOVE_UP_BIT				= 2						; Bit 2 - Jetman moving up
MOVE_UP_MASK			= %0000'0100

MOVE_DOWN_BIT			= 3						; Bit 3 - Jetman moving down
MOVE_DOWN_MASK			= %0000'1000

MOVE_MSK_LR				= %0000'0011			; Left + Right

; Holds currently pressed direction button. State will be updated right at the beginning of each joystick loop
joyDirection			BYTE MOVE_INACTIVE

; This byte holds the direction in which Jetman is facing(#MOVE_XXX). It takes movement bits as arguments but gets updated only when 
; the opsite direction changes. Pressing left will reset the right bit and set left; pressing up will reset the down bit and set up. 
; However, only opposite directions are reset, so for example, when Jetman is facing right, and the right button is released, 
; it still looks right; now, when up is pressed, it will look upright, and the right will be reset only when left is pressed. 
; Prolonged inactivity resets #jetmanDirection to #MOVE_INACTIVE.
jetmanDirection			BYTE MOVE_INACTIVE	; Jetman initially hovers, no movement

JOY_DELAY				= 2					; Probe joystick every few loops. Loop speed is controled by: #WaitForScanline     
joyDelayCnt				BYTE 0				; The delay counter for joistink input and Jetman movement speed
;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE
