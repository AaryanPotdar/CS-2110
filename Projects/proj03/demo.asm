.orig x3000

;  **** PUTS and OUT TRAPS ++++
;     LD R1, X ;; 2
;     LD R2, Y ;; 3
;     LD R3, TOASCII ;; 48
;     ADD R1, R2, R1 ;; 5
;     ADD R1, R1, R3 ;; 53
    
;     LEA R0, HELLO ;; prints string to console
;     PUTS
    
;     ADD R0, R1, 0 ;; prints char (ascii value) to console
;     OUT


; HALT

; HELLO .stringz "The sum is: "
; X .fill #2
; Y .fill #3
; TOASCII .fill #48

;  **** KBSR and KBDR demo ****

.orig x3000
POLL LDI R0, KBSRPtr    ; memory mapped IO so we use bit[15]
     BRzp POLL          ; branches back if bit[15] is 0 -> Keyboard enabled
     LDI R0, KBDRPtr    ; bit[15] is 1. Read the key. Keyboard is disabled (no new key read in)
     
POLL2 LDI R1, DSRPtr ; memory mapped IO so we use bit[15]
      BRzp POLL2     ; check if bit[15] is 1. Branch back if 0 --> Screen not ready
      STI R0, DDRPtr ; bit[15] is 1. Screen ready to display
     
KBSRPtr .fill xFE00
KBDRPtr .fill xFE02
DSRPtr .fill xFE04
DDRPtr .fill xFE06

.end

