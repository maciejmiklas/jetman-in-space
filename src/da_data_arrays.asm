;----------------------------------------------------------;
;                  Structures and Arrays                   ;
;----------------------------------------------------------;
	module da

	MMU _RAM_SLOT6, _ARR_BANK1_D68
	ORG _RAM_SLOT6_START_HC000
arraysBank1Start:



	ASSERT $$ == _ARR_BANK1_D68					; Data shold remain in the same bank
	ASSERT $$arraysBank1Start == _ARR_BANK1_D68 ; Make sure that we have configured the right bank.

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE
