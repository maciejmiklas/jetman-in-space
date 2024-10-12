;----------------------------------------------------------;
;                      Jetman Position                     ;
;----------------------------------------------------------;
	MODULE jo

jetX					WORD 100				; 0-320px
jetY 					BYTE 100				; 0-256px

;----------------------------------------------------------;
;                          #IncJetX                        ;
;----------------------------------------------------------;
IncJetX
	LD BC, (jo.jetX)	
	INC BC

	; If X >= 315 then set it to 0. X is 9-bit value. 
	; 315 = 256 + 59 = %00000001 + %00111011 -> MSB: 1, LSB: 59
	LD A, B										; Load MSB from X into A
	CP 1										; 9-th bit set means X > 256
	JR NZ, .lessThanMaxX
	LD A, C										; Load MSB from X into A
	CP 59										; MSB > 59 
	JR C, .lessThanMaxX
	LD BC, 1									; Jetman is above 315 -> set to 1
.lessThanMaxX
	LD (jo.jetX), BC							; Update new X position

	CALL JetmanMoves
	RET

;----------------------------------------------------------;
;                        #DecJetX                          ;
;----------------------------------------------------------;
DecJetX
	LD BC, (jo.jetX)	
	DEC BC

	; If X == 0 (SCR_X_MIN_POS) then set it to 315. X == 0 when B and C are 0
	LD A, B
	CP sc.SCR_X_MIN_POS							; If B > 0 then X is also > 0
	JR NZ, .afterResetX
	LD A, C
	CP sc.SCR_X_MIN_POS							; If C > 0 then X is also > 0
	JR NZ, .afterResetX
	LD BC, sc.SCR_X_MAX_POS						; X == 0 (both A and B are 0) -> set X to 315
.afterResetX
	LD (jo.jetX), BC

	CALL JetmanMoves
	RET

;----------------------------------------------------------;
;                          #IncJetY                        ;
;----------------------------------------------------------;
IncJetY
	LD A, (jo.jetY)	
	INC A
	LD (jo.jetY), A

	CALL JetmanMoves
	RET

;----------------------------------------------------------;
;                          #DecJetY                        ;
;----------------------------------------------------------;
DecJetY
	LD A, (jo.jetY)	
	DEC A
	LD (jo.jetY), A

	CALL JetmanMoves
	RET	

;----------------------------------------------------------;
;                         #IncJetYbyB                      ;
;----------------------------------------------------------;
; Input 
; - B: number of pixels to move Jetman Up
IncJetYbyB
	LD A, (jo.jetY)	
.loop	
	ADD B
	LD (jo.jetY), A

	CALL JetmanMoves
	RET	

;----------------------------------------------------------;
;                         #DecJetYbyB                      ;
;----------------------------------------------------------;
; Input 
; - B: number of pixels to move Jetman Up
DecJetYbyB
	LD A, (jo.jetY)	
	SUB B
	LD (jo.jetY), A

	CALL JetmanMoves
	RET		

;----------------------------------------------------------;
;                      #JetmanMoves                        ;
;----------------------------------------------------------;
JetmanMoves
	CALL bg.UpdateOnJetmanMove
	CALL ro.UpdateOnJetmanMove

	RET

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE	