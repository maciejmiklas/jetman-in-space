;----------------------------------------------------------;
;               Building and Flying the Rocket             ;
;----------------------------------------------------------;
	MODULE ro

; Number of GameLoop040 cycles to drop next rocket module.
dropNextDelay			BYTE 0

rocketElementCnt		BYTE _RO_EL_TANK1_D4 ;0 					; Counts from _RO_EL_LOW_D1 to _RO_EL_TANK3_D6, both inclusive.

rocketState				BYTE RO_ST_READY ;RO_ST_WAIT_DROP

RO_ST_INACTIVE			= 0
RO_ST_WAIT_DROP			= 1						; Rocket element (or fuel tank) is waiting for drop from the sky. This is initial state.

RO_ST_FALL_PICKUP		= 10					; Rocket element (or fuel tank) is falling down for pickup.
RO_ST_FALL_ASSEMBLY		= 11					; The rocket element (or fuel tank) falls towards the rocket for assembly.
RO_ST_WAIT_PICKUP		= 12					; Rocket element (or fuel tank) is waiting for pickup.
RO_ST_CARRY				= 13					; Jetman carries rocket element (or fuel tank).
RO_ST_TANK_EXPLODE		= 14

RO_ST_READY				= 100					; Rocket is ready to start and waits only for Jetman.
RO_ST_FLY				= 101					; The rocket is flying towards an unknown planet.
RO_ST_EXPLODE			= 102					; Rocket explodes after hitting something.

; The single rocket element or fule tank.
; The X coordinate of the rocket element is stored in two locations: 
;  1) #RO.DROP_X: when elements drop for pickup by Jetman,
;  2) #rocketAssemblyX when building the rocket
	STRUCT RO
; Configuration values	
DROP_X					BYTE					; X coordinate to drop the given element/tank, max 255.
DROP_LAND_Y				BYTE 					; Y coordinates where the dropped element/tank should land. Usually, it's the height of the platform/ground.
ASSEMBLY_Y				BYTE					; Height where given rocket element should land for assembly.
SPRITE_ID				BYTE					; Hardware ID of the sprite.
SPRITE_REF				BYTE					; Sprite pattern number from the sprite file.

; Values set in program
Y						BYTE					; Current Y position.
	ENDS

rocketEl
; rocket element
	RO {050/*DROP_X*/, 100/*DROP_LAND_Y*/, 227/*ASSEMBLY_Y*/, _RO_DOWN_SPR_ID_D50/*SPRITE_ID*/, 60/*SPRITE_REF*/, 233/* !!!! 0Y*/}	; bottom element
	RO {072/*DROP_X*/, 227/*DROP_LAND_Y*/, 211/*ASSEMBLY_Y*/,                 51/*SPRITE_ID*/, 56/*SPRITE_REF*/, 217/*Y*/}	; middle element
	RO {120/*DROP_X*/, 147/*DROP_LAND_Y*/, 195/*ASSEMBLY_Y*/,                 52/*SPRITE_ID*/, 52/*SPRITE_REF*/, 201/*Y*/}	; top of the rocket
; fuel tank
	RO {030/*DROP_X*/, 099/*DROP_LAND_Y*/, 226/*ASSEMBLY_Y*/, 43/*SPRITE_ID*/, 51/*SPRITE_REF*/, 0/*Y*/}
	RO {110/*DROP_X*/, 147/*DROP_LAND_Y*/, 226/*ASSEMBLY_Y*/, 43/*SPRITE_ID*/, 51/*SPRITE_REF*/, 0/*Y*/}
	RO {230/*DROP_X*/, 059/*DROP_LAND_Y*/, 226/*ASSEMBLY_Y*/, 43/*SPRITE_ID*/, 51/*SPRITE_REF*/, 0/*Y*/}

rocketAssemblyX			BYTE 170

expolodeTankDB 			DB 30, 31, 32, 33		; Sprite IDs for explosion.
expolodeTankCnt			BYTE 0					; Current position in #expolodeFuel.
EXPLODE_TANK_MAX		= 4						; The amount of explosion sprites.

rocketExhaustDB									; Sprite IDs for exhaust
	DB 53,57,62,  57,62,53,  62,53,57,  53,62,57,  62,57,53,  57,53,62

rocketExhaustCnt		BYTE 0					; Counts from 0 (inclusive) to #RO_EXHAUST_MAX (exclusive).
RO_EXHAUST_MAX			= 18

rocketDistance			WORD 0					; Increments with every rocket move when the rocket is flying towards the next planet.

rocketDelayDistance		BYTE 0					; Counts from 0 to _RO_FLY_DELAY_DIST_D5, increments with every rocket move (when #rocketFlyDelay resets).
rocketFlyDelay			BYTE _RO_FLY_DELAY_D8	; Counts from #rocketFlyDelayCnt to 0, decrementss with every skipped rocket move.
rocketFlyDelayCnt		BYTE _RO_FLY_DELAY_D8	; Counts from _RO_FLY_DELAY_D8 to 0, decrementss when #rocketDelayDistance resets.

; Three explode DBs for three rocket elements.
rocketExplodeDB1		DB 60,60,60,60, 60,60,60,60, 30,31,32,31, 30,32,31,31, 30,31,32,33	; bottom element
rocketExplodeDB2		DB 56,56,56,56, 30,31,32,31, 30,31,32,31, 32,30,32,31, 30,31,32,33	; middle element
rocketExplodeDB3		DB 30,31,32,31, 30,31,32,31, 30,31,32,31, 30,32,31,30, 30,31,32,33	; top of the rocket

rocketExplodeCnt		BYTE 0					; Counts from 1 to RO_EXPLODE_MAX (both inclusice).
RO_EXPLODE_MAX			= 18					; Amount of explosion frames stored in #rocketExplodeDB[1-3].

;----------------------------------------------------------;
;                  #StartRocketAssembly                    ;
;----------------------------------------------------------;
StartRocketAssembly

	CALL ResetAndDisableRocket

	LD A, RO_ST_WAIT_DROP
	LD (rocketState), A

	RET											; ## END of the function ##
;----------------------------------------------------------;
;                #ResetAndDisableRocket                    ;
;----------------------------------------------------------;
ResetAndDisableRocket

	XOR A
	LD (rocketState), A
	LD (expolodeTankCnt), A
	LD (rocketExplodeCnt), A
	LD (rocketElementCnt), A

	LD HL, 0
	LD (rocketDistance), HL
	
	; ##########################################
	LD A, _RO_FLY_DELAY_D8
	LD (rocketFlyDelay), A
	LD (rocketFlyDelayCnt), A

	; ##########################################
	; Reset rocket elements
	LD B, _RO_EL_TANK3_D6
.rocketElLoop
	LD A, B
	LD IX, rocketEl
	CALL MoveIXtoGivenRocketElement

	XOR A
	LD (IX + RO.Y), A

	DJNZ .rocketElLoop

	RET											; ## END of the function ##

;----------------------------------------------------------;
;             #UpdateRocketOnJetmanMove                    ;
;----------------------------------------------------------;
UpdateRocketOnJetmanMove

	CALL PickupRocketElement
	CALL CarryRocketElement
	CALL BoardRocket

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                     #BoardRocket                         ;
;----------------------------------------------------------;
BoardRocket

	; Return if rocket is not ready for boarding.
	LD A, (rocketState)
	CP RO_ST_READY
	RET NZ
	
	; ##########################################
	; Jetman collision with first (lowest) rocket element triggers take off.
	LD IX, rocketEl

	LD BC, (rocketAssemblyX)					; X of the element.
	LD B, 0
	LD D, (IX + RO.Y)							; Y of the element.
	CALL JetmanElementCollision
	CP COLLISION_NO
	RET Z

	; ##########################################
	; Jetman boards the rocket!
	LD A, RO_ST_FLY
	LD (rocketState), A

	CALL gc.RocketTakesOff

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                #StartRocketExplosion                     ;
;----------------------------------------------------------;
; Start explosion sequece. The rocket explodes when the state is flying and counter above zero.
StartRocketExplosion

	LD A, 1
	LD (rocketExplodeCnt), A

	; ##########################################
	; Hide exhaust
	LD A, _RO_EXHAUST_SPRID_D43					; Hide sprite on display.
	CALL sp.SetIdAndHideSprite

	; ##########################################
	; Update state
	LD A, RO_ST_EXPLODE
	LD (rocketState), A
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                     #HideRocket                          ;
;----------------------------------------------------------;
HideRocket

	; Hide the top rockets element.
	LD IX, rocketEl
	LD A, _RO_EL_TOP_D3
	CALL MoveIXtoGivenRocketElement

	LD A, (IX + RO.SPRITE_ID)
	CALL sp.SetIdAndHideSprite

	; ##########################################
	; Hide the middle rockets element.
	LD IX, rocketEl
	LD A, _RO_EL_MID_D2
	CALL MoveIXtoGivenRocketElement

	LD A, (IX + RO.SPRITE_ID)
	CALL sp.SetIdAndHideSprite

	; ##########################################
	; Hide the bottom rockets element.
	LD IX, rocketEl
	LD A, _RO_EL_LOW_D1
	CALL MoveIXtoGivenRocketElement

	LD A, (IX + RO.SPRITE_ID)
	CALL sp.SetIdAndHideSprite

	RET											; ## END of the function ##

;----------------------------------------------------------;
;              #AdminateRocketExplosion                    ;
;----------------------------------------------------------;
AdminateRocketExplosion

	; Is rocket exploding ?
	LD A, (rocketState)
	CP RO_ST_EXPLODE
	RET NZ
	
	; ##########################################
	; Is the exploding sequence over?
	LD A, (rocketExplodeCnt)
	CP RO_EXPLODE_MAX
	JR Z, .explodingEnds
	; Nope, keep exploding

	; ##########################################
	; Animation for the top rockets element.
	LD IX, rocketEl
	LD A, _RO_EL_TOP_D3
	CALL MoveIXtoGivenRocketElement

	; Move HL to current frame.
	LD DE, (rocketExplodeCnt)
	LD D, 0										; Reset D, we have an 8-bit counter here.
	LD HL, rocketExplodeDB3
	DEC DE										; Counter starts at 1.
	ADD HL, DE
	LD D, (HL)
	CALL UpdateSpritePattern

	; ##########################################
	; Animation for the middle rockets element.
	LD IX, rocketEl
	LD A, _RO_EL_MID_D2
	CALL MoveIXtoGivenRocketElement

	; Move HL to current frame.
	LD DE, (rocketExplodeCnt)
	LD D, 0										; Reset D, we have an 8-bit counter here.
	LD HL, rocketExplodeDB2
	DEC DE										; Counter starts at 1.
	ADD HL, DE
	LD D, (HL)
	CALL UpdateSpritePattern

	; ##########################################
	; Animation for the bottom rockets element.
	LD IX, rocketEl
	LD A, _RO_EL_LOW_D1
	CALL MoveIXtoGivenRocketElement

	; Move HL to current frame
	LD DE, (rocketExplodeCnt)
	LD D, 0										; Reset D, we have an 8-bit counter here.
	LD HL, rocketExplodeDB1
	DEC DE										; Counter starts at 1.
	ADD HL, DE
	LD D, (HL)
	CALL UpdateSpritePattern

	; ##########################################
	; Update explosion frame counter.
	LD A, (rocketExplodeCnt)
	INC A
	LD (rocketExplodeCnt), A

	RET
.explodingEnds
	; Sequecen is over, load next level.
	CALL gc.RocketExplosionOver

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                     #CheckHitTank                        ;
;----------------------------------------------------------;
; Checks falling tank for collision with leaser beam.
CheckHitTank

	; Is the thank out there?
	LD A, (rocketElementCnt)
	CP _RO_EL_TANK1_D4
	RET C										; Return if counter is < 4 (still assembling rocket).

	; Is tank already exploding?
	LD A, (rocketState)
	CP RO_ST_TANK_EXPLODE
	RET Z										; Return if tank is already exploding.

	; ##########################################
	; Check hit by leaser beam.
	CALL SetIXtoCurrentRocketElement

	; The X coordinate of the rocket element is stored in two locations: 
	;  1) #RO.DROP_X: when elements drop for pickup by Jetman,
	;  2) #rocketAssemblyX when building the rocket
	LD A, (rocketState)
	CP RO_ST_FALL_ASSEMBLY
	JR Z, .assembly
	
	; Dropping rocket element for pickup.
	LD DE, (IX + RO.DROP_X)						; X param for #ShotsColision.
	JR .afterAssembly
.assembly
	; The rocket is already assembled and waiting for fuel.
	LD DE, (rocketAssemblyX)					; X param for #ShotsColision.
.afterAssembly

	LD D, 0										; Reset D, X coordinate for drop is 8 bit.

	LD C,  (IX + RO.Y)							; Y param for #ShotsColision.
	CALL jw.ShotsColision
	CP jw.SHOT_HIT
	RET NZ

	; ##########################################
	; The laser beam hits the falling rocket tank!
	XOR A
	LD (expolodeTankCnt), A

	LD A, RO_ST_TANK_EXPLODE
	LD (rocketState), A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #AnimateTankExplode                     ;
;----------------------------------------------------------;
AnimateTankExplode

	; Return if tank is not exploding.
	LD A, (rocketState)
	CP RO_ST_TANK_EXPLODE
	RET NZ

	; Is explosion over?
	LD A, (expolodeTankCnt)
	CP EXPLODE_TANK_MAX
	JR NZ, .keepExploding

	; Exloding is over.
	LD A, RO_ST_WAIT_DROP
	LD (rocketState), A

	CALL ResetRocketElement
	RET

.keepExploding

	CALL SetIXtoCurrentRocketElement

	; Set the ID of the sprite for the following commands.
	LD A, (IX + RO.SPRITE_ID)
	NEXTREG _SPR_REG_NR_H34, A
	
	; Move #expolodeTankDB by #expolodeTankCnt, so that A points to current explosion frame.
	LD A, (expolodeTankCnt)
	LD B, A
	LD A, (expolodeTankDB)
	ADD B

	; Set sprite pattern.
	OR _SPR_PATTERN_SHOW						; Set show bit.
	NEXTREG _SPR_REG_ATR3_H38, A

	; Increment #expolodeTankCnt.
	LD A, (expolodeTankCnt)
	INC A
	LD (expolodeTankCnt), A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                 #AnimateRocketExhaust                    ;
;----------------------------------------------------------;
AnimateRocketExhaust

	; Return if rocket is not flying.
	LD A, (rocketState)
	CP RO_ST_FLY
	RET NZ

	; Increment sprite pattern counter.
	LD A, (rocketExhaustCnt)
	INC A
	CP RO_EXHAUST_MAX
	JP NZ, .afterIncrement
	XOR A										; Reset counter.
.afterIncrement	

	LD (rocketExhaustCnt), A					; Store current counter (incrementd or reset).

	; Set the ID of the sprite for the following commands.
	LD A, _RO_EXHAUST_SPRID_D43
	NEXTREG _SPR_REG_NR_H34, A

	; Load spirte pattern to A.
	LD HL, rocketExhaustDB
	LD A, (rocketExhaustCnt)
	ADD HL, A
	LD A, (HL)

	; Set sprite pattern.
	OR _SPR_PATTERN_SHOW						; Set show bit.
	NEXTREG _SPR_REG_ATR3_H38, A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                   #BlinkRocketReady                      ;
;----------------------------------------------------------;
BlinkRocketReady

	; Return if rocket is not flying.
	LD A, (rocketState)
	CP RO_ST_FLY
	RET NZ
		
	LD A, _RO_EL_LOW_D1
	CALL MoveIXtoGivenRocketElement

	; Set sprite pattern - one for flip, one for flop -> rocket will blink.
	LD A, (gld.counter008FliFLop)
	CP _GC_FLIP_ON_D1
	JR Z, .flip
	LD A, _RO_SPR_PAT_READY1_D60
	JR .afterSet
.flip	
	LD A, _RO_SPR_PAT_READY2_D61
.afterSet
	
	LD (IX + RO.SPRITE_REF), A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #MoveFlyingRocket                       ;
;----------------------------------------------------------;
MoveFlyingRocket

	; Slow down rocket movement speed while taking off. 
	; The rocket slowly accelerates, and the whole process is divided into sections. During each section, the rocket travels some distance 
	; with a given delay. When the current section ends, the following section begins, but with decrementd delay. During each section, 
	; the rocket moves by the same amount of pixels on the Y axis, only the delay decrements with each following section.

	; #rocketFlyDelayCnt == 0 when the whole delay sequence is over.
	LD A, (rocketFlyDelayCnt)
	CP 0
	JR Z, .afterDelay

	; Decrement delay counter.
	LD A, (rocketFlyDelay)
	DEC A
	LD (rocketFlyDelay), A

	CP 0
	RET NZ										; Return if delay counter has not been reached.
	
	; The counter reached 0, reset it and increment the distance counter.
	LD A, (rocketFlyDelayCnt)
	LD (rocketFlyDelay), A

	LD A, (rocketDelayDistance)
	INC A
	LD (rocketDelayDistance), A

	; Has the traveled distance of the rocket with the current delay been reached?
	CP _RO_FLY_DELAY_DIST_D5
	JR NZ, .afterDelay							; Jump if rocket should still move with current delay.

	; The rocket traveled far enough, decrement the delay for the next section.
	LD A, (rocketFlyDelayCnt)
	DEC A
	LD (rocketFlyDelayCnt), A
	LD (rocketFlyDelay), A

	XOR A
	LD (rocketDelayDistance), A
.afterDelay

	; ##########################################
	; Increment total distance.
	LD HL, (rocketDistance)
	INC HL
	LD (rocketDistance), HL

	; ##########################################
	; Has the rocket reached the asteroid, and should the explosion sequence begin?
	LD A, H
	CP _RO_EXPLODE_Y_HI_H4
	JR NZ, .notAtAsteroid

	LD A, L
	CP _RO_EXPLODE_Y_LO_H7E
	JR C, .notAtAsteroid

	CALL StartRocketExplosion
	RET
.notAtAsteroid

	; ##########################################
	; The current position of rocket elements is stored in #rocketAssemblyX and #RO.Y 
	; It was set when elements were falling towards the platform. Now, we need to decrement Y to animate the rocket.
	
	LD IX, rocketEl								; Load the pointer to #rocket into IX

	; ##########################################
	; Did the rocket reach the middle of the screen, and should it stop moving?
	LD A, (IX + RO.Y)
	CP _RO_MOVE_STOP_D120
	JR NC, .keepMoving

	; Do not move the rocket anymore, but keep updating the lower part to keep blinking animation.
	LD A, (rocketAssemblyX)
	CALL UpdateElementPosition
	RET
.keepMoving
	; Keep moving

	; ##########################################
	; Move bottom rocket element (nr.1).
	LD A, (IX + RO.Y)

	DEC A
	LD (IX + RO.Y), A

	LD A, (rocketAssemblyX)
	CALL UpdateElementPosition

	; ##########################################
	; Move middle rocket element.
	LD A, _RO_EL_MID_D2
	CALL MoveIXtoGivenRocketElement

	LD A, (IX + RO.Y)
	DEC A
	LD (IX + RO.Y), A

	LD A, (rocketAssemblyX)
	CALL UpdateElementPosition

	; ##########################################
	; Move top rocket element.
	LD A, _RO_EL_TOP_D3
	CALL MoveIXtoGivenRocketElement

	LD A, (IX + RO.Y)
	DEC A
	LD (IX + RO.Y), A
	
	LD A, (rocketAssemblyX)
	CALL UpdateElementPosition

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       #FlyRocket                         ;
;----------------------------------------------------------;
FlyRocket

	; Return if rocket is not flying.
	LD A, (rocketState)
	CP RO_ST_FLY
	RET NZ

	CALL MoveFlyingRocket

	; ##########################################
	; Flames coming out of the exhaust.
	LD A, _RO_EXHAUST_SPRID_D43
	NEXTREG _SPR_REG_NR_H34, A					; Set the ID of the sprite for the following commands.

	; Sprite X coordinate from assembly location.
	LD A, (rocketAssemblyX)
	NEXTREG _SPR_REG_X_H35, A

	LD A, _SPR_REG_ATR2_EMPTY
	NEXTREG _SPR_REG_ATR2_H37, A

	; Sprite Y coordinate.
	LD IX, rocketEl
	LD A, (IX + RO.Y)							; Lowest rocket element + 16px.
	ADD A, _RO_FLAME_OFFSET_D16
	NEXTREG _SPR_REG_Y_H36, A

	CALL js.HideJetSprite						; Keep hiding Jemtan sprite, just in case oter procedure would show it.

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                 #UpdateElementPosition                   ;
;----------------------------------------------------------;
; Input:
;  - IX:	Current #RO pointer
;  - A:		X postion
UpdateElementPosition

	LD B, A										; Backup A.

	LD D, (IX + RO.SPRITE_REF)
	CALL UpdateSpritePattern

	; ##########################################
	; Sprite X coordinate from A param
	LD A, B										; Restore A.
	NEXTREG _SPR_REG_X_H35, A

	LD A, _SPR_REG_ATR2_EMPTY
	NEXTREG _SPR_REG_ATR2_H37, A

	; ##########################################
	; Sprite Y coordinate
	LD A, (IX + RO.Y)
	NEXTREG _SPR_REG_Y_H36, A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #UpdateSpritePattern                    ;
;----------------------------------------------------------;
; Input:
;  - IX:	Current #RO pointer.
;  - D:		sprite pattern.
UpdateSpritePattern
	; Set the ID of the sprite for the following commands.
	LD A, (IX + RO.SPRITE_ID)
	NEXTREG _SPR_REG_NR_H34, A

	; ##########################################
	; Set sprite pattern	
	LD A, D
	OR _SPR_PATTERN_SHOW						; Set show bit.
	NEXTREG _SPR_REG_ATR3_H38, A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;              #ResetCarryingRocketElement                 ;
;----------------------------------------------------------;
ResetCarryingRocketElement

	; Return if the state does not match carry.
	LD A, (rocketState)
	CP RO_ST_CARRY
	RET NZ

	CALL ResetRocketElement
	
	RET											; ## END of the function ##	

;----------------------------------------------------------;
;                 #ResetRocketElement                      ;
;----------------------------------------------------------;
ResetRocketElement

	; Reset to wait for drop, hide spirte.
	CALL SetIXtoCurrentRocketElement

	; Hide rocket element sprite.
	LD A, (IX + RO.SPRITE_ID)
	CALL sp.SetIdAndHideSprite

	; Reset the state and decrement element counter -> we will drop this element again.
	LD A, (rocketElementCnt)
	DEC A
	LD (rocketElementCnt), A

	; Change state.
	LD A, RO_ST_WAIT_DROP
	LD (rocketState), A

	; Reset drop delay.
	XOR A										; Set A to 0.
	LD (dropNextDelay), A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #CarryRocketElement                     ;
;----------------------------------------------------------;
CarryRocketElement

	; Return if the state does not match.
	LD A, (rocketState)
	CP RO_ST_CARRY
	RET NZ

	CALL SetIXtoCurrentRocketElement
	CALL MoveWithJetman
	CALL JetmanDropsRocketElement

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                #JetmanDropsRocketElement                 ;
;----------------------------------------------------------;
JetmanDropsRocketElement

	; Is Jetman over the drop location (+/- #_RO_PICK_MARGX_D8)?
	LD BC, (jpo.jetX)
	LD A, (rocketAssemblyX)
	SUB C										; Ignore B because X < 255.
	CP _RO_PICK_MARGX_D8
	RET NC

	; ##########################################
	; Js Jetman above rocket?
	LD A, (jpo.jetY)
	CP _RO_DROP_H_D220
	RET NC

	; ##########################################
	; Jetman drops rocket element.
	LD A, RO_ST_FALL_ASSEMBLY
	LD (rocketState), A

	; ##########################################
	; Store the height of the drop so that the element can keep falling from this location into the assembly place.
	CALL SetIXtoCurrentRocketElement			; Set IX to current #rocket postion.
	LD A, (jpo.jetY)
	LD (IX + RO.Y), A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                    #MoveWithJetman                       ;
;----------------------------------------------------------;
; Move the element to the current Jetman's position.
MoveWithJetman

	; Set the ID of the sprite for the following commands.
	LD A, (IX + RO.SPRITE_ID)
	NEXTREG _SPR_REG_NR_H34, A

	; ##########################################
	; Set sprite X coordinate.
	LD BC, (jpo.jetX)
	LD A, C		
	NEXTREG _SPR_REG_X_H35, A					; Set _SPR_REG_NR_H34 with LDB from Jetmans X postion.
	
	; Set _SPR_REG_ATR2_H37 containing overflow bit from X position.
	LD A, B										; Load MSB from X into A.
	AND %00000001								; Keep only an overflow bit.
	NEXTREG _SPR_REG_ATR2_H37, A

	; ##########################################
	; Set Y coordinate
	LD A, (jpo.jetY)
	ADD _RO_CARRY_ADJUSTY_D10
	NEXTREG _SPR_REG_Y_H36, A					; Set Y position.

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                 #PickupRocketElement                     ;
;----------------------------------------------------------;
PickupRocketElement

	; Return if there is no element/tank to pick up. Status must be #RO_ST_WAIT_PICKUP or #RO_ST_FALL_PICKUP.
	LD A, (rocketState)
	CP RO_ST_WAIT_PICKUP
	JR Z, .afterStatusCheck

	CP RO_ST_FALL_PICKUP
	RET NZ
	
.afterStatusCheck

	; ##########################################
	;  Exit if RiP.
	LD A, (jt.jetState)
	CP jt.JET_ST_RIP
	RET Z

	; ##########################################
	; Set IX to current #rocket postion.
	CALL SetIXtoCurrentRocketElement

	; ##########################################
	; Check the collision (pickup possibility) between Jetman and the element, return if there is none.
	LD BC, (IX + RO.DROP_X)						; X of the element.
	LD B, 0
	LD D, (IX + RO.Y)							; Y of the element.
	CALL JetmanElementCollision
	CP COLLISION_NO
	RET Z

	; ##########################################
	; Jetman picks up element/tank. Update state to reflect it and return.
	LD A, RO_ST_CARRY
	LD (rocketState), A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                #JetmanElementCollision                   ;
;----------------------------------------------------------;
; Checks whether Jetman overlaps with rocket element/tank.
; Input:
;  - BC: X postion of rocket element.
;  - D: Y postion of rocket element.
; Output:
;  - A:		COLLISION_NO or COLLISION_YES
COLLISION_NO			= 0
COLLISION_YES			= 1

JetmanElementCollision

	; Compare X coordinate of element and Jetman.
	LD B, 0										; X is 8bit -> reset MSB.
	LD HL, (jpo.jetX)							; X of the Jetman.

	; Check whether Jetman is horizontal with the element.
	SBC HL, BC	
	CALL ut.AbsHL								; HL contains a positive distance between the enemy and Jetman.
	LD A, H
	CP 0
	JR Z, .keepCheckingHorizontal				; HL > 256 -> no collision.
	LD A, COLLISION_NO
	RET		
.keepCheckingHorizontal	
	LD A, L
	LD B, _RO_PICK_MARGX_D8
	CP B
	JR C, .checkVertical						; Jump if there is horizontal collision, check vertical.
	LD A, COLLISION_NO							; L >= D (Horizontal thickness of the enemy) -> no collision.
	RET
.checkVertical
	
	; We are here because Jemtman's horizontal position matches that of the element, now check vertical.
	LD A, (jpo.jetY)								; Y of the Jetman.

	; Subtracts B from A and check whether the result is less than or equal to #_RO_PICK_MARGY_D16.
	SUB D										; D is method param (Y postion of rocket element).
	CALL ut.AbsA
	LD B, A
	LD A, _RO_PICK_MARGY_D16
	CP B
	JR NC, .collision							; Jump if A(#_RO_PICK_MARGY_D16) >= B

.noCollision
	LD A, COLLISION_NO
	RET
.collision
	LD A, COLLISION_YES

	RET											; ## END of the function ##

;----------------------------------------------------------;
;              #RocketElementFallsForPickup                ;
;----------------------------------------------------------;
RocketElementFallsForPickup

	; Return if there is no fall.
	LD A, (rocketState)
	CP RO_ST_FALL_PICKUP
	RET NZ										; Return if falling bit is not set.

	CALL SetIXtoCurrentRocketElement			; Set IX to current #rocket postion.

	; Move element one pixel down.
	LD A, (IX + RO.Y)
	INC A
	LD (IX + RO.Y), A

	; Update rocket spirte.
	LD A, (IX + RO.DROP_X)					; Sprite X coordinate, do not change value - element is falling down.
	CALL UpdateElementPosition

	; Has the horizontal destination been reached?
	LD B, A
	LD A, (IX + RO.DROP_LAND_Y)
	CP B
	RET NZ										; No, keep falling down.
	
	; Yes, element has reached landing postion.
	LD A, RO_ST_WAIT_PICKUP
	LD (rocketState), A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #AnimateRocketReady                     ;
;----------------------------------------------------------;
AnimateRocketReady

	; Return if rocket is not ready.
	LD A, (rocketState)
	CP RO_ST_READY
	RET NZ	

	; Set the ID of the sprite for the following commands.
	LD A, _RO_DOWN_SPR_ID_D50
	NEXTREG _SPR_REG_NR_H34, A

	; Set sprite pattern - one for flip, one for flop -> rocket will blink waiting for Jetman.
	LD A, (gld.counter008FliFLop)
	CP _GC_FLIP_ON_D1
	JR Z, .flip
	LD A, _RO_SPR_PAT_READY1_D60
	JR .afterSet
.flip	
	LD A, _RO_SPR_PAT_READY2_D61
.afterSet
	OR _SPR_PATTERN_SHOW						; Set visibility bit.
	NEXTREG _SPR_REG_ATR3_H38, A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;             #RocketElementFallsForAssembly               ;
;----------------------------------------------------------;
RocketElementFallsForAssembly

	; Return if there is no assebly.
	LD A, (rocketState)
	CP RO_ST_FALL_ASSEMBLY
	RET NZ										; Return if assembky bit is not set

	; ##########################################
	; Set IX to current #rocket postion.
	CALL SetIXtoCurrentRocketElement

	; ##########################################
	; Set the ID of the sprite for the following commands.
	LD A, (IX + RO.SPRITE_ID)
	NEXTREG _SPR_REG_NR_H34, A

	; ##########################################
	; Sprite X coordinate to assembly location.
	LD A, (rocketAssemblyX)
	NEXTREG _SPR_REG_X_H35, A

	; ##########################################
	; Set sprite pattern.
	LD A, (IX + RO.SPRITE_REF)
	OR _SPR_PATTERN_SHOW						; Set show bit.
	NEXTREG _SPR_REG_ATR3_H38, A

	; ##########################################
	; Sprite Y coordinate, increment until the destination has been reached.
	LD A, (IX + RO.Y)
	INC A
	LD (IX + RO.Y), A
	NEXTREG _SPR_REG_Y_H36, A

	; ##########################################
	; Has the horizontal destination been reached?
	LD B, A
	LD A, (IX + RO.ASSEMBLY_Y)
	CP B
	RET NZ										; No, keep falling down.
	
	; ##########################################
	; Yes, element has reached landing postion, set state for next drop.
	LD A, RO_ST_WAIT_DROP
	LD (rocketState), A

	; ##########################################
	; Hide the fuel tank sprite if we drop fuel, and change rocket sprite showing fuel level.
	LD A, (rocketElementCnt)
	CP _RO_EL_TANK1_D4
	JR C, .notFuel								; Jump if counter is < 4 (still assembling rocket).

	; We are dropping fuel already, hHide the fuel sprite as it has reached the rocket.
	LD A, (IX + RO.SPRITE_ID)
	CALL sp.SetIdAndHideSprite
.notFuel	

	RET											; ## END of the function ##

;----------------------------------------------------------;
;               #DropNextRocketElement                     ;
;----------------------------------------------------------;
DropNextRocketElement

	; Check state.
	LD A, (rocketState)
	CP RO_ST_WAIT_DROP
	RET NZ

	; ##########################################
	; Increment delay counter and check whether it's already time to process with the next rocket element/tank.
	LD A, (dropNextDelay)
	INC A
	LD (dropNextDelay), A
	CP _RO_DROP_NEXT_D5
	RET NZ										; Jump if #nextCnt !=  #DROP_NEXT_MAX.

	; The counter has reached the required value, reset it first.
	XOR A										; Set A to 0.
	LD (dropNextDelay), A

	; Check whether rocket element counter has already reached max value.
	LD A, (rocketElementCnt)
	CP _RO_EL_TANK3_D6
	JR NZ, .dropNext							; Jump if the counter did not reach max value.

	; The rocket is assembled and fueled.
	LD A, RO_ST_READY
	LD (rocketState), A
	RET

.dropNext
	; ##########################################
	; Increment element counter.
	LD A, (rocketElementCnt)
	INC A
	LD (rocketElementCnt), A

	; We are going to drop the next element -> set falling state.
	LD A, RO_ST_FALL_PICKUP
	LD (rocketState), A

	; Drop next rocket element/tank, first set IX to current #rocket postion.
	CALL SetIXtoCurrentRocketElement

	; Reset Y for element/tank to top of the screen.
	XOR A										; Set A to 0
	LD (IX + RO.Y), A
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;              #SetIXtoCurrentRocketElement                ;
;----------------------------------------------------------;
; Set IX to current #rocket postion
SetIXtoCurrentRocketElement

	; Load the pointer to #rocket into IX and move the pointer to the actual rocket element.
	LD IX, rocketEl

    ; Now, move IX so that it points to the #RO given by the deploy counter. First, load the counter into A (value 1-6).
	; Afterward, load A indo D and the size of the #RO into E, and multiply D by E.
	LD A, (rocketElementCnt)
	CALL MoveIXtoGivenRocketElement

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                MoveIXtoGivenRocketElement                ;
;----------------------------------------------------------;
; Input:
;  - A:	rocket element from 1 to 6.
MoveIXtoGivenRocketElement

	; Load the pointer to #rocket into IX and move the pointer to the actual rocket element.
	LD IX, rocketEl
	
	SUB 1										; A contains 0-2.
	LD D, A
	LD E, RO									; D contains A, E contains size of #RO.
	MUL D, E									; DE contains D * E.
	ADD IX, DE									; IX points to active #rocket (#RO).

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE