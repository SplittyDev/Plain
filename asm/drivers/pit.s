%include "impl/pit.s"
%[PHI_IMPL]:

section .rodata

; PHI driver name.
.name: db 'Programmable Interval Timer'

section .text

; PHI load routine.
.load:
    call pit.set_phase
    ret

; PHI unload routine.
.unload:
    ret