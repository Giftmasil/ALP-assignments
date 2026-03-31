; q2_add_arrays.asm — Week 7 Q2
; Add two arrays element by element (each pair must sum to ≤ 9), print results.
; Build: ./build.sh week-7/q2_add_arrays 64

%macro print 2
    push rax
    push rcx
    push rdx
    push rdi
    push rsi

    mov rax, 1
    mov rdi, 1
    mov rsi, %1
    mov rdx, %2
    syscall

    pop rsi
    pop rdi
    pop rdx
    pop rcx
    pop rax
%endmacro

section .data
    array_1 db 1, 3, 6, 5, 7, 6
    array_len equ $ - array_1

    array_2 db 4, 3, 2, 3, 2, 2

    newline db 10

section .bss
    answer resb 6

section .text
    global _start

_start:
    ; ---- Step 1: Add the two arrays element by element ----
    ; Use registers that syscall does NOT destroy
    mov r13, array_1        ; r13 = pointer to array_1
    mov r14, array_2        ; r14 = pointer to array_2
    mov r15, answer         ; r15 = pointer to answer array
    mov rcx, array_len      ; rcx = loop counter (6)

.calculate:
    mov al, [r13]           ; al = current element from array_1
    add al, [r14]           ; al = array_1[i] + array_2[i]
    mov [r15], al           ; store result in answer[i]

    inc r13                 ; next element in array_1
    inc r14                 ; next element in array_2
    inc r15                 ; next slot in answer
    dec rcx
    cmp rcx, 0
    jne .calculate          ; keep going until all elements done

    ; After this loop, answer contains: 5, 6, 8, 8, 9, 8

    ; ---- Step 2: Print each result as an ASCII digit ----
    mov r15, answer         ; r15 = pointer back to start of answer
    mov rcx, array_len      ; rcx = how many to print

.print_array:
    push rcx                ; save counter (syscall destroys rcx)

    ; Convert number to ASCII and store back temporarily
    mov al, [r15]           ; al = the number (e.g. 5)
    add al, '0'             ; al = ASCII digit (e.g. '5')
    mov [r15], al           ; store ASCII version back

    ; Print the digit
    print r15, 1

    ; Restore the number (undo the ASCII conversion)
    mov al, [r15]
    sub al, '0'
    mov [r15], al

    ; Print a newline
    print newline, 1

    pop rcx                 ; restore counter
    inc r15                 ; move to next element
    dec rcx
    cmp rcx, 0
    jne .print_array

.done:
    mov rax, 60
    xor rdi, rdi
    syscall