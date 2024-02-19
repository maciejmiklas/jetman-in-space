	
	DEVICE ZXSPECTRUMNEXT					; Allow the Next paging and instructions	
	ORG $8000

start:
	CALL Setup

	CALL ShowSprites
	
;----------------------------------------------------------;
;                      Game Loop                           ;
;----------------------------------------------------------;
MainLoop:
	CALL HandleJoystingInput
	CALL WaitForScanlineUnderUla
	JR MainLoop

;----------------------------------------------------------;
;                      Routines                            ;
;----------------------------------------------------------;
	INCLUDE "src/constants.asm"
	INCLUDE "src/setup.asm"
	INCLUDE "src/data.asm"
	INCLUDE "src/sprites.asm"
	INCLUDE "src/game_input.asm"
	INCLUDE "src/jetman_move.asm"
	INCLUDE "src/display_sync.asm"

;----------------------------------------------------------;
;                      sjasmplus                           ;
;----------------------------------------------------------;
	; https://z00m128.github.io/sjasmplus/documentation.html

	CSPECTMAP "jetman.map"					; Generate a map file for use with Cspect

	; This sets the name of the project, the start address, 
	; and the initial stack pointer.
	SAVENEX OPEN "jetman.nex", start, $FF40

	; This asserts the minimum core version.  Set it to the core version 
	; you are developing on.
	SAVENEX CORE 2,0,0

	; This sets the border colour while loading (in this case white),
	; what to do with the file handle of the nex file when starting (0 = 
	; close file handle as we're not going to access the project.nex 
	; file after starting.  See sjasmplus documentation), whether
	; we preserve the next registers (0 = no, we set to default), and 
	; whether we require the full 2MB expansion (0 = no we don't).
	SAVENEX CFG 7,0,0,0

	; Generate the Nex file automatically based on which pages you use.
	SAVENEX AUTO