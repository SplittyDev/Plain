global start
%include "multiboot2.s"
%include "textmode.s"
%include "gdt.s"
%include "cpuid.s"

section .rodata
msg:
    .ok:            db 'OK',0x0A,0x00
    .fail:          db 'FAIL',0x0A,0x00
    .igdt:          db 'Initializing GDT',0x20,0x00
    .cpuinfo:       db '[CPU Information]',0x0A,0x00
    .vendor:        db 'Vendor:',0x20,0x00
    .welcome:       db 'Welcome to plain!',0x0A,0x00
    .prompt:        db 'recovery$',0x20,0x00
err:
    .mblegloader:   db 'Unsupported boot loader: Multiboot (Legacy).',0x00
    .otherloader:   db 'Unsupported boot loader.',0x00

section .text
bits 32

;
; This is where GRUB takes us.
; Responsible for setting up a basic stack and
; calling kearly and kmain.
;
; For now, only Multiboot 2 compliant boot loaders are supported.
; Multiboot Legacy or other boot loaders cause the system to print
; an error message and halt till the heath death of the universe.
;
start:
    cli
    mov esp, stack.top
    cmp eax, 0x2BADB002
    je .multiboot1
    cmp eax, 0x36D76289
    je .multiboot2
.unsupported:
    mov eax, err.otherloader
    call textmode.prints
    jmp .freeze
.multiboot1:
    mov eax, err.mblegloader
    call textmode.prints
    jmp .freeze
.multiboot2:
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
    call textmode.prints
    call textmode.reset_color
.end:
    ret

;
; Main entry point.
;
kmain:
.welcome:
    mov eax, msg.welcome
    call textmode.prints
.cpuinfo:
    call textmode.println
    mov eax, msg.cpuinfo
    call textmode.prints
    mov eax, msg.vendor
    call textmode.prints
    call cpuid_helper.print_vendor_string
    call textmode.println
.end:
    ret

section .bss
align 4096

; Bootstrap stack
stack:
.bottom:
    resb 4096
.top: