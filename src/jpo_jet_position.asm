;----------------------------------------------------------;
;                      Jetman Position                     ;
;----------------------------------------------------------;
	MODULE jpo

; Jetman sprite consists of two spires, each 16x16px. Coordinates relate to the left top corner of the upper sprite. 
; For example, corner positions to display the whole spirit are as follows: (X,Y) given by (0,0) would display a complete sprite in the 
; left corner. The most right position on X is 320-16, and the bottom on Y is 256 - 32.
jetX					WORD 0					; 0-320px
jetY 					BYTE 0					; 0-256px

;----------------------------------------------------------;
;                          #IncJetX                        ;
;----------------------------------------------------------;
IncJetX

	LD BC, (jpo.jetX)	
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
	LD (jpo.jetX), BC							; Update new X position

	CALL gc.JetmanMoves

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                         #IncJetXbyB                      ;
;----------------------------------------------------------;
; Input 
; - B: number of pixels to move Jetman Up
IncJetXbyB

.loop	
	PUSH BC
	CALL IncJetX
	POP BC
	DJNZ .loop

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                        #DecJetX                          ;
;----------------------------------------------------------;
DecJetX

	LD BC, (jpo.jetX)	
	DEC BC

	; If X == 0 (_CF_GSC_X_MIN) then set it to 315. X == 0 when B and C are 0
	LD A, B
	CP _CF_GSC_X_MIN							; If B > 0 then X is also > 0
	JR NZ, .afterResetX
	LD A, C
	CP _CF_GSC_X_MIN							; If C > 0 then X is also > 0
	JR NZ, .afterResetX
	LD BC, _CF_GSC_X_MAX						; X == 0 (both A and B are 0) -> set X to 315
.afterResetX
	LD (jpo.jetX), BC

	CALL gc.JetmanMoves

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                         #DecJetXbyB                      ;
;----------------------------------------------------------;
; Input 
; - B: number of pixels to move Jetman Up
DecJetXbyB

.loop	
	PUSH BC
	CALL DecJetX
	POP BC
	DJNZ .loop

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                          #IncJetY                        ;
;----------------------------------------------------------;
IncJetY

	LD A, (jpo.jetY)	
	INC A
	LD (jpo.jetY), A

	CALL gc.JetmanMoves

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                          #DecJetY                        ;
;----------------------------------------------------------;
DecJetY

	LD A, (jpo.jetY)	
	DEC A
	LD (jpo.jetY), A

	CALL gc.JetmanMoves

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                         #IncJetYbyB                      ;
;----------------------------------------------------------;
; Input 
; - B: number of pixels to move Jetman Up
IncJetYbyB

	LD A, (jpo.jetY)
	ADD B
	LD (jpo.jetY), A

	CALL gc.JetmanMoves

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                         #DecJetYbyB                      ;
;----------------------------------------------------------;
; Input 
; - B: number of pixels to move Jetman Up
DecJetYbyB

	LD A, (jpo.jetY)	
	SUB B
	LD (jpo.jetY), A

	CALL gc.JetmanMoves

	RET											; ## END of the function ##	

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE	