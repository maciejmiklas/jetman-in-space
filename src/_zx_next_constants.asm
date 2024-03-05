;----------------------------------------------------------;
;                  General Registers                       ;
;----------------------------------------------------------;
GL_REG_TURBO_H07		EQU $07				; bit 1-0 = Turbo (00 = 3.5MHz, 01 = 7MHz, 10 = 14MHz, 11 = 28Mhz)
GL_REG_SELECT_H243B		EQU $243B			; This Port is used to set the register number
GL_REG_VL_H1F			EQU $1F				; Active video line (LSB)

;----------------------------------------------------------;
;                   Display Control                        ;
;----------------------------------------------------------;

; bit 7: 1 to enable Layer 2 (alias for bit 1 in Layer 2 Access Port $123B)
; bit 6: 1 to enable ULA shadow display (alias for bit 3 in Memory Paging Control $7FFD)
; bit 5-0: Alias for bits 5-0 in Timex Sinclair Video Mode Control $xxFF
DC_REG_CONTROL_1_H69	EQU $69

; bit 7-6: Reserved, must be 0
; bit 5-4: Layer 2 resolution (0 after soft reset)
;			- '00': 256x192, 8BPP
;			- '01': 320x256, 8BPP
;			- '10': 640x256, 4BPP
; bit 3-0: Palette offset (0 after soft reset)
DC_REG_LAYER_2_H70		EQU $70

; bit 7-1: 7-1 Reserved, must be 0
; bit 0: MSB for X pixel offset
DC_REG_LAYER_2_OFFS_H71	EQU $71
;----------------------------------------------------------;
;                     ROM routines                         ;
;----------------------------------------------------------;
ROM_CLS_H0DAF			EQU $0DAF				; ROM address for "Clear Screen" routine
ROM_PRINT_H10			EQU $10					; ROM address for "Print Character from A" routine

; ROM address for "Print Text" routine.
; IN:
;    - DE: RAM location containing the text
;    - BC: Size of the text
ROM_PRINT_TEXT_H203C	EQU $203C

;----------------------------------------------------------;
;                  PRINT Control Codes                     ;
;----------------------------------------------------------;
PR_INK_H10				EQU $10
PR_PAPER_H11			EQU $11
PR_FLASH_H12			EQU $12
PR_BRIGHT_H13			EQU $13
PR_INVERSE_H14			EQU $14
PR_OVER_H15				EQU $15
PR_AT_H16				EQU $16
PR_TAB_H17				EQU $17
PR_CR_H0C				EQU $0C
PR_ENTER_H0D			EQU $0D

;----------------------------------------------------------;
;                     RAM 8K Slots                         ;
;----------------------------------------------------------;
RAM_SLOT_0_START_H0000	EQU $0000
RAM_SLOT_0_END_H1FFF	EQU $1FFF

RAM_SLOT_1_START_H2000	EQU $2000
RAM_SLOT_1_END_H3FFF	EQU $3FFF

RAM_SLOT_2_START_H4000	EQU $4000
RAM_SLOT_2_END_H5FFF	EQU $5FFF

RAM_SLOT_3_START_H6000	EQU $6000
RAM_SLOT_3_END_H7FFF	EQU $7FFF

RAM_SLOT_4_START_H8000	EQU $8000
RAM_SLOT_4_END_H9FFF	EQU $9FFF

RAM_SLOT_5_START_HA000	EQU $A000
RAM_SLOT_5_END_HBFFF	EQU $BFFF

RAM_SLOT_6_START_HC000	EQU $C000
RAM_SLOT_6_END_HDFFF	EQU $DFFF

RAM_SLOT_7_START_HE000	EQU $E000
RAM_SLOT_7_END_HFFFF	EQU $FFFF

;----------------------------------------------------------;
;                          MMU                             ;
;----------------------------------------------------------;
MMU_REG_SLOT_0_H50 		EQU $50
MMU_REG_SLOT_1_H51 		EQU $51
MMU_REG_SLOT_2_H52 		EQU $52
MMU_REG_SLOT_3_H53 		EQU $53
MMU_REG_SLOT_4_H54 		EQU $54
MMU_REG_SLOT_5_H55 		EQU $55
MMU_REG_SLOT_6_H56 		EQU $56
MMU_REG_SLOT_7_H57 		EQU $57	

;----------------------------------------------------------;
;          		         Sprites	   	                   ;
;----------------------------------------------------------;
SPR_REG_NR_H34			EQU $34					; Sprite Number (R/W)
SPR_REG_X_H35			EQU $35					; Sprite X coordinate
SPR_REG_Y_H36			EQU $36					; Sprite Y coordinate

; bits 7-4 = Palette offset added to top 4 bits of sprite colour index
; bit 3 = X mirror
; bit 2 = Y mirror
; bit 1 = Rotate
; bit 0 = MSB of X coordinate (palette offset indicator for relative sprites)
SPR_REG_ATTR_2_H37		EQU $37

; bit 7 = Visible flag (1 = displayed)
; bit 6 = Extended attribute (1 = Sprite Attribute 4 is active)
; bits 5-0 = Pattern used by sprite (0-63)
SPR_REG_ATTR_3_H38		EQU $38

; bit 7 = H (1 = sprite uses 4-bit patterns)
; bit 6 = N6 (0 = use the first 128 bytes of the pattern else use the last 128 bytes)
; bit 5 = 1 if relative sprites are composite, 0 if relative sprites are unified Scaling
; bits 4-3 = X scaling (00 = 1x, 01 = 2x, 10 = 4x, 11 = 8x)
; bits 2-1 = Y scaling (00 = 1x, 01 = 2x, 10 = 4x, 11 = 8x)
; bit 0 = MSB of Y coordinate
SPR_REG_ATTR_4_H39		EQU $39

; Sprite and Layers system
; bit 7 = LoRes mode, 128 x 96 x 256 colours (1 = enabled)
; bit 6 = Sprite priority (1 = sprite 0 on top, 0 = sprite 127 on top)
; bit 5 = Enable sprite clipping in over border mode (1 = enabled)
; bits 4-2 = set layers priorities:
; Reset default is 000, sprites over the Layer 2, over the ULA graphics
; 000 - S L U
; 001 - L S U
; 010 - S U L - (Top - Sprites, Enhanced_ULA, Layer 2)
; 011 - L U S
; 100 - U S L
; 101 - U L S
; 110 - S(U+L) ULA and Layer 2 combined, colours clamped to 7
; 111 - S(U+L-5) ULA and Layer 2 combined, colours clamped to [0,7]
; bit 1 = Over border (1 = yes)(Back to 0 after a reset)
; bit 0 = Sprites visible (1 = visible)(Back to 0 after a reset)
SPR_REG_SETUP_H15		EQU $15
SPR_PORT_H303B			EQU $303B

;----------------------------------------------------------;
;                         DMA                              ;
;----------------------------------------------------------;
DMA_PORT_H6B			EQU $6B					; Datagear DMA Port in zxnDMA mode, https://wiki.specnext.dev/DMA

;----------------------------------------------------------;
;                        Colors                            ;
;----------------------------------------------------------;
BORDER_IO				EQU $FE					
COL_BLACK				EQU 0
COL_BLUE				EQU 1
COL_RED					EQU 2
COL_MAGENTA				EQU 3
COL_GREEN				EQU 4
COL_CYAN				EQU 5
COL_YELLOW				EQU 6
COL_WHITE				EQU 7

;----------------------------------------------------------;
;                     Input processing                     ;
;----------------------------------------------------------;
KB_6_TO_0_HEF			EQU $EF					; Mask for keyboard input from 6 to 0 (to read arrow keys: up/down/right)
KB_5_TO_1_HF7			EQU $F7					; Mask for keyboard input from 5 to 1 (to read left arrow key)
KB_V_TO_Z_HFE			EQU $FE					; Mask for keyboard input from V to Z to read X for fire

KB_REG_HFE				EQU $FE 				; Activated keyboard input

JOY_MASK_H20			EQU $20 				; Mask to read Kempston input
JOY_REG_H1F				EQU $1F					; Activates Kempston input

;----------------------------------------------------------;
;                         Display                          ;
;----------------------------------------------------------;
DI_SYNC_SL				EQU 192					; Scanline to synch to. 192 for 60FPS, value above/below changes pause time
DI_COLOR_START_H5800	EQU $5800				; Start of Display Color RAM
DI_COLOR_ENND_H5AFF		EQU $5AFF				; End of Display Color RAM
DI_COL_SIZE				EQU 768					; Size of color RAM: $5AFF - $5800