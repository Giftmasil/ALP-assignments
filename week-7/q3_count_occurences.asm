;Gift Muuo Masila - SCS3/2109/2024
;Aneselmus  Oyando - SCS3/2127/2024
;Violet Onyango - SCS3/2137/2024
;Melissa Angwenyi - SCS3/149260/2024
;Juliet Jaoko - SCS3/2111/2024

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
    space db ' '

section .bss
    count resb 1
    positions resb array_len

section .text
    global _start

_start:
    mov rbx, 0    
    mov r14, positions      
    mov rsi, array      
    mov rcx, array_len    

.loop_array:
    mov al, [rsi]            
    cmp al, 3                
    jne .not_three           

    mov [r14], rsi
    inc r14
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


    mov rcx, rbx
    mov r15, positions

.print_array:
    push rcx

    mov al, [r15]
    add al, '0'
    mov [r15], al

    print_string r15, 1

    mov al, [r15]
    sub al, '0'
    mov [r15], al

    print_string space, 1

    pop rcx
    inc r15
    dec rcx
    cmp rcx, 0
    jne .print_array

.exit_code:
    print_string newline, 1
    mov rax, SYSEXIT
    xor rdi, rdi             
    syscall