;----------------------------------------------------------;
;                         Main File                        ;
;----------------------------------------------------------;

	DEVICE ZXSPECTRUMNEXT						; Allow the Next paging and instructions
	ORG _RAM_SLOT4_START_H8000

start
	DI											; Disable Interrupts, use wait_for_scanline instead.					

	NEXTREG _GL_REG_TURBO_H07, %00000011		; Switch to 28MHz
			
	INCLUDE "dl_data_load.asm"
	CALL ScSetupScreen
	CALL GmGameInit

vv BYTE  0
;----------------------------------------------------------;
;                      Game Loop                           ;
;----------------------------------------------------------;
mainLoop	
	CALL GmGameLoop
	JR mainLoop

;----------------------------------------------------------;
;                       Includes                           ;
;----------------------------------------------------------;
	INCLUDE "_constants.asm"
	INCLUDE "sp_sprite.asm"
	INCLUDE "sc_screen.asm"
	INCLUDE "jo_jetman_joystick.asm"
	INCLUDE "jt_jetman.asm"
	INCLUDE "js_jetman_sprite.asm"
	INCLUDE "jp_jetman_platform.asm"
	INCLUDE "ea_enemy_fly_01.asm"
	INCLUDE "gm_game.asm"
	INCLUDE "tx_text.asm"
	INCLUDE "ti_tiles.asm"
	INCLUDE "jw_jetman_weapon.asm"
	INCLUDE "sr_simple_sprite.asm"
	INCLUDE "ut_util.asm"

	; LAST import due to bank offset!
	INCLUDE "di_data_bin.asm"
;----------------------------------------------------------;
;                      sjasmplus                           ;
;----------------------------------------------------------;
	; https://z00m128.github.io/sjasmplus/documentation.html

	CSPECTMAP "jetman.map"						; Generate a map file for use with Cspect

	; This sets the name of the project, the start address, 
	; and the initial stack pointer.
	SAVENEX OPEN "jetman.nex", start, $FF40

	; This asserts the minimum core version.  Set it to the core version 
	; you are developing on.
	SAVENEX CORE 2,0,0

	; SAVENEX CFG <border 0..7>[,<fileHandle 0/1/$4000+>[,<PreserveNextRegs 0/1>[,<2MbRamReq 0/1>]]]
	SAVENEX CFG 0,0,0,0

	; Generate the Nex file automatically based on which pages you use.
	SAVENEX AUTO