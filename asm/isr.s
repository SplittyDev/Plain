section .rodata

%macro kisr 1
%%enter:
    pushad
    push ds
    push es
    push fs
    push gs
%%transition:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
%%general:
    mov al, %1
    cmp byte al, 0x1F
    jle %%exception
    cmp byte al, 0x2F
    jle %%irq
    jmp %%hang
%%exception:
    call textmode.disable_cursor
    mov dword [textmode_data.x], 0x00
    mov dword [textmode_data.y], 0x00
    mov dword eax, %1
    imul eax, 32
    add eax, exception_table
    kprints eax, MAKECOLOR(COLOR_WHITE, COLOR_RED)
%%hang:
    cli
    hlt
    jmp %%hang
%%irq:
    ;kprints msg.hexprefix
    ;kprinti %1, 16
    kintack %1
%%leave:
    pop gs
    pop fs
    pop es
    pop ds
    popad
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