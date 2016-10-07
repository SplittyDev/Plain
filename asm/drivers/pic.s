%include "impl/pic.s"
%[PHI_IMPL]:

section .rodata

; PHI driver name.
.name: db 'Programmable Interrupt Controller'

section .text

; PHI load routine.
.load:
    call pic.remap
    ret

; PHI unload routine.
.unload:
    ret