;----------------------------------------------------------;
;                        Main Game                         ;
;----------------------------------------------------------;
	MODULE gm 
	
COUNTER10_MAX		= 10
counter10			BYTE 0
counter10FliFLop	BYTE 0						; Changes with evety counter run from 1 to 0 and so on

;----------------------------------------------------------;
;                      #GameInit                           ;
;----------------------------------------------------------;
GameInit

	RET

;----------------------------------------------------------;
;                      #GameLoop                           ;
;----------------------------------------------------------;
	//DEFINE  PERFORMANCE_BORDER 

GameLoop
	IFDEF PERFORMANCE_BORDER
		LD	A, _COL_GREEN
		OUT (_BORDER_IO), A
	ENDIF

	CALL sc.WaitForScanline

	IFDEF PERFORMANCE_BORDER
		LD	A, _COL_RED
		OUT (_BORDER_IO), A
	ENDIF	

	; First update graphics, logic follows afterwards!
	CALL js.UpdateJetSpritePositionRotation
	CALL Counter10
	
	CALL jt.JetRip
	CALL in.JoyInput

	CALL jt.JoyDisabled
	CALL jw.MoveShots

	LD IX, de.sprite01
	LD A, (de.spritesSize)
	LD B, A 	
	CALL ep.MoveEnemies

	LD IX, de.sprite01
	LD A, (de.singleSpritesSize)
	LD B, A	
	CALL ep.RespownNextEnemy	

	CALL jw.WeaponHitEnemies
	CALL jt.JetmanEnemiesColision

	LD IY, de.formation
	CALL ef.RespownFormation

	CALL PrintDebug

	RET

;----------------------------------------------------------;
;                       #Counter10                         ;
;----------------------------------------------------------;
Counter10

	; Flip to flop
	LD A, (counter10FliFLop)
	XOR 1
	LD (counter10FliFLop), A

	; Decrement the counter
	LD A, (counter10)
	INC A
	LD (counter10), A
	CP COUNTER10_MAX
	RET NZ										; Jump if #counter10 !=  #COUNTER10_MAX 

	LD A, 0										; Reset the counter
	LD (counter10), A
		
	; Call functions that need to be updated every 10th loop
	CALL AnimateSprites		
	CALL jt.JetInvincibleCounter
	RET	

;----------------------------------------------------------;
;                    #AnimateSprites                       ;
;----------------------------------------------------------;
AnimateSprites
	; Update sprite patterns
	CALL js.UpdateJetmanSpritePattern
	CALL jw.AnimateShots

	; Animate enemies
	LD IX, de.sprite01	
	LD A, (de.spritesSize)
	LD B, A	
	CALL sr.AnimateSprites
		
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

	LD B, 20
	LD H, 0
	LD A,  (jt.invincibleCnt)
	LD L, A
	CALL tx.PrintNumHL

	LD B, 30
	LD H, 0
	LD A, (jd.jetState)
	LD L, A
	CALL tx.PrintNumHL	

	; PRINT END
	RET
;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE