;----------------------------------------------------------;
;              Bitmap on Layer 2 at 320x256                ;
;----------------------------------------------------------;
; The image on Layer Two has a resolution of 320x256 and occupies 81920 bytes (80KiB) in 10 banks.
; The pixel orientation is from top to bottom, left to right. 
; Each bank has 8KiB = 8192 bytes and can hold 32 horizontal lines. 10 banks hold 320 lines.

    MODULE bm

imageBank               BYTE 0                  ; Bank containing the image.

BM_16KBANK_D9           = 9                     ; 16K bank 9 = 8k bank 18.

;----------------------------------------------------------;
;                    #CopyImageData                        ;
;----------------------------------------------------------;
; Copies image data from temp RAM into screen memory. Copies data from slot 6 to 7. Slot 6 points to the bank containing the source of the 
; image, and slot 7 points to the bank that contains display data (NEXTREG _DC_REG_L2_BANK_H12).
CopyImageData

    ; We will copy 10x full bank, from slot 6 to slot 7.
    LD DE, _BANK_BYTES_D8192 : LD (ut.dmaTransferSize), DE
    LD DE, _RAM_SLOT6_STA_HC000 : LD (ut.dmaPortAAddress), DE
    LD DE, _RAM_SLOT7_STA_HE000 : LD (ut.dmaPortBAddress), DE

    LD D, dbs.BMA_ST_BANK_S6_D35                ; Start bank containing background image source.
    LD E, dbs.BMB_ST_BANK_S7_D18                ; Destination bank where layer 2 image is expected. See "NEXTREG _DC_REG_L2_BANK_H12 ....".

    NEXTREG _DC_REG_L2_BANK_H12, BM_16KBANK_D9 ; Layer 2 image (background) starts at 16k-bank 9 (default).

    LD B, dbs.BM_BANKS_D10                      ; Amount of banks occupied by the image. 320x256 has 10, 256x192 has 6, 256x128 has 4.
.bankLoop                                       ; Each loop copies single bank, there are 10 iterations.
    PUSH BC

    ; ##########################################
    ; Assign banks to slots.
    LD A, D
    NEXTREG _MMU_REG_SLOT6_H56, A               ; Read from.

    LD A, E
    NEXTREG _MMU_REG_SLOT7_H57, A               ; Write to.

    ; ##########################################
    ; Copy using DMA.
    CALL ut.CopyRam

    ; ##########################################
    ; Next iteration.
    INC D                                       ; Next source bank.
    INC E                                       ; Next destination bank.
    POP BC
    DJNZ .bankLoop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                  #CreateEmptyImageBank                   ;
;----------------------------------------------------------;
; Copies 10x bank with black color over displayed image.
CreateEmptyImageBank

    CALL dbs.SetupEmptyImageBank

    ; Fill this bank with 0 black color
    LD HL, _RAM_SLOT6_STA_HC000                 ; Start of the RAM area to fill (adjust as needed)
    LD DE, _RAM_SLOT6_STA_HC000 + _BANK_BYTES_D8192 ; End of the RAM area (start + 8192 bytes)
    
.fillLoop:
    XOR A                                       ; _COL_BLACK_D0 is 0 and XOR is faster.
    LD (HL), A                                  ; Store 0 at the current address
    INC HL                                      ; Move to the next address

    LD A, H                                     ; Check if HL reached DE
    CP E
    JR NZ, .fillLoop
    LD A, L
    CP D
    JR NZ, .fillLoop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                        #HideImage                        ;
;----------------------------------------------------------;
; Copies 10x bank with black color over displayed image.
HideImage

    CALL dbs.SetupEmptyImageBank

    ; We will copy 10x full bank, from slot 6 to slot 7.
    LD DE, _BANK_BYTES_D8192 : LD (ut.dmaTransferSize), DE
    LD DE, _RAM_SLOT6_STA_HC000 : LD (ut.dmaPortAAddress), DE
    LD DE, _RAM_SLOT7_STA_HE000 : LD (ut.dmaPortBAddress), DE
    
    LD D, dbs.EMPTY_IMG_S6_D48                  ; Bank containing just black color.
    LD E, dbs.BMB_ST_BANK_S7_D18                ; Destination bank where layer 2 image is expected. See "NEXTREG _DC_REG_L2_BANK_H12 ....".

    NEXTREG _DC_REG_L2_BANK_H12, BM_16KBANK_D9 ; Layer 2 image (background) starts at 16k-bank 9 (default).
   
    LD B, dbs.BM_BANKS_D10                      ; Amount of banks occupied by the image. 320x256 has 10, 256x192 has 6, 256x128 has 4.
.bankLoop                                       ; Each loop copies single bank, there are 10 iterations.
    PUSH BC

    ; ##########################################
    ; Assign banks to slots.
    LD A, D
    NEXTREG _MMU_REG_SLOT6_H56, A               ; Read from.

    LD A, E
    NEXTREG _MMU_REG_SLOT7_H57, A               ; Write to.

    ; ##########################################
    ; Copy using DMA.
    CALL ut.CopyRam

    ; ##########################################
    ; Next iteration.
    INC E                                       ; Next destination bank.
    POP BC
    DJNZ .bankLoop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                     #HideImageLine                       ;
;----------------------------------------------------------;
; Replaces horizontal line of the image with transparent color.
; Input:
;  - E:  Line number
HideImageLine

    LD B, dbs.BM_BANKS_D10
.bankLoop                                       ; Loop from 10 (dbs.BM_BANKS_D10) to 0.

    ; We will iterate over 10 banks ascending from dbs.BMB_ST_BANK_S7_D18 to dbs.BMB_END_BANK_S7_D27.
    ; However, the loop starts at 10 (inclusive) and goes to 0 (exclusive)
    LD A, dbs.BMB_END_BANK_S7_D27 + 1               ; 27 + 1 - 10 = 18 -> dbs.BMB_END_BANK_S7_D27 + 1 - dbs.BM_BANKS_D10 = dbs.BMB_ST_BANK_S7_D18
    SUB B
    NEXTREG _MMU_REG_SLOT7_H57, A               ; Use slot 7 to modify displayed image.

    ; Each bank contains columns, each having 256 bytes/pixels. To draw the horizontal line at pixel 12 (y position from the top of the 
    ; picture), we have to start at byte 12, then 12+256, 12+(256*2), 12+(256*3), and so on.
    LD HL, _RAM_SLOT7_STA_HE000
    LD D, 0                                     ; E contains the line number, reset only D to use DE for 16-bit math.
    ADD HL, DE                                  ; HL points at line that will be replaced.

    ; ##########################################
    ; Iterate over each picture line in the current bank. Each bank has 8*1024/256=32 lines.
    PUSH BC

    LD B, _BANK_BYTES_D8192/_BM_YRES_D256       ; 8*1024/256=32
.linesLoop
    LD (HL), _COL_BLACK_D0
    ADD HL, _BM_YRES_D256                       ; Move HL to the next pixel to the right by adding 256 pixels.

    DJNZ .linesLoop
    POP BC
    
    DJNZ .bankLoop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;                   #ReplaceImageLine                      ;
;----------------------------------------------------------;
; Replaces the line of the displayed layer 2 image with the corresponding line of the given image.
; Input:
;  - E:  Line number.
ReplaceImageLine

    LD B, 0
.bankLoop                                       ; Loop from 0 to dbs.BM_BANKS_D10 - 1.
    
    ; ##########################################
    ; Setup banks. The source image will be stored in bank 6, destination image in bank 7. We will copy line from 6 to 7.

    ; Setup slot 6 with source.
    LD A, dbs.BMA_ST_BANK_S6_D35
    ADD B                                       ; A points to current bank from the source image.
    NEXTREG _MMU_REG_SLOT6_H56, A               ; Slot 6 contains source of the image.
    
    ; Setup slot 7 with destination.
    LD A, dbs.BMB_ST_BANK_S7_D18
    ADD B                                       ; A points to current bank of the source image.
    NEXTREG _MMU_REG_SLOT7_H57, A               ; Use slot 7 to modify displayed image.

    ; ##########################################
    ; Copy line from source to destination image.  Iterate over each picture line's pixel in current bank. Each bank has 8*1024/256=32 lines.
    PUSH BC

    LD B, _BANK_BYTES_D8192/_BM_YRES_D256       ; 8*1024/256=32
    LD D, 0                                     ; E contains the line number, reset only D to use DE for 16-bit math.
.linesLoop

    ; Copy a pixel from the source image into C.
    LD HL, _RAM_SLOT6_STA_HC000
    ADD HL, DE                                  ; Move DE from the beginning of the bank to the current pixel.
    LD C, (HL)                                  ; C contains pixel value.
    
    ; Copy pixel value from C into the destination image.
    LD HL, _RAM_SLOT7_STA_HE000
    ADD HL, DE                                  ; Move DE from the beginning of the bank to the current pixel.
    LD (HL), C                                  ; Store pixel value.

    ADD DE, _BM_YRES_D256                       ; Move DE to the next pixel to the right by adding 256 pixels.

    DJNZ .linesLoop
    POP BC
    
    ; ##########################################
    ; Loop from 0 to dbs.BM_BANKS_D10 - 1.
    LD A, B
    INC A
    LD B, A
    CP dbs.BM_BANKS_D10
    JR NZ, .bankLoop

    RET                                         ; ## END of the function ##

;----------------------------------------------------------;
;----------------------------------------------------------;
;                   PRIVATE FUNCTIONS                      ;
;----------------------------------------------------------;
;----------------------------------------------------------;

;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
    ENDMODULE
