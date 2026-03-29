; q1_classify_number.asm — Week 7 Q1
; Classify digits 0–9 using LOOP, JMP, and macros:
;   0–3 → "Small Number" | 4–7 → "Average Number" | 8–9 → "Large Number"
; Build: ./build.sh week-7/q1_classify_number 64

section .data
    ; TODO: Define your message strings + lengths

section .bss
    ; TODO: Reserve any runtime buffers needed

section .text
    global _start

; TODO: Define your print macro (sys_write = 1, stdout fd = 1)
; %macro print 2
;     mov rax, 1
;     mov rdi, 1
;     mov rsi, %1
;     mov rdx, %2
;     syscall
; %endmacro

_start:
    ; TODO: Set up rcx as loop counter (0–9)
    ; TODO: Compare current digit → jump to small / average / large label
    ; TODO: LOOP back

.done:
    mov rax, 60
    xor rdi, rdi
    syscall