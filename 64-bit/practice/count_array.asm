extern printf
global main
default rel


section .data
    array db 1, 2, 3, 4, 5, 6, 7, 8, 9
    output db "The total numbers between 4 and 7 inclusive is: %d", 10 , 0

section .text
main:
    push rbp
    mov rbp, rsp

    mov rcx, 9
    xor r12, r12
    mov rax, array

.count:
    cmp byte [rax], 7
    jg .skip
    cmp byte [rax], 4
    jl .skip
    inc r12
    inc rax
    jmp .continue

.skip:
    inc rax

.continue:
    loop .count

.print_output:
    lea rdi, [output]
    mov rsi, r12
    xor rax, rax
    call printf

    pop rbp
    xor rax, rax
    ret