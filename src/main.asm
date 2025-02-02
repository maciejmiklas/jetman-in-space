;----------------------------------------------------------;
;                         Main File                        ;
;----------------------------------------------------------;
STACK_SIZE				= 100

	DEVICE ZXSPECTRUMNEXT						; Allow the Next paging and instructions.
	ORG _RAM_SLOT4_START_H8000 + STACK_SIZE		; Stack strats at 8000.

start
	DI											; Disable Interrupts, use wait_for_scanline instead.
	NEXTREG _GL_REG_TURBO_H07, %00000011		; Switch to 28MHz.
			
	INCLUDE "dl_data_load.asm"
	
	CALL sc.SetupScreen
	CALL gc.LoadLevel1
	CALL gm.GameInit

	;CALL ro.AssemblyRocketForDebug 				; FIXME - remoe it!

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

	INCLUDE "id_input_data.asm"
	INCLUDE "in_input.asm"
	INCLUDE "tx_text.asm"
	INCLUDE "ti_tiles.asm"
	INCLUDE "ut_util.asm"
	INCLUDE "gld_game_loop_data.asm"
	INCLUDE "gl_game_loop.asm"

	INCLUDE "gm_game.asm"

	INCLUDE "ll_level_loader.asm"
	INCLUDE "bm_bitmap.asm"
	INCLUDE "bp_bitmap_palette.asm"
	INCLUDE "btd_tod_palette.asm"
	INCLUDE "gc_game_cmd.asm"
	INCLUDE "gb_game_bar.asm"
	INCLUDE "sc_screen.asm"
	INCLUDE "sr_simple_sprite.asm"
	INCLUDE "sp_sprite.asm"
	INCLUDE "jt_jet_state.asm"
	INCLUDE "jpo_jet_position.asm"
	INCLUDE "jco_jet_colision.asm"
	INCLUDE "js_jet_sprite.asm"
	INCLUDE "pl_platform.asm"
	INCLUDE "bg_background.asm"
	INCLUDE "jm_jet_move.asm"
	INCLUDE "ep_enemy_pattern.asm"
	INCLUDE "ef_enemy_formation.asm"
	INCLUDE "ed_data_enemy.asm"
	INCLUDE "jw_jet_weapon.asm"
	INCLUDE "ro_rocket.asm"
	INCLUDE "st_stars.asm"
	INCLUDE "lo_lobby.asm"
	INCLUDE "td_times_of_day.asm"

	; LAST import due to bank offset!
	INCLUDE "dbi_data_bin.asm"
;----------------------------------------------------------;
;                      sjasmplus                           ;
;----------------------------------------------------------;
; https://z00m128.github.io/sjasmplus/documentation.html

	CSPECTMAP "jetman.map"						; Generate a map file for use with Cspect.

	; This sets the name of the project, the start address, and the initial stack pointer.
	SAVENEX OPEN "jetman.nex", start, _RAM_SLOT4_START_H8000

	; This asserts the minimum core version.
	SAVENEX CORE 3,0,0

	; SAVENEX CFG <border 0..7>[,<fileHandle 0/1/$4000+>[,<PreserveNextRegs 0/1>[,<2MbRamReq 0/1>]]].
	SAVENEX CFG 0,0,0,0

	; Generate the Nex file automatically based on which pages you use.
	SAVENEX AUTO
	SAVENEX CLOSE