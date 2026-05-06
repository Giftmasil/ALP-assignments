%macro PRINT_NEWLINE 0
    mov rax, 1
    mov rdi, 1
    mov rsi, _newline
    mov rdx, 1
    syscall
%endmacro

%macro EXIT
    mov rax, 60
    xor rdi, rdi
    syscall
%endmacro