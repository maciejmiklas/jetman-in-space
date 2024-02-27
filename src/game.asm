
;----------------------------------------------------------;
;                    #AnimateSprites                       ;
;----------------------------------------------------------;

ANIM_FR				EQU 5						; Change sprite pattern every few frames     
frameCnt			BYTE 0						; The animation counter is used to update the sprite pattern every few FP

AnimateSprites:

	LD A, (frameCnt)
	INC A
	LD (frameCnt), A							

	CP ANIM_FR								
	RET C										; Return if #frameCnt <  #ANIM_FR

	LD A, 0										; #frameCnt == #ANIM_FR -> reset counter and update the animation pattern
	LD (frameCnt), A

	; Update sprite patterns
	CALL UpdateJetmanSpritePattern
	RET