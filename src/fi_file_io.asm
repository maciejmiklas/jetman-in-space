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
FILE_SIZE_D25           = 25

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
F_OPEN_H9A              = $9A
F_OPEN_B_READ_H01       = $01                   ; Access mode: read + exists
F_OPEN_B_WR_CREAT_H0A   = $0A                   ; Access mode: write + open existing or create

; Close a file or directory
; Input:
;   - A: File handle or directory handle
; Output (success):
;   - Fc: 0
;   - A:  0
; Output (failure):
;   - Fc: 1
;   - A:  Error code
F_CLOSE_H9B             = $9B

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
F_READ_H9D              = $9D

; Write bytes to file
; Input:
;   - A:  File handle.
;   - IX: address of data to write.
;   - BC: number of bytes to write.
; Output (success):
;   - Fc:  0
;   - BC:  Bytes actually written.
; Output (failure):
;   - Fc: 1
;   - BC:  Bytes actually written.
;   - A:   Error code.
F_WRITE_H9E             = $9E

F_CMD_H08               = $08

;----------------------------------------------------------;
;                       FileOpenRead                       ;
;----------------------------------------------------------;
FileOpenRead

    LD B, F_OPEN_B_READ_H01                     ; Open file.
    CALL _FileOpen
    CALL C, _IOError

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                    FileOpenReadNoCheck                   ;
;----------------------------------------------------------;
; Return:
; - CF: set if file does not exists.
FileOpenReadNoCheck

    LD B, F_OPEN_B_READ_H01                     ; Open file.
    CALL _FileOpen

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                      FileOpenWrite                       ;
;----------------------------------------------------------;
; Open a file for writing, create if it does not exist. Uses default drive '*', filename from #fileNameBuf.
; On success stores handle to #fileHandle.
FileOpenWrite

    LD B, F_OPEN_B_WR_CREAT_H0A                 ; Write + open or create
    CALL _FileOpen
    CALL C, _IOError

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                         FileWrite                        ;
;----------------------------------------------------------;
; Write BC bytes from IX into the currently opened file,
; then closes the file.
; Input:
;   - IX: address of data to write
;   - BC: number of bytes to write
FileWrite

    LD A, (fileHandle)
    RST F_CMD_H08: DB F_WRITE_H9E
    CALL C, _IOError                            ; Handle errors
    CALL _FileClose

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
    RST F_CMD_H08: DB F_READ_H9D
    CALL C, _IOError                            ; Handle errors.
    CALL _FileClose

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                       CopyFileName                       ;
;----------------------------------------------------------;
; Input:
;  - HL: pointer to file name
CopyFileName

    PUSH BC, DE

    LD BC, FILE_SIZE_D25
    LD DE, fileNameBuf
    LDIR

    POP DE, BC

    RET                                         ; ## END of the function ##
;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                        _FileOpen                         ;
;----------------------------------------------------------;
; Input:
; - B: F_OPEN_B_XXX
_FileOpen

    LD IX, fileNameBuf
    LD A, '*'                                   ; Default drive
    RST F_CMD_H08: DB F_OPEN_H9A
    LD (fileHandle), A

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        _FileClose                        ;
;----------------------------------------------------------;
_FileClose

    LD A, (fileHandle)
    RST F_CMD_H08: DB F_CLOSE_H9B

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