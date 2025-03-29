;----------------------------------------------------------;
;                         File IO                          ;
;----------------------------------------------------------;
	MODULE fi

fileHandle				defb 0

_
; Open a file.
; Input:
;   - A:  Drive specifier ('*'=default, '$'=system) (overridden if filespec includes a drive).
;   - IX: [HL from dot command]=filespec, null-terminated.
;   - B:  Access modes, a combination of:
;      any/all of:
;        - esx_mode_read $01 request read access.
;        - esx_mode_write $02 request write access.
;        - esx_mode_use_header $40 read/write +3DOS header.
;      plus one of:
;        - esx_mode_open_exist $00 only open existing file.
;        - esx_mode_open_creat $08 open existing or create file.
;        - esx_mode_creat_noexist $04 create new file, error if exists.
;        - esx_mode_creat_trunc $0c create new file, delete existing.
;   - DE: 8-byte buffer with/for +3DOS header data (if specified in mode). NB: filetype will be set to $ff if headerless file was opened.
; Output (success):
;   - Fc: 0
;   - A: File handle.
; Output (failure):
;    - Fc: 0
;    - A : Error code.
F_OPEN					= $9A
F_OPEN_B_READ			= $01					; Access mode: read + exists

; Close a file or directory.
; Input:
;   - A: File handle or directory handle.
; Output (success):
;   - Fc: 0
;   - A:  0
; Output (failure):
;   - Fc: 1
;   - A:  Error code.
F_CLOSE					= $9B

; Read bytes from file.
; NOTES:
; EOF is not an error, check BC to determine if all bytes requested were read.
; Input:
;   - A:  File handle.
;   - IX: [HL from dot command]=address.
;   - BC  Bytes to read.
; Output (success):
;   - Fc:  0
;   - BC:  Bytes actually read (also in DE).
;   - HL:  Address following bytes read.
; Output (failure):
;   - Fc: 1
;   - BC: Bytes actually read.
;   - A:  Error code.
F_READ					= $9D

F_CMD					= $08
ASCII_O					= $30

;----------------------------------------------------------;
;                      #LoadTilemap                        ;
;----------------------------------------------------------;
; Input:
;  - IX: File name.
LoadTilemap

	; Open file.
	CALL _FileOpen

	; Read file.
	LD IX, _TI_START_H5B00
	LD BC, _TI_MAP_BYTES_D2560
	CALL _FileRead

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       #LoadImage                         ;
;----------------------------------------------------------;
; BMP 320x256 with 8bit palette (Gimp -> Image -> Mode -> Indexed)
; ./gfx2next -bitmap -preview -bitmap-y -pal-min .\l01_background.bmp
; Input:
;  - IX: File name.
;  - C: Position of the bank number is in the image's file name.
LoadImage

	; Iterate over banks, loading one after another, form 0 to 9 inclusive.
	LD B, 0 
.bankLoop
	PUSH IX, BC

	; ##########################################
	; Set the image part in the file name, for B=3  "...bg_0.nxi" -> "...bg_3.nxi".
	LD HL, IX
	LD A, C
	ADD HL, A									; Move HL to "...l00/bg_"
	LD A, ASCII_O								; Map B to ASCII value 0 to 9
	ADD B
	LD (HL), A

	; ##########################################
	; Load file into RAM
	LD A, _DB_BG_ST_BANK_D35					; Set bank number.
	ADD B
	NEXTREG _MMU_REG_SLOT6_H56, A

	; Open file.
	CALL _FileOpen

	; Read file.
	LD IX, _RAM_SLOT6_START_HC000
	LD BC, _BANK_BYTES_D8192
	CALL _FileRead

	; ##########################################
	; Loop up to B == 9
	POP BC, IX
	INC B
	LD A, B
	CP _BM_BANKS_D10
	JR NZ, .bankLoop

	RET											; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                      #_FileRead                          ;
;----------------------------------------------------------;
; Read bytes from a file.
; Input:
;  - A:  File handle.
;  - IX: Address to load into.
;  - BC: Number of bytes to read.
_FileRead

	RST F_CMD: DB F_READ
	CALL C, _IOError							; Handle errors.
	CALL _FileClose
	RET											; ## END of the function ##

;----------------------------------------------------------;
;                        #_FileOpen                        ;
;----------------------------------------------------------;
_FileOpen

	; Set params for F_OPEN
	LD A, '*'									; Read from default drive.
	LD B, F_OPEN_B_READ							; Open file.
	RST F_CMD: DB F_OPEN						; Execute command.
	CALL C, _IOError							; Handle errors.

	LD (fileHandle), A

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       #_FileClose                        ;
;----------------------------------------------------------;
_FileClose
	LD A, (fileHandle)
	RST F_CMD: DB F_CLOSE

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                         #_IOError                         ;
;----------------------------------------------------------;
_IOError
	nextreg 2,8

	RET											; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE