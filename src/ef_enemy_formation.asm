;----------------------------------------------------------;
;               Formation of 16x16 enemies                 ;
;----------------------------------------------------------;
	MODULE ef


; The move formation consists of multiple sprites. #MF.MSS_POINTER gives the first sprite, and #MF.SPRITES determines the amount. 
; For example, for #MF.MSS_POINTER=sprite10 and #MF.SPRITES=3, the formation will contain three sprites: sprite10, sprite11, and sprite12. 
; The #MF.RESPOWN_DELAY determines the respawn delay of the first sprite in the formation. The #ESS.RESPOWN_DELAY for the remaining sprites 
; determines the deploy delay for the following sprite in the formation. 
	STRUCT MF
MSS_POINTER			WORD						; Pointer to the first sprite (#MSS)
RESPOWN_DELAY		WORD						; Number of game loops delaying respawn
RESPOWN_DELAY_CNT	WORD						; Respawn delay counter
SPRITES				BYTE						; Number of sprites used in this formation, starting from #MSS_POINTER inclusive
SPRITES_CNT			BYTE						; Current respown position
	ENDS

formation MF{ep.spriteEf01/*MSS_POINTER*/, 50/*RESPOWN_DELAY*/, 0/*RESPOWN_DELAY_CNT*/, 5/*SPRITES*/, 0/*SPRITES_CNT*/}

;----------------------------------------------------------;
;                   #RespownFormation                      ;
;----------------------------------------------------------;
RespownFormation	
	LD IY, formation

	; Check whether it's time to start a new formation deployment.
	LD BC, (IY + MF.RESPOWN_DELAY)
	LD DE, (IY + MF.RESPOWN_DELAY_CNT)

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
	LD (IY + MF.RESPOWN_DELAY_CNT), DE
	RET
.afterDelayTimer

	; Formation deployment in progress.....

	; Check if deployment is over -> the last sprite has been deployed.
	LD A, (IY + MF.SPRITES_CNT)
	LD B, (IY + MF.SPRITES)	
	CP B
	JR C, .afterSpritesCounterCheck				; Jump if  MF.SPRITES_CNT < MF.SPRITES -> There are still enemies that need to be deployed
	CALL RestartFormation						; Deployment is over
	RET
.afterSpritesCounterCheck	

	; Deploy next enemy!
	LD HL, (IY + MF.MSS_POINTER)
	LD IX, HL									; IX points for ESS for the first sprite in the formation

	ld a, $30
	nextreg 2,8

	; Move IX to the current sprite in the formation
	LD D, (IY + MF.SPRITES_CNT)					; IX = IX + MF.SPRITES_CNT * MF
	LD E, sr.MSS
	MUL D, E
	ADD IX, DE

	ld a, $31
	nextreg 2,8

	;CALL ep.RespownEnemy
	
	INC (IY + MF.SPRITES_CNT)
	RET

;----------------------------------------------------------;
;                  #RestartFormation                       ;
;----------------------------------------------------------;
; Input
;  - IY:	pointer to #MF holding data for the formation
; Modifies: ALL
RestartFormation
	LD A, 0										; Reset counters
	LD (IY + MF.SPRITES_CNT), A
	LD (IY + MF.RESPOWN_DELAY_CNT), A
	
	LD DE, (IY + MF.MSS_POINTER)				; Load pointer to the first sprite (#MSS) into IX
	LD IX, DE

	LD B, (IY + MF.SPRITES)						; Counter for the .loop	
.loop
	PUSH BC
	CALL ep.RestartMovePattern
	POP BC

	LD DE, sr.MSS								; Move IX to the next sprite
	ADD IX, DE

	DJNZ .loop									; Jump if B > 0 (loop starts with B = #MF.MSS_CNT)

	RET

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE	