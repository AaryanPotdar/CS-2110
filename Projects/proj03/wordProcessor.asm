;; ============================================================================
;; CS 2110 - Fall 2023
;; Project 3 - wordProcessor
;; ============================================================================
;; Name: Aaryan Potdar
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
    LD R1, ASCII_NEWLINE_1   ; load ascii value of newline char
    LD R2, ASCII_SPACE_1     ; load ascii value of space
    AND R3, R3, 0            ; initialize R3
    
WHILE
    LDR R4, R0, 0       ; load the char at address stored in R0
    NOT R4, R4          ; negate value
    ADD R4, R4, 1       ;
    
    ADD R5, R4, R1      ; check for newline char
    BRz END_LOOP        ; branch to END_LOOP
    
    ADD R5, R4, R2      ; check for space char
    BRz END_LOOP        ; branch to END_LOOP
    
    ADD R5, R4, 0       ; check for null char
    BRz END_LOOP        ; branch to END_LOOP
    
    ADD R0, R0, 1       ; increment address
    ADD R3, R3, 1       ; increment length
    BR WHILE            ; branch return to while loop

END_LOOP
    AND R0, R0, 0       ; set R0 to 0
    ADD R0, R3, R0      ; add wordlength

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

MCPY_LOOP
    LDR R3, R0, 0       ; load value using source pointer
    STR R3, R1, 0       ; store value to destination pointer
    ADD R0, R0, 1       ; increment sourcePtr
    ADD R1, R1, 1       ; increment destPtr
    ADD R2, R2, -1      ; decrement length
    BRz END_MCPY_LOOP   ; check if length is 0
    BR MCPY_LOOP        ; repeat loop
    
END_MCPY_LOOP
RET                      ; return from subroutine
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
CAP_LOOP
    LDR R1, R0, 0           ; load character in R1
    BRz END_CAP_LOOP        ; if null char, exit loop
    
    LD R2, ASCII_NEWLINE_2  ; check if newline character
    NOT R2, R2
    ADD R2, R2, 1
    ADD R3, R1, R2
    BRz END_CAP_LOOP        ; exit loop
    
    LD R2, LOWER_A          ; check if ascii value < 97
    NOT R2, R2
    ADD R2, R2, 1
    ADD R3, R1, R2
    BRn SKIP_LETTER         ; skip character
    
    LD R2, LOWER_Z          ; check if ascii value > 122
    NOT R2, R2
    ADD R2, R2, 1
    ADD R3, R1, R2
    BRp SKIP_LETTER         ; skip character
    
    LD R2, MINUS_32         ; capitalize charcter
    ADD R1, R1, R2
    
    STR R1, R0, 0           ; store capitalized letter in memory
    ADD R0, R0, 1           ; increment R0
    BR CAP_LOOP             ; return to loop
    
SKIP_LETTER                 ; skip character
    ADD R0, R0, 1           ; increment R0
    BR CAP_LOOP             ; branch return to loop
    
END_CAP_LOOP
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
REVERSE_LOOP  
        LDR R2, R0, 0               ; i = R1 = R0
        BRz REVERSE_LOOP_END        ; check if null character
        ADD R1, R2, -10             ; check if newline character
        BRz REVERSE_LOOP_END        ; go to end if newline char or null
        
        LD R1, ASCII_SPACE_2        ; check if space character reached
        NOT R1, R1                  ; negate value for comparison
        ADD R1, R1, 1
        ADD R1, R1, R2              ; compare R2 curr char and R1
        BRnp START                  ; if not branch to start
        
        ADD R0, R0, 1               ; increment i / R0
        BR REVERSE_LOOP             ; uncoditional branch to R0

START   AND R5, R5, 0               ; clear R5
        ADD R5, R0, 0               ; start = R5 = i
        AND R3, R3, 0               ; clear count register
        
REVERSE_LOOP2
        LDR R1, R0, 0               ; read mem[i]
        ADD R1, R1, 0               ; check if char is null
        BRz LEAVE_LOOP2                    ; exit loop if char is null

        LD R2, ASCII_SPACE_2        ; check if char is space
        NOT R2, R2                  ; negate value for checking char
        ADD R2, R2, 1               ; +1 for negation
        
        ADD R2, R1, R2              ; check fo rspace char
        BRz LEAVE_LOOP2                    ; exit loop if space char
        
        ADD R4, R1, -10             ; if null char exit
        BRz LEAVE_LOOP2
        
        ADD R6, R6, -1              ; push on stack mem[i]
        STR R1, R6, 0               ; store mem[i] to stack
        
        ADD R0, R0, 1               ; increment i
        ADD R3, R3, 1               ; increment count
        
        BR REVERSE_LOOP2            ; branch back to while loop

LEAVE_LOOP2
        AND R0, R0, 0               ; reset start i
        ADD R0, R5, 0               ; reset count
        
REVERSE_LOOP3                       ; output loop
        ADD R3, R3, 0               ; if the count is 0
        BRnz REVERSE_LOOP           ; return to first loop
        
        LDR R4, R6, 0               ; pop from stack
        ADD R6, R6, 1               ; adjust stack pointer
        
        STR R4, R0, 0               ; write value to mem[i]
        ADD R0, R0, 1               ; increment i
        
        ADD R3, R3, -1              ; decrement count
        
        BR REVERSE_LOOP3            ; unconditional branch

REVERSE_LOOP_END
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
    AND, R1, R1, 0      ; clear R1. R1 is curr
    ADD, R1, R1, R0     ; R1 is start

RIGHT_LOOP1 
    LDR, R2, R1, 0          ; read current char in R2
    BRz RIGHT_LOOP_STOP1    ; stop if null char
    ADD, R2, R2, -10        ; check if newline character
    BRz RIGHT_LOOP_STOP1    ; stop if newline char
    ADD, R1, R1, 1          ; increment R1 = curr ++
    BR RIGHT_LOOP1          ; return to loop

RIGHT_LOOP_STOP1 
    ADD, R1, R1, -1     ; decrement R2 = cur --

    ADD, R3, R1, 0      ; R3 = end, end = curr ;; keep track of last char address

RIGHT_LOOP2
    LDR, R2, R3, 0          ; read last char in R2  ;; reusing R2
    LD, R4, ASCII_SPACE_3   ; load space char in R4
    NOT, R4, R4             ; negate value
    ADD, R4, R4, 1
    ADD, R4, R2, R4         ; check if char is space
    BRnp RIGHT_LOOP_STOP2   ; if not space, break loop
    
    RIGHT_LOOP3 
        NOT, R0, R0          ; negate start to make it negative
        ADD, R0, R0, 1
        ADD, R1, R1, r0      ; check if curr = start
        BRz RIGHT_LOOP_STOP3 ; stop when curr = start
        
        NOT, R0, R0          ; make start positive
        ADD, R0 ,R0, 1
        ADD, R1, R1, R0      ; add start back to curr
                             ; basically we are doing: mem[curr] = mem[curr - 1] from pseudocode
        LDR, R2, R1, -1      ; load mem[curr - 1] into R2
        STR, R2, R1, 0       ; mem[curr] = r2
        
        ADD, R1, R1, -1      ; decrement R1, curr --
    BR RIGHT_LOOP3

RIGHT_LOOP_STOP3
    NOT, R0, R0             ; negate start to make it positive again
    ADD, R0 ,R0, 1
    ADD, R1, R1, R0         ; curr = curr + start (adding start back to curr)
    LD, R4, ASCII_SPACE_3   ; load space char in R4
    STR, R4, R1, 0          ; mem[curr] = r4 # from pseudocode
    ADD, R1, R3, 0          ; curr = end     # from pseudocode
BR RIGHT_LOOP2              ; return to main loop

RIGHT_LOOP_STOP2

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
    ADD R1, R0, 0               ; use R1 as buffer pointer

GET_IN_WHILE 
    GETC                        ; get char from console and store to R0
    OUT                         ; print char in R0
    STR R0, R1, 0               ; store char at buffer pointer
    
    LD R2, ASCII_DOLLAR_SIGN    ; load $ char in R2
    NOT R2, R2                  ; compare char to $
    ADD R2, R2, 1
    ADD R2, R0, R2              ; check if char = $
    BRnp GET_IN_SKIP            ; if not found skip | if found continue
    
    LD R2, ASCII_DOLLAR_SIGN    ; load $ char in R2
    NOT R2, R2                  ; negate char ascii value
    ADD R2, R2, 1
    ADD R3, R1, -1              ; R3 = buffer_ptr - 1
    LDR R4, R3, 0               ; R4 = mem[buffer_ptr - 1]
    ADD R4, R2, R4              ; check if char = $
    BRnp GET_IN_SKIP            ; if not found skip | if found continue
    
    STR R4, R3, 0               ; set mem[bf - 1] = 0
    BR FOUND_CHAR
    
    GET_IN_SKIP 
        ADD R1, R1, 1           ; increment buffer pointer
        
    BR GET_IN_WHILE
    
FOUND_CHAR
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

ADD R6, R6, -1;                 ; save ret address on stack
STR R7, R6, 0;                  ; store R7 on stack
    LD R0, BUFFER_1             ; load buffer address into R0
    LD R3, GETINPUT_ADDR        ; load getinput address into R3
    JSRR R3                     ; jump to R# to get input instruction
    
    LD R0, ASCII_NEWLINE_6      ; load newline char into R0
    OUT                         ; print out char in R0
    
    LD R0, BUFFER_1             ; R0 = x8000
    LD R1, BUFFER_2             ; R1 = x8500
    LD R3, PARSELINES_ADDR      ; R3 = address of parselines
    JSRR R3                     ; jump to parselines instruction
    
    LD R4, BUFFER_2             ; start of currline = x8500
    ST R4, TEMP                 ; store address in block
    
    LEA R0, OPTIONS_MSG         ; R0 = string addrs of PUTS
    PUTS
    
    FIRST_WHILE_LOOP 
        GETC                    ; get character from console -> stored in R0 by default
        
        LD R2, ASCII_ZERO       ; R2 = zero character
        NOT R2, R2              ; negate ascii value
        ADD R2, R2, 1
        ADD R2, R2, R0          ; check if 0
        BRz PASS  
        
        LD R2, ASCII_ONE        ; load ascii value of 1
        NOT R2, R2              ; negate value
        ADD R2, R2, 1
        ADD R2, R2, R0          ; check if option 1
        BRz ELIF1               ; go to elif 1
        
        LD R2, ASCII_TWO        ; load ascii value of char 2
        NOT R2, R2              ; negate
        ADD R2, R2, 1
        ADD R2, R2, R0          ; check if option 2
        BRz ELIF2               ; go to elif 2
        
        LD R2, ASCII_THREE       ; load ascii value of char 3
        NOT R2, R2               ; negate
        ADD R2, R2, 1
        ADD R2, R2, R0          ; check if option 3
        BRz ELIF3               ; go to elif 3
        
        BR FIRST_WHILE_LOOP     ; loop back to first while loop
        
    ELIF1
        ADD R0, R4, 0           ; load curr address to R4
        
        ADD R6, R6, -1          ; save values of existing registers on the stack
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
        ADD R6, R6, -1
        STR R7, R6, 0
        
        LD R3, CAPITALIZE_ADDR  ; R3 = capitalizer subroutine address
        JSRR R3                 ; jump to subroutine
        
        LDR R7, R6, 0
        ADD R6, R6, 1
        LDR R5, R6, 0           ; restore previous values of registers
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
        
        BR PASS
        
    ELIF2
        ADD R0, R4, 0       ; load curr address from block
        
        ADD R6, R6, -1      ; save values of existing registers on the stack
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
        ADD R6, R6, -1
        STR R7, R6, 0
        
        LD R3, REVERSE_ADDR ; R3 = reverse subroutine address
        JSRR R3             ; jump to subroutine
        
        LDR R7, R6, 0
        ADD R6, R6, 1
        LDR R5, R6, 0       ; restore previous values of registers
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
        
        BR PASS
        
    ELIF3
        ADD R0, R4, 0     ; load curr address from block
        
        ADD R6, R6, -1    ; save values of existing registers on the stack
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
        ADD R6, R6, -1
        STR R7, R6, 0
        
        LD R3, RIGHT_JUSTIFY_ADDR   ; R3 = justify right subroutine address
        JSRR R3                     ; jump to subroutine
        
        LDR R7, R6, 0
        ADD R6, R6, 1
        LDR R5, R6, 0               ; restore previous values of registers
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
        
        BR PASS
    
    PASS
       LD R4, TEMP                        ; load curr address
       AND R2, R2, 0                      ; initialise R2. i = 0
        
        SECOND_WHILE_LOOP
            AND R1, R1, 0
            ADD R1, R1, -9                ; while loop: check if i < 9
            ADD R1, R2, R1
            BRzp END_SECOND_WHILE_LOOP    ; check if i <= 9
            
            LDR R0, R4, 0                 ; curr address
            ; BRz END_FIRST_WHILE_LOOP      ; exit of null character
            OUT                           ; out char to console
            
            ADD R4, R4, 1                 ; curr++
            ADD R2, R2, 1                 ; i++
            BR SECOND_WHILE_LOOP          ; loop back to this while loop
            
        END_SECOND_WHILE_LOOP
            ADD R2, R4, 0
            ADD R2, R2, -1          ; R2 = [curr - 1]
            LDR R2, R2, 0           ; check if mem[curr-1] is \0
            ST R4, TEMP
            
            BRnp FIRST_WHILE_LOOP   ; if not null
    
END_FIRST_WHILE_LOOP
   
LDR, R7, R6, 0;
ADD R6, R6, 1;    

RET

TEMP .blkw 1
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