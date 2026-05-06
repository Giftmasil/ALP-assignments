%define SYSEXIT 60
%define SYSREAD 0
%define STDIN 0
%define SYSWRITE 1
%define STDOUT 1

%macro print_string 2
push rax
push rdi
push rsi
push rdx
push rbx

mov rax, SYSWRITE
mov rdi, STDOUT
mov rsi, %1
mov rdx, %2
syscall

pop rbx
pop rdx
pop rsi
pop rdi
pop rax
%endmacro

%macro print_integer 1
push rax
push rdi
push rsi
push rdx
push rbx

add byte [temp_buffer], 48

mov rax, SYSWRITE
mov rdi, STDOUT
mov rsi, temp_buffer
mov rdx, 1
syscall

pop rbx
pop rdx
pop rsi
pop rdi
pop rax
%endmacro

%macro print_newline 0
mov rax, SYSWRITE
mov rdi, STDOUT
mov rsi, newline
mov rdx, 1
syscall
%endmacro

section .data
    prompt1 db "Enter first number: "
    prompt1_len equ $ - prompt1

    prompt2 db "Enter second number: "
    prompt2_len equ $ - prompt2

    answer db "The multiplication is: "
    answer_len equ $ - answer

    newline db 10

section .bss
    temp_buffer resb 1
    num1 resb 2
    num2 resb 2

section .text
    global _start

_start:
    ;prompt user
    print_string prompt1, prompt1_len

    mov rax, SYSREAD
    mov rdi, STDIN
    mov rsi, num1
    mov rdx, 2
    syscall


    print_string prompt2, prompt2_len

    mov rax, SYSREAD
    mov rdi, STDIN
    mov rsi, num2
    mov rdx, 2
    syscall

    ;convert to normal values from ascii
    mov al, [num1]
    sub al, 48
    mov bl, [num2]
    sub bl, 48

    call multiply

    mov byte [temp_buffer], al

    print_string answer, answer_len

    print_integer temp_buffer

    print_newline

    mov rax, SYSEXIT
    xor rdi, rdi
    syscall

multiply: 
    push rbp
    mov rbp, rsp

    imul bl
    
    pop rbp
    ret
