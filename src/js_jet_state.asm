;----------------------------------------------------------;
;                     Jetman State Logic                   ;
;----------------------------------------------------------;
	MODULE js

;----------------------------------------------------------;
;                 #ChangeJetStateAir                       ;
;----------------------------------------------------------;
; Input:
;  - A:										; Air State: #AIR_XXX
ChangeJetStateAir
	
	LD (jd.jetAir), A

	LD A, (jd.jetState)
	SET jd.JET_STATE_AIR_BIT, A
	RES jd.JET_STATE_GND_BIT, A
	LD (jd.jetState), A

	LD A, jd.STATE_INACTIVE
	LD (jd.jetGnd), A

	RET

;----------------------------------------------------------;
;                 #ChangeJetStateGnd                       ;
;----------------------------------------------------------;
ChangeJetStateGnd

	LD A, (jd.jetState)
	SET jd.JET_STATE_GND_BIT, A
	RES jd.JET_STATE_AIR_BIT, A
	LD (jd.jetState), A

	LD A, jd.STATE_INACTIVE
	LD (jd.jetAir), A

	LD A, jd.GND_WALK
	LD (jd.jetGnd), A

	RET	

;----------------------------------------------------------;
;                 #ChangeJetStateRip                       ;
;----------------------------------------------------------;
ChangeJetStateRip
	LD A, jd.STATE_INACTIVE
	LD (jd.jetAir), A
	LD (jd.jetGnd), A

	LD A, jd.JET_STATE_INIT
	SET jd.JET_STATE_AIR_BIT, A
	SET jd.JET_STATE_RIP_BIT, A
	LD (jd.jetState), A

	RET

;----------------------------------------------------------;
;                #ChangeJetStateRespown                    ;
;----------------------------------------------------------;
ChangeJetStateRespown
	LD A, jd.STATE_INACTIVE
	LD (jd.jetGnd), A

	LD A, jd.AIR_HOOVER
	LD (jd.jetAir), A

	LD A, jd.JET_STATE_INIT
	SET jd.JET_STATE_AIR_BIT, A
	SET jd.JET_STATE_INV_BIT, A
	LD (jd.jetState), A
	
	RET	

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE		