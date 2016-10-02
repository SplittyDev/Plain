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