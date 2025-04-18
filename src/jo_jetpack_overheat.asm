;----------------------------------------------------------;
;                     Jetpack Overheating                  ;
;----------------------------------------------------------;
	MODULE jo 
; During the flight, the Jetpack heats up. When it overheats, the Jetman can only fly slowly. To cool down the Jetpack,
; the Jetman needs to land.

; Jetpack temperature and the temp bar in UI increase in two steps. First, when Jetman is flying, the #jetHeatCnt will increase.
; When it reaches JM_HEAT_CNT, the jetpack temperature will increase (#jetTempLevel) until it reaches MAX_TEMP. Then, it will update Jetman
; state to #JETST_OVERHEAT and slow flying down. 
; When Jetman lands, the #jetCoolCnt decreases. When it reaches JM_COOL_CNT, the jetpack temperature decreases,
; until it reaches #TEMP_NORM. At this point, the Jetman state changes to #JETST_NORMAL, and Jetman can fly at a full speed.

; Jetpack heats up/cools down during the flight.
jetHeatCnt				BYTE 0					; Runs from 0 to JM_HEAT_CNT
jetCoolCnt				BYTE 0					; Runs from 0 to JM_COOL_CNT

jetTempLevel			BYTE 0

TEMP_MAX				= 6
TEMP_NORM				= 2
TEMP_RED				= 4
TEMP_MIN				= 0

BAR_TILE_START			= 31*2					; *2 because each tile takes 2 bytes
BAR_TILE_PAL			= $30
BAR_TILES				= 6
BAR_FULL_SPR			= 176
BAR_EMPTY_SPR			= 182


; The Jetpack heating up / cooling down thresholds.
JM_HEAT_RED_CNT			= 80
JM_HEAT_CNT				= 40
JM_COOL_CNT				= 20

;----------------------------------------------------------;
;                 #ResetJetpackOverheating                 ;
;----------------------------------------------------------;
ResetJetpackOverheating
	XOR A
	LD (jetHeatCnt), A
	LD (jetCoolCnt), A
	LD (jetTempLevel), A
	CALL _UpdateUiHeatBar

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                #UpdateJetpackOverheating                 ;
;----------------------------------------------------------;
UpdateJetpackOverheating

	; Increase the overheating timer if Jetman is flying.
	LD A, (jt.jetAir)
	CP jt.STATE_INACTIVE
	JR Z, .afterFlaying
	
	; Jetman is flying.
	CALL _JetpackTempUp
	RET
.afterFlaying

	; ##########################################
	; Increase the cool down timer if Jetman is walking.
	LD A, (jt.jetGnd)
	CP jt.STATE_INACTIVE
	RET Z
	
	; Jetman is walking.
	CALL _JetpackTempDown

	RET											; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                    #_JetpackTempUp                       ;
;----------------------------------------------------------;
_JetpackTempUp

	; Check if Jetpack has overheated already.
	LD A, (jetTempLevel)
	CP TEMP_MAX
	RET Z

	; ##########################################
	; Increase the heat counter, and check whether it's necessary to increase the heat level of the jetpack.
	LD A, (jetHeatCnt)
	INC A
	LD (jetHeatCnt),A

	; Heat increase speed slows down when #jetTempLevel is over JM_HEAT_RED_CNT.
	; if #jetTempLevel < TEMP_RED then compare #jetHeatCnt with JM_HEAT_CNT
	; if #jetTempLevel >= TEMP_RED then compare #jetHeatCnt with JM_HEAT_RED_CNT
	LD A, (jetTempLevel)
	CP TEMP_RED
	JR NC, .increaseSlow

	; Fast heat increase.
	LD A, (jetHeatCnt)
	CP JM_HEAT_CNT
	RET NZ										; The counter did not reach the required value to increase jeptack's temp.
	JR .afterIncrease

.increaseSlow
	; Slow down hating.
	LD A, (jetHeatCnt)
	CP JM_HEAT_RED_CNT
	RET NZ										; The counter did not reach the required value to increase jeptack's temp.
.afterIncrease

	; Heat up counter has reached max value, reset it.
	XOR A
	LD (jetHeatCnt),A

	; ##########################################
	; Increase jetpack temp.
	LD A, (jetTempLevel)
	INC A
	LD (jetTempLevel),A

	CP TEMP_MAX
	JR NZ, .afterTempCheck

	; Jetpack has overhated.
	LD A, jt.JETST_OVERHEAT
	LD (jt.jetState), A
.afterTempCheck	

	CALL _UpdateUiHeatBar
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                   #_JetpackTempDown                      ;
;----------------------------------------------------------;
_JetpackTempDown

	; Exit if jetpack is cold
	LD A, (jetTempLevel)
	CP TEMP_MIN
	RET Z

	; ##########################################
	; Increase the heat counter, and check whether it's necessary to decrease the heat level of the jetpack.
	LD A, (jetCoolCnt)
	INC A
	LD (jetCoolCnt),A

	CP JM_COOL_CNT
	RET NZ										; The counter did not reach the required value to decrease jeptack temp.

	; Cool down counter has reached max value, reset it.
	XOR A
	LD (jetCoolCnt), A

	; ##########################################
	; Decrease jetpack temp.
	LD A, (jetTempLevel)
	DEC A
	LD (jetTempLevel),A

	CP TEMP_NORM
	JR NZ, .afterNormTempCheck

	; Jetpack is coll again.
	LD A, jt.JETST_NORMAL
	LD (jt.jetState), A
.afterNormTempCheck

	CALL _UpdateUiHeatBar
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                 #_UpdateUiHeatBar                        ;
;----------------------------------------------------------;
_UpdateUiHeatBar

	LD B, 0
	LD HL, ti.RAM_START_H5B00 + BAR_TILE_START -1	; HL points to screen memory containing tilemap. ; // TODO why -1?
.tilesLoop

	; ##########################################
	; Load heat progress bar.
	LD A, (jetTempLevel)
	CP B
	JR NC, .emptyBar							; Jump if B >= #jetTempLevel
	LD A, BAR_EMPTY_SPR
	JR .afterBar
.emptyBar
	LD A, BAR_FULL_SPR
.afterBar
	ADD B
	
	LD (HL), BAR_TILE_PAL						; Set palette for tile.
	INC HL
	
	LD (HL), A									; Set tile id.
	INC HL	

	; ##########################################
	; Loop
	INC B
	LD A, B
	CP BAR_TILES
	JR NZ, .tilesLoop

	RET											; ## END of the function ##
;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE
