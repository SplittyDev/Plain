section .rodata

;
; Macro to wrap the out instruction.
; Preserves registers.
;
; Usage:
; koutb <addr> <val>
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
; Macro to waste an IO cycle.
; Preserves registers.
;
; Usage:
; kiowait
;
%macro kiowait 0
    koutb 0x80, 0x00
%endmacro