; ============================================================================
; 04_variables.asm — Variables, Data Types & Sections (64-bit)
; ============================================================================
;
; Build & Run:
;   nasm -f elf64 04_variables.asm
;   ld -o 04_variables 04_variables.o
;   ./04_variables
; ============================================================================
;
; DATA SIZES IN ASSEMBLY
; ============================================================================
;
; Name          Size        Bits   Define    Reserve    Type specifier
; ─────────────────────────────────────────────────────────────────────
; Byte          1 byte       8     db        resb       byte
; Word          2 bytes     16     dw        resw       word
; Double word   4 bytes     32     dd        resd       dword
; Quad word     8 bytes     64     dq        resq       qword
; Ten bytes    10 bytes     80     dt        rest       tbyte
;
; db = "define byte"      → use in section .data (with initial value)
; resb = "reserve byte"   → use in section .bss  (no initial value)
;
; Range of values:
;   1 byte  unsigned: 0 to 255
;   1 byte  signed:   -128 to 127
;   2 bytes unsigned: 0 to 65,535
;   4 bytes unsigned: 0 to ~4 billion
;   8 bytes unsigned: 0 to ~18 quintillion
;
; ============================================================================
;
; THE THREE SECTIONS
; ============================================================================
;
; section .data   — Variables you give a value right away
;                   Readable + Writable, NOT executable
;                   Like global variables in C/Python
;
; section .bss    — Space reserved for variables you'll fill later
;                   Readable + Writable, NOT executable
;                   Filled with zeros when program starts
;                   Great for: user input buffers, results of calculations
;
; section .text   — Your actual code (instructions)
;                   Readable + Executable, NOT writable
;
; ============================================================================

; ---- INITIALIZED DATA (section .data) ----
section .data

    ; --- Byte variables (1 byte each) ---
    grade db 'A'                ; a single character (stored as ASCII value 65)
    age db 25                   ; a small number (0-255)
    flag db 1                   ; a boolean-like value

    ; --- Word variables (2 bytes each) ---
    year dw 2026                ; a medium number (0-65535)
    count dw 0                  ; initialized to zero

    ; --- Double word variables (4 bytes each) ---
    speed dd 300000             ; speed of light in km/s
    population dd 56000000      ; approximate population of Kenya

    ; --- Quad word variables (8 bytes each) ---
    bignum dq 123456789012      ; very large number

    ; --- Strings (sequences of bytes) ---
    name db "Tison", 0         ; 0 = null terminator (marks end of string)
    greeting db "Habari!", 10  ; 10 = newline character
    greet_len equ $ - greeting

    ; --- Arrays (multiple values in sequence) ---
    scores db 85, 92, 78, 95, 88       ; array of 5 bytes
    prices dw 1500, 2300, 800, 4500    ; array of 4 words (2 bytes each)

    ; --- Constants (equ) ---
    ; These do NOT take any memory! The assembler replaces the name
    ; with the value everywhere it appears in the code.
    SYS_WRITE equ 1            ; syscall number for write (64-bit)
    SYS_EXIT  equ 60           ; syscall number for exit  (64-bit)
    STDOUT    equ 1            ; file descriptor for screen
    NEWLINE   equ 10           ; ASCII code for newline

    ; --- Using constants makes code more readable ---
    ; Compare:
    ;   mov rax, 1       ← what is 1? hard to remember
    ;   mov rax, SYS_WRITE  ← oh, it's the write syscall!

    ; --- The $ and equ explained ---
    ; $ always means "the current address right here"
    ;
    ;   msg db "Hello", 10
    ;   len equ $ - msg
    ;
    ;   If msg starts at address 100:
    ;     'H' is at 100
    ;     'e' is at 101
    ;     'l' is at 102
    ;     'l' is at 103
    ;     'o' is at 104
    ;     10  is at 105
    ;     $ is now 106 (the next free address)
    ;
    ;   len = $ - msg = 106 - 100 = 6 bytes
    ;
    ;   IMPORTANT: equ must come RIGHT AFTER the variable it measures!
    ;   If you put other data between them, $ will have moved and the
    ;   length will be wrong.

    ;TIMES Key word
    marks TIMES 20 DW 0 ;0 is stored 20 times

    ; --- Messages for printing ---
    msg_done db "All variables defined and demo complete!", 10
    msg_done_len equ $ - msg_done


; ---- UNINITIALIZED DATA (section .bss) ----
section .bss

    ; Reserve space for variables you'll fill in later at runtime.
    ; These are all zeros when the program starts.

    buffer resb 64              ; reserve 64 bytes (e.g. for user input)
    result resd 1               ; reserve 1 double word (4 bytes)
    temp resq 1                 ; reserve 1 quad word (8 bytes)
    array resb 100              ; reserve 100 bytes (e.g. for an array)
    gift rest 1                 ; tserve 1 tenbyte 


; ---- CODE (section .text) ----
section .text
    global _start

_start:

    ; ---- Demo: Read a variable from .data ----
    mov al, [grade]             ; al = 65 (ASCII 'A')
    mov al, [age]               ; al = 25

    ; ---- Demo: Modify a variable ----
    add byte [age], 1           ; age is now 26 (happy birthday!)
    mov word [count], 42        ; count is now 42

    ; ---- Demo: Access array elements with direct-offset ----
    mov al, [scores]            ; al = 85  (first score)
    mov al, [scores+1]          ; al = 92  (second score)
    mov al, [scores+2]          ; al = 78  (third score)
    mov al, [scores+3]          ; al = 95  (fourth score)
    mov al, [scores+4]          ; al = 88  (fifth score)

    ; For the prices array (word = 2 bytes each):
    mov ax, [prices]            ; ax = 1500 (first price)
    mov ax, [prices+2]          ; ax = 2300 (second price, skip 2 bytes!)
    mov ax, [prices+4]          ; ax = 800  (third price, skip 4 bytes!)
    mov ax, [prices+6]          ; ax = 4500 (fourth price, skip 6 bytes!)
    ; NOTE: offset increases by 2 for words, not 1!

    ; ---- Demo: Store a result in .bss ----
    mov dword [result], 999     ; put 999 into the reserved space

    ; ---- Demo: Use constants for cleaner syscalls ----
    mov rax, SYS_WRITE          ; much clearer than "mov rax, 1"
    mov rdi, STDOUT             ; much clearer than "mov rdi, 1"
    mov rsi, msg_done
    mov rdx, msg_done_len
    syscall

    ; ---- Exit ----
    mov rax, SYS_EXIT           ; cleaner than "mov rax, 60"
    mov rdi, 0
    syscall