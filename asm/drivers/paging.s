%include "impl/paging.s"
%[PHI_IMPL]:

section .rodata

; PHI driver name.
.name: db 'Paging'

section .text

; PHI load routine.
.load:
    call paging.setup_tables
    call paging.load_p4
    call paging.enable_pae
    call paging.enable_paging
    ret

; PHI unload routine.
.unload:
    ret