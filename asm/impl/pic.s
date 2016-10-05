section .rodata

; General
%define PIC_EOI             0x20

; Masking
%define PIC_UNMASK          0x00
%define PIC_MASK            0xFF

; PIC 1 (Master)
%define PIC_MASTER_COMMAND  0x20
%define PIC_MASTER_DATA     0x21

; PIC 2 (Slave)
%define PIC_SLAVE_COMMAND   0xA0
%define PIC_SLAVE_DATA      0xA1

; ICW 1
%define PIC_ICW1_ICW4       0x01
%define PIC_ICW1_SINGLE     0x02
%define PIC_ICW1_INTERVAL4  0x04
%define PIC_ICW1_LEVEL      0x08
%define PIC_ICW1_INIT       0x10

; ICW 2
%define PIC_ICW2_MASTER_OFF 0x20
%define PIC_ICW2_SLAVE_OFF  0x28

; ICW 3
%define PIC_ICW3_CASCADE    0x02
%define PIC_ICW3_IRQ2_SLAVE 0x04

; ICW 4
%define PIC_ICW4_8086       0x01
%define PIC_ICW4_AUTO       0x02
%define PIC_ICW4_BUF_SLAVE  0x08
%define PIC_ICW4_BUF_MASTER 0x0C
%define PIC_ICW4_SFNM       0x10

;
; Macro to acknowledge an interrupt.
; Registers are preserved.
;
; Usage:
; kintack <interrupt>
;
%macro kintack 1
%%enter:
    push ax
    mov byte al, %1
    cmp byte al, 0x08
    jl %%master
%%slave:
    koutb PIC_SLAVE_COMMAND, PIC_EOI
%%master:
    koutb PIC_MASTER_COMMAND, PIC_EOI
%%leave:
    pop ax
%endmacro

section .text
pic:

;
; Routine to remap the PIC.
; Registers are preserved.
;
; Remaps PIC 1 to PIC_ICW2_MASTER_OFF.
; Remaps PIC 2 to PIC_ICW2_SLAVE_OFF.
; IRQs are unmasked after remapping.
;
.remap:
    call .remap_master
    call .remap_slave
    call .enable
    ret

;
; Routine to remap PIC 1 to PIC_ICW2_MASTER_OFF.
; Registers are preserved.
;
.remap_master:
    koutbwait PIC_MASTER_COMMAND, PIC_ICW1_INIT + PIC_ICW1_ICW4
    koutbwait PIC_MASTER_DATA, PIC_ICW2_MASTER_OFF
    koutbwait PIC_MASTER_DATA, PIC_ICW3_IRQ2_SLAVE
    koutbwait PIC_MASTER_DATA, PIC_ICW4_8086
    ret

;
; Routine to remap PIC 2 to PIC_ICW2_SLAVE_OFF.
; Registers are preserved.
;
.remap_slave:
    koutbwait PIC_SLAVE_COMMAND, PIC_ICW1_INIT + PIC_ICW1_ICW4
    koutbwait PIC_SLAVE_DATA, PIC_ICW2_SLAVE_OFF
    koutbwait PIC_SLAVE_DATA, PIC_ICW3_CASCADE
    koutbwait PIC_SLAVE_DATA, PIC_ICW4_8086
    ret

;
; PIC routine to unmask all IRQs.
; Registers are preserved.
;
.enable:
    koutbwait PIC_MASTER_DATA, PIC_UNMASK
    koutbwait PIC_SLAVE_DATA, PIC_UNMASK
    ret

;
; PIC routine to mask all IRQs.
; Registers are preserved.
;
.disable:
    koutbwait PIC_MASTER_DATA, PIC_MASK
    koutbwait PIC_SLAVE_DATA, PIC_MASK
    ret