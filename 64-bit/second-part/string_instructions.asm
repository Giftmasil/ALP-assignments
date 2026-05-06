; ============================================================================
; 13_string_instructions.asm — Built-in String Instructions
; ============================================================================
;
; Build:
;   nasm -f elf64 13_string_instructions.asm
;   gcc -o 13_string_instructions 13_string_instructions.o -no-pie
;   ./13_string_instructions
;
; Shows: MOVSB, LODSB, STOSB, CMPSB, SCASB with REP prefixes
; Then rewrites get_length, char_exists, count_char using them
; ============================================================================

extern printf
global main
default rel

section .data
    source db "Hello Kenya!", 0
    source_len equ $ - source - 1       ; -1 to exclude null terminator

    str1 db "Assembly", 0
    str2 db "Assembly", 0
    str3 db "Assemble", 0

    search_char db 'l'

    fmt_copy db "1. Copied string: '%s'", 10, 0
    fmt_fill db "2. Filled buffer: '%s'", 10, 0
    fmt_len db "3. String length: %d", 10, 0
    fmt_cmp_eq db "4. '%s' and '%s' are EQUAL", 10, 0
    fmt_cmp_ne db "4. '%s' and '%s' are DIFFERENT", 10, 0
    fmt_found db "5. Found '%c' in string", 10, 0
    fmt_not db "5. '%c' not found", 10, 0
    fmt_count db "6. '%c' appears %d times", 10, 0

section .bss
    dest resb 20
    buffer resb 10

section .text
main:
    push rbp
    mov rbp, rsp
    sub rsp, 8

    ; ================================================================
    ; 1. MOVSB — Copy a string
    ;    Copies bytes from [rsi] to [rdi], advances both
    ; ================================================================
    cld                             ; ALWAYS clear direction flag first
    lea rsi, [source]               ; source address
    lea rdi, [dest]                 ; destination address
    mov rcx, source_len + 1         ; include null terminator
    rep movsb                       ; copy rcx bytes from [rsi] to [rdi]

    lea rdi, [fmt_copy]
    lea rsi, [dest]
    xor rax, rax
    call printf

    ; ================================================================
    ; 2. STOSB — Fill memory with a character
    ;    Stores al into [rdi], advances rdi
    ; ================================================================
    cld
    lea rdi, [buffer]
    mov al, '*'                     ; fill with asterisks
    mov rcx, 9                      ; 9 asterisks
    rep stosb                       ; write al to [rdi], repeat rcx times
    mov byte [buffer + 9], 0        ; null terminate

    lea rdi, [fmt_fill]
    lea rsi, [buffer]
    xor rax, rax
    call printf

    ; ================================================================
    ; 3. Get string length using SCASB
    ;    Search for null terminator (0) — distance = length
    ; ================================================================
    cld
    lea rdi, [source]
    xor al, al                      ; al = 0 (searching for null terminator)
    mov rcx, -1                     ; search "forever" (huge number)
    repne scasb                     ; keep scanning while [rdi] != al
                                    ; stops when it finds 0
    not rcx                         ; rcx was counting DOWN from -1
    dec rcx                         ; rcx = string length (exclude null)

    mov rsi, rcx
    lea rdi, [fmt_len]
    xor rax, rax
    call printf

    ; ================================================================
    ; 4. CMPSB — Compare two strings
    ; ================================================================

    ; Compare str1 with str2 (both "Assembly" — should be equal)
    cld
    lea rsi, [str1]
    lea rdi, [str2]
    mov rcx, 8                      ; compare 8 bytes
    repe cmpsb                      ; repeat while bytes are equal
    je .equal1                      ; if all matched, ZF is still set

    lea rdi, [fmt_cmp_ne]
    jmp .print_cmp1
.equal1:
    lea rdi, [fmt_cmp_eq]
.print_cmp1:
    lea rsi, [str1]
    lea rdx, [str2]
    xor rax, rax
    call printf

    ; Compare str1 with str3 ("Assembly" vs "Assemble" — different)
    cld
    lea rsi, [str1]
    lea rdi, [str3]
    mov rcx, 8
    repe cmpsb
    je .equal2

    lea rdi, [fmt_cmp_ne]
    jmp .print_cmp2
.equal2:
    lea rdi, [fmt_cmp_eq]
.print_cmp2:
    lea rsi, [str1]
    lea rdx, [str3]
    xor rax, rax
    call printf

    ; ================================================================
    ; 5. SCASB — Search for a character in a string
    ;    Like your char_exists function but using built-in instruction
    ; ================================================================
    cld
    lea rdi, [source]               ; string to search
    mov al, [search_char]           ; character to find ('l')
    mov rcx, source_len             ; how many bytes to search
    repne scasb                     ; repeat while [rdi] != al

    je .found_it                    ; ZF=1 means we found it
    
    ; Not found
    lea rdi, [fmt_not]
    movzx esi, byte [search_char]
    xor rax, rax
    call printf
    jmp .after_search

.found_it:
    lea rdi, [fmt_found]
    movzx esi, byte [search_char]
    xor rax, rax
    call printf

.after_search:

    ; ================================================================
    ; 6. Count occurrences using LODSB
    ;    Like your count_char but using LODSB to walk the string
    ; ================================================================
    cld
    lea rsi, [source]               ; rsi = string to scan
    xor r12, r12                    ; r12 = occurrence counter
    mov bl, [search_char]           ; bl = character to count

.count_loop:
    lodsb                           ; al = next char, rsi advances automatically
    cmp al, 0                       ; end of string?
    je .count_done
    cmp al, bl                      ; does it match?
    jne .count_loop                 ; no — next character
    inc r12                         ; yes — increment counter
    jmp .count_loop

.count_done:
    lea rdi, [fmt_count]
    movzx esi, byte [search_char]
    mov rdx, r12
    xor rax, rax
    call printf

    ; Exit
    add rsp, 8
    pop rbp
    xor rax, rax
    ret

section .note.GNU-stack noalloc noexec nowrite progbits