; ============================================================================
; 02_addressing_modes.asm — All 5 Addressing Modes (64-bit)
; ============================================================================
;
; Build & Run:
;   nasm -f elf64 02_addressing_modes.asm
;   ld -o 02_addressing_modes 02_addressing_modes.o
;   ./02_addressing_modes
; ============================================================================
;
; ADDRESSING MODES = the different ways to tell the CPU where the data is
;
; 1. Register     — data is in a register
; 2. Immediate    — data is a constant number written in the code
; 3. Direct       — data is at a memory address (variable name)
; 4. Direct-offset— data is at a memory address + some offset (arrays)
; 5. Indirect     — a register holds the memory address
;
; IMPORTANT RULE: You CANNOT move memory to memory directly!
;   mov [var1], [var2]   ; ILLEGAL!
;   You must go through a register:
;   mov al, [var2]       ; memory → register
;   mov [var1], al       ; register → memory
;
; SQUARE BRACKETS [ ] mean "go to this address and get the value there"
;   mov al, num      ; al gets the ADDRESS of num
;   mov al, [num]    ; al gets the VALUE stored at num
; ============================================================================

section .data
    ; ---- Variables for demonstrations ----
    num db 20                           ; a single byte variable, value = 20
    nums db 10, 5, 3, 7                ; an array of 4 bytes

    ; ---- Messages ----
    msg1 db "Mode 1: Register addressing done", 10
    len1 equ $ - msg1

    msg2 db "Mode 2: Immediate addressing done", 10
    len2 equ $ - msg2

    msg3 db "Mode 3: Direct memory addressing done", 10
    len3 equ $ - msg3

    msg4 db "Mode 4: Direct-offset addressing done", 10
    len4 equ $ - msg4

    msg5 db "Mode 5: Indirect memory addressing done", 10
    len5 equ $ - msg5

section .text
    global _start

_start:

; ============================================================================
; MODE 1: REGISTER ADDRESSING
; One or both operands are registers. Data lives in registers.
; ============================================================================

    mov rax, rbx            ; copy value from rbx into rax
    mov rcx, rdx            ; copy value from rdx into rcx
    mov rsi, rdi            ; copy value from rdi into rsi

    ; Print confirmation
    mov rax, 1
    mov rdi, 1
    mov rsi, msg1
    mov rdx, len1
    syscall

; ============================================================================
; MODE 2: IMMEDIATE ADDRESSING
; One of the arguments is a constant (a number written directly in the code).
; The constant is "immediately" available — no need to look it up in memory.
; ============================================================================

    mov rax, 42             ; put the number 42 into rax
    mov rbx, 100            ; put the number 100 into rbx
    add rax, 10             ; add 10 to rax (rax is now 52)
    sub rbx, 25             ; subtract 25 from rbx (rbx is now 75)

    ; Print confirmation
    mov rax, 1
    mov rdi, 1
    mov rsi, msg2
    mov rdx, len2
    syscall

; ============================================================================
; MODE 3: DIRECT MEMORY ADDRESSING
; One operand is a variable name (which represents a memory address).
; The variable name is looked up in the symbol table to find its offset.
; Square brackets [ ] mean "get the value at this address."
; ============================================================================

    mov al, [num]           ; al = 20 (the value stored at address "num") al is 8 byte so it starts from rax, eax then al
    add byte [num], 10      ; add 10 to the value at "num" (num is now 30)
                            ; "byte" tells NASM the size of data at that address

    ; Why "byte" keyword?
    ; When you write [num], NASM doesn't always know if you mean
    ; 1 byte, 2 bytes, or 4 bytes. "byte" says "treat this as 1 byte"
    ; Other options: word (2 bytes), dword (4 bytes), qword (8 bytes)

    ; Print confirmation
    mov rax, 1
    mov rdi, 1
    mov rsi, msg3
    mov rdx, len3
    syscall

; ============================================================================
; MODE 4: DIRECT-OFFSET MEMORY ADDRESSING
; Access array elements by adding an offset to the variable name.
; offset = how many bytes to skip from the start.
;
; Our array:  nums db 10, 5, 3, 7
;
;   Address:    nums    nums+1   nums+2   nums+3
;   Value:      10      5        3        7
;   Offset:     +0      +1       +2       +3
;
; Since each element is 1 byte (db), offset increases by 1 per element.
; If it were dw (2 bytes each), offset would increase by 2 per element.
; ============================================================================

    mov al, [nums]          ; al = 10 (first element, offset 0)
    mov al, [nums+1]        ; al = 5  (second element, offset 1)
    mov al, [nums+2]        ; al = 3  (third element, offset 2)
    mov al, [nums+3]        ; al = 7  (fourth element, offset 3)

    ; Print confirmation
    mov rax, 1
    mov rdi, 1
    mov rsi, msg4
    mov rdx, len4
    syscall

; ============================================================================
; MODE 5: INDIRECT MEMORY ADDRESSING
; A register holds the memory address, and you use [ ] around the register
; to access the value at that address. Useful for walking through arrays.
;
; Think of it like a pointer in C:
;   rbx = &nums;       // rbx holds the address
;   *rbx = 20;         // write 20 to that address
;   rbx += 2;          // move pointer forward
;   *rbx = 15;         // write 15 to the new address
; ============================================================================

    mov rbx, nums           ; rbx = address of nums (NOT the value 10!)
                            ; rbx is now a "pointer" to the array

    mov byte [rbx], 20      ; go to the address in rbx, put 20 there
                            ; nums is now: 20, 5, 3, 7

    add rbx, 1              ; move the pointer forward 1 byte
    mov byte [rbx], 99      ; put 99 at this new address
                            ; nums is now: 20, 99, 3, 7

    add rbx, 1              ; move forward again
    mov byte [rbx], 15      ; put 15 here
                            ; nums is now: 20, 99, 15, 7

    ; Print confirmation
    mov rax, 1
    mov rdi, 1
    mov rsi, msg5
    mov rdx, len5
    syscall

; ============================================================================
; EXIT
; ============================================================================

    mov rax, 60             ; sys_exit (64-bit syscall number)
    mov rdi, 0              ; exit code 0
    syscall