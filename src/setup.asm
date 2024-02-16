Setup:
	DI										; Disable Interupts, use wait_for_scanline instead.					

	NEXTREG REG_L2, %00000000     			; Layer 2 screen resolution 256 x 192 x8bpp
	NEXTREG REG_TURBO, %00000011    		; Switch to 28MHz

	CALL ROM_CLS							;  Clear screen.	
	
	RET