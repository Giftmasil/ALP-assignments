extern printf
global main
default rel

%include 'utils.asm'

section .data
    my_string db "My Assembly Group is made of very intelligent people. Gift, Melissa, Juliet, Violet and I!", 0
    target_char db 'e'

    fmt_len db "1. Length of string: %d", 10, 0
    fmt_exists db "2. Does it contain '%c'? %s", 10, 0
    fmt_count db "3. '%c' has occurred %d times", 10, 0

    str_yes db "Yes!", 0
    str_no db "No.", 0

section .text
main:
    functionStart
    saveCalleeSaved
    sub rsp, 8

    ; Get string length
    lea rdi, [my_string]
    call get_length

    mov rsi, rax                
    lea rdi, [fmt_len]
    xor rax, rax
    call printf

    ; Check if character exists
    lea rdi, [my_string]
    mov sil, [target_char]
    call char_exists

    lea rcx, [str_yes]
    lea r8, [str_no]
    cmp rax, 1
    cmovne rcx, r8

    lea rdi, [fmt_exists]
    movzx esi, byte [target_char]
    mov rdx, rcx
    xor rax, rax
    call printf

    ; Count occurrences
    lea rdi, [my_string]
    mov sil, [target_char]
    call count_char

    mov rdx, rax                ; count = 3rd arg
    lea rdi, [fmt_count]
    movzx esi, byte [target_char]
    xor rax, rax
    call printf

    add rsp, 8
    retriveCalleeSaved
    functionEnd
    xor rax, rax
    ret

get_length:
    functionStart
    xor rax, rax
.len_loop:
    cmp byte [rdi + rax], 0
    je .len_done
    inc rax
    jmp .len_loop
.len_done:
    functionEnd
    ret

char_exists:
    functionStart
    xor rcx, rcx
.exist_loop:
    mov al, [rdi + rcx]
    cmp al, 0
    je .not_found
    cmp al, sil
    je .found
    inc rcx
    jmp .exist_loop
.found:
    mov rax, 1
    jmp .exist_done
.not_found:
    mov rax, 0
.exist_done:
    functionEnd
    ret

count_char:
    functionStart
    xor rax, rax
    xor rcx, rcx
.count_loop:
    mov r8b, [rdi + rcx]
    cmp r8b, 0
    je .count_done
    cmp r8b, sil
    jne .skip_add
    inc rax
.skip_add:
    inc rcx
    jmp .count_loop
.count_done:
    functionEnd
    ret

section .note.GNU-stack noalloc noexec nowrite progbits