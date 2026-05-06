; ============================================================================
; 05b_jump_reference.asm — Complete Jump Instructions Reference
; ============================================================================
;
; DO NOT RUN THIS FILE — it's a reference sheet only.
;
; ============================================================================
; ALL CONDITIONAL JUMPS — used after CMP
; ============================================================================
;
; SIGNED comparisons (for numbers that can be negative):
; ┌──────────┬───────────────────────────────┬─────────────────────┐
; │ Instruction │ Meaning                    │ Jumps when...       │
; ├──────────┼───────────────────────────────┼─────────────────────┤
; │ je       │ jump if equal                 │ al == value         │
; │ jne      │ jump if not equal             │ al != value         │
; │ jg       │ jump if greater               │ al > value          │
; │ jge      │ jump if greater or equal      │ al >= value         │
; │ jl       │ jump if less                  │ al < value          │
; │ jle      │ jump if less or equal         │ al <= value         │
; └──────────┴───────────────────────────────┴─────────────────────┘
;
; UNSIGNED comparisons (for numbers that are always positive):
; ┌──────────┬───────────────────────────────┬─────────────────────┐
; │ Instruction │ Meaning                    │ Jumps when...       │
; ├──────────┼───────────────────────────────┼─────────────────────┤
; │ je       │ jump if equal                 │ al == value         │
; │ jne      │ jump if not equal             │ al != value         │
; │ ja       │ jump if above                 │ al > value          │
; │ jae      │ jump if above or equal        │ al >= value         │
; │ jb       │ jump if below                 │ al < value          │
; │ jbe      │ jump if below or equal        │ al <= value         │
; └──────────┴───────────────────────────────┴─────────────────────┘
;
; OTHER jumps (check specific flags):
; ┌──────────┬───────────────────────────────┬─────────────────────┐
; │ Instruction │ Meaning                    │ Jumps when...       │
; ├──────────┼───────────────────────────────┼─────────────────────┤
; │ jmp      │ unconditional jump            │ ALWAYS              │
; │ jz       │ jump if zero                  │ ZF = 1 (same as je) │
; │ jnz      │ jump if not zero              │ ZF = 0 (same as jne)│
; │ js       │ jump if sign (negative)       │ SF = 1              │
; │ jns      │ jump if no sign (positive)    │ SF = 0              │
; │ jo       │ jump if overflow              │ OF = 1              │
; │ jno      │ jump if no overflow           │ OF = 0              │
; │ jc       │ jump if carry                 │ CF = 1              │
; │ jnc      │ jump if no carry              │ CF = 0              │
; └──────────┴───────────────────────────────┴─────────────────────┘
;
; ============================================================================
; COMMON PATTERNS — How to write if/else in assembly
; ============================================================================
;
; --- IF statement ---
;
; Python:
;   if x == 5:
;       do_something()
;
; Assembly (note: we jump OVER the code if condition is FALSE):
;   cmp al, 5
;   jne .skip           ; if NOT equal, skip over
;       ; do_something
;   .skip:
;
;
; --- IF/ELSE statement ---
;
; Python:
;   if x > 10:
;       do_this()
;   else:
;       do_that()
;
; Assembly:
;   cmp al, 10
;   jle .else_part      ; if NOT greater (i.e. less or equal), go to else
;       ; do_this
;       jmp .end_if     ; skip over the else part
;   .else_part:
;       ; do_that
;   .end_if:
;
;
; --- IF/ELIF/ELSE statement ---
;
; Python:
;   if x == 1:
;       option_a()
;   elif x == 2:
;       option_b()
;   else:
;       option_c()
;
; Assembly:
;   cmp al, 1
;   je .option_a
;   cmp al, 2
;   je .option_b
;   jmp .option_c       ; none matched, go to else
;
;   .option_a:
;       ; option_a code
;       jmp .end_if
;   .option_b:
;       ; option_b code
;       jmp .end_if
;   .option_c:
;       ; option_c code
;   .end_if:
;
;
; ============================================================================
; COMMON PATTERNS — How to write loops in assembly
; ============================================================================
;
; --- While loop ---
;
; Python:
;   while x > 0:
;       x -= 1
;
; Assembly:
;   .while:
;       cmp al, 0
;       jle .end_while  ; if al <= 0, exit loop
;       dec al
;       jmp .while      ; go back to check again
;   .end_while:
;
;
; --- For loop (count up) ---
;
; Python:
;   for i in range(0, 10):
;       do_something(i)
;
; Assembly:
;   mov rcx, 0          ; i = 0
;   .for:
;       cmp rcx, 10
;       jge .end_for    ; if i >= 10, stop
;       ; do_something with rcx as i
;       inc rcx         ; i += 1
;       jmp .for
;   .end_for:
;
;
; --- For loop (count down) ---
;
; Python:
;   for i in range(10, 0, -1):
;       do_something(i)
;
; Assembly:
;   mov rcx, 10
;   .for:
;       ; do_something with rcx as i
;       dec rcx
;       cmp rcx, 0
;       jne .for        ; if rcx != 0, keep going
;
;
; ============================================================================
; OTHER USEFUL INSTRUCTIONS
; ============================================================================
;
; neg al      — flip sign: 5 becomes -5, -3 becomes 3
; inc al      — add 1 to al (same as add al, 1)
; dec al      — subtract 1 from al (same as sub al, 1)
; test al, al — like cmp al, 0 but faster (sets flags based on AND)
; xor rax,rax — fastest way to set rax to 0
; ============================================================================