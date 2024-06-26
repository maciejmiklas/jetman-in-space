;----------------------------------------------------------;
;                         Main File                        ;
;----------------------------------------------------------;

	DEVICE ZXSPECTRUMNEXT						; Allow the Next paging and instructions
	ORG _RAM_SLOT4_START_H8000

start
	DI											; Disable Interrupts, use wait_for_scanline instead
	NEXTREG _GL_REG_TURBO_H07, %00000011		; Switch to 28MHz
			
	INCLUDE "dl_data_load.asm"
	CALL sc.SetupScreen
	CALL gm.GameInit

;----------------------------------------------------------;
;                      Game Loop                           ;
;----------------------------------------------------------;
mainLoop	
	CALL gm.GameLoop
	JR mainLoop

;----------------------------------------------------------;
;                       Includes                           ;
;----------------------------------------------------------;
	INCLUDE "_constants.asm"

	INCLUDE "in_input.asm"
	INCLUDE "tx_text.asm"
	INCLUDE "ti_tiles.asm"
	INCLUDE "ut_util.asm"

	INCLUDE "gm_game.asm"

	INCLUDE "sr_simple_sprite.asm"
	INCLUDE "sp_sprite.asm"	
	INCLUDE "jd_jetman_data.asm"
	INCLUDE "jp_jetman_platform.asm"
	INCLUDE "jt_jetman.asm"
	INCLUDE "js_jetman_sprite.asm"
	INCLUDE "ep_enemy_pattern.asm"
	INCLUDE "ef_enemy_formation.asm"
	INCLUDE "sc_screen.asm"
	INCLUDE "jw_jetman_weapon.asm"

	; LAST import due to bank offset!
	INCLUDE "di_data_bin.asm"
;----------------------------------------------------------;
;                      sjasmplus                           ;
;----------------------------------------------------------;
	; https://z00m128.github.io/sjasmplus/documentation.html

	CSPECTMAP "jetman.map"						; Generate a map file for use with Cspect

	; This sets the name of the project, the start address, and the initial stack pointer.
	SAVENEX OPEN "jetman.nex", start, $FF40

	; This asserts the minimum core version. 
	SAVENEX CORE 3,0,0

	; SAVENEX CFG <border 0..7>[,<fileHandle 0/1/$4000+>[,<PreserveNextRegs 0/1>[,<2MbRamReq 0/1>]]]
	SAVENEX CFG 0,0,0,0

	; Generate the Nex file automatically based on which pages you use.
	SAVENEX AUTO
	SAVENEX CLOSE