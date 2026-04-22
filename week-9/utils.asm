
%macro saveCallerSaved 0
push RAX
push RCX
push RDX
push RDI
push RSI
push R8
push R9
push R10
push R11
%endmacro

%macro retrieveCallerSaved 0
POP R11
POP R10
POP R9
POP R8
POP RSI
POP RDI
POP RDX
POP RCX
POP RAX
%endmacro

%macro saveCalleeSaved 0
PUSH RBX
PUSH R12
PUSH R13
PUSH R14
PUSH R15
%endmacro

%macro retriveCalleeSaved 0
POP R15
POP R14
POP R13
POP R12
POP RBX
%endmacro

%macro exiting 0
   mov	RAX,60
   mov RDI, 0
   syscall
%endmacro

%macro  functionStart 0	
push RBP
mov RBP, RSP
%endmacro

%macro  functionEnd 0	
mov RSP, RBP
POP RBP
%endmacro
