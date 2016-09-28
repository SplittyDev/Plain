global start
%include "multiboot2.s"

section .rodata
msg:
    .welcome: db 'Welcome to plain!',10,'test...',0

section .data
console:
    .x: db 0x00 ; x
    .y: db 0x00 ; y
    .c: db 0x07 ; color

section .text
bits 32

start:
    cli
    mov esp, stack.top
    jmp kmain

kmain:
    ; Print welcome message
    mov eax, msg.welcome
    call vga.prints
    ; Halt
    hlt

vga:
; VGA routine to print a single char.
; Preserves registers.
;
; Register - Argument
; -------- - ---------
; eax      - char
; -------- - ---------
.printc:
    cmp al, 10                      ; test if char is '\n'
    je .printc_case_nl              ; ---> jump to handler
    cmp al, 13                      ; test if char is '\r'
    je .printc_case_cr              ; ---> jump to handler
    jmp .printc_default             ; jump to the print routine
.printc_case_nl:                    ; case '\n':
    inc byte [console.y]            ; y = y + 1
.printc_case_cr:                    ; case '\r':
    mov byte [console.x], 0x00      ; x = 0
    ret                             ; return
.printc_default:                    ; default:
    push ebx                        ; save ebx
    push ecx                        ; save ecx
    mov cl, [console.y]             ; off = y
    imul cx, 80                     ; off = ptr * 80
    add cl, [console.x]             ; off = ptr + x
    mov bl, [console.c]             ; load color
    mov [0xb8000 + 0 + ecx * 2], al ; *(0xB8000 + 0 + off * 2) = char
    mov [0xb8000 + 1 + ecx * 2], bl ; *(0xB8000 + 1 + off * 2) = color
    inc byte [console.x]            ; x = x + 1
    pop ecx                         ; restore ecx
    pop ebx                         ; restore ebx
    ret                             ; return
; VGA routine to print a null-terminated string.
;
; Register - Argument
; -------- - ---------
; eax      - str
; -------- - ---------
.prints:
    push eax
.prints_loop:
    cmp byte [eax], 0   ; if *str == '\0'
    je .prints_next     ; break
    push eax            ; save str
    mov al, [eax]       ; chr = *str
    call .printc        ; print chr
    pop eax             ; restore str
    inc eax             ; str++
    jmp .prints_loop    ; continue
.prints_next:
    pop eax
    ret

section .bss
align 4096

; Bootstrap stack
stack:
.bottom:
    resb 4096
.top: