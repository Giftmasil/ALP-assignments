; ============================================================================
; 03_stack.asm — Understanding the Stack (64-bit)
; ============================================================================
;
; Build & Run:
;   nasm -f elf64 03_stack.asm
;   ld -o 03_stack 03_stack.o
;   ./03_stack
; ============================================================================
;
; THE STACK — A LIFO (Last In, First Out) data structure
;
; Imagine a stack of plates:
;   - You can only add a plate to the TOP      (push)
;   - You can only remove a plate from the TOP  (pop)
;   - The last plate you put on is the first you take off
;
; In memory, the stack grows DOWNWARD (from high addresses to low addresses)
;
;   BEFORE push:                 AFTER push rax (where rax=42):
;
;   Address    Value              Address    Value
;   ───────    ─────              ───────    ─────
;   1000       ...                1000       ...
;    996       ...                 996       ...
;    992       ... ← RSP           992       42  ← RSP (moved down!)
;                                  988       ...
;
; push = put a value ON TOP of the stack, RSP moves DOWN by 8 bytes
; pop  = take the TOP value OFF the stack, RSP moves UP by 8 bytes
;
; WHY IS THE STACK USEFUL?
;   1. Saving register values temporarily
;   2. Passing arguments to functions
;   3. Storing local variables in functions
;   4. Keeping track of return addresses when calling functions
;
; RSP (stack pointer) always points to the top of the stack.
; Never modify RSP directly unless you really know what you're doing.
; ============================================================================

section .data
    msg1 db "Before: rax and rbx have values", 10
    len1 equ $ - msg1

    msg2 db "Middle: rax and rbx were overwritten", 10
    len2 equ $ - msg2

    msg3 db "After: rax and rbx restored from stack!", 10
    len3 equ $ - msg3

    msg4 db "Stack demo complete!", 10
    len4 equ $ - msg4

section .text
    global _start

_start:

; ============================================================================
; DEMO: Using the stack to save and restore register values
;
; Scenario: You have important values in rax and rbx, but you need
; to use those registers for a syscall (which overwrites them).
; Solution: Push them onto the stack, do your work, then pop them back.
; ============================================================================

    ; ---- Step 1: Put important values in registers ----
    mov rax, 12345          ; rax has an important value
    mov rbx, 67890          ; rbx has an important value

    ; ---- Print message 1 ----
    ; PROBLEM: sys_write needs rax=1, but rax currently has 12345!
    ; SOLUTION: Save rax and rbx on the stack first

    push rax                ; push 12345 onto the stack (RSP goes down by 8)
    push rbx                ; push 67890 onto the stack (RSP goes down by 8)

    ; Stack now looks like (top to bottom):
    ;   67890    ← RSP points here (top, last thing pushed)
    ;   12345
    ;   ...

    ; Now we can safely use rax and rbx for the syscall
    mov rax, 1
    mov rdi, 1
    mov rsi, msg1
    mov rdx, len1
    syscall

    ; Print message 2
    mov rax, 1
    mov rdi, 1
    mov rsi, msg2
    mov rdx, len2
    syscall

    ; ---- Step 2: Restore our important values ----
    ; IMPORTANT: Pop in REVERSE order!
    ; We pushed rax first, then rbx.
    ; So we pop rbx first, then rax.
    ; (Last In, First Out!)

    pop rbx                 ; rbx = 67890 again (RSP goes up by 8)
    pop rax                 ; rax = 12345 again (RSP goes up by 8)

    ; rax is back to 12345, rbx is back to 67890!

    ; Save them again so we can print message 3
    push rax
    push rbx

    mov rax, 1
    mov rdi, 1
    mov rsi, msg3
    mov rdx, len3
    syscall

    pop rbx
    pop rax

    ; ---- Print final message and exit ----
    ; (At this point rax=12345, rbx=67890 — still preserved!)
    push rax
    push rbx

    mov rax, 1
    mov rdi, 1
    mov rsi, msg4
    mov rdx, len4
    syscall

    pop rbx
    pop rax

    ; ---- Exit ----
    mov rax, 60
    mov rdi, 0
    syscall

; ============================================================================
; PUSH and POP summary:
;
;   push rax     →  RSP = RSP - 8, then store rax at [RSP]
;   pop rbx      →  load [RSP] into rbx, then RSP = RSP + 8
;
;   push 42      →  you can push constants too
;
; GOLDEN RULE: Every push must have a matching pop!
;   If you push 3 things, you must pop 3 things.
;   If you don't, RSP will be wrong and your program will crash.
;
; GOLDEN RULE: Pop in reverse order!
;   push rax     ; first
;   push rbx     ; second
;   push rcx     ; third
;   pop rcx      ; third out first
;   pop rbx      ; second out second
;   pop rax      ; first out last
; ============================================================================