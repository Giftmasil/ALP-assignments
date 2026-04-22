%include "utils.asm"

extern printf, scanf
global main
default rel

section .text
main:
    functionStart
    saveCalleeSaved

    ; Ask for input
    lea rdi, [prompt]
    xor rax, rax
    sub rsp, 8
    call printf
    add rsp, 8

    lea rdi, [scan_fmt]
    lea rsi, [num]
    xor rax, rax
    sub rsp, 8
    call scanf
    add rsp, 8


    xor rdi, rdi
    mov edi, [num]
    mov ebx, edi            

    call triangular

    mov [result], eax       


    lea rdi, [msg]
    mov esi, ebx            
    mov edx, [result]       
    xor rax, rax
    sub rsp, 8
    call printf
    add rsp, 8

    retriveCalleeSaved
    functionEnd
    xor rax, rax
    ret

triangular:
    functionStart

    mov rcx, rdi            
    xor rax, rax            

    cmp rcx, 0
    je .done                

.add_loop:
    add rax, rcx            
    dec rcx                 
    cmp rcx, 0
    jg .add_loop           

.done:
    functionEnd
    ret

section .data
    prompt db "Enter a number: ", 0
    scan_fmt db "%d", 0
    msg db "Triangular of %d is %d", 10, 0

section .bss
    num resd 1
    result resd 1

section .note.GNU-stack noalloc noexec nowrite progbits