; cleaner code but loop instruction cannot jump more than 128 bytes

%macro print 2
    push rax
    push rdi
    push rsi
    push rdx
    push rcx

    mov rax, 1
    mov rdi, 1
    mov rsi, %1
    mov rdx, %2
    syscall

    pop rcx
    pop rdx
    pop rsi
    pop rdi
    pop rax
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
    print small, small_len
    jmp .next_iteration

.print_average:
    print average, average_len
    jmp .next_iteration

.print_large:
    print large, large_len

.next_iteration:
    inc rbx
    dec rcx
    cmp rcx, 0
    je .done
    
    jmp .check_category


.done:
    mov rax, 60
    xor rdi, rdi
    syscall