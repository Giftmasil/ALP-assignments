; ============================================================================
; 10_print_numbers.asm — Printing 2-digit (and larger) numbers
; ============================================================================
;
; Build & Run:
;   ./build.sh 10_print_numbers 64
;
; This program demonstrates:
;   1. Why add al, '0' only works for single digits (0–9)
;   2. How to print a 2-digit number using division
;   3. How to print ANY size number using the STACK trick
; ============================================================================

; ============================================================================
; THE PROBLEM WITH MULTI-DIGIT NUMBERS
;
; You already know this works for single digits:
;   mov al, 7
;   add al, '0'     ; al = 55 = ASCII '7'
;   print al        ; prints: 7
;
; But what about the number 47?
;   add al, '0'     ; 47 + 48 = 95 = ASCII '_'   ← WRONG, prints underscore
;
; The trick: use DIVISION to pull each digit off one at a time.
;
;   47 ÷ 10 = 4  remainder 7
;                ↑              ↑
;           tens digit      units digit
;
; So:
;   divide by 10 → quotient is TENS DIGIT, remainder is UNITS DIGIT
;   convert each to ASCII separately, print tens first then units
; ============================================================================

; ============================================================================
; THE STACK TRICK FOR ANY SIZE NUMBER
;
; For 3+ digit numbers, the digits come out in REVERSE order when dividing.
; Example: 385
;   385 ÷ 10 = 38  remainder 5   ← units digit (comes out FIRST)
;    38 ÷ 10 = 3   remainder 8   ← tens digit  (comes out SECOND)
;     3 ÷ 10 = 0   remainder 3   ← hundreds digit (comes out LAST)
;
; Stack to the rescue! The stack is LIFO (last in, first out).
; Push digits in the order they come out (5, 8, 3).
; Pop them off in reverse (3, 8, 5) — that's the correct print order!
;
;   PUSH 5  →  stack: [5]
;   PUSH 8  →  stack: [8, 5]
;   PUSH 3  →  stack: [3, 8, 5]
;
;   POP → 3  print '3'
;   POP → 8  print '8'
;   POP → 5  print '5'
;   Output: 385  ✓
; ============================================================================

section .data
    msg_two   db "Printing 47:  "
    msg_two_len equ $ - msg_two

    msg_three db "Printing 385: "
    msg_three_len equ $ - msg_three

    msg_sum   db "Sum of 38+25: "
    msg_sum_len equ $ - msg_sum

    newline db 10

section .bss
    digit resb 1            ; temporary space for one ASCII digit

section .text
    global _start

_start:

; ============================================================================
; EXAMPLE 1: Print a 2-digit number (47)
;
; Python equivalent:
;   n = 47
;   tens  = n // 10     # = 4
;   units = n % 10      # = 7
;   print(str(tens) + str(units))
; ============================================================================

    ; Print label first
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_two
    mov rdx, msg_two_len
    syscall

    ; Now split 47 into its digits
    mov rax, 47             ; the number
    xor rdx, rdx            ; clear rdx before dividing
    mov rbx, 10             ; divide by 10
    div rbx                 ; rax = 4 (quotient = tens digit)
                            ; rdx = 7 (remainder = units digit)

    ; Save units digit (rdx = 7) because we need to print tens first
    push rdx                ; stack: [7]

    ; Print tens digit (rax = 4)
    add al, '0'             ; 4 + 48 = 52 = ASCII '4'
    mov [digit], al
    mov rax, 1
    mov rdi, 1
    mov rsi, digit
    mov rdx, 1
    syscall

    ; Print units digit (pop it back from stack)
    pop rax                 ; rax = 7
    add al, '0'             ; 7 + 48 = 55 = ASCII '7'
    mov [digit], al
    mov rax, 1
    mov rdi, 1
    mov rsi, digit
    mov rdx, 1
    syscall

    ; Newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

; ============================================================================
; EXAMPLE 2: Print a 3-digit number (385) using the STACK TRICK
;
; This is the general algorithm that works for ANY size number:
;
;   digit_count = 0
;   while number != 0:
;       remainder = number % 10    ← extract last digit
;       push remainder             ← save it on stack (reversed order)
;       number = number // 10      ← remove last digit
;       digit_count += 1
;   for i in range(digit_count):
;       pop digit                  ← comes out in correct order now!
;       print(chr(digit + 48))
; ============================================================================

    ; Print label
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_three
    mov rdx, msg_three_len
    syscall

    ; Set up the number and counter
    mov r12, 385            ; the number to print (stored in r12 to survive loops)
    mov r13, 0              ; digit counter (how many digits we've pushed)

    ; ---- PHASE 1: Extract digits and push onto stack ----
.extract_loop:
    cmp r12, 0              ; is the number zero?
    je .print_loop          ; yes → all digits extracted, go print them

    mov rax, r12            ; put current number into rax for division
    xor rdx, rdx            ; clear rdx
    mov rbx, 10
    div rbx                 ; rax = number ÷ 10
                            ; rdx = number % 10  ← this is the LAST digit

    push rdx                ; push the digit onto the stack
    inc r13                 ; count one more digit

    mov r12, rax            ; update number (remove the last digit we just extracted)
    jmp .extract_loop       ; go back and extract the next digit

    ; After the loop for 385:
    ; Stack (top to bottom): [3, 8, 5]   ← 5 pushed first, 3 pushed last
    ; r13 = 3                             ← we pushed 3 digits

    ; ---- PHASE 2: Pop digits off stack and print ----
.print_loop:
    cmp r13, 0              ; have we printed all digits?
    je .done_385            ; yes → done

    pop rax                 ; pop the TOP digit (comes out in correct order: 3, then 8, then 5)
    add al, '0'             ; convert to ASCII
    mov [digit], al

    push r13                ; ── save counter before syscall clobbers registers ──
    mov rax, 1
    mov rdi, 1
    mov rsi, digit
    mov rdx, 1
    syscall
    pop r13                 ; ── restore counter ──

    dec r13                 ; one fewer digit to print
    jmp .print_loop

.done_385:
    ; Newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

; ============================================================================
; EXAMPLE 3: Add two 2-digit numbers and print the result
; 38 + 25 = 63
;
; Python equivalent:
;   result = 38 + 25   # = 63
;   print(result)
; ============================================================================

    ; Print label
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_sum
    mov rdx, msg_sum_len
    syscall

    ; Do the addition
    mov rax, 38
    add rax, 25             ; rax = 63

    ; Use the same stack trick to print it
    mov r12, rax
    mov r13, 0

.extract_sum:
    cmp r12, 0
    je .print_sum
    mov rax, r12
    xor rdx, rdx
    mov rbx, 10
    div rbx
    push rdx
    inc r13
    mov r12, rax
    jmp .extract_sum

.print_sum:
    cmp r13, 0
    je .done_sum
    pop rax
    add al, '0'
    mov [digit], al
    push r13
    mov rax, 1
    mov rdi, 1
    mov rsi, digit
    mov rdx, 1
    syscall
    pop r13
    dec r13
    jmp .print_sum

.done_sum:
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

; ============================================================================
; EXIT
; ============================================================================
    mov rax, 60
    xor rdi, rdi
    syscall

; ============================================================================
; SUMMARY: The Print-Any-Number Pattern
;
; Whenever you need to print a number (no matter how big):
;
;   mov r12, <your_number>      ; put number in a safe register
;   mov r13, 0                  ; digit counter = 0
;
;   ; Phase 1 — extract digits (push them reversed onto stack)
;   .extract:
;       cmp r12, 0
;       je .print
;       mov rax, r12
;       xor rdx, rdx
;       mov rbx, 10
;       div rbx
;       push rdx                ; push remainder (last digit)
;       inc r13
;       mov r12, rax
;       jmp .extract
;
;   ; Phase 2 — pop digits (now in correct order) and print
;   .print:
;       cmp r13, 0
;       je .done
;       pop rax
;       add al, '0'
;       mov [digit], al         ; digit is a 1-byte variable in .bss
;       ; ... syscall to print digit ...
;       dec r13
;       jmp .print
;   .done:
;
; This works for 1-digit, 2-digit, 10-digit — any number at all.
; ============================================================================