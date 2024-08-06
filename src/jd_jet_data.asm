;----------------------------------------------------------;
;                      Jetman Data                         ;
;----------------------------------------------------------;
	MODULE jd

jetmanX					WORD 100				; 0-320px
jetmanY 				BYTE 100				; 0-256px

STATE_INACTIVE			= 0

; States for Jetmain in the air, 0 for not in the air
AIR_FLY					= 1						; Jetman is flaying
AIR_HOOVER				= 2						; Jetman is hovering
AIR_FALL_RIGHT			= 3						; Jetmal falls from paltform on the right
AIR_FALL_LEFT			= 4						; Jetmal falls from paltform on the left
AIR_BUMP_RIGHT			= 5						; Jetban bumps into a platform from the right, he faces/moves left
AIR_BUMP_LEFT			= 6						; Jetban bumps into a platform from the left, he faces/moves right
AIR_BUMP_BOTTOM			= 7						; Jetban bumps into a platform from the bottom

jetAir					BYTE AIR_FLY

; States for Jetman on the platform/ground
GND_WALK				= 1						; Jetman walks on the ground
GND_JSTAND				= 2						; Jetman stands on the ground for a very short time, not enougt to switch to #GND_STAND
GND_STAND				= 3						; Jetman stands on the ground

jetGnd				BYTE 0

; Jetman states
JET_STATE_INIT			= %00000000
JET_STATE_AIR_BIT		= 0						; Jemtan is flying, possible states are in #jetAir
JET_STATE_GND_BIT		= 1						; Jemtan is walking, possible states are in #jetGnd
JET_STATE_RIP_BIT		= 2						; Jemtan got hit by enemy
JET_STATE_INV_BIT		= 3						; Jetman is invincible

jetState				BYTE %00000001			; Game start, Jetman in the air

; Hovering/Standing
jetmanInactivityCnt		BYTE 0					; The counter increases with each frame when no up/down is pressed. 
												; When it reaches #HOVER_START, Jetman will start hovering
HOVER_START				= 40
STAND_START				= 30
JSTAND_START			= 5

; Misc
JOY_DISABLED_FALL		= 6						; Disable the joystick for a few frames because Jetman is falling from the platform
JOY_DISABLED_BUMP		= 6						; Disable the joystick for a few frames because Jetman is bumping into the platform

GROUND_LEVEL			= 230					; The lowest walking platform.

; The counter turns off the joystick for a few iterations. Each call #JoyInput decreases it by one. 
; It's used for effects like bumping from the platform's edge or falling.
joyDisabledCnt			BYTE 0

; Possible move directions##
MOVE_INACTIVE			= 0						; No movement

MOVE_LEFT_BIT			= 0						; Bit 0 - Jetman moving left, facing left
MOVE_LEFT_MASK			= %0000'0001

MOVE_RIGHT_BIT			= 1						; Bit 1 - Jetman moving right, facing rith
MOVE_RIGHT_MASK			= %0000'0010

MOVE_UP_BIT				= 2						; Bit 2 - Jetman moving up, facing up
MOVE_UP_MASK			= %0000'0100

MOVE_DOWN_BIT			= 3						; Bit 3 - Jetman moving down, facing up
MOVE_DOWN_MASK			= %0000'1000

MOVE_MSK_LR				= %0000'0011			; Left + Right

; This byte holds the direction in which Jetman is facing(#MOVE_XXX_MASK). It takes movement bits as arguments but gets updated only when 
; the opsite direction changes. Pressing left will reset the right bit and set left; pressing up will reset the down bit and set up. 
; However, only opposite directions are reset, so for example, when Jetman is facing right, and the right button is released, 
; it still looks right; now, when up is pressed, it will look upright, and the right will be reset only when left is pressed. 
; Prolonged inactivity resets #jetDirection to #MOVE_INACTIVE.
jetDirection			BYTE MOVE_INACTIVE	; Jetman initially hovers, no movement

; Holds currently pressed direction button. State will be updated right at the beginning of each joystick loop
joyDirection			BYTE MOVE_INACTIVE

JOY_DELAY				= 2					; Probe joystick every few loops. Loop speed is controled by: #WaitForScanline     
joyDelayCnt				BYTE 0				; The delay counter for joistink input and Jetman movement speed
	
ENEMY_THICKNESS			= 10
SHAKE_SCREEN_BY			= 5					; Number of pixels to move the screen by shaking

RIP_MOVE_LEFT			= 0
RIP_MOVE_RIGHT			= 1
ripMoveState			BYTE 0				; 1 - move right, 0 - move left

; Amount of steps to move in a direction is given by #ripMoveState. This counter counts down to 0. When that happens, 
; the counter gets initialized from #ripMoveMul, and the direction changes (#ripMoveState)
ripMoveCnt				BYTE jd.RIP_MOVE_MUL_INC

RIP_MOVE_MUL_INC		= 10
ripMoveMul				BYTE jd.RIP_MOVE_MUL_INC

invincibleCnt			BYTE 0				; Makes Jetman invincible when > 0

RESPOWN_INVINCIBLE_CNT = 250				; Number of loops to keep Jetman invincible	
;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE
