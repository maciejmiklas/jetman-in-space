;----------------------------------------------------------;
;                      Lobby State                         ;
;----------------------------------------------------------;
	MODULE los

LOBBY_INACTIVE			= 0
LEVEL_INTRO				= 1
MAIN_MENU				= 2

lobbyState				BYTE LOBBY_INACTIVE

;----------------------------------------------------------;
;                #SetLobbyStateInactive                    ;
;----------------------------------------------------------;
SetLobbyStateInactive

	LD A, LOBBY_INACTIVE
	LD (lobbyState), A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;               #SetLobbyStateLevelIntro                   ;
;----------------------------------------------------------;
SetLobbyStateLevelIntro

	LD A, LEVEL_INTRO
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