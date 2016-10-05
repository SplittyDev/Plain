%include "impl/idt.s"
%[PHI_IMPL]:

section .rodata

; PHI driver name.
.name: db 'Interrupt Descriptor Table'

section .text

; PHI load routine.
.load:
    call %[PHI_DRIVER].set_gates
    ret

; PHI unload routine.
.unload:
    ret