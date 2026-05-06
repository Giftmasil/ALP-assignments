section .data
    prompt db "Enter your name: "
    prompt_len equ $ - prompt
    newline db 10

    sys_exit equ 60
    sys_write equ 1
    stdout equ 1
    sys_read equ 0
    stdin equ 0

section .bss
    name resb 32            ; reserve 32 bytes for the user's name

section .text
    global _start

_start:
    ; Print "Enter your name: "
    mov rax, sys_write
    mov rdi, stdout
    mov rsi, prompt
    mov rdx, prompt_len
    syscall

    ; Read user input into the reserved space
    mov rax, sys_read       ; sys_read
    mov rdi, stdin          ; stdin (keyboard)
    mov rsi, name           ; WHERE to store what they type
    mov rdx, 32             ; read up to 32 bytes
    syscall
    ; rax now contains how many bytes were actually typed

    ; Print back what they typed
    mov rdx, rax            ; use the actual number of bytes read
    mov rax, sys_write
    mov rdi, stdout
    mov rsi, name           ; print from the same address we stored to
    syscall

    ; Exit
    mov rax, sys_exit
    xor rdi, rdi
    syscall