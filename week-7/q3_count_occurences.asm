; q3_count_occurrences.asm — Week 7 Q3
; Part A: Count how many times a target value appears in an array.
; Part B (bonus): Print the position(s) where it appears (1-indexed).
; Build: ./build.sh week-7/q3_count_occurrences 64

section .data
    ; TODO: Define array, arr_len, target value
    ; TODO: Any output strings ("Count: ", "Found at position: ", newline)

section .text
    global _start

; TODO: (Optional) print macro

_start:
    ; --- Part A ---
    ; TODO: Set count = 0, index = 0, rcx = arr_len

.count_loop:
    ; TODO: Compare array[index] with target, increment count on match
    ; TODO: Increment index, LOOP back
    ; TODO: Print count

    ; --- Part B (bonus) ---
    ; TODO: Reset index = 0, rcx = arr_len

.pos_loop:
    ; TODO: On match, print position (index + 1)
    ; TODO: Increment index, LOOP back

.done:
    mov rax, 60
    xor rdi, rdi
    syscall