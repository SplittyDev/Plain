section .rodata

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

;
; Macro to print a string.
; Registers are preserved.
;
; Usage:
; kprints <string_addr>
;
%macro kprints 1
    push eax
    mov eax, %1
    call textmode.prints
    pop eax
%endmacro

;
; Macro to print a colored string.
; Registers are preserved.
;
; Usage:
; kprints <string_addr>, <color>
;
%macro kprints 2
    push ax
    mov al, %2
    call textmode.set_color
    pop ax
    kprints %1
    call textmode.reset_color
%endmacro

section .data
textmode_data:
    .x: dd 0x00 ; x
    .y: dd 0x00 ; y
    .c: db 0x07 ; color
    .w: db 0x50 ; width
    .h: db 0x19 ; height
    .z: db 0x01 ; cursor

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
    cmp byte [textmode_data.z], 0x00
    je .update_cursor_end
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
.update_cursor_end:
    ret

;
; VGA routine to update the cursor position.
; Calculates the correct cursor position and updates it.
; Registers are preserved.
;
.update_cursor_ex:
    push ecx
    call .get_cursor_location
    call .update_cursor
    pop ecx
    ret

;
; VGA routine to disable the cursor.
; Registers are preserved.
;
.disable_cursor:
    push ax
    push dx
    mov al, 0x0A
    mov dx, 0x03D4
    out dx, al
    mov dx, 0x03D5
    in al, dx
    or al, 0x20
    push ax
    mov al, 0x0A
    mov dx, 0x03D4
    out dx, al
    mov dx, 0x03D5
    pop ax
    out dx, al
    pop dx
    pop ax
    mov byte [textmode_data.z], 0x00
    ret

;
; VGA routine to enable the cursor.
; Registers are preserved.
;
.enable_cursor:
    push ax
    push dx
    mov al, 0x0A
    mov dx, 0x03D4
    out dx, al
    mov dx, 0x03D5
    in al, dx
    and al, ~0x20
    push ax
    mov al, 0x0A
    mov dx, 0x03D4
    out dx, al
    mov dx, 0x03D5
    pop ax
    out dx, al
    pop dx
    pop ax
    mov byte [textmode_data.z], 0x01
    ret

;
; VGA routine to calculate the cursor location.
; Stores the result in ECX.
;
.get_cursor_location:
    mov ecx, [textmode_data.y]
    imul ecx, 80
    add ecx, [textmode_data.x]
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
    call .get_cursor_location
    mov bl, [textmode_data.c]
    mov [0xb8000 + 0 + ecx * 2], al ; *(0xB8000 + 0 + off * 2) = char
    mov [0xb8000 + 1 + ecx * 2], bl ; *(0xB8000 + 1 + off * 2) = color
    pop ebx
    pop ecx
    inc byte [textmode_data.x]
    cmp byte [textmode_data.x], 80
    jge .printc_handle_lf
    call .update_cursor_ex
    ret
.printc_handle_lf:
    inc dword [textmode_data.y]
.printc_handle_cr:
    mov dword [textmode_data.x], 0
    call .update_cursor_ex
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
; VGA routine to print a line feed character.
; Registers are preserved.
;
.println:
    push ax
    mov al, 0x0A
    call .printc
    pop ax
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
    call .println
    ret