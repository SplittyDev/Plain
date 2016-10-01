section .rodata
gdt_data:

;
; GDT register.
;
align 16
.gdtr:
    ; Limit
    dw .end - .start - 1
    ; Base
	dd .start

;
; GDT contents.
;
align 16
.start:
    ; Null descriptor
	dw 0x0000, 0x0000
	dw 0x0000, 0x0000
    ; Code descriptor
	dw 0xFFFF, 0x0000
	dw 0x9A00, 0x00CF
    ; Data descriptor
	dw 0xFFFF, 0x0000
	dw 0x9200, 0x00CF
.end:

section .text
gdt:

;
; Routine to load and configure the GDT.
; Segment registers are reloaded automatically.
; General purpose registers are preserved.
;
.setup:
    lgdt [gdt_data.gdtr]
.flush:
    jmp 0x08:.reload
.reload:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    ret