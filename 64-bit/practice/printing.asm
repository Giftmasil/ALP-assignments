%define SYSEXIT 60
%define SYSREAD 0
%define STDIN 0
%define SYSWRITE 1
%define STDOUT 1

section .data
    sentence db "Assembly is fun!", 
    sentence_length equ $ - sentence

    newline db 10


section .text
    global _start

_start:
    ;Print
    mov rax, SYSWRITE
    mov rdi, STDOUT
    mov rsi, sentence
    mov rdx, sentence_length
    syscall

    mov rax, SYSWRITE
    mov rdi, STDOUT
    mov rsi, newline
    mov rdx, 1
    syscall

.exit:
    mov rax, SYSEXIT
    xor rdx, rdx
    syscall
