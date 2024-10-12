;----------------------------------------------------------;
;                   Global Counters                        ;
;----------------------------------------------------------;
	MODULE co 

;----------------------------------------------------------;
;                     #CounterLoop                         ;
;----------------------------------------------------------;
CounterLoop	
	CALL Counter02
	CALL Counter04	
	CALL Counter06
	CALL Counter08
	CALL Counter10
	CALL Counter40
	RET	

;----------------------------------------------------------;
;                       #Counter02                         ;
;----------------------------------------------------------;
Counter02
	; Increment the counter
	LD A, (cd.counter02)
	INC A
	LD (cd.counter02), A
	CP cd.COUNTER02_MAX
	RET NZ

	; Reset the counter
	XOR A										; Set A to 0
	LD (cd.counter02), A

	; ; 1 -> 0 and 0 -> 1
	LD A, (cd.counter02FliFLop)
	XOR 1
	LD (cd.counter02FliFLop), A

	; CALL functions that need to be updated every xx-th loop
	CALL jc.JetInvincible
	CALL ro.FlyRocket

	RET

;----------------------------------------------------------;
;                       #Counter04                         ;
;----------------------------------------------------------;
Counter04
	; Increment the counter
	LD A, (cd.counter04)
	INC A
	LD (cd.counter04), A
	CP cd.COUNTER04_MAX
	RET NZ
	; Reset the counter
	XOR A										; Set A to 0
	LD (cd.counter04), A

	; 1 -> 0 and 0 -> 1
	LD A, (cd.counter04FliFLop)
	XOR 1
	LD (cd.counter04FliFLop), A

	; CALL functions that need to be updated every xx-th loop
	CALL ro.RocketElementFallsForPickup
	CALL ro.RocketElementFallsForAssembly
	RET	

;----------------------------------------------------------;
;                       #Counter06                         ;
;----------------------------------------------------------;
Counter06
	; Increment the counter
	LD A, (cd.counter06)
	INC A
	LD (cd.counter06), A
	CP cd.COUNTER06_MAX
	RET NZ

	; Reset the counter
	XOR A										; Set A to 0
	LD (cd.counter06), A

	; 1 -> 0 and 0 -> 1
	LD A, (cd.counter06FliFLop)
	XOR 1
	LD (cd.counter06FliFLop), A

	; CALL functions that need to be updated every xx-th loop

	RET		

;----------------------------------------------------------;
;                       #Counter08                         ;
;----------------------------------------------------------;
Counter08
	; Increment the counter
	LD A, (cd.counter08)
	INC A
	LD (cd.counter08), A
	CP cd.COUNTER08_MAX
	RET NZ

	; Reset the counter
	XOR A										; Set A to 0
	LD (cd.counter08), A

	; 1 -> 0 and 0 -> 1
	LD A, (cd.counter08FliFLop)
	XOR 1
	LD (cd.counter08FliFLop), A

	; CALL functions that need to be updated every xx-th loop
	
	CALL js.UpdateJetSpritePattern
	CALL jw.AnimateShots
	
	; Animate enemies
	LD IX, ed.sprite01	
	LD A, (ed.spritesSize)
	LD B, A	
	CALL sr.AnimateSprites


	CALL ro.AnimateRocketReady
	CALL ro.AnimateTankExplode
	CALL ro.AnimateRocketExhaust

	RET

;----------------------------------------------------------;
;                       #Counter10                         ;
;----------------------------------------------------------;
Counter10
	; Increment the counter
	LD A, (cd.counter10)
	INC A
	LD (cd.counter10), A
	CP cd.COUNTER10_MAX
	RET NZ

	; Reset the counter
	XOR A										; Set A to 0
	LD (cd.counter10), A

	; ; 1 -> 0 and 0 -> 1
	LD A, (cd.counter10FliFLop)
	XOR 1
	LD (cd.counter10FliFLop), A

	; CALL functions that need to be updated every xx-th loop

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
	RET NZ

	; Reset the counter
	XOR A										; Set A to 0
	LD (cd.counter40), A

	; 1 -> 0 and 0 -> 1
	LD A, (cd.counter40FliFLop)
	XOR 1
	LD (cd.counter40FliFLop), A

	; CALL functions that need to be updated every xx-th loop
	CALL ro.DropNextRocketElement
	RET	

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE