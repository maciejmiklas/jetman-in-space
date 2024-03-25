	DEVICE ZXSPECTRUMNEXT						; Allow the Next paging and instructions
	ORG RAM_SLOT_4_START_H8000

start:
	DI											; Disable Interupts, use wait_for_scanline instead.					

	NEXTREG GL_REG_TURBO_H07, %00000011    		; Switch to 28MHz
			
	INCLUDE "data_load.asm"
	CALL SetupScreen
	CALL GameInit

vv BYTE  0
;----------------------------------------------------------;
;                      Game Loop                           ;
;----------------------------------------------------------;
mainLoop:	

	CALL GameLoop
	JR mainLoop

;----------------------------------------------------------;
;                       Includes                           ;
;----------------------------------------------------------;
	INCLUDE "_zx_next_constants.asm"
	INCLUDE "sprite.asm"
	INCLUDE "screen.asm"
	INCLUDE "joystick.asm"
	INCLUDE "jetman.asm"
	INCLUDE "enemies.asm"
	INCLUDE "game.asm"
	INCLUDE "text.asm"
	INCLUDE "tiles.asm"

	; LAST import due to bank offset!
	INCLUDE "data_bin.asm"
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

	; This sets the border colour while loading (in this case white),
	; what to do with the file handle of the nex file when starting (0 = 
	; close file handle as we're not going to access the project.nex 
	; file after starting.  See sjasmplus documentation), whether
	; we preserve the next registers (0 = no, we set to default), and 
	; whether we r=ire the full 2MB expansion (0 = no we don't).
	SAVENEX CFG 7,0,0,0

	; Generate the Nex file automatically based on which pages you use.
	SAVENEX AUTO