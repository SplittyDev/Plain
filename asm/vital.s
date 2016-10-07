section .rodata

;
; Define to translate a memory-mapped address
; to the corresponding higher-half address.
;
%xdefine TRANSLATE(addr) (0xC0000000 | addr)

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
; Macro to wrap the in instruction.
; Discards the value after reading.
; Registers are preserved.
;
; Usage:
; kinb <addr>
;
%macro kinbsafe 1
    push ax
    kinb %1
    pop ax
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

;
; Macro to fill a memory area.
; Registers are preserved.
;
; Usage:
; kmemsetb <start_address> <, length> [, filler]
;
%macro kmemsetb 2-3 0x00
%%enter:
    push eax
    push ebx
    push ecx
    xor ecx, ecx
    mov dword eax, %1
    mov dword ebx, %2
%%loop:
    cmp ecx, ebx
    jge %%leave
    mov byte [eax + ecx], %3
    inc ecx
    jmp %%loop
%%leave:
    pop ecx
    pop ebx
    pop eax
%endmacro

;
; Macro to fill a memory area.
; Registers are preserved.
;
; -------------------
; - NOTE: UNTESTED! -
; -------------------
;
; Usage:
; kmemsetw <start_address> <, length> [, filler]
;
%macro kmemsetw 2-3 0x00
%%enter:
    push eax
    push ebx
    push ecx
    xor ecx, ecx
    mov dword eax, %1
    mov dword ebx, %2
%%loop:
    cmp ecx, ebx
    jge %%leave
    mov word [eax + ecx * 2], %3
    inc ecx
    jmp %%loop
%%leave:
    pop ecx
    pop ebx
    pop eax
%endmacro

;
; Macro to copy one memory chunk to another.
; Registers are ..probably.. preserved.
;
; Usage:
; kmemcpy <dest_addr> <, src_addr> <, length>
;
%macro kmemcpy 3
%%enter:
    push eax
    push ebx
    push ecx
    push dx
    mov dword eax, %1
    mov dword ebx, %2
    mov dword ecx, %3
%%loop:
    test ecx, ecx
    jz %%leave
    mov byte dl, [ebx]
    mov byte [eax], dl
    inc eax
    inc ebx
    dec ecx
    jmp %%loop
%%leave:
    pop dx
    pop ecx
    pop ebx
    pop eax
%endmacro