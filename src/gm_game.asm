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
	
	CALL jw.FireDelayCounter
	CALL jc.JetRip
	CALL in.JoyInput

	CALL jm.JoyDisabled

	LD IX, ed.sprite01
	LD A, (ed.spritesSize)
	LD B, A 	
	CALL ep.MoveEnemies

	LD IX, ed.sprite01
	LD A, (ed.singleSpritesSize)
	LD B, A	
	CALL ep.RespownNextEnemy	

	;CALL jc.JetmanEnemiesColision
	CALL ro.CheckHitTank
	
	LD IY, ed.formation
	CALL ef.RespownFormation

	CALL jw.MoveShots
	CALL jw.WeaponHitEnemies
	
	CALL PrintDebug

	RET	

;----------------------------------------------------------;
;                     #PrintDebug                          ;
;----------------------------------------------------------;
PrintDebug
	LD B, 120
	LD H, 0
	LD HL, (jo.jetX)
	CALL ut.PrintNumHLDebug

	LD B, 130
	LD H, 0
	LD A,  (jo.jetY)
	LD L, A
	CALL ut.PrintNumHLDebug


	LD B, 140
	LD H, 0
	LD HL, (ro.tmp)
	CALL ut.PrintNumHLDebug	

	LD B, 150
	LD HL, (ro.tmp1)
	CALL ut.PrintNumHLDebug	

	RET
;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE