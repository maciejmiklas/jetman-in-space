;----------------------------------------------------------;
;                     Global Constants                     ;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                  General Registers                       ;
;----------------------------------------------------------;
_GL_REG_TURBO_H07		= 11				; Bit 1-0 = Turbo (00 = 3.5MHz, 01 = 7MHz, 10 = 14MHz, 11 = 28Mhz)

_GL_REG_TRANP_COL_H14	 = $14				; Global transparency color
_GL_REG_SELECT_H243B	= $243B				; This Port is used to set the register number
_GL_REG_VL_H1F			= $1F				; Active video line (LSB)

;----------------------------------------------------------;
;                   Display Control                        ;
;----------------------------------------------------------;

; Layer 2 RAM bank
_DC_REG_L2_BANK_H12		= $12

; Layer2 Offset X
_DC_REG_L2_OFFSET_X_H16	= $16

; Layer2 Offset Y
_DC_REG_L2_OFFSET_Y_H17	= $17

; Tilemap Offset X MSB
; Bits:
;  - 7-2 = Reserved, must be 0
;  - 1-0 = MSB X Offset
_DC_REG_TILE_X_MSB_H2f	= $2F

; Tilemap Offset X LSB
; Bits:
;  - 7-0 = LSB X Offset
_DC_REG_TILE_X_LSB_H30	= $30

; Tilemap Offset Y
_DC_REG_TILE_Y_H31		= $31

; ULA / LoRes Offset X
_DC_REG_ULA_X_H32		= $32

; ULA / LoRes Offset Y
_DC_REG_ULA_Y_H33		= $33

; Bits:
;  - 7: 1 to enable Layer 2 (alias for bit 1 in Layer 2 Access Port $123B)
;  - 6: 1 to enable ULA shadow display (alias for bit 3 in Memory Paging Control $7FFD)
;  - 5-0: Alias for bits 5-0 in Timex Sinclair Video Mode Control $xxFF
_DC_REG_CONTROL1_H69	= $69

; Bits:
;  - 7-6: Reserved, must be 0
;  - 5-4: Layer 2 resolution (0 after soft reset)
;			- '00': 256x192, 8BPP
;			- '01': 320x256, 8BPP
;			- '10': 640x256, 4BPP
;  - 3-0: Palette offset (0 after soft reset)
_DC_REG_LA2_H70			= $70

; Palette index
_DC_REG_LA2_PAL_IDX_H40	= $40

; Palette Value (8 bit colour)
; bits 7-0 = Colour for the palette index selected by the register 0x40.
; (Format is RRRGGGBB - the lower blue bit of the 9-bit colour will be a logical or of blue bits 1 and 0 of this 8-bit value.)
; After the write, the palette index is auto-incremented to the next index if the auto-increment is enabled at reg 0x43
_DC_REG_LA2_PAL_VAL_H41	= $41

; Palette Control
; Bits:
;  - 7: '1' to disable palette write auto-increment
;  - 6-4: Select palette for reading or writing:
;     000 = ULA first palette
;     100 = ULA second palette
;     001 = Layer 2 first palette
;     101 = Layer 2 second palette
;     010 = Sprites first palette
;     110 = Sprites second palette
;     011 = Tilemap first palette
;     111 = Tilemap second palette
;  - 3: Select Sprites palette (0 = first palette, 1 = second palette)
;  - 2 Select Layer 2 palette (0 = first palette, 1 = second palette)
;  - 1: Select ULA palette (0 = first palette, 1 = second palette)
;  - 0: Enabe ULANext mode if 1. (0 after a reset)
_DC_REG_LA2_PAL_CTR_H43	= $43

; Palette Value (9 bit colour)
; Two consecutive writes are needed to write the 9 bit colour
; 1st write: bits 7-0 = RRRGGGBB
; 2nd write:
;    If writing a L2 palette:
;      Bits:
;       - 7: 1 for L2 priority colour, 0 for normal
;            Priority colour will always be on top even on an SLU priority arrangement. If you need the exact same colour on priority and non 
;            priority locations you will need to program the same colour twice changing bit 7 to 0 for the second colour
;       - 6-1: Reserved, must be 0
;       - 0: LSB B
;   If writing another palette:
;     Bits:
;      - 7-1: Reserved, must be 0
;      - 0:  LSB B
; After the two consecutives writes the palette index is auto-incremented if the auto-increment is enabled by reg 0x43.
_DC_REG_LA2_PAL_VAL_H44	= $44

; Transparency index for the tilemap
; Bits:
;  - 7-4 = Reserved, must be 0
;  - 3-0 = Set the index value (0xF after reset)
_DC_REG_TILE_TRANSP_H4C = $4C

; Bits:
;  -  7-1: 7-1 Reserved, must be 0
;  -  0: MSB for X pixel offset
_DC_REG_LA2_OFFS_H71	= $71

;----------------------------------------------------------;
;                     ROM routines                         ;
;----------------------------------------------------------;
_ROM_PRINT_H10			= $10					; ROM address for "Print Character from A" routine

; ROM address for "Print Text" routine
; Input:
;    - DE: RAM location containing the text
;    - BC: Size of the text
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
_RAM_SLOT0_START_H0000	= $0000
_RAM_SLOT0_END_H1FFF	= $1FFF

_RAM_SLOT1_START_H2000	= $2000
_RAM_SLOT1_END_H3FFF	= $3FFF

_RAM_SLOT2_START_H4000	= $4000
_RAM_SLOT2_END_H5FFF	= $5FFF

_RAM_SLOT3_START_H6000	= $6000
_RAM_SLOT3_END_H7FFF	= $7FFF

_RAM_SLOT4_START_H8000	= $8000
_RAM_SLOT4_END_H9FFF	= $9FFF

_RAM_SLOT5_START_HA000	= $A000
_RAM_SLOT5_END_HBFFF	= $BFFF

_RAM_SLOT6_START_HC000	= $C000
_RAM_SLOT6_END_HDFFF	= $DFFF

_RAM_SLOT7_START_HE000	= $E000
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
_SPR_REG_NR_H34			= $34					; Sprite Number (R/W)
_SPR_REG_X_H35			= $35					; Sprite X coordinate
_SPR_REG_Y_H36			= $36					; Sprite Y coordinate

; Bits:
;  - 7-4: Palette offset added to top 4 bits of sprite colour index
;  - 3: X mirror
;  - 2: Y mirror
;  - 1: Rotate
;  - 0: MSB of X coordinate (palette offset indicator for relative sprites)
_SPR_REG_ATR2_H37		= $37
_SPR_REG_ATR2_MIRX_BIT	= 3
_SPR_REG_ATR2_MIRY_BIT	= 2
_SPR_REG_ATR2_ROT_BIT	= 1
_SPR_REG_ATR2_OVER_BIT	= 0
_SPR_REG_ATR2_RES_PAL	= %00001111				; Mask to reset palette bits
_SPR_REG_ATR2_OVEFLOW	= %00000001
_SPR_REG_ATR2_EMPTY		= %00000000				; No rotation, no mirrot, no overflow

; Bits:
;  - 7: Visible flag (1 = displayed)
;  - 6: Extended attribute (1 = Sprite Attribute 4 is active)
;  - 5-0: Pattern used by sprite (0-63)
_SPR_REG_ATR3_H38		= $38

; Bits:
;  - 7: H (1 = sprite uses 4-bit patterns)
;  - 6: N6 (0 = use the first 128 bytes of the pattern else use the last 128 bytes)
;  - 5: 1 if relative sprites are composite, 0 if relative sprites are unified Scaling
;  - 4-3: X scaling (00 = 1x, 01 = 2x, 10 = 4x, 11 = 8x)
;  - 2-1: Y scaling (00 = 1x, 01 = 2x, 10 = 4x, 11 = 8x)
;  - 0: MSB of Y coordinate
_SPR_REG_ATR4_H39		= $39

; Sprite and Layers system
; Bits:
;  - 7: LoRes mode, 128 x 96 x 256 colours (1 = enabled)
;  - 6: Sprite priority (1 = sprite 0 on top, 0 = sprite 127 on top)
;  - 5: Enable sprite clipping in over border mode (1 = enabled)
;  - 4-2: set layers priorities:
;   Reset default is 000, sprites over the Layer 2, over the ULA graphics:
;    - 000: S L U
;    - 001: L S U
;    - 010: S U L - (Top - Sprites, Enhanced_ULA, Layer 2)
;    - 011: L U S
;    - 100: U S L
;    - 101: U L S
;    - 110: S(U+L) ULA and Layer 2 combined, colors clamped to 7
;    - 111: S(U+L-5) ULA and Layer 2 combined, colors clamped to [0,7]
;  - 1: Over border (1 = yes)(Back to 0 after a reset)
;  - 0: Sprites visible (1 = visible)(Back to 0 after a reset)
_SPR_REG_SETUP_H15		= $15

_SPR_PORT_H303B			= $303B

; bit 7 = Visible flag (1 = displayed)
; bits 5-0 = Pattern used by sprite (0-63)
_SPR_PATTERN_SHOW		= %10000000
_SPR_PATTERN_HIDE		= %00000000

;----------------------------------------------------------;
;          		         Tiles  	   	                   ;
;----------------------------------------------------------;

; Tilemap Control
; Bits:
;  - 7: 1 to enable the tilemap
;  - 6: 0 for 40x32, 1 for 80x32
;  - 5: 1 to eliminate the attribute entry in the tilemap
;  - 4: palette select
;  - 3-2: Reserved set to 0
;  - 1: 1 to activate 512 tile mode
;  - 0: 1 to force tilemap on top of ULA
_TILE_MAP_CONTROL_H6B	= $6B

; Tilemap Attribute
; Bits:
;  - bits 7-4: Palette Offset
;  - bit 3: X mirror
;  - bit 2: Y mirror
;  - bit 1: Rotate
;  - bit 0: ULA over tilemap. (bit 8 of the tile number if 512 tile mode is enabled). Active tile attribute if bit 5 of NEXTREG 0x6B is set.
_TILE_ATTRIBTE_H6C		= $6C

; Tilemap Base Address
; The value written is an offset into Bank 5 allowing the tilemap to be placed at any multiple of 256 bytes.
; Writing a physical MSB address in 0x40-0x7F or 0xC0-0xFF range is permitted.
; The value read back should be treated as having a fully significant 8-bit value.
;
; bits 7-6: Read back as zero, write values ignored
; bits 5-0: MSB of the address of the tilemap in Bank 5 ($A000 - $BFFF)
_TILE_MAP_ADDRESR_H6E	= $6E

; Tile Definitions Base Address
; The value written is an offset into Bank 5 allowing tile definitions to be placed at any multiple of 256 bytes.
; Writing a physical MSB address in 0x40-0x7F or 0xC0-0xFF range is permitted. 
; The value read back should be treated as having a fully significant 8-bit value.
; Bits:
;  - 7-6: Read back as zero, write values ignored
;  - 5-0: MSB of the address of tile definitions in Bank 5
_TILE_ADDRESR_H6F		= $6F

; Tilemap Offset X MSB
; bits 7-2 = Reserved, must be 0
; bits 1-0 = MSB X Offset
; Meaningful Range is 0-319 in 40 char mode, 0-639 in 80 char mode
_TILE_OFFSET_X_MSB_H2F 	= $2F

; Tilemap Offset X LSB
; Meaningful range is 0-319 in 40 char mode, 0-639 in 80 char mode
_TILE_OFFSET_X_LSB_H30	= $30

; Tilemap Offset Y
_TILE_OFFSET_Y_H31		= $31

;----------------------------------------------------------;
;                         DMA                              ;
;----------------------------------------------------------;
_DMA_PORT_H6B			= $6B					; Datagear DMA Port in zxnDMA mode, https://wiki.specnext.dev/DMA

;----------------------------------------------------------;
;                        Colors                            ;
;----------------------------------------------------------;
_BORDER_IO_HFE			= $FE
_COL_BLACK				= 0
_COL_BLUE				= 1
_COL_RED				= 2
_COL_MAGENTA			= 3
_COL_GREEN				= 4
_COL_CYAN				= 5
_COL_YELLOW				= 6
_COL_WHITE				= 7

;----------------------------------------------------------;
;                     Input processing                     ;
;----------------------------------------------------------;
_KB_6_TO_0_HEF			= $EF					; Mask for keyboard input from 6 to 0 (to read arrow keys: up/down/right)
_KB_5_TO_1_HF7			= $F7					; Mask for keyboard input from 5 to 1 (to read left arrow key)
_KB_V_TO_Z_HFE			= $FE					; Mask for keyboard input from V to Z to read X for fire

_KB_REG_HFE				= $FE					; Activated keyboard input

_JOY_MASK_H20			= $20					; Mask to read Kempston input
_JOY_REG_H1F			= $1F					; Activates Kempston input

;----------------------------------------------------------;
;                         Display                          ;
;----------------------------------------------------------;
_DI_COLOR_START_H5800	= $5800					; Start of Display Color RAM
_DI_COLOR_ENND_H5AFF	= $5AFF					; End of Display Color RAM
_DI_COL_SIZE			= 768					; Size of color RAM: $5AFF - $5800