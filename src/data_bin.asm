;----------------------------------------------------------;
;                        Globals                           ;
;----------------------------------------------------------;
BANK40_SPR1				= 40				; Sprites for Level 1 are on bank 40, 41
BANK41_SPR2				= 41
BANK42_PALETTE			= 42

;-------------------------------------------------------------------------------------;
;             Load tilemap into bank 42 mapping it to Slot: 6                         ;
;-------------------------------------------------------------------------------------;
	MMU 6, BANK42_PALETTE
	ORG RAM_SLOT_6_START_HC000

; Tilemap settings: 8px, 40x32 (2 bytes pre pixel), disable "include header" when downloading, file is then usabe as is.
tilemapBin INCBIN "assets/tiles.map"
tilemapBinLength: = $ - tilemapBin

; Sprite editor settings: 4bit, 8x8. After downloading manually removed empty data!.
tilesBin INCBIN "assets/tiles.spr"
tilesBinLength: = $ - tilesBin

tilePaletteBin:									; RGB332

/* Values for Remy's editor
  $1C7    $0    $5   $27   $2F   $6F   $B7  $13F   $10   $13   $15   $17   $18   $1B   $1D   $1F
  $1C7   $43   $42   $41   $40   $25   $2D   $2F   $1B   $1D   $35   $37   $38   $3B   $3D   $3F
*/
	DB $E3, $E0, $2, $13, $17, $37, $5B, $1F, $8, $9, $A, $B, $C, $D, $E, $F
	DB $E3, $21, $21, $20, $20, $12, $16, $17, $D, $E, $1A, $1B, $1C, $1D, $1E, $1F

tilePaletteBinLength: = $ - tilePaletteBin

;-------------------------------------------------------------------------------------;
;           Load sprites (16KB) into bank 40,41 mapping it to Slot: 6,7               ;
;-------------------------------------------------------------------------------------;
	MMU 6 7, BANK40_SPR1
	ORG RAM_SLOT_6_START_HC000
spritesBin INCBIN "assets/sprites.spr"
spritesBinLength: = $ - spritesBin