; ============================================================================
; 07_loops.asm — Loops in Assembly (64-bit)
; ============================================================================
;
; Build & Run:
;   ./build.sh 07_loops 64
;
; This program demonstrates three ways to loop:
;   1. Manual loop with jmp (like a while loop)
;   2. Manual loop with cmp + jne (like a for loop)
;   3. The LOOP instruction (automatic counter with rcx)
; ============================================================================

section .data
    ; Messages
    msg1 db "--- Method 1: Print 'A' five times using jmp ---", 10
    msg1_len equ $ - msg1

    msg2 db "--- Method 2: Count 1 to 5 using cmp + jne ---", 10
    msg2_len equ $ - msg2

    msg3 db "--- Method 3: Print 'X' three times using LOOP ---", 10
    msg3_len equ $ - msg3

    newline db 10

section .bss
    char resb 1             ; space to store a character for printing

section .text
    global _start

_start:

; ============================================================================
; METHOD 1: Manual loop with a counter and jmp
;
; This is like Python:
;   count = 5
;   while count > 0:
;       print('A')
;       count -= 1
;
; In assembly we:
;   1. Set a counter in a register
;   2. Do the work
;   3. Decrement the counter
;   4. Check if zero
;   5. If not zero, jump back to step 2
; ============================================================================

    ; Print header
    mov rax, 1
    mov rdi, 1
    mov rsi, msg1
    mov rdx, msg1_len
    syscall

    mov byte [char], 'A'   ; the character we want to print
    mov rcx, 5              ; counter = 5 (print 5 times)

.loop1:
    ; Save rcx before syscall (syscall can destroy rcx!)
    push rcx

    ; Print 'A'
    mov rax, 1
    mov rdi, 1
    mov rsi, char
    mov rdx, 1
    syscall

    ; Restore rcx
    pop rcx

    dec rcx                 ; rcx = rcx - 1
    cmp rcx, 0              ; is rcx zero yet?
    jne .loop1              ; if NOT zero, jump back to .loop1
                            ; if zero, fall through (loop ends)

    ; Print newline after the A's
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    ; Flow:
    ;   rcx=5 → print A → rcx=4 → not zero → jump back
    ;   rcx=4 → print A → rcx=3 → not zero → jump back
    ;   rcx=3 → print A → rcx=2 → not zero → jump back
    ;   rcx=2 → print A → rcx=1 → not zero → jump back
    ;   rcx=1 → print A → rcx=0 → IS zero  → fall through (done!)
    ;   Output: AAAAA

; ============================================================================
; METHOD 2: Counting loop (like a for loop)
;
; This is like Python:
;   for i in range(1, 6):
;       print(i)
;
; We use a register as a counter, convert each number to ASCII, print it
; ============================================================================

    ; Print header
    mov rax, 1
    mov rdi, 1
    mov rsi, msg2
    mov rdx, msg2_len
    syscall

    mov r12, 1              ; r12 = our counter, starting at 1
                            ; using r12 because syscall doesn't destroy it

.loop2:
    ; Convert counter to ASCII
    mov al, r12b            ; r12b is the low 8 bits of r12
    add al, '0'             ; convert number to ASCII character
    mov [char], al          ; store in memory for printing

    ; Print the digit
    mov rax, 1
    mov rdi, 1
    mov rsi, char
    mov rdx, 1
    syscall

    inc r12                 ; r12 = r12 + 1
    cmp r12, 6              ; have we reached 6?
    jl .loop2               ; if r12 < 6, keep looping
                            ; (jl = "jump if less")

    ; Print newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    ; Flow:
    ;   r12=1 → print '1' → r12=2 → 2 < 6? yes → loop
    ;   r12=2 → print '2' → r12=3 → 3 < 6? yes → loop
    ;   r12=3 → print '3' → r12=4 → 4 < 6? yes → loop
    ;   r12=4 → print '4' → r12=5 → 5 < 6? yes → loop
    ;   r12=5 → print '5' → r12=6 → 6 < 6? NO  → stop
    ;   Output: 12345

; ============================================================================
; METHOD 3: The LOOP instruction
;
; LOOP does THREE things automatically:
;   1. Decrements rcx by 1
;   2. Checks if rcx is zero
;   3. If not zero, jumps to the label
;
; So "loop .label" is shorthand for:
;   dec rcx
;   cmp rcx, 0
;   jne .label
;
; WARNING: LOOP always uses rcx. You don't get to pick.
; WARNING: syscall can destroy rcx! Always push/pop it.
; ============================================================================

    ; Print header
    mov rax, 1
    mov rdi, 1
    mov rsi, msg3
    mov rdx, msg3_len
    syscall

    mov byte [char], 'X'   ; character to print
    mov rcx, 3              ; loop 3 times

.loop3:
    push rcx                ; SAVE rcx (syscall will destroy it!)

    mov rax, 1
    mov rdi, 1
    mov rsi, char
    mov rdx, 1
    syscall

    pop rcx                 ; RESTORE rcx (so loop can decrement it)
    loop .loop3             ; rcx--, if rcx != 0, jump to .loop3

    ; Print newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    ; Output: XXX

; ============================================================================
; METHOD 4: Conditional loop instructions (LOOPE, LOOPNE, LOOPZ, LOOPNZ)
;
; These are variations of LOOP that also check the Zero Flag (ZF):
;
; ┌───────────────┬──────────────────────────────────────────────────┐
; │ Instruction   │ What it does                                     │
; ├───────────────┼──────────────────────────────────────────────────┤
; │ LOOPE/LOOPZ   │ rcx--, loop while rcx != 0 AND ZF = 1 (equal)   │
; │               │ Stops when: rcx = 0 OR ZF = 0 (not equal)       │
; │               │                                                  │
; │ LOOPNE/LOOPNZ │ rcx--, loop while rcx != 0 AND ZF = 0 (not eq) │
; │               │ Stops when: rcx = 0 OR ZF = 1 (equal/found!)   │
; └───────────────┴──────────────────────────────────────────────────┘
;
; LOOPE and LOOPZ are the same instruction (just two names).
; LOOPNE and LOOPNZ are the same instruction (just two names).
;
; These are useful for searching through arrays — you want to loop
; through elements but stop early if you find what you're looking for.
;
; IMPORTANT: The cmp (or any instruction that sets ZF) must come
;            RIGHT BEFORE the loop instruction!
;
; Python equivalent of LOOPNE (search for 'X' in a string):
;   text = "ABCDXFGH"
;   i = 0
;   while i < len(text) and text[i] != 'X':
;       i += 1
;   if text[i] == 'X':
;       print("Found it!")
; ============================================================================

    ; Print header
    mov rax, 1
    mov rdi, 1
    mov rsi, msg4
    mov rdx, msg4_len
    syscall

    ; --- LOOPNE example: Search for the letter 'X' in a string ---
    ; LOOPNE = "loop while NOT equal"
    ; It keeps looping as long as the comparison says "not equal"
    ; It stops when either we find what we want (equal) or run out of items

    mov rsi, search_str     ; rsi points to start of string
    mov rcx, search_len     ; rcx = how many characters to check

.search_loop:
    mov al, [rsi]           ; load current character into al
    inc rsi                 ; move pointer to next character
    cmp al, 'X'             ; compare with 'X'
                            ; if al == 'X', ZF = 1 (equal, found it!)
                            ; if al != 'X', ZF = 0 (not equal, keep looking)
    loopne .search_loop     ; rcx--, then check:
                            ;   rcx != 0 AND ZF == 0?  → keep looping
                            ;   rcx == 0 OR  ZF == 1?  → STOP

    ; WHY did the loop stop?
    ; Two possible reasons:
    ;   1. We found 'X' (ZF = 1 from the cmp)
    ;   2. We checked everything and ran out (rcx = 0)
    ;
    ; We use je to check: "did the LAST cmp find a match?"

    je .found               ; if ZF = 1 → we found 'X'!
    jmp .not_found          ; if ZF = 0 → never found it

.found:
    mov rax, 1
    mov rdi, 1
    mov rsi, found_msg
    mov rdx, found_msg_len
    syscall
    jmp .search_done

.not_found:
    mov rax, 1
    mov rdi, 1
    mov rsi, notfound_msg
    mov rdx, notfound_msg_len
    syscall

.search_done:

    ; Flow with "ABCDXFGH" (searching for 'X'):
    ;   rcx=8, al='A', cmp 'A','X' → ZF=0 (not equal) → loopne: rcx=7, keep going
    ;   rcx=7, al='B', cmp 'B','X' → ZF=0 (not equal) → loopne: rcx=6, keep going
    ;   rcx=6, al='C', cmp 'C','X' → ZF=0 (not equal) → loopne: rcx=5, keep going
    ;   rcx=5, al='D', cmp 'D','X' → ZF=0 (not equal) → loopne: rcx=4, keep going
    ;   rcx=4, al='X', cmp 'X','X' → ZF=1 (EQUAL!)    → loopne: rcx=3, STOP!
    ;   je .found → ZF=1 → YES → print "Found!"

    ; Print newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

