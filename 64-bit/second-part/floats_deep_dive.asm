; ============================================================================
; 14_floats_deep_dive.asm — REFERENCE ONLY (do not run)
; Complete Floating Point Guide — XMM / SSE Only
; ============================================================================


; ============================================================================
; 1. FLOAT DATA TYPES
; ============================================================================
;
; ┌──────────────────┬───────┬───────────┬──────────────────────────┐
; │ Type             │ Bytes │ Define    │ Precision                │
; ├──────────────────┼───────┼───────────┼──────────────────────────┤
; │ Single precision │   4   │ dd 3.14   │ ~7 decimal digits        │
; │ Double precision │   8   │ dq 3.14   │ ~15 decimal digits       │
; └──────────────────┴───────┴───────────┴──────────────────────────┘
;
; IEEE 754 format:
;   Single (32 bits): [1 sign] [8 exponent] [23 mantissa]   bias = 127
;   Double (64 bits): [1 sign] [11 exponent] [52 mantissa]  bias = 1023
;
; Defining variables:
;   section .data
;       pi dd 3.14159              ; single precision (4 bytes)
;       f1 dq 454.23e4             ; double precision (8 bytes)
;       two dd 2.0                 ; MUST have decimal point!
;       ; dd 2   ← NASM thinks this is an integer!
;       ; dd 2.0 ← NASM knows this is a float ✓
;
;   section .bss
;       result_s resd 1            ; 4 bytes for single
;       result_d resq 1            ; 8 bytes for double
;
; ============================================================================


; ============================================================================
; 2. XMM REGISTERS
; ============================================================================
;
; 16 registers: xmm0 through xmm15
; Each is 128 bits (16 bytes) wide.
;
; How they're used depends on the instruction suffix:
;
;   Scalar Single (ss) — lower 32 bits only:
;     ┌────────────┬────────────┬────────────┬────────────┐
;     │  unused    │  unused    │  unused    │  float     │
;     │  96-127    │  64-95     │  32-63     │  0-31      │
;     └────────────┴────────────┴────────────┴────────────┘
;
;   Scalar Double (sd) — lower 64 bits only:
;     ┌─────────────────────────┬─────────────────────────┐
;     │  unused                 │  double                 │
;     │  64-127                 │  0-63                   │
;     └─────────────────────────┴─────────────────────────┘
;
;   Packed Single (ps) — all 128 bits, 4 floats:
;     ┌────────────┬────────────┬────────────┬────────────┐
;     │  float 3   │  float 2   │  float 1   │  float 0   │
;     └────────────┴────────────┴────────────┴────────────┘
;
;   Packed Double (pd) — all 128 bits, 2 doubles:
;     ┌─────────────────────────┬─────────────────────────┐
;     │  double 1               │  double 0               │
;     └─────────────────────────┴─────────────────────────┘
;
; CALLING CONVENTION:
;   - ALL xmm registers are CALLER-SAVED (no exceptions!)
;   - Float return value → xmm0
;   - Float arguments → xmm0 through xmm7 (first 8)
;   - RAX must = number of float arguments before calling
;   - If you need a float after a call, save it to memory first
;
; ============================================================================


; ============================================================================
; 3. MOVING DATA — MOVSS AND MOVSD
; ============================================================================
;
; movss = Move Scalar Single (4 bytes)
; movsd = Move Scalar Double (8 bytes)
;
; One operand MUST be a register. No memory-to-memory.
;
;   movss xmm0, [var]        ; memory → register (load single)
;   movss [var], xmm0        ; register → memory (store single)
;   movss xmm0, xmm1         ; register → register (copy)
;
;   movsd xmm0, [var]        ; load double
;   movsd [var], xmm0        ; store double
;   movsd xmm0, xmm1         ; copy
;
; Other moves:
;   movq xmm0, rax            ; 64-bit integer register → xmm
;   movd xmm0, eax            ; 32-bit integer register → xmm
;
; ============================================================================


; ============================================================================
; 4. SCALAR ARITHMETIC
; ============================================================================
;
; Format: instruction xmm_dest, xmm_source_or_memory
; Result always goes in the destination (first operand).
;
; ---- Single Precision (ss suffix, 4 bytes) ----
;
;   addss xmm0, xmm1         ; xmm0 = xmm0 + xmm1
;   subss xmm0, xmm1         ; xmm0 = xmm0 - xmm1
;   mulss xmm0, xmm1         ; xmm0 = xmm0 * xmm1
;   divss xmm0, xmm1         ; xmm0 = xmm0 / xmm1
;   sqrtss xmm0, xmm1        ; xmm0 = sqrt(xmm1)
;
;   ; All also work with memory:
;   addss xmm0, [var]        ; xmm0 = xmm0 + var
;
; ---- Double Precision (sd suffix, 8 bytes) ----
;
;   addsd xmm0, xmm1         ; xmm0 = xmm0 + xmm1
;   subsd xmm0, xmm1         ; xmm0 = xmm0 - xmm1
;   mulsd xmm0, xmm1         ; xmm0 = xmm0 * xmm1
;   divsd xmm0, xmm1         ; xmm0 = xmm0 / xmm1
;   sqrtsd xmm0, xmm1        ; xmm0 = sqrt(xmm1)
;
; Unlike x87 (fld/fadd/fstp), XMM is straightforward:
;   No stack to manage
;   You pick which register to use
;   Result goes where you tell it
;
; ============================================================================


; ============================================================================
; 5. COMPARISON — UCOMISS AND UCOMISD
; ============================================================================
;
; These compare and set CPU FLAGS directly. Just compare and jump.
;
;   ucomiss xmm0, xmm1       ; compare singles, set flags
;   ucomiss xmm0, [var]      ; compare with memory
;
;   ucomisd xmm0, xmm1       ; compare doubles, set flags
;   ucomisd xmm0, [var]      ; compare with memory
;
; Then use UNSIGNED jumps:
;   ja   — xmm0 > source
;   jb   — xmm0 < source
;   je   — xmm0 == source
;   jae  — xmm0 >= source
;   jbe  — xmm0 <= source
;   jp   — one value is NaN (unordered)
;
; DO NOT use jg/jl/jge/jle — those are signed integer jumps!
;
; Checking against zero:
;   xorpd xmm1, xmm1          ; xmm1 = 0.0
;   ucomisd xmm0, xmm1        ; compare xmm0 with 0.0
;
; ============================================================================


; ============================================================================
; 6. CONVERSION INSTRUCTIONS
; ============================================================================
;
; Between float types:
;   cvtss2sd xmm0, xmm1       ; single → double
;   cvtsd2ss xmm0, xmm1       ; double → single
;
; Integer → float:
;   cvtsi2ss xmm0, eax         ; 32-bit int → single
;   cvtsi2ss xmm0, rax         ; 64-bit int → single
;   cvtsi2sd xmm0, eax         ; 32-bit int → double
;   cvtsi2sd xmm0, rax         ; 64-bit int → double
;
; Float → integer (truncate toward zero):
;   cvttss2si eax, xmm0        ; single → 32-bit int
;   cvttss2si rax, xmm0        ; single → 64-bit int
;   cvttsd2si eax, xmm0        ; double → 32-bit int
;   cvttsd2si rax, xmm0        ; double → 64-bit int
;
; The 'tt' means truncate. cvtss2si (single t) rounds to nearest instead.
;
; Example:
;   mov eax, 42
;   cvtsi2sd xmm0, eax         ; xmm0 = 42.0
;
;   movsd xmm0, [some_double]  ; xmm0 = 3.7
;   cvttsd2si eax, xmm0        ; eax = 3 (truncated, not rounded)
;
; ============================================================================


; ============================================================================
; 7. PACKED INSTRUCTIONS (SIMD)
; ============================================================================
;
; SIMD = Single Instruction, Multiple Data
; Do the same operation on multiple values simultaneously.
;
; MOVING PACKED DATA:
;   movaps xmm0, [vec]       ; load 4 aligned singles (16 bytes)
;   movapd xmm0, [vec]       ; load 2 aligned doubles (16 bytes)
;   movdqa xmm0, [vec]       ; load aligned 128-bit data
;   movdqu xmm0, [vec]       ; load unaligned 128-bit data (slower)
;
;   ; ALIGNED means the memory address must be divisible by 16
;   ; Use 'align 16' before your data:
;   align 16
;   vec dd 1.0, 2.0, 3.0, 4.0
;
; PACKED ARITHMETIC:
;   addps xmm0, xmm1         ; add 4 singles at once
;   addpd xmm0, xmm1         ; add 2 doubles at once
;   subps / subpd             ; subtract packed
;   mulps / mulpd             ; multiply packed
;   divps / divpd             ; divide packed
;   paddd xmm0, xmm1         ; add 4 packed 32-bit integers
;
; Example: vec1 + vec2 (4 floats each, ONE instruction)
;
;   section .data
;       align 16
;       vec1 dd 1.0, 2.0, 3.0, 4.0
;       align 16
;       vec2 dd 5.0, 6.0, 7.0, 8.0
;   section .bss
;       align 16
;       result resd 4
;
;   section .text
;       movaps xmm0, [vec1]     ; xmm0 = [1.0, 2.0, 3.0, 4.0]
;       addps xmm0, [vec2]      ; xmm0 = [6.0, 8.0, 10.0, 12.0]
;       movaps [result], xmm0   ; store all 4 results
;
; Without SIMD this would need 4 separate addss instructions.
; With SIMD it's done in ONE cycle. That's the power of packed operations.
;
; ============================================================================


; ============================================================================
; 8. PRINTF / SCANF WITH FLOATS
; ============================================================================
;
; PRINTING:
;   Integer args: rdi, rsi, rdx, rcx, r8, r9
;   Float args:   xmm0, xmm1, xmm2, xmm3, xmm4, xmm5, xmm6, xmm7
;   RAX = number of float args (REQUIRED!)
;   Printf always expects DOUBLES (8 bytes)
;
;   ; printf("Value: %f\n", 3.14)
;   lea rdi, [fmt]
;   movsd xmm0, [my_double]   ; float → xmm0 (NOT rsi!)
;   mov rax, 1                 ; 1 float arg
;   call printf
;
;   ; If your var is dd (single), convert first:
;   movss xmm0, [my_float]
;   cvtss2sd xmm0, xmm0       ; single → double
;   ; now pass xmm0 to printf
;
; READING:
;   ; scanf("%lf", &num)       ← %lf reads a double
;   lea rdi, [fmt]
;   lea rsi, [num]             ; address → rsi (integer arg, not float!)
;   xor rax, rax               ; 0 float args (address is integer)
;   call scanf
;
; ============================================================================


; ============================================================================
; 9. USEFUL TRICKS
; ============================================================================
;
; Zero a register:      xorpd xmm0, xmm0        ; or xorps, or pxor
; Negate:               subsd xmm1, xmm0 (where xmm1=0, gives -xmm0)
; Absolute value:       andpd xmm0, [abs_mask]   ; clear sign bit
; Copy:                 movsd xmm2, xmm0         ; xmm2 = xmm0
;
; Save across calls:
;   movsd [temp], xmm0       ; save to memory
;   call some_function
;   movsd xmm0, [temp]       ; restore from memory
;
; ============================================================================


; ============================================================================
; 10. COMMON FORMULAS
; ============================================================================
;
; Area of circle: A = π * r²
;   movsd xmm0, [pi]
;   mulsd xmm0, [radius]
;   mulsd xmm0, [radius]
;   movsd [area], xmm0
;
; Fahrenheit = C × 9/5 + 32
;   movsd xmm0, [celsius]
;   mulsd xmm0, [nine]
;   divsd xmm0, [five]
;   addsd xmm0, [thirty_two]
;   movsd [fahrenheit], xmm0
;
; Distance = √((x₂-x₁)² + (y₂-y₁)²)
;   movsd xmm0, [x2]
;   subsd xmm0, [x1]          ; xmm0 = x2-x1
;   mulsd xmm0, xmm0          ; xmm0 = (x2-x1)²
;   movsd xmm1, [y2]
;   subsd xmm1, [y1]          ; xmm1 = y2-y1
;   mulsd xmm1, xmm1          ; xmm1 = (y2-y1)²
;   addsd xmm0, xmm1          ; xmm0 = (x2-x1)² + (y2-y1)²
;   sqrtsd xmm0, xmm0         ; xmm0 = distance
;   movsd [dist], xmm0
;
; ============================================================================


; ============================================================================
; 11. INSTRUCTION QUICK REFERENCE
; ============================================================================
;
; SUFFIX GUIDE:
;   ss = Scalar Single    (1 × 4-byte float)
;   sd = Scalar Double    (1 × 8-byte float)
;   ps = Packed Single    (4 × 4-byte floats)
;   pd = Packed Double    (2 × 8-byte floats)
;
; SCALAR:
; ┌────────────────┬──────────────────────────────────────────┐
; │ Instruction    │ What it does                              │
; ├────────────────┼──────────────────────────────────────────┤
; │ movss / movsd  │ Move single / double                     │
; │ addss / addsd  │ Add                                      │
; │ subss / subsd  │ Subtract                                 │
; │ mulss / mulsd  │ Multiply                                 │
; │ divss / divsd  │ Divide                                   │
; │ sqrtss / sqrtsd│ Square root                              │
; │ ucomiss/ucomisd│ Compare and set CPU flags                │
; │ cvtsi2ss       │ Integer → single                        │
; │ cvtsi2sd       │ Integer → double                        │
; │ cvttss2si      │ Single → integer (truncate)             │
; │ cvttsd2si      │ Double → integer (truncate)             │
; │ cvtss2sd       │ Single → double                         │
; │ cvtsd2ss       │ Double → single                         │
; └────────────────┴──────────────────────────────────────────┘
;
; PACKED:
; ┌────────────────┬──────────────────────────────────────────┐
; │ movaps / movapd│ Move aligned packed (needs align 16)     │
; │ movdqa / movdqu│ Move 128 bits (aligned / unaligned)     │
; │ addps / addpd  │ Add packed (4 singles / 2 doubles)      │
; │ subps / subpd  │ Subtract packed                         │
; │ mulps / mulpd  │ Multiply packed                         │
; │ divps / divpd  │ Divide packed                           │
; │ paddd          │ Add packed doubleword integers           │
; └────────────────┴──────────────────────────────────────────┘
;
; ============================================================================