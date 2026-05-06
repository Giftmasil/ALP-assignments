; ============================================================================
; 08_functions.asm — Functions (Procedures) in Assembly (64-bit)
; ============================================================================
;
; Build & Run:
;   ./build.sh 08_functions 64
;
; This program demonstrates:
;   1. Simple function with no parameters
;   2. Function with parameters (using registers)
;   3. Function with parameters (using the stack)
; ============================================================================

section .data
    msg_hello db "Hello from a function!", 10
    msg_hello_len equ $ - msg_hello

    msg_before db "Before function call", 10
    msg_before_len equ $ - msg_before

    msg_after db "After function call", 10
    msg_after_len equ $ - msg_after

    msg_result db "Sum result: "
    msg_result_len equ $ - msg_result

    msg_func3 db "Stack function result: "
    msg_func3_len equ $ - msg_func3

    newline db 10

section .bss
    output resb 1

section .text
    global _start

_start:

; ============================================================================
; FUNCTION 1: Simple function with no parameters
;
; A function is just:
;   - A label (the function name)
;   - Some code
;   - ret (go back to where you were called from)
;
; call = "jump to this function AND remember where I am"
; ret  = "jump back to where call was made"
;
; Behind the scenes:
;   call pushes the return address onto the stack
;   ret pops it off and jumps there
;
; Python equivalent:
;   def say_hello():
;       print("Hello from a function!")
;
;   print("Before function call")
;   say_hello()
;   say_hello()
;   print("After function call")
; ============================================================================

    ; Print "Before function call"
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_before
    mov rdx, msg_before_len
    syscall

    call print_hello        ; call the function (first time)
    call print_hello        ; call it again (second time)
                            ; The function runs twice, printing twice

    ; Print "After function call"
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_after
    mov rdx, msg_after_len
    syscall

; ============================================================================
; FUNCTION 2: Function that takes parameters in registers
;
; Convention: put arguments in registers before calling.
; The simplest approach — just agree on which registers to use.
;
; We'll make an "add" function:
;   - Input: r12 = first number, r13 = second number
;   - Output: rax = the sum
;
; Python equivalent:
;   def add_numbers(a, b):
;       return a + b
;   result = add_numbers(3, 4)
;   print(result)
; ============================================================================

    mov r12, 3              ; first argument = 3
    mov r13, 4              ; second argument = 4
    call add_numbers        ; call the function
                            ; result is now in rax

    ; rax = 7, convert to ASCII and print
    add al, '0'
    mov [output], al

    ; Print "Sum result: "
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_result
    mov rdx, msg_result_len
    syscall

    ; Print the digit
    mov rax, 1
    mov rdi, 1
    mov rsi, output
    mov rdx, 1
    syscall

    ; Print newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

; ============================================================================
; FUNCTION 3: Function that takes parameters via the STACK
;
; This is the "proper" way taught in your course (8-functions.pdf).
; The caller pushes arguments onto the stack, then calls the function.
; The function sets up a "stack frame" to access them.
;
; Stack frame setup (the function "prologue"):
;   push rbp          ; save the old base pointer
;   mov rbp, rsp      ; set base pointer to current stack top
;
; Now the stack looks like:
;   [rbp+24]  = second argument (pushed first — right to left!)
;   [rbp+16]  = first argument  (pushed second)
;   [rbp+8]   = return address  (pushed by call)
;   [rbp]     = old rbp         (pushed by push rbp)
;
; Stack frame teardown (the function "epilogue"):
;   pop rbp           ; restore old base pointer
;   ret               ; return to caller
;
; Python equivalent:
;   def add_stack(a, b):
;       return a + b
;   result = add_stack(2, 6)
;   print(result)
; ============================================================================

    ; Push arguments RIGHT TO LEFT (second arg first!)
    push 6                  ; second argument
    push 2                  ; first argument
    call add_stack          ; call the function
    add rsp, 16             ; clean up: remove 2 arguments from stack
                            ; (each push was 8 bytes, 2 × 8 = 16)

    ; rax = 8, convert to ASCII and print
    add al, '0'
    mov [output], al

    ; Print "Stack function result: "
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_func3
    mov rdx, msg_func3_len
    syscall

    ; Print the digit
    mov rax, 1
    mov rdi, 1
    mov rsi, output
    mov rdx, 1
    syscall

    ; Print newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

; ============================================================================
; EXIT
; ============================================================================

    mov rax, 60
    mov rdi, 0
    syscall

; ============================================================================
; FUNCTION DEFINITIONS (below _start so they don't run automatically)
; ============================================================================

; ----------------------------------------------------------------------------
; print_hello — prints "Hello from a function!"
; Parameters: none
; Returns: nothing
; ----------------------------------------------------------------------------
print_hello:
    ; No stack frame needed for simple functions with no local variables
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_hello
    mov rdx, msg_hello_len
    syscall
    ret                     ; go back to where call was made

; ----------------------------------------------------------------------------
; add_numbers — adds two numbers passed in registers
; Parameters: r12 = first number, r13 = second number
; Returns: rax = sum
; ----------------------------------------------------------------------------
add_numbers:
    mov rax, r12            ; rax = first number
    add rax, r13            ; rax = first + second
    ret                     ; return with result in rax

; ----------------------------------------------------------------------------
; add_stack — adds two numbers passed on the stack
; Parameters: [rbp+16] = first number, [rbp+24] = second number
; Returns: rax = sum
; ----------------------------------------------------------------------------
add_stack:
    push rbp                ; ┐ PROLOGUE: save old base pointer
    mov rbp, rsp            ; ┘ set base pointer to current stack position

    ; Now the stack looks like:
    ;
    ;   Address       Contents
    ;   ─────────     ────────
    ;   rbp + 24      6              (second arg, pushed first)
    ;   rbp + 16      2              (first arg, pushed second)
    ;   rbp + 8       return address (pushed by call)
    ;   rbp           old rbp        (pushed by push rbp)
    ;   ← rsp and rbp point here

    mov rax, [rbp + 16]     ; rax = first argument (2)
    add rax, [rbp + 24]     ; rax = rax + second argument (2 + 6 = 8)

    pop rbp                 ; ┐ EPILOGUE: restore old base pointer
    ret                     ; ┘ return to caller with result in rax

; ============================================================================
; FUNCTION SUMMARY:
;
; Defining a function:
;   my_func:
;       ; do stuff
;       ret
;
; Calling a function:
;   call my_func
;
; With parameters in registers (simple):
;   mov r12, value1
;   mov r13, value2
;   call my_func
;   ; result in rax
;
; With parameters on the stack (proper/formal):
;   push value2         ; push right-to-left!
;   push value1
;   call my_func
;   add rsp, 16         ; clean up stack (num_args × 8)
;   ; result in rax
;
; Inside the stack function:
;   push rbp            ; prologue
;   mov rbp, rsp
;   ; use [rbp+16] for first arg, [rbp+24] for second arg
;   pop rbp             ; epilogue
;   ret
;
; CALLEE-SAVED registers (function must preserve these):
;   rbx, rbp, r12, r13, r14, r15
;
; CALLER-SAVED registers (function can freely destroy these):
;   rax, rcx, rdx, rsi, rdi, r8, r9, r10, r11
; ============================================================================