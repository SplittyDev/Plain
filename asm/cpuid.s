section .text
cpuid_helper:

;
; CPUID routine to print the CPU vendor string.
; Registers are preserved.
;
.print_vendor_string:
    pusha
    xor eax, eax
    cpuid
    mov eax, ebx
    call .print_register_string
    mov eax, edx
    call .print_register_string
    mov eax, ecx
    call .print_register_string
    popa
    ret
.print_register_string:
    push eax
    call textmode.printc
    push cx
    mov cl, 0x03
.print_register_string_loop:
    shr eax, 0x08
    call textmode.printc
    dec cl
    cmp cl, 0x00
    jne .print_register_string_loop
.print_register_string_next:
    pop cx
    pop eax
    ret