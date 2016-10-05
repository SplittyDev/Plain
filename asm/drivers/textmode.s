%include "impl/textmode.s"
%[PHI_IMPL]:

section .rodata

; PHI driver name.
.name: db 'VGA Textmode Framebuffer'

section .text

; PHI load routine.
.load:
    ret

; PHI unload routine.
.unload:
    ret