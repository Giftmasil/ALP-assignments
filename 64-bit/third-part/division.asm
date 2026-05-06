; ============================================================================
; 09_division.asm — Division in 64-bit Assembly
; ============================================================================
;
; Build & Run:
;   ./build.sh 09_division 64
;
; This program demonstrates:
;   1. How DIV works (quotient and remainder)
;   2. Why you MUST clear RDX before dividing
;   3. Signed vs unsigned division
;   4. A real example: checking if a number is even or odd
; ============================================================================

; ============================================================================
; HOW DIV WORKS — The key rule
;
; DIV splits the DIVIDEND across two registers: RDX:RAX
; You give it a DIVISOR in any register (except rax/rdx)
;
; After DIV:
;   RAX = quotient   (the result of the division)
;   RDX = remainder  (what's left over)
;
; In maths:
;   17 ÷ 5 = 3 remainder 2
;   → rax = 3
;   → rdx = 2
;
; ALWAYS xor rdx, rdx before dividing.
; If you forget, the CPU reads RDX:RAX as a huge number and crashes.
; ============================================================================

; ============================================================================
; SIGNED vs UNSIGNED DIVISION
;
; DIV  = unsigned division (treats numbers as positive only, 0 to 2^64)
; IDIV = signed division   (treats numbers as signed, -2^63 to 2^63)
;
; For IDIV you also need to sign-extend RAX into RDX:
;   Use CQO (Convert Quadword to Octoword) instead of xor rdx, rdx
;   CQO fills RDX with copies of RAX's sign bit (0 if positive, all 1s if negative)
;
; Rule:
;   Dividing unsigned numbers → xor rdx, rdx  +  div
;   Dividing signed numbers   → cqo            +  idiv
; ============================================================================

section .data
    msg_quot  db "Quotient:  "
    msg_quot_len equ $ - msg_quot

    msg_rem   db "Remainder: "
    msg_rem_len equ $ - msg_rem

    msg_even  db "That number is even!", 10
    msg_even_len equ $ - msg_even

    msg_odd   db "That number is odd!", 10
    msg_odd_len equ $ - msg_odd

    newline db 10

section .bss
    output resb 1

section .text
    global _start

_start:

; ============================================================================
; EXAMPLE 1: Basic division — 17 ÷ 5
;
; Python equivalent:
;   a = 17
;   b = 5
;   quotient  = a // b    # = 3
;   remainder = a % b     # = 2
; ============================================================================

    mov rax, 17             ; dividend in rax
    xor rdx, rdx            ; ALWAYS clear rdx first! (rdx = 0)
    mov rbx, 5              ; divisor in any register you choose
    div rbx                 ; rax = 17 ÷ 5 = 3
                            ; rdx = 17 % 5 = 2

    ; Print "Quotient:  "
    push rax                ; ── SAVE rax because syscall overwrites it ──
    push rdx                ; ── SAVE rdx too ──
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_quot
    mov rdx, msg_quot_len
    syscall
    pop rdx                 ; ── RESTORE rdx ──
    pop rax                 ; ── RESTORE rax ──

    ; Print the quotient digit (rax = 3)
    push rdx                ; save remainder before we touch rax
    add al, '0'             ; 3 + 48 = 51 = ASCII '3'
    mov [output], al
    mov rax, 1
    mov rdi, 1
    mov rsi, output
    mov rdx, 1
    syscall
    ; print newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall
    pop rdx                 ; restore remainder

    ; Print "Remainder: "
    push rdx                ; save remainder again during syscall
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_rem
    mov rdx, msg_rem_len
    syscall
    pop rdx                 ; restore remainder

    ; Print the remainder digit (rdx = 2)
    mov rax, rdx            ; move remainder into rax to work with it
    add al, '0'             ; 2 + 48 = 50 = ASCII '2'
    mov [output], al
    mov rax, 1
    mov rdi, 1
    mov rsi, output
    mov rdx, 1
    syscall
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

; ============================================================================
; EXAMPLE 2: Even/Odd check using remainder
;
; If a number divided by 2 has remainder 0 → it's EVEN
; If remainder is 1 → it's ODD
;
; Python equivalent:
;   n = 14
;   if n % 2 == 0:
;       print("even")
;   else:
;       print("odd")
; ============================================================================

    mov rax, 14             ; the number to check
    xor rdx, rdx
    mov rbx, 2
    div rbx                 ; rdx = 14 % 2 = 0

    cmp rdx, 0              ; is remainder zero?
    jne .odd                ; if NOT zero, it's odd — jump

    ; It's even
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_even
    mov rdx, msg_even_len
    syscall
    jmp .done_even_odd

.odd:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_odd
    mov rdx, msg_odd_len
    syscall

.done_even_odd:

; ============================================================================
; EXIT
; ============================================================================
    mov rax, 60
    xor rdi, rdi
    syscall

; ============================================================================
; DIVISION SUMMARY:
;
; BEFORE dividing:
;   xor rdx, rdx        ← clear rdx (for unsigned, positive numbers)
;   cqo                 ← sign-extend rax into rdx (for signed/negative)
;
; THE DIVIDE:
;   div  rbx            ← unsigned: 0 to huge positive
;   idiv rbx            ← signed:   negative and positive
;
; AFTER dividing:
;   rax = quotient      ← the "how many times it goes in"
;   rdx = remainder     ← the "left over" (same as % in Python)
;
; COMMON CRASH CAUSE:
;   Forgetting xor rdx, rdx → CPU sees huge number in RDX:RAX → crash!
;   Error message: "Floating point exception" (misleading name)
; ============================================================================