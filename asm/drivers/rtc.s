%include "impl/rtc.s"
%[PHI_IMPL]:

section .rodata

; PHI driver name.
.name: db 'Real Time Clock'

section .text

; PHI load routine.
.load:
    call %[PHI_DRIVER].enable_interrupts
    ret

; PHI unload routine.
.unload:
    ret