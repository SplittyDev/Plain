%include "impl/gdt.s"
%[PHI_IMPL]:

section .rodata

; PHI driver name.
.name: db 'Global Descriptor Table'

section .text

; PHI load routine.
.load:
    call gdt.setup
    ret

; PHI unload routine.
.unload:
    ret