section .data
console:
    .x: dd 0x00000000 ; x
    .y: dd 0x00000000 ; y
    .c: db 0x07 ; color

section .text
textmode:
; VGA routine to print a single char.
; Preserves registers.
;
; Register - Argument
; -------- - ---------
; eax      - char
; -------- - ---------
.printc:
    cmp al, 10                      ; test if char is '\n'
    je .printc_case_lf              ; ---> jump to handler
    cmp al, 13                      ; test if char is '\r'
    je .printc_case_cr              ; ---> jump to handler
    jmp .printc_default             ; jump to the print routine
.printc_case_lf:                    ; case '\n':
    inc dword [console.y]           ; y = y + 1
.printc_case_cr:                    ; case '\r':
    mov dword [console.x], 0x00     ; x = 0
    ret                             ; return
.printc_default:                    ; default:
    push ebx                        ; save ebx
    push ecx                        ; save ecx
    mov ecx, [console.y]            ; off = y
    imul ecx, 80                    ; off = ptr * 80
    add ecx, [console.x]            ; off = ptr + x
    mov bl, [console.c]             ; load color
    mov [0xb8000 + 0 + ecx * 2], al ; *(0xB8000 + 0 + off * 2) = char
    mov [0xb8000 + 1 + ecx * 2], bl ; *(0xB8000 + 1 + off * 2) = color
    inc byte [console.x]            ; x = x + 1
    pop ecx                         ; restore ecx
    pop ebx                         ; restore ebx
    cmp byte [console.x], 80        ; compare x to 80
    jg .printc_case_lf              ; perform line feed
.printc_scroll:
    ;push eax
    ;mov byte al, 14
    ;out 0x3D4, al
    ;mov eax, ecx
    ;shr eax, 8
    ;out 0x3D5, al
    ;mov byte al, 15
    ;out 0x3D4, al
    ;mov eax, ecx
    ;out 0x3D5, al
    ;pop eax
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