; ============================================================================
; 11_division_practice.asm — Practice: Read two numbers, divide, print result
; ============================================================================
;
; Build & Run:
;   ./build.sh 11_division_practice 64
;
; What it does:
;   - Asks for a dividend (number to divide)
;   - Asks for a divisor (what to divide by)
;   - Prints: "<dividend> ÷ <divisor> = <quotient> remainder <remainder>"
;
; This combines EVERYTHING you have learned so far:
;   reading input, ASCII conversion, division, and printing multi-digit numbers
; ============================================================================

section .data
    prompt1     db "Enter dividend: "
    prompt1_len equ $ - prompt1

    prompt2     db "Enter divisor: "
    prompt2_len equ $ - prompt2

    msg_equals  db " = "
    msg_equals_len equ $ - msg_equals

    msg_rem     db " remainder "
    msg_rem_len equ $ - msg_rem

    msg_div     db " / "
    msg_div_len equ $ - msg_div

    newline     db 10

    sysread     equ 0
    stdin       equ 0
    syswrite    equ 1
    stdout      equ 1
    sys_exit    equ 60

section .bss
    num1    resb 4          ; space for up to 3 digit number + newline
    num2    resb 4
    digit   resb 1          ; temp space for one character when printing

section .text
    global _start

_start:

; ---- Read dividend ----
    mov rax, syswrite
    mov rdi, stdout
    mov rsi, prompt1
    mov rdx, prompt1_len
    syscall

    mov rax, sysread
    mov rdi, stdin
    mov rsi, num1
    mov rdx, 4
    syscall
    ; rax now = how many bytes were actually read (e.g. "17\n" = 3 bytes)
    ; We'll use this length later to convert all digit characters

; ---- Read divisor ----
    mov rax, syswrite
    mov rdi, stdout
    mov rsi, prompt2
    mov rdx, prompt2_len
    syscall

    mov rax, sysread
    mov rdi, stdin
    mov rsi, num2
    mov rdx, 4
    syscall

