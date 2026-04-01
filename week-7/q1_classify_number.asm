;Gift Muuo Masila - SCS3/2109/2024
;Aneselmus  Oyando - SCS3/2127/2024
;Violet Onyango - SCS3/2137/2024
;Melissa Angwenyi - SCS3/149260/2024
;Juliet Jaoko - SCS3/2111/2024
%macro print 2
    push rax
    push rcx            
    push rdx
    push rdi
    push rsi

    mov rax, 1
    mov rdi, 1
    mov rsi, %1
    mov rdx, %2
    syscall

    pop rsi
    pop rdi
    pop rdx
    pop rcx          
    pop rax
%endmacro

%macro print_digit 1
    push rax
    push rcx            
    push rdx
    push rdi
    push rsi

    add byte [%1], 48 

    mov rax, 1
    mov rdi, 1
    mov rsi, %1
    mov rdx, 1
    syscall

    sub byte [%1], 48

    pop rsi
    pop rdi
    pop rdx
    pop rcx              
    pop rax
%endmacro

%macro manage_counter 0
    inc rbx
    dec rcx
    cmp rcx, 0
    je .done
%endmacro

section .data
    array db 9, 7, 3, 5, 6, 4, 2, 8, 1
    array_len equ $ - array

    small db "Small Number"
    small_len equ $ - small

    average db "Average Number"
    average_len equ $ - average

    large db "Large Number"
    large_len equ $ - large

    newline db 10
    colon_space db " : "
    colon_space_len equ $ - colon_space

section .text
    global _start

_start:
    mov rcx, array_len
    mov rbx, array

.check_category:
    cmp byte [rbx], 3
    jle .print_small

    cmp byte [rbx], 7
    jle .print_average
    
    jmp .print_large
    

.print_small:
    print_digit rbx
    print colon_space, colon_space_len
    print small, small_len
    print newline, 1  
    manage_counter
    jmp .check_category

.print_average:
    print_digit rbx
    print colon_space, colon_space_len
    print average, average_len
    print newline, 1  
    manage_counter
    jmp .check_category

.print_large:
    print_digit rbx
    print colon_space, colon_space_len
    print large, large_len
    print newline, 1  
    manage_counter
    jmp .check_category


.done:
    mov rax, 60
    xor rdi, rdi
    syscall