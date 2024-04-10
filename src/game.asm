;----------------------------------------------------------;
;                      #GameInit                           ;
;----------------------------------------------------------;
GameInit	
	CALL IntiJetmanSprite
	RET
;----------------------------------------------------------;
;                      #GameLoop                           ;
;----------------------------------------------------------;
GameLoop	
	CALL WaitOneFrame
	CALL JoystickInput
	CALL UpdateJetmanSpritePosition
	CALL JoystickDisabled
	CALL AnimateSprites
	
	RET