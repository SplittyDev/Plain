section .rodata:
idt_msg:
    .generic_error: db 0x0A,'*** ERROR!!!',0x00

;
; Macro to calculate the base address of the given gate.
;
%define IDT_GATE_ADDR(gate) (idt_data.start + (gate * 0x40))

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
    mov word [eax + 0x04], 0x0000
    ; Set flags
    mov word [eax + 0x05], %4
    ; Set high base
    shr ebx, 16
    mov word [eax + 0x06], bx
    pop ebx
    pop eax
%endmacro

section .rodata:
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
    idtsetgate 0x00, isr.isr00, 0x08, 0x8E
    idtsetgate 0x01, isr.isr01, 0x08, 0x8E
    idtsetgate 0x02, isr.isr02, 0x08, 0x8E
    idtsetgate 0x03, isr.isr03, 0x08, 0x8E
    idtsetgate 0x04, isr.isr04, 0x08, 0x8E
    idtsetgate 0x05, isr.isr05, 0x08, 0x8E
    idtsetgate 0x06, isr.isr06, 0x08, 0x8E
    idtsetgate 0x07, isr.isr07, 0x08, 0x8E
    idtsetgate 0x08, isr.exc08, 0x08, 0x8E
    idtsetgate 0x09, isr.isr09, 0x08, 0x8E
    idtsetgate 0x0a, isr.exc10, 0x08, 0x8E
    idtsetgate 0x0b, isr.exc11, 0x08, 0x8E
    idtsetgate 0x0c, isr.exc12, 0x08, 0x8E
    idtsetgate 0x0d, isr.exc13, 0x08, 0x8E
    idtsetgate 0x0e, isr.exc14, 0x08, 0x8E
    idtsetgate 0x0f, isr.isr15, 0x08, 0x8E
    idtsetgate 0x10, isr.isr16, 0x08, 0x8E
    idtsetgate 0x11, isr.isr17, 0x08, 0x8E
    idtsetgate 0x12, isr.isr18, 0x08, 0x8E
    idtsetgate 0x13, isr.isr19, 0x08, 0x8E
    idtsetgate 0x14, isr.isr20, 0x08, 0x8E
    idtsetgate 0x15, isr.isr21, 0x08, 0x8E
    idtsetgate 0x16, isr.isr22, 0x08, 0x8E
    idtsetgate 0x17, isr.isr23, 0x08, 0x8E
    idtsetgate 0x18, isr.isr24, 0x08, 0x8E
    idtsetgate 0x19, isr.isr25, 0x08, 0x8E
    idtsetgate 0x1a, isr.isr26, 0x08, 0x8E
    idtsetgate 0x1b, isr.isr27, 0x08, 0x8E
    idtsetgate 0x1c, isr.isr28, 0x08, 0x8E
    idtsetgate 0x1d, isr.isr29, 0x08, 0x8E
    idtsetgate 0x1e, isr.isr30, 0x08, 0x8E
    idtsetgate 0x1f, isr.isr31, 0x08, 0x8E
    idtsetgate 0x20, isr.isr32, 0x08, 0x8E
    idtsetgate 0x21, isr.isr33, 0x08, 0x8E
    idtsetgate 0x22, isr.isr34, 0x08, 0x8E
    idtsetgate 0x23, isr.isr35, 0x08, 0x8E
    idtsetgate 0x24, isr.isr36, 0x08, 0x8E
    idtsetgate 0x25, isr.isr37, 0x08, 0x8E
    idtsetgate 0x26, isr.isr38, 0x08, 0x8E
    idtsetgate 0x27, isr.isr39, 0x08, 0x8E
    idtsetgate 0x28, isr.isr40, 0x08, 0x8E
    idtsetgate 0x29, isr.isr41, 0x08, 0x8E
    idtsetgate 0x2a, isr.isr42, 0x08, 0x8E
    idtsetgate 0x2b, isr.isr43, 0x08, 0x8E
    idtsetgate 0x2c, isr.isr44, 0x08, 0x8E
    idtsetgate 0x2d, isr.isr45, 0x08, 0x8E
    idtsetgate 0x2e, isr.isr46, 0x08, 0x8E
    idtsetgate 0x2f, isr.isr47, 0x08, 0x8E
    jmp .load

;
; Routine to load the IDT.
; Does not modify any registers.
;
.load:
    lidt [idt_data.idtr]
    ret