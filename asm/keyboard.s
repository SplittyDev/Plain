section .rodata

;
; Keyboard registers
;

%define KBD_DATA    0x60
%define KBD_STATUS  0x64

;
; Keyboard responses
;
; Terminology:
; ACK = Acknowledge
; ST = Self test
;

%define KBD_RES_ACK         0xFA
%define KBD_RES_ECHO        0xEE
%define KBD_RES_RESEND      0xFE
%define KBD_RES_ERROR_A     0x00
%define KBD_RES_ERROR_B     0xFF
%define KBD_RES_ST_PASS     0xAA
%define KBD_RES_ST_FAIL_A   0xFC
%define KBD_RES_ST_FAIL_B   0xFD

;
; Keyboard command constants
;
; Terminology:
; TM = Typematic
; AR = Autorepeat
; MK = Make
; RE = Release
;

%define KBD_COM_LED                 0xED
%define KBD_COM_ECHO                0xEE
%define KBD_COM_SCANCODE            0xF0
%define KBD_COM_IDENTIFY            0xF2
%define KBD_COM_TYPEMATIC           0xF3
%define KBD_COM_SCAN_ON             0xF4
%define KBD_COM_SCAN_OFF            0xF5
%define KBD_COM_SET_DEFAULT         0xF6
%define KBD_COM_TM_AR_ALL           0xF7
%define KBD_COM_MK_RE_ALL           0xF8
%define KBD_COM_MK_ALL              0xF9
%define KBD_COM_TM_AR_MK_RE_ALL     0xFA
%define KBD_COM_TM_AR_SINGLE        0xFB
%define KBD_COM_MK_RE_SINGLE        0xFC
%define KBD_COM_MK_SINGLE           0xFD
%define KBD_COM_RESEND              0xFE
%define KBD_COM_SELF_TEST           0xFF

section .rodata:
keymap:
.en_us:
    db `\0`                 ; NUL
    db `\e`                 ; ESC
    db `1234567890-=`       ;
    db `\b`                 ; BS
    db `\t`                 ; TAB
    db `qwertyuiop[]\n`     ;
    db 0                    ; Control
    db `asdfghjkl;'\``      ;
    db 0                    ; LShift
    db `\\zxcvbnm,./`       ;
    db 0                    ; RShift
    db 0                    ; Alt
    db ' '                  ; Space
    db 0                    ; Caps Lock
    db 0,0,0,0,0,0,0,0,0,0  ; F1 - F10
    db 0                    ; Num Lock
    db 0                    ; Scroll Lock
    db 0                    ; Home
    db 0                    ; Arrow Up
    db 0                    ; Page Up
    db '-'                  ; Keypad Minus
    db 0                    ; Arrow Left
    db 0                    ;
    db 0                    ; Arrow Right
    db '+'                  ; Keypad Plus
    db 0                    ; End
    db 0                    ; Arrow Down
    db 0                    ; Page Down
    db 0                    ; Insert
    db 0                    ; Delete
    db 0,0,0                ;
    db 0,0                  ; F11 - F12
    times 128-$+.en_us db 0
    db 0
    db 0
    db `!@#$%^&*()_+`
    db 0
    db 0
    db `QWERTYUIOP{}\n`
    db 0
    db `ASDFGHJKL:"~`
    db 0
    db `|ZXCVBNM<>?`
    db 0
    db 0
    db ' '
    db 0
    db 0,0,0,0,0,0,0,0,0,0
    db 0
    db 0
    db 0
    db 0
    db 0
    db '-'
    db 0
    db 0
    db 0
    db '+'
    db 0
    db 0
    db 0
    db 0
    db 0
    db 0,0,0
    db 0,0
    times 256-$+.en_us db 0

section .data
keyboard_data:
    .shift: db 0

section .text
keyboard:

;
; IRQ handler.
;
.irqh:
.irqh_enter:
    push eax
    push ebx
.irqh_scan:
    xor eax, eax
    kinb KBD_DATA
    mov bl, al
    and bl, 0x80
    test bl, bl
    jz .irqh_key_pressed
    jmp .irqh_key_released
.irqh_key_pressed:
.irqh_check_shift_a:
    cmp eax, 42 ; LShift
    je .irqh_set_shift
    cmp eax, 55 ; RShift
    je .irqh_set_shift
    mov byte dl, [keyboard_data.shift]
    test dl, dl
    jnz .irqh_add_shift
    jmp .irqh_print_key
.irqh_set_shift:
    mov byte [keyboard_data.shift], 1
    jmp .irqh_leave
.irqh_add_shift:
    add eax, 128
.irqh_print_key:
    mov byte [keyboard_data.shift], 0
    add eax, keymap.en_us
    kprintc [eax]
    jmp .irqh_leave
.irqh_key_released:
    jmp .irqh_leave
.irqh_leave:
    pop ebx
    pop eax
    ret