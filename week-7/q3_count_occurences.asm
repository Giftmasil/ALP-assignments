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
    comma db ','

section .bss
    count resb 1
    positions resb array_len

section .text
    global _start

_start:
    mov rbx, 0    ;counter    
    mov r14, positions      
    mov rsi, array   ;position of first element        
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


    mov rcx, rbx; rbx contains the lenght of the array that was actually filled with values
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

    pop rcx

    ; Only print comma if this is NOT the last element
    cmp rcx, 1
    je .skip_comma          ; if rcx == 1, this is the last one, skip comma

    push rcx
    print_string comma, 1
    pop rcx

.skip_comma:
    inc r15
    dec rcx
    cmp rcx, 0
    jne .print_array

.exit_code:
    print_string newline, 1
    mov rax, SYSEXIT
    xor rdi, rdi             
    syscall