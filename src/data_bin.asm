;----------------------------------------------------------;
;                        Globals                           ;
;----------------------------------------------------------;
SPR_BANK1_40		EQU 40					; Sprites for Level 1 are on bank 40, 41
SPR_BANK2_41		EQU 41	


;-------------------------------------------------------------------------------------;
;             Load tilemap into bank 42 mapping it to Slot: 6,7                       ;
;-------------------------------------------------------------------------------------;

; Tilemap settings: 8px, 40x32,2 bytes pre pixel, disable "include header" when downloading, file is then usabe as is.
tilemapBin INCBIN "assets/tiles.map"
tilemapBinLength: EQU $ - tilemapBin

; Sprite editor settings: 4bit, 8x8. After downloading manually removed empty data!.
tilesBin INCBIN "assets/tiles.spr"
tilesBinLength: EQU $ - tilesBin

tilePaletteBin:						; RGB332
	db $e3, $0, $2, $13, $17, $37, $5b, $1f, $8, $9, $a, $b, $c, $d, $e, $f
	db $e3, $21, $21, $20, $20, $12, $16, $17, $d, $e, $1a, $1b, $1c, $1d, $1e, $1f
tilePaletteBinLength: EQU $ - tilePaletteBin

;-------------------------------------------------------------------------------------;
;           Load sprites (16KB) into bank 40,41 mapping it to Slot: 6,7               ;
;-------------------------------------------------------------------------------------;
	MMU 6 7, SPR_BANK1_40
	ORG RAM_SLOT_6_START_HC000
spritesBin INCBIN "assets/sprites.spr"
spritesBinLength: EQU $ - spritesBin