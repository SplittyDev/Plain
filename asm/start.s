global start
%include "multiboot2.s"

section .rodata
console:
    .color: db 0x0F
msg:
    .welcome: db 'Welcome to plain!',10,'test...',0

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
; VGA routine to print a single char.
;
; Register - Argument
; -------- - ---------
; eax      - char
; ebx      - color    
; ecx      - y        
; edx      - x      
; -------- - ---------
.printc:
    cmp al, 10
    je .printc_case_nl
    cmp al, 13
    je .printc_case_cr
    jmp .printc_main
.printc_case_nl:
    inc ecx
    jmp .printc_case_cr
.printc_case_cr:
    mov edx, 0
    ret
.printc_main:
    push ebx
    push ecx
    ; attr = chr | (color << 8)
    shl bx, 8           ; color <<= 8
    or bx, ax           ; color |= chr
    ; ptr = 0xb8000 + y * 80 + x
    imul ecx, 80        ; y *= 80
    add ecx, edx        ; y += x
    shl ecx, 1          ; y *= 2
    add ecx, 0xb8000    ; y += 0xb8000
    mov [ecx], bx       ; *y = color
    inc edx             ; x++
    pop ecx
    pop ebx
    ret
; VGA routine to print a null-terminated string.
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