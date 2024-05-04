;----------------------------------------------------------;
;                        Main Game                         ;
;----------------------------------------------------------;
gmLoopCnt										; The game loop counter gets increased with each loop and restarts by overflow
	DB 0
;----------------------------------------------------------;
;                     #GmGameInit                          ;
;----------------------------------------------------------;
GmGameInit	
	CALL JsIntiJetmanSprite
	RET

;----------------------------------------------------------;
;                     #GmGameLoop                          ;
;----------------------------------------------------------;
GmGameLoop	

	; Increase game counter
	LD A, (gmLoopCnt)
	INC A
	LD (gmLoopCnt), A

	CALL ScWaitForScanline
	CALL JoInput
	CALL JsUpdateJetmanSpritePosition
	CALL JoDisabled
	CALL SpAnimateSprites
	CALL JwMoveShots
	CALL EaMoveEnemies
	CALL EaRespown
	CALL EaWeaponHit
	RET