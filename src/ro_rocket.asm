;----------------------------------------------------------;
;               Building and Flying the Rocket             ;
;----------------------------------------------------------;
	MODULE ro

; Number of Counter40 cycles to drop next rocket module
DROP_NEXT_DELAY_MAX		= 10
dropNextDelay			BYTE 3

; The state is used to build the rocket and then bring fuel to it. Building the rocket requires three elements, as does fueling it. 
; It's basically the same process, but Jetman is carrying either rocket elements or fuel tanks. Bit 7 determines whether Jetman is building 
; the rocket or already carries fuel. 
; Bits:
;  - 0-2: Current element 1-3 (rocket element), 4-6 (fuel tank), 7 - fully assembed
;  - 3  : #STATE_FALL_BIT
;  - 4  : #STATE_WAIT_BIT
;  - 5  : #STATE_CARRY_BIT
;  - 6  : #STATE_ASSEMBLY_BIT
;  - 7  : #STATE_FLYING_BIT
state					BYTE 0					; Start with building first rocket element

STATE_FALL_BIT			= 3						; Rocket element (or fuel tank) is falling down for pickup
STATE_WAIT_BIT			= 4						; Rocket element (or fuel tank) is waiting for pickup
STATE_CARRY_BIT			= 5						; Jetman carries rocket element (or fuel tank)
STATE_ASSEMBLY_BIT		= 6						; Rocket element (or fuel tank) is falling down for assembly
STATE_FLYING_BIT		= 7						; The rocket is flying towards an unknown planet

STATE_DROP_NEXT_MASK	= %11111'000			; Dorp next element if the rocket is not fully assembled and no element is deployed at the moment
STATE_ELEMET_CNT_MASK	= %00000'111			; Reset all bits except the counter
STATE_ELEMET_READY_MASK	= %1'0000'111			; Reset all bits except the counter and ready flag
STATE_ELEMET_DEPL_MASK	= %000'11'000			; Jetman can pick up element/tank

STATE_CNT_ELEMET_MAX	= 6
STATE_CNT_FUEL_MIN		= 4
STATE_CNT_ASSEMBLED		= 7						; Counter will be set to 7 when the rocket is ready for takeoff

; The single rocket element or fule tank
	STRUCT ROCKET
; Configuration values	
DROP_X					BYTE					; X coordinate to drop the given element/tank
DROP_LAND_Y				BYTE 					; Y coordinates where the dropped element/tank should land. Usually, it's the height of the platform/ground
ASSEMBLY_Y				BYTE					; Height where given rocket element should land for assembly
SPRITE_ID				BYTE					; Next ID of the sprite
SPRITE_REF				BYTE					; ID of the Sprite from spr-file

; Values set in program
Y						BYTE					; Current Y position
	ENDS

; The rocket fuel level when the fuel tank reaches the rocket
	STRUCT FUEL_LEVEL
ELEMENT_ID				BYTE					; ID of rocket element, 4-6
SPRITE_REF				BYTE					; ID of the Sprite from spr-file
	ENDS

ROCKET_DOWN_SPR_ID		= 40					; Sprite ID is used to lower the rocket part, which has the engine and fuel
MIN_DROP_HEIGHT			= 180					; Jetman has to be above the rocket to drop the element, 170 > Y >10

ROCKET_SPR_ID_READY1	= 63					; Once the rocket is ready, it will start blinking using #ROCKET_SPR_ID_READY1 and #ROCKET_SPR_ID_READY2
ROCKET_SPR_ID_READY2	= 59

rocket
; rocket element
	ROCKET {050/*DROP_X*/, 100/*DROP_LAND_Y*/, 235/*ASSEMBLY_Y*/, ROCKET_DOWN_SPR_ID/*SPRITE_ID*/, 60/*SPRITE_REF*/, 0/*Y*/}
	ROCKET {070/*DROP_X*/, 235/*DROP_LAND_Y*/, 219/*ASSEMBLY_Y*/,                 41/*SPRITE_ID*/, 56/*SPRITE_REF*/, 0/*Y*/}
	ROCKET {120/*DROP_X*/, 145/*DROP_LAND_Y*/, 203/*ASSEMBLY_Y*/,                 42/*SPRITE_ID*/, 52/*SPRITE_REF*/, 0/*Y*/}
; fuel tank
	ROCKET {015/*DROP_X*/, 235/*DROP_LAND_Y*/, 235/*ASSEMBLY_Y*/, 43/*SPRITE_ID*/, 10/*SPRITE_REF*/, 0/*Y*/}
	ROCKET {160/*DROP_X*/, 235/*DROP_LAND_Y*/, 219/*ASSEMBLY_Y*/, 43/*SPRITE_ID*/, 10/*SPRITE_REF*/, 0/*Y*/}
	ROCKET {230/*DROP_X*/, 059/*DROP_LAND_Y*/, 203/*ASSEMBLY_Y*/, 43/*SPRITE_ID*/, 10/*SPRITE_REF*/, 0/*Y*/}

fuelLevel
	FUEL_LEVEL {4/*ELEMENT_ID*/, 61/*SPRITE_REF*/}
	FUEL_LEVEL {5/*ELEMENT_ID*/, 62/*SPRITE_REF*/}
	FUEL_LEVEL {6/*ELEMENT_ID*/, 63/*SPRITE_REF*/}

rocketAssemblyX			BYTE 170

COLISION_MARGIN_X		= 8
COLISION_MARGIN_Y		= 16
CARRY_ADJUST_Y			= 10

;----------------------------------------------------------;
;                #UpdateOnJetmanMove                       ;
;----------------------------------------------------------;
UpdateOnJetmanMove
	CALL AttachRocketElement
	CALL CarryRocketElement
	CALL BoardRocket
	RET	

;----------------------------------------------------------;
;                     #BoardRocket                         ;
;----------------------------------------------------------;
BoardRocket
	; Return if rocket is not ready for boarding
	LD A, (state)
	AND STATE_ELEMET_READY_MASK
	CP STATE_CNT_ASSEMBLED
	RET NZ	
	
	; Jetman collision with first (lowest) rocket element triggers take off
	LD IX, rocket

	LD BC, (rocketAssemblyX)					; X of the element
	LD B, 0
	LD D, (IX + ROCKET.Y)						; Y of the element
	CALL CheckCollision
	CP COLLISION_NO
	RET Z

	; We have collision!
	LD A, (state)
	SET STATE_FLYING_BIT, A
	LD (state), A

	; Hide sprite (before changing state!)
	CALL js.HideJetSprite

	; change state
	LD A, jt.AIR_FLY_ROCKET
	CALL jt.ChangeJetStateAir
	
	RET

;----------------------------------------------------------;
;                     #CheckHitTank                        ;
;----------------------------------------------------------;
; Checks falling tank for collision with leaser beam
CheckHitTank

	; Is something (could be rocket element or tank) falling down?
	LD A, (state)
	BIT STATE_FALL_BIT, A
	RET Z										; Return if fall bit is not set

	; Something is falling, is that a tank?
	AND STATE_ELEMET_CNT_MASK
	CP STATE_CNT_FUEL_MIN
	RET C										; Return if counter is < 4 (still assembling rocket)

	; Fuel tank is falling down, check hit by leaser beam
	CALL SetIXtoCurrentRocketElement


	;CALL jw.ShotsColision
	RET

;----------------------------------------------------------;
;                       #FlyRocket                         ;
;----------------------------------------------------------;
FlyRocket
	; Return if rocket is not flying
	LD A, (state)
	BIT STATE_FLYING_BIT, A
	RET Z

	; The current position of rocket elements is stored in #rocketAssemblyX and #ROCKET.Y 
	; It was set when elements were falling towards the platform. Now, we need to decrease X to animate the rocket.
	
	LD IX, rocket								; Load the pointer to #rocket into IX

	; Move 1 rocket eleent
	LD A, (IX + ROCKET.Y)
	DEC A
	LD (IX + ROCKET.Y), A

	LD A, (rocketAssemblyX)
	CALL UpdateElementPosition

	; Move 2 rocket eleent
	LD A, 2
	CALL MoveIXtoGivemRocketElement

	LD A, (IX + ROCKET.Y)
	DEC A
	LD (IX + ROCKET.Y), A

	LD A, (rocketAssemblyX)
	CALL UpdateElementPosition

	; Move 3 rocket eleent
	LD A, 3
	CALL MoveIXtoGivemRocketElement
	
	LD A, (IX + ROCKET.Y)
	DEC A
	LD (IX + ROCKET.Y), A

	LD A, (rocketAssemblyX)
	CALL UpdateElementPosition	

	CALL js.HideJetSprite						; Keep hiding Jemtan sprite, just in case oter procedure would show it
	RET

;----------------------------------------------------------;
;                 #UpdateElementPosition                   ;
;----------------------------------------------------------;
; Input:
;  - IX:	Current #ROCKET pointer
;  - A:		X postion
UpdateElementPosition

	; The current position of rocket elements is stored in #rocketAssemblyX and #ROCKET.Y
	LD B, A

	; Set the ID of the sprite for the following commands
	LD A, (IX + ROCKET.SPRITE_ID)
	NEXTREG _SPR_REG_NR_H34, A

	; Sprite X coordinate from A param
	LD A, B
	NEXTREG _SPR_REG_X_H35, A

	LD A, _SPR_REG_ATR2_EMPTY
	NEXTREG _SPR_REG_ATR2_H37, A

	; Set sprite pattern	
	LD A, (IX + ROCKET.SPRITE_REF)
	OR _SPR_PATTERN_SHOW						; Set show bit
	NEXTREG _SPR_REG_ATR3_H38, A

	; Sprite Y coordinate, increment until the destination has been reached
	LD A, (IX + ROCKET.Y)
	NEXTREG _SPR_REG_Y_H36, A

	RET
;----------------------------------------------------------;
;              #ResetCarryingRocketElement                 ;
;----------------------------------------------------------;
ResetCarryingRocketElement
	; Return if the state does not match carry
	LD A, (state)
	BIT STATE_CARRY_BIT, A
	RET Z

	; Reset from carry to wait for drop, hide spirte

	CALL SetIXtoCurrentRocketElement

	; Hide rocket element sprite
	LD A, (IX + ROCKET.SPRITE_ID)
	NEXTREG _SPR_REG_NR_H34, A

	LD A, _SPR_PATTERN_HIDE						; Hide sprite on display	
	NEXTREG _SPR_REG_ATR3_H38, A

	; Reset the state and decrement element counter -> we will drop this element again
	LD A, (state)
	RES STATE_CARRY_BIT, A
	DEC A										; Go back to previous element
	LD (state), A

	; Reset drop delay
	LD A, 0
	LD (dropNextDelay), A

	RET

;----------------------------------------------------------;
;                  #CarryRocketElement                     ;
;----------------------------------------------------------;
CarryRocketElement
	
	; Return if the state does not match
	LD A, (state)
	BIT STATE_CARRY_BIT, A
	RET Z

	CALL SetIXtoCurrentRocketElement
	CALL MoveWithJetman
	CALL JetmanDropsRocketElement
	RET

;----------------------------------------------------------;
;                #JetmanDropsRocketElement                 ;
;----------------------------------------------------------;
JetmanDropsRocketElement
	
	; Is Jetman over the drop location (+/- #COLISION_MARGIN_X) ?
	LD BC, (jo.jetX)
	LD A, (rocketAssemblyX)
	SUB C
	CP COLISION_MARGIN_X
	RET NC

	; Js Jetman above rocket?
	LD A, (jo.jetY)
	CP MIN_DROP_HEIGHT
	RET NC

	; Jetman drops rocket element
	LD A, (state)
	RES STATE_CARRY_BIT, A
	SET STATE_ASSEMBLY_BIT, A
	LD (state), A

	; Store the height of the drop so that the element can keep falling from this location into the assembly place.
	CALL SetIXtoCurrentRocketElement						; Set IX to current #rocket postion
	LD A, (jo.jetY)
	LD (IX + ROCKET.Y), A

	RET

;----------------------------------------------------------;
;                    #MoveWithJetman                       ;
;----------------------------------------------------------;
; Move the element to the current Jetman's position
MoveWithJetman

	; Set the ID of the sprite for the following commands
	LD A, (IX + ROCKET.SPRITE_ID)
	NEXTREG _SPR_REG_NR_H34, A

	; Set sprite X coordinate
	LD BC, (jo.jetX)
	LD A, C		
	NEXTREG _SPR_REG_X_H35, A					; Set _SPR_REG_NR_H34 with LDB from Jetmans X postion
	
	; Set _SPR_REG_ATR2_H37 containing overflow bit from X position
	LD A, B										; Load MSB from X into A
	AND %00000001								; Keep only an overflow bit
	NEXTREG _SPR_REG_ATR2_H37, A

	; Set Y coordinate
	LD A, (jo.jetY)
	ADD CARRY_ADJUST_Y
	NEXTREG _SPR_REG_Y_H36, A					; Set Y position

	RET
;----------------------------------------------------------;
;                 #AttachRocketElement                     ;
;----------------------------------------------------------;
AttachRocketElement
	; Return if there is no element/tank to pick up
	LD A, (state)
	AND STATE_ELEMET_DEPL_MASK
	CP 0
	RET Z										; Return if A == 0 -> none of the bits is set

	CALL SetIXtoCurrentRocketElement						; Set IX to current #rocket postion

	; Check the collision (pickup possibility) between Jetman and the element, return if there is none	
	LD BC, (IX + ROCKET.DROP_X)					; X of the element
	LD B, 0
	LD D, (IX + ROCKET.Y)						; Y of the element	
	CALL CheckCollision
	CP COLLISION_NO
	RET Z

	; Jetman can pick up rocket element/tank. Update state to reflect it and return
	LD A, (state)
	RES STATE_FALL_BIT, A
	RES STATE_WAIT_BIT, A
	SET STATE_CARRY_BIT, A	
	LD (state), A

	RET
;----------------------------------------------------------;
;                    #CheckCollision                       ;
;----------------------------------------------------------;
; Checks whether Jetman overlaps with rocket element/tank
; Input:
;  - BC: X postion of rocket element
;  - D: Y postion of rocket element
; Output:
;  - A:		COLLISION_NO or COLLISION_YES
COLLISION_NO			= 0
COLLISION_YES			= 1

CheckCollision
	; Compare X coordinate of element and Jetman
	LD B, 0										; X is 8bit -> reset MSB
	LD HL, (jo.jetX)							; X of the Jetman

	; Check whether Jetman is horizontal with the element
	SBC HL, BC	
	CALL ut.AbsHL								; HL contains a positive distance between the enemy and Jetman
	LD A, H
	CP 0
	JR Z, .keepCheckingHorizontal				; HL > 256 -> no collision
	LD A, COLLISION_NO
	RET		
.keepCheckingHorizontal	
	LD A, L
	LD B, COLISION_MARGIN_X
	CP B
	JR C, .checkVertical						; Jump if there is horizontal collision, check vertical
	LD A, COLLISION_NO							; L >= D (Horizontal thickness of the enemy) -> no collision	
	RET
.checkVertical
	
	; We are here because Jemtman's horizontal position matches that of the element, now check vertical
	LD A, (jo.jetY)								; Y of the Jetman

	; Subtracts B from A and check whether the result is less than or equal to #COLISION_MARGIN_Y
	SUB D										; D is method param (Y postion of rocket element)
	CALL ut.AbsA
	LD B, A
	LD A, COLISION_MARGIN_Y
	CP B
	JR NC, .collision							; Jump if A(#COLISION_MARGIN_Y) >= B

.noCollision
	LD A, COLLISION_NO
	RET
.collision
	LD A, COLLISION_YES

	RET	

;----------------------------------------------------------;
;              #RocketElementFallsForPickup                ;
;----------------------------------------------------------;
RocketElementFallsForPickup	
	; Return if there is no fall
	LD A, (state)
	BIT STATE_FALL_BIT, A
	RET Z										; Return if falling bit is not set

	CALL SetIXtoCurrentRocketElement			; Set IX to current #rocket postion	

	; Move element one pixel down
	LD A, (IX + ROCKET.Y)
	INC A
	LD (IX + ROCKET.Y), A

	; Update rocket spirte
	LD A, (IX + ROCKET.DROP_X)					; Sprite X coordinate, do not change value - element is falling down
	CALL UpdateElementPosition

	; Has the horizontal destination been reached?
	LD B, A
	LD A, (IX + ROCKET.DROP_LAND_Y)
	CP B
	RET NZ										; No, keep falling down
	
	; Yes, element has reached landing postion
	LD A, (state)
	RES STATE_FALL_BIT, A
	SET STATE_WAIT_BIT, A
	LD (state), A

	RET

;----------------------------------------------------------;
;                  #AnimateRocketReady                     ;
;----------------------------------------------------------;
AnimateRocketReady	
	; Return if rocket is not ready
	LD A, (state)
	AND STATE_ELEMET_READY_MASK
	CP STATE_CNT_ASSEMBLED
	RET NZ	

	; Set the ID of the sprite for the following commands
	LD A, ROCKET_DOWN_SPR_ID
	NEXTREG _SPR_REG_NR_H34, A

	; Set sprite pattern - one for flip, one for flop -> rocket will blink waiting for Jetman	
	LD A, (cd.counter10FliFLop)
	CP cd.FLIP_ON
	JR Z, .flip
	LD A, ROCKET_SPR_ID_READY1
	JR .afterSet
.flip	
	LD A, ROCKET_SPR_ID_READY2
.afterSet
	OR _SPR_PATTERN_SHOW						; Set visibility bit
	NEXTREG _SPR_REG_ATR3_H38, A

	RET
;----------------------------------------------------------;
;             #RocketElementFallsForAssembly               ;
;----------------------------------------------------------;
RocketElementFallsForAssembly	
	; Return if there is no assebly
	LD A, (state)
	BIT STATE_ASSEMBLY_BIT, A
	RET Z										; Return if assembky bit is not set

	CALL SetIXtoCurrentRocketElement						; Set IX to current #rocket postion	

	; Set the ID of the sprite for the following commands
	LD A, (IX + ROCKET.SPRITE_ID)
	NEXTREG _SPR_REG_NR_H34, A

	; Sprite X coordinate to assembly location
	LD A, (rocketAssemblyX)
	NEXTREG _SPR_REG_X_H35, A

	; Set sprite pattern	
	LD A, (IX + ROCKET.SPRITE_REF)
	OR _SPR_PATTERN_SHOW						; Set show bit
	NEXTREG _SPR_REG_ATR3_H38, A

	; Sprite Y coordinate, increment until the destination has been reached
	LD A, (IX + ROCKET.Y)
	INC A
	LD (IX + ROCKET.Y), A
	NEXTREG _SPR_REG_Y_H36, A

	; Has the horizontal destination been reached?
	LD B, A
	LD A, (IX + ROCKET.ASSEMBLY_Y)
	CP B
	RET NZ										; No, keep falling down
	
	; Yes, element has reached landing postion, set state for next drop
	LD A, (state)
	RES STATE_ASSEMBLY_BIT, A
	LD (state), A

	; Hide the fuel tank sprite if we drop fuel, and change rocket sprite showing fuel level.
	LD A, (state)
	AND STATE_ELEMET_CNT_MASK
	CP STATE_CNT_FUEL_MIN
	JR C, .notFuel								; Jump if counter is < 3 (still assembling rocket)

	; We are dropping fuel already

	; Hide the fuel sprite as it has reached the rocket
	LD A, _SPR_PATTERN_HIDE
	NEXTREG _SPR_REG_ATR3_H38, A

	; Switch the lower rocket sprite to reflect the fueling level
	CALL MoveIXtoCurrentFuelLevel

	; Set the ID of the sprite for the following commands
	LD A, ROCKET_DOWN_SPR_ID
	NEXTREG _SPR_REG_NR_H34, A

	; Set sprite pattern	
	LD A, (IX + FUEL_LEVEL.SPRITE_REF)
	OR _SPR_PATTERN_SHOW						; Set visibility bit
	NEXTREG _SPR_REG_ATR3_H38, A

.notFuel	
	RET

;----------------------------------------------------------;
;               #DropNextRocketElement                     ;
;----------------------------------------------------------;
DropNextRocketElement
	; Do not drop the next element if there is one that is ongoing.
	LD A, (state)
	AND STATE_DROP_NEXT_MASK					; Apply a mask to reset bits indicating the rocket is ready or the element is deployed
	CP 0
	RET NZ

	; Do not drop next element, if rocket is ready (element counter is 7)
	LD A, (state)
	AND STATE_ELEMET_CNT_MASK
	CP STATE_CNT_ASSEMBLED
	RET Z	

	; Increment delay counter and check whether it's already time to process with the next rocket element/tank
	LD A, (dropNextDelay)
	INC A
	LD (dropNextDelay), A
	CP DROP_NEXT_DELAY_MAX
	RET NZ										; Jump if #nextCnt !=  #DROP_NEXT_MAX 

	; The counter has reached the required value, reset it first
	LD A, 0
	LD (dropNextDelay), A

	; Check whether rocket element counter has already reached max value
	LD A, (state)
	AND STATE_ELEMET_CNT_MASK
	CP STATE_CNT_ELEMET_MAX
	JR NZ, .dropNext							; Jump if the counter did not reach max value	

	; The rocket is assembled and fueled
	LD A, STATE_CNT_ASSEMBLED
	LD (state), A
	RET

.dropNext
	; Increment element counter
	LD A, (state)
	INC A

	; We are going to drop the next element -> set falling and reset waiting for pickup
	SET STATE_FALL_BIT, A
	RES STATE_WAIT_BIT, A
	LD (state), A

	; Drop next rocket element/tank, first set IX to current #rocket postion
	CALL SetIXtoCurrentRocketElement

	; Reset Y for element/tank to top of the screen
	LD A, 0
	LD (IX + ROCKET.Y), A
	
	RET	

;----------------------------------------------------------;
;              #SetIXtoCurrentRocketElement                ;
;----------------------------------------------------------;
; Set IX to current #rocket postion
SetIXtoCurrentRocketElement
	; Load the pointer to #rocket into IX and move the pointer to the actual rocket element
	LD IX, rocket

    ; Now, move IX so that it points to the #ROCKET given by the deploy counter. First, load the counter into A (value 1-3).
	; Afterward, load A indo D and the size of the #ROCKET into E, and multiply D by E. 
	LD A, (state)
	AND	STATE_ELEMET_CNT_MASK						; A contains 1-3

	; Return if the counter is 0 -> it has not been initialized yet
	CP 0
	RET Z

	CALL MoveIXtoGivemRocketElement

	RET	

;----------------------------------------------------------;
;                MoveIXtoGivemRocketElement                ;
;----------------------------------------------------------;
; Input:
;  -A:	rocket element from 1 to 3
MoveIXtoGivemRocketElement
	; Load the pointer to #rocket into IX and move the pointer to the actual rocket element
	LD IX, rocket

	SUB 1											; A contains 0-2
	LD D, A
	LD E, ROCKET									; D contains A, E contains size of #ROCKET
	MUL D, E										; DE contains D * E
	ADD IX, DE										; IX points to active #rocket (#ROCKET)

	RET	

;----------------------------------------------------------;
;             #MoveIXtoCurrentFuelLevel                    ;
;----------------------------------------------------------;
; Set IX to current #fuel postion
MoveIXtoCurrentFuelLevel
	; Load the pointer to #rocket into IX and move the pointer to the actual rocket element
	LD IX, fuelLevel								; IX contains pointer

    ; Now, move IX so that it points to the #FUEL_LEVEL given by the deploy counter. First, load the counter into A (value 3-6), sub 4
	; Afterward, load A indo D and the size of the #FUEL_LEVEL into E, and multiply D by E. 
	LD A, (state)
	AND	STATE_ELEMET_CNT_MASK						; A contains 4-6
	SUB STATE_CNT_FUEL_MIN							; A contains 0-2

	LD D, A
	LD E, FUEL_LEVEL										; D contains A, E contains size of #FUEL_LEVEL
	MUL D, E										; DE contains D * E
	ADD IX, DE										; IX points to active #rocket (#FUEL_LEVEL)

	RET	

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE