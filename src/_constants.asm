;----------------------------------------------------------;
;                  General Registers                       ;
;----------------------------------------------------------;
REG_TURBO				EQU $07					; bit 1-0 = Turbo (00 = 3.5MHz, 01 = 7MHz, 10 = 14MHz, 11 = 28Mhz)

; bit 7-6 - Video RAM bank select (write/read paging)
; bit 5-4 - Reserved, write 0
; bit 3	- Use Shadow Layer 2 for paging - Layer 2 RAM Shadow Page Register ($13)
; bit 2	- Enable Layer 2 read-only paging
; bit 1	- Layer 2 visible - Layer 2 RAM Page Register ($12)
; bit 0	- Enable Layer 2 write-only paging
REG_LAYER2				EQU $123B

REG_SELECT				EQU $243B				; This Port is used to set the register number
REG_VL					EQU $1F					; Active video line (LSB)

;----------------------------------------------------------;
;                     ROM routines                         ;
;----------------------------------------------------------;
ROM_CLS					EQU $0DAF				; ROM address for "Clear Screen" routine
ROM_PRINT				EQU $10					; ROM address for "Print Character from A" routine

; ROM address for "Print Text" routine.
; IN:
;    - DE: RAM location containing the text
;    - BC: Size of the text
ROM_PRINT_TEXT			EQU $203C

;----------------------------------------------------------;
;                  PRINT Control Codes                     ;
;----------------------------------------------------------;
PR_INK					EQU $10
PR_PAPER				EQU $11
PR_FLASH				EQU $12
PR_BRIGHT				EQU $13
PR_INVERSE				EQU $14
PR_OVER					EQU $15
PR_AT					EQU $16
PR_TAB					EQU $17
PR_CR					EQU $0C
PR_ENTER				EQU $0D

;----------------------------------------------------------;
;                          MMU                             ;
;----------------------------------------------------------;
MMU_SLOT_0 				EQU $50
MMU_SLOT_1 				EQU $51
MMU_SLOT_2 				EQU $52
MMU_SLOT_3 				EQU $53
MMU_SLOT_4 				EQU $54
MMU_SLOT_5 				EQU $55
MMU_SLOT_6 				EQU $56
MMU_SLOT_7 				EQU $57	


;----------------------------------------------------------;
;          		         Sprites	   	                   ;
;----------------------------------------------------------;
SPR_NR					EQU $34					; Sprite Number (R/W)
SPR_X					EQU $35					; Sprite X coordinate
SPR_Y					EQU $36					; Sprite Y coordinate

; bits 7-4 = Palette offset added to top 4 bits of sprite colour index
; bit 3 = X mirror
; bit 2 = Y mirror
; bit 1 = Rotate
; bit 0 = MSB of X coordinate (palette offset indicator for relative sprites)
SPR_ATTR_2				EQU $37

; bit 7 = Visible flag (1 = displayed)
; bit 6 = Extended attribute (1 = Sprite Attribute 4 is active)
; bits 5-0 = Pattern used by sprite (0-63)
SPR_ATTR_3				EQU $38

; bit 7 = H (1 = sprite uses 4-bit patterns)
; bit 6 = N6 (0 = use the first 128 bytes of the pattern else use the last 128 bytes)
; bit 5 = 1 if relative sprites are composite, 0 if relative sprites are unified Scaling
; bits 4-3 = X scaling (00 = 1x, 01 = 2x, 10 = 4x, 11 = 8x)
; bits 2-1 = Y scaling (00 = 1x, 01 = 2x, 10 = 4x, 11 = 8x)
; bit 0 = MSB of Y coordinate
SPR_ATTR_4				EQU $39

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
SPR_SETUP				EQU $15
SPR_PORT				EQU $303B

;----------------------------------------------------------;
;                           DMA                            ;
;----------------------------------------------------------;
DMA_PORT				EQU $6B					; Datagear DMA Port in zxnDMA mode, https://wiki.specnext.dev/DMA

;----------------------------------------------------------;
;                   Charactes Codes                        ;
;----------------------------------------------------------;
CH_ENTER				EQU $0D					; Character code for Enter key


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
KB_6_TO_0				EQU $EF					; Mask for keyboard input from 6 to 0 (to read arrow keys: up/down/right)
KB_5_TO_1				EQU $F7					; Mask for keyboard input from 5 to 1 (to read left arrow key)
KB_V_TO_Z				EQU $FE					; Mask for keyboard input from V to Z to read X for fire

KB_REG					EQU $FE 				; Activated keyboard input

JOY_MASK				EQU $20 				; Mask to read Kempston input
JOY_REG					EQU $1F					; Activates Kempston input

;----------------------------------------------------------;
;                         Display                          ;
;----------------------------------------------------------;
DI_SYNC_SL				EQU 192					; Scanline to synch to. 192 for 60FPS, value above/below changes pause time
DI_COL_ST				EQU $5800				; Start of Display Color RAM
DI_COL_EN				EQU $5AFF				; End of Display Color RAM
DI_COL_SIZE				EQU 768					; Size of color RAM: $5AFF - $5800