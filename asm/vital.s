section .rodata

;
; Macro to waste an I/O cycle.
; Preserves registers.
;
; Usage:
; kiowait
;
%macro kiowait 0
    koutb 0x80, 0x00
%endmacro

;
; Macro to wrap the in instruction.
;
; Mapping:
; OUT/AL = Result
;
; Usage:
; kinb <addr>
;
%macro kinb 1
    push dx
    mov word dx, %1
    in al, dx
    pop dx
%endmacro

;
; Macro to wrap the out instruction.
; Preserves registers.
;
; Usage:
; koutb <addr> <, val>
;
%macro koutb 2
    push dx
    push ax
    mov byte al, %2
    mov word dx, %1
    out dx, al
    pop ax
    pop dx
%endmacro

;
; Macro to wrap the out instruction.
; Burns an additional I/O cycle.
; Preserves registers.
;
; Usage:
; koutbwait <addr> <, val>
;
%macro koutbwait 2
    koutb %1, %2
    kiowait
%endmacro