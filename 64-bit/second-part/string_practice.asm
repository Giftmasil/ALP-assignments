; ============================================================================
; 13b_strings_practice.asm — String Instructions in Action
; ============================================================================
;
; Build:
;   nasm -f elf64 13b_strings_practice.asm
;   gcc -o 13b_strings_practice 13b_strings_practice.o -no-pie
;   ./13b_strings_practice
; ============================================================================

extern printf
global main
default rel

section .data
    ; Source strings
    source db "Hello Kenya!", 0
    source_len equ $ - source - 1   ; 12 (exclude null)

    str_a db "Assembly", 0
    str_b db "Assembly", 0
    str_c db "Assemble", 0

    ; Format strings
    fmt_copy db "1. MOVSB copy:     '%s'", 10, 0
    fmt_fill db "2. STOSB fill:     '%s'", 10, 0
    fmt_len db "3. SCASB strlen:    %d characters", 10, 0
    fmt_eq db "4. CMPSB compare:   '%s' and '%s' are EQUAL", 10, 0
    fmt_ne db "4. CMPSB compare:   '%s' and '%s' are DIFFERENT", 10, 0
    fmt_found db "5. SCASB search:   Found '%c' at position %d", 10, 0
    fmt_notf db "5. SCASB search:   '%c' not found", 10, 0
    fmt_count db "6. LODSB count:    '%c' appears %d times", 10, 0
    fmt_upper db "7. LODSB+STOSB:    '%s' → '%s'", 10, 0

section .bss
    dest resb 20
    buffer resb 12
    upper_buf resb 20

section .text
main:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    sub rsp, 8

    ; ================================================================
    ; 1. MOVSB — Copy "Hello Kenya!" to dest
    ; ================================================================
    cld                             ; forward direction
    lea rsi, [source]
    lea rdi, [dest]
    mov rcx, source_len + 1         ; +1 for null terminator
    rep movsb

    lea rdi, [fmt_copy]
    lea rsi, [dest]
    xor rax, rax
    call printf

    ; ================================================================
    ; 2. STOSB — Fill buffer with asterisks
    ; ================================================================
    cld
    lea rdi, [buffer]
    mov al, '*'
    mov rcx, 10
    rep stosb
    mov byte [buffer + 10], 0       ; null terminate

    lea rdi, [fmt_fill]
    lea rsi, [buffer]
    xor rax, rax
    call printf

    ; ================================================================
    ; 3. SCASB — Get string length (find null terminator)
    ;    This is the assembly equivalent of strlen()
    ; ================================================================
    cld
    lea rdi, [source]
    xor al, al                      ; search for 0
    mov rcx, -1                     ; search "forever"
    repne scasb                     ; scan until [rdi] == 0
    not rcx                         ; magic: flip bits
    dec rcx                         ; rcx = string length
    mov r12, rcx                    ; save length

    lea rdi, [fmt_len]
    mov rsi, r12
    xor rax, rax
    call printf

    ; ================================================================
    ; 4. CMPSB — Compare two strings
    ; ================================================================

    ; Compare "Assembly" with "Assembly" (should be equal)
    cld
    lea rsi, [str_a]
    lea rdi, [str_b]
    mov rcx, 8
    repe cmpsb                      ; compare while equal
    je .eq1

    lea rdi, [fmt_ne]
    jmp .print1
.eq1:
    lea rdi, [fmt_eq]
.print1:
    lea rsi, [str_a]
    lea rdx, [str_b]
    xor rax, rax
    call printf

    ; Compare "Assembly" with "Assemble" (should be different)
    cld
    lea rsi, [str_a]
    lea rdi, [str_c]
    mov rcx, 8
    repe cmpsb
    je .eq2

    lea rdi, [fmt_ne]
    jmp .print2
.eq2:
    lea rdi, [fmt_eq]
.print2:
    lea rsi, [str_a]
    lea rdx, [str_c]
    xor rax, rax
    call printf

    ; ================================================================
    ; 5. SCASB — Search for 'K' in "Hello Kenya!"
    ; ================================================================
    cld
    lea rdi, [source]
    mov r13, rdi                    ; save start address
    mov al, 'K'
    mov rcx, source_len
    repne scasb                     ; scan until match

    je .found_char
    ; not found
    lea rdi, [fmt_notf]
    mov sil, 'K'
    xor rax, rax
    call printf
    jmp .after_search

.found_char:
    ; rdi points to byte AFTER the match
    ; position = rdi - start - 1
    mov r12, rdi
    sub r12, r13
    dec r12                         ; r12 = position of 'K'

    lea rdi, [fmt_found]
    mov sil, 'K'
    mov rdx, r12
    xor rax, rax
    call printf

.after_search:

    ; ================================================================
    ; 6. LODSB — Count how many times 'l' appears
    ; ================================================================
    cld
    lea rsi, [source]
    xor r12, r12                    ; occurrence counter
    mov bl, 'l'

.count_loop:
    lodsb                           ; al = next char, rsi++
    cmp al, 0
    je .count_done
    cmp al, bl
    jne .count_loop
    inc r12
    jmp .count_loop

.count_done:
    lea rdi, [fmt_count]
    mov sil, 'l'
    mov rdx, r12
    xor rax, rax
    call printf

    ; ================================================================
    ; 7. LODSB + STOSB — Convert to uppercase
    ; ================================================================
    cld
    lea rsi, [source]
    lea rdi, [upper_buf]

.upper_loop:
    lodsb                           ; al = next char from source
    cmp al, 0
    je .upper_done
    cmp al, 'a'                     ; is it lowercase?
    jb .store_char                  ; below 'a' — not lowercase
    cmp al, 'z'
    ja .store_char                  ; above 'z' — not lowercase
    sub al, 32                      ; 'a'-'A' = 32, so subtract to uppercase
.store_char:
    stosb                           ; store al into upper_buf, rdi++
    jmp .upper_loop
.upper_done:
    stosb                           ; store null terminator

    lea rdi, [fmt_upper]
    lea rsi, [source]
    lea rdx, [upper_buf]
    xor rax, rax
    call printf

    ; Exit
    add rsp, 8
    pop r13
    pop r12
    pop rbp
    xor rax, rax
    ret

section .note.GNU-stack noalloc noexec nowrite progbits