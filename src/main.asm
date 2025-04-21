;----------------------------------------------------------;
;                         Main File                        ;
;----------------------------------------------------------;
STACK_SIZE				= 100

	DEVICE ZXSPECTRUMNEXT						; Allow the Next paging and instructions.
	ORG _RAM_SLOT4_STA_H8000 + STACK_SIZE		; Stack starts at 8000.

start
	DI											; Disable Interrupts, use wait_for_scanline instead.
	NEXTREG _GL_REG_TURBO_H07, %00000011		; Switch to 28MHz.
	
	CALL gc.SetupGame
	;CALL gc.LoadLevel1
	CALL gc.LoadLobby
	
	;CALL ro.AssemblyRocketForDebug

;----------------------------------------------------------;
;                      Main Loop                           ;
;----------------------------------------------------------;
mainLoop
	CALL gc.MainLoopCmd
	JR mainLoop

;----------------------------------------------------------;
;                       Includes                           ;
;----------------------------------------------------------;
	INCLUDE "_constants.asm"

	INCLUDE "gid_game_input_data.asm"
	INCLUDE "gi_game_input.asm"
	INCLUDE "tx_text.asm"
	INCLUDE "ti_tiles.asm"
	INCLUDE "ut_util.asm"
	INCLUDE "gld_game_loop_data.asm"
	INCLUDE "ml_main_loop.asm"

	INCLUDE "gc_game_cmd.asm"

	INCLUDE "fi_file_io.asm"
	INCLUDE "dbs_bank_setup.asm"
	INCLUDE "ll_level_loader.asm"
	INCLUDE "bm_bitmap.asm"
	INCLUDE "bp_bitmap_palette.asm"
	INCLUDE "btd_tod_palette.asm"
	INCLUDE "gb_game_bar.asm"
	INCLUDE "sc_screen.asm"
	INCLUDE "sr_simple_sprite.asm"
	INCLUDE "sp_sprite.asm"
	INCLUDE "jt_jet_state.asm"
	INCLUDE "jpo_jet_position.asm"
	INCLUDE "jco_jet_collision.asm"
	INCLUDE "js_jet_sprite.asm"
	INCLUDE "pl_platform.asm"
	INCLUDE "bg_background.asm"
	INCLUDE "jm_jet_move.asm"
	INCLUDE "ep_enemy_pattern.asm"
	INCLUDE "ef_enemy_formation.asm"
	INCLUDE "es_enemy_single.asm"
	INCLUDE "jw_jet_weapon.asm"
	INCLUDE "ro_rocket.asm"
	INCLUDE "ros_rocket_stars.asm"
	INCLUDE "td_times_of_day.asm"
	INCLUDE "st_stars.asm"
	INCLUDE "jo_jetpack_overheat.asm"
	INCLUDE "loi_lobby_input.asm"
	INCLUDE "lom_lobby_menu.asm"
	INCLUDE "los_lobby_state.asm"

	; LAST import due to bank offset!
	INCLUDE "db_data_bin.asm"
	
;----------------------------------------------------------;
;                      sjasmplus                           ;
;----------------------------------------------------------;
; https://z00m128.github.io/sjasmplus/documentation.html

	CSPECTMAP "jetman.map"						; Generate a map file for use with Cspect.

	; This sets the name of the project, the start address, and the initial stack pointer.
	SAVENEX OPEN "jetman.nex", start, _RAM_SLOT4_STA_H8000

	; This asserts the minimum core version.
	SAVENEX CORE 3,0,0

	; SAVENEX CFG <border 0..7>[,<fileHandle 0/1/$4000+>[,<PreserveNextRegs 0/1>[,<2MbRamReq 0/1>]]].
	SAVENEX CFG 0,0,0,0

	; Generate the Nex file automatically based on which pages you use.
	SAVENEX AUTO
	SAVENEX CLOSE