; ============================================================================
; 06_neg_and_signs.asm — NEG instruction and handling negative results
; ============================================================================
;
; Build & Run:
;   ./build.sh 06_neg_and_signs 64
;
; This program subtracts two single-digit numbers and correctly handles
; negative results by printing a minus sign.
;
; Examples:
;   7 - 3 = 4     (positive, prints "4")
;   3 - 7 = -4    (negative, prints "-4")
;   5 - 5 = 0     (zero, prints "0")
; ============================================================================

section .data
    prompt1 db "First number (0-9): "
    prompt1_len equ $ - prompt1

    prompt2 db "Second number (0-9): "
    prompt2_len equ $ - prompt2

    result_msg db "Result: "
    result_msg_len equ $ - result_msg

    minus db '-'                ; the minus character, stored in memory
    newline db 10

section .bss
    num1 resb 2
    num2 resb 2
    answer resb 1

section .text
    global _start

_start:
    ; ---- Read first number ----
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt1
    mov rdx, prompt1_len
    syscall

    mov rax, 0
    mov rdi, 0
    mov rsi, num1
    mov rdx, 2
    syscall

    ; ---- Read second number ----
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt2
    mov rdx, prompt2_len
    syscall

    mov rax, 0
    mov rdi, 0
    mov rsi, num2
    mov rdx, 2
    syscall

    ; ---- Convert both from ASCII to numbers ----
    mov al, [num1]
    sub al, '0'

    mov bl, [num2]
    sub bl, '0'

    ; ---- Subtract ----
    sub al, bl              ; al = num1 - num2
                            ; if num1=3, num2=7: al = -4
                            ; if num1=7, num2=3: al = 4

    ; ---- Print "Result: " ----
    ; IMPORTANT: al has our result, but syscall will destroy rax!
    ; So we must save al before the syscall.

    push rax                ; save our result on the stack

    mov rax, 1
    mov rdi, 1
    mov rsi, result_msg
    mov rdx, result_msg_len
    syscall

    pop rax                 ; restore our result back into rax/al

    ; ================================================================
    ; HANDLING NEGATIVE RESULTS
    ;
    ; Step 1: Check if al is negative
    ; Step 2: If negative → print '-' and flip al to positive with NEG
    ; Step 3: Convert the (now positive) number to ASCII and print
    ;
    ; NEG instruction:
    ;   neg al    →  al = 0 - al   (flips the sign)
    ;   -4 becomes 4
    ;    4 becomes -4
    ;    0 stays 0
    ; ================================================================

    cmp al, 0               ; is the result negative?
    jge .positive            ; if al >= 0, skip ahead to .positive
                            ; (jge = "jump if greater or equal")

    ; ---- Result is negative ----
    neg al                  ; flip -4 to 4 (so we can convert to ASCII)

    ; But we need to save al again because syscall destroys rax!
    push rax                ; save the positive version

    ; Print the minus sign
    mov rax, 1
    mov rdi, 1
    mov rsi, minus          ; points to '-' in .data
    mov rdx, 1
    syscall

    pop rax                 ; restore al (still has the positive number)

.positive:
    ; ---- Convert to ASCII and print ----
    ; At this point al is ALWAYS positive (or zero)
    ; whether the original result was negative or not

    add al, '0'            ; convert number to ASCII digit
    mov [answer], al        ; store in memory (rsi needs an address!)

    mov rax, 1
    mov rdi, 1
    mov rsi, answer
    mov rdx, 1
    syscall

    ; ---- Print newline ----
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    ; ---- Exit ----
    mov rax, 60
    mov rdi, 0
    syscall

; ============================================================================
; WALKTHROUGH: Input 3 and 7 (result = -4)
;
;   sub al, bl          → al = 3 - 7 = -4
;   cmp al, 0           → -4 < 0, flags say "less than"
;   jge .positive        → NO (not greater or equal), don't jump
;   neg al               → al = 4 (flipped from -4)
;   push rax             → save 4 on stack
;   syscall (print '-')  → screen shows: -
;   pop rax              → al = 4 again
;   .positive:
;   add al, '0'          → al = 52 (ASCII '4')
;   syscall (print '4')  → screen shows: -4
;
; WALKTHROUGH: Input 7 and 3 (result = 4)
;
;   sub al, bl          → al = 7 - 3 = 4
;   cmp al, 0           → 4 > 0, flags say "greater than"
;   jge .positive        → YES (greater or equal), JUMP to .positive
;   (skip neg and minus printing entirely)
;   .positive:
;   add al, '0'          → al = 52 (ASCII '4')
;   syscall (print '4')  → screen shows: 4
;
; WALKTHROUGH: Input 5 and 5 (result = 0)
;
;   sub al, bl          → al = 5 - 5 = 0
;   cmp al, 0           → 0 == 0, flags say "equal"
;   jge .positive        → YES (0 is >= 0), JUMP to .positive
;   .positive:
;   add al, '0'          → al = 48 (ASCII '0')
;   syscall (print '0')  → screen shows: 0
; ============================================================================