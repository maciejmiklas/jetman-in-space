;----------------------------------------------------------;
;                     Jetman State Logic                   ;
;----------------------------------------------------------;
	MODULE jt

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
JET_STATE_RESET			= %00000000
JET_STATE_AIR_BIT		= 0						; Jemtan is flying, possible states are in #jetAir
JET_STATE_GND_BIT		= 1						; Jemtan is walking, possible states are in #jetGnd
JET_STATE_RIP_BIT		= 2						; Jemtan got hit by enemy
JET_STATE_INV_BIT		= 3						; Jetman is invincible
JET_STATE_KICK_BIT		= 4						; Jetman flies above the enemy and kicks

jetState				BYTE %00000001			; Game start, Jetman in the air

;----------------------------------------------------------;
;                 #ChangeJetStateAir                       ;
;----------------------------------------------------------;
; Input:
;  - A:										; Air State: #AIR_XXX
ChangeJetStateAir
	LD (jetAir), A							; Update Air from param

	LD A, (jetState)
	SET JET_STATE_AIR_BIT, A
	RES JET_STATE_GND_BIT, A
	LD (jetState), A

	LD A, STATE_INACTIVE
	LD (jetGnd), A

	RET

;----------------------------------------------------------;
;                 #ChangeJetStateGnd                       ;
;----------------------------------------------------------;
ChangeJetStateGnd
	LD A, (jetState)
	SET JET_STATE_GND_BIT, A
	RES JET_STATE_AIR_BIT, A
	LD (jetState), A

	LD A, STATE_INACTIVE
	LD (jetAir), A

	LD A, GND_WALK
	LD (jetGnd), A

	RET	

;----------------------------------------------------------;
;                 #ChangeJetStateRip                       ;
;----------------------------------------------------------;
ChangeJetStateRip
	LD A, STATE_INACTIVE
	LD (jetAir), A
	LD (jetGnd), A

	LD A, JET_STATE_RESET
	SET JET_STATE_AIR_BIT, A
	SET JET_STATE_RIP_BIT, A
	LD (jetState), A

	RET

;----------------------------------------------------------;
;                #ChangeJetStateRespown                    ;
;----------------------------------------------------------;
ChangeJetStateRespown	
	LD A, STATE_INACTIVE
	LD (jetGnd), A

	LD A, AIR_HOOVER
	LD (jetAir), A

	LD A, JET_STATE_RESET
	SET JET_STATE_AIR_BIT, A
	SET JET_STATE_INV_BIT, A
	LD (jetState), A
	
	RET	

;----------------------------------------------------------;
;                   #ResetKickState                        ;
;----------------------------------------------------------;
ResetKickState
	LD A, (jetState)
	BIT JET_STATE_KICK_BIT, A
	RET Z										; State not set

	RES JET_STATE_KICK_BIT, A
	LD  (jetState), A

	RET

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE		