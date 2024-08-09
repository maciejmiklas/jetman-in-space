;----------------------------------------------------------;
;                   Global Counters                        ;
;----------------------------------------------------------;
	MODULE co 

;----------------------------------------------------------;
;                     #CounterLoop                         ;
;----------------------------------------------------------;
CounterLoop
	CALL Counter10
	CALL Counter4
	CALL Counter2
	RET	

;----------------------------------------------------------;
;                       #Counter10                         ;
;----------------------------------------------------------;
Counter10
	; Decrement the counter
	LD A, (cd.counter10)
	INC A
	LD (cd.counter10), A
	CP cd.COUNTER10_MAX
	RET NZ										; Jump if #counter10 !=  #COUNTER10_MAX 

	; Reset the counter
	LD A, 0
	LD (cd.counter10), A

	; 1 -> 0 and 0 -> 1
	LD A, (cd.counter10FliFLop)
	XOR 1
	LD (cd.counter10FliFLop), A

	; CALL functions that need to be updated every 10th loop
	CALL gm.Counter10		
	RET	

;----------------------------------------------------------;
;                       #Counter4                          ;
;----------------------------------------------------------;
Counter4
	; Decrement the counter
	LD A, (cd.counter4)
	INC A
	LD (cd.counter4), A
	CP cd.COUNTER4_MAX
	RET NZ										; Jump if #counter4 !=  #COUNTER4_MAX 

	; Reset the counter
	LD A, 0
	LD (cd.counter4), A

	; 1 -> 0 and 0 -> 1
	LD A, (cd.counter4FliFLop)
	XOR 1
	LD (cd.counter4FliFLop), A

	; CALL functions that need to be updated every 10th loop
	; nothing yet
	RET		

;----------------------------------------------------------;
;                       #Counter2                          ;
;----------------------------------------------------------;
Counter2
	; Decrement the counter
	LD A, (cd.counter2)
	INC A
	LD (cd.counter2), A
	CP cd.COUNTER2_MAX
	RET NZ										; Jump if #counter2 !=  #COUNTER2_MAX 

	; Reset the counter
	LD A, 0
	LD (cd.counter2), A

	; ; 1 -> 0 and 0 -> 1
	LD A, (cd.counter2FliFLop)
	XOR 1
	LD (cd.counter2FliFLop), A
	
	; CALL functions that need to be updated every 10th loop
	CALL gm.Counter2
	RET


;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE