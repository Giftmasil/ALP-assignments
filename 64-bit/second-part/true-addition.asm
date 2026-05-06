; sum_multi.nasm
; Read two multi-digit integers from stdin, sum them, print result.
; NASM / Linux x86-64 syscalls

section .data
    prompt1 db "Enter first number: ", 0
    prompt1_len equ $ - prompt1

    prompt2 db "Enter second number: ", 0
    prompt2_len equ $ - prompt2

    out_prefix db "The sum is: ", 0
    out_prefix_len equ $ - out_prefix

    newline db 10

section .bss
    num1      resb 32    ; buffer for first number (max 31 chars + newline)
    num2      resb 32
    outbuf    resb 64    ; buffer to hold converted output (digits go near end)

section .text
    global _start

_start:
    ; --- Prompt 1 ---
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    mov rsi, prompt1
    mov rdx, prompt1_len
    syscall

    ; Read first input
    mov rax, 0              ; sys_read
    mov rdi, 0              ; stdin
    mov rsi, num1
    mov rdx, 32
    syscall
    mov r12, rax            ; r12 = bytes read for num1

    ; --- Prompt 2 ---
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt2
    mov rdx, prompt2_len
    syscall

    ; Read second input
    mov rax, 0
    mov rdi, 0
    mov rsi, num2
    mov rdx, 32
    syscall
    mov r13, rax            ; r13 = bytes read for num2

    ; --- Parse num1 into rax (signed) ---
    xor rax, rax            ; rax = 0 (accumulator)
    xor rbx, rbx            ; rbx = sign flag (0 = positive, 1 = negative)
    mov rsi, num1           ; rsi -> buffer
    mov rcx, r12            ; rcx = length
parse1_loop:
    cmp rcx, 0
    je parse1_done
    mov bl, [rsi]
    ; stop on newline or space or null
    cmp bl, 10              ; '\n'
    je parse1_done
    cmp bl, 13              ; '\r'
    je parse1_done
    cmp bl, ' '
    je parse1_done
    cmp bl, 9               ; tab
    je parse1_done
    cmp bl, '-'
    je parse1_minus
    cmp bl, '0'
    jl parse1_done
    cmp bl, '9'
    jg parse1_done
    ; digit: rax = rax * 10 + (bl - '0')
    movzx rdx, bl
    sub dl, '0'
    imul rax, rax, 10
    add rax, rdx
    inc rsi
    dec rcx
    jmp parse1_loop

parse1_minus:
    mov rbx, 1              ; negative
    inc rsi
    dec rcx
    jmp parse1_loop

parse1_done:
    test rbx, rbx
    jz parse1_ok
    neg rax                 ; apply sign if negative
parse1_ok:
    mov r14, rax            ; store parsed num1 in r14

    ; --- Parse num2 into rax (signed) ---
    xor rax, rax
    xor rbx, rbx
    mov rsi, num2
    mov rcx, r13
parse2_loop:
    cmp rcx, 0
    je parse2_done
    mov bl, [rsi]
    cmp bl, 10
    je parse2_done
    cmp bl, 13
    je parse2_done
    cmp bl, ' '
    je parse2_done
    cmp bl, 9
    je parse2_done
    cmp bl, '-'
    je parse2_minus
    cmp bl, '0'
    jl parse2_done
    cmp bl, '9'
    jg parse2_done
    movzx rdx, bl
    sub dl, '0'
    imul rax, rax, 10
    add rax, rdx
    inc rsi
    dec rcx
    jmp parse2_loop

parse2_minus:
    mov rbx, 1
    inc rsi
    dec rcx
    jmp parse2_loop

parse2_done:
    test rbx, rbx
    jz parse2_ok
    neg rax
parse2_ok:
    mov r15, rax            ; parsed num2 in r15

    ; --- Sum: r14 + r15 -> rax (signed) ---
    mov rax, r14
    add rax, r15            ; sum in rax

    ; --- Convert signed rax to ASCII in outbuf ---
    ; We'll write digits from the end of outbuf backwards.
    mov rsi, outbuf
    add rsi, 63             ; rsi -> one past end of outbuf (address to fill backwards)
    mov rbx, rsi            ; save end pointer in rbx

    ; handle sign
    xor rdx, rdx
    mov rdi, rax            ; rdi = value to convert
    cmp rdi, 0
    jge conv_positive
    neg rdi                 ; make positive for digit extraction
    mov byte [rsi-1], '-'   ; reserve a spot for '-' (we'll adjust pointer later)
    dec rsi
    mov dl, 1               ; sign flag = 1
    jmp conv_do

conv_positive:
    mov dl, 0               ; sign flag = 0

conv_do:
    ; if value == 0, write '0'
    cmp rdi, 0
    jne conv_loop
    dec rsi
    mov byte [rsi], '0'
    jmp conv_done

conv_loop:
    ; loop until rdi == 0: div by 10, remainder is digit
    xor rdx, rdx
    mov rcx, 10
    mov rax, rdi            ; dividend in rax
    div rcx                 ; quotient in rax, remainder in rdx
    add dl, '0'
    dec rsi
    mov [rsi], dl           ; store digit
    mov rdi, rax            ; rdi = quotient
    cmp rdi, 0
    jne conv_loop

conv_done:
    ; if negative sign was reserved earlier, it's already placed just before digits
    ; compute length = end - rsi
    mov rdx, rbx            ; rdx = end pointer
    sub rdx, rsi            ; rdx = length
    ; --- Print prefix ---
    mov rax, 1
    mov rdi, 1
    mov rsi, out_prefix
    mov rdx, out_prefix_len
    syscall

    ; --- Print number ---
    mov rax, 1
    mov rdi, 1
    mov rsi, rsi            ; pointer to string (already in rsi)
    ; rdx already holds length
    syscall

    ; --- Print newline ---
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    ; exit
    mov rax, 60
    xor rdi, rdi
    syscall