; ---- Convert num1 from ASCII string to actual integer ----
;
; When you type "17" and press Enter, num1 holds: ['1', '7', '\n']
; We need to convert that to the integer 17.
;
; Algorithm:
;   result = 0
;   for each character (stopping at newline):
;       result = result * 10 + (character - '0')
;
; For "17":
;   result = 0 * 10 + ('1' - 48) = 0 + 1 = 1
;   result = 1 * 10 + ('7' - 48) = 10 + 7 = 17
;
    mov r12, 0              ; r12 = running total (will become num1's integer)
    mov r14, num1           ; r14 = pointer to current character in num1

.convert_num1:
    movzx rax, byte [r14]   ; load the current character into rax (zero-extended)
                            ; movzx = "move zero-extend" fills upper bits with zeros
    cmp al, 10              ; is it newline (ASCII 10)?
    je .done_convert_num1   ; yes → done converting
    cmp al, 13              ; is it carriage return (ASCII 13)? (just in case)
    je .done_convert_num1

    sub al, '0'             ; convert ASCII digit to number: '7' - 48 = 7

    imul r12, r12, 10       ; r12 = r12 * 10  (shift existing digits left)
                            ; imul = signed multiply with 3 operands
                            ; imul dest, src1, immediate
    add r12, rax            ; r12 = r12 + new digit

    inc r14                 ; move pointer to next character
    jmp .convert_num1

.done_convert_num1:
    ; r12 now holds the integer value of num1

; ---- Convert num2 from ASCII string to integer (same logic) ----
    mov r13, 0              ; r13 = running total for num2
    mov r14, num2

.convert_num2:
    movzx rax, byte [r14]
    cmp al, 10
    je .done_convert_num2
    cmp al, 13
    je .done_convert_num2
    sub al, '0'
    imul r13, r13, 10
    add r13, rax
    inc r14
    jmp .convert_num2

.done_convert_num2:
    ; r13 now holds the integer value of num2

; ---- Print num1 (to show "17 / 3 = ...") ----
    mov r15, r12            ; save num2 in r15 (we'll need it after printing)
    call print_number       ; print r12 (num1) — see function below

    ; Print " / "
    mov rax, syswrite
    mov rdi, stdout
    mov rsi, msg_div
    mov rdx, msg_div_len
    syscall

    ; Print num2
    mov r12, r13            ; put num2 into r12 for the print function
    push r13                ; save divisor (r13) — print_number might use r13
    call print_number
    pop r13                 ; restore divisor

    ; Print " = "
    mov rax, syswrite
    mov rdi, stdout
    mov rsi, msg_equals
    mov rdx, msg_equals_len
    syscall

; ---- Perform the division ----
    mov rax, r15            ; put dividend back in rax
    xor rdx, rdx            ; CLEAR rdx before dividing!
    div r13                 ; rax = quotient, rdx = remainder

    push rdx                ; save remainder — we need to print quotient first

; ---- Print the quotient ----
    mov r12, rax
    call print_number

    ; Print " remainder "
    mov rax, syswrite
    mov rdi, stdout
    mov rsi, msg_rem
    mov rdx, msg_rem_len
    syscall

; ---- Print the remainder ----
    pop r12                 ; get remainder back
    call print_number

; ---- Newline and exit ----
    mov rax, syswrite
    mov rdi, stdout
    mov rsi, newline
    mov rdx, 1
    syscall

    mov rax, sys_exit
    xor rdi, rdi
    syscall

; ============================================================================
; FUNCTION: print_number
; Input:  r12 = the integer to print (any size, >= 0)
; Output: prints it to stdout
; Clobbers: rax, rbx, rdx, r13
; ============================================================================
print_number:
    push rbp
    mov rbp, rsp

    mov r13, 0              ; digit counter

    ; Edge case: if the number is 0, just print '0'
    cmp r12, 0
    jne .pn_extract
    mov byte [digit], '0'
    mov rax, syswrite
    mov rdi, stdout
    mov rsi, digit
    mov rdx, 1
    syscall
    pop rbp
    ret

    ; Phase 1: extract digits (push onto stack in reverse order)
.pn_extract:
    cmp r12, 0
    je .pn_print
    mov rax, r12
    xor rdx, rdx
    mov rbx, 10
    div rbx
    push rdx                ; push the last digit
    inc r13
    mov r12, rax            ; remove last digit from number
    jmp .pn_extract

    ; Phase 2: pop digits and print (now in correct order)
.pn_print:
    cmp r13, 0
    je .pn_done
    pop rax
    add al, '0'
    mov [digit], al
    push r13                ; save counter — syscall will clobber r13? no but good habit
    mov rax, syswrite
    mov rdi, stdout
    mov rsi, digit
    mov rdx, 1
    syscall
    pop r13
    dec r13
    jmp .pn_print

.pn_done:
    pop rbp
    ret

; ============================================================================
; NEW INSTRUCTION LEARNED: movzx
;
; movzx rax, byte [r14]
;
; Regular mov rax, [r14] would try to copy 8 bytes.
; But [r14] might only be 1 byte (a character).
; movzx copies the 1 byte and fills the upper bits of rax with ZEROS.
; This prevents garbage from old register values affecting your code.
;
; movzx = "MOVe with Zero eXtension"
;
; You'll see this a lot when working with byte-sized data in 64-bit registers.
; ============================================================================

; ============================================================================
; NEW INSTRUCTION LEARNED: imul with 3 operands
;
; imul r12, r12, 10
;
; This means: r12 = r12 * 10
; It's signed multiply but the 3-operand form lets you choose destination.
; Unlike the 1-operand "mul rbx" that always writes to RDX:RAX,
; this version: imul dest, src, immediate  — writes only to dest.
;
; Used here to shift the number left by one decimal place:
;   r12 = 1              (we read digit '1')
;   imul r12, r12, 10    → r12 = 10
;   add r12, 7           (we read digit '7')
;   → r12 = 17  ✓
; ============================================================================