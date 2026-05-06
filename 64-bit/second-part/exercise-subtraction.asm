section .data
    prompt1 db "What is the first number: "
    prompt1_length equ $ - prompt1

    prompt2 db "What is the second number: "
    prompt2_length equ $ - prompt2

    minus db '-'
    newline db 10

    sysread equ 0
    stdin equ 0
    syswrite equ 1
    stdout equ 1
    sys_exit equ 60

section .bss
    num1 resb 2
    num2 resb 2
    answer resb 1

section .text
    global _start

_start:

    ; prompt1
    mov rax, syswrite
    mov rdi, stdout
    mov rsi, prompt1
    mov rdx, prompt1_length
    syscall

    ; read num1
    mov rax, sysread
    mov rdi, stdin
    mov rsi, num1
    mov rdx, 2
    syscall

    ; prompt2
    mov rax, syswrite
    mov rdi, stdout
    mov rsi, prompt2
    mov rdx, prompt2_length
    syscall

    ; read num2
    mov rax, sysread
    mov rdi, stdin
    mov rsi, num2
    mov rdx, 2
    syscall

    ; ASCII -> number
    mov al, [num1]
    sub al, 48
    mov bl, [num2]
    sub bl, 48

    ; subtraction: al = al - bl
    sub al, bl

    ; check if result is negative
    cmp al, 0
    jge .positive

    neg al

    push rax           

    ; print the minus sign
    mov rax, syswrite
    mov rdi, stdout
    mov rsi, minus
    mov rdx, 1
    syscall             

    pop rax             

.positive:
    add al, '0'         
    mov [answer], al

    ; print result
    mov rax, syswrite
    mov rdi, stdout
    mov rsi, answer
    mov rdx, 1
    syscall

    ; newline
    mov rax, syswrite
    mov rdi, stdout
    mov rsi, newline
    mov rdx, 1
    syscall

    ; exit
    mov rax, sys_exit
    xor rdi, rdi
    syscall