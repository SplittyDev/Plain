global start

%include "multiboot2.s" ; multiboot2 headers

%include "vital.s"      ; koutb, kiowait
%include "string.s"     ; kitoa
%include "serial.s"     ; kinitcom, ksendcomc, ksendcoms, ksendcomi
%include "textmode.s"   ; kprintc, kprints, kprinti
%include "pic.s"        ; ksetupidt
%include "gdt.s"        ; ksetupgdt
%include "isr.s"        ; kinstallirq
%include "idt.s"        ; ksetupidt
%include "pit.s"        ; ksetuppit

%include "cpuid.s"      ; cpuid.*

section .rodata
msg:
    .ok:            db 'OK',0x0A,0x00
    .fail:          db 'FAIL',0x0A,0x00
    .hexprefix:     db '0x',0x00
    .iserial:       db '[BOOT] RS-232',0x20,0x00
    .igdt:          db '[BOOT] GDT',0x20,0x00
    .ipic:          db '[BOOT] PIC',0x20,0x00
    .iapic:         db '[BOOT] APIC',0x20,0x00
    .iidt:          db '[BOOT] IDT',0x20,0x00
    .ipit:          db '[BOOT] PIT',0x20,0x00
    .icpuvendor:    db '[INFO] CPU Vendor:',0x00
    .icpumodel:     db '[INFO] CPU Model:',0x00
    .icpuprefix:    db '[INFO] -->',0x20,0x00
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

    ; Disable interrupts
    cli

    ; Point esp to kernel stack
    mov esp, stack.top

    ; Test for multiboot1
    cmp eax, 0x2BADB002
    je .multiboot1

    ; Test for multiboot2
    cmp eax, 0x36D76289
    je .multiboot2

;
; Handle unsupported bootloader.
;
.unsupported:
    kprints err.otherloader
    jmp .freeze

;
; Handle multiboot1 boot.
;
.multiboot1:
    kprints err.mblegloader
    jmp .freeze

;
; Handle multiboot2 boot.
;
.multiboot2:
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx
    jmp kmain

;
; Do nothing.
;
.freeze:
    cli
    hlt
    jmp .freeze

;
; Prints a message and calls a function.
; Pretty simple, but incredibly useful.
;
; Usage:
; setup <message> <, routine>
;
; Notes:
; <message> => msg.i<message>
;
; More notes:
; We just assume that the call was successful
; if the kernel still runs after it. Duh.
;
%macro setup 2
    kprints msg.i%1
    %2
    kprints msg.ok, COLOR_CUSTOM_OK
%endmacro

;
; Main entry point of the kernel.
; Gets jumped into by `start`.
;
kmain:

; Pave the way for .main.
.setup:
    setup gdt, ksetupgdt
    setup pic, ksetuppic
    setup idt, ksetupidt
    setup pit, ksetuppit
    setup serial, kinitcom
    kinstallirq 0x00, pit
    sti

; There we go
.main:
    call .print_cpu_info
    ksendcoms msg.welcome
    kprints msg.welcome
    jmp .end

; Temporary workaround to keep the kernel alive.
.end:
    jmp .end

;
; Prints some basic information about the CPU.
; Registers are preserved.
;
.print_cpu_info:
    kprints msg.icpuvendor
    call textmode.println
    kprints msg.icpuprefix
    call cpuid_helper.print_vendor_string
    call textmode.println
    kprints msg.icpumodel
    call textmode.println
    kprints msg.icpuprefix
    call cpuid_helper.print_brand_string
    call textmode.println
    ret

section .bss

; Bootstrap stack
align 4
stack:
.bottom:
    resb 4096
.top:

;
; Buffer to store the result of __itoa in.
;
; Reserved:
; 0x00-0x01 sign
; 0x01-0x23 digits (2**32-1 in base 2 has 34 digits)
; 0x23-0x24 NUL
;
align 4
__itoabuf32:
    resb 36