; q2_add_arrays.asm — Week 7 Q2
; Add two arrays element by element (each pair must sum to ≤ 9), print results.
; Build: ./build.sh week-7/q2_add_arrays 64

section .data
    ; TODO: Define array_a, array_b (5–6 elements each), and array_len
    ; TODO: Any output strings (newline, separator, etc.)

section .bss
    ; TODO: Reserve result buffer if needed

section .text
    global _start

; TODO: (Optional) print macro

_start:
    ; TODO: Set rcx = array_len, index register = 0

.loop:
    ; TODO: Load array_a[index] and array_b[index]
    ; TODO: Add them, convert to ASCII (+0x30), print
    ; TODO: Increment index, LOOP back

.done:
    mov rax, 60
    xor rdi, rdi
    syscall