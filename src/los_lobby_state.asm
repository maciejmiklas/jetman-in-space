;----------------------------------------------------------;
;                      Lobby State                         ;
;----------------------------------------------------------;
	MODULE los

LOBBY_INACTIVE			= 0
MAIN_MENU				= 1

lobbyState				BYTE LOBBY_INACTIVE

;----------------------------------------------------------;
;                #SetLobbyStateInactive                    ;
;----------------------------------------------------------;
SetLobbyStateInactive

	LD A, LOBBY_INACTIVE
	LD (lobbyState), A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                #SetLobbyStateMainMenu                    ;
;----------------------------------------------------------;
SetLobbyStateMainMenu

	LD A, MAIN_MENU
	LD (lobbyState), A

	RET											; ## END of the function ##
	
;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE