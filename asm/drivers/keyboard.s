%include "impl/keyboard.s"
%[PHI_IMPL]:

section .rodata

; PHI driver name.
.name: db 'PS/2 Keyboard'

section .text

; PHI load routine.
.load:
    ret

; PHI unload routine.
.unload:
    ret