; q1_addition_register.asm - Add 3 double-digit numbers using REGISTER parameter passing
; Build: ./build_c.sh week-9/q1_addition_register
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
    sub rsp, 8              ; align stack (3 pushes = odd)

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

    ; Save inputs for printing later
    mov r12d, [num1]
    mov r13d, [num2]
    mov r14d, [num3]

    ; Call add_three with parameters in REGISTERS
    mov edi, r12d
    mov esi, r13d
    mov edx, r14d
    call add_three

    ; Print result
    lea rdi, [result_fmt]
    mov esi, r12d
    mov edx, r13d
    mov ecx, r14d
    mov r8, rax
    xor rax, rax
    call printf

    add rsp, 8              ; undo the alignment
    pop r14
    pop r13
    pop r12
    functionEnd
    xor rax, rax
    ret

; Parameters: rdi = a, rsi = b, rdx = c
add_three:
    functionStart
    mov rax, rdi
    add rax, rsi
    add rax, rdx
    functionEnd
    ret

section .note.GNU-stack noalloc noexec nowrite progbits