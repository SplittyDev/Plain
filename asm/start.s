global start
%include "multiboot2.s"
%include "textmode.s"

section .rodata
ctext:
    .welcome: db 'Welcome to plain!',10,0

section .text
bits 32

start:
    cli
    mov esp, stack.top
    jmp kmain

kmain:
    ; Print welcome message
    mov eax, ctext.welcome
    call textmode.prints
    ; Halt
    hlt

section .bss
align 4096

; Bootstrap stack
stack:
.bottom:
    resb 4096
.top: