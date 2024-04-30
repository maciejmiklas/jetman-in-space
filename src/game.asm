;----------------------------------------------------------;
;                        Main Game                         ;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                      #GameInit                           ;
;----------------------------------------------------------;
GameInit	
	CALL JsIntiJetmanSprite
	RET
;----------------------------------------------------------;
;                      #GameLoop                           ;
;----------------------------------------------------------;
GameLoop	
	CALL ScWaitForScanline
	CALL JoInput
	CALL JsUpdateJetmanSpritePosition
	CALL JoDisabled
	CALL SpAnimateSprites
	CALL JwMoveShots
	RET