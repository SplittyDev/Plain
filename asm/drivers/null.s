%include "impl/null.s"
%[PHI_IMPL]:

section .rodata

; PHI driver name.
.name: db 'NULL'

section .text

; PHI load routine.
.load:
    ret

; PHI unload routine.
.unload:
    ret