global start
%include "multiboot2.s"
%include "textmode.s"

section .rodata
ctext:
    .welcome: db 'Welcome to plain!',0x00
    .prompt: db 'recovery$',0x20,0x00

section .text
bits 32

start:
    cli
    mov esp, stack.top
    jmp kmain

kmain:
    ; Print welcome message
    mov eax, ctext.welcome
    call textmode.printsln

    ; Print prompt
    mov eax, ctext.prompt
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