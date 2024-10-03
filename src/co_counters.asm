;----------------------------------------------------------;
;                   Global Counters                        ;
;----------------------------------------------------------;
	MODULE co 

;----------------------------------------------------------;
;                     #CounterLoop                         ;
;----------------------------------------------------------;
CounterLoop
	CALL Counter12							; Fist is 10 because we use it to time animation
	CALL Counter2
	CALL Counter4	
	CALL Counter6
	CALL Counter40
	RET	

;----------------------------------------------------------;
;                       #Counter2                          ;
;----------------------------------------------------------;
Counter2
	; Increment the counter
	LD A, (cd.counter2)
	INC A
	LD (cd.counter2), A
	CP cd.COUNTER2_MAX
	RET NZ										; Jump if #counter2 !=  #COUNTER2_MAX 

	; Reset the counter
	XOR A										; Set A to 0
	LD (cd.counter2), A

	; ; 1 -> 0 and 0 -> 1
	LD A, (cd.counter2FliFLop)
	XOR 1
	LD (cd.counter2FliFLop), A
	
	; CALL functions that need to be updated every 10th loop
	CALL gm.Counter2
	RET

;----------------------------------------------------------;
;                       #Counter4                          ;
;----------------------------------------------------------;
Counter4
	; Increment the counter
	LD A, (cd.counter4)
	INC A
	LD (cd.counter4), A
	CP cd.COUNTER4_MAX
	RET NZ										; Jump if #counter4 !=  #COUNTER4_MAX 

	; Reset the counter
	XOR A										; Set A to 0
	LD (cd.counter4), A

	; 1 -> 0 and 0 -> 1
	LD A, (cd.counter4FliFLop)
	XOR 1
	LD (cd.counter4FliFLop), A

	; CALL functions that need to be updated every 10th loop
	CALL ro.FlyRocket
	RET	

;----------------------------------------------------------;
;                       #Counter6                          ;
;----------------------------------------------------------;
Counter6
	; Increment the counter
	LD A, (cd.counter6)
	INC A
	LD (cd.counter6), A
	CP cd.COUNTER6_MAX
	RET NZ										; Jump if #counter4 !=  #COUNTER4_MAX 

	; Reset the counter
	XOR A										; Set A to 0
	LD (cd.counter6), A

	; 1 -> 0 and 0 -> 1
	LD A, (cd.counter6FliFLop)
	XOR 1
	LD (cd.counter6FliFLop), A

	; CALL functions that need to be updated every 10th loop
	RET		

;----------------------------------------------------------;
;                       #Counter12                         ;
;----------------------------------------------------------;
Counter12
	; Increment the counter
	LD A, (cd.counter12)
	INC A
	LD (cd.counter12), A
	CP cd.COUNTER12_MAX
	RET NZ										; Jump if #counter12 !=  #COUNTER12_MAX 

	; Reset the counter
	XOR A										; Set A to 0
	LD (cd.counter12), A

	; 1 -> 0 and 0 -> 1
	LD A, (cd.counter12FliFLop)
	XOR 1
	LD (cd.counter12FliFLop), A

	; CALL functions that need to be updated every 10th loop
	CALL gm.Counter12
	CALL ro.RocketElementFallsForPickup
	CALL ro.RocketElementFallsForAssembly
	CALL ro.AnimateRocketReady
	CALL ro.AnimateTankExplode
	CALL ro.AnimateRocketExhaust
	RET		

;----------------------------------------------------------;
;                       #Counter40                         ;
;----------------------------------------------------------;
Counter40
	; Increment the counter
	LD A, (cd.counter40)
	INC A
	LD (cd.counter40), A
	CP cd.COUNTER40_MAX
	RET NZ										; Jump if #counter12 !=  #COUNTER40_MAX 

	; Reset the counter
	XOR A										; Set A to 0
	LD (cd.counter40), A

	; 1 -> 0 and 0 -> 1
	LD A, (cd.counter40FliFLop)
	XOR 1
	LD (cd.counter40FliFLop), A

	; CALL functions that need to be updated every 40th loop
	CALL ro.DropNextRocketElement
	RET	

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE