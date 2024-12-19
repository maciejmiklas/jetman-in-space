;----------------------------------------------------------;
;                     Jetman State Logic                   ;
;----------------------------------------------------------;
	MODULE jt

STATE_INACTIVE			= 0

; States for Jetmain in the air, 0 for not in the air
AIR_FLY					= 10					; Jetman is flaying
AIR_HOOVER				= 11					; Jetman is hovering
AIR_FALL_RIGHT			= 12					; Jetman falls from paltform on the right
AIR_FALL_LEFT			= 13					; Jetman falls from paltform on the left
AIR_BUMP_RIGHT			= 14					; Jetman bumps into a platform from the right, he faces/moves left
AIR_BUMP_LEFT			= 15					; Jetman bumps into a platform from the left, he faces/moves right
AIR_BUMP_BOTTOM			= 16					; Jetman bumps into a platform from the bottom
AIR_ENEMY_KICK			= 17					; Jetman flies above the enemy and kicks

jetAir					BYTE STATE_INACTIVE		; Game start, Jetman standing on the ground (see _CF_JET_RESPOWN_Y)

; States for Jetman on the platform/ground
GND_WALK				= 51					; Jetman walks on the ground
GND_JSTAND				= 52					; Jetman stands on the ground for a very short time, not enougt to switch to #GND_STAND
GND_STAND				= 53					; Jetman stands on the ground

jetGnd					BYTE GND_STAND

; Jetman states
JET_ST_NORMAL			= 101					; Jetman is alive, could be flying (#jetAir != STATE_INACTIVE) or walking (#jetGnd != STATE_INACTIVE)
JET_ST_INV				= 102					; Jetman is invincible
JET_ST_RIP				= 110					; Jemtan got hit by enemy
jetState				BYTE JET_ST_NORMAL		; Game start, Jetman in the air

;----------------------------------------------------------;
;              #UpdateStateOnJoyWillEnable                 ;
;----------------------------------------------------------;
UpdateStateOnJoyWillEnable

	; Reset #jetAir
	LD A, (jetAir)
	CP STATE_INACTIVE
	JR Z, .afterResetAir						; Do not need to reset if  #jetAir is inactive

	; Reset!
	LD A, AIR_FLY
	LD (jetAir), A
.afterResetAir	

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                   #SetJetStateAir                        ;
;----------------------------------------------------------;
; Input:
;  - A:											; Air State: #AIR_XXX
SetJetStateAir

	LD (jetAir), A								; Update Air from param

	XOR A
	LD (jetGnd), A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                    #SetJetStateGnd                       ;
;----------------------------------------------------------;
; Input:
;  - A:											; Air State: #GND_XXX
SetJetStateGnd

	LD (jetGnd), A

	XOR A
	LD (jetAir), A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                    #SetJetStateRip                       ;
;----------------------------------------------------------;
SetJetStateRip

	XOR A
	LD (jetAir), A
	LD (jetGnd), A

	LD A, JET_ST_RIP
	LD (jetState), A

	RET											; ## END of the function ##
	
;----------------------------------------------------------;
;                  #SetJetStateRespown                     ;
;----------------------------------------------------------;
SetJetStateRespown

	XOR A
	LD (jetGnd), A

	LD A, AIR_HOOVER
	LD (jetAir), A
	
	LD A, JET_ST_NORMAL
	LD (jetState), A
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #SetJetStateInactive                    ;
;----------------------------------------------------------;
SetJetStateInactive

	XOR A
	LD (jetAir), A
	LD (jetGnd), A
	LD (jetState), A
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                      #SetJetState                        ;
;----------------------------------------------------------;
; Input:
;  - A:											; Air State: #JET_ST_XXX
SetJetState
	LD (jetState), A
	
	RET											; ## END of the function ##	

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE		