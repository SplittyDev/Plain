global start
%include "multiboot2.s"
%include "textmode.s"
%include "gdt.s"

section .rodata
msg:
    .ok: db 'OK',00
    .fail: db 'FAIL',00
    .igdt: db 'Initializing GDT',0x20,0x00
    .welcome: db 'Welcome to plain!',0x00
    .prompt: db 'recovery$',0x20,0x00

section .text
bits 32

;
; This is where GRUB takes us.
; Responsible for setting up a basic stack and
; calling kearly and kmain.
;
start:
    cli
    mov esp, stack.top
    call kearly
    call kmain
.freeze:
    cli
    hlt

;
; Early entry point.
; Paves the way for kmain.
;
kearly:
.initialize_gdt:
    mov eax, msg.igdt
    call textmode.prints
    call gdt.setup
    mov al, COLOR_CUSTOM_OK
    call textmode.set_color
    mov eax, msg.ok
    call textmode.printsln
    call textmode.reset_color
.end:
    ret

;
; Main entry point.
;
kmain:
    mov eax, msg.welcome
    call textmode.printsln
    ;mov eax, msg.prompt
    ;call textmode.prints
    ret

section .bss
align 4096

; Bootstrap stack
stack:
.bottom:
    resb 4096
.top: