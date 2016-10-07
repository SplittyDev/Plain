section .text
paging:

;
; Sets the page tables up.
; Registers are preserved.
;
.setup_tables:
    push eax
    mov eax, page_tables.p3
    or eax, 0x03
    mov [page_tables.p4], eax
    mov dword [page_tables.p3], 0x83
    pop eax
    ret

;
; Loads the P4 table into CR3.
; Registers are preserved.
;
.load_p4:
    push eax
    mov eax, page_tables.p4
    mov cr3, eax
    pop eax
    ret

;
; Enables PAE (Physical Address Extension).
; Registers are preserved.
;
.enable_pae:
    push eax
    mov eax, cr4
    or eax, 0x20
    mov cr4, eax
    pop eax
    ret

;
; Enables paging.
; Registers are preserved.
;
.enable_paging:
    push eax
    mov eax, cr0
    or eax, 0x80010000
    mov cr0, eax
    pop eax
    ret