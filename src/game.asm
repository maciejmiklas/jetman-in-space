;----------------------------------------------------------;
;                      #GameInit                           ;
;----------------------------------------------------------;
GameInit:	
	CALL IntiJetmanSprite
	RET
;----------------------------------------------------------;
;                      #GameLoop                           ;
;----------------------------------------------------------;
GameLoop:	
	CALL WaitOneFrame
	CALL HandleJoystickInput
	CALL UpdateJetmanSpritePosition
	CALL AnimateSprites
	
	RET