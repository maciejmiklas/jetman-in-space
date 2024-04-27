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
	CALL ScWaitOneFrame
	CALL JoInput
	CALL JsUpdateJetmanSpritePosition
	CALL JoDisabled
	CALL SpAnimateSprites
	CALL JwMoveShots
	RET