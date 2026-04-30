%include "utils.asm"

extern printf
extern scanf

section .data
    prompt_base     db "Enter base: ", 0
    prompt_exp      db "Enter exponent: ", 0
    format_in       db "%ld", 0
    format_out      db "Result: %ld", 10, 0

section .bss
    base resq 1
    exp  resq 1

section .text
    global main

main:
    functionStart

    mov RDI, prompt_base
    mov RAX, 0
    call printf

    mov RDI, format_in
    mov RSI, base
    mov RAX, 0
    call scanf

    mov RDI, prompt_exp
    mov RAX, 0
    call printf

    mov RDI, format_in
    mov RSI, exp
    mov RAX, 0
    call scanf

    mov RDI, [base]
    mov RSI, [exp]
    call power


    mov RDI, format_out
    mov RSI, RAX
    mov RAX, 0
    call printf

    functionEnd
    exiting

; ---------------------------------------------------------
; Recursive Power Function
; Inputs:  RDI = base
;          RSI = exponent
; Outputs: RAX = result (base^exponent)
; ---------------------------------------------------------
power:
    functionStart 
    saveCalleeSaved

    cmp RSI, 0
    jne .recursive_step
    mov RAX, 1
    jmp .end_power

.recursive_step:
    ; Save the base (RDI) into a callee-saved register (RBX)
    ; so it survives the recursive call
    mov RBX, RDI
    
    ; Decrement exponent (exponent - 1)
    dec RSI
    
    ; Recursive call: power(base, exponent - 1)
    call power
    
    ; Multiply the returned result (in RAX) by the base (in RBX)
    imul RAX, RBX

.end_power:
    ; Restore callee-saved registers before returning
    retriveCalleeSaved
    
    functionEnd
    ret