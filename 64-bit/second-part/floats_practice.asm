; ============================================================================
; 14b_floats_practice.asm — XMM Float Arithmetic in Action
; ============================================================================
;
; Build:
;   nasm -f elf64 14b_floats_practice.asm
;   gcc -o 14b_floats_practice 14b_floats_practice.o -no-pie
;   ./14b_floats_practice
; ============================================================================

extern printf, scanf
global main
default rel

section .data
    ; Constants
    pi dq 3.14159265358979
    nine dq 9.0
    five dq 5.0
    thirty_two dq 32.0

    ; Test values for comparison
    val_a dq 7.5
    val_b dq 3.2

    ; Prompts
    prompt_r db "Enter radius: ", 0
    prompt_c db "Enter temperature in Celsius: ", 0
    scan_fmt db "%lf", 0

    ; Output formats
    fmt_area db "Circle area = pi * %.2f * %.2f = %.4f", 10, 0
    fmt_temp db "%.2f C = %.2f F", 10, 0
    fmt_sqrt db "sqrt(%.2f) = %.4f", 10, 0
    fmt_cmp db "Comparing: %.2f is %s %.2f", 10, 0
    fmt_conv db "Integer 42 as double = %.2f", 10, 0
    fmt_trunc db "Double 9.87 truncated to integer = %d", 10, 0
    fmt_vec db "Vector add: [%.1f, %.1f, %.1f, %.1f]", 10, 0

    str_greater db "greater than", 0
    str_less db "less than", 0
    str_equal db "equal to", 0

    ; Packed vectors (must be 16-byte aligned!)
    align 16
    vec1 dd 1.0, 2.0, 3.0, 4.0
    align 16
    vec2 dd 5.0, 6.0, 7.0, 8.0

    trunc_val dq 9.87

section .bss
    radius dq 1
    celsius dq 1
    result dq 1
    temp_save dq 1

    align 16
    vec_result resd 4
    ; Individual doubles for printing vector results
    vr0 dq 1
    vr1 dq 1
    vr2 dq 1
    vr3 dq 1

section .text
main:
    push rbp
    mov rbp, rsp
    sub rsp, 16

    ; ---- Read radius ----
    lea rdi, [prompt_r]
    xor rax, rax
    call printf

    lea rdi, [scan_fmt]
    lea rsi, [radius]
    xor rax, rax
    call scanf

    ; ---- Read celsius ----
    lea rdi, [prompt_c]
    xor rax, rax
    call printf

    lea rdi, [scan_fmt]
    lea rsi, [celsius]
    xor rax, rax
    call scanf

    ; ================================================================
    ; 1. CIRCLE AREA: A = pi * r * r  (using mulsd)
    ; ================================================================
    movsd xmm0, [pi]               ; xmm0 = pi
    mulsd xmm0, [radius]           ; xmm0 = pi * r
    mulsd xmm0, [radius]           ; xmm0 = pi * r * r
    movsd [result], xmm0           ; save result

    lea rdi, [fmt_area]
    movsd xmm0, [radius]           ; arg1: r
    movsd xmm1, [radius]           ; arg2: r
    movsd xmm2, [result]           ; arg3: area
    mov rax, 3
    call printf

    ; ================================================================
    ; 2. CELSIUS TO FAHRENHEIT: F = C * 9/5 + 32  (using mulsd, divsd, addsd)
    ; ================================================================
    movsd xmm0, [celsius]          ; xmm0 = C
    mulsd xmm0, [nine]             ; xmm0 = C * 9
    divsd xmm0, [five]             ; xmm0 = C * 9/5
    addsd xmm0, [thirty_two]       ; xmm0 = C * 9/5 + 32
    movsd [result], xmm0

    lea rdi, [fmt_temp]
    movsd xmm0, [celsius]
    movsd xmm1, [result]
    mov rax, 2
    call printf

    ; ================================================================
    ; 3. SQUARE ROOT  (using sqrtsd)
    ; ================================================================
    sqrtsd xmm0, [radius]          ; xmm0 = sqrt(radius)
    movsd [result], xmm0

    lea rdi, [fmt_sqrt]
    movsd xmm0, [radius]
    movsd xmm1, [result]
    mov rax, 2
    call printf

    ; ================================================================
    ; 4. COMPARISON  (using ucomisd)
    ; ================================================================
    movsd xmm0, [val_a]
    ucomisd xmm0, [val_b]          ; compare 7.5 with 3.2, sets CPU flags

    lea rdx, [str_equal]
    ja .is_greater
    jb .is_less
    jmp .print_cmp

.is_greater:
    lea rdx, [str_greater]
    jmp .print_cmp
.is_less:
    lea rdx, [str_less]

.print_cmp:
    lea rdi, [fmt_cmp]
    movsd xmm0, [val_a]
    movsd xmm1, [val_b]
    mov rax, 2
    call printf

    ; ================================================================
    ; 5. CONVERSION: integer to double  (using cvtsi2sd)
    ; ================================================================
    mov eax, 42
    cvtsi2sd xmm0, eax             ; xmm0 = 42.0
    movsd [result], xmm0

    lea rdi, [fmt_conv]
    movsd xmm0, [result]
    mov rax, 1
    call printf

    ; ================================================================
    ; 6. CONVERSION: double to integer  (using cvttsd2si — truncates!)
    ; ================================================================
    movsd xmm0, [trunc_val]        ; xmm0 = 9.87
    cvttsd2si eax, xmm0            ; eax = 9 (truncated, not rounded)

    lea rdi, [fmt_trunc]
    mov esi, eax
    xor rax, rax                    ; 0 float args (printing integer)
    call printf

    ; ================================================================
    ; 7. PACKED ADD: vec1 + vec2 = ?  (using addps — 4 floats at once!)
    ; ================================================================
    movaps xmm0, [vec1]            ; xmm0 = [1.0, 2.0, 3.0, 4.0]
    addps xmm0, [vec2]             ; xmm0 = [6.0, 8.0, 10.0, 12.0]
    movaps [vec_result], xmm0      ; store packed result

    ; printf needs doubles, so convert each single to double
    movss xmm0, [vec_result]
    cvtss2sd xmm0, xmm0
    movss xmm1, [vec_result + 4]
    cvtss2sd xmm1, xmm1
    movss xmm2, [vec_result + 8]
    cvtss2sd xmm2, xmm2
    movss xmm3, [vec_result + 12]
    cvtss2sd xmm3, xmm3

    lea rdi, [fmt_vec]
    mov rax, 4                      ; 4 float args
    call printf

    ; Exit
    add rsp, 16
    pop rbp
    xor rax, rax
    ret

section .note.GNU-stack noalloc noexec nowrite progbits