section .data
    num db '1', '2', '3', '4'
    newline db 10   
            

section .text
    global _start

_start:
    mov rax, 1
    mov rdi, 1
    mov rsi, num + 3
    mov rdx, 1
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, newline 
    mov rdx, 1
    syscall

    mov rax, 60
    mov rdi, 0
    syscall