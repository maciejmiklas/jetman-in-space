;----------------------------------------------------------;
;                        Main Game                         ;
;----------------------------------------------------------;
	MODULE gm 

;----------------------------------------------------------;
;                      #GameInit                           ;
;----------------------------------------------------------;
GameInit
	CALL jc.RespawnJet
	RET

;----------------------------------------------------------;
;                      #GameLoop                           ;
;----------------------------------------------------------;
	//DEFINE  PERFORMANCE_BORDER 

GameLoop
	IFDEF PERFORMANCE_BORDER
		LD	A, _COL_GREEN
		OUT (_BORDER_IO_HFE), A
	ENDIF

	CALL sc.WaitForScanline

	IFDEF PERFORMANCE_BORDER
		LD	A, _COL_RED
		OUT (_BORDER_IO_HFE), A
	ENDIF	

	; First update graphics, logic follows afterwards!
	CALL js.UpdateJetSpritePositionRotation
	
	CALL jc.JetRip
	CALL in.JoyInput

	CALL jm.JoyDisabled
	CALL jw.MoveShots

	LD IX, ed.sprite01
	LD A, (ed.spritesSize)
	LD B, A 	
	CALL ep.MoveEnemies

	LD IX, ed.sprite01
	LD A, (ed.singleSpritesSize)
	LD B, A	
	CALL ep.RespownNextEnemy	

	CALL jw.WeaponHitEnemies
	CALL jc.JetmanEnemiesColision

	LD IY, ed.formation
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
	LD IX, ed.sprite01	
	LD A, (ed.spritesSize)
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
	LD HL, (jo.jetX)
	CALL tx.PrintNumHL

	LD B, 10
	LD H, 0
	LD A,  (jo.jetY)
	LD L, A
	CALL tx.PrintNumHL
/*
	LD B, 20
	LD HL, (jc.invincibleCnt)
	CALL tx.PrintNumHL

	LD B, 30
	LD H, 0
	LD A, (jt.jetState)
	LD L, A
	CALL tx.PrintNumHL	
*/
	; PRINT END
	RET
;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE