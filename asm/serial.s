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

; Special values
%define SERIAL_ENABLE_DLAB 0x80

;
; Macro to initialize a serial port.
; Registers are preserved.
;
; Usage:
; kinitcom [port]
;
%macro kinitcom 0-1 COM1
    koutb SERIAL_IER    (%1), 0x00 ; Disable IRQs
    koutb SERIAL_LINE   (%1), SERIAL_ENABLE_DLAB
    koutb SERIAL_DATA   (%1), 0x03 ; 38400 baud (lo)
    koutb SERIAL_IER    (%1), 0x00 ; 38400 baud (hi)
    koutb SERIAL_LINE   (%1), 0x03
    koutb SERIAL_FIFO   (%1), 0xC7 ; Enable FIFO
    koutb SERIAL_MODEM  (%1), 0x03 ; RTS = 1, DTS = 1
%endmacro

;
; Macro to spin till the serial port is ready.
; Registers are preserved.
;
; Usage:
; kwaitcom [port]
;
; Example usage:
; kwaitcom
; kwaitcom COM2
;
%macro kwaitcom 0-1 COM1
    push ax
%%wait:
    mov word ax, %1
    add word ax, 0x05
    kinb ax
    and byte al, 0x20
    test al, al
    jz %%wait
    pop ax
%endmacro
;
; Macro to send a character to a serial port.
; Registers are preserved.
;
; Usage:
; ksendcomc <character> [, port]
;
; Example usage:
; ksendcomc 'A'
; ksendcomc 'B', COM1
; ksendcomc 0x43, COM4
;
%macro ksendcomc 1-2 COM1
    kwaitcom %2
    koutb %2, %1
%endmacro

;
; Macro to send an integer to a serial port.
; Registers are preserved.
;
; Usage:
; ksendcomi <integer> [, port]
;
; Example usage:
; ksendcomi 1234
; ksendcomi 0xACAB, 16
; ksendcomi 0xBABE, 16, COM1
; ksendcomi 123456, 10, COM2
;
%macro ksendcomi 1-3 10, COM1
    kitoa %1 %2
    ksendcoms __itoabuf32, %3
%endmacro

;
; Macro to send a null-terminated string to a serial port.
; Registers are preserved.
;
; Usage:
; ksendcoms <string_addr> [, com_port]
;
; Example usage:
; hello db 'hello, world',0
; ksendcoms hello
; ksendcoms hello, COM2
;
%macro ksendcoms 1-2 COM1
    push eax
    mov eax, %1
%%next:
    cmp byte [eax], 0
    je %%end
    ksendcomc [eax], %2
    inc eax
    jmp %%next
%%end:
    pop eax
%endmacro