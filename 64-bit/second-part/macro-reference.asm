; ============================================================================
; 14_macro_reference.asm — Macros Reference Sheet (DO NOT RUN)
; ============================================================================
;
; Everything you need to know about macros in one place.
; Keep this open while writing code.
; ============================================================================

; ============================================================================
; 1. BASIC SYNTAX
; ============================================================================

; No arguments:
%macro my_macro 0
    ; code here
%endmacro

; One argument (%1):
%macro my_macro 1
    mov rax, %1             ; %1 = whatever you pass in
%endmacro

; Two arguments (%1 and %2):
%macro my_macro 2
    mov rsi, %1
    mov rdx, %2
%endmacro

; Using the macro:
;   my_macro                        ← 0 args
;   my_macro some_value             ← 1 arg
;   my_macro some_label, some_len   ← 2 args


; ============================================================================
; 2. %define — SIMPLE TEXT SUBSTITUTION
; ============================================================================

; %define replaces a word with a value everywhere it appears.
; Think of it as a named constant.

%define SYS_WRITE   1
%define STDOUT      1
%define BUFFER_SIZE 64

; Using %define:
;   mov rax, SYS_WRITE      → becomes: mov rax, 1
;   resb BUFFER_SIZE        → becomes: resb 64

; %define vs %macro:
;   %define → single value replacement, no code blocks, no arguments
;   %macro  → multi-line code, can take arguments, contains instructions


; ============================================================================
; 3. THE %% LABEL RULE — Most important thing to remember
; ============================================================================

; WRONG — will error if macro is used more than once:
%macro bad 0
.loop:
    dec rcx
    jnz .loop               ; "label .loop defined twice" ERROR on second use
%endmacro

; CORRECT — %% makes the label unique each time:
%macro good 0
%%loop:
    dec rcx
    jnz %%loop              ; NASM turns this into loop__1, loop__2, etc.
%endmacro

; Rule: ANY label inside a macro must start with %%


; ============================================================================
; 4. MACRO OVERLOADING — same name, different argument count
; ============================================================================

; You can have two macros with the same name if they take different numbers
; of arguments. NASM picks the right one automatically.

%macro exit 0
    mov rax, 60
    xor rdi, rdi
    syscall
%endmacro

%macro exit 1
    mov rax, 60
    mov rdi, %1             ; use the argument as the exit code
    syscall
%endmacro

; Usage:
;   exit        ← calls the 0-argument version (exit code 0)
;   exit 1      ← calls the 1-argument version (exit code 1)
;   exit 42     ← calls the 1-argument version (exit code 42)


; ============================================================================
; 5. MACROS CALLING OTHER MACROS
; ============================================================================

; A macro can use other macros inside it. NASM expands them all.

%macro newline 0
    mov rax, 1
    mov rdi, 1
    mov rsi, _newline
    mov rdx, 1
    syscall
%endmacro

%macro println 2            ; print string + automatic newline
    mov rax, 1
    mov rdi, 1
    mov rsi, %1
    mov rdx, %2
    syscall
    newline                 ; calling another macro inside this macro — fine!
%endmacro


; ============================================================================
; 6. %include — SHARING MACROS ACROSS FILES
; ============================================================================

; Put your macros in a separate file (like macro_lib.asm).
; At the top of any program that needs them, write:
;
;   %include "macro_lib.asm"
;
; NASM pastes the entire file contents there before assembling.
; Both files must be in the same folder.
;
; NASM processes files top-to-bottom, so %include must come
; BEFORE you use any of the macros it provides.


; ============================================================================
; 7. MACRO vs FUNCTION — when to use each
; ============================================================================

; ┌──────────────────┬─────────────────────────┬─────────────────────────┐
; │                  │ MACRO                   │ FUNCTION                │
; ├──────────────────┼─────────────────────────┼─────────────────────────┤
; │ How it works     │ Code is PASTED IN PLACE │ CPU JUMPS to code       │
; │ call/ret needed? │ No                      │ Yes                     │
; │ Stack overhead?  │ No                      │ Yes (return address)    │
; │ Code size        │ Grows with each use     │ One copy, many calls    │
; │ Speed            │ Slightly faster         │ Slight overhead         │
; │ Best for         │ Short, frequent code    │ Long or complex code    │
; │ Examples         │ exit, newline, print    │ print_number, factorial │
; └──────────────────┴─────────────────────────┴─────────────────────────┘
;
; If you use a 5-line macro 10 times → 50 lines in your binary
; If you use a 5-line function 10 times → 5 lines + 10 call instructions
;
; For tiny things used constantly (exit, newline, print): use a MACRO
; For anything more than ~5 lines: use a FUNCTION


; ============================================================================
; 8. COMMON MISTAKES
; ============================================================================

; MISTAKE 1: Forgetting %% on labels inside macros
;   %macro bad 0
;   .done:              ← missing %%, will crash on second use
;   %endmacro

; MISTAKE 2: Using %include after the code that needs it
;   section .text        ← too late, macros below aren't defined yet
;   global _start
;   %include "macros.asm"   ← WRONG, must be at the TOP of the file

; MISTAKE 3: Forgetting to push/pop when a macro uses rax internally
;   If your macro changes rax but your code needs rax after the macro,
;   either push/pop inside the macro, or save_regs before calling it.

; MISTAKE 4: Defining a macro after trying to use it
;   my_macro            ← used here
;   %macro my_macro 0   ← defined HERE — too late, NASM errors
;   %endmacro
;   Solution: always define macros BEFORE using them (top of file or %include)


; ============================================================================
; 9. QUICK REFERENCE CARD
; ============================================================================
;
; Define:      %macro name  num_args
;              %endmacro
;
; Argument:    %1 %2 %3 ...
;
; Label:       %%my_label   (safe inside macro)
;
; Constant:    %define NAME value
;
; Include:     %include "filename.asm"
;
; Overload:    Same name, different arg count — both are defined
;
; Use:         name arg1, arg2, arg3