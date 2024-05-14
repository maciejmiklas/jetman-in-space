;----------------------------------------------------------;
;                        Joystick Input                    ;
;----------------------------------------------------------;
	MODULE jo
	
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
jetmanDirection		BYTE MOVE_INACTIVE	; Jetman initially hovers, no movement

JOY_DELAY				= 2					; Probe joystick every few loops. Loop speed is controled by: #WaitForScanline     
joyDelayCnt				BYTE 0				; The delay counter for joistink input and Jetman movement speed

;----------------------------------------------------------;
;                         #JoyInput                        ;
;----------------------------------------------------------;
JoyInput

	; Slow down joystick input and, therefore, speed of Jetman movement
	LD A, (joyDelayCnt)
	INC A
	LD (joyDelayCnt), A

	CP JOY_DELAY
	RET C										; Return if #joyDelayCnt <  #JOY_DELAY

	LD A, 0										; Reset delay counter
	LD (joyDelayCnt), A

	; Handle disabled joystick
	LD A, (joyDisabledCnt)
	CP 0
	JR Z, .afterjoystickDisabled				; Jump if joystick is enabled -> #joyDisabledCnt > 0

	; Joystick is disabled
	DEC A										; Decrement disabled counter
	LD (joyDisabledCnt), A
	RET											; Do not process input, as the joystick is disabled
.afterjoystickDisabled	

	CALL JoyStart
	
	; Key Rright pressed ?
	LD A, _KB_6_TO_0_HEF						; $EF -> A (6...0)
	IN A, (_KB_REG_HFE)							; Read keyboard input into A
	BIT 2, A									; Bit 2 reset -> Rright pressed
	CALL Z, JoyMoveRight

	; Joystick right pressed ?
	LD A, _JOY_MASK_H20							; Activete joystick register
	IN A, (_JOY_REG_H1F) 						; Read joystick input into A
	BIT 0, A									; Bit 0 set -> Right pressed
	CALL NZ, JoyMoveRight			

	; Key Left pressed ?
	LD A, _KB_5_TO_1_HF7						; $FD -> A (5...1)
	IN A, (_KB_REG_HFE)							; Read keyboard input into A
	BIT 4, A									; Bit 4 reset -> Left pressed
	CALL Z, JoyMoveLeft		

	; Joystick left pressed ?
	LD A, _JOY_MASK_H20							; Activete joystick register
	IN A, (_JOY_REG_H1F) 						; Read joystick input into A
	BIT 1, A									; Bit 1 set -> Left pressed
	CALL NZ, JoyMoveLeft

	; Key Up pressed ?
	LD A, _KB_6_TO_0_HEF						; $EF -> A (6...0)
	IN A, (_KB_REG_HFE)							; Read keyboard input into A
	BIT 3, A									; Bit 3 reset -> Up pressed
	CALL Z, JoyMoveUp	

	; Joystick up pressed ?
	LD A, _JOY_MASK_H20							; Activete joystick register
	IN A, (_JOY_REG_H1F) 						; Read joystick input into A
	BIT 3, A									; Bit 3 set -> Up pressed
	CALL NZ, JoyMoveUp

	; Key Down pressed ?
	LD A, _KB_6_TO_0_HEF						; $EF -> A (6...0)
	IN A, (_KB_REG_HFE)							; Read keyboard input into A
	BIT 4, A									; Bit 4 reset -> Down pressed
	CALL Z, JoyMoveDown				

	; Joystick down pressed ?
	LD A, _JOY_MASK_H20							; Activete joystick register
	IN A, (_JOY_REG_H1F) 						; Read joystick input into A
	BIT 2, A									; Bit 2 set -> Down pressed
	CALL NZ, JoyMoveDown

	; Key Fire (Z) pressed ?
	LD A, _KB_V_TO_Z_HFE						; $FD -> A (5...1)
	IN A, (_KB_REG_HFE)							; Read keyboard input into A
	BIT 1, A									; Bit 1 reset -> Z pressed
	CALL Z, JoyPressFire

	; Joystick fire pressed ?
	LD A, _JOY_MASK_H20							; Activete joystick register
	IN A, (_JOY_REG_H1F) 						; Read joystick input into A
	AND %01110000								; Any of three fires pressed?
	CALL NZ, JoyPressFire	
	
	CALL JoyEnd

	RET											; END JoyInput

;----------------------------------------------------------;
;                      #JoyMoveUp                          ;
;----------------------------------------------------------;
JoyMoveUp
	; Update #joyDirection state
	LD A, (joyDirection)
	SET MOVE_UP_BIT, A	
	LD (joyDirection), A

	CALL jt.JetmanMoves							

	; Decrement Y position
	LD A, (jt.jetmanY)	
	CP sc.SCR_Y_MIN_POS 						; Do not decrement if Jetman has reached the top of the screen.
	JR Z, .afterDec
	DEC A
	LD (jt.jetmanY), A
.afterDec	

	; Direction change: down -> up
	LD A, (jetmanDirection)
	AND MOVE_UP_MASK							; Are we moving Up already?
	CP MOVE_UP_MASK
	JR Z, .afterDirectionChange

	; We have direction change!
	LD A, (jetmanDirection)						; Update #jetState by resetting down and setting up
	RES MOVE_DOWN_BIT, A
	SET MOVE_UP_BIT, A
	LD (jetmanDirection), A
.afterDirectionChange

	; Transition from walking to flaying
	CALL JetmanTakesoff

	; Bumping from below into the platform?
	CALL BumpIntoPlatFormBelow
	RET											; END #JoyMoveUp	

;----------------------------------------------------------;
;                     #JoyMoveRight                        ;
;----------------------------------------------------------;
JoyMoveRight
	; Update temp state
	LD A, (joyDirection)
	SET MOVE_RIGHT_BIT, A	
	LD (joyDirection), A

	CALL jt.JetmanMoves						
	CALL jt.StandToWalk
	CALL jt.IncJetX

	; ##Direction change: left -> right##
	LD A, (jetmanDirection)
	AND MOVE_RIGHT_MASK							; Are we moving right already?
	CP MOVE_RIGHT_MASK
	JR Z, .afterDirectionChange

	; We have direction change!		
	LD A, (jetmanDirection)						; Reset left and set right						
	RES MOVE_LEFT_BIT, A
	SET MOVE_RIGHT_BIT, A
	LD (jetmanDirection), A
	
.afterDirectionChange

	; Bupm from the left side of the platform?
	LD H, jt.AIR_BUMP_LEFT
	CALL BumpIntoPlatformLR

	CALL FallingFromPlatform
	RET											; END #JoyMoveRight

;----------------------------------------------------------;
;                      #JoyMoveLeft                        ;
;----------------------------------------------------------;
JoyMoveLeft
	; Update #joyDirection state
	LD A, (joyDirection)
	SET MOVE_LEFT_BIT, A	
	LD (joyDirection), A

	CALL jt.JetmanMoves	
	CALL jt.StandToWalk					
	CALL jt.DecJetX

	; Direction change: right -> left
	LD A, (jetmanDirection)
	AND MOVE_LEFT_MASK							; Are we moving left already?
	CP MOVE_LEFT_MASK
	JR Z, .afterDirectionChange					; Jetman is moving left already -> end

	; We have direction change!		
	LD A, (jetmanDirection)						; Reset right and set left 					
	RES MOVE_RIGHT_BIT, A
	SET MOVE_LEFT_BIT, A
	LD (jetmanDirection), A
.afterDirectionChange

	; Bupm from the right side of the platform?
	LD H, jt.AIR_BUMP_RIGHT
	CALL BumpIntoPlatformLR

	CALL FallingFromPlatform
	RET											; END #JoyMoveLeft

;----------------------------------------------------------;
;                    #JoyPressFire                         ;
;----------------------------------------------------------;
JoyPressFire
	CALL jw.Fire
	RET											; END #JoyPressFire

;----------------------------------------------------------;
;                      #JoyMoveDown                        ;
;----------------------------------------------------------;
JoyMoveDown
	; Update #joyDirection state
	LD A, (joyDirection)
	SET MOVE_DOWN_BIT, A	
	LD (joyDirection), A

	; Cannot move down when walking
	LD A, (jt.jetmanGnd)
	CP jt.GND_INACTIVE
	RET NZ	

	CALL jt.JetmanMoves						

	; Increment Y position#
	LD A, (jt.jetmanY)
	CP jt.GROUND_LEVEL							; Do not increment if Jetman has reached the ground
	JR Z, .afterInc						

	; Move Jetman 1px down
	INC A
	LD (jt.jetmanY), A

	; Landing on the ground
	CP jt.GROUND_LEVEL
	CALL Z, JetmanLanding						; Execute landing on the ground if Jetman has reached the ground.
	CALL LandingOnPlatform						; Or should he land on one of the platforms?

	; Direction change? 
	LD A, (jetmanDirection)
	AND MOVE_DOWN_MASK							; Are we moving down already?
	CP MOVE_DOWN_MASK
	JR Z, .afterDirectionChange

	; We have direction change!	
	LD A, (jetmanDirection)						; Update #jetState by resetting Up/Hover and setting Down
	RES MOVE_UP_BIT, A
	SET MOVE_DOWN_BIT, A	
	LD (jetmanDirection), A
.afterDirectionChange
.afterInc	

	RET

;----------------------------------------------------------;
;                        #JoyStart                         ;
;----------------------------------------------------------;
JoyStart
	LD A, MOVE_INACTIVE							; Update #jetState by resetting left/hover and setting right
	LD (joyDirection), A

	RET

;----------------------------------------------------------;
;                         #JoyEnd                          ;
;----------------------------------------------------------;
JoyEnd											; After input processing, #JoyEnd gets executed as the last procedure. 

	; #Jetman inactivity#
	LD A, (joyDirection)
	CP MOVE_INACTIVE
	JR NZ, .afterInactivity						; Jump to the end if there is a movement

	LD A, (jt.jetmanInactivityCnt)				; Increment inactivity counter
	INC A
	LD (jt.jetmanInactivityCnt), A

	; Should Jetman hover?
	LD A, (jt.jetmanAir)
	CP jt.AIR_INACTIVE							; Is Jemtan in the air already?
	JR Z, .afterHoover							; Jump if not flaying

	CP jt.AIR_HOOVER							; Jetman is in the air, but is he hovering already?
	JR Z, .afterHoover							; Jump if already hovering

	; Jetman is in the air, not hovering, but is he not moving long enough?
	LD A, (jt.jetmanInactivityCnt)
	CP jt.HOVER_START
	JR NZ, .afterHoover							; Jetman is not moving, by sill not long enough to start hovering

	; Jetamn starts to hover!
	LD A, jt.AIR_HOOVER
	LD (jt.jetmanAir), A

	LD A, js.SDB_HOVER
	CALL js.ChangeJetmanSpritePattern
	JR .afterInactivity							; Alerady hovering, do not check standing	
.afterHoover

	; Jetman is not hovering, but should he stand?
	LD A, (jt.jetmanGnd)
	CP jt.AIR_INACTIVE							; Is Jemtan on the ground already?
	JR Z, .afterInactivity						; Jump if not on the ground

	CP jt.GND_STAND								; Jetman is on the ground, but is he stainding already?
	JR Z, .afterInactivity						; Jump if already standing

	; Jetman is on the ground and does not move, but is he not moving long enough?
	LD A, (jt.jetmanInactivityCnt)
	CP jt.STAND_START
	JR NZ, .afterStand							; Jump if Jetman stands for too short to trigger standing

	; Transtion from walking to standing
	LD A, jt.GND_STAND
	LD (jt.jetmanGnd), A

	LD A, js.SDB_STAND							; Change animation
	CALL js.ChangeJetmanSpritePattern
	JR .afterInactivity
.afterStand
	
	; Code is here because: jetmanInactivityCnt > 0 AND jetmanInactivityCnt < STAND_START 
	; Jetman stands still for a short time, not long enough, to play standing animation, but at least we should stop walking animation.	
	LD A, (jt.jetmanGnd)
	CP jt.GND_WALK
	JR NZ, .afterInactivity						; Jump is if not walking
	
	CP jt.GND_JSTAND
	JR Z, .afterInactivity						; Jump already j-standing (just standing - for a short time)

	LD A, (jt.jetmanInactivityCnt)
	CP jt.JSTAND_START
	JR NZ, .afterInactivity						; Jump if Jetman stands for too short to trigger j-standing

	LD A, jt.GND_JSTAND
	LD (jt.jetmanGnd), A

	LD A, js.SDB_JSTAND							; Change animation
	CALL js.ChangeJetmanSpritePattern

.afterInactivity

	RET

;----------------------------------------------------------;
;                      #JoyDisabled                        ;
;----------------------------------------------------------;
JoyDisabled
	; Handle disabled joystick
	LD A, (joyDisabledCnt)
	CP 0
	RET Z										; Jump if joystick is enabled -> #joyDisabledCnt == 0

	CALL BumpOnJoystickDisabled

	; Reset the #jetmanAir on the last frame of the disabled joystick
	LD A, (jt.jetmanAir)
	CP 1
	RET NZ										; Jump if it's not the last frame (!=1)
	LD A, jt.AIR_FLY
	LD (jt.jetmanAir), A

	RET

;----------------------------------------------------------;
;                            END                           ;
;----------------------------------------------------------;
	ENDMODULE		