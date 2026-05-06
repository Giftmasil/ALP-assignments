; ============================================================================
; 05_comparisons.asm — CMP and Conditional Jumps (64-bit)
; ============================================================================
;
; Build & Run:
;   ./build.sh 05_comparisons 64
;
; This program asks for a number (0-9) and tells you if it's:
;   - Equal to 5
;   - Greater than 5
;   - Less than 5
;
; Think of it like this Python code:
;   num = int(input("Enter a number: "))
;   if num == 5:
;       print("Equal to 5!")
;   elif num > 5:
;       print("Greater than 5!")
;   else:
;       print("Less than 5!")
; ============================================================================

section .data
    prompt db "Enter a number (0-9): "
    prompt_len equ $ - prompt

    msg_equal db "Equal to 5!", 10
    msg_equal_len equ $ - msg_equal

    msg_greater db "Greater than 5!", 10
    msg_greater_len equ $ - msg_greater

    msg_less db "Less than 5!", 10
    msg_less_len equ $ - msg_less

    newline db 10

section .bss
    input resb 2            ; digit + newline

section .text
    global _start

_start:
    ; Print prompt
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt
    mov rdx, prompt_len
    syscall

    ; Read input
    mov rax, 0
    mov rdi, 0
    mov rsi, input
    mov rdx, 2
    syscall

    ; Convert ASCII to number
    mov al, [input]
    sub al, '0'            ; al now holds the actual number (0-9)

    ; ================================================================
    ; CMP + JUMPS
    ;
    ; cmp al, 5 asks: "how does al compare to 5?"
    ; It sets flags internally but does NOT change al.
    ;
    ; Then the jump instruction reads those flags:
    ;   je  = jump if equal         (al == 5)
    ;   jg  = jump if greater       (al > 5)
    ;   jl  = jump if less          (al < 5)
    ;
    ; The logic: we check each condition and jump to the
    ; matching message. If a condition doesn't match, we
    ; "fall through" to the next check.
    ; ================================================================

    cmp al, 5               ; compare al with 5
    je .is_equal            ; if al == 5, jump to .is_equal
    jg .is_greater          ; if al > 5, jump to .is_greater
    jl .is_less             ; if al < 5, jump to .is_less

; ---- al == 5 ----
.is_equal:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_equal
    mov rdx, msg_equal_len
    syscall
    jmp .exit               ; IMPORTANT: jump to exit, otherwise we'd
                            ; "fall through" into .is_greater below!

; ---- al > 5 ----
.is_greater:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_greater
    mov rdx, msg_greater_len
    syscall
    jmp .exit

; ---- al < 5 ----
.is_less:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_less
    mov rdx, msg_less_len
    syscall
    jmp .exit               ; technically not needed since .exit is next,
                            ; but good habit for clarity

; ---- Exit ----
.exit:
    mov rax, 60
    mov rdi, 0
    syscall

; ============================================================================
; WHY jmp .exit IS IMPORTANT:
;
; Without it, after printing "Equal to 5!", the CPU would just keep going
; to the next line — which is .is_greater! It would print ALL messages.
;
; Labels don't create walls. They're just bookmarks. The CPU doesn't
; know they exist — it just executes the next instruction in memory.
; You must use jmp to skip over code you don't want to run.
;
; The flow for input = 5:
;   cmp al, 5       → flags say "equal"
;   je .is_equal    → YES, jump to .is_equal
;   print "Equal to 5!"
;   jmp .exit       → skip everything, go to exit
;
; The flow for input = 8:
;   cmp al, 5       → flags say "greater"
;   je .is_equal    → NO, don't jump, fall through
;   jg .is_greater  → YES, jump to .is_greater
;   print "Greater than 5!"
;   jmp .exit       → skip everything, go to exit
;
; The flow for input = 2:
;   cmp al, 5       → flags say "less"
;   je .is_equal    → NO, fall through
;   jg .is_greater  → NO, fall through
;   jl .is_less     → YES, jump to .is_less
;   print "Less than 5!"
;   jmp .exit       → go to exit
; ============================================================================