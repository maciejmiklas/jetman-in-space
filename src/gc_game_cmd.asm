;----------------------------------------------------------;
;                      Game Command                        ;
;----------------------------------------------------------;
	MODULE gc

;----------------------------------------------------------;
;                   #GameLoopCmd                           ;
;----------------------------------------------------------;
	//DEFINE  PERFORMANCE_BORDER 
GameLoopCmd

	IFDEF PERFORMANCE_BORDER
		LD	A, _COL_GREEN_D4
		OUT (_BORDER_IO_HFE), A
	ENDIF

	CALL sc.WaitForScanline

	IFDEF PERFORMANCE_BORDER
		LD	A, _COL_RED_D2
		OUT (_BORDER_IO_HFE), A
	ENDIF	

	CALL gl.GameLoop

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                      #SetupGame                          ;
;----------------------------------------------------------;
SetupGame
	CALL sc.SetupScreen
	CALL ti.SetupTiles
	CALL sp.LoadSpritesFPGA

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                      #LoadLevel1                         ;
;----------------------------------------------------------;
LoadLevel1

	CALL _InitLevelLoad
	CALL ll.LoadLevel1Data
	CALL _StartLevel
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                      #LoadLevel2                         ;
;----------------------------------------------------------;
LoadLevel2

	CALL _InitLevelLoad
	CALL ll.LoadLevel2Data
	CALL _StartLevel
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                      #LoadLevel3                         ;
;----------------------------------------------------------;
LoadLevel3

	CALL _InitLevelLoad
	CALL ll.LoadLevel3Data
	CALL _StartLevel

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                      #LoadLevel4                         ;
;----------------------------------------------------------;
LoadLevel4

	CALL _InitLevelLoad
	CALL ll.LoadLevel4Data
	CALL _StartLevel

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                      #LoadLevel5                         ;
;----------------------------------------------------------;
LoadLevel5

	CALL _InitLevelLoad
	CALL ll.LoadLevel5Data
	CALL _StartLevel

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                      #LoadLevel6                         ;
;----------------------------------------------------------;
LoadLevel6

	CALL _InitLevelLoad
	CALL ll.LoadLevel6Data
	CALL _StartLevel

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                      #LoadLevel7                         ;
;----------------------------------------------------------;
LoadLevel7

	CALL _InitLevelLoad
	CALL ll.LoadLevel7Data
	CALL _StartLevel

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                      #LoadLevel8                         ;
;----------------------------------------------------------;
LoadLevel8

	CALL _InitLevelLoad
	CALL ll.LoadLevel8Data
	CALL _StartLevel

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                      #LoadLevel9                         ;
;----------------------------------------------------------;
LoadLevel9

	CALL _InitLevelLoad
	CALL ll.LoadLevel9Data
	CALL _StartLevel

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                     #LoadLevel10                         ;
;----------------------------------------------------------;
LoadLevel10

	CALL _InitLevelLoad
	CALL ll.LoadLevel10Data
	CALL _StartLevel
	
	RET											; ## END of the function ##

;----------------------------------------------------------;
;              #BackgroundPaletteLoaded                    ;
;----------------------------------------------------------;
BackgroundPaletteLoaded

	CALL st.LoadStarsPalette					; Call it after the level palette because the stars' colors are right after it.

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                    #RocketTakesOff                       ;
;----------------------------------------------------------;
RocketTakesOff
	CALL jt.SetJetStateInactive
	CALL js.HideJetSprite
	CALL gb.HideGameBar
	CALL ti.SetTilesClipRocket

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #RocketExplosionOver                    ;
;----------------------------------------------------------;
RocketExplosionOver

	CALL ti.ResetTilemapOffset
	CALL ro.HideRocket
	CALL ro.ResetAndDisableRocket
	CALL ti.SetTilesClipFull

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                   #RocketFlyingEnd                       ;
;----------------------------------------------------------;
RocketFlyingEnd

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                     #RocketFlying                        ;
;----------------------------------------------------------;
RocketFlying
	
	CALL bg.UpdateBackgroundOnRocketMove
	CALL bg.HideBackgroundBehindHorizon

	RET											; ## END of the function ##	

;----------------------------------------------------------;
;                        #EnemyHit                         ;
;----------------------------------------------------------;
; Input
;  - IX:	Pointer enemy's #SPR.
EnemyHit

	CALL sr.SetSpriteId
	CALL sr.SpriteHit

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                      #EnemyHitsJet                       ;
;----------------------------------------------------------;
; Input
;  - IX:	Pointer enemy's #SPR
EnemyHitsJet

	; Destroy the enemy.
	CALL sr.SetSpriteId
	CALL sr.SpriteHit

	; ##########################################
	; Is Jetman already dying? If so, do not start the RiP sequence again, just kill the enemy.
	LD A, (jt.jetState)							
	CP jt.JET_ST_RIP
	RET Z										; Exit if RIP.

	; ##########################################
	; Is Jetman invincible? If so, just kill the enemy.
	CP jt.JET_ST_INV
	RET Z										; Exit if invincible.

	; ##########################################
	; This is the first enemy hit.
	CALL jt.SetJetStateRip
	
	LD A, js.SDB_RIP							; Change animation.
	CALL js.ChangeJetSpritePattern

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                      #RespawnJet                         ;
;----------------------------------------------------------;
RespawnJet

	; Set respawn coordinates.
	LD BC, _JET_RESPAWN_X_D100
	LD (jpo.jetX), BC

	LD A, _JET_RESPAWN_Y_D217
	LD (jpo.jetY), A

	; Reload the image because it has moved with the Jetman, and now he respawns on the ground.
	CALL bm.LoadImage

	CALL jt.SetJetStateRespawn

	LD HL, _INVINCIBLE_D400
	CALL jco.MakeJetInvincible

	CALL bg.UpdateBackgroundOnJetmanMove
	CALL ro.ResetCarryingRocketElement

	; Show stars after loading the background image.
	CALL st.ShowStars

	; Switch to flaying animation.
	LD A, js.SDB_FLY
	CALL js.ChangeJetSpritePattern

	RET											; ## END of the function ##	

;----------------------------------------------------------;
;                      #JetmanMoves                        ;
;----------------------------------------------------------;
; Called on any Jetman movement, always before the method indicating concrete movement (#JetmanMovesUp,#JetmanMovesDown).
JetmanMoves

	CALL ro.UpdateRocketOnJetmanMove

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                     #JetmanMovesUp                       ;
;----------------------------------------------------------;
JetmanMovesUp

	; The #UpdateBackgroundOnJetmanMove calculates #bgOffset, which is used to hide the background line behind the horizon.
	; To avoid glitches, like not hidden lines, we always have to first hide the line and then calculate the #bgOffset. This will introduce 
	; a one pixel delay, but at the same time, it ensures that the previously hidden line will get repainted by direction change.
	CALL bg.HideBackgroundBehindHorizon
	CALL bg.UpdateBackgroundOnJetmanMove
	CALL st.MoveStarsDown

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                    #JetmanMovesDown                      ;
;----------------------------------------------------------;
JetmanMovesDown

	CALL bg.ShowBackgroundAboveHorizon
	CALL bg.UpdateBackgroundOnJetmanMove
	CALL st.MoveStarsUp

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                 #MovementInactivity                      ;
;----------------------------------------------------------;
; It gets executed as a last procedure after the input has been processed, and there was no movement from joystick.
MovementInactivity

	; Increment inactivity counter.
	LD A, (jm.jetInactivityCnt)
	INC A
	LD (jm.jetInactivityCnt), A	

	; ##########################################
	; Should Jetman hover?
	LD A, (jt.jetAir)
	CP jt.STATE_INACTIVE						; Is Jetman in the air?
	JR Z, .afterHoover							; Jump if not flaying.

	LD A, (jt.jetAir)
	CP jt.AIR_HOOVER							; Jetman is in the air, but is he hovering already?
	JR Z, .afterHoover							; Jump if already hovering.

	; Jetman is in the air, not hovering, but is he not moving long enough?
	LD A, (jm.jetInactivityCnt)
	CP _HOVER_START_D250
	JR NZ, .afterHoover							; Jetman is not moving, by sill not long enough to start hovering.

	; Jetman starts to hover!
	LD A, jt.AIR_HOOVER
	CALL jt.SetJetStateAir

	LD A, js.SDB_HOVER
	CALL js.ChangeJetSpritePattern
	RET						; Already hovering, do not check standing.
.afterHoover

	; ##########################################
	; Jetman is not hovering, but should he stand?
	LD A, (jt.jetGnd)
	CP jt.STATE_INACTIVE						; Is Jetman on the ground already?
	RET Z										; Jump if not on the ground.

	LD A, (jt.jetGnd)
	CP jt.GND_STAND								; Jetman is on the ground, but is he standing already?
	RET Z										; Jump if already standing.

	; ##########################################
	; Jetman is on the ground and does not move, but is he not moving long enough?
	LD A, (jm.jetInactivityCnt)
	CP _STAND_START_D30
	JR NZ, .afterStand							; Jump if Jetman stands for too short to trigger standing.
	
	; Transtion from walking to standing.
	LD A, jt.GND_STAND
	CALL jt.SetJetStateGnd

	LD A, js.SDB_STAND							; Change animation.
	CALL js.ChangeJetSpritePattern
	RET
.afterStand

	; We are here because: jetInactivityCnt > 0 and jetInactivityCnt < _STAND_START_D30 
	; Jetman stands still for a short time, not long enough, to play standing animation, but at least we should stop walking animation.
	LD A, (jt.jetGnd)
	CP jt.GND_WALK
	RET NZ										; Jump is if not walking.
	
	CP jt.GND_JSTAND
	RET Z										; Jump already j-standing (just standing - for a short time).

	LD A, (jm.jetInactivityCnt)
	CP _JSTAND_START_D100
	RET NZ										; Jump if Jetman stands for too short to trigger j-standing.

	LD A, jt.GND_JSTAND
	CALL jt.SetJetStateGnd

	LD A, js.SDB_JSTAND							; Change animation.
	CALL js.ChangeJetSpritePattern

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                      JoyWillEnable                       ;
;----------------------------------------------------------;
JoyWillEnable

	CALL jt.UpdateStateOnJoyWillEnable

	RET											; ## END of the function ##


;----------------------------------------------------------;
;                         NightEnds                        ;
;----------------------------------------------------------;
NightEnds

	; #NextTodPalette moves the palette address to the next chunk after loading colors into the hardware. Now, we are after the last 
	; transition step from day to night (night to day will start), and the palette address points to the memory containing the next step, 
	; but there is no palette on that address. We have to move the back palette addresses by one palette so that it points to the last 
	; palette containing colors for the darkest night.
	CALL btd.PrevTodPaletteAddr

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                    #NextDayToNight                       ;
;----------------------------------------------------------;
; The function will be called when a night shifts to a day.
; Call sequence:
; A) NextDayToNight -> NextDayToNight -> .... -> NextDayToNight -> GOTO B)
; B) NextNightToDay -> NextNightToDay -> .... -> NextNightToDay -> ChangeToFullDay -> GOTO A)
NextDayToNight

	CALL btd.NextTodPalette

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                  #NextNightToDay                         ;
;----------------------------------------------------------;
; The function will be called when a day shifts to a night.
NextNightToDay

	CALL btd.PrevTodPalette

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                   #ChangeToFullDay                       ;
;----------------------------------------------------------;
; Called when the lighting condition has changed to a full day.
ChangeToFullDay

	CALL btd.ResetPaletteArrd
	CALL btd.LoadCurrentTodPalette

	RET											; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                     #_StartLevel                         ;
;----------------------------------------------------------;
_StartLevel

	CALL gc.RespawnJet
	CALL ro.StartRocketAssembly
	CALL ti.ResetTilemapOffset

	RET											; ## END of the function ##


;----------------------------------------------------------;
;                   #_InitLevelLoad                        ;
;----------------------------------------------------------;
_InitLevelLoad

	CALL jt.SetJetStateInactive
	CALL js.HideJetSprite
	CALL bm.HideImage
	CALL td.ResetTimeOfDay

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE