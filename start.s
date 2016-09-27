global start
%include "multiboot2.s"

section .data
console:
    .color: db 0x0F
msg:
    .welcome: db 'Welcome to plain!',0

section .text
bits 32

start:
    cli
    mov esp, stack.top
    jmp kmain

kmain:
    ; Print welcome message
    mov eax, msg.welcome
    mov ebx, [console.color]
    mov ecx, 0 ; y
    mov edx, 0 ; x
    call vga.prints
    ; Halt
    hlt

vga:
; VGA printing routine to print a single char.
; Preserves all registers.
;
; Register - Argument
; -------- - ---------
; eax      - char
; ebx      - color    
; ecx      - y        
; edx      - x      
; -------- - ---------
.printc:
    push ebx
    push ecx
    ; attr = chr | (color << 8)
    shl ebx, 8           ; color <<= 8
    or ebx, eax           ; color |= chr
    ; ptr = 0xb8000 + y * 80 + x
    imul ecx, 40        ; y *= 40
    add ecx, edx        ; y += x
    shl ecx, 1          ; y *= 2
    add ecx, 0xb8000    ; y += 0xb8000
    mov [ecx], bx       ; *y = color
    inc dl              ; increment x
    pop ecx
    pop ebx
    ret
; VGA priting routine to print a null-terminated string.
; Preserves all registers.
;
; Register - Argument
; -------- - ---------
; eax      - str
; ebx      - color
; ecx      - y
; edx      - x
; -------- - ---------
.prints:
    push eax
.prints_loop:
    cmp byte [eax], 0   ; if *str == 0
    je .prints_next     ; break
    push eax            ; push str
    mov al, [eax]       ; chr = str[i]
    call .printc        ; print
    pop eax             ; pop str
    inc eax             ; str++
    jmp .prints_loop    ; continue
.prints_next:
    pop eax
    ret

section .bss
align 4096

; Bootstrap stack
stack:
.bottom:
    resb 4096
.top: