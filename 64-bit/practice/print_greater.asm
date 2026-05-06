extern printf
global main
default rel

section .data
    nums db 4, 7, 2, 9, 1 
    output db "Numbers greater than 5: %d", 10, 0

section .text
main:
    push rbp
    mov rbp, rsp

    ;count to 0
    xor r12, r12
    mov rcx, 5
    mov rax, nums

.counter:
    cmp byte [rax], 5
    jle .skip_add     
    
    inc r12            

.skip_add:
    inc rax            
    loop .counter      

.finish:
    ;print answer
    lea rdi, [output]
    mov rsi, r12
    xor rax, rax
    sub rsp, 8
    call printf
    add rsp, 8

    pop rbp
    xor rax, rax
    ret

section .note.GNU-stack noalloc noexec nowrite progbits