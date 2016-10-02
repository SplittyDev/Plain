global start

%include "multiboot2.s" ; multiboot2 headers

%include "vital.s"      ; koutb, kiowait
%include "string.s"     ; kitoa
%include "serial.s"     ; kinitcom, ksendcomc, ksendcoms
%include "textmode.s"   ; kprintc, kprints, kprinti

%include "gdt.s"        ; gdt.*
%include "pic.s"        ; pic.*
%include "isr.s"        ; isr.*
%include "idt.s"        ; idt.*
%include "cpuid.s"      ; cpuid.*

section .rodata
msg:
    .ok:            db 'OK',0x0A,0x00
    .fail:          db 'FAIL',0x0A,0x00
    .iserial:       db 'Initializing RS-232',0x20,0x00
    .igdt:          db 'Initializing GDT',0x20,0x00
    .ipic:          db 'Initializing PIC',0x20,0x00
    .iapic:         db 'Initializing APIC',0x20,0x00
    .iidt:          db 'Initializing IDT',0x20,0x00
    .cpuinfo:       db '[CPU Information]',0x0A,0x00
    .vendor:        db 'Vendor:',0x20,0x00
    .brand:         db 'Brand:',0x20,0x00
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
    kprints err.otherloader
    jmp .freeze
.multiboot1:
    kprints err.mblegloader
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
.setup_serial:
    kprints msg.iserial
    kinitcom COM1
    kprints msg.ok, COLOR_CUSTOM_OK
.setup_gdt:
    kprints msg.igdt
    call gdt.setup
    kprints msg.ok, COLOR_CUSTOM_OK
.setup_pic:
    kprints msg.ipic
    call pic.init
    kprints msg.ok, COLOR_CUSTOM_OK
.setup_idt:
    kprints msg.iidt
    call idt.setup
    kprints msg.ok, COLOR_CUSTOM_OK
.end:
    sti
    ret

;
; Main entry point.
;
kmain:
.welcome:
    ksendcoms COM1, msg.welcome
    kprints msg.welcome
.cpuinfo:
    call textmode.println
    kprints msg.cpuinfo
    kprints msg.vendor
    call cpuid_helper.print_vendor_string
    call textmode.println
    kprints msg.brand
    call cpuid_helper.print_brand_string
    call textmode.println
.end:
    jmp .end

section .bss

; Bootstrap stack
align 4096
stack:
.bottom:
    resb 4096
.top:

;
; Buffer to store the result of __itoa in.
;
; Reserved:
; 0x00-0x01 sign
; 0x01-0x0B digits (2**32-1 has 10 digits)
; 0x0B-0x0C NUL
;
align 16
__itoabuf32:
    resb 12