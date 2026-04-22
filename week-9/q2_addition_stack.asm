; q2_addition_stack.asm  Add 3 double-digit numbers using STACK parameter passing
; Build: ./build_c.sh week-9/q2_addition_stack

%include "utils.asm"

section .data
    prompt1 db "Enter first number: ", 0
    prompt2 db "Enter second number: ", 0
    prompt3 db "Enter third number: ", 0
    scan_fmt db "%d", 0
    result_fmt db "%d + %d + %d = %d", 10, 0

section .bss
    num1 resd 1
    num2 resd 1
    num3 resd 1

section .text
    extern printf, scanf
    global main
    default rel

main:
    functionStart
    push r12
    push r13
    push r14

    ; Read 3 numbers
    lea rdi, [prompt1]
    xor rax, rax
    call printf

    lea rdi, [scan_fmt]
    lea rsi, [num1]
    xor rax, rax
    call scanf

    lea rdi, [prompt2]
    xor rax, rax
    call printf

    lea rdi, [scan_fmt]
    lea rsi, [num2]
    xor rax, rax
    call scanf

    lea rdi, [prompt3]
    xor rax, rax
    call printf

    lea rdi, [scan_fmt]
    lea rsi, [num3]
    xor rax, rax
    call scanf

    ; Save inputs for printing
    mov r12d, [num1]
    mov r13d, [num2]
    mov r14d, [num3]

    ; Push arguments onto the stack (RIGHT TO LEFT to add in order)
    push qword [num3]       ; 3rd arg pushed first
    push qword [num2]       ; 2nd arg pushed second
    push qword [num1]       ; 1st arg pushed last (closest to top)
    call add_three_stack
    add rsp, 24             ; clean up: 3 args × 8 bytes = 24

    ; Print result
    lea rdi, [result_fmt]
    mov esi, r12d
    mov edx, r13d
    mov ecx, r14d
    mov r8, rax
    xor rax, rax
    call printf

    pop r14
    pop r13
    pop r12
    functionEnd
    xor rax, rax
    ret

; Stack after functionStart:
;   [rbp + 32] = c (pushed first)
;   [rbp + 24] = b
;   [rbp + 16] = a (pushed last)
;   [rbp + 8]  = return address - this should not be touched
;   [rbp]      = saved rbp
; Returns: rax = a + b + c
add_three_stack:
    functionStart
    mov rax, [rbp + 16]     ; 1st arg
    add rax, [rbp + 24]     ; + 2nd arg
    add rax, [rbp + 32]     ; + 3rd arg
    functionEnd
    ret

section .note.GNU-stack noalloc noexec nowrite progbits