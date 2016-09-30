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

;
; CPUID routine to print the CPU brand string.
; Registers are preserved.
;
.print_brand_string:
    pusha
    mov eax, 0x80000000
    cpuid
    cmp eax, 0x80000004
    jl .print_brand_string_end
    mov eax, 0x80000002
.print_brand_string_loop:
    push eax
    cpuid
    call .print_register_string
    mov eax, ebx
    call .print_register_string
    mov eax, ecx
    call .print_register_string
    mov eax, edx
    call .print_register_string
    pop eax
    add eax, 0x00000001
    cmp eax, 0x80000004
    jle .print_brand_string_loop
.print_brand_string_end:
    popa
    ret

;
; Routine to print a string stored in a register.
; Registers are preserved.
;
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