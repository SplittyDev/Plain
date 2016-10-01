section .rodata

; COM ports
%define COM1 0x03F8
%define COM2 0x02F8
%define COM3 0x03E8
%define COM4 0x02E8

; Macros for addresses
%define SERIAL_DATA(port)           (port + 0x00)
%define SERIAL_IER(port)            (port + 0x01)
%define SERIAL_FIFO(port)           (port + 0x02)
%define SERIAL_LINE(port)           (port + 0x03)
%define SERIAL_MODEM(port)          (port + 0x04)
%define SERIAL_LINE_STATUS(port)    (port + 0x05)

;
; Macro to initialize a serial port.
; Registers are preserved.
;
; Usage:
; kinitcom <com_port>
;
%macro kinitcom 1
    koutb SERIAL_IER    (%1), 0x00 ; Disable IRQs
    koutb SERIAL_LINE   (%1), 0x80 ; Enable DLAB
    koutb SERIAL_DATA   (%1), 0x03 ; 38400 baud (lo)
    koutb SERIAL_IER    (%1), 0x00 ; 38400 baud (hi)
    koutb SERIAL_LINE   (%1), 0x03
    koutb SERIAL_FIFO   (%1), 0xC7 ; Enable FIFO
    koutb SERIAL_MODEM  (%1), 0x0B ; Enable IRQs
%endmacro

;
; Macro to send a character to a serial port.
; Registers are preserved.
;
; Usage:
; ksendcomc <com_port> <char>
;
%macro ksendcomc 2
    koutb %1, %2
%endmacro

;
; Macro to send a null-terminated string to a serial port.
; Registers are preserved.
;
; Usage:
; ksendcoms <com_port> <string_addr>
;
%macro ksendcoms 2
%%start:
    push dx
    mov dx, %1
    push eax
    mov eax, %2
%%next:
    cmp byte [eax], 0
    je %%end
    push ax
    mov al, [eax]
    out dx, al
    pop ax
    inc eax
    jmp %%next
%%end:
    pop eax
    pop dx
%endmacro