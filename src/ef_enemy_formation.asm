;----------------------------------------------------------;
;               Formation of 16x16 enemies                 ;
;----------------------------------------------------------;
	MODULE ef

; The move formation consists of multiple sprites. #EF.SPRITE_POINTER gives the first sprite, and #EF.SPRITES determines the amount. 
; For example, for #EF.SPRITE_POINTER=sprite10 and #EF.SPRITES=3, the formation will contain three sprites: sprite10, sprite11, and sprite12. 
; The #EF.RESPOWN_DELAY determines the respawn delay of the first sprite in the formation. The #ENP.RESPOWN_DELAY for the remaining sprites 
; determines the deploy delay for the following sprite in the formation. 
	STRUCT EF
SPRITE_POINTER		WORD						; Pointer to the first sprite (#SPR)
RESPOWN_DELAY		WORD						; Number of game loops delaying respawn
RESPOWN_DELAY_CNT	WORD						; Respawn delay counter
SPRITES				BYTE						; Number of sprites used in this formation, starting from #SPRITE_POINTER inclusive
SPRITES_CNT			BYTE						; Current respown position
	ENDS

;----------------------------------------------------------;
;                   #RespownFormation                      ;
;----------------------------------------------------------;
; Input:
;  - IY:	Pointer to #EF
RespownFormation	

	; Check whether it's time to start a new formation deployment.
	LD BC, (IY + EF.RESPOWN_DELAY)
	LD DE, (IY + EF.RESPOWN_DELAY_CNT)

	; Compare timer
	LD A, B
	CP D
	JR NZ, .increaseDelayTimer					; Jump if B != E

	LD A, C
	CP E
	JR NZ, .increaseDelayTimer					; Jump if C != E

	JR .afterDelayTimer							; RESPOWN_DELAY == RESPOWN_DELAY_CNT -> deplyment is active
.increaseDelayTimer
	INC DE										; Increase delay timer and return
	LD (IY + EF.RESPOWN_DELAY_CNT), DE
	RET
.afterDelayTimer

	; Formation deployment in progress.....

	; Check if deployment is over -> the last sprite has been deployed.
	LD A, (IY + EF.SPRITES_CNT)
	CP (IY + EF.SPRITES)
	JR C, .deplyNextEnemy						; Jump if  EF.SPRITES_CNT < EF.SPRITES -> There are still enemies that need to be deployed
	
	; Deplyment is over
	LD DE, 0									; Reset formation counters
	LD (IY + EF.SPRITES_CNT), E
	LD (IY + EF.RESPOWN_DELAY_CNT), DE

	RET
.deplyNextEnemy	

	; Deploy next enemy!
	LD HL, (IY + EF.SPRITE_POINTER)
	LD IX, HL									; IX points for ENP for the first sprite in the formation

	; Move IX to the current sprite in the formation
	LD D, (IY + EF.SPRITES_CNT)					; IX = IX + EF.SPRITES_CNT * EF
	LD E, sr.SPR
	MUL D, E
	ADD IX, DE

	PUSH IY
	CALL ep.RespownEnemy
	POP IY

	CP ep.RES_SE_OUT_YES						; Has the enemy respawned?		
	RET NZ
	INC (IY + EF.SPRITES_CNT)					; Move to the next enemy if this has respawned

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE	