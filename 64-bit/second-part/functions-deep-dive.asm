; ============================================================================
; 09_functions_deep_dive.asm — REFERENCE ONLY (do not run)
; ============================================================================
;
; EVERYTHING about functions in 64-bit assembly:
;   - How call/ret work
;   - Stack frames (prologue/epilogue)
;   - Stack balancing
;   - Parameter passing (registers and stack)
;   - Local variables
;   - Caller-saved vs callee-saved
;   - Calling C functions (printf, scanf)
;   - Recursion
;   - Your lecturer's macros explained
;
; ============================================================================


; ============================================================================
; 1. HOW CALL AND RET WORK
; ============================================================================
;
; call my_function:
;   Step 1: push the address of the NEXT instruction onto the stack
;           (this is the "return address" — where to come back to)
;   Step 2: jmp to my_function
;
; ret:
;   Step 1: pop the top of the stack into RIP (instruction pointer)
;           (this jumps back to right after the call)
;
; So call = push return_address + jmp
;    ret  = pop into RIP
;
; This is why the stack must be balanced — if RSP is wrong when
; ret executes, it pops the wrong value and jumps to garbage → crash.
;
; ============================================================================


; ============================================================================
; 2. STACK FRAME — THE PROLOGUE AND EPILOGUE
; ============================================================================
;
; PROLOGUE (start of every function):
;
;   push rbp          ; save the caller's base pointer on the stack
;   mov rbp, rsp      ; our base pointer = current top of stack
;
; Now RBP is our anchor. It won't move even if we push/pop things.
; We use RBP to find parameters and local variables.
;
; EPILOGUE (end of every function):
;
;   mov rsp, rbp      ; reset RSP to where it was after push rbp
;                      ; this automatically removes any local variables
;                      ; THIS IS STACK BALANCING
;   pop rbp            ; restore the caller's base pointer
;   ret                ; pop return address and jump there
;
;
; Your lecturer's macros:
;
;   %macro functionStart 0
;       push RBP
;       mov RBP, RSP
;   %endmacro
;
;   %macro functionEnd 0
;       mov RSP, RBP       ; ← stack balancing!
;       pop RBP
;   %endmacro
;
; ============================================================================


; ============================================================================
; 3. THE STACK FRAME LAYOUT
; ============================================================================
;
; After prologue, with parameters pushed by caller:
;
; EXAMPLE: caller does "push 6; push 2; call add_nums"
;
;   HIGH ADDRESSES (stack grows downward)
;   ┌───────────────────────────────────────────────────────────────┐
;   │  ...caller's data...                                         │
;   ├───────────────────────────────────────────────────────────────┤
;   │  6                        ← second arg (pushed first)        │  [rbp + 24]
;   ├───────────────────────────────────────────────────────────────┤
;   │  2                        ← first arg (pushed second)        │  [rbp + 16]
;   ├───────────────────────────────────────────────────────────────┤
;   │  return address            ← pushed by call                  │  [rbp + 8]
;   ├───────────────────────────────────────────────────────────────┤
;   │  old RBP                   ← pushed by push rbp             │  [rbp]  ← RBP points here
;   ├───────────────────────────────────────────────────────────────┤
;   │  local variable 1          ← created by sub rsp, 8          │  [rbp - 8]
;   ├───────────────────────────────────────────────────────────────┤
;   │  local variable 2                                            │  [rbp - 16]
;   ├───────────────────────────────────────────────────────────────┤
;   │  saved RBX                 ← pushed by saveCalleeSaved      │  [rbp - 24]
;   ├───────────────────────────────────────────────────────────────┤
;   │  saved R12                                                   │  [rbp - 32]
;   ├───────────────────────────────────────────────────────────────┤
;   │                            ← RSP points here (top of stack) │
;   └───────────────────────────────────────────────────────────────┘
;   LOW ADDRESSES
;
; KEY RULES:
;   [rbp + positive] = parameters and return address (ABOVE rbp)
;   [rbp]            = saved rbp (the anchor point)
;   [rbp - negative] = local variables and saved registers (BELOW rbp)
;
; PARAMETER OFFSETS (with stack-passed args):
;   [rbp + 16] = 1st parameter
;   [rbp + 24] = 2nd parameter
;   [rbp + 32] = 3rd parameter
;   ... and so on (+8 for each additional parameter)
;
; Why +16 and not +8 for the first parameter?
;   [rbp + 0]  = old rbp (8 bytes)
;   [rbp + 8]  = return address (8 bytes)
;   [rbp + 16] = first parameter starts here
;
; ============================================================================


; ============================================================================
; 4. LOCAL VARIABLES
; ============================================================================
;
; To create local variables, subtract from RSP:
;
;   push rbp
;   mov rbp, rsp
;   sub rsp, 16          ; make room for 2 local variables (8 bytes each)
;
;   mov qword [rbp - 8], 0      ; local variable 1 = 0
;   mov qword [rbp - 16], 100   ; local variable 2 = 100
;
;   ; ... use them ...
;
;   mov rsp, rbp         ; ← stack balancing removes the local variables
;   pop rbp
;   ret
;
; The "mov rsp, rbp" at the end is crucial — it undoes the "sub rsp, 16"
; and any other stack changes. This is STACK BALANCING.
;
; Without it, RSP would be 16 bytes too low, and ret would pop
; a local variable instead of the return address → crash.
;
; ============================================================================


; ============================================================================
; 5. CALLER-SAVED vs CALLEE-SAVED REGISTERS
; ============================================================================
;
; This is a CONTRACT between the caller and the called function.
;
; CALLEE-SAVED (the function MUST preserve these):
;   RBX, RBP, R12, R13, R14, R15
;
;   Rule: if you USE any of these in your function, you MUST:
;     1. Push them at the start
;     2. Pop them at the end (reverse order!)
;
;   Example:
;     my_func:
;         push rbp
;         mov rbp, rsp
;         push rbx         ; save rbx because we're about to use it
;         push r12         ; save r12 too
;
;         mov rbx, 42      ; now we can safely use rbx
;         mov r12, 100     ; and r12
;
;         pop r12          ; restore in REVERSE order
;         pop rbx
;         pop rbp
;         ret
;
;   Your lecturer's macros:
;     saveCalleeSaved   = push RBX, R12, R13, R14, R15
;     retriveCalleeSaved = pop R15, R14, R13, R12, RBX
;
;
; CALLER-SAVED (the function can freely destroy these):
;   RAX, RCX, RDX, RDI, RSI, R8, R9, R10, R11
;
;   Rule: if YOU (the caller) have important data in these registers,
;   save them BEFORE calling a function, because the function
;   is allowed to trash them.
;
;   Example:
;     ; rcx has our loop counter, but we need to call a function
;     push rcx            ; save it ourselves
;     call some_function  ; this might destroy rcx
;     pop rcx             ; get it back
;
;   Your lecturer's macros:
;     saveCallerSaved    = push RAX, RCX, RDX, RDI, RSI, R8-R11
;     retrieveCallerSaved = pop R11-R8, RSI, RDI, RDX, RCX, RAX
;
; ============================================================================


; ============================================================================
; 6. 64-BIT CALLING CONVENTION (System V AMD64 ABI)
; ============================================================================
;
; When calling functions (including C functions like printf):
;
; PARAMETERS (integer/pointer):
;   1st arg → RDI
;   2nd arg → RSI
;   3rd arg → RDX
;   4th arg → RCX
;   5th arg → R8
;   6th arg → R9
;   7th+ args → pushed on the stack (right to left)
;
; RETURN VALUE:
;   Integer result → RAX
;   Float result   → XMM0
;
; BEFORE calling:
;   RAX = number of floating-point arguments in XMM registers
;         (set to 0 if no float args, which is most of the time)
;
; STACK ALIGNMENT:
;   RSP must be 16-byte aligned at the point of the call instruction.
;   After the prologue (push rbp), RSP is 16-byte aligned.
;   If you've pushed an odd number of 8-byte values since then,
;   you need to "sub rsp, 8" to realign before calling.
;
; This is why the lecturer does:
;   sub RSP, 8     ; align to 16 bytes
;   call printf
;   add RSP, 8     ; undo the alignment
;
; ============================================================================


; ============================================================================
; 7. CALLING C FUNCTIONS — printf AND scanf
; ============================================================================
;     RDI = 1st argument
;     RSI = 2nd argument
;     RDX = 3rd argument
;     RCX = 4th argument
;     R8  = 5th argument
;     R9  = 6th argument
;
; SETUP (at the top of your file):
;
;   extern printf, scanf       ; declare external C functions
;   global main                ; use 'main' not '_start'
;   default rel                ; position-independent addressing
;
; BUILD COMMAND (different from regular!):
;
;   nasm -f elf64 file.asm
;   gcc -o file file.o -no-pie
;   ./file
;
; PRINTF EXAMPLE:
;
;   section .data
;       fmt db "Hello %s, you are %d years old", 10, 0
;       ;                                         ↑   ↑
;       ;                                    newline  null terminator
;       ;                                              (C strings need this!)
;       name db "Tison", 0
;
;   section .text
;       ; printf("Hello %s, you are %d years old\n", "Tison", 21)
;       lea rdi, [fmt]       ; 1st arg: format string
;       lea rsi, [name]      ; 2nd arg: the string for %s
;       mov rdx, 21          ; 3rd arg: the number for %d
;       xor rax, rax         ; 0 float args (REQUIRED!)
;       sub rsp, 8           ; stack alignment
;       call printf
;       add rsp, 8           ; undo alignment
;
;
; SCANF EXAMPLE:
;
;   section .data
;       fmt db "%d", 0
;   section .bss
;       num resd 1            ; 4 bytes for an integer
;
;   section .text
;       ; scanf("%d", &num)
;       lea rdi, [fmt]       ; 1st arg: format string
;       lea rsi, [num]       ; 2nd arg: ADDRESS where scanf stores the input
;       xor rax, rax         ; 0 float args
;       sub rsp, 8           ; stack alignment
;       call scanf
;       add rsp, 8           ; undo alignment
;       ; The number is now stored at [num]
;       ; Access it with: mov eax, [num]
;
;
; IMPORTANT NOTES:
;   - C strings MUST end with 0 (null terminator)
;   - Format strings: %d = integer, %s = string, %c = character, %f = float
;   - 10 = newline (add it to format strings for line breaks)
;   - Always set RAX = 0 before calling printf/scanf (unless passing floats)
;   - Always align the stack (sub rsp, 8 / add rsp, 8)
;   - Use LEA not MOV for loading addresses with default rel
;
; ============================================================================


; ============================================================================
; 8. LEA vs MOV
; ============================================================================
;
; MOV rdi, msg      ; loads the ADDRESS of msg into rdi
; MOV rdi, [msg]    ; loads the VALUE at msg into rdi
;
; LEA rdi, [msg]    ; loads the ADDRESS of msg into rdi
;                    ; with default rel, this generates position-independent code
;
; When using C functions with "default rel", always use LEA for addresses.
; Your lecturer uses LEA consistently — follow that pattern.
;
; ============================================================================


; ============================================================================
; 9. STACK ALIGNMENT EXPLAINED
; ============================================================================
;
; The System V ABI requires RSP to be 16-byte aligned when you call
; a function. "Aligned" means RSP is divisible by 16.
;
; When your program starts, RSP is 8-byte aligned (NOT 16).
; After "push rbp" (8 bytes), RSP becomes 16-byte aligned. Good.
;
; But if you push MORE things (like saveCalleeSaved pushes 5 registers = 40 bytes),
; the alignment changes. You need to track it:
;
;   push rbp          ; RSP moved by 8  → 16-aligned ✓
;   push rbx          ; RSP moved by 8  → 8-aligned  ✗
;   push r12          ; RSP moved by 8  → 16-aligned ✓
;   push r13          ; RSP moved by 8  → 8-aligned  ✗
;   push r14          ; RSP moved by 8  → 16-aligned ✓
;   push r15          ; RSP moved by 8  → 8-aligned  ✗ ← need sub rsp, 8!
;   sub rsp, 8        ; RSP moved by 8  → 16-aligned ✓ ← now safe to call
;   call printf
;   add rsp, 8        ; undo the alignment fix
;
; Rule of thumb: if you've pushed an ODD number of things since the
; function started, sub rsp, 8 before calling. If EVEN, you're fine.
;
; Your lecturer's saveCalleeSaved pushes 5 registers (odd), so he
; always does sub rsp, 8 before calling printf/scanf.
;
; ============================================================================


; ============================================================================
; 10. YOUR LECTURER'S MACROS DECODED
; ============================================================================
;
; %macro functionStart 0
;     push RBP             ; save caller's base pointer
;     mov RBP, RSP         ; set our base pointer
; %endmacro
;     → This is the standard function PROLOGUE
;
;
; %macro functionEnd 0
;     mov RSP, RBP         ; stack balancing! reset RSP
;     pop RBP              ; restore caller's base pointer
; %endmacro
;     → This is the standard function EPILOGUE
;     → "mov RSP, RBP" is the key — it undoes ALL sub rsp and pushes
;       that happened between functionStart and functionEnd
;
;
; %macro saveCalleeSaved 0
;     PUSH RBX
;     PUSH R12
;     PUSH R13
;     PUSH R14
;     PUSH R15
; %endmacro
;     → Saves all callee-saved registers
;     → Use at the START of a function, after functionStart
;
;
; %macro retriveCalleeSaved 0
;     POP R15
;     POP R14
;     POP R13
;     POP R12
;     POP RBX
; %endmacro
;     → Restores all callee-saved registers (REVERSE order!)
;     → Use at the END of a function, before functionEnd
;
;
; %macro saveCallerSaved 0
;     push RAX, RCX, RDX, RDI, RSI, R8, R9, R10, R11
; %endmacro
;     → Saves all caller-saved registers
;     → Use BEFORE calling another function if you need those values after
;
;
; %macro retrieveCallerSaved 0
;     pop R11, R10, R9, R8, RSI, RDI, RDX, RCX, RAX
; %endmacro
;     → Restores all caller-saved registers
;     → Use AFTER calling another function
;
;
; %macro exiting 0
;     mov RAX, 60
;     mov RDI, 0
;     syscall
; %endmacro
;     → Clean exit using syscall (for programs without C library)
;
; ============================================================================


; ============================================================================
; 11. COMPLETE FUNCTION TEMPLATE
; ============================================================================
;
; my_function:
;     ; ---- PROLOGUE ----
;     functionStart               ; push rbp; mov rbp, rsp
;     saveCalleeSaved             ; push rbx, r12-r15
;
;     ; ---- YOUR CODE HERE ----
;     ; Parameters: rdi, rsi, rdx, rcx, r8, r9
;     ; Return value goes in rax
;     ; Use rbx, r12-r15 freely (you saved them)
;     ; Create local variables: sub rsp, N
;     ; Access locals: [rbp - 8], [rbp - 16], etc.
;
;     ; If calling another function:
;     ;   sub rsp, 8              ; align stack if needed
;     ;   call other_func
;     ;   add rsp, 8
;
;     ; ---- EPILOGUE ----
;     retriveCalleeSaved          ; pop r15-r12, rbx
;     functionEnd                 ; mov rsp, rbp; pop rbp
;     ret
;
; ============================================================================