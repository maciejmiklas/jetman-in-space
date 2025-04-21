;----------------------------------------------------------;
;                      Lobby State                         ;
;----------------------------------------------------------;
	MODULE los

LOBBY_INACTIVE			= 0
LOBBY_INTRO				= 1

lobbyState				BYTE LOBBY_INACTIVE


;----------------------------------------------------------;
;                #SetLobbyStateInactive                    ;
;----------------------------------------------------------;
SetLobbyStateInactive

	LD A, LOBBY_INACTIVE
	LD (lobbyState), A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #SetLobbyStateIntro                     ;
;----------------------------------------------------------;
SetLobbyStateIntro

	LD A, LOBBY_INTRO
	LD (lobbyState), A

	RET											; ## END of the function ##
	
;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE