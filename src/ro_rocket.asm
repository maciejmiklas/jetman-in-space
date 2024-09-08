;----------------------------------------------------------;
;               Building and Flying the Rocket             ;
;----------------------------------------------------------;
	MODULE ro

; Number of Counter40 cycles to drop next rocket module
DROP_NEXT_DELAY_MAX		= 10
dropNextDelay			BYTE 0

; The state is used to build the rocket and then bring fuel to it. Building the rocket requires three elements, as does fueling it. 
; It's basically the same process, but Jetman is carrying either rocket elements or fuel tanks. Bit 7 determines whether Jetman is building 
; the rocket or already carries fuel. 
; Bits:
;  - 1-0: Current rocket element (or fuel tank), values 1-3
;  - 2  : Rocket element (or fuel tank) is falling down
;  - 3  : Rocket element (or fuel tank) is waiting for pickup
;  - 4  : Jetman carries rocket element (or fuel tank)
;  - 5  : The rocket is fully assembled and waiting for fuel, or it is already fully tanked and waiting to start
;  - 6  : 1 - building rocket, 0 - bringing fuel
;  - 7  : Not used
state					BYTE %01000000		; Start with building first rocket element

STATE_FALL_BIT			= 2
STATE_WAIT_BIT			= 3
STATE_CARRY_BIT			= 4
STATE_READY_BIT			= 5
STATE_ROCKET_BIT		= 6

STATE_DROP_NEXT_MASK	= %0'0'1'111'00			; Dorp next element if the rocket is not fully assembled and no element is deployed at the moment
STATE_ELEMET_CNT_MASK	= %000000'11			; Reset all bits except the counter
STATE_ELEMET_DEPL_MASK	= %0000'11'00			; Jetman can pick up element/tank.

STATE_ELEMET_CNT_MAX	= 3

MAX_ELEMENTS			= 3

; The single rocket element or fule tank
	STRUCT RDA
; Configuration values	
DROP_X					BYTE					; X coordinate to drop the given element/tank
LAND_Y					BYTE 					; Y coordinates where the dropped element/tank should land. Usually, it's the height of the platform/ground
SPRITE_ID				BYTE					; Next ID of the sprite
SPRITE_REF				BYTE					; ID of the Sprite from spr-file.

; Values set in program
Y						BYTE					; Current Y position
	ENDS

rocket
	RDA {050/*DROP_X*/, 100/*LAND_Y*/, 40/*SPRITE_ID*/, 60/*SPRITE_REF*/, 0/*Y*/}
	RDA {070/*DROP_X*/, 225/*LAND_Y*/, 41/*SPRITE_ID*/, 56/*SPRITE_REF*/, 0/*Y*/}
	RDA {120/*DROP_X*/, 137/*LAND_Y*/, 42/*SPRITE_ID*/, 52/*SPRITE_REF*/, 0/*Y*/}

rocketAssemblyX			BYTE 220
COLISION_MARGIN			= 12
CARRY_ADJUST_Y			= 10
;----------------------------------------------------------;
;                #UpdateOnJetmanMove                       ;
;----------------------------------------------------------;
UpdateOnJetmanMove
	CALL AttachRocketElement
	CALL CarryRocketElement

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

	; First reset state
	RES STATE_CARRY_BIT, A
	DEC A										; Go back to previous element
	LD (state), A

	CALL MoveIXtoCurrentRDA

	; Reset drop delay
	LD A, 0
	LD (dropNextDelay), A

	; Hide Sprite

	; Set the ID of the sprite for the following commands
	LD A, (IX + RDA.SPRITE_ID)
	NEXTREG _SPR_REG_NR_H34, A

	LD A, _SPR_PATTERN_HIDE						; Hide sprite on display	
	NEXTREG _SPR_REG_ATR3_H38, A

	RET

;----------------------------------------------------------;
;                  #CarryRocketElement                     ;
;----------------------------------------------------------;
CarryRocketElement
	
	; Return if the state does not match
	LD A, (state)
	BIT STATE_CARRY_BIT, A
	RET Z

	CALL MoveIXtoCurrentRDA
	CALL MoveWithJetman

	RET

;----------------------------------------------------------;
;                    #MoveWithJetman                       ;
;----------------------------------------------------------;
; Move the element to the current Jetman's position
MoveWithJetman

	; Set the ID of the sprite for the following commands
	LD A, (IX + RDA.SPRITE_ID)
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

	CALL MoveIXtoCurrentRDA						; Set IX to current #rocket postion

	; Check the collision (pickup possibility) between Jetman and the element, return if there is none
	CALL CheckCollision
	CP COLLISION_NO
	RET Z

	; Jetman can pick up rocket element/tank. Update state to reflect it and return.  
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
; Output:
;  - A:		COLLISION_NO or COLLISION_YES
COLLISION_NO			= 0
COLLISION_YES			= 1

CheckCollision
	; Compare X coordinate of element and Jetman
	LD BC, (IX + RDA.DROP_X)					; X of the element
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
	LD B, COLISION_MARGIN
	CP B
	JR C, .checkVertical						; Jump if there is horizontal collision, check vertical
	LD A, COLLISION_NO							; L >= D (Horizontal thickness of the enemy) -> no collision	
	RET
.checkVertical
	
	; We are here because Jemtman's horizontal position matches that of the element, now check vertical
	LD B, (IX + RDA.Y)							; Y of the element
	LD A, (jo.jetY)								; Y of the Jetman

	; Is Jemtan above or below the element?
	CP B
	JR C, .jetmanAboveElement					; Jump if "Jet Y" < "element Y". Jet is above element (0 is at the top, 256 bottom)

	; Jetman is below element
	SUB B
	CP COLISION_MARGIN
	JR C, .collision							; Jump if A - B < D
	JR .noCollision

.jetmanAboveElement
	; Jetman is above element

	; Swap A and B (compared to above) to avoid negative value
	LD A, (jo.jetY)
	LD B, A										; B: Y of the Jetman
	LD A, (IX + RDA.Y)							; A: Y of the element
	SUB B
	CP COLISION_MARGIN
	JR C, .collision
	JR .noCollision

.noCollision
	LD A, COLLISION_NO
	RET
.collision
	LD A, COLLISION_YES

	RET	

;----------------------------------------------------------;
;                 #RocketElementFalls                      ;
;----------------------------------------------------------;
RocketElementFalls	
	; Return if there is no movement
	LD A, (state)
	BIT STATE_FALL_BIT, A
	RET Z										; Return if movement bit is not set

	CALL MoveIXtoCurrentRDA						; Set IX to current #rocket postion	

	; Set the ID of the sprite for the following commands
	LD A, (IX + RDA.SPRITE_ID)
	NEXTREG _SPR_REG_NR_H34, A

	; Sprite X coordinate, do not change value - element is falling down
	LD A, (IX + RDA.DROP_X)
	NEXTREG _SPR_REG_X_H35, A

	; Set sprite pattern	
	LD A, (IX + RDA.SPRITE_REF)
	OR _SPR_PATTERN_SHOW						; Store pattern number into Sprite Attribute	
	NEXTREG _SPR_REG_ATR3_H38, A

	; Sprite Y coordinate, increment until the destination has been reached
	LD A, (IX + RDA.Y)
	INC A
	LD (IX + RDA.Y), A
	NEXTREG _SPR_REG_Y_H36, A

	; Has the horizontal destination been reached?
	LD B, A
	LD A, (IX + RDA.LAND_Y)
	CP B
	RET NZ										; No, keep falling down
	
	; Yes, element has reached landing postion
	LD A, (state)
	RES STATE_FALL_BIT, A
	SET STATE_WAIT_BIT, A
	LD (state), A

	RET

;----------------------------------------------------------;
;               #DropNextRocketElement                     ;
;----------------------------------------------------------;
DropNextRocketElement
	LD A, (state)
	AND STATE_DROP_NEXT_MASK					; Apply a mask to reset bits indicating the rocket is ready or the element is deployed
	CP 0
	RET NZ

	; Increment delay counter and check whether it's already time to process with the next rocket element/tank
	LD A, (dropNextDelay)
	INC A
	LD (dropNextDelay), A
	CP DROP_NEXT_DELAY_MAX
	RET NZ										; Jump if #nextCnt !=  #DROP_NEXT_MAX 

	; The counter has reached the required value, reset it first
	LD A, 0
	LD (dropNextDelay), A

	; Check whether element counter has already reached max value
	LD A, (state)
	AND STATE_ELEMET_CNT_MASK
	CP STATE_ELEMET_CNT_MAX
	JR NZ, .dropNext							; Jump if the counter did not reach max value
	
	; The Counter has reached its maximum value; if the rocket is ready, it's time to start dropping fuel. Otherwise, it is fueled and ready to go
	LD A, $AA
	nextreg 2,8

.dropNext
	; Increment element counter
	LD A, (state)
	INC A

	; We are going to drop the next element -> set falling and reset waiting for pickup
	SET STATE_FALL_BIT, A
	RES STATE_WAIT_BIT, A
	LD (state), A

	; Determine whether we should drop the next rocket element or the next fuel tank
	BIT STATE_READY_BIT, A
	JR NZ, .dropFuel

	; Drop next rocket element, first set IX to current #rocket postion
	CALL MoveIXtoCurrentRDA

	; Reset Y for element/tank to top of the screen
	LD A, 0
	LD (IX + RDA.Y), A

	JR .afterDrop
.dropFuel
	; Drop next fuel element
	LD A, $CC
	nextreg 2,8

.afterDrop
	
	RET	

;----------------------------------------------------------;
;                 #MoveIXtoCurrentRDA                      ;
;----------------------------------------------------------;
; Set IX to current #rocket postion
MoveIXtoCurrentRDA
	; Load the pointer to #rocket into IX and move the pointer to the actual rocket element
	LD IX, rocket									; IX contains pointer

    ; Now, move IX so that it points to the #RDA given by the deploy counter. First, load the counter into A (value 1-3).
	; Afterward, load A indo D and the size of the #RDA into E, and multiply D by E. 
	LD A, (state)
	AND	STATE_ELEMET_CNT_MASK						; A contains 1-3

	; Return if the counter is 0 -> it has not been initialized yet
	CP 0
	RET Z

	SUB 1											; A contains 0-2
	LD D, A
	LD E, RDA										; D contains A, E contains size of #RDA
	MUL D, E										; DE contains D * E
	ADD IX, DE										; IX points to active #rocket (#RDA)

	RET	
;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE