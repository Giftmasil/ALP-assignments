;i modified for it to ask from the user values and add them, i would like to practice that is why
extern printf, scanf
global main
default rel


section .data
    prompt_1 db "first number: ", 0
    prompt_2 db "second number: ", 0

    scan_fmt db "%lf", 0

    output db "%.2f + %.2f = %.2f", 10, 0



section .bss
    num1 resq 1
    num2 resq 1

section .text
main:
    push rbp
    mov rbp, rsp

    ;ask first number
    lea rdi, [prompt_1]
    xor rax, rax
    call printf

    lea rdi, [scan_fmt]
    lea rsi, [num1]
    xor rax, rax
    call scanf

    lea rdi, [prompt_2]
    xor rax, rax
    call printf

    lea rdi, [scan_fmt]
    lea rsi, [num2]
    xor rax, rax
    call scanf

    movsd xmm0, [num1]
    addsd xmm0, qword [num2]
    movsd xmm2, xmm0

    lea rdi, [output]
    movsd xmm0, qword [num1]
    movsd xmm1, qword [num2] 
    mov rax, 3
    call printf

    pop rbp
    xor rax, rax
    ret