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

section .data
    array_1 db 1, 2, 6, 1, 7, 6
    array_len equ $ - array_1

    array_2 db 4, 3, 2, 3, 2, 2

    newline db 10

section .bss
    answer resb 6

section .text
    global _start

_start:
    mov r13, array_1       
    mov r14, array_2        
    mov r15, answer       
    mov rcx, array_len      

.calculate:
    mov al, [r13]           
    add al, [r14]           
    mov [r15], al           

    inc r13                 
    inc r14                 
    inc r15                 
    dec rcx
    cmp rcx, 0
    jne .calculate          


    mov r15, answer         
    mov rcx, array_len    

.print_array:
              
    mov al, [r15]          
    cmp al, 5
    jle .print_digit
    dec rcx
    inc r15
    cmp rcx, 0
    jne .print_array
    jmp .done

.print_digit:
    add al, '0'
    mov [r15], al

    print r15, 1

    mov al, [r15]
    sub al, '0'
    mov [r15], al

    print newline, 1
    dec rcx
    inc r15
    cmp rcx, 0
    jne .print_array

.done:
    mov rax, 60
    xor rdi, rdi
    syscall