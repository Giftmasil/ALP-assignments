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
    sunday db "Sunday"
    sunday_len equ $ - sunday

    monday db "Monday"
    monday_len equ $ - monday

    tuesday db "Tuesday"
    tuesday_len equ $ - tuesday

    wednesday db "Wednesday"
    wednesday_len equ $ - wednesday

    thursday db "Thursday"
    thursday_len equ $ - thursday

    friday db "Friday"
    friday_len equ $ - friday

    saturday db "Saturday"
    saturday_len equ $ - saturday 

    prompt db "Enter the day of the week: "
    prompt_len equ $ - prompt

    invalid_input db "Invalid input. Please enter a number between 0 and 6."
    invalid_input_len equ $ - invalid_input

    newline db 10

    sys_exit equ 60
    sys_write equ 1
    stdout equ 1
    sys_read equ 0
    stdin equ 0

section .bss
    day resb 2

section .text
    global _start


_start:
.get_input:
    print newline, 1
    print prompt, prompt_len
    mov rax, sys_read       
    mov rdi, stdin          
    mov rsi, day
    mov rdx, 2           
    syscall

.check_day:

    cmp byte [day], '0'
    je .print_sunday

    cmp byte [day], '1'
    je .print_monday

    cmp byte [day], '2'
    je .print_tuesday

    cmp byte [day], '3'
    je .print_wednesday

    cmp byte [day], '4'
    je .print_thursday

    cmp byte [day], '5'
    je .print_friday

    cmp byte [day], '6'
    je .print_saturday

    jmp .invalid_input

.print_sunday:
    print sunday, sunday_len
    jmp .done
.print_monday:
    print monday, monday_len
    jmp .done
.print_tuesday:
    print tuesday, tuesday_len
    jmp .done
.print_wednesday:
    print wednesday, wednesday_len
    jmp .done
.print_thursday:
    print thursday, thursday_len
    jmp .done
.print_friday:
    print friday, friday_len
    jmp .done
.print_saturday:
    print saturday, saturday_len
    jmp .done
.invalid_input:
    print invalid_input, invalid_input_len
    jmp .get_input


.done:
    print newline, 1
    mov rax, sys_exit
    xor rdi, rdi
    syscall