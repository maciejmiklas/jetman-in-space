;----------------------------------------------------------;
;                        Main Game                         ;
;----------------------------------------------------------;
	MODULE gm 
	
ANIMATE_DELAY			= 10					; Change sprite pattern every few game loops
animDelayCnt			BYTE 0					; The delay counter for sprite animation	
;----------------------------------------------------------;
;                      #GameInit                           ;
;----------------------------------------------------------;
GameInit
	CALL js.IntiJetmanSprite

	RET

;----------------------------------------------------------;
;                      #GameLoop                           ;
;----------------------------------------------------------;
	//DEFINE  PERFORMANCE_BORDER 

GameLoop
	IFDEF PERFORMANCE_BORDER
		LD	A, _COL_GREEN
		OUT (_BORDER_IO), A
	ENDIF

	CALL sc.WaitForScanline

	IFDEF PERFORMANCE_BORDER
		LD	A, _COL_RED
		OUT (_BORDER_IO), A
	ENDIF	

	; First update graphics, logic follows afterwards!
	CALL js.UpdateJetSpritePositionRotation
	CALL AnimateSprites
	
	; Handle state RIP
	LD A, (jd.jetState)
	CP jd.JET_STATE_RIP
	JR NZ, .jetAlive

	; Jetman is dying
	CALL jt.JetRip
	JR .afterJetRip
.jetAlive										; Jetman is alive
	
	CALL in.JoyInput							; Do not process input if Jetman is dying
.afterJetRip

	CALL jt.JoyDisabled
	;CALL jt.JetInvincible
	CALL jw.MoveShots

	LD IX, de.sprite01
	LD A, (de.spritesSize)
	LD B, A 	
	CALL ep.MoveEnemies

	LD IX, de.sprite01
	LD A, (de.singleSpritesSize)
	LD B, A	
	CALL ep.RespownNextEnemy	

	CALL jw.WeaponHitEnemies
	CALL jt.JetmanEnemiesColision


	LD IY, de.formation
	CALL ef.RespownFormation	
	CALL PrintDebug

	RET

;----------------------------------------------------------;
;                    #AnimateSprites                       ;
;----------------------------------------------------------;
AnimateSprites
	LD A, (animDelayCnt)
	INC A
	LD (animDelayCnt), A
	CP ANIMATE_DELAY
	RET C										; Return if #animDelayCnt <  #ANIMATE_DELAY

	LD A, 0										; Reset delay counter
	LD (animDelayCnt), A

	; Update sprite patterns
	CALL js.UpdateJetmanSpritePattern
	CALL jw.AnimateShots

	; Animate enemies
	LD IX, de.sprite01	
	LD A, (de.spritesSize)
	LD B, A	
	CALL sr.AnimateSprites
	
	RET	

;----------------------------------------------------------;
;                     #PrintDebug                          ;
;----------------------------------------------------------;
PrintDebug
	; PRINT START
	LD B, 0
	LD H, 0
	LD HL, (jd.jetmanX)
	CALL tx.PrintNumHL

	LD B, 10
	LD H, 0
	LD A,  (jd.jetmanY)
	LD L, A
	CALL tx.PrintNumHL
/*
	LD B, 20
	LD H, 0
	LD HL, (jd.jetmanX)
	CALL tx.PrintNumHL

	LD B, 30
	LD H, 0
	LD A,  (jd.jetmanY)
	LD L, A
	CALL tx.PrintNumHL	
*/
	; PRINT END
	RET
;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE