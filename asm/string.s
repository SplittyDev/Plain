section .rodata

;
; Convenience wrapper for __itoa.
; Assumes an unsigned integer as input.
; Registers are preserved.
;
; Usage:
; kitoa <value> [, base]
;
; Produces a null-terminated string in __itoabuf32.
;
%macro kitoa 1-2 10
    push eax
    push ebx
    push ecx
    push edx
    mov dword eax, %1
    mov dword ecx, %2
    mov dword ebx, __itoabuf32
    xor edx, edx
    call __itoa
    pop edx
    pop ecx
    pop ecx
    pop eax
%endmacro

;
; Convenience wrapper for __itoa.
; Assumes a signed integer as input.
; Registers are preserved.
;
; Usage:
; kitoa <value> [, base]
;
; Produces a null-terminated string in __itoabuf32.
;
%macro kitoas 1-2 10
    push eax
    push ebx
    push ecx
    push edx
    mov dword eax, %1
    mov dword ecx, %2
    mov dword ebx, __itoabuf32
    mov edx, 1
    call __itoa
    pop edx
    pop ecx
    pop ecx
    pop eax
%endmacro

section .rodata

;
; Conversion table for __itoa.
; Works for bases [2 ... 36].
;
__itoacvt:
    db '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'

section .text

;
; Routine to convert a 32-bit integer to a string.
; Registers are preserved.
;
; EAX: Source integer
; EBX: Target address
; ECX: Base
; EDX: Sign extend
;
; Internal register layout:
; start:
; EAX: Source integer
; ECX: Target address
; EDX: Base
; checknegative:
; EAX: Source integer
; EBX: Target address (original)
; ECX: Target address (active)
; EDX: Sign extend (temporary)
; divrem:
; EAX: Source integer
; ECX: Target address (active)
; EDX: Base / Result
; reverse:
; EBX: Target address (original)
; ECX: Target address (active)
; EDX: Target address (temporary)
;
__itoa:
.start:
    push eax
    push ebx
    push ecx
    push edx
    mov edx, ecx
    mov ecx, ebx
.checknegative:
    push edx
    mov dword edx, [esp + 32]
    test edx, edx
    pop edx
    jz .divrem
    test eax, eax
    jns .divrem
    mov byte [ecx], 0x2D
    inc ecx
    mov ebx, ecx
    neg eax
.divrem:
    push edx
    push ecx
    mov ecx, edx
    xor edx, edx
    div ecx
    mov byte dl, [__itoacvt + edx]
    pop ecx
    mov byte [ecx], dl
    pop edx
    inc ecx
    cmp eax, 0x00
    jne .divrem
    mov byte [ecx], 0x00
    dec ecx
.reverse:
    cmp ebx, ecx
    jge .end
    mov byte dl, [ebx]
    mov byte al, [ecx]
    mov byte [ebx], al
    mov byte [ecx], dl
    inc ebx
    dec ecx
    jmp .reverse
.end:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret