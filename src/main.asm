	DEVICE ZXSPECTRUMNEXT						; Allow the Next paging and instructions
	ORG RAM_SLOT_4_START

start:
	DI											; Disable Interupts, use wait_for_scanline instead.					

	NEXTREG REG_TURBO, %00000011    			; Switch to 28MHz
	NEXTREG SPR_SETUP, %01000011 				; Sprite 0 on top, SLU, over border, sprites visible

	CALL SetupScreen



;----------------------------------------------------------;
;                      Game Loop                           ;
;----------------------------------------------------------;
MainLoop:	
	CALL GameLoop

	JR MainLoop

;----------------------------------------------------------;
;                       Includes                           ;
;----------------------------------------------------------;
	INCLUDE "_constants.asm"
	INCLUDE "api_sprite.asm"
	INCLUDE "api_screen.asm"
	INCLUDE "api_joystick.asm"
	INCLUDE "player.asm"
	INCLUDE "enemies.asm"
	INCLUDE "game.asm"
	INCLUDE "util.asm"

;----------------------------------------------------------;
;                         Data                             ;
;----------------------------------------------------------;
; Load sprites into MMU slot 40,41 (16KB) mapping it to Bank: 6 and 7
	MMU 6 7, 40   
	ORG RAM_SLOT_6_START
spritesFile INCBIN "assets/sprites.spr"

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
	; whether we require the full 2MB expansion (0 = no we don't).
	SAVENEX CFG 7,0,0,0

	; Generate the Nex file automatically based on which pages you use.
	SAVENEX AUTO