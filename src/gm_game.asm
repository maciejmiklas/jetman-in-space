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
	CALL jo.JoyInput
	CALL js.UpdateJetmanSpritePosition
	CALL jo.JoyDisabled
	CALL sp.AnimateSprites
	CALL jw.MoveShots
	CALL en.MoveEnemies
	CALL en.respown
	CALL en.WeaponHit
	RET

;----------------------------------------------------------;
;                            END                           ;
;----------------------------------------------------------;
	ENDMODULE			