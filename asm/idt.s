section .rodata

;
; Macro to calculate the base address of the given gate.
;
%define IDT_GATE_ADDR(gate) (idt_data.start + (gate * 8))

;
; Macro to set an IDT gate.
;
; Usage:
; idtsetgate <num> <base_addr> <sel> <flags>
;
%macro idtsetgate 4
    push eax
    push ebx
    ; Get gate address
    mov eax, IDT_GATE_ADDR(%1)
    ; Set low base
    mov ebx, %2
    mov word [eax + 0x00], bx
    ; Set selector
    mov word [eax + 0x02], %3
    ; Set zero byte
    mov byte [eax + 0x04], 0x00
    ; Set flags
    mov byte [eax + 0x05], %4
    ; Set high base
    shr ebx, 16
    mov word [eax + 0x06], bx
    pop ebx
    pop eax
%endmacro

;
; Macro to build an ISR (Common).
;
%macro build_isr 1
    .isr%1:
        cli
        kisr %1
        iretd
%endmacro

;
; Macro to build an ISR (Exception).
;
%macro build_exc 1
    .isr%1:
        cli
        kisr %1
        add esp, 8
        iretd
%endmacro

section .rodata
idt_data:

;
; IDT register
;
align 16
.idtr:
    ; Limit
    dw .end - .start - 1
    ; Base
    dd .start

section .bss
align 16

;
; IDT contents
;
.start:
    resb 0x4000
.end:

section .text
idt:

;
; Routine to set ISRs up.
; Loads the IDT in the process.
; Does not modify any registers.
;
.setup:

    ; Exceptions
    idtsetgate 0x00, idt.isr00, 0x08, 0x8E
    idtsetgate 0x01, idt.isr01, 0x08, 0x8E
    idtsetgate 0x02, idt.isr02, 0x08, 0x8E
    idtsetgate 0x03, idt.isr03, 0x08, 0x8E
    idtsetgate 0x04, idt.isr04, 0x08, 0x8E
    idtsetgate 0x05, idt.isr05, 0x08, 0x8E
    idtsetgate 0x06, idt.isr06, 0x08, 0x8E
    idtsetgate 0x07, idt.isr07, 0x08, 0x8E
    idtsetgate 0x08, idt.isr08, 0x08, 0x8E
    idtsetgate 0x09, idt.isr09, 0x08, 0x8E
    idtsetgate 0x0a, idt.isr10, 0x08, 0x8E
    idtsetgate 0x0b, idt.isr11, 0x08, 0x8E
    idtsetgate 0x0c, idt.isr12, 0x08, 0x8E
    idtsetgate 0x0d, idt.isr13, 0x08, 0x8E
    idtsetgate 0x0e, idt.isr14, 0x08, 0x8E
    idtsetgate 0x0f, idt.isr15, 0x08, 0x8E
    idtsetgate 0x10, idt.isr16, 0x08, 0x8E
    idtsetgate 0x11, idt.isr17, 0x08, 0x8E
    idtsetgate 0x12, idt.isr18, 0x08, 0x8E

    ; Reserved
    idtsetgate 0x13, idt.isr19, 0x08, 0x8E
    idtsetgate 0x14, idt.isr20, 0x08, 0x8E
    idtsetgate 0x15, idt.isr21, 0x08, 0x8E
    idtsetgate 0x16, idt.isr22, 0x08, 0x8E
    idtsetgate 0x17, idt.isr23, 0x08, 0x8E
    idtsetgate 0x18, idt.isr24, 0x08, 0x8E
    idtsetgate 0x19, idt.isr25, 0x08, 0x8E
    idtsetgate 0x1a, idt.isr26, 0x08, 0x8E
    idtsetgate 0x1b, idt.isr27, 0x08, 0x8E
    idtsetgate 0x1c, idt.isr28, 0x08, 0x8E
    idtsetgate 0x1d, idt.isr29, 0x08, 0x8E
    idtsetgate 0x1e, idt.isr30, 0x08, 0x8E
    idtsetgate 0x1f, idt.isr31, 0x08, 0x8E

    ; IRQs
    idtsetgate 0x20, idt.isr32, 0x08, 0x8E
    idtsetgate 0x21, idt.isr33, 0x08, 0x8E
    idtsetgate 0x22, idt.isr34, 0x08, 0x8E
    idtsetgate 0x23, idt.isr35, 0x08, 0x8E
    idtsetgate 0x24, idt.isr36, 0x08, 0x8E
    idtsetgate 0x25, idt.isr37, 0x08, 0x8E
    idtsetgate 0x26, idt.isr38, 0x08, 0x8E
    idtsetgate 0x27, idt.isr39, 0x08, 0x8E
    idtsetgate 0x28, idt.isr40, 0x08, 0x8E
    idtsetgate 0x29, idt.isr41, 0x08, 0x8E
    idtsetgate 0x2a, idt.isr42, 0x08, 0x8E
    idtsetgate 0x2b, idt.isr43, 0x08, 0x8E
    idtsetgate 0x2c, idt.isr44, 0x08, 0x8E
    idtsetgate 0x2d, idt.isr45, 0x08, 0x8E
    idtsetgate 0x2e, idt.isr46, 0x08, 0x8E
    idtsetgate 0x2f, idt.isr47, 0x08, 0x8E

    lidt [idt_data.idtr]
    ret

; ISRs (Exceptions)
build_isr 00
build_isr 01
build_isr 02
build_isr 03
build_isr 04
build_isr 05
build_isr 06
build_isr 07
build_exc 08
build_isr 09
build_exc 10
build_exc 11
build_exc 12
build_exc 13
build_exc 14
build_isr 15
build_isr 16
build_exc 17
build_isr 18

; ISRs (Reserved)
build_isr 19
build_isr 20
build_isr 21
build_isr 22
build_isr 23
build_isr 24
build_isr 25
build_isr 26
build_isr 27
build_isr 28
build_isr 29
build_isr 30
build_isr 31

; IRQs
build_isr 32
build_isr 33
build_isr 34
build_isr 35
build_isr 36
build_isr 37
build_isr 38
build_isr 39
build_isr 40
build_isr 41
build_isr 42
build_isr 43
build_isr 44
build_isr 45
build_isr 46
build_isr 47