%include "utils.asm"

section .data
    prompt db "Enter the base: ", 0
    power_prompt db "Enter the exponent: ", 0
    read db "%d", 0
    result_msg db "The power of %d to %d is %d", 10, 0

section .bss
    base resd 1
    exponent resd 1

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
    lea rsi, [base]
    xor rax, rax
    sub rsp, 8
    call scanf
    add rsp, 8

    lea rdi, [power_prompt]
    xor rax, rax
    sub rsp, 8
    call printf
    add rsp, 8

    lea rdi, [read]
    lea rsi, [exponent]
    xor rax, rax
    sub rsp, 8
    call scanf
    add rsp, 8  


    mov esi, dword [base]  
    mov edi, dword [exponent]

    call power

    lea rdi, [result_msg]
    mov esi, [base]
    mov rdx, [exponent]
    mov rcx, rax
    xor rax, rax
    sub rsp, 8
    call printf
    add rsp, 8

    pop r12                     
    functionEnd                
    xor rax, rax
    ret


power:
    push rbp
    mov rbp, rsp
    push rbx

    mov rbx, rsi

    cmp rdi, 0
    je .base_case

    dec rdi
    call power

    imul rax, rbx 
    jmp .done 

.base_case:
    mov rax, 1

.done:
    pop rbx            
    pop rbp
    ret            

section .note.GNU-stack noalloc noexec nowrite progbits