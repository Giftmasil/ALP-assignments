extern printf
global main
default rel


section .data
    a dd 45
    b dd 9
    fmt_string db "%d / %d = %d remainder %d", 10, 0

section .text
main:
    push rbp
    mov rbp, rsp

    ;division
    mov eax, [a]
    cdq
    idiv dword [b]
    mov r12d, edx

    lea rdi, [fmt_string]
    mov esi, [a]
    mov edx, [b]
    mov ecx, eax
    mov r8d, r12d
    xor rax, rax
    sub rsp, 8
    call printf
    add rsp, 8

    pop rbp
    xor rax, rax
    ret

section .note.GNU-stack noalloc noexec nowrite progbits