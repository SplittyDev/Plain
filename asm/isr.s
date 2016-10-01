section .rodata

;
; Macro to build an ISR (Common).
;
%macro build_isr 1
    .isr%1:
        cli
        push byte 0
        push byte %1
        jmp .stub
%endmacro

;
; Macro to build an ISR (Exception).
;
%macro build_exc 1
    .exc%1:
        cli
        push byte %1
        jmp .stub
%endmacro

section .rodata
exception_table:
    db 'DIVIDE BY ZERO',0x00,'                 '
    db 'DEBUG',0x00,'                          '
    db 'NON MASKABLE INTERRUPT',0x00,'         '
    db 'BREAKPOINT',0x00,'                     '
    db 'INTO DETECTED OVERFLOW',0x00,'         '
    db 'OUT OF BOUNDS',0x00,'                  '
    db 'INVALID OPCODE',0x00,'                 '
    db 'NO COPROCESSOR',0x00,'                 '
    db 'DOUBLE FAULT',0x00,'                   '
    db 'COPROCESSOR SEGMENT OVERRUN',0x00,'    '
    db 'BAD TSS',0x00,'                        '
    db 'SEGMENT NOT PRESENT',0x00,'            '
    db 'STACK FAULT',0x00,'                    '
    db 'GENERAL PROTECTION FAULT',0x00,'       '
    db 'PAGE FAULT',0x00,'                     '
    db 'UNKNOWN INTERRUPT',0x00,'              '
    db 'COPROCESSOR FAULT',0x00,'              '
    db 'ALIGNMENT CHECK',0x00,'                '
    db 'MACHINE CHECK',0x00,'                  '
    db 'X',0x00,'                              '
    db 'X',0x00,'                              '
    db 'X',0x00,'                              '
    db 'X',0x00,'                              '
    db 'X',0x00,'                              '
    db 'X',0x00,'                              '
    db 'X',0x00,'                              '
    db 'X',0x00,'                              '
    db 'X',0x00,'                              '
    db 'X',0x00,'                              '
    db 'X',0x00,'                              '
    db 'X',0x00,'                              '
    db 'X',0x00,'                              '

section .data
isr_frame:
    .irql:  db 0x00
    .eax:   dd 0x00000000
    .ebx:   dd 0x00000000
    .ecx:   dd 0x00000000
    .edx:   dd 0x00000000
    .esp:   dd 0x00000000

section .text
isr:

;
; General ISR handler.
;
.handle_general:
    cmp byte [isr_frame.irql], 0x1F
    jle .handle_exception
    cmp byte [isr_frame.irql], 0x2F
    jle .handle_irq
    cli
    hlt

;
; Exception handler.
;
.handle_exception:
    xor eax, eax
    mov al, [isr_frame.irql]
    shl al, 24
    imul eax, 32
    add eax, exception_table
    mov dword [textmode_data.x], 0x00
    mov dword [textmode_data.y], 0x00
    call textmode.disable_cursor
    kprints eax, MAKECOLOR(COLOR_WHITE, COLOR_RED)
    cli
    hlt

;
; IRQ handler.
;
.handle_irq:
    call pic.send_eoi ; TODO: FIX!
    ret

;
; Common ISR stub.
;
.stub:
    mov dword [isr_frame.eax], eax
    mov dword [isr_frame.ebx], ebx
    mov dword [isr_frame.ecx], ecx
    mov dword [isr_frame.edx], edx
    mov dword [isr_frame.esp], esp
    pusha
    mov ax, 0x10
    mov dx, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    ;call .handle_general
    popa
    add esp, 8
    iret

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
build_isr 17
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