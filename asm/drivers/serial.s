%include "impl/serial.s"
%[PHI_IMPL]:

section .rodata

; PHI driver name.
.name: db 'Serial Port'

section .text

; PHI load routine.
.load:
    kinitcom
    ret

; PHI unload routine.
.unload:
    ret