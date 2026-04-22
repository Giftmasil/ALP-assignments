; q3_multiplication_register.asm — Multiply 3 double-digit numbers using REGISTERS
; Build: ./build_c.sh week-9/q3_multiplication_register
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
    sub rsp, 8              ; align stack (3 pushes = odd, need this)

    ;read 3 numbers
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


    mov r12d, [num1]
    mov r13d, [num2]
    mov r13d, [num3]

    mov edi, r12d
    mov esi, r13d
    mov edx, r14d
    call multiply

    lea rdi, [result_fmt]
    mov esi, r12d
    mov edx, r13d
    mov ecx, r14d
    mov r8, rax
    xor rax, rax
    call printf

    add rsp, 8              ; undo alignment for calls
    pop r14
    pop r13
    pop r12
    functionEnd
    xor rax, rax
    ret

.multiply:
    functionStart
    mov rax, rdi
    imul rax, rsi
    imul rax, rdx
    functionEnd
    ret

section .note.GNU-stack noalloc noexec nowrite progbits