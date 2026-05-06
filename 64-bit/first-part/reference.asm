; ============================================================================
; 00_reference.asm — CHEAT SHEET (Do not run this — it's just notes!)
; ============================================================================
;
; 64-BIT SYSCALLS (used with "syscall" instruction)
; ============================================================================
;
; ┌─────────┬─────────────┬─────────┬──────────────┬──────────────┐
; │   RAX   │   Syscall   │   RDI   │     RSI      │     RDX      │
; ├─────────┼─────────────┼─────────┼──────────────┼──────────────┤
; │    0    │  sys_read   │ fd (0)  │ buffer addr  │ bytes to read│
; │    1    │  sys_write  │ fd (1)  │ string addr  │ bytes to write│
; │   60    │  sys_exit   │ exit code│     —       │     —        │
; └─────────┴─────────────┴─────────┴──────────────┴──────────────┘
;
; fd = file descriptor:  0 = stdin, 1 = stdout, 2 = stderr
;
; ============================================================================
;
; 32-BIT SYSCALLS (used with "int 0x80")
; ============================================================================
;
; ┌─────────┬─────────────┬─────────┬──────────────┬──────────────┐
; │   EAX   │   Syscall   │   EBX   │     ECX      │     EDX      │
; ├─────────┼─────────────┼─────────┼──────────────┼──────────────┤
; │    1    │  sys_exit   │ exit code│     —       │     —        │
; │    3    │  sys_read   │ fd (0)  │ buffer addr  │ bytes to read│
; │    4    │  sys_write  │ fd (1)  │ string addr  │ bytes to write│
; └─────────┴─────────────┴─────────┴──────────────┴──────────────┘
;
; NOTE: syscall numbers are DIFFERENT between 32-bit and 64-bit!
;   sys_exit:  EAX=1 (32-bit)  vs  RAX=60 (64-bit)
;   sys_write: EAX=4 (32-bit)  vs  RAX=1  (64-bit)
;   sys_read:  EAX=3 (32-bit)  vs  RAX=0  (64-bit)
;
; ============================================================================
;
; REGISTER QUICK REFERENCE
; ============================================================================
;
; 64-bit    32-bit    16-bit    8-bit         Role
; ──────    ──────    ──────    ─────         ────
; rax       eax       ax        ah + al       Accumulator / syscall number
; rbx       ebx       bx        bh + bl       Base register
; rcx       ecx       cx        ch + cl       Counter (loops)
; rdx       edx       dx        dh + dl       Data / I/O / remainder
; rsi       esi       si        sil           Source index / syscall arg 2
; rdi       edi       di        dil           Dest index / syscall arg 1
; rsp       esp       sp        spl           Stack pointer (don't touch!)
; rbp       ebp       bp        bpl           Base pointer (functions)
;
; ============================================================================
;
; BUILD COMMANDS
; ============================================================================
;
; 32-bit:
;   nasm -f elf file.asm
;   ld -m elf_i386 -s -o file file.o
;   ./file
;
; 64-bit:
;   nasm -f elf64 file.asm
;   ld -o file file.o
;   ./file
;
; Or just use:
;   ./build.sh file         (32-bit)
;   ./build.sh file 64      (64-bit)
;
; ============================================================================