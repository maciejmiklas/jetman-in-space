;----------------------------------------------------------;
;                        Main Game                         ;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                      #GameInit                           ;
;----------------------------------------------------------;
GameInit	
	CALL JsIntiJetmanSprite
	CALL SrTest
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
	
	RET