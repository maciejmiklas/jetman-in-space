;----------------------------------------------------------;
;                     Global Constants                     ;
;----------------------------------------------------------;
; Lots of documentation comes from https://wiki.specnext.dev

;----------------------------------------------------------;
;                  General Registers                       ;
;----------------------------------------------------------;
_GL_REG_TURBO_H07		= 11				; Bit 1-0 = Turbo (00 = 3.5MHz, 01 = 7MHz, 10 = 14MHz, 11 = 28Mhz)

_GL_REG_TRANP_COL_H14	= $14				; Global transparency color.
_GL_REG_SELECT_H243B	= $243B				; This Port is used to set the register number.
_GL_REG_VL_H1F			= $1F				; Active video line (LSB).

;----------------------------------------------------------;
;                   Display Control                        ;
;----------------------------------------------------------;

; Layer 2 RAM bank.
_DC_REG_L2_BANK_H12		= $12

; Layer 2 Offset X (0-255) (0 after a reset)
_DC_REG_L2_OFFSET_X_H16	= $16

; Layer 2 Offset Y. (0-191) (0 after a reset)
_DC_REG_L2_OFFSET_Y_H17	= $17

; The coordinate values are 0,255,0,191 after a Reset
; For Layer 2 at 320x256 use 0,159,0,255
_DC_REG_L2_CLIP_H18		= $18

; Tilemap Offset X MSB
; Bits:
;  - 7-2 = Reserved, must be 0
;  - 1-0 = MSB X Offset
_DC_REG_TI_X_MSB_H2f	= $2F

; Tilemap Offset X LSB
; Bits:
;  - 7-0 = LSB X Offset
_DC_REG_TI_X_LSB_H30	= $30

; Tilemap Offset Y
_DC_REG_TI_Y_H31		= $31

; ULA / LoRes Offset X
_DC_REG_ULA_X_H32		= $32

; ULA / LoRes Offset Y
_DC_REG_ULA_Y_H33		= $33

; Bits:
;  - 7: 1 to enable Layer 2 (alias for bit 1 in Layer 2 Access Port $123B),
;  - 6: 1 to enable ULA shadow display (alias for bit 3 in Memory Paging Control $7FFD),
;  - 5-0: Alias for bits 5-0 in Timex Sinclair Video Mode Control $xxFF.
;
; The 256x192x8bpp mode is simple 256 color mode, one pixel is one byte (index into Layer 2 palette), pixels are stored from left to right, 
; from top to bottom.
; The 320x256x8bpp mode is similar, but pixels are stored from top to bottom, then from left to right.
; 
; Don't forget to set up the clip window (_DC_REG_L2_CLIP_H18) for 320x256 mode, to make whole area visible, use 0,159,0,255 settings.
_DC_REG_CONTROL1_H69	= $69

; Bits:
;  - 7-6: Reserved, must be 0,
;  - 5-4: Layer 2 resolution (0 after soft reset),
;			- '00': 256x192, 8BPP,
;			- '01': 320x256, 8BPP,
;			- '10': 640x256, 4BPP.
;  - 3-0: Palette offset (0 after soft reset),
_DC_REG_LA2_H70			= $70

; Selects color index that will be read or written (_DC_REG_LA2_PAL_VAL_H44).
_DC_REG_LA2_PAL_IDX_H40	= $40

; Palette Value (8 bit color).
; bits 7-0 = Color for the palette index selected by the register 0x40.
; (Format is RRRGGGBB - the lower blue bit of the 9-bit color will be a logical or of blue bits 1 and 0 of this 8-bit value.)
; After the write, the palette index is auto-incremented to the next index if the auto-increment is enabled at reg 0x43.
_DC_REG_LA2_PAL_VAL_H41	= $41

; Palette Control
; Bits:
;  - 7: '1' to disable palette write auto-increment (for _DC_REG_LA2_PAL_VAL_H44)
;  - 6-4: Select palette for reading or writing:
;     000 = ULA first palette,
;     100 = ULA second palette,
;     001 = Layer 2 first palette,
;     101 = Layer 2 second palette,
;     010 = Sprites first palette,
;     110 = Sprites second palette,
;     011 = Tilemap first palette,
;     111 = Tilemap second palette.
;  - 3: Select Sprites palette (0 = first palette, 1 = second palette),
;  - 2 Select Layer 2 palette (0 = first palette, 1 = second palette),
;  - 1: Select ULA palette (0 = first palette, 1 = second palette),
;  - 0: Enable ULANext mode if 1. (0 after a reset).
_DC_REG_LA2_PAL_CTR_H43	= $43

; Palette Value (9 bit color)
; Two consecutive writes are needed to write the 9 bit color
; 1st write: bits 7-0 = RRRGGGBB
; 2nd write:
;    If writing a L2 palette:
;      Bits:
;       - 7: 1 for L2 priority color, 0 for normal
;            Priority color will always be on top even on an SLU priority arrangement. If you need the exact same color on priority and non 
;            priority locations you will need to program the same color twice changing bit 7 to 0 for the second color.
;       - 6-1: Reserved, must be 0
;       - 0: LSB B
;   If writing another palette:
;     Bits:
;      - 7-1: Reserved, must be 0
;      - 0:  LSB B
; After the two consecutive writes the palette index is auto-incremented if the auto-increment is enabled by reg 0x43.
_DC_REG_LA2_PAL_VAL_H44	= $44

; Transparency index for the Tilemap
; Bits:
;  - 7-4 = Reserved, must be 0,
;  - 3-0 = Set the index value (0xF after reset).
_DC_REG_TI_TRANSP_H4C = $4C

; Bits:
;  -  7-1: 7-1 Reserved, must be 0,
;  -  0: MSB for X pixel offset.
_DC_REG_LA2_OFFS_H71	= $71

;----------------------------------------------------------;
;                     ROM routines                         ;
;----------------------------------------------------------;
_ROM_PRINT_H10			= $10					; ROM address for "Print Character from A" routine

; ROM address for "Print Text" routine.
; Input:
;    - DE: RAM location containing the text.
;    - BC: Size of the text.
_ROM_PRINT_TEXT_H203C	= $203C

;----------------------------------------------------------;
;                  PRINT Control Codes                     ;
;----------------------------------------------------------;
_PR_INK_H10				= $10
_PR_PAPER_H11			= $11
_PR_FLASH_H12			= $12
_PR_BRIGHT_H13			= $13
_INVERSE_H14			= $14
_PR_OVER_H15			= $15
_PR_AT_H16				= $16
_PR_TAB_H17				= $17
_PR_CR_H0C				= $0C
_PR_ENTER_H0D			= $0D

;----------------------------------------------------------;
;                     RAM 8K Slots                         ;
;----------------------------------------------------------;
_RAM_SLOT0_STA_H0000	= $0000
_RAM_SLOT0_END_H1FFF	= $1FFF

_RAM_SLOT1_STA_H2000	= $2000
_RAM_SLOT1_END_H3FFF	= $3FFF

_RAM_SLOT2_STA_H4000	= $4000
_RAM_SLOT2_END_H5FFF	= $5FFF

_RAM_SLOT3_STA_H6000	= $6000
_RAM_SLOT3_END_H7FFF	= $7FFF

_RAM_SLOT4_STA_H8000	= $8000
_RAM_SLOT4_END_H9FFF	= $9FFF

_RAM_SLOT5_STA_HA000	= $A000
_RAM_SLOT5_END_HBFFF	= $BFFF

_RAM_SLOT6_STA_HC000	= $C000
_RAM_SLOT6_END_HDFFF	= $DFFF

_RAM_SLOT7_STA_HE000	= $E000
_RAM_SLOT7_END_HFFFF	= $FFFF

_RAM_SLOT0				= 0
_RAM_SLOT1				= 1
_RAM_SLOT2				= 2
_RAM_SLOT3				= 3
_RAM_SLOT4				= 4
_RAM_SLOT5				= 5
_RAM_SLOT6				= 6
_RAM_SLOT7				= 7

;----------------------------------------------------------;
;                          MMU                             ;
;----------------------------------------------------------;
_MMU_REG_SLOT0_H50		= $50
_MMU_REG_SLOT1_H51		= $51
_MMU_REG_SLOT2_H52		= $52
_MMU_REG_SLOT3_H53		= $53
_MMU_REG_SLOT4_H54		= $54
_MMU_REG_SLOT5_H55		= $55
_MMU_REG_SLOT6_H56		= $56
_MMU_REG_SLOT7_H57		= $57

;----------------------------------------------------------;
;          		         Sprites	   	                   ;
;----------------------------------------------------------;
_SPR_REG_NR_H34			= $34					; Sprite Number (R/W).
_SPR_REG_X_H35			= $35					; Sprite X coordinate.
_SPR_REG_Y_H36			= $36					; Sprite Y coordinate.

; Bits:
;  - 7-4: Palette offset added to top 4 bits of sprite color index,
;  - 3: X mirror,
;  - 2: Y mirror,
;  - 1: Rotate,
;  - 0: MSB of X coordinate (palette offset indicator for relative sprites).
_SPR_REG_ATR2_H37		= $37
_SPR_REG_ATR2_MIRX_BIT	= 3
_SPR_REG_ATR2_MIRY_BIT	= 2
_SPR_REG_ATR2_ROT_BIT	= 1
_SPR_REG_ATR2_OVER_BIT	= 0
_SPR_REG_ATR2_RES_PAL	= %00001111				; Mask to reset palette bits.
_SPR_REG_ATR2_OVERFLOW	= %00000001
_SPR_REG_ATR2_EMPTY		= %00000000				; No rotation, no mirror, no overflow.

; Bits:
;  - 7: Visible flag (1 = displayed),
;  - 6: Extended attribute (1 = Sprite Attribute 4 is active),
;  - 5-0: Pattern used by sprite (0-63).
_SPR_REG_ATR3_H38		= $38

; Bits:
;  - 7: H (1 = sprite uses 4-bit patterns),
;  - 6: N6 (0 = use the first 128 bytes of the pattern else use the last 128 bytes),
;  - 5: 1 if relative sprites are composite, 0 if relative sprites are unified Scaling,
;  - 4-3: X scaling (00 = 1x, 01 = 2x, 10 = 4x, 11 = 8x),
;  - 2-1: Y scaling (00 = 1x, 01 = 2x, 10 = 4x, 11 = 8x),
;  - 0: MSB of Y coordinate.
_SPR_REG_ATR4_H39		= $39

; Sprite and Layers system.
; Bits:
;  - 7: LoRes mode, 128 x 96 x 256 colors (1 = enabled),
;  - 6: Sprite priority (1 = sprite 0 on top, 0 = sprite 127 on top),
;  - 5: Enable sprite clipping in over border mode (1 = enabled),
;  - 4-2: set layers priorities:
;   Reset default is 000, sprites over the Layer 2, over the ULA graphics:
;    S - Sprites, L - Layer 2, U - ULA
;    - 000: S L U
;    - 001: L S U
;    - 010: S U L - (Top - Sprites, Enhanced_ULA, Layer 2)
;    - 011: L U S
;    - 100: U S L
;    - 101: U L S
;    - 110: S(U+L) ULA and Layer 2 combined, colors clamped to 7
;    - 111: S(U+L-5) ULA and Layer 2 combined, colors clamped to [0,7]
;  - 1: Over border (1 = yes)(Back to 0 after a reset),
;  - 0: Sprites visible (1 = visible)(Back to 0 after a reset).
_SPR_REG_SETUP_H15		= $15

_SPR_PORT_H303B			= $303B

; bit 7 = Visible flag (1 = displayed),
; bits 5-0 = Pattern used by sprite (0-63).
_SPR_PATTERN_SHOW		= %10000000
_SPR_PATTERN_HIDE		= %00000000

;----------------------------------------------------------;
;                        Tiles                             ;
;----------------------------------------------------------;

; Clip Window Tilemap.
; bits 7-0 = coordinates of the clip window.
;  1st write = X1 position
;  2nd write = X2 position
;  3rd write = Y1 position
;  4rd write = Y2 position
;  The values are 0,159,0,255 after a Reset.
_C_TI_CLIP_WINDOW_H1B	= $1B

; Tilemap Offset X MSB.
; bits 7-2 = Reserved, must be 0,
; bits 1-0 = MSB X Offset.
; Meaningful Range is 0-319 in 40 char mode, 0-639 in 80 char mode.
_TI_OFFSET_X_MSB_H2F	= $2F

; Tilemap Offset X LSB.
; Meaningful range is 0-319 in 40 char mode, 0-639 in 80 char mode.
_TI_OFFSET_X_LSB_H30	= $30

; Tilemap Offset Y.
_TI_OFFSET_Y_H31		= $31

; Tilemap Control.
; Bits:
;  - 7: 1 to enable the tilemap,
;  - 6: 0 for 40x32, 1 for 80x32,
;  - 5: 1 to eliminate the attribute entry in the tilemap,
;  - 4: palette select,
;  - 3-2: Reserved set to 0,
;  - 1: 1 to activate 512 tile mode,
;  - 0: 1 to force tilemap on top of ULA.
_TI_MAP_CONTROL_H6B		= $6B

; Tilemap Attribute.
; Bits:
;  - bits 7-4: Palette Offset,
;  - bit 3: X mirror,
;  - bit 2: Y mirror,
;  - bit 1: Rotate,
;  - bit 0: ULA over tilemap. (bit 8 of the tile number if 512 tile mode is enabled). Active tile attribute if bit 5 of NEXTREG 0x6B is set.
_TI_ATTRIBUTE_H6C		= $6C

; Tilemap Base Address.
; The value written is an offset into Bank 5 allowing the tilemap to be placed at any multiple of 256 bytes.
; Writing a physical MSB address in 0x40-0x7F or 0xC0-0xFF range is permitted.
; The value read back should be treated as having a fully significant 8-bit value.
;
; bits 7-6: Read back as zero, write values ignored,
; bits 5-0: MSB of the address of the tilemap in Bank 5 ($A000 - $BFFF).
_TI_MAP_ADR_H6E			= $6E

; Tile Definitions Base Address.
; The value written is an offset into Bank 5 allowing tile definitions to be placed at any multiple of 256 bytes.
; Writing a physical MSB address in 0x40-0x7F or 0xC0-0xFF range is permitted. 
; The value read back should be treated as having a fully significant 8-bit value.
; Bits:
;  - 7-6: Read back as zero, write values ignored,
;  - 5-0: MSB of the address of tile definitions in Bank 5.
_TI_DEF_ADR_H6F			= $6F

;----------------------------------------------------------;
;                         DMA                              ;
;----------------------------------------------------------;
_DMA_PORT_H6B			= $6B					; DMA Port in zxnDMA mode, https://wiki.specnext.dev/DMA

;----------------------------------------------------------;
;                        Colors                            ;
;----------------------------------------------------------;
_BORDER_IO_HFE			= $FE
_COL_BLACK_D0			= 0
_COL_BLUE_D1			= 1
_COL_RED_D2				= 2
_COL_MAGENTA_D3			= 3
_COL_GREEN_D4			= 4
_COL_CYAN_D5			= 5
_COL_YELLOW_D6			= 6
_COL_WHITE_D7			= 7
_COL_BLACK_D0			= 0

;----------------------------------------------------------;
;                     Input processing                     ;
;----------------------------------------------------------;

; Bit:			4	3 	2 	1 	0
; %11111110 	V	C	X	Z	SHIFT
; %11111101		G	F	D	S	A
; %11111011		T	R	E	W	Q
; %11110111		5	4	3	2	1
; %11101111		6	7	8	9	0
; %11011111		Y	U	I	O	P
; %10111111		H	J	K	L	ENTER
; %01111111		B	N	M	DEL	SPC
_KB_5_TO_1_HF7			= $F7					; Mask for row: 1, 2, 3, 4, & 5 and to read left arrow key.
_KB_6_TO_0_HEF			= $EF					; Mask for row: 6, 7, 8 ,9, 0 and to read arrow keys: up/down/right.
_KB_T_TO_Q_HFB			= $FB					; Mask for row: T, R, E, W, Q
_KB_P_TO_Y_HDF			= $DF					; Mask for row: P, O, I, U, Y
_KB_G_TO_A_HFD			= $FD					; Mask for row: G, F, D, S, T, A
_KB_H_TO_ENT_HBF		= $BF					; Mask for row: H, J, K, L, ENTER
_KB_V_TO_SH_HFE			= $FE					; Mask for row: V, C, X, Z, SHIFT
_KB_B_TO_SPC_H7F		= $7F					; Mask for row: B, M, M, FULL-STOP, SPACE

_KB_REG_HFE				= $FE					; Activate keyboard input.

_JOY_REG_H1F			= $1F					; Activate kempston input.
_JOY_MASK_H20			= $20					; Mask to read Kempston input.

;----------------------------------------------------------;
;                         ULA                              ;
;----------------------------------------------------------;
_ULA_COLOR_START_H5800	= $5800					; Start of Display Color RAM.
_ULA_COLOR_END_H5AFF	= $5AFF					; End of Display Color RAM.
_ULA_COL_SIZE			= 768					; Size of color RAM: $5AFF - $5800.

;----------------------------------------------------------;
;                Configuration Values                      ;
;----------------------------------------------------------;

; ##############################################
; Common return types.
_RET_YES_D1				= 1
_RET_NO_D0				= 2
_BANK_BYTES_D8192		= 8*1024

; ##############################################
; Start times to change animations.
_HOVER_START_D250		= 250
_STAND_START_D30		= 30
_JSTAND_START_D100		= 100

; ##############################################
; Platform.
_PL_FALL_JOY_OFF_D10	= 10					; Disable the joystick for a few frames because Jetman is falling from the platform.
_PL_BUMP_JOY_D15		= 15					; Disable the joystick for a few frames because Jetman is bumping into the platform.
_PL_BUMP_JOY_DEC_D1		= 1						; With each bump into the platform, the period to turn off the joystick decrements by this value.
_PL_BUMP_Y_D4			= 4						; Amount of pixels to move Jetman down when hitting platform from below.
_PL_BUMP_X_D4			= 4
_PL_FALL_Y_D4			= 4						; Amount of pixels to move Jetman down when falling from the platform.
_PL_FALL_X_D2			= 2

; ##############################################
; Rocket
_RO_DROP_NEXT_D5		= 10	;10	TODO			; Drop next element delay
_RO_DROP_Y_MAX_D180		= 180					; Jetman has to be above the rocket to drop the element.
_RO_DROP_Y_MIN_D130		= 130					; Maximal height above ground (min y) to drop rocket element.
_RO_FLY_DELAY_D8		= 8
_RO_FLY_DELAY_DIST_D5	= 5

; ##############################################
; Screen
_SC_SYNC_SL_D192		= 192					; Sync to scanline 192, scanline on the frame (256 > Y > 192) might be skipped on 60Hz.
_SC_SHAKE_BY_D2			= 2						; Number of pixels to move the screen by shaking.

_SC_RESX_D320			= 320
_SC_RESX1_D319			= _SC_RESX_D320 - 1

_SC_RESY_D256			= 256
_SC_RESY1_D255			= _SC_RESY_D256 -1

_SC_L2_MAX_OFFSET_D191	= 191					; Max value for _DC_REG_L2_OFFSET_Y_H17.

; ##############################################
; Tilemap for in game platforms.
_TI_PIXELS_D8			= 8						; Size of a single tile in pixels.
_TI_GND_D8				= 8						; The thickness of the ground (tilemap).

_TI_VTILES_D32			= 256/8					; 256/8 = 32 rows (256 - vertical screen size).
	ASSERT _TI_VTILES_D32 =  32

_TI_EMPTY_D57			= 57					; Empty tile.
_TI_MAP_BYTES_D2560		= 40*32*2				; 2560 bytes. 320x256 = 40x32 tiles (each 8x8 pixels), each tile takes 2 bytes.
	
; ##############################################
; Game screen
_GSC_X_MIN_D0			= 0
_GSC_X_MAX_D315			= 315
_GSC_Y_MIN_D15			= 15
_GSC_Y_MAX_D232			= 232

; Ground level from Jetman's sprite perspective.
_GSC_JET_GND_D217		= _GSC_Y_MAX_D232 - _TI_GND_D8 +1

; ##############################################
; Util
_UT_PAUSE_TIME_D10		= 10

; ##############################################
; Bitmap Manipulation
_BM_16KBANK_D9			= 9						; 16K bank 9 = 8k bank 18.

_BM_XRES_D320			= 320
_BM_YRES_D256			= 256

_BM_BYTES_D81920		= _BM_XRES_D320*_BM_YRES_D256
	ASSERT _BM_BYTES_D81920 == 81920

_BM_PAL2_BYTES_D512		= 512
_BM_BANKS_D10			= 10

; ##############################################
; In game background image on Layer 2.
_GB_MOVE_ROCKET_D100	= 100					; Start moving background when the rocket reaches the given height.
_GB_MOVE_SLOW_D2		= 2						; Slows down background movement (when Jetman moves).

; ##############################################
; In game stars.
ST_L1_MOVE_DEL_D4		= 2						; Stars move delay.
ST_L2_MOVE_DEL_D4		= 8						; Stars move delay.

; ##############################################
; Binary Data Loader.

; Tiles must be stored in 16K bank 5 ($4000 and $7FFF) or 8K slot 2-3.
; ULA also uses this bank and occupies $4000 - $5AFF. So tiles start at $5AFF + 1 = $5B00.
_DB_TI_START_H5B00	= _ULA_COLOR_END_H5AFF + 1	; Start of tilemap.
	ASSERT _DB_TI_START_H5B00 >= _RAM_SLOT2_STA_H4000
	ASSERT _DB_TI_START_H5B00 <= _RAM_SLOT3_END_H7FFF

_DB_SPR_BYT_D16384		= 16384
_DBS_SP_ADDR_HC000		= _RAM_SLOT6_STA_HC000 ; RAM start address for sprites.
_DBS_RS_ADDR_HC000		= _RAM_SLOT6_STA_HC000 ; RAM start address for tilemap with stars for flying rocket.

; ##############################################
; Banks
_DBS_BGST_BANK_D18		= 18					; Background image occupies 10 8K banks from 18 to 27 (starts on 16K bank 9, uses 5 16K banks).
_DBS_BG_END_BANK_D27	= 27					; Last background bank (inclusive).
_DBS_ST_BANK_D28		= 28					; Bank for stars, slot 6
_DBS_ARR_BANK_D29		= 29					; Bank for arrays, slot 6
_DBS_TI_SPR_BANK_D30	= 30
_DBS_PAL2_BANK_D31		= 31					; Layer 2 pallettes
_DBS_PAL2_BR_BANK_D32	= 32					; Layer 2 brightness change for pallettes from _DBS_PAL2_BANK_D31.
_DBS_SPR_BANK1_D33		= 33
_DBS_SPR_BANK2_D34		= 34

; Background image (all values inclusive). Each background image has 80KiB (320x256), taking 10 banks.
_DBS_BGST_BANK_D35		= 35
_DBS_BG_EN_BANK_D44 	= _DBS_BGST_BANK_D35+_BM_BANKS_D10-1; -1 because inclusive.
	ASSERT _DBS_BG_EN_BANK_D44 == 44

_DBS_RO_STAR_BANK1_D45	= 46
_DBS_RO_STAR_BANK2_D46	= 47

; ##############################################
; Game Counters.
_GC_FLIP_ON_D1			= 1
_GC_FLIP_OFF_D0			= 0

; ##############################################
; Jetman

; Invincibility
_JM_INV_D400 			= 400					; Number of loops to keep Jetman invincible.
_JM_INV_BLINK_D100		= 100

; RIP movement.
_JM_RIP_MOVE_R_D3		= 3
_JM_RIP_MOVE_L_D3		= 3
_JM_RIP_MOVE_Y_D4		= 4

; Respawn location.
_JM_RESPAWN_X_D100		= 100
_JM_RESPAWN_Y_D217		= _GSC_JET_GND_D217		; Jetman must respond by standing on the ground. Otherwise, the background will be off.

; The Jetpack heating up / cooling down thresholds.
_JM_HEAT_RED_CNT		= 80
_JM_HEAT_CNT			= 40
_JM_COOL_CNT			= 20

; Jetman weapon
_JM_FIRE_DELAY			= 15

; ##############################################
; Enemy Formation
_EF_FORM_SIZE			= 7

; ##############################################
; Single enemy

; Each enemy has a dedicated respawn delay (EF.RESPAWN_DELAY_CNT). Enemies are renowned one after another from the enemies list. 
; An additional delay is defined here to avoid situations where multiple enemies are respawned simultaneously. It is used to delay 
; the respawn of the next enemy from the enemies list. 
_ES_NEXT_RESP_DEL		= 20