; ============================================================================
; macro_lib.asm — Your Personal Macro Library
; ============================================================================
;
; This is NOT a standalone program. It is a file you %include into others.
;
; HOW TO USE:
;   At the very top of any .asm file, write:
;       %include "macro_lib.asm"
;   Then you can use all the macros below freely.
;
; EXAMPLE:
;   %include "macro_lib.asm"
;
;   section .data
;       msg db "Hello!", 10
;       msg_len equ $ - msg
;
;   section .text
;       global _start
;   _start:
;       print msg, msg_len
;       exit 0
;
; ============================================================================

; ============================================================================
; SYSCALL CONSTANTS — so you never have to remember the numbers
; ============================================================================
%define SYS_READ    0
%define SYS_WRITE   1
%define SYS_EXIT    60
%define STDIN       0
%define STDOUT      1

; ============================================================================
; %define vs %macro — what's the difference?
;
; %define is a simple text substitution (like #define in C).
; It replaces a word with another word/number. No arguments, no code blocks.
;
;   %define SYS_EXIT 60
;   mov rax, SYS_EXIT       → becomes: mov rax, 60
;
; %macro is for multi-line code blocks, optionally with arguments.
;
; Rule of thumb:
;   Single value or simple substitution → use %define
;   Multiple lines of code              → use %macro
; ============================================================================

; ============================================================================
; INTERNAL STORAGE (used by the macros below)
; These get included when you %include this file.
; They are placed in .data and .bss via the macros' own sections.
; We define them here so all macros can share them.
; ============================================================================

section .bss
    _digit_buf  resb 1          ; temp byte for digit printing
    _num_buf    resb 20         ; temp buffer for number printing (up to 20 digits)

section .data
    _newline    db 10

; ============================================================================
; MACRO: exit
; Exits the program with code 0 (success)
; Or pass an exit code: exit 1
;
; Usage:
;   exit          ← exit code 0
;   exit 1        ← exit code 1
; ============================================================================
%macro exit 0
    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall
%endmacro

%macro exit 1
    mov rax, SYS_EXIT
    mov rdi, %1
    syscall
%endmacro

; NOTE: You can define TWO macros with the SAME name but DIFFERENT argument
; counts. NASM picks the right one based on how many arguments you pass.
; This is called "macro overloading."

; ============================================================================
; MACRO: print
; Prints a string to stdout.
;
; Usage:
;   print msg, msg_len
; ============================================================================
%macro print 2
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, %1
    mov rdx, %2
    syscall
%endmacro

; ============================================================================
; MACRO: println
; Prints a string followed by a newline.
;
; Usage:
;   println msg, msg_len
; ============================================================================
%macro println 2
    print %1, %2
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, _newline
    mov rdx, 1
    syscall
%endmacro

; ============================================================================
; MACRO: newline
; Prints just a newline character.
;
; Usage:
;   newline
; ============================================================================
%macro newline 0
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, _newline
    mov rdx, 1
    syscall
%endmacro

; ============================================================================
; MACRO: read
; Reads input from stdin into a buffer.
;
; Usage:
;   read buffer, max_bytes
;
; After this, rax contains how many bytes were actually read.
; ============================================================================
%macro read 2
    mov rax, SYS_READ
    mov rdi, STDIN
    mov rsi, %1
    mov rdx, %2
    syscall
%endmacro

; ============================================================================
; MACRO: print_num
; Prints any non-negative integer (uses stack trick from 10_print_numbers.asm)
;
; Usage:
;   mov r12, 385
;   print_num r12
;
; Argument must be a 64-bit register.
; ============================================================================
%macro print_num 1
    push rax                    ; save registers we'll clobber
    push rbx
    push rcx
    push rdx

    mov rax, %1                 ; number to print
    mov rcx, 0                  ; digit counter

    ; Edge case: number is 0
    cmp rax, 0
    jne %%extract
    mov byte [_digit_buf], '0'
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, _digit_buf
    mov rdx, 1
    syscall
    jmp %%done

%%extract:                      ; push digits onto stack (in reverse order)
    cmp rax, 0
    je %%print
    xor rdx, rdx
    mov rbx, 10
    div rbx                     ; rax = quotient, rdx = remainder (last digit)
    push rdx
    inc rcx
    jmp %%extract

%%print:                        ; pop digits and print (now in correct order)
    cmp rcx, 0
    je %%done
    pop rax
    add al, '0'
    mov [_digit_buf], al
    push rcx
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, _digit_buf
    mov rdx, 1
    syscall
    pop rcx
    dec rcx
    jmp %%print

%%done:
    pop rdx
    pop rcx
    pop rbx
    pop rax
%endmacro

; ============================================================================
; MACRO: save_regs / restore_regs
; Saves and restores the 4 main working registers.
; Useful when you need to do a syscall in the middle of some calculation
; and don't want to lose your values.
;
; Usage:
;   mov rax, 42             ; important value
;   mov rbx, 7              ; another important value
;   save_regs               ; push rax, rbx, rcx, rdx onto stack
;   ; ... do a syscall here safely ...
;   restore_regs            ; pop them back in correct order
;   ; rax = 42, rbx = 7 again
;
; RULE: Every save_regs MUST have a matching restore_regs.
; ============================================================================
%macro save_regs 0
    push rax
    push rbx
    push rcx
    push rdx
%endmacro

%macro restore_regs 0
    pop rdx
    pop rcx
    pop rbx
    pop rax
%endmacro

; ============================================================================
; MACRO LIBRARY SUMMARY:
;
;   exit              — exit with code 0
;   exit N            — exit with code N
;   print msg, len    — print a string
;   println msg, len  — print a string + newline
;   newline           — print just a newline
;   read buf, max     — read from keyboard into buffer
;   print_num reg     — print any non-negative integer from a register
;   save_regs         — push rax, rbx, rcx, rdx
;   restore_regs      — pop rdx, rcx, rbx, rax
;
; CONSTANTS:
;   SYS_READ = 0, SYS_WRITE = 1, SYS_EXIT = 60
;   STDIN = 0, STDOUT = 1
; ============================================================================