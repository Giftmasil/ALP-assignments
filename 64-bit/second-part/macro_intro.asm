; ============================================================================
; 12_macros_intro.asm — Introduction to Macros in NASM (64-bit)
; ============================================================================
;
; Build & Run:
;   ./build.sh 12_macros_intro 64
;
; This file demonstrates:
;   1. A macro with no arguments
;   2. A macro with one argument
;   3. A macro with multiple arguments
;   4. The %% label trick
;   5. Macro vs function — when to use each
; ============================================================================

; ============================================================================
; MACRO DEFINITIONS — always put these at the TOP of your file
; (before section .data and section .text)
; Macros must be defined BEFORE they are used.
; ============================================================================

; ============================================================================
; MACRO 1: exit — exits the program cleanly
;
; No arguments. Every program needs this and it's always the same 3 lines.
; Wrapping it in a macro means you never type those lines again.
;
; Usage:
;   exit
;
; Becomes (after NASM substitutes it):
;   mov rax, 60
;   xor rdi, rdi
;   syscall
; ============================================================================

%macro exit 0                   ; 0 = this macro takes zero arguments
    mov rax, 60
    xor rdi, rdi
    syscall
%endmacro

; ============================================================================
; MACRO 2: print_newline — prints a newline character
;
; No arguments. You've been typing these 4 lines after every print.
; Now it's one word.
;
; Usage:
;   print_newline
; ============================================================================

%macro print_newline 0
    mov rax, 1
    mov rdi, 1
    mov rsi, _newline           ; points to the newline byte defined in .data
    mov rdx, 1
    syscall
%endmacro

; ============================================================================
; MACRO 3: print_str — prints a string given its address and length
;
; 2 arguments:
;   %1 = address of the string (the label name)
;   %2 = length of the string
;
; Usage:
;   print_str msg, msg_len
;
; Becomes:
;   mov rax, 1
;   mov rdi, 1
;   mov rsi, msg
;   mov rdx, msg_len
;   syscall
; ============================================================================

%macro print_str 2              ; 2 = this macro takes two arguments
    mov rax, 1
    mov rdi, 1
    mov rsi, %1                 ; %1 is replaced by the first argument you pass
    mov rdx, %2                 ; %2 is replaced by the second argument
    syscall
%endmacro

; ============================================================================
; MACRO 4: print_digit — prints a single digit number (0–9)
;
; 1 argument:
;   %1 = a register or memory location containing the digit (0–9)
;
; Usage:
;   mov al, 7
;   print_digit al
; ============================================================================

%macro print_digit 1            ; 1 argument
    push rax                    ; save rax — we're about to change it
    push rdx
    movzx rax, %1               ; load the digit (zero-extend to 64-bit)
    add al, '0'                 ; convert number to ASCII character
    mov [_digit_buf], al        ; store in temp buffer
    mov rax, 1
    mov rdi, 1
    mov rsi, _digit_buf
    mov rdx, 1
    syscall
    pop rdx
    pop rax                     ; restore rax
%endmacro

; ============================================================================
; MACRO 5: repeat — runs a block of code N times (demonstrates %% labels)
;
; 1 argument:
;   %1 = how many times to repeat
;
; This macro contains a loop — so it needs %% labels to avoid
; "label defined twice" errors when used more than once.
;
; Usage:
;   mov rbx, 0          ; rbx = loop body variable (you manage it)
;   repeat 3
;       ; your code here (not really possible in NASM macros this way)
;   ; but the counter loop itself works fine:
; ============================================================================

%macro countdown 1              ; counts down from %1 to 1, printing each digit
    mov rcx, %1                 ; set counter to argument
%%loop:                         ; %% makes this label unique each expansion!
    push rcx                    ; save counter (syscall will clobber rcx)
    mov al, cl                  ; cl = lower byte of rcx
    print_digit al              ; print the current count (MACRO INSIDE MACRO!)
    print_newline               ; print newline  (MACRO INSIDE MACRO!)
    pop rcx                     ; restore counter
    dec rcx                     ; count down
    cmp rcx, 0
    jne %%loop                  ; %%loop is unique — no conflict if used twice
%endmacro

; ============================================================================
; DATA SECTION
; ============================================================================

section .data
    msg1        db "Hello from a macro!", 10
    msg1_len    equ $ - msg1

    msg2        db "Counting down from 3:"
    msg2_len    equ $ - msg2

    msg3        db "Counting down from 2:"
    msg3_len    equ $ - msg3

    _newline    db 10           ; underscore prefix = "internal, for macro use"

section .bss
    _digit_buf  resb 1          ; 1-byte buffer used by print_digit macro

; ============================================================================
; CODE SECTION
; ============================================================================

section .text
    global _start

_start:

; ---- Use the print_str macro ----
    print_str msg1, msg1_len    ; instead of 4 lines of mov + syscall

; ---- Use print_newline ----
    print_newline               ; instead of 4 more lines

; ---- Use print_digit ----
    mov al, 5
    print_digit al              ; prints: 5
    print_newline

; ---- Use countdown macro (demonstrates %% labels) ----
;     The countdown macro has a %%loop label inside it.
;     We call it TWICE — without %%, both would create ".loop" → ERROR
;     With %%, NASM creates "loop__1" and "loop__2" automatically → OK

    print_str msg2, msg2_len
    print_newline
    countdown 3                 ; prints 3, 2, 1 each on new line
                                ; %%loop becomes something like "loop__1"

    print_newline
    print_str msg3, msg3_len
    print_newline
    countdown 2                 ; prints 2, 1 each on new line
                                ; %%loop becomes "loop__2" — no conflict!

; ---- Use exit macro ----
    exit                        ; instead of: mov rax, 60 / xor rdi, rdi / syscall

; ============================================================================
; WHAT NASM ACTUALLY SEES after substituting the macros:
;
; The line:
;   print_str msg1, msg1_len
;
; Gets expanded to:
;   mov rax, 1
;   mov rdi, 1
;   mov rsi, msg1
;   mov rdx, msg1_len
;   syscall
;
; The line:
;   exit
;
; Gets expanded to:
;   mov rax, 60
;   xor rdi, rdi
;   syscall
;
; There is NO jump, NO call, NO ret.
; The code is physically inserted in place.
; ============================================================================

; ============================================================================
; MACRO SYNTAX CHEAT SHEET:
;
; Define a macro:
;   %macro name  num_args
;       ; code using %1, %2, %3 ... for arguments
;   %endmacro
;
; Use a macro:
;   name arg1, arg2, arg3
;
; Labels inside macros → use %% not . or nothing:
;   %%my_label:     ← safe, gets unique name each expansion
;   .my_label:      ← DANGEROUS if macro used more than once
;
; Macros inside macros → allowed! (like print_digit inside countdown)
;
; num_args can be 0:
;   %macro my_macro 0
;   ...just write code, no %1 etc...
;   %endmacro
; ============================================================================