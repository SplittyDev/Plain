section .rodata

;
; Macro to set the PIT up.
;
; Usage:
; ksetuppit
;
%macro ksetuppit 0
    call pit.setup
%endmacro

; PIT constants
%define PIT_PHASE       100
%define PIT_FREQUENCY   1193182
%define PIT_DIVISOR     PIT_FREQUENCY / PIT_PHASE
%define PIT_CH0         0x40
%define PIT_CH1         0x41
%define PIT_CH2         0x42
%define PIT_COMMAND     0x43

section .text
pit:

;
; Routine to initialize the PIT.
; Registers are preserved.
;
.setup:
    call .set_phase
    ret

;
; Routine to set the phase of the PIT.
; Registers are preserved.
;
.set_phase:
    koutb PIT_COMMAND, 0x36
    koutb PIT_CH0, PIT_DIVISOR & 0xFF
    koutb PIT_CH0, (PIT_DIVISOR >> 8) & 0xFF
    ret

;
; IRQ handler.
; Registers are preserved.
;
.irqh:
    ret