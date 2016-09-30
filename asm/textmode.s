section .data
textmode_data:
    .x: dd 0x00
    .y: dd 0x00
    .c: db 0x07
    .w: db 0x50
    .h: db 0x19

; Colors
%define COLOR_BLACK           0x0
%define COLOR_BLUE            0x1
%define COLOR_GREEN           0x2
%define COLOR_CYAN            0x3
%define COLOR_RED             0x4
%define COLOR_MAGENTA         0x5
%define COLOR_BROWN           0x6
%define COLOR_LIGHTGRAY       0x7
%define COLOR_DARKGRAY        BRIGHT(COLOR_BLACK)
%define COLOR_LIGHTBLUE       BRIGHT(COLOR_BLUE)
%define COLOR_LIGHTGREEN      BRIGHT(COLOR_GREEN)
%define COLOR_LIGHTCYAN       BRIGHT(COLOR_CYAN)
%define COLOR_LIGHTRED        BRIGHT(COLOR_RED)
%define COLOR_LIGHTMAGENTA    BRIGHT(COLOR_MAGENTA)
%define COLOR_YELLOW          BRIGHT(COLOR_BROWN)
%define COLOR_WHITE           BRIGHT(COLOR_LIGHTGRAY)

; Default colors
%define COLOR_DEFAULT_FC      COLOR_LIGHTGRAY
%define COLOR_DEFAULT_BC      COLOR_BLACK
%define COLOR_DEFAULT         MAKECOLOR(COLOR_DEFAULT_FC, COLOR_DEFAULT_BC)

; Custom colors
%define COLOR_CUSTOM_OK       MAKECOLOR(COLOR_GREEN, COLOR_DEFAULT_BC)
%define COLOR_CUSTOM_FAIL     MAKECOLOR(COLOR_RED, COLOR_DEFAULT_BC)

; Helper macros
%define BRIGHT(c) (0x8 + c)
%define MAKECOLOR(fc, bc) ((fc & 0x0F) | (bc << 4))

section .text
textmode:

;
; VGA routine to set the text color.
; Registers are preserved.
;
; AL: Foreground
; BL: Background
;
; Calculating the color attribute:
; color = (fc & 0x0F) | (bc << 4)
;
.set_color:
    push ax
    and al, 0x0F
    mov ah, bl
    shl ah, 4
    or al, ah
    call .set_color_ex
    pop ax
    ret

;
; VGA routine to set the text color.
; Use the MAKECOLOR macro to create the attribute.
; Registers are preserved.
;
; AL: Attribute
;
.set_color_ex:
    mov [textmode_data.c], al
    ret

;
; VGA routine to reset the text color.
; Uses the color specified in the DEFAULT macro.
; Registers are preserved.
;
.reset_color:
    mov byte [textmode_data.c], COLOR_DEFAULT
    ret

;
; VGA routine to update the cursor position.
; Registers are preserved.
;
; CX: Target location
;
; Calculating the target location:
; cx = (y * 80 + x) & 0xFF
;
.update_cursor:
    push ax
    push dx
    mov al, 0x0E
    mov dx, 0x03D4
    out dx, al
    push cx
    mov ax, cx
    pop cx
    shr ax, 8
    mov dx, 0x03D5
    out dx, al
    mov al, 0x0F
    mov dx, 0x03D4
    out dx, al
    mov al, cl
    mov dx, 0x03D5
    out dx, al
    pop dx
    pop ax
    ret

;
; VGA routine to disable the cursor.
; Registers are preserved.
;
.disable_cursor:
    push ax
    push dx
    mov al, 0x0F
    mov dx, 0x03D4
    out dx, al
    mov al, 0xFF 
    mov dx, 0x03D5
    out dx, al
    mov al, 0x0E
    mov dx, 0x03D4
    out dx, al
    mov al, 0xFF
    mov dx, 0x03D5
    out dx, al
    pop dx
    pop ax
    ret

;
; VGA routine to print a character.
; Registers are preserved.
;
; AL: Character (ASCII code).
;
.printc:
    cmp al, 0x0A
    je .printc_handle_lf
    cmp al, 0x0D
    je .printc_handle_cr
    push ecx
    push ebx
    mov ecx, [textmode_data.y]
    imul ecx, 80
    add ecx, [textmode_data.x]
    mov bl, [textmode_data.c]
    mov [0xb8000 + 0 + ecx * 2], al ; *(0xB8000 + 0 + off * 2) = char
    mov [0xb8000 + 1 + ecx * 2], bl ; *(0xB8000 + 1 + off * 2) = color
    pop ebx
    inc ecx
    inc byte [textmode_data.x]
    cmp byte [textmode_data.x], 80
    jl .printc_update_cursor
    call .printc_handle_lf
.printc_update_cursor:
    call .update_cursor
    pop ecx
    ret
.printc_handle_lf:
    inc dword [textmode_data.y]
.printc_handle_cr:
    mov dword [textmode_data.x], 0
    ret

;
; VGA routine to print a null-terminated string.
; Registers are preserved.
;
; EAX: Pointer to string.
;
.prints:
    push eax
.prints_loop:
    cmp byte [eax], 0
    je .prints_next
    push eax
    mov al, [eax]
    call .printc
    pop eax
    inc eax
    jmp .prints_loop
.prints_next:
    pop eax
    ret

;
; VGA routine to print a null-terminated string,
; followed by a line-feed (0x0A) character.
; Registers are preserved.
;
; EAX: Pointer to string.
;
.printsln:
    call .prints
    push eax
    mov al, 0x0A
    call .printc
    pop eax
    ret