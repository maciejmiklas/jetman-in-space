;----------------------------------------------------------;
;                     Jetman State Logic                   ;
;----------------------------------------------------------;
	MODULE jt

STATE_INACTIVE			= 0

; States for Jetman in the air, 0 for not in the air.
AIR_FLY					= 10					; Jetman is flaying.
AIR_HOOVER				= 11					; Jetman is hovering.
AIR_FALL_RIGHT			= 12					; Jetman falls from platform on the right.
AIR_FALL_LEFT			= 13					; Jetman falls from platform on the left.
AIR_BUMP_RIGHT			= 14					; Jetman bumps into a platform from the right, he faces/moves left.
AIR_BUMP_LEFT			= 15					; Jetman bumps into a platform from the left, he faces/moves right.
AIR_BUMP_BOTTOM			= 16					; Jetman bumps into a platform from the bottom.
AIR_ENEMY_KICK			= 17					; Jetman flies above the enemy and kicks.

jetAir					BYTE STATE_INACTIVE		; Game start, Jetman standing on the ground (see _JM_RESPAWN_Y_D217)

; States for Jetman on the platform/ground
GND_WALK				= 51					; Jetman walks on the ground.
GND_JSTAND				= 52					; Jetman stands on the ground for a very short time, not enough to switch to #GND_STAND.
GND_STAND				= 53					; Jetman stands on the ground.

jetGnd					BYTE GND_STAND

; Jetman states
JETST_NORMAL			= 101					; Jetman is alive, could be flying (#jetAir != STATE_INACTIVE) or walking (#jetGnd != STATE_INACTIVE).
JETST_INV				= 102					; Jetman is invincible.
JETST_RIP				= 103					; Jetman got hit by enemy.
JETST_OVERHEAT			= 104					; Jetpack is overheating, and Jetman flays slowly.
jetState				BYTE JETST_NORMAL		; Game start, Jetman in the air.

;----------------------------------------------------------;
;              #UpdateStateOnJoyWillEnable                 ;
;----------------------------------------------------------;
UpdateStateOnJoyWillEnable

	; Reset #jetAir
	LD A, (jetAir)
	CP STATE_INACTIVE
	JR Z, .afterResetAir						; Do not need to reset if #jetAir is inactive.

	; Reset!
	LD A, AIR_FLY
	LD (jetAir), A
.afterResetAir	

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                   #SetJetStateAir                        ;
;----------------------------------------------------------;
; Input:
;  - A:											; Air State: #AIR_XXX.
SetJetStateAir

	LD (jetAir), A								; Update Air from param.

	XOR A
	LD (jetGnd), A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                    #SetJetStateGnd                       ;
;----------------------------------------------------------;
; Input:
;  - A:											; Air State: #GND_XXX.
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

	LD A, JETST_RIP
	LD (jetState), A

	RET											; ## END of the function ##
	
;----------------------------------------------------------;
;                  #SetJetStateRespawn                     ;
;----------------------------------------------------------;
SetJetStateRespawn

	XOR A
	LD (jetGnd), A

	LD A, AIR_HOOVER
	LD (jetAir), A
	
	LD A, JETST_NORMAL
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
;  - A:											; Air State: #JETST_XXX.
SetJetState
	LD (jetState), A
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE		