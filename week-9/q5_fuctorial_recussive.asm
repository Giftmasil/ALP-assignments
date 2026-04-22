%include "utils.asm"

section .data
    prompt db "Enter a number: ", 0
    read db "%d", 0
    result_msg db "Factorial of %d is %d", 10, 0

section .bss
    number resd 1

section .text
    extern printf, scanf
    global main
    default rel

main:
    functionStart
    push r12                    

    lea rdi, [prompt]
    xor rax, rax
    sub rsp, 8
    call printf
    add rsp, 8

    lea rdi, [read]
    lea rsi, [number]
    xor rax, rax
    sub rsp, 8
    call scanf
    add rsp, 8

    xor rdi, rdi
    mov edi, [number]
    mov r12d, edi

    call factorial

    lea rdi, [result_msg]
    mov esi, r12d
    mov rdx, rax
    xor rax, rax
    sub rsp, 8
    call printf
    add rsp, 8

    pop r12                     
    functionEnd                
    xor rax, rax
    ret


factorial:
    push rbp
    mov rbp, rsp
    push rbx               

    mov rax, rdi            ; rax = n (parameter in rdi)
    cmp rdi, 0
    je .base_case           

    mov rbx, rdi            ; save n in rbx (survives the recursive call)
    dec rdi                 ; rdi = n - 1
    call factorial          ; rax = factorial(n - 1)
    imul rax, rbx           ; rax = factorial(n - 1) * n
    jmp .done

.base_case:
    mov rax, 1              ; return 1 since it continues to .done

.done:
    pop rbx                 
    pop rbp
    ret               

section .note.GNU-stack noalloc noexec nowrite progbits