;; ============================================================================
;; CS 2110 - Fall 2023
;; Project 3 - wordProcessor
;; ============================================================================
;; Name: Aaryan Potdar
;; ============================================================================

;; =============================== absoluteSum ===============================
;; DESCRIPTION:
;; This function calculates the sum of the absolute values of an array of 
;; integers.
;; The starting address of the array and the length of the array are provided
;; in memory The answer should also be stored in memory at x3050 (ANSWER)

;; SUGGESTED PSUEDOCODE:
;; answer = 0
;; currNum = 0
;; i = 0
;; arrLength = ARR.length()
;; while (arrLength > 0)
;;    currNum = ARR[i]
;;    if (currNum < 0):
;;        currNum = -(currNum); 
;;    answer += currNum;
;;    i++
;;    arrLength--
;; return

.orig x3000
    AND R0, R0, 0 ; initialize R0 to 0. This reg will hold the sum
    LD R1, LEN    ; load length of array in R1
    BRz ZERO_LENGTH
    LD R2, ARR    ; load address of array in R2

FOR
    LDR R3, R2, 0  ; load array element in R3
    BRn NEGATIVE   ; check if value is negative
    ADD R0, R0, R3 ; if not negative add to sum
    BR DONE        ; unconditional branch
    
NEGATIVE
    NOT R3, R3     ; negate value by flipping bits
    ADD R3, R3, 1  ; add 1
    ADD R0, R0, R3 ; add to sum
        
DONE
    ADD R2, R2, 1  ; increment array element address
    ADD R1, R1, -1 ; decrement array length
    BRp FOR        ; if array length is positive, return to for loop
ZERO_LENGTH
    LD R5, ANSWER  ; load address stored in label
    STR R0, R5, 0  ; store sum in memory

HALT

;; Do not rename or remove any existing labels
LEN      .fill 5
ARR      .fill x6000
ANSWER   .fill x3050
.end

;; Answer needs to be stored here
.orig x3050
.blkw 1
.end

;; Array. Change values here for debugging!
.orig x6000
    .fill -3
    .fill 4
    .fill -1
    .fill 10
    .fill -20
.end