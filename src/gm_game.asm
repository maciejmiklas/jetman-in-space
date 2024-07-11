;----------------------------------------------------------;
;                        Main Game                         ;
;----------------------------------------------------------;
	MODULE gm 

loopCnt										; The game loop counter gets increased with each loop and restarts by overflow
	DB 0
;----------------------------------------------------------;
;                      #GameInit                           ;
;----------------------------------------------------------;
GameInit
	CALL js.IntiJetmanSprite

	RET

;----------------------------------------------------------;
;                      #GameLoop                           ;
;----------------------------------------------------------;
GameLoop

	; Increase game counter
	LD A, (loopCnt)
	INC A
	LD (loopCnt), A

	CALL sc.WaitForScanline

	; First update graphics, logic follows afterwards!
	CALL js.UpdateJetmanSpritePosition
	CALL sp.AnimateSprites

	CALL in.JoyInput
	CALL jt.JoyDisabled
	CALL jw.MoveShots
	CALL ep.MoveEnemies
	CALL ep.RespownNextEnemy	
	CALL ep.WeaponHit
	CALL ef.RespownFormation	
	CALL PrintDebug
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
	LD A, (jd.jetmanGnd)
	LD L, A
	CALL tx.PrintNumHL	

	LD B, 30
	LD H, 0
	LD A, (jd.joyDirection)
	LD L, A
	CALL tx.PrintNumHL		
	*/
	; PRINT END
	RET
;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE