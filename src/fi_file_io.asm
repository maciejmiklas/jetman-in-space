/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                         File IO                          ;
;----------------------------------------------------------;
    MODULE fi

fileHandle              DEFB 0
fileNameBuf             DB "0000000000000000000000000"
FILE_SIZE               = 25

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
;   - A: File handle
; Output (failure):
;    - Fc: 0
;    - A : Error code
F_OPEN                  = $9A
F_OPEN_B_READ           = $01                   ; Access mode: read + exists

; Close a file or directory
; Input:
;   - A: File handle or directory handle
; Output (success):
;   - Fc: 0
;   - A:  0
; Output (failure):
;   - Fc: 1
;   - A:  Error code
F_CLOSE                 = $9B

; Read bytes from file
; NOTES:
; EOF is not an error, check BC to determine if all bytes requested were read
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
F_READ                  = $9D

F_CMD                   = $08


;----------------------------------------------------------;
;                         FileOpen                        ;
;----------------------------------------------------------;
FileOpen

    ; Set params for F_OPEN.
    LD IX, fileNameBuf
    LD A, '*'                                   ; Read from default drive.
    LD B, F_OPEN_B_READ                         ; Open file.
    RST F_CMD: DB F_OPEN                        ; Execute command.
    CALL C, _IOError                            ; Handle errors.

    LD (fileHandle), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      CopyFileName                       ;
;----------------------------------------------------------;
; Input:
;  - HL: pointer to file name
CopyFileName

    PUSH BC, DE

    LD BC, FILE_SIZE
    LD DE, fileNameBuf
    LDIR

    POP DE, BC

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        FileRead                          ;
;----------------------------------------------------------;
; Read bytes from a file.
; Input:
;  - IX: address to load into.
;  - BC: number of bytes to read.
FileRead

    LD A, (fileHandle)
    RST F_CMD: DB F_READ
    CALL C, _IOError                            ; Handle errors.
    CALL _FileClose

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                        _FileClose                        ;
;----------------------------------------------------------;
_FileClose

    LD A, (fileHandle)
    RST F_CMD: DB F_CLOSE

    RET                                         ; ## END of the function ##
    
;----------------------------------------------------------;
;                         _IOError                         ;
;----------------------------------------------------------;
_IOError

    LD A, er.ERR_002
    CALL er.ReportError

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE