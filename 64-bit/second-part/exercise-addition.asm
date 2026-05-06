section .data
    prompt1 db "What is your first number: "
    prompt1_len equ $ - prompt1

    prompt2 db "What is your second number: "
    prompt2_len equ $ - prompt2          

    prompt3 db "The sum is: "
    prompt3_len equ $ - prompt3          

    newline db 10
    sys_exit equ 60
    sys_read equ 0
    stdin equ 0
    sys_write equ 1
    stdout equ 1

section .bss
    num1 resb 2                         
    num2 resb 2                          
    answer resb 1

section .text
    global _start

_start:
    ; Print prompt 1
    mov rax, sys_write
    mov rdi, stdout
    mov rsi, prompt1
    mov rdx, prompt1_len
    syscall

    ; Read first number
    mov rax, sys_read
    mov rdi, stdin
    mov rsi, num1
    mov rdx, 2                           
    syscall                              

    ; Print prompt 2
    mov rax, sys_write                  
    mov rdi, stdout
    mov rsi, prompt2
    mov rdx, prompt2_len
    syscall

    ; Read second number
    mov rax, sys_read
    mov rdi, stdin
    mov rsi, num2
    mov rdx, 2                           
    syscall

    mov al, [num1]
    sub al, 48
    mov [num1], al                       

    mov al, [num2]
    sub al, 48
    mov [num2], al                       


    mov al, [num1]                       
    add al, [num2]
    mov [answer], al                     

    mov al, [answer]                     
    add al, 48
    mov [answer], al                    

    ; Print "The sum is: "
    mov rax, sys_write
    mov rdi, stdout
    mov rsi, prompt3
    mov rdx, prompt3_len
    syscall

    ; Print the answer
    mov rax, sys_write
    mov rdi, stdout
    mov rsi, answer
    mov rdx, 1
    syscall

    ; Print newline
    mov rax, sys_write
    mov rdi, stdout
    mov rsi, newline
    mov rdx, 1
    syscall

    mov rax, sys_exit
    xor rdi, rdi
    syscall

