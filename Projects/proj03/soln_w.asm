;; ============================================================================
;; CS 2110 - Fall 2023
;; Project 3 - wordProcessor
;; ============================================================================
;; Name: Cliff Lin
;; ============================================================================


;; =============================== Part 0: main ===============================
;; This is the starting point of the assembly program.
;; It sets up the stack pointer, and then calls the wordProcess() subroutine.
;; This subroutine has been provided for you. Change which subroutine is called
;; to debug your solutions!

.orig x3000
;; Set Stack Pointer = xF000
LD R6, STACK_PTR
;; Call wordProcess(). Change the subroutine being called for your own debugging!
LD R5, SUBROUTINE_ADDR
JSRR R5
HALT
;; Use a different label above to test your subroutines. 
;; DO NOT CHANGE OR RENAME THESE!
STACK_PTR        .fill xF000
;; Change the value below to be the address you want to test! 
;; IMPORTANT: change it back to x7000 for the autograder to work!
SUBROUTINE_ADDR  .fill x7000 
.end


;; ============================ Part 1: wordLength ============================
;; DESCRIPTION:
;; This function calculates the length of a word, given the starting address of
;; the word.
;; The starting address of the word should be passed in via register R0.
;; The length of the word should be returned in register R0.
;; A word is terminated by either a space bar, a null terminator, or a newline
;; character.

;; SUGGESTED PSEUDOCODE:
;; def wordLength(R0):
;;     addr = R0
;;     length = 0
;;     while (true):
;;         if (mem[addr] == '\0'):
;;             break
;;         if (mem[addr] == '\n'):
;;             break
;;         if (mem[addr] == ' '):
;;             break
;;         addr += 1
;;         length += 1
;;     R0 = length
;;     return
.orig x3800
AND, r1, r1, 0 ;; clear r1, r1 is length = 0
AND, r2, r2, 0 ;; clear r2. r2 holds the current char
LD, r3, ASCII_SPACE_1 ;; loads in space
NOT, r3, r3 ;;negates space
ADD, r3, r3, 1

LENGTH_WHILE LDR, r2, r0, 0 ;; load in current char
        BRz LENGTH_STOP ;; breaks when null
    ADD, r2, r2, -10 ;; check for newline
        BRz LENGTH_STOP ;; breaks when newline
    ADD, r2, r2, 10 ;; add 10 back
    ADD, r2, r2, r3 ;; check for space
        BRz LENGTH_STOP ;; breaks when space
    ADD, r0, r0, 1 ;; increment address
    ADD, r1, r1, 1 ;; increment length
    BR LENGTH_WHILE
LENGTH_STOP AND, r0, r0, 0 ;; clear r0
ADD, r0, r0, r1 ;; put length into r0

RET
ASCII_NEWLINE_1 .fill 10 
ASCII_SPACE_1   .fill 32 
.end 


;; ============================== Part 2: memcpy ==============================
;; DESCRIPTION: 
;; This function copies a block of memory from one location to another.
;; sourcePtr and destPtr are the starting addresses of the source and 
;; destination blocks of memory, respectively.
;; The length is the number of memory addresses to copy.
;; The sourcePtr, destPtr, and length should be passed in via registers R0, R1,
;; and R2 respectivley

;; SUGGESTED PSEUDOCODE:
;; def memcpy(R0, R1, R2):
;;     sourcePtr = R0
;;     destPtr = R1
;;     length = R2
;;     while (length > 0):
;;         mem[destPtr] = mem[sourcePtr]
;;         sourcePtr += 1
;;         destPtr += 1
;;         length -= 1
;;     return

.orig x4000


MEM_WHILE ADD, r2, r2, 0 ;; check cc
    BRz MEM_STOP ;; stop if length = 0
    LDR, r3, r0, 0 ;; loads source value into r3
    STR, r3, r1, 0 ;; stores source value into destination
    ADD, r0, r0, 1 ;; increment source address
    ADD, r1, r1, 1 ;; increment destination address
    ADD, r2, r2, -1 ;; decrement length
BR MEM_WHILE
MEM_STOP 

RET
.end


;; ========================== Part 3: capitalizeLine ==========================
;; DESCRIPTION:
;; This subroutine capitalizes all the letters in a line of text. A line is 
;; terminated by either the null terminator or the newline character.
;; The starting address of the line should be passed in via register R0.
;; Keep in mind that ASCII characters that are not lowercase letters (i.e. 
;; symbols, number, etc) should not be modified!

;; SUGGESTED PSUEDOCODE:
;; def capitalizeLine(R0):
;;     addr = R0
;;     while (mem[addr] != '\0' and mem[addr] != '\n'):
;;         if (mem[addr] >= 'a' and mem[addr] <= 'z'): 
;;             mem[addr] = mem[addr] - 32 
;;         addr += 1
;;     return

.orig x4800

AND, r1, r1, 0 ;; clears r1. r1 stores curr char

CAP_WHILE LDR, r1, r0, 0 ;; load in curr char
    BRz CAP_STOP ;; stop when null
    ADD, r1, r1, -10 ;;check for newline
    BRz CAP_STOP ;; stop when newline
    ADD, r1, r1, 10 ;; add 10 back
        
        LD, r2, MINUS_32 ;; put -32 into r2
        LD, r3, LOWER_A ;; put 97 into r3
        NOT, r3, r3 ;; negate to -97
        ADD, r3, r3, 1
        LD, r4, LOWER_Z ;; put 122 into r4
        NOT, r4, r4 ;; negate to -122
        ADD, r4, r4, 1
    
        ADD, r1, r1, r3 ;; check for lower a
            BRn CAP_SKIP ;; skip if below lower a
        
        NOT, r3, r3 ;; negate back to 97
        ADD, r3, r3, 1
        ADD, r1, r1, r3 ;; add 97 back
       
        ADD, r1, r1, r4 ;; check for lower z
            BRp CAP_SKIP ;; skip if above lower z
        
        NOT, r4, r4 ;; negate back to 122
        ADD, r4, r4, 1
        ADD, r1, r1, r4 ;; add 122 back
          
            ADD, r1, r1, r2 ;; turn uppercase
            STR, r1, r0, 0 ;; store back into memory
        
        CAP_SKIP ADD, r0 , r0, 1 ;; increment address
BR CAP_WHILE ;; while loop

CAP_STOP
RET
LOWER_A         .fill 97
LOWER_Z         .fill 122
MINUS_32        .fill -32
ASCII_NEWLINE_2 .fill 10 
.end




;; =========================== Part 4: reverseWords ===========================
;; DESCRIPTION:
;; This subroutine reverses each individual word in a line of text.
;; For example, the line "Hello World" would become "olleH dlroW".
;; A line is terminated by either the null terminator or the newline character.
;; The starting address of the line should be passed in via register R0.

;; SUGGESTED PSEUDOCODE:
;; def reverseWords(R0):
;;     i = R0
;;     while (true):
;;          if (mem[i] == '\0' or mem[i] == '\n'):
;;              break
;;          if (mem[i] == ' '):
;;              i++
;;              continue
;;          start = i
;;          count = 0
;;          while (mem[i] != ' ' and mem[i] != '\0' and mem[i] != '\n'):
;;              stack.push(mem[i])
;;              i++
;;              count++
;;          i = start
;;          while (count > 0):
;;              mem[i] = stack.pop()
;;              i++
;;              count--
;;     return

.orig x5000

AND, r1, r1, 0 ;; clears r1. Put cur char in r1


REV_WHILE1
    LDR, r1, r0, 0 ;; loads in cur char
    BRz REV_STOP ;; stops when null
    ADD, r1, r1, -10 ;; checks for newline
    BRz REV_STOP ;; stops when newline
    ADD, r1, r1, 10 ;; add 10 back
    
    LD, r4, ASCII_SPACE_2 ;; loads in 32
    NOT, r4, r4 ;;negates to -32
    ADD, r4, r4, 1
    ADD, r4, r1, r4 ;; checks for space
    BRnp REV_SKIP1 ;; skips when no space
    ADD, r0, r0, 1 ;; increment i
    BR REV_WHILE1 ;; continue to next while loop
   
    REV_SKIP1 
    
    AND, r2, r2, 0 ;; clears r2. Holds the start var
    AND, r3, r3, 0 ;; clears r3. Holds the count var
    
    ADD, r2, r2, r0 ;; start = r0
    
    REV_WHILE2 LDR, r1, r0, 0 ;; load in cur char
        BRz REV_SKIP2 ;; skips when zero
        ADD, r1, r1, -10 ;; checks for newline
        BRz REV_SKIP2 ;; skips when newline
        ADD, r1, r1, 10 ;; add 10 back
    
        LD, r4, ASCII_SPACE_2 ;; loads in 32
        NOT, r4, r4 ;;negates to -32
        ADD, r4, r4, 1
        ADD, r4, r1, r4 ;; checks for space
        BRz REV_SKIP2 ;; skips when space
        
        ADD, r6, r6, -1 ;; decrement stack pointer
        STR, r1, r6, 0 ;; store cur char at stack pointer
        ADD, r0, r0, 1 ;; increment i
        ADD, r3, r3, 1 ;; increment count
    BR REV_WHILE2
    REV_SKIP2
    
    AND, r0, r0, 0 ;; clear r0
    ADD, r0, r2, 0 ;; i = start
    ADD, r3, r3, 0 ;; set cc
    
    REV_WHILE3 BRz REV_SKIP3
        LDR, r1, r6, 0 ;; loads in char at stack pointer
        ADD, r6, r6, 1 ;; increment stack pointer
        STR, r1, r0, 0 ;; stores char into memory
        ADD, r0, r0, 1 ;; increment i
        ADD, r3, r3, -1 ;; decrement count
    BR REV_WHILE3
    REV_SKIP3
BR REV_WHILE1
REV_STOP
        

RET
ASCII_NEWLINE_3 .fill 10 
ASCII_SPACE_2   .fill 32 
.end


;; =========================== Part 5: rightJustify ===========================
;; DESCRIPTION: 
;; This subroutine right justifies a line of text by padding with space bars.
;; For example, the line "CS2110   " would become "   CS2110". A line is 
;; terminated by either the null terminator or the newline character.
;; The starting address of the line should be passed in via register R0.

;; SUGGESTED PSEUDOCODE:
;; def rightJustify(R0):
;;    start = R0
;;    curr = start
;;    while (mem[curr] != '\n' and mem[curr] != '\0'):
;;        curr++
;;    curr--
;;    end = curr
;;    // This loop shifts over the entire string one spacebar at a time,
;;    // until it is no longer terminated by a spacebar!
;;    while (mem[end] == ' '):
;;        while (curr != start):
;;            mem[curr] = mem[curr - 1]
;;            curr--
;;        mem[curr] = ' '
;;        curr = end
;;    return

.orig x5800

AND, r1, r1, 0 ;; clear r1, r1 is curr
ADD, r1, r1, r0 ;; r1 = start

RIGHT_WHILE1 LDR, r2, r1, 0 ;; load in mem[curr] into r2
    BRz RIGHT_STOP1 ;; stops when null
    ADD, r2, r2, -10 ;; checks for newline
    BRz RIGHT_STOP1 ;; stops when newline
    ADD, r1, r1, 1 ;; increment curr
BR RIGHT_WHILE1
RIGHT_STOP1 ADD, r1, r1, -1 ;; decrement curr

ADD, r3, r1, 0 ;; r3 is end, end = curr

RIGHT_WHILE2 LDR, r2, r3, 0 ;; load in mem[end] into r2
    LD, r4, ASCII_SPACE_3 ;; load 32 into r4
    NOT, r4, r4 ;; -32
    ADD, r4, r4, 1
    ADD, r4, r2, r4 ;; check for space
    BRnp RIGHT_STOP2 ;; stop when not space
    RIGHT_WHILE3 
        NOT, r0, r0 ;; make start negative
        ADD, r0, r0, 1
        ADD, r1, r1, r0 ;; check if curr = start
        BRz RIGHT_STOP3 ;; stop when curr = start
        
        NOT, r0, r0 ;; make start positive
        ADD, r0 ,r0, 1
        ADD, r1, r1, r0 ;; add start back to curr
        
        LDR, r2, r1, -1 ;; load mem[curr - 1] into r2
        STR, r2, r1, 0 ;; mem[curr] = r2
        
        ADD, r1, r1, -1 ;; decrement curr
    BR RIGHT_WHILE3
    RIGHT_STOP3
    NOT, r0, r0 ;; make start positive
    ADD, r0 ,r0, 1
    ADD, r1, r1, r0 ;; add start back to curr
    LD, r4, ASCII_SPACE_3 ;; load 32 into r4
    STR, r4, r1, 0 ;; mem[curr] = r4
    ADD, r1, r3, 0 ;; curr = end
BR RIGHT_WHILE2
RIGHT_STOP2

    

RET
ASCII_SPACE_3   .fill 32
ASCII_NEWLINE_4 .fill 10
.end


;; ============================= Part 6: getInput =============================
;; DESCRIPTION: 
;; This function should read a string of characters from the keyboard and place
;; them in a buffer.
;; The address of the buffer should be passed in via register R0.
;; The string should be terminated by two consecutive '$' characters.
;; The '$' characters should not be placed in the buffer.
;; Remember to properly null-terminate your string, and to print out each 
;; character as it is typed!
;; You may assume that the user will always enter a valid input.

;; SUGGESTED PSEUDOCODE:
;; def getInput(R0):
;;      bufferPointer = R0
;;      while (true):
;;          input = GETC() 
;;          OUT(input)
;;          mem[bufferPointer] = input 
;;          if input == '$':
;;              if mem[bufferPointer - 1] == '$':
;;                  mem[bufferPointer - 1] = '\0'
;;                  break
;;          bufferPointer += 1

.orig x6000

ADD, r1, r0, 0 ;; sets r1 as buffer pointer

GET_WHILE GETC ;; get char from console, stores in r0
    OUT ;; print input
    STR, r0, r1, 0 ;; store input at buffer pointer
    
    LD, r2, ASCII_DOLLAR_SIGN ;; load 36 in r2
    NOT, r2, r2 ;; negate 36
    ADD, r2, r2, 1
    ADD, r2, r0, r2 ;; check for $
    BRnp GET_SKIP ;; skip when no $
    LD, r2, ASCII_DOLLAR_SIGN ;; load 36 in r2
    NOT, r2, r2 ;; negate 36
    ADD, r2, r2, 1
    ADD, r3, r1, -1 ;; put bufferpointer - 1 at r3
    LDR, r4, r3, 0 ;; load in mem[bp - 1] at r4
    ADD, r4, r2, r4 ;; check for $
    BRnp GET_SKIP ;; skip when no $
    STR, r4, r3, 0 ;; mem[bf - 1] = 0
    BR GET_STOP
    GET_SKIP ADD, r1, r1, 1 ;; increment bf
BR GET_WHILE
GET_STOP
RET
ASCII_DOLLAR_SIGN .fill 36
.end


;; ============================ Part 7: parseLines ============================
;; IMPORTANT: This method has already been implemented for you. It will help 
;; you when implementing wordProcessor!

;; Description: This subroutine parses a string of characters from an 
;; initial buffer and places the parsed string in a new buffer. 
;; This subroutine divides each line into 8 characters or less. If a word
;; cannot fully fit on the current line, trailing spaces will be added and it
;; will be placed on the next line instead.

;; The address of the buffer containing the unparsed string, as well as the 
;; address of the destination buffer should be passed in via registers R0 and
;; R1 respectively.

;; An example of what memory looks like before and after parsing:
;;  x3000 │ 'A' │               x6000 │ 'A' │  ───┐
;;  x3001 │ ' ' │               x6001 │ ' ' │     │
;;  x3002 │ 'q' │               x6002 │ 'q' │     │
;;  x3003 │ 'u' │               x6003 │ 'u' │     │ 8 characters
;;  x3004 │ 'i' │               x6004 │ 'i' │     │ (not including \n!)
;;  x3005 │ 'c' │               x6005 │ 'c' │     │
;;  x3006 │ 'k' │               x6006 │ 'k' │     │
;;  x3007 │ ' ' │               x6007 │ ' ' │  ───┘
;;  x3008 │ 'r' │               x6008 │ \n  │
;;  x3009 │ 'e' │               x6009 │ 'r' │  ───┐
;;  x300A │ 'd' │               x600A │ 'e' │     │
;;  x300B │ ' ' │               x600B │ 'd' │     │
;;  x300C │ 'k' │     ───>      x600C │ ' ' │     │ 8 characters
;;  x300D │ 'i' │               x600D │ ' ' │     │ (not including \n!)
;;  x300E │ 't' │               x600E │ ' ' │     │
;;  x300F │ 't' │               x600F │ ' ' │     │
;;  x3010 │ 'y' │               x6010 │ ' ' │  ───┘
;;  x3011 │ \0  │               x6011 │ \n  │
;;  x3012 │ \0  │               x6012 │ 'k' │  ───┐
;;  x3013 │ \0  │               x6013 │ 'i' │     │
;;  x3014 │ \0  │               x6014 │ 't' │     │
;;  x3015 │ \0  │               x6015 │ 't' │     │ 8 characters
;;  x3016 │ \0  │               x6016 │ 'y' │     │ (not including \0!)
;;  x3017 │ \0  │               x6017 │ ' ' │     │
;;  x3018 │ \0  │               x6018 │ ' ' │     │
;;  x3019 │ \0  │               x6019 │ ' ' │  ───┘
;;  x301A │ \0  │               x601A │ \0  │

;; PSEUDOCODE:
;; def parseLines(R0, R1):
;;      source = R0
;;      destination = R1
;;      currLineLen = 0
;;      while (mem[source] != '\0'):
;;          wordLen = wordLength(source)
;;          if (currLineLen + wordLen - 8 <= 0):
;;              memcpy(source, destination + currLineLen, wordLen)
;;              lineLen += wordLen
;;              if (mem[source + wordLen] == '\0'):
;;                  break 
;;              source += wordLen + 1 
;;              if (lineLen < 8):
;;                  mem[destination + lineLen] = ' '
;;                  lineLen += 1
;;          else:
;;              while (lineLen - 8 < 0):
;;                  mem[destination + lineLen] = ' '
;;                  lineLen += 1
;;              mem[destination + lineLen] = '\n'
;;              destination += lineLen + 1
;;              lineLen = 0
;;      while (lineLen - 8 < 0):
;;          mem[destination + lineLen] = ' '   
;;      mem[destination + lineLen] = '\0'
.orig x6800
;; Save RA on the stack
ADD R6, R6, -1
STR R7, R6, 0
AND R2, R2, 0 ; currLineLen = 0
PARSE_LINES_WHILE
    LDR R3, R0, 0 
    BRz EXIT_PARSE_LINES_WHILE ; mem[source] == '\0'
    ; make a wordLength(source) call
    ; Save R0-R5 on the stack
    ADD R6, R6, -1
    STR R0, R6, 0
    ADD R6, R6, -1
    STR R1, R6, 0
    ADD R6, R6, -1
    STR R2, R6, 0
    ADD R6, R6, -1
    STR R4, R6, 0
    ADD R6, R6, -1
    STR R5, R6, 0

    LD R3, WORDLENGTH_ADDR
    JSRR R3            
    ADD R3, R0, 0 ; wordLen (R3) = wordLength(source)

    ; Restore R0-R5 from the stack!
    LDR R5, R6, 0
    ADD R6, R6, 1
    LDR R4, R6, 0
    ADD R6, R6, 1
    LDR R2, R6, 0
    ADD R6, R6, 1
    LDR R1, R6, 0
    ADD R6, R6, 1
    LDR R0, R6, 0
    ADD R6, R6, 1

    ADD R4, R2, R3 ;; R4 = currLineLen + wordLen
    ADD R4, R4, -8
    BRp PARSE_LINES_ELSE
        ;; Save R0-R5 on the stack
        ADD R6, R6, -1
        STR R0, R6, 0
        ADD R6, R6, -1
        STR R1, R6, 0
        ADD R6, R6, -1
        STR R2, R6, 0
        ADD R6, R6, -1
        STR R3, R6, 0
        ADD R6, R6, -1
        STR R4, R6, 0
        ADD R6, R6, -1
        STR R5, R6, 0

        ADD R1, R1, R2 ;; destination + currLineLen
        ADD R2, R3, 0  ;; wordLen is in R3
        LD R5, MEMCPY_ADDR
        JSRR R5 ;; memcpy(source, destination + currLineLen, wordLen)

        ;; Restore R0-R5 from the stack
        LDR R5, R6, 0
        ADD R6, R6, 1
        LDR R4, R6, 0
        ADD R6, R6, 1
        LDR R3, R6, 0
        ADD R6, R6, 1
        LDR R2, R6, 0
        ADD R6, R6, 1
        LDR R1, R6, 0
        ADD R6, R6, 1
        LDR R0, R6, 0
        ADD R6, R6, 1

        ADD R2, R2, R3 ;; lineLen += wordLen

        ; if (mem[source + wordLen] == '\0'), 
        ADD R5, R0, R3 ;; R5 = source + wordLen
        LDR R5, R5, 0 ;; R5 = mem[source + wordLen]
        BRnp LINE_HASNT_ENDED
        BR FILL_WITH_SPACES
        LINE_HASNT_ENDED

        ADD R0, R0, R3 ;; source += wordLen
        ADD R0, R0, 1 ;; source += 1

        ADD R4, R2, -8 ; if (linelen < 8):
        BRzp DONT_ADD_SPACE
            ;; Add the spacebar
            ADD R5, R1, R2 ;; R5 = destination + lineLen
            LD R4, ASCII_SPACE_4
            STR R4, R5, 0 ;; mem[destination + lineLen] = ' '
            ADD R2, R2, 1 ;; lineLen += 1
        DONT_ADD_SPACE
        BRnzp PARSE_LINES_WHILE
    PARSE_LINES_ELSE
        ;; Else clause
        PARSE_LINES_WHILE2
            ADD R4, R2, -8
            BRzp EXIT_PARSE_LINES_WHILE2
            LD R4, ASCII_SPACE_4
            ADD R5, R1, R2 ;; R5 = destination + lineLen
            STR R4, R5, 0 ;; mem[destination + lineLen] = ' '
            ADD R2, R2, 1 ;; lineLen += 1
            BRnzp PARSE_LINES_WHILE2
        EXIT_PARSE_LINES_WHILE2
        LD R4, ASCII_NEWLINE_5
        ADD R5, R1, R2 ;; R5 = destination + lineLen
        STR R4, R5, 0 ;; mem[destination + lineLen] = '\n'
        ADD R1, R1, R2 ;; destination += lineLen
        ADD R1, R1, 1 ;; destination += 1
        AND R2, R2, 0 ;; lineLen = 0
        BRnzp PARSE_LINES_WHILE
EXIT_PARSE_LINES_WHILE

;; while (lineLen - 5 < 0):
;;    mem[destination + lineLen] = ' ' 
FILL_WITH_SPACES
    ADD R4, R2, -8
    BRzp EXIT_FILL_WITH_SPACES
    LD R4, ASCII_SPACE_4
    ADD R5, R1, R2 ;; R5 = destination + lineLen
    STR R4, R5, 0 ;; mem[destination + lineLen] = ' '
    ADD R2, R2, 1 ;; lineLen += 1
BRnzp FILL_WITH_SPACES
EXIT_FILL_WITH_SPACES

AND R4, R4, 0 ;; '\0'
ADD R5, R1, R2 ;; R5 = destination + lineLen
STR R4, R5, 0 ;; mem[destination + lineLen] = '\0'

; Pop RA from the stack
LDR R7, R6, 0
ADD R6, R6, 1

RET

WORDLENGTH_ADDR .fill x3800
MEMCPY_ADDR     .fill x4000
ASCII_SPACE_4   .fill 32
ASCII_NEWLINE_5 .fill 10
.end


;; ========================== Part 8: wordProcessor ===========================
;; Implement this subroutine LAST! It will use all the other subroutines.
;; This subroutine should read in a string of characters from the keyboard and
;; write it into the buffer provided at x8000. It should then parse the string
;; into lines of 8 characters or less, and write the parsed string to the 
;; buffer provided at x8500. Finally, for each line, the user should be able to
;; select between leaving the line as is, capitalizing the line, reversing the 
;; words in the line, or right justifying the line. The final parsed string 
;; should be written to the buffer at x8500 and printed out to the console.

;; You may assume that the input will always be valid - it will not exceed the 
;; length of the buffer, no word will be longer than 8 characters, and there 
;; will not be any leading / trailing spaces!

;; An example of what correct console output looks like if the sentence typed
;; is "The quick brown fox jumps over the lazy dog", and the options entered
;; are 0, 1, 2, 3, 0, 1, 2, 3
;; Note that any characters that are not 0, 1, 2, or 3 should be ignored!

;; Expected console output:

;; The quick brown fox jumps over the lazy dog$$
;; Enter modifier options:
;; The 
;; QUICK
;; nworb
;;     fox
;; jumps
;; OVER THE
;; yzal god

;; SUGGESTED PSEUDOCODE:
;; def WordProcess():
;;      GetInput(x8000)
;;      OUT(\n)
;;      ParseLines(x8000, x8500)
;;      startOfCurrLine = x8500
;;      PUTS("Enter modifier options.\n")
;;      while (true):
;;          option = GETC()
;;          if (option == '0'):
;;              pass
;;          elif (option == '1'):
;;              CapitalizeLine(startOfCurrLine)
;;          elif (option == '2'):
;;              ReverseWords(startOfCurrLine)
;;          elif (option == '3'):
;;              RightJustify(startOfCurrLine)
;;          else:
;;              // Input is not valid, just try again:
;;              continue
;;          // Print the line after it is modified
;;          i = 0
;;          while (i < 9):
;;              OUT(mem[startOfCurrLine])
;;              startOfCurrLine++
;;              i++
;;          if (mem[startOfCurrLine - 1] == '\0'):
;;              break
;;      return
.orig x7000

LD, r0, BUFFER_1 ;; load x8000 into r0
LD, r1, GETINPUT_ADDR ;; load get input addr 
JSRR r1 ;; call get input

AND, r0, r0, 0 ;; clear r0
ADD, r0, r0, 10 ;; put newline into r0
OUT ;; print out newline

LD, r0, BUFFER_1 ;; load x8000 into r0
LD, r1, BUFFER_2 ;; load x8500 into r1
LD, r2, PARSELINES_ADDR ;; load parse lines address into r2
JSRR r2 ;; call parselines

LD, r5, BUFFER_2 ;; load x8500 into r5, r5 is start of currline
LD, r0, OPTIONS_MSG ;; load message addr into r0
PUTS ;; prints message into console

WORD_WHILE1
    GETC ;; get input from console, stores at r0
    LD, r1, ASCII_ZERO ;; load 48 into r1
    NOT, r1, r1 ;; -48
    ADD, r1, r1, 1
    ADD, r0, r0, r1
    BRz WORD_PASS ;; pass if option = 0
    
    ADD, r0, r0, -1 ;; check if option = 1
    BRz WORD_IF1 ;; go to if statement option = 1
    
    ADD, r0, r0, -1 ;; check if option = 2
    BRz WORD_IF2 ;; go to if statment option = 2
    
    ADD, r0, r0, -1 ;; check if option = 3
    BRz WORD_IF3 ;; go to if statement option = 3
    
    BR WORD_WHILE1
    
    WORD_IF1
        LD, r1, CAPITALIZE_ADDR ;; load capitalize addr into r1
        ADD, r0, r5, 0 ;; put start into r0
        JSRR r1 ;; call capitalize
        BR WORD_PASS
    
    WORD_IF2
        LD, r1, REVERSE_ADDR ;; load reverse addr into r1
        ADD, r0, r5, 0 ;; put start into r0
        JSRR r1 ;; call reverse
        BR WORD_PASS
    
    WORD_IF3
        LD, r1, RIGHT_JUSTIFY_ADDR ;; load right justify addr into r1
        ADD, r0, r5, 0 ;; put start into r0
        JSRR r1 ;; call right justify
        BR WORD_PASS
    
    WORD_PASS
    
    AND, r1, r1, 0 ;; i = 0
    
    WORD_WHILE2
        ADD, r1, r1, -9 ;; set cc
        BRz WORD_STOP2 ;; exit while loop if i = 9
        ADD, r1, r1, 9 ;; add 9 back
        LDR, r0, r5, 0 ;; load mem[start] into r0
        OUT ;; print out mem[start]
        ADD, r5, r5, 1 ;; increment start
        ADD, r1, r1, 1 ;; increment i
    BR WORD_WHILE2
    WORD_STOP2
    LDR, r1, r5, -1 ;; set cc
    BRz WORDSTOP_1 ;; break when null
BR WORD_WHILE1
WORDSTOP_1
    
    
    

RET
BUFFER_1           .fill x8000
BUFFER_2           .fill x8500
GETINPUT_ADDR      .fill x6000
PARSELINES_ADDR    .fill x6800
CAPITALIZE_ADDR    .fill x4800
REVERSE_ADDR       .fill x5000
RIGHT_JUSTIFY_ADDR .fill x5800
ASCII_ZERO         .fill 48
ASCII_ONE          .fill 49
ASCII_TWO          .fill 50
ASCII_THREE        .fill 51
ASCII_NEWLINE_6    .fill 10
OPTIONS_MSG        .stringz "Enter modifier options:\n"
.end


;; x8000 Buffer
.orig x8000
.blkw 100
.end


;; x8500 Buffer
.orig x8500
.blkw 100
.end