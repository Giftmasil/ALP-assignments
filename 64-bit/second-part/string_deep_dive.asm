; ============================================================================
; 13_strings_deep_dive.asm — REFERENCE ONLY (do not run)
; Complete String Instructions Guide
; ============================================================================


; ============================================================================
; 1. WHAT ARE STRINGS IN ASSEMBLY?
; ============================================================================
;
; A string is just a sequence of bytes in memory. Nothing special.
; The CPU doesn't know what a "string" is — it just sees bytes.
;
; Defining strings:
;
;   Single quotes:  msg db 'Hello Kenya'
;   Double quotes:  msg db "Hello Kenya"
;   Back quotes:    msg db `Hello\nKenya`    ; allows escape sequences!
;
; Quote rules:
;   'He said "hello"'     ← double quotes inside single quotes: OK
;   "It's assembly"       ← single quote inside double quotes: OK
;   `She said \"hi\"`     ← escaped quotes inside back quotes: OK
;
; Escape sequences (only with back quotes):
;   `\n`   = newline       (ASCII 10)
;   `\t`   = tab           (ASCII 9)
;   `\r`   = carriage return (ASCII 13)
;   `\\`   = literal backslash
;   `\'`   = literal single quote
;   `\"`   = literal double quote
;   `\0`   = null terminator (ASCII 0)
;   `\a`   = bell sound    (ASCII 7)
;   `\b`   = backspace     (ASCII 8)
;
; Or you can manually add special characters:
;   msg db "Hello", 10, 0     ; 10 = newline, 0 = null terminator
;   msg db 'Line1', 0xa, 'Line2', 0x0
;
; Length calculation:
;   msg db "Hello Kenya!", 0xa
;   len equ $ - msg               ; $ = current address, msg = start address
;                                 ; len = number of bytes in the string
;
; Null-terminated vs length-stored:
;   ; C style (null terminated):
;   msg db "Hello", 0             ; the 0 marks the end
;
;   ; Pascal style (length stored):
;   msg db "Hello"
;   len equ $ - msg               ; length stored separately
;
; Your course uses BOTH styles depending on the situation.
; Syscalls need the length. C functions (printf) need null termination.
;
; ============================================================================


; ============================================================================
; 2. IMPLICIT REGISTERS — THE STRING INSTRUCTION CONTRACT
; ============================================================================
;
; String instructions don't let you choose registers. They use:
;
;   RSI (Source Index)      — always points to the SOURCE data
;   RDI (Destination Index) — always points to the DESTINATION
;   RCX (Counter)           — how many times to repeat
;   RAX (AL/AX/EAX/RAX)    — the value to store, load, or search for
;
; These are not suggestions — they are HARDWIRED into the CPU.
;
;   rep movsb     ALWAYS reads from [RSI] and writes to [RDI]
;   rep stosb     ALWAYS writes AL to [RDI]
;   lodsb         ALWAYS reads from [RSI] into AL
;   rep scasb     ALWAYS compares AL with [RDI]
;   rep cmpsb     ALWAYS compares [RSI] with [RDI]
;
; You cannot change this. If your source is in R12, you must
; mov rsi, r12 before using string instructions.
;
; After each byte/word/dword/qword operation:
;   - RSI and/or RDI are automatically incremented (or decremented)
;   - RCX is automatically decremented (when using REP)
;
; ============================================================================


; ============================================================================
; 3. DIRECTION FLAG — CLD AND STD
; ============================================================================
;
; The Direction Flag (DF) controls which way RSI and RDI move:
;
;   CLD  — Clear Direction Flag (DF = 0)
;           RSI and RDI INCREASE after each operation
;           Processing goes LEFT → RIGHT (forward)
;           THIS IS THE DEFAULT. ALWAYS CALL CLD BEFORE STRING OPS.
;
;   STD  — Set Direction Flag (DF = 1)
;           RSI and RDI DECREASE after each operation
;           Processing goes RIGHT → LEFT (backward)
;           Rarely used. Only needed for overlapping copies.
;
; How much do the pointers move?
;   movsb / lodsb / stosb / scasb / cmpsb  → move by 1 (byte)
;   movsw / lodsw / stosw / scasw / cmpsw  → move by 2 (word)
;   movsd / lodsd / stosd / scasd / cmpsd  → move by 4 (doubleword)
;   movsq / lodsq / stosq / scasq / cmpsq  → move by 8 (quadword)
;
; Example:
;   cld                     ; go forward
;   lea rsi, [source]       ; rsi = address 100
;   lodsb                   ; read byte at 100, rsi becomes 101
;   lodsb                   ; read byte at 101, rsi becomes 102
;
;   std                     ; go backward
;   lea rsi, [source + 5]   ; rsi = address 105
;   lodsb                   ; read byte at 105, rsi becomes 104
;   lodsb                   ; read byte at 104, rsi becomes 103
;
; ============================================================================


; ============================================================================
; 4. REP PREFIXES — AUTOMATIC REPETITION
; ============================================================================
;
; REP prefixes go BEFORE a string instruction to repeat it:
;
; ┌────────────┬───────────────────────────────────────────────────┐
; │ Prefix     │ Behavior                                         │
; ├────────────┼───────────────────────────────────────────────────┤
; │ rep        │ Repeat RCX times (unconditional)                 │
; │            │ Stops when: RCX == 0                             │
; │            │ Used with: movsb, stosb                          │
; ├────────────┼───────────────────────────────────────────────────┤
; │ repe       │ Repeat while EQUAL (ZF == 1)                     │
; │ repz       │ Same as repe                                     │
; │            │ Stops when: ZF == 0 (mismatch) OR RCX == 0       │
; │            │ Used with: cmpsb, scasb                          │
; ├────────────┼───────────────────────────────────────────────────┤
; │ repne      │ Repeat while NOT EQUAL (ZF == 0)                 │
; │ repnz      │ Same as repne                                    │
; │            │ Stops when: ZF == 1 (match found) OR RCX == 0    │
; │            │ Used with: cmpsb, scasb                          │
; └────────────┴───────────────────────────────────────────────────┘
;
; CRITICAL: After a repe/repne loop, check WHY it stopped:
;   je   → stopped because of a match/equal (ZF == 1)
;   jne  → stopped because RCX ran out (ZF == 0)
;
; ============================================================================


; ============================================================================
; 5. MOVSB / MOVSW / MOVSD / MOVSQ — Copy Memory
; ============================================================================
;
; Copies data from [RSI] to [RDI].
; After each copy, both RSI and RDI advance automatically.
;
; Think of it as: memcpy() in C
;
; Variants:
;   movsb — copy 1 byte,       RSI += 1, RDI += 1
;   movsw — copy 2 bytes,      RSI += 2, RDI += 2
;   movsd — copy 4 bytes,      RSI += 4, RDI += 4
;   movsq — copy 8 bytes,      RSI += 8, RDI += 8
;
; Example: Copy a string
;
;   section .data
;       source db "Hello", 0        ; 6 bytes (5 chars + null)
;   section .bss
;       dest resb 6
;
;   section .text
;       cld                         ; forward direction
;       lea rsi, [source]           ; source address
;       lea rdi, [dest]             ; destination address
;       mov rcx, 6                  ; copy 6 bytes
;       rep movsb                   ; copy!
;
;   Step by step:
;     rcx=6: copy [rsi]='H' → [rdi], rsi++, rdi++, rcx=5
;     rcx=5: copy [rsi]='e' → [rdi], rsi++, rdi++, rcx=4
;     rcx=4: copy [rsi]='l' → [rdi], rsi++, rdi++, rcx=3
;     rcx=3: copy [rsi]='l' → [rdi], rsi++, rdi++, rcx=2
;     rcx=2: copy [rsi]='o' → [rdi], rsi++, rdi++, rcx=1
;     rcx=1: copy [rsi]= 0  → [rdi], rsi++, rdi++, rcx=0 → stop
;     dest now contains "Hello\0"
;
; Using movsq for faster copying (8 bytes at a time):
;   If your data is a multiple of 8 bytes, use movsq with rcx = size/8
;   mov rcx, 16              ; copy 16 bytes
;   shr rcx, 3               ; rcx = 16/8 = 2 (two quadwords)
;   rep movsq                ; copies 8 bytes per iteration
;
; ============================================================================


; ============================================================================
; 6. LODSB / LODSW / LODSD / LODSQ — Load from Memory into Register
; ============================================================================
;
; Loads a value from [RSI] into AL/AX/EAX/RAX.
; After loading, RSI advances automatically.
;
; Variants:
;   lodsb — load 1 byte  from [RSI] into AL,  RSI += 1
;   lodsw — load 2 bytes from [RSI] into AX,  RSI += 2
;   lodsd — load 4 bytes from [RSI] into EAX, RSI += 4
;   lodsq — load 8 bytes from [RSI] into RAX, RSI += 8
;
; NOTE: LODSB is rarely used with REP because each iteration
; overwrites AL. It's usually used in a manual loop where you
; process each character.
;
; Example: Convert a string to uppercase
;
;   cld
;   lea rsi, [my_string]
;   lea rdi, [my_string]     ; overwrite in place
;
;   .loop:
;       lodsb                ; al = next character, rsi advances
;       cmp al, 0            ; null terminator?
;       je .done
;       cmp al, 'a'          ; is it lowercase?
;       jb .store            ; below 'a' — not lowercase
;       cmp al, 'z'
;       ja .store            ; above 'z' — not lowercase
;       sub al, 32           ; convert to uppercase (ASCII trick)
;   .store:
;       stosb                ; store al at [rdi], rdi advances
;       jmp .loop
;   .done:
;       stosb                ; store the null terminator
;
; ============================================================================


; ============================================================================
; 7. STOSB / STOSW / STOSD / STOSQ — Store Register into Memory
; ============================================================================
;
; Stores AL/AX/EAX/RAX into [RDI].
; After storing, RDI advances automatically.
;
; Think of it as: memset() in C (when used with REP)
;
; Variants:
;   stosb — store AL  (1 byte)  at [RDI], RDI += 1
;   stosw — store AX  (2 bytes) at [RDI], RDI += 2
;   stosd — store EAX (4 bytes) at [RDI], RDI += 4
;   stosq — store RAX (8 bytes) at [RDI], RDI += 8
;
; Example: Fill a buffer with zeros (clear it)
;
;   cld
;   lea rdi, [buffer]
;   xor al, al              ; al = 0
;   mov rcx, 64             ; clear 64 bytes
;   rep stosb               ; write 0 to [rdi], repeat 64 times
;
; Example: Fill with a specific character
;
;   cld
;   lea rdi, [buffer]
;   mov al, '-'             ; fill with dashes
;   mov rcx, 50
;   rep stosb               ; buffer = "------...------"
;
; Example: Fill with a word value
;
;   cld
;   lea rdi, [buffer]
;   mov ax, 0xFFFF          ; fill with 0xFFFF
;   mov rcx, 25             ; 25 words = 50 bytes
;   rep stosw
;
; ============================================================================


; ============================================================================
; 8. SCASB / SCASW / SCASD / SCASQ — Search for a Value
; ============================================================================
;
; Compares AL/AX/EAX/RAX with the value at [RDI].
; After comparing, RDI advances automatically. Flags are set.
;
; Think of it as: strchr() or memchr() in C
;
; Variants:
;   scasb — compare AL  with byte at [RDI],       RDI += 1
;   scasw — compare AX  with word at [RDI],       RDI += 2
;   scasd — compare EAX with doubleword at [RDI], RDI += 4
;   scasq — compare RAX with quadword at [RDI],   RDI += 8
;
; Used with REPNE to search for a character:
;   "Keep scanning while NOT equal, stop when found"
;
; Example: Search for 'K' in "Hello Kenya"
;
;   cld
;   lea rdi, [my_string]    ; string to search
;   mov al, 'K'             ; character to find
;   mov rcx, 11             ; string length
;   repne scasb             ; scan until [rdi] == al or rcx == 0
;
;   ; WHY did it stop?
;   je .found               ; ZF=1 → found 'K'!
;   jmp .not_found          ; ZF=0 → rcx ran out, 'K' not in string
;
; After finding, RDI points to the byte AFTER the match.
; So to get the position: position = original_rdi - current_rdi - 1
;
; Used with REPE to find first non-matching character:
;   "Keep scanning while equal, stop when different"
;
;   cld
;   lea rdi, [buffer]       ; buffer filled with 'A'
;   mov al, 'A'
;   mov rcx, 100
;   repe scasb              ; scan while [rdi] == 'A'
;   ; stops at first byte that ISN'T 'A'
;
; Getting string length with SCASB (like strlen):
;
;   cld
;   lea rdi, [my_string]
;   xor al, al              ; search for 0 (null terminator)
;   mov rcx, -1             ; search indefinitely (huge number)
;   repne scasb             ; scan until we find 0
;   not rcx                 ; flip bits: rcx was counting down from -1
;   dec rcx                 ; subtract 1 (don't count the null itself)
;   ; rcx = string length
;
;   Why "not rcx; dec rcx" works:
;     rcx starts at -1 (0xFFFFFFFFFFFFFFFF)
;     After scanning 5 chars + null: rcx was decremented 6 times
;     rcx = -1 - 6 = -7
;     not(-7) = 6
;     6 - 1 = 5 = string length (excluding null)
;
; ============================================================================


; ============================================================================
; 9. CMPSB / CMPSW / CMPSD / CMPSQ — Compare Two Memory Locations
; ============================================================================
;
; Compares byte/word/dword/qword at [RSI] with value at [RDI].
; After comparing, BOTH RSI and RDI advance. Flags are set.
;
; Think of it as: strcmp() or memcmp() in C
;
; Variants:
;   cmpsb — compare byte at [RSI] with byte at [RDI]
;   cmpsw — compare word at [RSI] with word at [RDI]
;   cmpsd — compare doubleword at [RSI] with dword at [RDI]
;   cmpsq — compare quadword at [RSI] with qword at [RDI]
;
; Used with REPE to compare strings:
;   "Keep comparing while bytes are equal, stop at first difference"
;
; Example: Compare two strings
;
;   section .data
;       str1 db "Assembly", 0
;       str2 db "Assemble", 0
;
;   section .text
;       cld
;       lea rsi, [str1]
;       lea rdi, [str2]
;       mov rcx, 8              ; compare 8 bytes
;       repe cmpsb              ; compare while equal
;
;       je .strings_equal       ; if ZF still set, all bytes matched
;       jne .strings_different  ; if ZF clear, a difference was found
;
;   Step by step:
;     rcx=8: [rsi]='A' vs [rdi]='A' → equal, continue. rcx=7
;     rcx=7: [rsi]='s' vs [rdi]='s' → equal, continue. rcx=6
;     rcx=6: [rsi]='s' vs [rdi]='s' → equal, continue. rcx=5
;     rcx=5: [rsi]='e' vs [rdi]='e' → equal, continue. rcx=4
;     rcx=4: [rsi]='m' vs [rdi]='m' → equal, continue. rcx=3
;     rcx=3: [rsi]='b' vs [rdi]='b' → equal, continue. rcx=2
;     rcx=2: [rsi]='l' vs [rdi]='l' → equal, continue. rcx=1
;     rcx=1: [rsi]='y' vs [rdi]='e' → NOT EQUAL! Stop. ZF=0
;     jne .strings_different → they differ at position 7
;
; Used with REPNE to find first matching position:
;   Less common but possible.
;
; ============================================================================


; ============================================================================
; 10. PUTTING IT ALL TOGETHER — COMMON PATTERNS
; ============================================================================
;
; PATTERN: Copy a string (like strcpy)
;   cld
;   lea rsi, [source]
;   lea rdi, [dest]
;   mov rcx, length           ; include null terminator!
;   rep movsb
;
;
; PATTERN: Get string length (like strlen)
;   cld
;   lea rdi, [my_string]
;   xor al, al
;   mov rcx, -1
;   repne scasb
;   not rcx
;   dec rcx                    ; rcx = length
;
;
; PATTERN: Compare two strings (like strcmp)
;   cld
;   lea rsi, [str1]
;   lea rdi, [str2]
;   mov rcx, length
;   repe cmpsb
;   je .equal
;   jne .different
;
;
; PATTERN: Search for a character (like strchr)
;   cld
;   lea rdi, [my_string]
;   mov al, 'x'               ; character to find
;   mov rcx, length
;   repne scasb
;   je .found
;   jmp .not_found
;
;
; PATTERN: Fill memory (like memset)
;   cld
;   lea rdi, [buffer]
;   mov al, 0                  ; fill with zeros
;   mov rcx, size
;   rep stosb
;
;
; PATTERN: Process each character (manual loop with lodsb)
;   cld
;   lea rsi, [my_string]
;   .loop:
;       lodsb                  ; al = next char, rsi++
;       cmp al, 0
;       je .done
;       ; do something with al
;       jmp .loop
;   .done:
;
;
; PATTERN: Count occurrences of a character
;   cld
;   lea rsi, [my_string]
;   xor rcx, rcx              ; counter
;   mov bl, 'e'               ; character to count
;   .loop:
;       lodsb
;       cmp al, 0
;       je .done
;       cmp al, bl
;       jne .loop
;       inc rcx
;       jmp .loop
;   .done:
;   ; rcx = count
;
;
; PATTERN: Reverse a string
;   ; Step 1: Find the length
;   ; Step 2: Set RSI to start, RDI to end-1
;   ; Step 3: Swap characters moving inward
;   cld
;   lea rsi, [my_string]       ; start
;   lea rdi, [my_string]
;   add rdi, length
;   dec rdi                    ; end - 1 (last character before null)
;   mov rcx, length
;   shr rcx, 1                 ; only need to swap half the string
;   .swap:
;       mov al, [rsi]
;       mov bl, [rdi]
;       mov [rsi], bl
;       mov [rdi], al
;       inc rsi
;       dec rdi
;       dec rcx
;       jnz .swap
;
; ============================================================================


; ============================================================================
; 11. INSTRUCTION QUICK REFERENCE TABLE
; ============================================================================
;
; ┌──────────┬──────────────────────┬────────────┬─────────────────────────┐
; │ Instr    │ What it does         │ Registers  │ REP prefix              │
; ├──────────┼──────────────────────┼────────────┼─────────────────────────┤
; │ movsb    │ [RSI] → [RDI]        │ RSI, RDI   │ rep (copy N bytes)     │
; │ movsw    │ [RSI] → [RDI] (word) │ RSI, RDI   │ rep                    │
; │ movsd    │ [RSI] → [RDI] (dword)│ RSI, RDI   │ rep                    │
; │ movsq    │ [RSI] → [RDI] (qword)│ RSI, RDI   │ rep                    │
; ├──────────┼──────────────────────┼────────────┼─────────────────────────┤
; │ lodsb    │ [RSI] → AL           │ RSI, AL    │ rarely used with rep   │
; │ lodsw    │ [RSI] → AX           │ RSI, AX    │                        │
; │ lodsd    │ [RSI] → EAX          │ RSI, EAX   │                        │
; │ lodsq    │ [RSI] → RAX          │ RSI, RAX   │                        │
; ├──────────┼──────────────────────┼────────────┼─────────────────────────┤
; │ stosb    │ AL → [RDI]           │ RDI, AL    │ rep (fill N bytes)     │
; │ stosw    │ AX → [RDI]           │ RDI, AX    │ rep                    │
; │ stosd    │ EAX → [RDI]          │ RDI, EAX   │ rep                    │
; │ stosq    │ RAX → [RDI]          │ RDI, RAX   │ rep                    │
; ├──────────┼──────────────────────┼────────────┼─────────────────────────┤
; │ scasb    │ AL vs [RDI]          │ RDI, AL    │ repne (search)         │
; │ scasw    │ AX vs [RDI]          │ RDI, AX    │ repe  (scan while =)  │
; │ scasd    │ EAX vs [RDI]         │ RDI, EAX   │                        │
; │ scasq    │ RAX vs [RDI]         │ RDI, RAX   │                        │
; ├──────────┼──────────────────────┼────────────┼─────────────────────────┤
; │ cmpsb    │ [RSI] vs [RDI]       │ RSI, RDI   │ repe (compare strings)│
; │ cmpsw    │ [RSI] vs [RDI] (word)│ RSI, RDI   │ repne                  │
; │ cmpsd    │ [RSI] vs [RDI] (dwd) │ RSI, RDI   │                        │
; │ cmpsq    │ [RSI] vs [RDI] (qwd) │ RSI, RDI   │                        │
; └──────────┴──────────────────────┴────────────┴─────────────────────────┘
;
; ============================================================================