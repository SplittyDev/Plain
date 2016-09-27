ENTRY(start)

SECTIONS {
  . = 1M;

  .boot : {
    KEEP(*(.multiboot))
  }

  .text : {
    *(.text .text.*)
  }

  .bss : {
    *(.bss)
  }

  .rodata : {
    *(.rodata .rodata.*)
  }

  .data.rel.ro : {
    *(.data.rel.ro.local*) *(.data.rel.ro .data.rel.ro.*)
  }
}