; ============================================================================
; METHOD 5: LOOPE / LOOPZ example
;
; LOOPE = "loop while equal"
; Opposite of LOOPNE — keeps going while things ARE equal, stops when
; something is different.
;
; Use case: checking if all elements in an array are the same value.
;
; Python equivalent:
;   arr = [5, 5, 5, 5, 3, 5]
;   i = 0
;   while i < len(arr) and arr[i] == 5:
;       i += 1
;   if i < len(arr):
;       print("Found a different value!")
;   else:
;       print("All values are 5!")
; ============================================================================

    ; Print header
    mov rax, 1
    mov rdi, 1
    mov rsi, msg5
    mov rdx, msg5_len
    syscall

    mov rsi, check_arr      ; point to the array
    mov rcx, check_arr_len  ; number of elements to check

.check_loop:
    mov al, [rsi]           ; load current byte
    inc rsi                 ; move to next element
    cmp al, 5               ; is it equal to 5?
                            ; if yes, ZF = 1
                            ; if no,  ZF = 0
    loope .check_loop       ; rcx--, then check:
                            ;   rcx != 0 AND ZF == 1 (still equal)?  → keep looping
                            ;   rcx == 0 OR  ZF == 0 (found different)? → STOP

    je .all_same            ; if ZF = 1 → last element was also 5, all are same
    jmp .found_diff         ; if ZF = 0 → found something different

.all_same:
    mov rax, 1
    mov rdi, 1
    mov rsi, all_same_msg
    mov rdx, all_same_msg_len
    syscall
    jmp .check_done

.found_diff:
    mov rax, 1
    mov rdi, 1
    mov rsi, diff_msg
    mov rdx, diff_msg_len
    syscall

.check_done:

    ; Flow with [5, 5, 5, 3, 5, 5]:
    ;   rcx=6, al=5, cmp 5,5 → ZF=1 (equal)     → loope: rcx=5, keep going
    ;   rcx=5, al=5, cmp 5,5 → ZF=1 (equal)     → loope: rcx=4, keep going
    ;   rcx=4, al=5, cmp 5,5 → ZF=1 (equal)     → loope: rcx=3, keep going
    ;   rcx=3, al=3, cmp 3,5 → ZF=0 (DIFFERENT!) → loope: rcx=2, STOP!
    ;   je .all_same → ZF=0 → NO → jmp .found_diff → print "Found different!"

    ; Print newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

; ============================================================================
; EXIT
; ============================================================================

    mov rax, 60
    mov rdi, 0
    syscall

; ============================================================================
; ADDITIONAL DATA for Methods 4 and 5
; (placed here so it doesn't break the flow above)
; ============================================================================

section .data
    msg4 db "--- Method 4: Search for 'X' using LOOPNE ---", 10
    msg4_len equ $ - msg4

    msg5 db "--- Method 5: Check all equal using LOOPE ---", 10
    msg5_len equ $ - msg5

    search_str db "ABCDXFGH"
    search_len equ $ - search_str

    check_arr db 5, 5, 5, 3, 5, 5      ; the 3 breaks the pattern
    check_arr_len equ $ - check_arr

    found_msg db "Found 'X' in the string!", 10
    found_msg_len equ $ - found_msg

    notfound_msg db "Did not find 'X'", 10
    notfound_msg_len equ $ - notfound_msg

    all_same_msg db "All values are 5!", 10
    all_same_msg_len equ $ - all_same_msg

    diff_msg db "Found a different value!", 10
    diff_msg_len equ $ - diff_msg

; ============================================================================
; SUMMARY OF LOOP PATTERNS:
;
; Pattern 1 — While loop (do something N times):
;   mov rcx, N
;   .loop:
;       ; do work (save/restore rcx if needed)
;       dec rcx
;       cmp rcx, 0
;       jne .loop
;
; Pattern 2 — For loop (count from A to B):
;   mov r12, A
;   .loop:
;       ; do work with r12 as the counter
;       inc r12
;       cmp r12, B+1
;       jl .loop
;
; Pattern 3 — LOOP instruction:
;   mov rcx, N
;   .loop:
;       push rcx        ; if doing syscalls
;       ; do work
;       pop rcx
;       loop .loop
;
; ALL loops need an exit condition, or they run forever!
; ============================================================================