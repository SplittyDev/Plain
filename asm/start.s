global start

;
; Multiboot2 Headers
;
; Exports:
; None.
;
%include "multiboot2.s"

;
; Plain Hardware Interface.
;
; Exports:
; - PHI_USE
; - PHI_LOAD
; - PHI_UNLOAD
;
%include "phi.s"

;
; Vital Routines.
;
; Exports:
; - kinb
; - kinbsafe
; - koutb
; - koutbwait
; - kmemsetb
; - kmemsetw
; - kmemcpy
; - kiowait
;
%include "vital.s"

;
; String Routines.
;
; Exports:
; - kitoa
;
%include "string.s"

;
; VGA Textmode Framebuffer.
;
; Exports:
; - kprintc
; - kprints
; - kprinti
;
PHI_USE textmode

;
; Serial Port.
;
; Exports:
; - ksendcomc
; - ksendcoms
; - ksendcomi
;
PHI_USE serial    

;
; Programmable Interrupt Controller.
;
; Exports:
; None.
;  
PHI_USE pic

;
; Global Descriptor Table.
;
; Exports:
; None.
;  
PHI_USE gdt

;
; Interrupt Descritor Table.
;
; Exports:
; - IRQ_INSTALL
;
PHI_USE idt

;
; Programmable Interval Timer.
;
; Exports:
; None.
;
PHI_USE pit

;
; Real Time Clock.
;
; Exports:
; - kreadrtc
;
PHI_USE rtc

;
; PS/2 Keyboard.
;
; Exports:
; - kgetc
;
PHI_USE keyboard

;
; CPUID Query Helpers.
;
; Exports:
; - cpuid
; --- .print_vendor_string
; --- .print_brand_string
;
%include "cpuid.s"

;
; Constant strings used by the kernel.
;
section .rodata
loglevel:
    .boot:          db '[BOOT]',0x20,0x00
    .info:          db '[INFO]',0x20,0x00
    .debug:         db '[DEBUG]',0x20,0x00
    .error:         db '[ERROR]',0x20,0x00
msg:
    .ok:            db 'OK',0x0A,0x00
    .fail:          db 'FAIL',0x0A,0x00
    .hexprefix:     db '0x',0x00
    .iserial:       db 'RS-232',0x20,0x00
    .igdt:          db 'GDT',0x20,0x00
    .ipic:          db 'PIC',0x20,0x00
    .iapic:         db 'APIC',0x20,0x00
    .iidt:          db 'IDT',0x20,0x00
    .ipit:          db 'PIT',0x20,0x00
    .irtc:          db 'RTC',0x20,0x00
    .cpuvendor:     db 'CPU Vendor:',0x00
    .cpumodel:      db 'CPU Model:',0x00
    .arrow:         db '-->',0x20,0x00
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
; setup <thing>
;
; Transformations:
; msg => msg.i<thing>
; routine => ksetup<thing>
;
; More notes:
; We just assume that the call was successful
; if the kernel still runs after it. Duh.
;
%macro setup 1
    kprints loglevel.boot
    kprints msg.i%1
    ksetup%1
    kprints msg.ok, COLOR_CUSTOM_OK
%endmacro

;
; Main entry point of the kernel.
; Gets jumped into by `start`.
;
kmain:
kprintc `\n`

; Pave the way for .main.
.setup:
    PHI_LOAD gdt
    PHI_LOAD pic
    PHI_LOAD idt
    PHI_LOAD pit
    PHI_LOAD rtc
    PHI_LOAD serial
    IRQ_INSTALL 0x00, pit
    IRQ_INSTALL 0x01, keyboard
    IRQ_INSTALL 0x08, rtc
    sti

; There we go
.main:
    call .print_cpu_info
    ksendcoms msg.welcome
    kprints msg.welcome
    kprinti 31

; Temporary workaround to keep the kernel alive.
.end:
    call textmode.disable_cursor
    jmp $

;
; Prints some basic information about the CPU.
; Registers are preserved.
;
.print_cpu_info:
    kprints loglevel.info
    kprints msg.cpuvendor
    call textmode.println
    kprints loglevel.info
    kprints msg.arrow
    call cpuid_helper.print_vendor_string
    call textmode.println
    kprints loglevel.info
    kprints msg.cpumodel
    call textmode.println
    kprints loglevel.info
    kprints msg.arrow
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