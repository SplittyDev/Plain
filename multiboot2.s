section .multiboot

; Constants
MB_MAGIC    equ 0xe85250d6
MB_ARCH     equ 0
MB_TYPE     equ 0
MB_SIZE     equ 0
MB_FLAGS    equ 0
MB_CHKSUM   equ MB_CHKBNDS - MB_CHKRVAL
MB_LENGTH   equ multiboot.end - multiboot.start

; Helper constants
MB_CHKBNDS  equ 0x100000000
MB_CHKRVAL  equ MB_MAGIC + MB_ARCH + MB_LENGTH

; Memory layout
multiboot:
.start:
    dd MB_MAGIC
    dd MB_ARCH
    dd MB_LENGTH
    dd MB_CHKSUM
    dd MB_TYPE
    dd MB_FLAGS
    dd MB_SIZE
.end: