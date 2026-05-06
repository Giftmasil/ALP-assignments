%define SYSWRITE 1
%define STDOUT 1
%define SYSREAD 0
%define STDIN 0
%define SYSEXIT 60

%macro print_string 2
    push rax
    push rdi
    push rsi
    push rdx

    mov rax, SYSWRITE
    mov rdi, STDOUT
    mov rsi, %1
    mov rdx, %2
    syscall

    pop rdx             
    pop rsi
    pop rdi
    pop rax
%endmacro

section .data
    array db 3, 2, 3, 6, 3, 4, 5, 3, 10
    array_len equ $ - array
    newline db 10

section .bss
    count resb 1

section .text
    global _start

_start:
    mov rbx, 0              
    mov rsi, array           
    mov rcx, array_len    

.loop_array:
    mov al, [rsi]            
    cmp al, 3                
    jne .not_three           

    inc rbx                  

.not_three:
    inc rsi                  
    dec rcx                  
    cmp rcx, 0
    jne .loop_array          

.print_count:
    mov [count], bl          
    add byte [count], '0'   
    print_string count, 1    
    print_string newline, 1  

.exit_code:
    mov rax, SYSEXIT
    xor rdi, rdi             
    syscall