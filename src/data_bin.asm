;-------------------------------------------------------------------------------------;
; Load sprites into MMU Slot 40,41 (16KB) mapping it to Bank: 6 and 7                 ;
;-------------------------------------------------------------------------------------;
	MMU 6 7, 40
	ORG RAM_SLOT_6_START
spritesFile INCBIN "assets/sprites.spr"

;----------------------------------------------------------;
;                 Load Tiles into Slot 5                   ;
;----------------------------------------------------------;
tilemap:
	INCBIN "assets/tiles.spr"
	tilemapLength = $-tilemap

OFFSET_OF_TILES = (START_OF_TILES - START_OF_BANK_5) >> 8
	NEXTREG $6F, OFFSET_OF_TILES ; MSB of tilemap definitions	