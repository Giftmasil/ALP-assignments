; ============================================================================
; 13_using_macros.asm — Using the macro library in a real program
; ============================================================================
;
; Build & Run:
;   ./build.sh 13_using_macros 64
;
; This program:
;   - Asks for two numbers
;   - Prints their sum, difference, product, quotient and remainder
;   - Uses macros for ALL printing and input — compare how clean the code is!
;
; BEFORE macros — printing "Hello" needed 4 lines every time:
;   mov rax, 1
;   mov rdi, 1
;   mov rsi, msg
;   mov rdx, msg_len
;   syscall
;
; AFTER macros — one line:
;   print msg, msg_len
; ============================================================================

%include "macro_lib.asm"        ; pull in all our macros

; ============================================================================
; HOW %include WORKS:
;
; NASM literally reads macro_lib.asm and pastes its entire contents
; here before assembling. It's like copy-pasting that file to this spot.
; This is why the macros are available everywhere below.
;
; Both files must be in the SAME folder when you build.
; ============================================================================

section .data
    prompt1     db "Enter first number:  "
    prompt1_len equ $ - prompt1

    prompt2     db "Enter second number: "
    prompt2_len equ $ - prompt2

    msg_sum     db "Sum:       "
    msg_sum_len equ $ - msg_sum

    msg_diff    db "Difference: "
    msg_diff_len equ $ - msg_diff

    msg_prod    db "Product:   "
    msg_prod_len equ $ - msg_prod

    msg_quot    db "Quotient:  "
    msg_quot_len equ $ - msg_quot

    msg_rem     db "Remainder: "
    msg_rem_len equ $ - msg_rem

section .bss
    input1  resb 4
    input2  resb 4

section .text
    global _start

_start:

; ---- Read first number ----
    println prompt1, prompt1_len    ; print prompt + newline (one line!)
    read input1, 4                  ; read up to 4 bytes from keyboard

; ---- Read second number ----
    println prompt2, prompt2_len
    read input2, 4

; ---- Convert input1 (ASCII string) to integer in r12 ----
;     e.g. user typed "12" → r12 = 12
    mov r12, 0
    mov r14, input1
%%cvt1:
    movzx rax, byte [r14]
    cmp al, 10
    je %%cvt1_done
    cmp al, 13
    je %%cvt1_done
    sub al, '0'
    imul r12, r12, 10
    add r12, rax
    inc r14
    jmp %%cvt1
%%cvt1_done:

; ---- Convert input2 to integer in r13 ----
    mov r13, 0
    mov r14, input2
%%cvt2:
    movzx rax, byte [r14]
    cmp al, 10
    je %%cvt2_done
    cmp al, 13
    je %%cvt2_done
    sub al, '0'
    imul r13, r13, 10
    add r13, rax
    inc r14
    jmp %%cvt2
%%cvt2_done:

; ---- SUM ----
    print msg_sum, msg_sum_len
    mov r15, r12
    add r15, r13                ; r15 = r12 + r13
    print_num r15               ; print the result
    newline

; ---- DIFFERENCE ----
    print msg_diff, msg_diff_len
    mov r15, r12
    sub r15, r13                ; r15 = r12 - r13
    ; Note: if r15 is negative, print_num won't work right (it's for positives)
    ; For now we just print — you could add a neg check like in 06_neg_and_signs
    print_num r15
    newline

; ---- PRODUCT ----
    print msg_prod, msg_prod_len
    mov rax, r12
    imul rax, r13               ; rax = r12 × r13
    mov r15, rax
    print_num r15
    newline

; ---- QUOTIENT AND REMAINDER ----
    print msg_quot, msg_quot_len
    mov rax, r12
    xor rdx, rdx                ; ALWAYS clear rdx before div!
    div r13                     ; rax = quotient, rdx = remainder
    mov r15, rax
    push rdx                    ; save remainder before print_num uses rdx
    print_num r15
    newline

    print msg_rem, msg_rem_len
    pop r15                     ; get remainder back
    print_num r15
    newline

; ---- Exit ----
    exit                        ; one word instead of 3 lines!

; ============================================================================
; NOTICE HOW MUCH CLEANER THIS IS:
;
; Without macros, every print would be:
;   mov rax, 1
;   mov rdi, 1
;   mov rsi, msg_sum
;   mov rdx, msg_sum_len
;   syscall
;   (4 lines × 10+ prints = 40+ lines of noise)
;
; With macros:
;   print msg_sum, msg_sum_len
;   (1 line — and it reads like English)
;
; With macros, you read the LOGIC of the program.
; Without macros, you read the MECHANICS of the computer.
; ============================================================================