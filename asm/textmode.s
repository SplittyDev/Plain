section .data
console:
    .x: dd 0x00
    .y: dd 0x00
    .c: db 0x07
    .w: db 0x50
    .h: db 0x19

section .text
textmode:

;
; VGA routine to update the cursor position.
; Registers are preserved.
;
; CX: Target location
;
; Calculating the target location:
; cx = (y * 80 + x) & 0xFF
;
.update_cursor:
    push ax
    push dx
    mov al, 0x0E
    mov dx, 0x03D4
    out dx, al
    push cx
    mov ax, cx
    pop cx
    shr ax, 8
    mov dx, 0x03D5
    out dx, al
    mov al, 0x0F
    mov dx, 0x03D4
    out dx, al
    mov al, cl
    mov dx, 0x03D5
    out dx, al
    pop dx
    pop ax
    ret

;
; VGA routine to disable the cursor.
; Registers are preserved.
;
.disable_cursor:
    push ax
    push dx
    mov al, 0x0F
    mov dx, 0x03D4
    out dx, al
    mov al, 0xFF 
    mov dx, 0x03D5
    out dx, al
    mov al, 0x0E
    mov dx, 0x03D4
    out dx, al
    mov al, 0xFF
    mov dx, 0x03D5
    out dx, al
    pop dx
    pop ax
    ret

;
; VGA routine to print a character.
; Registers are preserved.
;
; AL: Character (ASCII code).
;
.printc:
    cmp al, 0x0A
    je .printc_handle_lf
    cmp al, 0x0D
    je .printc_handle_cr
    push ecx
    push ebx
    mov ecx, [console.y]
    imul ecx, 80
    add ecx, [console.x]
    mov bl, [console.c]
    mov [0xb8000 + 0 + ecx * 2], al ; *(0xB8000 + 0 + off * 2) = char
    mov [0xb8000 + 1 + ecx * 2], bl ; *(0xB8000 + 1 + off * 2) = color
    pop ebx
    inc ecx
    inc byte [console.x]
    cmp byte [console.x], 80
    jl .printc_update_cursor
    call .printc_handle_lf
.printc_update_cursor:
    call .update_cursor
    pop ecx
    ret
.printc_handle_lf:
    inc dword [console.y]
.printc_handle_cr:
    mov dword [console.x], 0
    ret

;
; VGA routine to print a null-terminated string.
; Registers are preserved.
;
; EAX: Pointer to string.
;
.prints:
    push eax
.prints_loop:
    cmp byte [eax], 0
    je .prints_next
    push eax
    mov al, [eax]
    call .printc
    pop eax
    inc eax
    jmp .prints_loop
.prints_next:
    pop eax
    ret

;
; VGA routine to print a null-terminated string,
; followed by a line-feed (0x0A) character.
; Registers are preserved.
;
; EAX: Pointer to string.
;
.printsln:
    call .prints
    push eax
    mov al, 0x0A
    call .printc
    pop eax
    ret