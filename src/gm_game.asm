;----------------------------------------------------------;
;                        Main Game                         ;
;----------------------------------------------------------;
	MODULE gm 

;----------------------------------------------------------;
;                      #GameInit                           ;
;----------------------------------------------------------;
GameInit

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
	
	CALL jc.JetRip
	CALL in.JoyInput

	CALL jm.JoyDisabled
	CALL jw.MoveShots

	LD IX, DE.sprite01
	LD A, (DE.spritesSize)
	LD b, A 	
	CALL ep.MoveEnemies

	LD IX, DE.sprite01
	LD A, (DE.singleSpritesSize)
	LD B, A	
	CALL ep.RespownNextEnemy	

	CALL jw.WeaponHitEnemies
	CALL jc.JetmanEnemiesColision

	LD IY, DE.formation
	CALL ef.RespownFormation

	CALL PrintDebug

	RET

;----------------------------------------------------------;
;                       #Counter10                         ;
;----------------------------------------------------------;
Counter10
	CALL AnimateSprites		
	RET	

;----------------------------------------------------------;
;                       #Counter2                          ;
;----------------------------------------------------------;
Counter2
	CALL jc.JetInvincible
	RET		

;----------------------------------------------------------;
;                    #AnimateSprites                       ;
;----------------------------------------------------------;
AnimateSprites
	; Update sprite patterns
	CALL js.UpdateJetSpritePattern
	CALL jw.AnimateShots

	; Animate enemies
	LD IX, DE.sprite01	
	LD A, (DE.spritesSize)
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
	LD HL, (jp.jetmanX)
	CALL tx.PrintNumHL

	LD B, 10
	LD H, 0
	LD A,  (jp.jetmanY)
	LD L, A
	CALL tx.PrintNumHL

	LD B, 20
	LD HL, (jc.invincibleCnt)
	CALL tx.PrintNumHL

	LD B, 30
	LD H, 0
	LD A, (js.jetState)
	LD L, A
	CALL tx.PrintNumHL	

	; PRINT END
	RET
;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE