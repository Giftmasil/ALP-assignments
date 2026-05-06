; ============================================================================
; 01_registers.asm — Understanding Registers (64-bit)
; ============================================================================
;
; Build & Run:
;   nasm -f elf64 01_registers.asm
;   ld -o 01_registers 01_registers.o
;   ./01_registers
;
; Or with build.sh:
;   ./build.sh 01_registers 64
; ============================================================================
;
; REGISTERS ARE TINY STORAGE BOXES INSIDE THE CPU
; You only get 8 main ones. That's it.
;
; 64-bit name    32-bit    16-bit    8-bit high + low    Purpose
; ─────────────────────────────────────────────────────────────────
; rax            eax       ax        ah + al             Accumulator
; rbx            ebx       bx        bh + bl             Base register
; rcx            ecx       cx        ch + cl             Counter
; rdx            edx       dx        dh + dl             Data register
; rsi            esi       si        —  + sil            Source index
; rdi            edi       di        —  + dil            Destination index
; rsp            esp       sp        —                   Stack pointer
; rbp            ebp       bp        —                   Base pointer
;
; The smaller names access the SAME register, just fewer bits:
;
;   rax (64 bits):  [???????? ???????? ???????? ???????? ???????? ???????? ???????? ????????]
;   eax (32 bits):                                      [???????? ???????? ???????? ????????]
;    ax (16 bits):                                                          [???????? ????????]
;    ah (8 bits):                                                           [????????]
;    al (8 bits):                                                                    [????????]
;
; ============================================================================

section .data
    ; Messages to print for each demonstration
    msg1 db "1. Registers demo running!", 10     ; 10 = newline (decimal)
    len1 equ $ - msg1

    msg2 db "2. Moved values between registers", 10
    len2 equ $ - msg2

    msg3 db "3. Used smaller parts of registers", 10
    len3 equ $ - msg3

    msg4 db "4. All done!", 10
    len4 equ $ - msg4

section .text
    global _start

_start:
    ; ---- Print message 1 ----
    mov rax, 1              ; syscall number: sys_write
    mov rdi, 1              ; file descriptor: stdout (screen)
    mov rsi, msg1           ; address of string to print
    mov rdx, len1           ; how many bytes to print
    syscall                 ; go!

    ; ---- Demonstrate moving values between registers ----
    mov rax, 100            ; rax = 100
    mov rbx, 200            ; rbx = 200
    mov rcx, rax            ; rcx = rax = 100 (copy, rax still has 100)
    mov rdx, rbx            ; rdx = rbx = 200

    ; At this point:
    ; rax = 100, rbx = 200, rcx = 100, rdx = 200

    ; Print message 2
    mov rax, 1
    mov rdi, 1
    mov rsi, msg2
    mov rdx, len2
    syscall

    ; ---- Demonstrate smaller register parts ----
    mov rax, 0              ; clear entire rax (all 64 bits become 0)
    mov al, 65              ; put 65 in the lowest 8 bits only (65 = ASCII 'A')
                            ; rax is now 0x0000000000000041
    mov ah, 66              ; put 66 in bits 8-15 (66 = ASCII 'B')
                            ; rax is now 0x0000000000004241
    mov ax, 0               ; clear the lower 16 bits
                            ; rax is now 0x0000000000000000
    mov eax, 12345          ; set lower 32 bits
                            ; NOTE: this also clears the upper 32 bits!

    ; Print message 3
    mov rax, 1
    mov rdi, 1
    mov rsi, msg3
    mov rdx, len3
    syscall

    ; ---- Print message 4 ----
    mov rax, 1
    mov rdi, 1
    mov rsi, msg4
    mov rdx, len4
    syscall

    ; ---- Exit the program ----
    mov rax, 60             ; syscall number: sys_exit (60 in 64-bit!)
    mov rdi, 0              ; exit code 0 (success)
    syscall