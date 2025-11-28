/*
  Copyright (c) 2025 Maciej Miklas
  Licensed under the Apache License, Version 2.0. See the LICENSE file for details.
*/
;----------------------------------------------------------;
;                      Error Reporting                     ;
;----------------------------------------------------------;
    MODULE er

errorCnt                DB 0
ERROR_MAX               = 5                     ; Limit the number of errors shown to the player

; Error Codes
ERR_001                 = $E1                   ; #SPR.REMAINING == 0
ERR_002                 = $E2                   ; File read error
ERR_003                 = $E3                   ; Sprite in #srSpriteDB not found

;----------------------------------------------------------;
;                      ReportError                         ;
;----------------------------------------------------------;
; Input:
;  - A: error code: ERR_XXX
ReportError

    ; Limit the number of errors shown to the player.
    PUSH AF
    LD A, (errorCnt)
    CP ERROR_MAX
    JR NZ, .showError
    POP AF
    RET
.showError
    INC A
    LD (errorCnt), A
    POP AF

    ; ##########################################
    ; Show error
    nextreg 2,8
    
    RET                                         ; ## END of the function ##
;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE   