section .rodata
gdt_data:
align 16
.gdtr:
    dw .end - .start - 1
	dd .start
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