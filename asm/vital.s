section .data

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
    mov al, %2
    mov dx, %1
    out dx, al
    pop ax
    pop dx
%endmacro