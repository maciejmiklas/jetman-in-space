	
	DEVICE ZXSPECTRUMNEXT						; Allow the Next paging and instructions	
	ORG $8000

spritesFile INCBIN "assets/sprites.spr"

start:
	DI											; Disable Interupts, use wait_for_scanline instead.					

	NEXTREG REG_TURBO, %00000011    			; Switch to 28MHz
	NEXTREG REG_LAYER2, %10000000     			; Layer 2 screen resolution 256 x 192 x 8bpp

	CALL ClearScreen

	; Load sprites to Hardware
	LD HL, spritesFile							; Sprites binary data
	LD BC, 16*16*63								; Copy 63 sprites, each 16x16 pixels
	CALL LoadSprites						

	CALL IntiJetman

;----------------------------------------------------------;
;                      Game Loop                           ;
;----------------------------------------------------------;
MainLoop:	
	CALL WaitOneFrame
	CALL HandleJoystickInput
	CALL UpdateJetman
	CALL AnimateSprites
	JR MainLoop

;----------------------------------------------------------;
;                       Imports                            ;
;----------------------------------------------------------;
	INCLUDE "_constants.asm"
	INCLUDE "api_sprite.asm"
	INCLUDE "api_display.asm"
	INCLUDE "api_joystick.asm"
	INCLUDE "jetman.asm"
	INCLUDE "enemies.asm"
	INCLUDE "game.asm"

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